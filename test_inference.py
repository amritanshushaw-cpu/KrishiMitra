"""
SmartFarm AI - Offline TFLite Inference & Advisory Tester
=========================================================
Tests any image file against 'smartfarm_unified.tflite', 'labels.txt',
and queries 'advisory_db.json' to output full diagnosis + treatment.
"""

import os
import sys
import json
import numpy as np
from PIL import Image

try:
    import tensorflow as tf
    Interpreter = tf.lite.Interpreter
except ImportError:
    try:
        from tflite_runtime.interpreter import Interpreter
    except ImportError:
        print("Error: Please install tensorflow (`pip install tensorflow`) or tflite-runtime (`pip install tflite-runtime`).")
        sys.exit(1)


def load_advisory_db(db_path="advisory_db.json"):
    if os.path.exists(db_path):
        with open(db_path, "r", encoding="utf-8") as f:
            return json.load(f).get("advisories", {})
    return {}


def predict_image(image_path, model_path="smartfarm_unified.tflite", labels_path="labels.txt", db_path="advisory_db.json"):
    if not os.path.exists(image_path):
        print(f"Error: Image not found at {image_path}")
        return

    if not os.path.exists(model_path):
        print(f"Error: Model not found at {model_path}. Run training first!")
        return

    # Load labels
    with open(labels_path, "r", encoding="utf-8") as f:
        labels = [line.strip() for line in f.readlines() if line.strip()]

    # Load TFLite interpreter
    interpreter = Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    # Preprocess image
    img = Image.open(image_path).convert("RGB")
    img = img.resize((224, 224))
    input_data = np.expand_dims(np.array(img, dtype=np.float32) / 255.0, axis=0)

    # Invoke interpreter
    interpreter.set_tensor(input_details[0]["index"], input_data)
    interpreter.invoke()
    predictions = interpreter.get_tensor(output_details[0]["index"])[0]

    # Top 3 predictions
    top_indices = np.argsort(predictions)[::-1][:3]
    top_label = labels[top_indices[0]]
    top_conf = predictions[top_indices[0]] * 100.0

    print("=" * 60)
    print(f"📷 Target Image: {image_path}")
    print(f"🏆 Top Prediction: {top_label} ({top_conf:.2f}%)")
    print("-" * 60)
    print("Top 3 Candidates:")
    for rank, idx in enumerate(top_indices, 1):
        print(f"  {rank}. {labels[idx]}: {predictions[idx]*100:.2f}%")
    print("-" * 60)

    # Advisory Lookup
    advisories = load_advisory_db(db_path)
    advisory = advisories.get(top_label)

    if advisory:
        print("\n🌾 SMART ADVISORY DISPATCH")
        print(f"  English Name   : {advisory.get('name_en')}")
        print(f"  Bengali Name   : {advisory.get('name_bn')}")
        print(f"  Category       : {advisory.get('category').upper()}")
        print(f"  Severity       : {advisory.get('severity')}")
        print(f"\n  [Symptoms]")
        print(f"  EN: {advisory.get('symptoms_en')}")
        print(f"  BN: {advisory.get('symptoms_bn')}")
        print(f"\n  [Organic Remedy / জৈব সমাধান]")
        print(f"  EN: {advisory.get('organic_treatment_en')}")
        print(f"  BN: {advisory.get('organic_treatment_bn')}")
        print(f"\n  [Chemical Control / রাসায়নিক সমাধান]")
        print(f"  EN: {advisory.get('chemical_treatment_en')}")
        print(f"  BN: {advisory.get('chemical_treatment_bn')}")
        print(f"\n  🔊 Voice Audio Script (Bengali):")
        print(f"  \"{advisory.get('tts_prompt_bn')}\"")
    else:
        print(f"No custom advisory found for label: {top_label}")

    print("=" * 60)


if __name__ == "__main__":
    test_img = sys.argv[1] if len(sys.argv) > 1 else "sample_leaf.jpg"
    predict_image(test_img)
