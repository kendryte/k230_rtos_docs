# K230 综合demo - 单路智能 IPC

## 功能概述

单路智能 IPC 系统是一款集 **网络推流**、**画面渲染** 和 **人脸识别** 功能于一体的智能监控系统。该系统仅需连接一个摄像头，即可实现以下功能：

- **实时画面显示与人脸识别**：通过 HDMI 输出或 LCD 屏幕实时显示摄像头画面，并对画面中的人脸进行检测和标注。
- **网络视频推流**：将摄像头的实时画面通过网络进行推流，客户端可通过网络流地址查看实时视频。*注意：推流的画面不包含人脸识别的标注信息，仅传输原始视频。*

## 代码编译

项目的源代码位于目录 `canmv_k230/src/rtsmart/examples/integrated_poc/smart_ipc`。

以 01studio 开发板为例，演示整个编译流程：

1. **配置开发板**：

    ```sh
    make k230_canmv_01studio_defconfig
    ```

1. **启用编译该示例**：

    在编译之前，请确保已将示例代码包含在构建配置中。进入项目根目录 `canmv_k230`，运行以下命令：

    ```sh
    make menuconfig
    ```

    在配置界面中，依次选择：

    ```sh
    RT-Smart Configuration > Enable build Rtsmart examples > Enable build integrated examples
    ```

    确认 **Smart IPC examples** 已被启用。如果未启用，请选中它，保存并退出配置界面后，运行以下命令使配置生效：

    ```sh
    make savedefconfig
    ```

1. **编译生成镜像文件**：

    ```sh
    make
    ```

## 使用说明

使用以下命令启动单路智能 IPC 系统：

```sh
cd /sdcard/elf/examples/integrated_poc
./smart_ipc.elf [选项]
```

示例：

- 使用 HDMI 输出：

    ```sh
    ./smart_ipc.elf -C 0
    ```

- 使用 LCD 输出：

    ```sh
    ./smart_ipc.elf -C 1
    ```

查看帮助参数信息：

```sh
./smart_ipc.elf -H
```

以下是详细的命令行参数说明：

| 选项                  | 描述                                   | 默认值                      |
|-----------------------|----------------------------------------|-----------------------------|
| `-H`                  | 显示帮助信息                           | -                           |
| `-a <audio_sample>`   | 音频采样率                             | 8000                        |
| `-c <channel_count>`  | 音频通道数                             | 1                           |
| `-t <codec_type>`     | 视频编码类型，h264/h265                | h264                         |
| `-w <width>`          | 视频编码宽度                           | 1280                        |
| `-h <height>`         | 视频编码高度                           | 720                         |
| `-b <bitrate_kbps>`   | 视频编码码率(kbps)                     | 2000                        |
| `-C <connector_type>` | 视频输出连接类型 (0:HDMI,1:LCD)        | HDMI                        |
| `-A <ai_input_width>` | AI 分析输入宽度                        | 1280                        |
| `-I <ai_input_height>`| AI 分析输入高度                        | 720                         |
| `-K <kmodel_file>`    | kmodel 文件路径                        | face_detection_320.kmodel   |
| `-T <obj_thresh>`     | 人脸检测阈值                           | 0.6                         |
| `-N <nms_thresh>`     | 人脸检测 NMS 阈值                      | 0.4                         |

## 关键代码解析

项目的源代码位于目录 `canmv_k230/src/rtsmart/examples/integrated_poc/smart_ipc`。该目录包含以下关键模块和文件：

- `face_detection`：人脸检测模块，实现人脸识别功能。
- `media.cpp`：媒体处理实现文件，封装了所有 MPI 接口，用于摄像头、显示器和音视频编解码等基础模块的初始化和启动。
- `media.h`：媒体处理头文件，声明媒体处理相关的接口和类。
- `smart_ipc.cpp`：智能 IPC 系统主程序，实现系统的初始化和启动逻辑。
- `smart_ipc.h`：智能 IPC 系统头文件，定义 `MySmartIPC` 类和相关接口。

`MySmartIPC` 类封装了智能摄像头系统的所有功能。在 `main` 函数中，只需实例化该类并调用 `init` 和 `start` 方法即可启动系统。

在 `MySmartIPC` 类内部，通过调用 `KdMedia` 中封装的 MPI 接口，完成了 VB 缓冲区的初始化，以及摄像头、显示器和音视频编解码等功能。通过初始化这些底层 MPI 接口，可以获取以下数据回调：

- 视频编码数据：`OnVEncData`
- 音频编码数据：`OnAEncData`
- AI 模块输入的视频数据：`OnAIFrameData`

此外，`MySmartIPC` 类还引用了 `KdRtspServer` 和 `FaceDetection` 类，分别实现音视频的网络推流和人脸识别功能。在 `OnAIFrameData` 方法中，调用 `FaceDetection` 实现人脸识别，并将检测结果显示在 VO 的 OSD 图层上；在 `OnVEncData` 和 `OnAEncData` 回调中，调用 `KdRtspServer` 实现音视频数据的网络推流。

## 数据流pipeline

该数据流pipeline展示了单路智能 IPC 系统的工作流程。系统启用了摄像头的三路通道，分别用于 HDMI/LCD 屏幕输出、人脸识别数据输入和编码推流。

1. **摄像头输入**：摄像头捕获实时视频数据，视频数据被分成三路进行处理。
1. **HDMI/LCD 输出**：一路视频数据通过 HDMI 或 LCD 屏幕进行实时显示。
1. **人脸识别**：另一路视频数据输入到 AI 模块进行人脸检测和识别。检测到的人脸信息会被标注在视频画面上，并显示在 HDMI/LCD 屏幕上。
1. **编码推流**：最后一路视频数据进行编码处理，通过网络进行视频推流。推流的视频数据不包含人脸识别的标注信息，仅传输原始视频。

该pipeline确保了摄像头捕获的视频数据能够同时用于本地显示、人脸识别和网络推流，满足多种应用需求。

![alt text](https://kendryte-download.canaan-creative.com/developer/pictures/pipeline_1.png)

## 操作演示

要在PC端通过网络获取摄像头的实时流画面，请确保开发板已连接网络并获得有效的IP地址。可以按照以下步骤检查网络配置：

1. 启动开发板后，在串口中输入 `ifconfig`，查看当前开发板的IP地址是否有效。
1. 确保开发板和PC端网络互通，在开发板上输入 `ping <PC_IP>`，检查网络连接。

如果需要通过HDMI输出画面，请将HDMI输出口连接到显示器。如果需要通过LCD屏输出画面，请将LCD屏连接到开发板。完成上述准备工作后，启动开发板并执行以下命令：

```sh
cd /sdcard/elf/examples/integrated_poc
./smart_ipc.elf -C 0 # HDMI输出
./smart_ipc.elf -C 1 # LCD输出
```

同时查看串口输出，会有提示“Play this stream using the URL `rtsp://<IP>:8554/test`”。在PC端使用VLC播放器打开该地址，即可通过网络接收实时画面。

![alt text](https://kendryte-download.canaan-creative.com/developer/pictures/smart_ipc.png)
