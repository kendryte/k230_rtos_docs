# Display Demo

## 简介

VO（Video Output，视频输出）模块主动从内存相应位置读取视频和图形数据，并通过相应的显示设备输出视频和图形。芯片支持的显示/回写设备、视频层和图形层情况。VO demo是对这些接口和功能进行测试。

## 功能说明

### VO功能

本示例展示了VO模块的主要功能：

- **多路输出支持**：支持HDMI、LCD等多种输出设备
- **多层叠加**：支持视频层和图形层的叠加显示
- **OSD显示**：支持OSD（On-Screen Display）文字和图形叠加
- **分辨率设置**：支持多种输出分辨率
- **刷新率配置**：可配置显示刷新率

### 支持的输出设备

- **HDMI**：HDMI输出，支持1080P等高分辨率
- **LCD**：LCD屏幕输出，支持多种LCD面板
- **MIPI**：MIPI接口输出

### 视频层和图形层

- **视频层**：用于显示视频流
- **图形层**：用于显示OSD、UI等图形内容
- **混合模式**：支持多种层混合模式

## 代码位置

当前SDK中可用的显示相关Demo位于：

- `src/rtsmart/examples/mpp/sample_vo_video`
- `src/rtsmart/examples/mpp/sample_vo_osd`
- `src/rtsmart/examples/mpp/sample_vo_mix_order`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将Display示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_vo_video.elf <connector_type> [options]
```

### 参数说明

| 参数名 | 说明 | 参数范围 |
|--------|------|----------|
| connector_type | 连接器类型 | HDMI(101), LCD(20) 等 |

### 查看结果

程序运行后会：

1. 初始化VO模块
1. 配置输出设备
1. 创建视频层和图形层
1. 启动OSD显示
1. 开始视频输出

输出示例：

```text
Display Demo
=============

Initializing VO module...
VO initialized successfully

Configuring output device...
Connector type: 101 (HDMI)
Output resolution: 1920x1080 @ 60Hz

Creating video layers...
Layer 0: Created
Layer 1: Created

Setting up OSD...
OSD configured successfully

Starting video output...
Video output started!
Press Ctrl+C to stop.
```

```{admonition} 提示
使用list_connector命令可查看支持的连接器类型和枚举值。有关VO模块的具体接口，请参考 [显示输出 API 文档](../../api_reference/mpp/display.md)。
```
