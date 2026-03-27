# ADC 示例

## 简介

本示例演示 K230 ADC HAL 的基本用法：初始化 ADC、读取指定通道的原始值，并根据参考电压换算为电压值。

源码位置：`src/rtsmart/examples/peripheral/adc/test_adc.c`

## 示例行为

- 支持命令行参数选择 ADC 通道
- 支持选择参考电压（仅 `1.8V` 或 `3.6V`）
- 每秒输出一次原始值与换算电压
- 支持 Ctrl+C 退出并反初始化 ADC

## 关键接口

- `drv_adc_init()`
- `drv_adc_read(channel)`
- `drv_adc_read_uv(channel, ref_uv)`
- `drv_adc_deinit()`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/adc
make
```

运行：

```shell
./test_adc [channel] [ref_uv]
```

参数说明：

- `channel`：ADC 通道号，范围 `0..DRV_ADC_MAX_CHANNEL-1`，默认 `0`
- `ref_uv`：参考电压（微伏），仅支持 `1800000` 或 `3600000`，默认 `DRV_ADC_DEFAULT_REF_UV`

示例：

```shell
./test_adc
./test_adc 1 1800000
./test_adc 2 3600000
```

## 输出示例

```text
ADC Test Application
Reading channel 0 with reference 1.80V
Press Ctrl+C to stop...

Channel 0: Raw=0x123 ( 291), Voltage=1.0245V (1024500 uV)
```

```{admonition} 提示
ADC 接口细节请参考 [ADC API 文档](../../api_reference/peripheral/adc.md)。
```
