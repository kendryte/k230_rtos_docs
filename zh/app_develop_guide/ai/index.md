# AI 应用开发指南

本章节聚焦 AI 场景开发，覆盖从推理基础调用到多任务、多路输入和完整场景化示例。

```{toctree}
:maxdepth: 1
:caption: 详细指南

nncase.md
usage_ai2d.md
usage_kpu.md
single_model_example.md
double_model_example.md
triple_camera_ai_example.md
uvc_face_detection.md
yolo.md
cloudplat_deploy.md
aidemo.md
multi_object_tracking.md

```

RT-Smart SDK 的 AI 应用示例位于 `src/rtsmart/examples/ai` 目录下。为了帮助你实现从“跑通 Demo”到“自主开发”的跨越，我们将示例划分为以下三大类：

## 核心加速入门 (基础)

**目标：理解 K230 硬件加速实现**
如果你是首次接触嘉楠 K230 芯片，建议首先研读此类示例，掌握硬件计算加速的基础。

| 应用目录 | 功能说明 | 核心价值 |
| --- | --- | --- |
| **usage_ai2d** | 演示硬件支持的 **5 种预处理**（裁剪、缩放、填充、仿射变换、移位）。 | 掌握如何利用 AI2D 硬件**卸载 CPU 压力**。 |
| **usage_kpu** | 以 YOLOv8 为例，完整展示从加载模型、预处理、推理到后处理的全流程。 | 学习 **KPU 底层 API** 调用逻辑及 Tensor 处理。 |

## 经典任务模板 (进阶)

**目标：基于封装框架快速仿写应用**
此类示例提供了标准化的代码结构，适合快速熟悉AI应用的开发逻辑，并仿照给出的示例构建基于封装框架的 AI 应用。

| 应用目录 | 任务类型 | 适用场景 |
| --- | --- | --- |
| **face_detection** | 单模型任务 | 开发最基础的单点 AI 功能。 |
| **face_recognition** | 多模型串联 | 学习 **检测 + 识别** 的流水线逻辑（Pipeline）。 |
| **triple_camera_ai** | 多摄视觉 | 展示 **三路摄像头输入** 同时挂载 AI 推理的架构。 |
| **uvc_face_detection** | UVC输入 | 学习如何驱动 **USB 摄像头 (UVC)** 进行 AI 分析。 |
| **yolo** | 通用封装工具 | 高度封装，支持 YOLOv5/v8/v11，覆盖分类、检测、分割、旋转检测。 |
| **cloudplat_deploy** | 平台模型部署 | 配合在线训练平台或 **AICube** 得到的模型进行快速验证。 |

## 场景化应用 (实战)

**目标：产品级开发方案原型参考**
此类示例对底层多媒体（ISP 摄像头、VO 显示、视频编解码）做了深度封装，主要展示 K230 的场景适配能力。

| 应用目录 | 功能说明 | 适用场景 |
| --- | --- | --- |
| **ai_demo** | 集成 50+ 场景化示例，涵盖物体识别、人脸检测、手势识别、人体识别、车牌识别、OCR 文字识别等。 | 评估 K230 性能上限，快速寻找业务原型。 |
| **multi_object_tracking** | 集成多种常用多目标跟踪算法（MOT）。 | 适用于安防监控、人流统计等动态分析场景。 |
