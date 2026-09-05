# 🌾 KrishiMitra

**KrishiMitra** is an Edge-Native, 100% Offline Smart Agriculture Compute Hub (Phone-as-the-Brain). Designed for rural farmers, it provides real-time crop disease diagnosis, pest detection, nutrient deficiency analysis, and hardware sensor integration (NPK/Moisture) without requiring an active internet connection.

## 🚀 Key Features
*   **Zero-Latency Offline AI:** A heavily optimized 2.71 MB MobileNetV2 model running directly on the edge via TensorFlow Lite.
*   **4-in-1 Diagnostics:** Identifies 8 diseases, 3 nutrient deficiencies, 3 pests, and 3 growth stages across Tomatoes, Potatoes, and Rice.
*   **Hardware Sensor Fusion:** Integrates via Wi-Fi (ESP32-CAM Static IP http://192.168.4.1) to combine live visual data with soil sensor metrics.
*   **"Phone-as-the-Brain" Architecture:** By offloading compute to the farmer's smartphone, we completely eliminate cloud processing costs and rural connectivity barriers.

---

## 🧠 Machine Learning Engine (/ml_engine)

To balance high diagnostic accuracy with extreme offline mobile performance, the KrishiMitra AI is a **Two-Stage Fine-Tuned Convolutional Neural Network (CNN)**.

> **Dataset Transparency:** The model was trained on a highly curated, 23,000+ image dataset. 
> 🔗 [View the Raw 16.2GB Dataset on Google Drive](https://drive.google.com/file/d/1QkYkow9GoKiYa5Mt3YuDUwlxaEAaqc49/view?usp=sharing)

### Core Architecture
*   **Base Model:** MobileNetV2 (Unfrozen Top-50 layers for fine-tuning)
*   **Custom Head:** GlobalAveragePooling2D -> Dense(256, relu) -> Dropout(0.4) -> Dense(20, softmax)
*   **Input Shape:** (224, 224, 3) RGB, Rescaled to 1./255
*   **Final Validation Accuracy:** ~89.1% (On strictly unseen test data)
*   **Optimization:** Post-Training Quantization (	f.lite.Optimize.DEFAULT)
*   **Final Model Size:** 2.71 MB (Guarantees zero-latency offline inference)

### Diagnostic Targets (20 Classes)
*   **Health Status & Diseases:** Healthy_Potato, Healthy_Rice, Healthy_Tomato, Potato_Early_Blight, Potato_Late_Blight, Rice_Brown_Spot, Rice_Leaf_Blast, Tomato_Early_Blight, Tomato_Late_Blight, Tomato_Leaf_Mold, Tomato_Yellow_Leaf_Curl
*   **Nutrient Deficiencies:** Nitrogen_Deficiency, Phosphorus_Deficiency, Potassium_Deficiency
*   **Pests:** Caterpillar, Grasshopper, Rice_Stem_Hispa
*   **Growth Stages:** Seedling, Vegetative, Flowering_Fruiting

### Training Strategy (Continuous Learning Pipeline)
A professional MLOps two-stage transfer learning approach was utilized:
1.  **Stage 1 (Head Initialization):** Frozen base MobileNetV2 layers to establish basic geometric boundaries.
2.  **Stage 2 (Deep Fine-Tuning):** Unfroze the top 50 layers with a micro-learning rate (1e-5) to force the network to learn highly specific microscopic details (leaf necrosis, blights).
3.  **Dynamic Augmentation:** Handled real-world camera noise via Rotation (25°), Width/Height Shift (15%), Zoom (20%), and Brightness variations.

*Note: You can view the exact training pipeline in ml_engine/SmartFarm.ipynb.*

---

## 📡 Hardware & IoT Integration
KrishiMitra connects directly to an ESP32-based hardware node. 
*   **Communication Protocol:** Local SoftAP Wi-Fi (No cloud required).
*   **Static IP / Endpoint:** http://192.168.4.1/capture
*   **Failover Mechanism:** If the hardware node disconnects in the field, the Flutter app utilizes a bundled asset fallback system to maintain diagnostic capabilities.

---

## 🛠️ Repository Structure
*   **/lib**: The Flutter UI, state management, and Edge-AI inference logic.
*   **/assets/models**: Contains the quantized smartfarm_model.tflite payload.
*   **/assets/data**: Contains the label maps and offline advisory rule-engine (dvisory_db.json).
*   **/ml_engine**: Contains the Jupyter Notebook for cloud retraining, and the comprehensive Model Card.
