# 三路 AHD 示例

## 简介

本示例演示了如何使用K230芯片实现三路AHD（Analog High Definition）视频输入。AHD是一种模拟高清视频传输技术，支持1080P分辨率的模拟视频传输。

## 功能说明

### AHD特性

本示例展示了三路AHD视频输入的处理：

- **三路视频输入**：同时采集三路AHD视频
- **视频解码**：将AHD模拟信号解码为数字视频
- **视频输出**：将解码后的视频输出到显示设备
- **视频切换**：支持在三路视频之间切换显示

### AHD规格

- **分辨率**：支持720P、1080P等分辨率
- **帧率**：25fps或30fps
- **色彩空间**：YUV422或YUV420
- **信号类型**：AHD、TVI、CVI等

### 主要功能

- AHD视频采集
- 视频解码处理
- 视频显示输出
- 多路视频切换

## 代码位置

Demo 源码位置：`src/rtsmart/examples/integrated_poc/smart_ipc/face_detection`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将三路AHD示例编译进固件，然后编译固件。

### 硬件准备

1. 准备三路AHD摄像头
1. 将三路摄像头连接到K230的AHD输入接口
1. 连接显示设备（HDMI或LCD）

### 运行示例

```shell
./sample_ahd
```

输出示例：

```text
Three-way AHD Demo
=================

Initializing AHD channels...
Channel 1: 1080P @ 30fps
Channel 2: 1080P @ 30fps
Channel 3: 720P @ 25fps

Starting video capture...
Channel 1 active, outputting to display
Use keys 1-3 to switch channels

Press '1' to switch to Channel 1
Press '2' to switch to Channel 2
Press '3' to switch to Channel 3
Press 'q' to quit

Current channel: 1
[Video display...]
```

用户可以通过按键切换显示不同通道的视频。

```{admonition} 提示
AHD摄像头需要专门的AHD输入接口，请确保硬件支持。有关 AHD 模块的具体接口，请参考 [VICAP API 文档](../../api_reference/mpp/vicap.md)。
```
