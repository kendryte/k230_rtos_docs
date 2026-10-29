# ADC Hal Interface Document

## Hardware Introduction

The K230 has an integrated ADC converter with 6 channels and a resolution of 12 bits.

---

## Function Interface Description

### `int drv_adc_init(void);`

**Function**: Initialize the ADC driver.

**Return Value**:

* `0`: Initialization successful
* `-1`: Failed to open the device

---

### `int drv_adc_deinit(void);`

**Function**: Deinitialize the ADC driver.

**Return Value**:

* `0`: Success

---

### `uint32_t drv_adc_read(int channel);`

**Function**: Read the raw ADC value (integer, 12-bit) of the specified channel.

**Parameters**:

* `channel`: ADC channel number, range `[0, DRV_ADC_MAX_CHANNEL - 1]`

**Return Value**:

* Valid: ADC raw reading, range `0~4095`
* Invalid: Returns `UINT32_MAX`

---

### `uint32_t drv_adc_read_uv(int channel, uint32_t ref_uv);`

**Function**: Read the voltage value (unit: μV) of the specified channel.

**Parameters**:

* `channel`: ADC channel number
* `ref_uv`: Reference voltage value, in μV (e.g., if using the default 1.8V, pass `DRV_ADC_DEFAULT_REF_UV`)

**Return Value**:

* Converted voltage value (μV)

---

## Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_adc.c`
