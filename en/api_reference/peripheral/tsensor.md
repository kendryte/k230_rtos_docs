# Temperature Sensor HAL Interface Documentation

## Hardware Introduction

The K230 integrates an internal Temperature Sensor for monitoring chip internal temperature. It supports both single sampling and continuous sampling modes, and temperature calibration adjustment can be performed via the trim value.

---

## Macro Definitions

### Operating Modes

- `RT_DEVICE_TS_CTRL_MODE_SINGLE`: Single sampling mode
- `RT_DEVICE_TS_CTRL_MODE_CONTINUUOS`: Continuous sampling mode

### Trim Value Range

- `RT_DEVICE_TS_CTRL_MAX_TRIM`: Maximum trim value (15)

---

## Function Interface Description

### `int drv_tsensor_read_temperature(double *temp);`

**Function**: Read the current temperature value.

**Parameters**:

- `temp`: Pointer used to store the temperature value (unit: degrees Celsius)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_tsensor_set_mode(uint8_t mode);`

**Function**: Set the temperature sensor working mode.

**Parameters**:

- `mode`: Working mode
  - `RT_DEVICE_TS_CTRL_MODE_SINGLE`: Single sampling mode
  - `RT_DEVICE_TS_CTRL_MODE_CONTINUUOS`: Continuous sampling mode

**Return Value**:

- `0`: Success
- `-1`: Failure (invalid mode)

---

### `int drv_tsensor_get_mode(uint8_t *mode);`

**Function**: Get the current working mode.

**Parameters**:

- `mode`: Pointer used to store the working mode

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_tsensor_set_trim(uint8_t trim);`

**Function**: Set the temperature sensor trim value, used for temperature calibration.

**Parameters**:

- `trim`: Trim value, range `[0, 15]`

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_tsensor_get_trim(uint8_t *trim);`

**Function**: Get the current trim value.

**Parameters**:

- `trim`: Pointer used to store the trim value

**Return Value**:

- `0`: Success
- `-1`: Failure

---

## Usage Example

Please refer to `src/rtsmart/examples/peripheral/tsensor/test_tsensor.c`
