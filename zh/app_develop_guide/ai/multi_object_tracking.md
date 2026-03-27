# 多目标跟踪（MOT）应用开发指南

```{attention}
本示例代码的开发逻辑使用单摄双通道实现，bytetrack和ocsort的开发逻辑参见文档: [单模型开发应用指南](./single_model_example.md), deepsort和botsort开发逻辑参见文档: [双模型开发应用指南](./double_model_example.md)。
```

## 多目标跟踪概述

多目标跟踪（Multi-Object Tracking，MOT）的目标是在视频序列中检测多个目标，并在连续帧之间为每个目标保持一致的身份（ID）。一个典型的 MOT 流水线包括：

1. **目标检测（Object Detection）** —— 使用 YOLO等检测器在每一帧中检测目标（如行人、车辆）。
1. **状态预测（State Prediction）** —— 预测目标在相邻帧之间的运动，通常使用卡尔曼滤波器。
1. **数据关联（Data Association）** —— 基于运动信息、外观特征或两者结合，将当前检测结果与已有轨迹进行匹配。
1. **轨迹管理（Track Management）** —— 初始化新轨迹、更新已有轨迹以及删除丢失轨迹。

本示例支持四种算法，分别为**DeepSORT、ByteTrack、OCSort 和 BoTSORT**。它们在精度、鲁棒性、计算开销以及对外观特征依赖程度方面体现了不同的设计取舍。

## 算法介绍

### DeepSORT

DeepSORT 是经典 SORT（Simple Online and Realtime Tracking）算法的扩展。SORT 仅依赖运动信息（边界框几何关系和卡尔曼滤波预测），而 DeepSORT 引入了**深度外观特征（ReID）**，在遮挡和重新出现（re-identification）场景中显著提升了身份一致性。

**核心组件**：

* **运动模型（Motion Model）**：

  * 恒定速度卡尔曼滤波器
  * 状态通常包含位置、尺度、宽高比及其速度

* **外观模型（Appearance Model）**：

  * 使用深度 CNN 为每个检测目标提取特征嵌入向量
  * 特征通常为 L2 归一化向量（如 512 维）

* **数据关联（Data Association）**：

  * 第一阶段：使用卡尔曼滤波预测进行马氏距离（Mahalanobis）门控
  * 第二阶段：通过匈牙利算法，基于组合代价进行匹配：

    * 运动距离（马氏距离）
    * 外观距离（余弦相似度）

* **轨迹生命周期（Track Lifecycle）**：

  * 轨迹状态包括 *Tentative（暂定）*、*Confirmed（确认）* 和 *Deleted（删除）*
  * 需要连续多次成功匹配后才确认轨迹

### ByteTrack

ByteTrack 是一种现代 MOT 算法，旨在**不使用外观特征**的情况下最大化跟踪性能。其核心思想是：**低置信度检测结果虽然常被丢弃，但仍然包含有价值的运动信息**。传统跟踪器通常只使用高置信度检测进行关联，忽略低置信度检测。ByteTrack 则将检测结果分为：

* **高分检测（High-score detections）**：用于可靠匹配；
* **低分检测（Low-score detections）**：用于恢复可能丢失的轨迹；

匹配过程：

1. **高分匹配阶段**：

   * 使用 IoU 距离将预测轨迹与高置信度检测进行匹配
   * 采用匈牙利算法求解

1. **低分匹配阶段**：

   * 将未匹配的轨迹与低置信度检测进一步匹配
   * 有助于在遮挡或运动模糊情况下恢复目标

1. **轨迹管理**：

   * 新轨迹仅由高分检测初始化
   * 低分检测从不用于创建新轨迹

ByteTrack 的主要特点包括：

* 纯运动建模（卡尔曼滤波 + IoU 匹配）
* 无需 ReID 模型
* 极快且易于部署

### OCSort

OCSort 基于 SORT/ByteTrack 风格的跟踪器进行改进，针对卡尔曼滤波在**剧烈运动或相机移动时运动预测不准确**的问题进行了优化。OCSort 引入**以观测为中心的运动建模（Observation-Centric Motion Modeling）**，更加重视最近的观测结果，而非长期速度估计。

关键技术包括：

* **基于最近观测估计速度**，而非完全依赖卡尔曼状态
* **自适应关联策略**，在以下情况下更加鲁棒：

  * 突然加速
  * 相机抖动或快速平移

OCSort使用与 SORT/ByteTrack 类似的 IoU 匹配，引入方向一致性约束，侧重几何一致性，而非外观特征。

### BoTSORT

