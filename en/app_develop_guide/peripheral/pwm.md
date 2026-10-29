# PWM Example

## Introduction

This example is a PWM HAL functional test program, focusing on verifying multi-channel simultaneous output, dynamic adjustment of frequency/duty cycle, and readback verification.

Source location: `src/rtsmart/examples/peripheral/pwm/test_pwm.c`

## Example Behavior

- Map `PWM0`/`PWM1` to `PIN42`/`PIN43` respectively
- Perform dual-channel synchronous output test after PWM initialization
- Dynamically adjust frequency and duty cycle at runtime
- Execute frequency test scenarios such as synchronous/independent/rapid switching
- Finally disable the channel and deinitialize

## Key Interfaces

- `drv_pwm_init()` / `drv_pwm_deinit()`
- `drv_pwm_set_freq()` / `drv_pwm_get_freq()`
- `drv_pwm_set_duty()` / `drv_pwm_get_duty()`
- `drv_pwm_enable()` / `drv_pwm_disable()`
- `drv_fpioa_set_pin_func()`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/pwm
make
./test_pwm
```

This example has no command-line arguments.

```{admonition} Hint
For PWM interface details, please refer to [PWM API Documentation](../../api_reference/peripheral/pwm.md).
```
