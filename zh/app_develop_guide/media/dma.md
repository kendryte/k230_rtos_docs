# DMA Demo

## 简介

DMA（直接内存访问）硬件被抽象为一个设备，包含八个通道，其中通道0至3为GDMA（图形直接内存访问）通道，通道4至7为SDMA（系统直接内存访问）通道。GDMA主要负责将内存中的图像数据复制到另一块内存中，并可以执行图像旋转和镜像等操作。SDMA则负责将内存中的数据复制到另一块内存中，即传统意义上的DMA。

本示例展示了如何使用GDMA和SDMA，包括绑定模式和非绑定模式的操作方法。DMA功能具有多项关键特性：

- **设备属性配置**：支持配置DMA设备的属性，如突发长度（burst_len）、时钟旁路（ckg_bypass）和未完成事务数（outstanding）等。
- **通道属性设置**：可以精确设置通道的工作模式和图像格式等属性。
- **高效数据处理**：实现图像数据的高效输入、处理和输出，并支持资源的及时释放。
- **模块协同作业**：支持pipeline绑定，确保不同模块间的协同作业，保障数据处理流程的顺畅。

通过这些特性，用户可以灵活地配置和使用DMA，实现高效的数据传输和处理。

## 功能说明

### 非绑定模式

DMA通道分为不同类型，其中通道0至3属于GDMA，通道4至7属于SDMA。在非绑定模式下，各通道执行特定的图像数据处理与传输任务：

- **通道0**：接收分辨率为1920x1080、8位深度、YUV400格式的图像，以单通道模式工作。接收图像后，将其旋转90度再输出，并与golden数据比对，以此校验数据准确性。
- **通道1**：输入分辨率1280x720、8位深度、YUV420格式的图像，采用双通道模式。处理时将图像旋转180度后输出，并与golden数据进行比对验证。
- **通道2**：接收分辨率1280x720、10位深度、YUV420格式的图像，工作在三通道模式。对图像执行x-mirror和y-mirror后输出，并与golden数据比对确认处理结果的正确性。
- **通道4**：以1D模式循环传输一段数据，传输结束后，把传输结果和golden数据进行比对，判断传输是否准确。
- **通道5**：采用2D模式循环传输一段数据，完成传输后，通过与golden数据比对，验证传输数据的准确性。

### 绑定模式

绑定模式下，借助VVI（视频输入接口）模拟DMA的输入。具体绑定关系为：VVI设备0的通道0与DMA的通道0绑定，VVI设备0的通道1与DMA的通道1绑定。

VVI设备按每秒一次的频率向绑定的DMA通道输入图像数据：向通道0输入分辨率640x320、8位深度、YUV400格式且旋转90°的图像；向通道1输入分辨率640x320、8位深度、YUV400格式且旋转180°的图像。

## 使用说明

### 代码位置

绑定模式demo 源码位置：`canmv_k230/src/rtsmart/mpp/userapps/sample/sample_dma`。
非绑定模式demo 源码位置：`canmv_k230/src/rtsmart/mpp/userapps/sample/sample_dma_bind`。

假设您已经正确编译该 demo。启动开发板后，进入 `/sdcard/elf/userapps` 目录，`sample_dma.elf` 和 `sample_dma_bind.elf`为测试 demo。

## 示例

### 非绑定模式demo

在命令行输入`./sample_dma.elf`，即可启动非绑定模式的demo。运行时，屏幕会实时展示测试信息，用于反馈DMA各通道的工作状态。若想停止运行，输入`q`即可。示例输出如下：

```shell
msh /sdcard/app/userapps>./sample_dma.elf
dma sample case, press q to end the operation.
---------------------dma sample test---------------------
dev_attr: burst_len: 0, ckg_bypass: 255, outstanding: 7
**************DMA_CHN0 success**************
**************DMA_CHN1 success**************
**************DMA_CHN2 success**************
**************DMA_CHN4 success**************
**************DMA_CHN5 success**************
loop:00001
**************DMA_CHN0 success**************
**************DMA_CHN1 success**************
**************DMA_CHN2 success**************
**************DMA_CHN4 success**************
**************DMA_CHN5 success**************
loop:00002
**************DMA_CHN0 success**************
**************DMA_CHN1 success**************
**************DMA_CHN2 success**************
**************DMA_CHN4 success**************
**************DMA_CHN5 success**************
loop:00003
```

### 绑定模式demo

在命令行执行`./sample_dma_bind.elf`，启动绑定模式的demo。运行期间屏幕会显示测试信息，输入`q`可结束运行。示例输出如下：

```shell
msh /sdcard/app/userapps>./sample_dma_bind.elf
dma sample case, press q to end the operation.
---------------------dma sample test---------------------
sample_vvi_bind_gdma success
pipe[0] dev[0] h:1920 w:1080 chn[0] h:160 w:320
pipe[1] dev[0] h:1920 w:1080 chn[1] h:160 w:320
```

若要查看底层VVI与DMA的绑定情况，可在命令行输入`cat /proc/umap/sysbind`，示例输出如下：

```shell
-----BIND RELATION TABLE--------------------------------------------------------
    FirMod  FirDev  FirChn  SecMod  SecDev  SecChn  TirMod  TirDev  TirChn    SendCnt     rstCnt
         vvi       0       0     dma       0       0    null       0       0         16          0
         vvi       0       1     dma       0       1    null       0       0         16          0
```

```{admonition} 提示
有关 dma 模块的具体接口，请参考[API文档](../../api_reference/dma.md)
```
