"""
SmartFarm AI - 20-Class Unified Plant Vision Pipeline
=====================================================
Target Model: MobileNetV2 (Transfer Learning + Fine-Tuning)
Target Format: TensorFlow Lite (.tflite) with Dynamic Range Quantization
Runtime: Google Colab (T4 GPU recommended) or Local CUDA GPU
"""

import os
import sys
import glob
import numpy as np
from PIL import Image

import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping, ReduceLROnPlateau

# ==============================================================================
# CONFIGURATION
# ==============================================================================
DATASET_DIR = '/content/SmartFarm_Master_Dataset'  # Adjust path if running locally
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
NUM_CLASSES = 20
PHASE_1_EPOCHS = 10
PHASE_2_EPOCHS = 5
OUTPUT_TFLITE_PATH = 'smartfarm_unified.tflite'
OUTPUT_LABELS_PATH = 'labels.txt'

EXPECTED_CLASSES = [
    "Nutrient___Nitrogen_Deficiency",
    "Nutrient___Phosphorus_Deficiency",
    "Nutrient___Potassium_Deficiency",
    "Pest___Aphids",
    "Pest___Rice_Stem_Borer",
    "Pest___Whitefly",
    "Potato___Early_Blight",
    "Potato___Healthy",
    "Potato___Late_Blight",
    "Rice___Brown_Spot",
    "Rice___Healthy",
    "Rice___Leaf_Blast",
    "Stage___Flowering_Fruiting",
    "Stage___Seedling",
    "Stage___Vegetative",
    "Tomato___Early_Blight",
    "Tomato___Healthy",
    "Tomato___Late_Blight",
    "Tomato___Leaf_Mold",
    "Tomato___Yellow_Leaf_Curl_Virus"
]

# ==============================================================================
# 1. HARDWARE & GPU VERIFICATION
# ==============================================================================
print("=" * 60)
print("1. HARDWARE & GPU CHECK")
print("=" * 60)
gpus = tf.config.list_physical_devices('GPU')
if gpus:
    print(f"✅ GPU Detected: {gpus[0].name}")
    try:
        tf.config.experimental.set_memory_growth(gpus[0], True)
    except Exception as e:
        print(f"Memory growth notice: {e}")
else:
    print("⚠️ No GPU detected. Running on CPU (training will be slower).")
    print("👉 In Colab, enable GPU via: Runtime > Change runtime type > T4 GPU")

# ==============================================================================
# 2. DATASET SANITY & HYGIENE CHECK
# ==============================================================================
def clean_and_verify_dataset(root_dir):
    print("\n" + "=" * 60)
    print("2. DATASET HYGIENE & SANITY CHECK")
    print("=" * 60)
    if not os.path.exists(root_dir):
        print(f"❌ Error: Dataset directory '{root_dir}' not found!")
        print("Please ensure your dataset folder is created and extracted.")
        sys.exit(1)

    existing_folders = sorted([f for f in os.listdir(root_dir) if os.path.isdir(os.path.join(root_dir, f))])
    print(f"Found {len(existing_folders)} class folders in {root_dir}")

    total_clean_images = 0
    corrupted_count = 0

    for folder in existing_folders:
        folder_path = os.path.join(root_dir, folder)
        files = os.listdir(folder_path)
        valid_files = 0

        for fname in files:
            fpath = os.path.join(folder_path, fname)
            # Check for corrupt files or non-images
            try:
                with Image.open(fpath) as img:
                    img.verify()
                valid_files += 1
            except Exception:
                print(f"⚠️ Removing corrupted file: {fpath}")
                os.remove(fpath)
                corrupted_count += 1

        total_clean_images += valid_files
        status = "✅" if valid_files >= 100 else "⚠️ (Low count)"
        print(f"  {status} {folder}: {valid_files} valid images")

    print(f"\nTotal Valid Images: {total_clean_images}")
    print(f"Total Corrupted Files Removed: {corrupted_count}")
    return existing_folders

