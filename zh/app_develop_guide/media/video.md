# Video Demo

## 简介

本示例演示了如何使用K230的视频编解码模块（VENC/VDEC），实现视频的编码和解码功能。

## 功能说明

### VENC功能

视频编码模块功能：

- **编码格式支持**：支持H.264、H.265等格式
- **分辨率配置**：支持多种分辨率
- **码率控制**：支持CBR、VBR等码率控制模式
- **帧率设置**：可配置输出帧率
- **GOP配置**：支持GOP大小设置

### VDEC功能

视频解码模块功能：

- **解码格式支持**：支持H.264、H.265等格式
- **硬件加速**：硬件加速解码
- **多路解码**：支持多路同时解码
- **帧输出**：直接输出到VO显示

## 代码位置

Demo 源码位置：`src/rtsmart/examples/mpp/sample_venc`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将Video示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_venc.elf [options]
```

### 参数说明

| 参数名 | 说明 | 默认值 |
|--------|------|--------|
| 编码类型 | h264/h265 | h265 |
| 宽度 | 图像宽度 | 1920 |
| 高度 | 图像高度 | 1080 |
| 帧率 | 帧率 | 30 |
| 码率 | 编码码率 | 4000 |

### 查看结果

程序运行后会：

1. 初始化视频编码器
1. 配置编码参数
1. 开始编码循环
1. 输出编码后的码流

输出示例：

```text
Video Encoder Demo
=================

Initializing VENC module...
VENC initialized successfully

Configuring encoder...
Codec: H.265
Resolution: 1920x1080
Frame rate: 30fps
Bitrate: 4000Kbps

Starting encoding...
Encoding frames...
Frame 1 encoded
Frame 2 encoded
Frame 3 encoded
...

Encoding statistics:
Total frames: 1000
Total bytes: 52428800
Bitrate: 4000Kbps (actual)

Press Ctrl+C to stop.
```

```{admonition} 提示
视频编解码是多媒体处理的核心功能，需要根据实际应用场景选择合适的编码参数。有关视频编解码模块的具体接口，请参考 [视频编解码 API 文档](../../api_reference/mpp/video.md)。
```
