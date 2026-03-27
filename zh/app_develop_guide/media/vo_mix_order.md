# VO混合排序 Demo

## 简介

本示例演示了如何使用K230的VO（Video Output）模块进行多路视频的混合和排序显示。该功能常用于多路监控、画中画等场景。

## 功能说明

### VO混合排序功能

本示例展示了VO的混合排序能力：

- **多路视频输入**：支持多路视频同时输入
- **视频混合**：将多路视频混合显示
- **画中画**：支持画中画功能
- **层级管理**：管理不同视频层的显示优先级
- **区域设置**：为每路视频设置显示区域

### 支持的功能

- **多通道输入**：支持多个视频输入通道
- **混合模式**：支持多种混合模式
- **缩放**：支持视频缩放
- **位置调整**：可调整视频显示位置

## 代码位置

Demo 源码位置：`src/rtsmart/examples/mpp/sample_vo_mix_order`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将VO混合排序示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_vo_mix_order
```

### 查看结果

程序运行后会：

1. 初始化VO模块
1. 配置多路视频输入
1. 设置视频混合参数
1. 开始混合显示
1. 支持动态调整视频位置和层级

输出示例：

```text
VO Mix Order Demo
===================

Initializing VO module...
VO initialized successfully

Configuring video mix...
Channel 0: Main video, 1920x1080, Full screen
Channel 1: Sub video 1, 640x480, Position(100,100)
Channel 2: Sub video 2, 640x480, Position(1200,100)
Channel 3: Sub video 3, 640x480, Position(100,600)

Starting video mix...
Video mix started!

Display info:
Main: 1920x1080 @ 30fps
Sub1: 640x480 @ 30fps
Sub2: 640x480 @ 30fps
Sub3: 640x480 @ 30fps

Use keys to adjust video order:
[1] Move sub1 forward
[2] Move sub1 backward
[3] Move sub2 forward
[4] Move sub2 backward
...
[Q] Quit

Press Ctrl+C to exit.
```

```{admonition} 提示
VO混合排序功能可用于多路监控、画中画等应用场景。有关VO模块的具体接口，请参考 [显示输出 API 文档](../../api_reference/mpp/display.md)。
```
