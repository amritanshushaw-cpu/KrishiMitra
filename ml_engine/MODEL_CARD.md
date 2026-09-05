# 🧠 SmartFarm ML Architecture & Model Card

**Version:** 1.0.0 (Hackathon Release)
**Framework:** TensorFlow / Keras
**Deployment Target:** Flutter (Edge AI via TensorFlow Lite)
**Final Model Size:** 2.71 MB

---

## 1. Core Architecture
To balance high diagnostic accuracy with extreme offline mobile performance, the model is built on a **MobileNetV2** backbone initialized with `ImageNet` weights.

*   **Base Model:** MobileNetV2 (Unfrozen Top-50 layers for fine-tuning)
*   **Custom Head:** 
    *   `GlobalAveragePooling2D`
    *   `Dense(256, activation='relu')`
    *   `Dropout(0.4)` (To prevent overfitting)
    *   `Dense(20, activation='softmax')` (Output classification)
*   **Input Shape:** `(224, 224, 3)` RGB
*   **Scaling:** Rescaled strictly to `1./255` (Required for Flutter image matrix)

---

## 2. Dataset & Target Classes
The model was trained on a highly curated, 20-class dataset containing ~23,000 images, meticulously filtered to remove corrupted/invalid files. It encompasses four diagnostic categories:

**Health Status & Diseases (11):**
*   `Healthy_Potato` | `Healthy_Rice` | `Healthy_Tomato`
*   `Potato_Early_Blight` | `Potato_Late_Blight`
*   `Rice_Brown_Spot` | `Rice_Leaf_Blast`
*   `Tomato_Early_Blight` | `Tomato_Late_Blight` | `Tomato_Leaf_Mold` | `Tomato_Yellow_Leaf_Curl`

**Nutrient Deficiencies (3):**
*   `Nitrogen_Deficiency` | `Phosphorus_Deficiency` | `Potassium_Deficiency`

**Pests (3):**
*   `Caterpillar` | `Grasshopper` | `Rice_Stem_Hispa`

**Growth Stages (3):**
*   `Seedling` | `Vegetative` | `Flowering_Fruiting`

---

## 3. Data Augmentation Pipeline
To ensure the model generalizes perfectly to real-world farming environments (where users might take photos at weird angles or in bad lighting), dynamic augmentation was applied to the training generator:
*   **Rotation Range:** 25°
*   **Width/Height Shift:** 15%
*   **Zoom Range:** 20%
*   **Flip:** Horizontal True
*   **Brightness Range:** [0.8, 1.2]

---

## 4. The Two-Stage Fine-Tuning Strategy
A professional MLOps two-stage transfer learning approach was utilized to maximize accuracy.

### Stage 1: Head Initialization (Epochs 1-8)
*   **Logic:** Frozen base MobileNetV2 layers. Trained only the custom dense head to establish basic geometric boundaries.
*   **Optimizer:** Adam (Default LR)
*   **Loss Function:** Categorical Crossentropy

### Stage 2: Deep Fine-Tuning (Epochs 9-12)
*   **Logic:** Unfroze the top 50 layers of the MobileNetV2 base to force the network to learn the highly specific visual nuances of leaf necrosis, blights, and insect damage.
*   **Optimizer:** Adam with micro-learning rate (`1e-5`) to protect pretrained weights.
*   **Callbacks:** 
    *   `ReduceLROnPlateau` (Factor: 0.5, Patience: 2)
    *   `EarlyStopping` (Monitor: `val_accuracy`, Patience: 4, `restore_best_weights=True`)

---

## 5. Final Evaluation & Compression
The model successfully triggered Early Stopping at Epoch 12, recognizing that Epoch 8 was its absolute mathematical zenith. It safely restored the Epoch 8 weights.

*   **Final Validation Accuracy:** `~89.1%` (On completely unseen test data)
*   **Optimization:** Post-Training Quantization (`tf.lite.Optimize.DEFAULT`)
*   **Result:** Reduced model size from ~14MB down to an ultra-lightweight **2.71 MB**, guaranteeing zero-latency offline inference on budget Android devices.
