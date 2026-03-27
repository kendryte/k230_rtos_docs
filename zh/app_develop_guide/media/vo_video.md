# VO视频输出 Demo

## 简介

本示例演示了如何使用K230的VO（Video Output）模块进行视频输出。VO模块支持多种输出设备和显示模式。

## 功能说明

### VO功能

本示例展示了VO视频输出的主要功能：

- **多输出设备**：支持HDMI、LCD等多种输出
- **多显示模式**：支持不同的显示模式
- **缩放功能**：支持视频缩放
- **帧率配置**：可配置输出帧率
- **色彩空间**：支持多种色彩空间

### 支持的输出设备

- **HDMI输出**：支持1080P等高分辨率
- **LCD输出**：支持多种LCD面板
- **MIPI输出**：MIPI接口输出
- **BT1120输出**：BT1120数字输出

### 显示特性

- **分辨率**：支持多种分辨率
- **刷新率**：支持60Hz、50Hz等刷新率
- **宽高比**：支持16:9、4:3等宽高比
- **色彩空间**：支持BT.601、BT.709等

## 代码位置

Demo 源码位置：`src/rtsmart/examples/mpp/sample_vo_video`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将VO视频输出示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_vo_video <connector_type> [options]
```

### 参数说明

| 参数名 | 说明 | 参数范围 |
|--------|------|----------|
| connector_type | 连接器类型 | HDMI(101), LCD(20), MIPI等 |
| width | 输出宽度 | 128-3840 |
| height | 输出高度 | 64-2160 |
| frame_rate | 帧率 | 24-60 |

### 查看结果

程序运行后会：

1. 初始化VO模块
1. 配置输出设备
1. 配置输出参数
1. 开始视频输出
1. 支持动态调整输出参数

输出示例：

```text
VO Video Output Demo
====================

Initializing VO module...
VO initialized successfully

Configuring output device...
Connector type: 101 (HDMI)
Output resolution: 1920x1080
Frame rate: 60Hz

Starting video output...
Video output started!

Display info:
Resolution: 1920x1080
Refresh rate: 60Hz
Color space: BT.601
Aspect ratio: 16:9

Use keys to change output settings:
[1] Change resolution
[2] Change frame rate
[3] Change color space
[Q] Quit

Press Ctrl+C to exit.
```

```{admonition} 提示
使用list_connector命令可查看支持的连接器类型和枚举值。VO视频输出是多媒体显示的最终环节，需要与VI、VDEC等模块配合使用。有关VO模块的具体接口，请参考 [显示输出 API 文档](../../api_reference/mpp/display.md)。
```