# Run hygiene check
existing_classes = clean_and_verify_dataset(DATASET_DIR)
num_classes_found = len(existing_classes)

if num_classes_found != NUM_CLASSES:
    print(f"⚠️ Warning: Found {num_classes_found} folders instead of expected {NUM_CLASSES}.")
    print(f"Adjusting NUM_CLASSES dynamically to {num_classes_found}...")
    NUM_CLASSES = num_classes_found

# ==============================================================================
# 3. DATA AUGMENTATION & PIPELINE
# ==============================================================================
print("\n" + "=" * 60)
print("3. PREPARING DATA GENERATORS WITH FARM AUGMENTATION")
print("=" * 60)

datagen = ImageDataGenerator(
    rescale=1.0 / 255.0,
    rotation_range=25,
    width_shift_range=0.15,
    height_shift_range=0.15,
    zoom_range=0.2,
    horizontal_flip=True,
    brightness_range=[0.8, 1.2],
    fill_mode='nearest',
    validation_split=0.20  # 80% train, 20% validation
)

print("Loading training data (80% split)...")
train_generator = datagen.flow_from_directory(
    DATASET_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='training',
    shuffle=True
)

print("Loading validation data (20% split)...")
val_generator = datagen.flow_from_directory(
    DATASET_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='validation',
    shuffle=False
)

# Export exact sorted labels matching Keras index order
sorted_labels = [k for k, v in sorted(train_generator.class_indices.items(), key=lambda item: item[1])]
with open(OUTPUT_LABELS_PATH, 'w', encoding='utf-8') as f:
    f.write('\n'.join(sorted_labels))
print(f"✅ Exported '{OUTPUT_LABELS_PATH}' ({len(sorted_labels)} labels).")

# ==============================================================================
# 4. ARCHITECTURE: MOBILENETV2 TRANSFER LEARNING
# ==============================================================================
print("\n" + "=" * 60)
print("4. CONSTRUCTING MOBILENETV2 ARCHITECTURE")
print("=" * 60)

# Base model with pre-trained ImageNet weights
base_model = MobileNetV2(
    weights='imagenet',
    include_top=False,
    input_shape=(IMG_SIZE[0], IMG_SIZE[1], 3)
)

# Freeze base feature extractor initially
base_model.trainable = False

# Build custom top classification head
inputs = tf.keras.Input(shape=(IMG_SIZE[0], IMG_SIZE[1], 3))
x = base_model(inputs, training=False)
x = GlobalAveragePooling2D(name='global_avg_pool')(x)
x = Dropout(0.2, name='head_dropout')(x)
x = Dense(128, activation='relu', name='dense_128')(x)
outputs = Dense(NUM_CLASSES, activation='softmax', name='classifier')(x)

model = Model(inputs=inputs, outputs=outputs, name='SmartFarm_MobileNetV2')
model.summary()

# ==============================================================================
# 5. PHASE 1: INITIAL FEATURE EXTRACTION TRAINING
# ==============================================================================
print("\n" + "=" * 60)
print("5. PHASE 1: TRAINING TOP CLASSIFICATION HEAD")
print("=" * 60)

