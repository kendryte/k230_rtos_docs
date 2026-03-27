# VO OSD Demo

## 简介

本示例演示了如何使用K230的VO（Video Output）模块的OSD（On-Screen Display）功能。OSD可以在视频画面上叠加文字、图形、时间等信息。

## 功能说明

### OSD功能

本示例展示了OSD的主要功能：

- **文字显示**：在视频画面上叠加文字信息
- **图形绘制**：在视频画面上绘制图形
- **时间显示**：显示当前时间
- **区域设置**：设置OSD显示区域
- **透明度控制**：支持OSD透明度调整

### 支持的OSD类型

- **文字OSD**：显示文本信息
- **图形OSD**：显示图形元素
- **时间OSD**：显示时间日期
- **LOGO显示**：显示公司LOGO

### OSD特性

- **多图层支持**：支持多个OSD图层
- **颜色配置**：支持多种颜色设置
- **字体配置**：支持不同字体大小
- **动态更新**：支持动态更新OSD内容

## 代码位置

Demo 源码位置：`src/rtsmart/examples/mpp/sample_vo_osd`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将VO OSD示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_vo_osd
```

### 查看结果

程序运行后会：

1. 初始化VO模块
1. 配置视频输出
1. 创建OSD层
1. 配置OSD参数
1. 开始显示OSD内容

输出示例：

```text
VO OSD Demo
=============

Initializing VO module...
VO initialized successfully

Configuring OSD layer...
OSD layer created

Setting OSD content...
Text: "K230 RTOS Demo"
Color: White
Position: Top left
Font: Large

Starting OSD display...
OSD display started!

Display info:
Video: 1920x1080 @ 30fps
OSD layer 1: Active
Text: "K230 RTOS Demo"
Time: 2025-02-03 18:30:00

Use keys to change OSD content:
[1] Change text
[2] Change color
[3] Change position
[T] Update time
[C] Clear OSD
[Q] Quit

Press Ctrl+C to exit.
```

```{admonition} 提示
OSD功能可用于显示状态信息、LOGO、时间等。支持动态更新OSD内容，适用于各种监控和显示场景。有关OSD模块的具体接口，请参考 [显示输出 API 文档](../../api_reference/mpp/display.md)。
```
