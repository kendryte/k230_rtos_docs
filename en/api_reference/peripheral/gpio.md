# GPIO HAL Interface Documentation

## Hardware Introduction

The k230 has 2 GPIO banks, each GPIO bank contains 32 GPIO ports, totaling 64 GPIO ports. Each GPIO port supports input and output functions, and supports rising edge interrupts, falling edge interrupts, high/low level interrupts, and both edge interrupts. The interrupts of each GPIO port of the k230 are independent of each other and do not affect each other.

---

## Data Structure Description

### `gpio_pin_edge_t`

**Description**: GPIO interrupt trigger edge type enumeration.

- `GPIO_PE_RISING`: Rising edge trigger
- `GPIO_PE_FALLING`: Falling edge trigger
- `GPIO_PE_BOTH`: Both edge trigger
- `GPIO_PE_HIGH`: High level trigger
- `GPIO_PE_LOW`: Low level trigger

### `gpio_drive_mode_t`

**Description**: GPIO drive mode enumeration.

- `GPIO_DM_OUTPUT`: Output mode
- `GPIO_DM_INPUT`: Input mode

### `gpio_pin_value_t`

**Description**: GPIO pin level value enumeration.

- `GPIO_PV_LOW`: Low level
- `GPIO_PV_HIGH`: High level

### `drv_gpio_inst_t`

**Description**: GPIO instance structure, containing pin configuration and status information.

---

## Function Interface Description

### `int drv_gpio_inst_create(int pin, drv_gpio_inst_t** inst);`

**Function**: Creates a GPIO instance. Before creation, ensure that the corresponding pin has been configured as a GPIO function via FPIOA.

**Parameters**:

- `pin`: GPIO pin number, range `[0, 71]`
- `inst`: Used to store the pointer to the created GPIO instance

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `void drv_gpio_inst_destroy(drv_gpio_inst_t** inst);`

**Function**: Destroys the GPIO instance and releases resources.

**Parameters**:

- `inst`: Pointer to the GPIO instance pointer

---

### `int drv_gpio_value_set(drv_gpio_inst_t* inst, gpio_pin_value_t val);`

**Function**: Sets the GPIO output value (only valid in output mode).

**Parameters**:

- `inst`: GPIO instance pointer
- `val`: The level value to set (`GPIO_PV_LOW` or `GPIO_PV_HIGH`)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `gpio_pin_value_t drv_gpio_value_get(drv_gpio_inst_t* inst);`

**Function**: Gets the current level value of the GPIO pin.

**Parameters**:

- `inst`: GPIO instance pointer

**Return Value**:

- `GPIO_PV_LOW`: Low level
- `GPIO_PV_HIGH`: High level

---

### `int drv_gpio_mode_set(drv_gpio_inst_t* inst, gpio_drive_mode_t mode);`

**Function**: Sets the GPIO operating mode.

**Parameters**:

- `inst`: GPIO instance pointer
- `mode`: Operating mode (`GPIO_DM_OUTPUT` or `GPIO_DM_INPUT`)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `gpio_drive_mode_t drv_gpio_mode_get(drv_gpio_inst_t* inst);`

**Function**: Gets the current GPIO operating mode.

**Parameters**:

- `inst`: GPIO instance pointer

**Return Value**:

- `GPIO_DM_OUTPUT`: Output mode
- `GPIO_DM_INPUT`: Input mode
- `GPIO_DM_MAX`: Failed to get

---

### `int drv_gpio_register_irq(drv_gpio_inst_t* inst, gpio_pin_edge_t mode, int debounce, gpio_irq_callback callback, void* userargs);`

**Function**: Registers the GPIO interrupt handler. Only pins 0-63 are supported.

**Parameters**:

- `inst`: GPIO instance pointer
- `mode`: Interrupt trigger mode
- `debounce`: Debounce time (unit: ms, minimum value is 10)
- `callback`: Interrupt callback function
- `userargs`: User parameters passed to the callback function

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_gpio_unregister_irq(drv_gpio_inst_t* inst);`

**Function**: Unregisters the GPIO interrupt.

**Parameters**:

- `inst`: GPIO instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_gpio_set_irq(drv_gpio_inst_t* inst, int enable);`

**Function**: Enables or disables the GPIO interrupt.

**Parameters**:

- `inst`: GPIO instance pointer
- `enable`: `1` to enable, `0` to disable

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### Helper Functions

#### `int drv_gpio_get_pin_id(drv_gpio_inst_t* inst);`

**Function**: Gets the pin number corresponding to the GPIO instance.

#### `int drv_gpio_toggle(drv_gpio_inst_t* inst);`

**Function**: Toggles the GPIO output level.

#### `int drv_gpio_enable_irq(drv_gpio_inst_t* inst);`

**Function**: Enables the GPIO interrupt (equivalent to `drv_gpio_set_irq(inst, 1)`).

#### `int drv_gpio_disable_irq(drv_gpio_inst_t* inst);`

**Function**: Disables the GPIO interrupt (equivalent to `drv_gpio_set_irq(inst, 0)`).

**Notes**:

1. Before using GPIO, the corresponding pin must first be configured as a GPIO function via FPIOA
1. The interrupt function only supports pins 0-63
1. The minimum debounce time is 10ms

---

## Usage Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_gpio.c`
