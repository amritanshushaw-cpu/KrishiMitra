"""
SmartFarm Dataset Setup Script for Google Colab
================================================
Automates downloading the exact required sub-folders from Kaggle directly
into Google Colab /content/SmartFarm_Master_Dataset in under 5 minutes.

Prerequisites:
  1. Upload your 'kaggle.json' to /content/ (or set KAGGLE_USERNAME and KAGGLE_KEY)
  2. Run: python setup_dataset_kaggle.py
"""

import os
import shutil
import zipfile

MASTER_DATASET_DIR = "/content/SmartFarm_Master_Dataset"

# 20 Standard Class Folders to create
TARGET_CLASSES = [
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

def init_workspace():
    os.makedirs(MASTER_DATASET_DIR, exist_ok=True)
    for cls in TARGET_CLASSES:
        os.path.join(MASTER_DATASET_DIR, cls)
        os.makedirs(os.path.join(MASTER_DATASET_DIR, cls), exist_ok=True)
    print(f"✅ Created master structure with {len(TARGET_CLASSES)} target folders.")

def setup_kaggle_credentials():
    kaggle_dir = os.path.expanduser("~/.kaggle")
    os.makedirs(kaggle_dir, exist_ok=True)
    if os.path.exists("/content/kaggle.json"):
        shutil.copy("/content/kaggle.json", os.path.join(kaggle_dir, "kaggle.json"))
        os.system("chmod 600 ~/.kaggle/kaggle.json")
        print("✅ Kaggle credentials configured successfully.")
        return True
    elif "KAGGLE_KEY" in os.environ and "KAGGLE_USERNAME" in os.environ:
        print("✅ Kaggle credentials detected from environment variables.")
        return True
    else:
        print("⚠️ Warning: kaggle.json not found in /content/.")
        print("Please upload 'kaggle.json' or download datasets manually.")
        return False

def print_colab_instructions():
    print("""
================================================================================
KAGGLE COMMANDS FOR COLAB NOTEBOOK CELL:
================================================================================
Run these commands in a Colab code cell:

# 1. Download PlantVillage (Tomato, Potato diseases & Healthy)
!kaggle datasets download -d abdallahalidev/plantvillage-dataset -p /content/downloads --unzip

# 2. Download Rice Diseases (Brown Spot, Leaf Blast, Healthy)
!kaggle datasets download -d vbookshelf/rice-leaf-diseases -p /content/downloads/rice --unzip

# 3. Download Pests (Aphids, Whitefly, Rice Stem Borer)
!kaggle datasets download -d nrmenad/ip102-pests -p /content/downloads/pests --unzip

# 4. Download NPK Deficiencies
!kaggle datasets download -d sriramr/rice-leaf-npk-deficiency -p /content/downloads/npk --unzip
================================================================================
""")

if __name__ == "__main__":
    init_workspace()
    setup_kaggle_credentials()
    print_colab_instructions()
