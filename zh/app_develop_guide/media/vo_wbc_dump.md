# VO WBC转存 Demo

## 简介

本示例演示了如何使用K230的VO（Video Output）模块的WBC（White Balance Calibration，白平衡校准）转存功能。WBC用于校准显示白平衡，提高显示质量。

## 功能说明

### WBC功能

本示例展示了WBC转存的主要功能：

- **白平衡校准**：自动校准显示白平衡
- **WBC数据转存**：将WBC数据转存到文件
- **WBC参数配置**：配置WBC校准参数
- **质量评估**：评估白平衡校准效果

### WBC特性

- **自动校准**：支持自动白平衡校准
- **手动校准**：支持手动设置白平衡参数
- **温度补偿**：支持温度相关的白平衡补偿
- **数据导出**：支持导出WBC校准数据

### 应用场景

- 显示质量优化
- 白平衡校准
- 显示效果测试
- 生产线校准

## 代码位置

Demo 源码位置：`src/rtsmart/examples/mpp/sample_vo_wbc_dump`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将VO WBC转存示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_vo_wbc_dump [options]
```

### 参数说明

| 参数名 | 说明 | 默认值 |
|--------|------|--------|
| output_file | 输出文件名 | wbc_data.bin |
| calibrate | 是否执行校准 | yes |
| dump_data | 是否转存数据 | yes |

### 查看结果

程序运行后会：

1. 初始化VO模块
1. 配置WBC功能
1. 执行白平衡校准
1. 转存WBC数据到文件
1. 显示校准统计信息

输出示例：

```text
VO WBC Dump Demo
==================

Initializing VO module...
VO initialized successfully

Configuring WBC...
WBC module configured

Starting WBC calibration...
Calibrating white balance...
Channel R: Gain=1.2, Offset=10
Channel G: Gain=1.1, Offset=5
Channel B: Gain=1.15, Offset=8

Calibration completed!

Dumping WBC data...
Data size: 1024 bytes
Output file: wbc_data.bin

Calibration statistics:
R gain: 1.200
G gain: 1.100
B gain: 1.150
R offset: 10
G offset: 5
B offset: 8
Quality score: 95.5

Dump completed!
Press Ctrl+C to exit.
```

```{admonition} 提示
WBC白平衡校准可以显著改善显示质量，建议定期进行校准。有关WBC模块的具体接口，请参考 [显示输出 API 文档](../../api_reference/mpp/display.md)。
```