model.compile(
    optimizer=Adam(learning_rate=1e-3),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

callbacks_phase1 = [
    ModelCheckpoint('best_phase1_model.keras', monitor='val_accuracy', save_best_only=True, verbose=1),
    EarlyStopping(monitor='val_loss', patience=3, restore_best_weights=True, verbose=1)
]

history_p1 = model.fit(
    train_generator,
    epochs=PHASE_1_EPOCHS,
    validation_data=val_generator,
    callbacks=callbacks_phase1
)

# ==============================================================================
# 6. PHASE 2: FINE-TUNING DEEP LAYERS
# ==============================================================================
print("\n" + "=" * 60)
print("6. PHASE 2: FINE-TUNING TOP 20 MOBILENETV2 LAYERS")
print("=" * 60)

# Unfreeze base model and make top 20 layers trainable
base_model.trainable = True
for layer in base_model.layers[:-20]:
    layer.trainable = False

print(f"Trainable layers in base model: {sum([1 for l in base_model.layers if l.trainable])} of {len(base_model.layers)}")

# Recompile with very small learning rate to avoid destroying ImageNet representations
model.compile(
    optimizer=Adam(learning_rate=1e-5),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

callbacks_phase2 = [
    ModelCheckpoint('best_smartfarm_model.keras', monitor='val_accuracy', save_best_only=True, verbose=1),
    EarlyStopping(monitor='val_loss', patience=3, restore_best_weights=True, verbose=1),
    ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=2, min_lr=1e-7, verbose=1)
]

history_p2 = model.fit(
    train_generator,
    epochs=PHASE_2_EPOCHS,
    validation_data=val_generator,
    callbacks=callbacks_phase2
)

# ==============================================================================
# 7. EVALUATION ON VALIDATION SET
# ==============================================================================
print("\n" + "=" * 60)
print("7. FINAL EVALUATION")
print("=" * 60)

val_loss, val_acc = model.evaluate(val_generator)
print(f"🏆 Final Validation Accuracy: {val_acc * 100:.2f}%")
print(f"📉 Final Validation Loss: {val_loss:.4f}")

# ==============================================================================
# 8. EXPORT TO OPTIMIZED TFLITE (DYNAMIC RANGE QUANTIZATION)
# ==============================================================================
print("\n" + "=" * 60)
print("8. EXPORTING TO QUANTIZED TFLITE (.tflite)")
print("=" * 60)

# Load best checkpoint
best_model = tf.keras.models.load_model('best_smartfarm_model.keras')

converter = tf.lite.TFLiteConverter.from_keras_model(best_model)
# Enable dynamic range quantization for mobile efficiency (~4x smaller size)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_quantized_model = converter.convert()

with open(OUTPUT_TFLITE_PATH, 'wb') as f:
    f.write(tflite_quantized_model)

tflite_size_mb = os.path.getsize(OUTPUT_TFLITE_PATH) / (1024 * 1024)
print(f"✅ Successfully exported '{OUTPUT_TFLITE_PATH}'")
print(f"📦 Model File Size: {tflite_size_mb:.2f} MB")

# ==============================================================================
# 9. TFLITE RUNTIME VERIFICATION (STANDALONE TEST)
# ==============================================================================
print("\n" + "=" * 60)
print("9. VERIFYING TFLITE INTERPRETER INFERENCE")
print("=" * 60)

interpreter = tf.lite.Interpreter(model_path=OUTPUT_TFLITE_PATH)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print(f"Input Tensor Shape : {input_details[0]['shape']} (dtype: {input_details[0]['dtype']})")
print(f"Output Tensor Shape: {output_details[0]['shape']} (dtype: {output_details[0]['dtype']})")

# Test with a dummy normalized tensor
dummy_input = np.random.uniform(0.0, 1.0, size=input_details[0]['shape']).astype(np.float32)
interpreter.set_tensor(input_details[0]['index'], dummy_input)
interpreter.invoke()
test_output = interpreter.get_tensor(output_details[0]['index'])[0]

top_idx = np.argmax(test_output)
top_confidence = test_output[top_idx]
print(f"Dummy Test Inference Result: Class #{top_idx} ({sorted_labels[top_idx]}) with {top_confidence*100:.1f}% confidence.")

print("\n" + "=" * 60)
print("🎉 SUCCESS! Pipeline Complete.")
print("Deliverables for Flutter App Team (M4/M5):")
print(f"  1. {OUTPUT_TFLITE_PATH} (~{tflite_size_mb:.1f} MB)")
print(f"  2. {OUTPUT_LABELS_PATH} ({len(sorted_labels)} classes)")
print("=" * 60)
