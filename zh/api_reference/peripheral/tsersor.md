# 温度传感器 HAL 接口文档

## 硬件介绍

K230 内部集成了温度传感器（Temperature Sensor），用于监测芯片内部温度。支持单次采样和连续采样两种工作模式，可通过 trim 值进行温度校准调整。

---

## 宏定义说明

### 工作模式

- `RT_DEVICE_TS_CTRL_MODE_SINGLE`：单次采样模式
- `RT_DEVICE_TS_CTRL_MODE_CONTINUUOS`：连续采样模式

### Trim 值范围

- `RT_DEVICE_TS_CTRL_MAX_TRIM`：最大 trim 值（15）

---

## 函数接口说明

### `int drv_tsensor_read_temperature(double *temp);`

**功能**：读取当前温度值。

**参数**：

- `temp`：用于存储温度值的指针（单位：摄氏度）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_tsensor_set_mode(uint8_t mode);`

**功能**：设置温度传感器工作模式。

**参数**：

- `mode`：工作模式
  - `RT_DEVICE_TS_CTRL_MODE_SINGLE`：单次采样模式
  - `RT_DEVICE_TS_CTRL_MODE_CONTINUUOS`：连续采样模式

**返回值**：

- `0`：成功
- `-1`：失败（模式无效）

---

### `int drv_tsensor_get_mode(uint8_t *mode);`

**功能**：获取当前工作模式。

**参数**：

- `mode`：用于存储工作模式的指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_tsensor_set_trim(uint8_t trim);`

**功能**：设置温度传感器 trim 值，用于温度校准。

**参数**：

- `trim`：trim 值，范围 `[0, 15]`

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_tsensor_get_trim(uint8_t *trim);`

**功能**：获取当前 trim 值。

**参数**：

- `trim`：用于存储 trim 值的指针

**返回值**：

- `0`：成功
- `-1`：失败

---

## 使用示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_tsensor.c`
