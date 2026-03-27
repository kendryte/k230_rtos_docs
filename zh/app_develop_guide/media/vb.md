# VB Demo

## 简介

本示例演示了如何使用K230的VB（Video Buffer）模块。VB模块是视频缓冲区管理模块，用于管理视频帧的分配、释放、传递等操作。

## 功能说明

### VB功能

本示例展示了VB的使用方法：

- **VB池初始化**：创建视频缓冲区池
- **帧分配**：从VB池中分配视频帧
- **帧释放**：释放视频帧回VB池
- **块分配**：分配指定大小的VB块
- **块释放**：释放VB块
- **统计信息**：查询VB使用统计

### VB池特性

- **多格式支持**：支持多种像素格式
- **动态分配**：运行时动态分配和释放
- **内存池**：预分配内存池提高性能
- **零拷贝**：减少内存拷贝操作
- **DMA支持**：支持DMA传输

### 支持的像素格式

- **RGB格式**：RGB565、RGB888、ARGB8888等
- **YUV格式**：YUV420、YUV422、YUV444等
- **压缩格式**：JPEG等

### 主要接口

- `kd_mpi_vb_init()` - 初始化VB模块
- `kd_mpi_vb_deinit()` - 反初始化VB模块
- `kd_mpi_vb_set_config()` - 配置VB参数
- `kd_mpi_vb_create_pool()` - 创建VB池
- `kd_mpi_vb_get_block()` - 获取VB块
- `kd_mpi_vb_release_block()` - 释放VB块
- `kd_mpi_vb_get_supplement_addr()` - 获取补充地址

## 代码位置

Demo 源码位置：`src/rtsmart/examples/mpp/sample_vb`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将VB示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_vb
```

### 查看结果

程序运行后会：

1. 初始化VB模块
1. 创建VB池
1. 分配视频帧
1. 释放视频帧
1. 查询统计信息

输出示例：

```text
Video Buffer Test
================

Initializing VB module...
VB initialized successfully

Creating VB pool...
Pool size: 10 blocks
Block size: 1920x1080
Pixel format: YUV420P
Pool created successfully

Allocating blocks...
Allocated block 1: phys=0x12345678, virt=0x87654321
Allocated block 2: phys=0x12349000, virt=0x87658000
...
Allocated block 10: phys=0x12350000, virt=0x87660000

Releasing blocks...
Released block 1
Released block 2
...
Released block 10

Getting statistics...
Total blocks: 10
Used blocks: 0
Free blocks: 10

Destroying VB pool...
Pool destroyed

All tests completed successfully!
```

### 使用场景

VB主要用于：

- 视频输入（VI）输出缓冲
- 视频解码（VDEC）输出缓冲
- 视频编码（VENC）输入缓冲
- 视频输出（VO）输入缓冲
- AI推理输入缓冲

```{admonition} 提示
VB是多媒体子系统的基础模块，在使用VI、VDEC、VENC、VO等模块时，必须先初始化VB。有关 VB 模块的具体接口，请参考 [系统控制 API 文档](../../api_reference/mpp/mpp_sys.md)。
```
