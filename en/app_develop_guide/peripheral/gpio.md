# GPIO Example

## Introduction

This example is a GPIO HAL regression test program, covering core capabilities such as instance creation, mode switching, level read/write, toggle, and interrupt registration.

Source code location: `src/rtsmart/examples/peripheral/gpio/test_gpio.c`

## Example Behavior

- Use FPIOA to map test pins to GPIO function
- Test GPIO instance creation/destruction and exception parameters
- Test input/output mode switching and status reading
- Test high/low level writing and `toggle`
- Test interrupt registration, triggering, and unregistration process

## Key Interfaces

- `drv_fpioa_set_pin_func()`
- `drv_gpio_inst_create()` / `drv_gpio_inst_destroy()`
- `drv_gpio_mode_set()` / `drv_gpio_mode_get()`
- `drv_gpio_value_set()` / `drv_gpio_value_get()` / `drv_gpio_toggle()`
- `drv_gpio_register_irq()` / `drv_gpio_unregister_irq()` (covered by the example interrupt test)

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/gpio
make
./test_gpio
```

This example has no command-line arguments.

```{admonition} Tip
For GPIO interface details, please refer to the [GPIO API Documentation](../../api_reference/peripheral/gpio.md).
```
