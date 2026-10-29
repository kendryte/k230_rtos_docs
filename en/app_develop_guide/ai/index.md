# AI Application Development Guide

This chapter focuses on AI scenario development, covering everything from basic inference calls to multi-task, multi-channel input, and complete scenario-based examples.

```{toctree}
:maxdepth: 1
:caption: Detailed Guide

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

The AI application examples for the RT-Smart SDK are located in the `src/rtsmart/examples/ai` directory. To help you progress from "running a demo" to "independent development," we have divided the examples into the following three major categories:

## Core Acceleration Introduction (Basics)

**Objective: Understand K230 hardware acceleration implementation**
If you are new to the Canaan K230 chip, it is recommended that you study these examples first to master the fundamentals of hardware-accelerated computing.

| Application Directory | Function Description | Core Value |
| --- | --- | --- |
| **usage_ai2d** | Demonstrates the **5 types of preprocessing** supported by hardware (cropping, scaling, padding, affine transformation, shifting). | Master how to use the AI2D hardware to **offload CPU pressure**. |
| **usage_kpu** | Using YOLOv8 as an example, this fully demonstrates the complete workflow from model loading, preprocessing, inference, to post-processing. | Learn the **KPU low-level API** call logic and Tensor processing. |

## Classic Task Templates (Advanced)

**Objective: Quickly build applications based on the encapsulated framework**
These examples provide standardized code structures, suitable for quickly familiarizing yourself with AI application development logic and building AI applications based on the encapsulated framework by following the given examples.

| Application Directory | Task Type | Applicable Scenario |
| --- | --- | --- |
| **face_detection** | Single-model task | Develop the most basic single-point AI functionality. |
| **face_recognition** | Multi-model cascade | Learn the pipeline logic of **detection + recognition**. |
| **triple_camera_ai** | Multi-camera vision | Demonstrate the architecture of **three-channel camera input** simultaneously running AI inference. |
| **uvc_face_detection** | UVC input | Learn how to drive a **USB camera (UVC)** for AI analysis. |
| **yolo** | General-purpose encapsulated tool | Highly encapsulated, supports YOLOv5/v8/v11, covering classification, detection, segmentation, and rotated detection. |
| **cloudplat_deploy** | Platform model deployment | Quickly validate models obtained from the online training platform or **AICube**. |

## Scenario-based Applications (Practical)

**Objective: Reference for product-level development solution prototypes**
These examples provide deep encapsulation of underlying multimedia (ISP camera, VO display, video encoding/decoding), primarily demonstrating K230's scenario adaptation capabilities.

| Application Directory | Function Description | Applicable Scenario |
| --- | --- | --- |
| **ai_demo** | Integrates 50+ scenario-based examples, covering object recognition, face detection, gesture recognition, human body recognition, license plate recognition, OCR text recognition, etc. | Evaluate K230's performance upper limit and quickly find business prototypes. |
| **multi_object_tracking** | Integrates various commonly used multi-object tracking (MOT) algorithms. | Suitable for dynamic analysis scenarios such as security surveillance and people flow statistics. |
