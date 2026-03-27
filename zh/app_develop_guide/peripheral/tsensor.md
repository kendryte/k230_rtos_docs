# 温度传感器示例

## 简介

本示例演示 K230 **内置温度传感器**的 HAL 调用流程，周期性读取芯片温度，并切换采样模式与 trim 校准值。

示例源码：`src/rtsmart/examples/peripheral/tsensor/test_tsensor.c`

## 示例能力

- 设置工作模式：单次采样/连续采样
- 设置和读取 trim 校准值（范围 `0..15`）
- 周期读取当前温度（单位：摄氏度）
- 支持 Ctrl+C 退出

## 关键接口

- `drv_tsensor_set_mode()` / `drv_tsensor_get_mode()`
- `drv_tsensor_set_trim()` / `drv_tsensor_get_trim()`
- `drv_tsensor_read_temperature()`

模式常量（来自 `drv_tsensor.h`）：

- `RT_DEVICE_TS_CTRL_MODE_SINGLE`
- `RT_DEVICE_TS_CTRL_MODE_CONTINUUOS`

## 编译与运行

### 编译

```shell
cd src/rtsmart/examples/peripheral/tsensor
make
```

### 运行

```shell
./test_tsensor
```

该示例**不需要命令行参数**。

## 输出说明

示例会打印当前 mode、trim 以及温度值。典型输出如下：

```text
mode = 2, trim = 0
temperature = 43.125000
temperature = 43.187500
temperature = 43.125000
mode = 2, trim = 1
temperature = 43.250000
...
```

行为特征：

- 每个 trim 值下读取 3 次温度
- trim 递增并循环（`0..RT_DEVICE_TS_CTRL_MAX_TRIM`）
- trim 走到上限附近时，示例在单次/连续模式间切换

## 与旧描述的差异

本示例当前仅覆盖 **K230 内置 tsensor HAL**，不包含 DS18B20、外接 I2C 温度传感器、华氏度换算、报警阈值策略等扩展示例逻辑。

```{admonition} 提示
温度传感器完整接口与宏定义请参考 [温度传感器 API 文档](../../api_reference/peripheral/tsensor.md)。
```
