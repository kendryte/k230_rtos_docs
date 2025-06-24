# ADC Hal 接口文档

## 硬件介绍

K230内部集成了一路ADC转换器，共6个通道，分辨率12bit。

---

## 函数接口说明

### `int drv_adc_init(void);`

**功能**：初始化 ADC 驱动。

**返回值**：

* `0`：初始化成功
* `-1`：打开设备失败

---

### `int drv_adc_deinit(void);`

**功能**：反初始化 ADC 驱动。

**返回值**：

* `0`：成功

---

### `uint32_t drv_adc_read(int channel);`

**功能**：读取指定通道的 ADC 原始值（整数，12bit）。

**参数**：

* `channel`：ADC 通道编号，范围 `[0, DRV_ADC_MAX_CHANNEL - 1]`

**返回值**：

* 有效时：ADC 原始读数，范围 `0~4095`
* 无效时：返回 `UINT32_MAX`

---

### `uint32_t drv_adc_read_uv(int channel, uint32_t ref_uv);`

**功能**：读取指定通道的电压值（单位：μV）。

**参数**：

* `channel`：ADC 通道编号
* `ref_uv`：参考电压值，单位为 μV（如使用默认 1.8V，则传 `DRV_ADC_DEFAULT_REF_UV`）

**返回值**：

* 转换后的电压值（μV）

---

## 示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_adc.c`
