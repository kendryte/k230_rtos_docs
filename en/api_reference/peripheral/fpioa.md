# FPIOA HAL Interface Document

## Hardware Introduction

The K230 integrates an internal FPIOA (Field Programmable IO Array) controller, used to manage the function multiplexing of chip pins. This controller supports up to 64 pins, and each pin can be configured with multiple different functions, including but not limited to peripheral functions such as GPIO, UART, SPI, I2C, PWM, etc.

---

## Data Structure Description

### `fpioa_func_t`

**Description**: Defines all available pin functions, including GPIO0~GPIO63 and various peripheral functions (UART, SPI, I2C, PWM, etc.).

### `fpioa_iomux_cfg_t`

**Description**: Pin configuration structure, containing the following configuration bits:

- `st`: Input Schmitt trigger control enable
- `ds`: Drive current control (4 bits)
- `pd`: Pull-down enable
- `pu`: Pull-up enable
- `oe`: Output enable
- `ie`: Input enable
- `msc`: Voltage selection
- `io_sel`: Multiplexing function selection (3 bits)
- `di`: Current PAD input data

---

## Function Interface Description

### `int drv_fpioa_get_pin_cfg(int pin, uint32_t* value);`

**Function**: Get the configuration register value of the specified pin.

**Parameters**:

- `pin`: Pin number, range `[0, 63]`
- `value`: Pointer used to store the configuration value

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_fpioa_set_pin_cfg(int pin, uint32_t value);`

**Function**: Set the configuration register value of the specified pin.

**Parameters**:

- `pin`: Pin number, range `[0, 63]`
- `value`: The configuration value to be set

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_fpioa_get_pin_func(int pin, fpioa_func_t* func);`

**Function**: Get the function currently configured for the specified pin.

**Parameters**:

- `pin`: Pin number, range `[0, 63]`
- `func`: Pointer used to store the function type

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_fpioa_set_pin_func(int pin, fpioa_func_t func);`

**Function**: Set the function of the specified pin. If the function is already assigned to another pin, the configuration of that other pin will be cleared first.

**Parameters**:

- `pin`: Pin number, range `[0, 63]`
- `func`: The function type to be set

**Return Value**:

- `0`: Success
- `-1`: Failure (the pin does not support this function)

---

### `int drv_fpioa_func_available_pins(fpioa_func_t func, int pins[FPIOA_PIN_FUNC_ALT_NUM]);`

**Function**: Get all pins to which the specified function can be assigned.

**Parameters**:

- `func`: Function type
- `pins`: Array used to store pin numbers, up to 4

**Return Value**:

- Number of available pins

---

### `int drv_fpioa_pin_supported_funcs(int pin, fpioa_func_t funcs[FPIOA_PIN_MAX_FUNCS]);`

**Function**: Get all functions supported by the specified pin.

**Parameters**:

- `pin`: Pin number, range `[0, 63]`
- `funcs`: Array used to store function types, up to 5

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_fpioa_get_func_name(fpioa_func_t func, char* buf, size_t buf_size);`

**Function**: Get the name string of the specified function.

**Parameters**:

- `func`: Function type
- `buf`: Buffer used to store the name
- `buf_size`: Buffer size

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_fpioa_get_pin_func_name(int pin, char* buf, size_t buf_size);`

**Function**: Get the name of the current function of the specified pin.

**Parameters**:

- `pin`: Pin number
- `buf`: Buffer used to store the name
- `buf_size`: Buffer size

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_fpioa_get_pin_alt_func_names(int pin, char* buf, size_t buf_size);`

**Function**: Get the names of all optional functions of the specified pin, separated by "/".

**Parameters**:

- `pin`: Pin number
- `buf`: Buffer used to store the names
- `buf_size`: Buffer size

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_fpioa_get_func_assigned_pin(fpioa_func_t func);`

**Function**: Get the pin number currently assigned to the specified function.

**Parameters**:

- `func`: Function type

**Return Value**:

- `>=0`: The pin number assigned to this function
- `-1`: The function is not assigned or is invalid

---

### Pin Parameter Configuration Functions

The following functions are used to configure the electrical characteristic parameters of pins:

#### `int drv_fpioa_set_pin_st(int pin, int value);`

**Function**: Set the Schmitt trigger enable of the pin.

#### `int drv_fpioa_get_pin_st(int pin);`

**Function**: Get the Schmitt trigger enable status of the pin.

#### `int drv_fpioa_set_pin_ds(int pin, int value);`

**Function**: Set the drive current strength of the pin (0-15).

#### `int drv_fpioa_get_pin_ds(int pin);`

**Function**: Get the drive current strength of the pin.

#### `int drv_fpioa_set_pin_pd(int pin, int value);`

**Function**: Set the pull-down resistor enable of the pin.

#### `int drv_fpioa_get_pin_pd(int pin);`

**Function**: Get the pull-down resistor enable status of the pin.

#### `int drv_fpioa_set_pin_pu(int pin, int value);`

**Function**: Set the pull-up resistor enable of the pin.

#### `int drv_fpioa_get_pin_pu(int pin);`

**Function**: Get the pull-up resistor enable status of the pin.

#### `int drv_fpioa_set_pin_oe(int pin, int value);`

**Function**: Set the output enable of the pin.

#### `int drv_fpioa_get_pin_oe(int pin);`

**Function**: Get the output enable status of the pin.

#### `int drv_fpioa_set_pin_ie(int pin, int value);`

**Function**: Set the input enable of the pin.

#### `int drv_fpioa_get_pin_ie(int pin);`

**Function**: Get the input enable status of the pin.

**Parameters**:

- `pin`: Pin number, range `[0, 63]`
- `value`: The value to be set (0 or 1, ds is 0-15)

**Return Value**:

- `>=0`: Success (the get function returns the current value)
- `-1`: Failure

---

## Usage Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_fpioa.c`
