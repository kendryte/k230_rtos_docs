# RT-Smart Deployment of Kanzhi Online Training Platform Model

```{attention}
The development logic of this example code is implemented using a single camera with dual channels. For image classification, object detection, semantic segmentation, OCR detection, OCR recognition, metric learning (image feature extraction), and multi-label classification development logic, please refer to the document: [Single Model Development Application Guide](./single_model_example.md). For the dual-model task OCR detection + recognition development logic, please refer to the document: [Dual Model Development Application Guide](./double_model_example.md).
```

## 1. Overview

`cloudplat_deploy_code` encapsulates the code for deploying models from the Kanzhi online training platform. Users need to compile executable files under `rtos_sdk` to deploy the models obtained from the training platform. For the compilation process, see: [How to Build Firmware](https://www.kendryte.com/k230_rtos/zh/main/userguide/how_to_build.html)

## 2. Source Code Description

The `cloudplat_deploy_code` implements a total of 8 tasks supported by the training platform: image classification, object detection, semantic segmentation, OCR detection, OCR recognition, dual-model task OCR detection + recognition, metric learning (image feature extraction), and multi-label classification. The code encapsulates the common parts of model inference, preprocessing utility methods, configuration file parsing, and result rendering, which are placed in the `common_files` directory. Other directories respectively store the inference code for corresponding tasks.

### 3. Code Structure

Below is the description of the code files:

```shell
cloudplat_deploy_code_linux
├── common_files
├── classification              #Image classification task
├── detection                   #Object detection task
├── segmentation                #Semantic segmentation task
├── ocr_detection               #OCR detection task
├── ocr_recognition             #OCR recognition task
├── ocr                         #OCR task
├── metric_learning             #Metric learning task
├── multilabel_classification   #Multi-label classification task
├── utils
│    │- SourceHanSansSC-Normal-Min.ttf  # Font file
│── libs                                # Third-party libraries related to freetype
├── CMakeLists.txt
└── build.sh
```

## 4. Compilation Instructions

### 4.1 Parameter Configuration

You can configure parameters in `setting.h` in `common_files`. The explanation of parameter configuration is as follows, mainly used for configuring the screen display:

|Macro Definition Parameter|Description|
|:-:|:-:|
|`ISP_WIDTH`|ISP output width|
|`ISP_HEIGHT`|ISP output height|
|`DISPLAY_MODE`|Display mode, 0 is 1920×1080 LT9611, 1 is 800×480 ST7701|
|`DISPLAY_WIDTH`|Display screen width|
|`DISPLAY_HEIGHT`|Display screen height|
|`AI_FRAME_WIDTH`|AI inference frame width|
|`AI_FRAME_HEIGHT`|AI inference frame height|
|`AI_FRAME_CHANNEL`|Number of AI inference frame channels|
|`USE_OSD`|Whether to use OSD, 0 is not used, 1 is used|
|`OSD_WIDTH`|OSD layer width, used to display AI inference results|
|`OSD_HEIGHT`|OSD layer height, used to display AI inference results|
|`OSD_CHANNEL`|Number of OSD layer channels|

### 4.2 Source Code Compilation

Enter the `src/rtsmart/examples/ai/cloudplat_deploy_code` directory

```shell
# Enter the directory
cd cloudplat_deploy_code

# Compile the file, all task compilation elf files will be obtained in the k230_bin directory
./build_app.sh

# If you only want to compile the deployment file for a certain task, you can use ./build.sh <task name>
./build_app.sh classification
./build_app.sh detection
...

```

Or directly execute the `make -j` command in this directory, which will compile the deployment files for all tasks.

The compiled output is in the `k230_bin` directory.

### 4.3 On-board Deployment

Copy the obtained `elf file`, font file, and the `kmodel`, `deploy_config.json` obtained from the Kanzhi training platform, and the test images to a directory on the development board, and run the command:

```shell
# Classification - Video inference, enter `q` and press Enter to exit video inference
./classification.elf deploy_config.json None 0

# Classification - Image inference
./classification.elf deploy_config.json test.jpg 0

# Detection - Video inference, enter `q` and press Enter to exit video inference
./detection.elf deploy_config.json None 0

# Detection - Image inference
./detection.elf deploy_config.json test.jpg 0

# Semantic segmentation - Video inference, enter `q` and press Enter to exit video inference
./segmentation.elf deploy_config.json None 0

# Semantic segmentation - Image inference
./segmentation.elf deploy_config.json test.jpg 0

# OCR detection - Video inference, enter `q` and press Enter to exit video inference
./ocr_detection.elf deploy_config.json None 0

# OCR detection - Image inference
./ocr_detection.elf deploy_config.json test.jpg 0

# OCR recognition - Image inference, this task only supports image inference
./ocr_recognition.elf deploy_config.json test.jpg 0

# OCR - Video inference, enter `q` and press Enter to exit video inference
./ocr.elf ocrdet_deploy_config.json ocrrec_deploy_config.json None 0

# OCR - Image inference
./ocr.elf ocrdet_deploy_config.json ocrrec_deploy_config.json test.jpg 0

# Metric learning - Video inference, enter `q` and press Enter to exit video inference
./metric_learning.elf deploy_config.json None 0

# Metric learning - Image inference
./metric_learning.elf deploy_config.json test.jpg 0

# Multi-label classification - Video inference, enter `q` and press Enter to exit video inference
./multilabel_classification.elf deploy_config.json None 0

# Multi-label classification - Image inference
./multilabel_classification.elf deploy_config.json test.jpg 0
```
