# YOLO 应用指南

## 概述

K230 针对 YOLO 模型中的 YOLOv5、YOLOv8 和 YOLO11 进行了封装，支持分类(classify)、检测(detect) 和分割(segment)三类任务。用户可以灵活的使用参数调用不同的模型，并按照场景需求修改输入模式(video/image)；还可以自由的修改摄像头获取的图像分辨率，以便对 YOLO 的部署进行调优。

## 模型转换

训练模型并转换kmodel的过程请参考：[YOLO大作战](https://www.kendryte.com/k230_canmv/zh/main/zh/example/ai/YOLO%E5%A4%A7%E4%BD%9C%E6%88%98.html#)，按照链接文档转换得到的模型在本文档内均可用。

## YOLO支持

YOLO 代码位于 `src/rtsmart/examples/YOLO` 目录下，代码对AI推理中摄像头、显示部分进行了封装，用户只需要调用接口获取推理帧给到 YOLO 系列模型即可。

### 代码结构

下面是已有代码结构：

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
│    └── CMakeLists.txt
├── utils
├── Makefile
├── CMakeLists.txt
└── build_app.sh
```

### 代码说明

下面对代码文件进行说明：

| 文件名称                    |         作用     |
|--------------------------- | -----------------|
|ai_base.h|提供模型推理过程中使用的接口|
|ai_bash.cc|提供ai_bash.h中定义的模型推理方法的接口实现|
|scoped_timing.hpp|提供计时工具，帮助开发调试|
|pipeline.h|针对视频流推理过程使用的media部分进行类封装，针对 video buffer、屏幕、视频输出、摄像头、视频采集、OSD 初始化等初始化部分封装成统一接口，还提供了获取一帧、释放当前帧、插入帧和销毁 PipeLine 实例的接口|
|pipeline.cc|针对pipeline.h中封装的接口实现 |
|utils.h|提供二进制数据读取，图片保存, 预处理配置等共用工具函数接口|
|utils.cc|提供utils.h中定义的工具函数实现|
|yolo11.h|提供yolo11模型的初始化、前处理、推理、后处理、结果绘制接口|
|yolo11.cc|提供yolo11模型的接口实现|
|yolov5.h|提供yolov5模型的初始化、前处理、推理、后处理、结果绘制接口|
|yolov5.cc|提供yolov5模型的接口实现|
|yolov8.h|提供yolov8模型的初始化、前处理、推理、后处理、结果绘制接口|
|yolov8.cc|提供yolov8模型的接口实现|
|main.cc|主函数实现，基于face_detection.h提供的接口实现具体的AI应用场景|

其中，`utils` 目录下是上板部署使用的示例模型和图片，`build_app.sh` 是编译脚本。

## 应用步骤

### 固件编译

在 `RTOS SDK` 下执行 `make menuconfig`，选择 `RT-Smart Configuration`->`Enable build RTsmart examples`->`Enable build YOLO examples`，选择下方的`Save`->`OK`，保存后退出。这样在编译固件时就可以将yolo示例编译到固件中，烧录固件后在 `/sdcard/elf/examples/yolo` 下可以找到编译好的 `yolo.elf` 可执行文件。

### 代码编译

如果不在编译固件时编译，您也可以选择单独编译yolos示例。进入 `src/rtsmart/examples/YOLO` 目录下，执行 `./build_app.sh` 脚本，编译生成的 `yolo.elf` 可执行文件在 `k230_bin` 目录下，您可以将 `k230_bin` 目录拷贝到已经烧录好的 `TF`卡中。

### 运行参数

下面对上板运行时的参数进行说明：

| 参数名称               | 默认值          | 说明                                                                 |
|------------------------|----------------|----------------------------------------------------------------------|
| `-ai_frame_width`      | 640            | 设置 AI 帧的宽度，默认值为 640，您可以自己选择使用的值。                                      |
| `-ai_frame_height`     | 360            | 设置 AI 帧的高度，默认值为 360，您可以自己选择使用的值。                                      |
| `-display_mode`        | 0              | 设置显示模式，默认值为 0：<br> - 模式 0: LT9611 <br> - 模式 1: ST7701 <br> - 模式 2: HX8377 |
| `-model_type`          | yolov8         | 设置模型类型，默认值为 yolov8，可选值：yolov5/yolov8/yolo11。          |
| `-task_type`           | detect         | 设置任务类型，默认值为 detect，可选值：classify/detect/segment。       |
| `-task_mode`           | video          | 设置任务模式，默认值为 video，可选值：image/video |
| `-image_path`          | test.jpg       | 设置图像路径，默认值为 test.jpg。                                      |
| `-kmodel_path`         | yolov8n.kmodel | 设置 kmodel 路径，默认值为 yolov8n.kmodel。                            |
| `-labels_txt_filepath` | coco_labels.txt| 设置标签文本文件路径，默认值为 coco_labels.txt，每个标签独占一行。                        |
| `-conf_thres`          | 0.35           | 设置置信度阈值，默认值为 0.35。                                        |
| `-nms_thres`           | 0.65           | 设置非极大值抑制阈值，默认值为 0.65。                                  |
| `-mask_thres`          | 0.5            | 设置掩码阈值，默认值为 0.5。                                           |
| `-debug_mode`          | 0              | 设置调试模式，默认值为 0，可选值：0/1，0为不调试，1为调试打印。                                |

### 运行示例

将烧录好的 `TF` 卡插入 `K230` 开发板，上电，使用串口连接开发板，分别运行视频推理命令和图片推理命令，即可看到推理结果。您可以执行 `yolo.elf -help` 查看参数配置。

- 视频推理

```shell
#您可以执行： ./video_run.sh
./yolo.elf -ai_frame_width 640 -ai_frame_height 360 -display_mode 0 -model_type yolov8 -task_type detect -task_mode video -kmodel_path yolov8n.kmodel -labels_txt_filepath coco_labels.txt -conf_thres 0.35 -nms_thres 0.65 -mask_thres 0.5 -debug_mode 0
```

- 图片推理

```shell
#您可以执行：./image_run.sh
./yolo.elf -model_type yolov8 -task_type detect -task_mode image -image_path test.jpg -kmodel_path yolov8n.kmodel -labels_txt_filepath coco_labels.txt -conf_thres 0.35 -nms_thres 0.65 -mask_thres 0.5 -debug_mode 0
```

您可以在部署过程中，按需更换模型、AI帧分辨率、任务类型、任务模式、阈值参数等，其中标签文本文件中，每个标签独占一行。

## 注意事项

- 目前支持的模型为 `yolov5`、`yolov8` 和 `yolo11`。
- 目前支持的任务类型为 `classify`、`detect` 和 `segment`。
- 目前支持的任务模式为 `video` 和 `image`。
- 目前支持的显示模式为 `LT9611`、`ST7701` 和 `HX8377`。
- 在进行调优的过程中，您可以先修改阈值进行调优，然后修改模型量化方式和输入分辨率进行调优。
- 如果将AI帧的分辨率和模型输入分辨率设置为相同值，可以得到较为优化的推理速度。
