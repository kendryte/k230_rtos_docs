# Sensor Demo

## 简介

本示例演示了如何使用K230的Sensor（传感器）模块进行图像采集。Sensor模块支持多种类型的摄像头和传感器，可以实现视频输入、图像捕获等功能。

## 功能说明

### Sensor功能

本示例展示了Sensor模块的主要功能：

- **摄像头初始化**：初始化摄像头传感器
- **图像采集**：实时采集图像数据
- **分辨率配置**：支持多种分辨率设置
- **帧率控制**：可配置采集帧率
- **曝光控制**：支持自动和手动曝光
- **白平衡**：支持白平衡调整

### 支持的传感器类型

- **MIPI CSI**：MIPI接口摄像头
- **DVP**：并行接口摄像头
- **TVP**：TVP系列转接芯片

## 代码位置

当前SDK中未提供独立的 `sample_sensor` 示例。

可参考与传感器采集相关的Demo：`src/rtsmart/examples/mpp/sample_uvc_dev_vicap`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将Sensor示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_uvc_dev_vicap.elf
```

### 查看结果

程序运行后会：

1. 枚举并初始化摄像头
1. 配置采集参数
1. 开始图像采集
1. 将图像输出到显示设备或保存到文件

输出示例：

```text
Sensor Demo
============

Enumerating sensors...
Sensor 1: IMX335 (MIPI CSI)
Sensor 2: OV5640 (MIPI CSI)
Sensor 3: TVP5150 (DVP)

Selecting sensor: IMX335
Sensor initialized!

Configuring capture...
Resolution: 1920x1080
Frame rate: 30fps
Exposure: Auto
White balance: Auto

Starting capture...
Capturing frames...
Frame 1 captured
Frame 2 captured
Frame 3 captured
...

Press Ctrl+C to stop.
```

```{admonition} 提示
Sensor模块是视频输入的基础，使用前需要根据摄像头类型配置相应的参数。有关Sensor模块的具体接口，请参考 [Sensor API 文档](../../api_reference/mpp/sensor.md)。
```