BoTSORT 结合了 **ByteTrack** 与 **DeepSORT** 的优势，目标是在保持高速度的同时，实现更强的身份一致性。BoTSORT 集成了：

* **ByteTrack 风格的检测关联策略**（高分与低分检测）
* **可选的基于外观的 ReID 特征**（类似 DeepSORT）
* **相较于经典 SORT 更优的运动建模**

数据关联策略：

1. **主关联阶段**：

   * 将高置信度检测与轨迹进行匹配
   * 代价函数可包含：

     * IoU 距离
     * 外观距离（余弦距离），若启用 ReID

1. **次关联阶段**：

   * 使用低置信度检测匹配剩余轨迹
   * 有助于减少误删除轨迹

### 对比与应用场景

| 算法            | 使用 ReID | 运动模型侧重             | 复杂度 | 核心特点                                                                               |
| ------------- | ------- | ------------------ | --- | ---------------------------------------------------------------------------------- |
| **DeepSORT**  | 是       | 卡尔曼滤波 + 外观特征       | 高   | 引入深度外观特征（ReID），在遮挡和目标重新出现（Re-identification）场景中显著提升身份一致性，ID 稳定性强。                  |
| **ByteTrack** | 否       | 卡尔曼滤波 + IoU        | 低   | 速度快、结构简单。在不使用外观特征的情况下最大化跟踪性能；不仅使用高置信度检测，还利用低置信度检测中的有效运动信息来恢复可能丢失的轨迹。               |
| **OCSort**    | 否       | 以观测为中心的运动模型        | 中   | 引入 **Observation-Centric** 运动建模，基于最近观测估计速度，而不是完全依赖卡尔曼预测，在检测抖动和短时丢失情况下更稳。           |
| **BoTSORT**   | 是       | 卡尔曼滤波 + IoU + ReID | 高   | 引入相机运动补偿（CMC）和改进的卡尔曼状态建模，实现更精确的框定位；融合运动与外观信息，通过多阶段匹配与 IoU + ReID 距离融合策略，复杂场景下表现优异。 |

K230对这些算法集成在同一类应用中，无需重构底层代码，只需切换目标检测模型和调整跟踪算法参数即可快速适配，加快开发落地速度，极大降低开发成本。

## 编译代码

回到 `RTOS` 根目录下，查看支持的开发板：

```shell
make list-def
```

切换使用的开发板并编译，切换您使用的开发板：

```shell
make ***_defconfig

make -j
```

执行结束后，在`output`目录下会生成编译的镜像。

* **编译方法一**

上面章节讲述的代码修改完成后，进入到`src/rtsmart/examples/ai/multi_object_tracking`的同级目录下的某一个算法目录中，执行：

```bash
build_app.sh
```

脚本执行完成后，编译中间产物位于`build`目录下，部署汇总文件位于`k230_bin`目录下。

* **编译方法二**

在`RTOS SDK`根目录下执行`make menuconfig`，选择`RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build MOT(Multi-Object Tracking) Programs`->`Botsort tracking algorithm`，保存并退出。如下图：

![rtos_facedet_menuconfig](https://www.kendryte.com/api/post/attachment?id=849)

因为附带提供了`Makefile文件`，直接执行

```bash
make -j
```

这样部署汇总文件会在编译过程中直接编译到固件中的`/sdcard/app/examples/ai/multi_object_tracking/botsort_track_app`目录下。

也可以**直接进入到对应的目录下**执行：

```bash
make -j
```

该命令也可实现编译，编译产物将生成在`k230_bin` 目录下。编译过程实现了增量编译。

## 开发板部署

烧录固件上电，固件烧录参考文档：[how_to_flash](../../userguide/how_to_flash.md)。

在盘符处可以看到一个虚拟磁盘`CanMV`,将`k230_bin`下编译的elf文件、kmodel文件以及其他使用的文件比如测试图片等拷贝到`CanMV/sdcard`目录下。

然后使用串口工具连接开发板，在命令行执行`run.sh`命令。

程序启动后，你应该可以在屏幕上看到视频输出。部署结果如下图所示：

![multi_object_tracking](https://www.kendryte.com/api/post/attachment?id=851)

如果你想使用 HDMI 显示器进行显示，请修改源文件 `~/canmv_k230/src/rtsmart/examples/ai/multi_object_tracking/botsort_track_app/src/setting.h`，将：

```c
#define DISPLAY_TYPE 'st7701'
```

修改为：

```c
#define DISPLAY_TYPE 'lt9611'
```

然后重新执行上述应用的编译流程。
