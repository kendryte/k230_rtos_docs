# YOLO Application Guide

```{attention}
The development logic of YOLO deployment code uses single-camera dual-channel implementation. For the development logic, please refer to the document: [Single Model Development Application Guide](./single_model_example.md).
```

## Overview

The K230 platform provides a unified wrapper for the YOLO series of models, supporting **YOLOv5, YOLOv8, YOLO11, and YOLO26** four models, covering **image classification (classify), object detection (detect), instance segmentation (segment), rotated object detection (obb, only yolov8/yolo11/yolo26), and keypoint detection (pose, only yolov8/yolo11/yolo26)** five mainstream visual tasks.

Users can flexibly switch between different model types through parameters and choose input modes (video / image) according to actual application scenarios. It also supports custom camera capture resolutions, facilitating comprehensive tuning of model performance, speed, and accuracy during actual deployment.

## Model Conversion

For the model training and kmodel conversion process, please refer to the official document **[YOLO Big Battle](https://www.kendryte.com/k230_canmv/zh/main/zh/example/ai/yolo_battle.html)**. After completing the model conversion following the steps in that link, the generated YOLO kmodel files can be directly adapted and used for the functions and examples described in this document.

## YOLO Support

The YOLO code is located in the `src/rtsmart/examples/ai/yolo` directory. The code wraps the camera and display parts in AI inference. Users only need to call the interface to obtain inference frames and pass them to the YOLO series models.

### Code Structure Introduction

The following is the existing code structure:

``` shell
|YOLO
├── cmake
├── src
│    ├── ai_base.cc
│    ├── ai_base.h
│    ├── main.cc
│    ├── pipeline.cc
│    ├── pipeline.h
│    ├── scoped_timing.hpp
│    ├── utils.cc
│    ├── utils.h
│    ├── yolo11.cc
│    ├── yolo11.h
│    ├── yolov5.cc
│    ├── yolov5.h
│    ├── yolov8.cc
│    ├── yolov8.h
│    ├── yolo26.cc
│    ├── yolo26.h
│    └── CMakeLists.txt
├── utils
├── Makefile
├── CMakeLists.txt
└── build_app.sh
```

### Code Description

The following describes the code files:

| File Name                    |         Function     |
|--------------------------- | -----------------|
|ai_base.h|Provides interfaces used during model inference|
|ai_bash.cc|Provides interface implementations for the model inference methods defined in ai_bash.h|
|scoped_timing.hpp|Provides timing utilities to assist in development and debugging|
|pipeline.h|Provides class wrappers for the media components used in video stream inference, wrapping initialization parts such as screen, video output, camera, video capture, and OSD into unified interfaces, and also provides interfaces for getting a frame, releasing the current frame, inserting a frame, and destroying the PipeLine instance|
|pipeline.cc|Provides the interface implementations wrapped in pipeline.h |
|utils.h|Provides common utility function interfaces such as binary data reading, image saving, and preprocessing configuration|
|utils.cc|Provides implementations of the utility functions defined in utils.h|
|yolo11.h|Provides interfaces for initialization, preprocessing, inference, postprocessing, and result drawing of the yolo11 model|
|yolo11.cc|Provides interface implementations for the yolo11 model|
|yolov5.h|Provides interfaces for initialization, preprocessing, inference, postprocessing, and result drawing of the yolov5 model|
|yolov5.cc|Provides interface implementations for the yolov5 model|
|yolov8.h|Provides interfaces for initialization, preprocessing, inference, postprocessing, and result drawing of the yolov8 model|
|yolov8.cc|Provides interface implementations for the yolov8 model|
|yolo26.h|Provides interfaces for initialization, preprocessing, inference, postprocessing, and result drawing of the yolo26 model|
|yolo26.cc|Provides interface implementations for the yolo26 model|
|main.cc|Implementation of the main function, which implements specific AI application scenarios based on the interfaces provided by face_detection.h|

Among them, the `utils` directory contains the example models and images used for on-board deployment, and `build_app.sh` is the compilation script.

## Compile Code

### Switch Development Board and Compile Application

Return to the `RTOS` root directory and view the supported development boards:

```shell
make list-def
```

Switch the development board to use and compile, switch to the development board you are using:

```shell
make ***_defconfig

make -j
```

After execution completes, the compiled image will be generated in the `output` directory.

- **Compilation Method One**

After the code modifications described in the above sections are completed, go to the same level directory as `build_app.sh` and execute:

```bash
build_app.sh
```

After the script execution is completed, the compilation intermediate products are located in the `build` directory, and the deployment summary file is located in the `k230_bin` directory.

- **Compilation Method Two**

Execute `make menuconfig` in the `RTOS SDK` root directory, select `RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build YOLO Programs`, save and exit. As shown in the figure below:

![rtos_yolo_menuconfig](https://www.kendryte.com/api/post/attachment?id=844)

Because the `Makefile file` is provided, directly execute

```bash
make -j
```

This way the deployment summary file will be directly compiled into the `/sdcard/app/examples/ai/yolo` directory in the firmware during the compilation process, just flash the new firmware.

You can also **directly go to the corresponding directory** and execute:

```bash
make -j
```

This command can also implement individual compilation, and the compilation product will be generated in the `k230_bin` directory. The compilation process implements incremental compilation.

### Running Parameter Description

The parameters for running on the board are described below:

| Parameter Name          | Default Value   | Description                                                                 |
|------------------------|----------------|----------------------------------------------------------------------|
| `-ai_frame_width`      | 640            | Set the AI frame width, the default value is 640, you can choose the value you want to use.                                      |
| `-ai_frame_height`     | 360            | Set the AI frame height, the default value is 360, you can choose the value you want to use.                                      |
| `-display_mode`        | 0              | Set the display mode, the default value is 0:<br> - Mode 0: LT9611 <br> - Mode 1: ST7701 <br> - Mode 2: HX8377 |
| `-model_type`          | yolov8         | Set the model type, the default value is yolov8, optional values: yolov5/yolov8/yolo11/yolo26.          |
| `-task_type`           | detect         | Set the task type, the default value is detect, optional values: classify/detect/segment/obb/pose.       |
| `-task_mode`           | video          | Set the task mode, the default value is video, optional values: image/video |
| `-image_path`          | test.jpg       | Set the image path, the default value is test.jpg.                                      |
| `-kmodel_path`         | yolov8n.kmodel | Set the kmodel path, the default value is yolov8n.kmodel.                            |
| `-labels_txt_filepath` | coco_labels.txt| Set the label text file path, the default value is coco_labels.txt, each label occupies one line.                        |
| `-conf_thres`          | 0.35           | Set the confidence threshold, the default value is 0.35.                                        |
| `-nms_thres`           | 0.65           | Set the non-maximum suppression threshold, the default value is 0.65.                                  |
| `-mask_thres`          | 0.5            | Set the mask threshold, the default value is 0.5, specific parameter for segmentation tasks.                          |
| `-kp_num`              | 17             | Set the number of keypoints, the default value is 17 (human skeleton keypoint scenario).                       |
| `-kp_dim`              | 3               | Set the model keypoint dimension, only supports 2/3, the default value is 3 (human skeleton keypoint scenario).       |
| `-debug_mode`          | 0              | Set the debug mode, the default value is 0, optional values: 0/1, 0 means no debug, 1 means debug print.             |

### Running Example

Flash the firmware and power on, refer to the document for firmware flashing: [how_to_flash](../../userguide/how_to_flash.md).

You can see a virtual disk `CanMV` in the drive letter, copy the elf file, kmodel file and other used files such as test images compiled under `k230_bin` to the `CanMV/sdcard` directory.

Then use the serial port debugging tool to connect to the development board, and run the video inference command and image inference command respectively to see the inference results. You can execute `yolo.elf -help` to view the parameter configuration.

- Video Inference

```shell
#You can execute: ./video_run.sh
./yolo.elf -ai_frame_width 640 -ai_frame_height 360 -display_mode 0 -model_type yolov8 -task_type detect -task_mode video -kmodel_path yolov8n.kmodel -labels_txt_filepath coco_labels.txt -conf_thres 0.35 -nms_thres 0.65 -mask_thres 0.5 -debug_mode 0
```

- Image Inference

```shell
#You can execute: ./image_run.sh
./yolo.elf -model_type yolov8 -task_type detect -task_mode image -image_path test.jpg -kmodel_path yolov8n.kmodel -labels_txt_filepath coco_labels.txt -conf_thres 0.35 -nms_thres 0.65 -mask_thres 0.5 -debug_mode 0
```

During the deployment process, you can replace the model, AI frame resolution, task type, task mode, threshold parameters, etc. as needed. In the label text file, each label occupies one line.

## Notes

- The currently supported models are `yolov5`, `yolov8`, `yolo11`, and `yolo26`.
- The currently supported task types are `classify`, `detect`, `segment`, `obb`, and `pose`.
- The currently supported task modes are `video` and `image`.
- The currently supported display modes are `LT9611`, `ST7701`, and `HX8377`.
- During the tuning process, you can first modify the threshold for tuning, and then modify the model quantization method and input resolution for tuning.
- If the resolution of the AI frame and the model input resolution are set to the same value, a relatively optimized inference speed can be obtained.
