# PWM HAL Interface Documentation

## Hardware Introduction

The K230 integrates a PWM controller internally, providing 2 PWM channels with a total of 6 Channels. Among them, Channel 0 ~ 2 belong to one PWM, and Channel 3 ~ 5 belong to another PWM. **Note that the same PWM can only use the same frequency, but the duty cycle can be different**.

---

## Function Interface Description

### `int drv_pwm_init(void);`

**Function**: Initialize the PWM driver.

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_pwm_deinit(void);`

**Function**: Deinitialize the PWM driver and close the device.

**Return Value**:

- `0`: Success

---

### `int drv_pwm_set_freq(int channel, uint32_t freq);`

**Function**: Set the PWM frequency of the specified channel. The current duty cycle is preserved when setting the frequency.

**Parameters**:

- `channel`: PWM channel number, range `[0, 5]`
- `freq`: Frequency value (Hz), cannot be 0

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_pwm_get_freq(int channel, uint32_t* freq);`

**Function**: Get the PWM frequency of the specified channel.

**Parameters**:

- `channel`: PWM channel number, range `[0, 5]`
- `freq`: Pointer used to store the frequency value (Hz)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_pwm_set_duty(int channel, uint32_t duty);`

**Function**: Set the PWM duty cycle of the specified channel.

**Parameters**:

- `channel`: PWM channel number, range `[0, 5]`
- `duty`: Duty cycle (%), range `[0, 100]`

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_pwm_get_duty(int channel, uint32_t* duty);`

**Function**: Get the PWM duty cycle of the specified channel.

**Parameters**:

- `channel`: PWM channel number, range `[0, 5]`
- `duty`: Pointer used to store the duty cycle value (%)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_pwm_enable(int channel);`

**Function**: Enable the PWM output of the specified channel.

**Parameters**:

- `channel`: PWM channel number, range `[0, 5]`

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_pwm_disable(int channel);`

**Function**: Disable the PWM output of the specified channel.

**Parameters**:

- `channel`: PWM channel number, range `[0, 5]`

**Return Value**:

- `0`: Success
- `-1`: Failure

---

## Usage Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_pwm.c`

**Notes**:

1. Before using PWM, the corresponding pin needs to be configured as PWM function through FPIOA.
1. The same PWM channel can only use the same frequency, but the duty cycle can be different.
