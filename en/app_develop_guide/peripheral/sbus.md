# SBUS Example

## Introduction

This example sends SBUS frames via UART3, and dynamically modifies channel values when a button is pressed.

```{warning}
SBUS uses physical UART pins. Before wiring, you must confirm that the development board I/O domain and the receiver signal use the same 1.8 V or 3.3 V voltage level. Do not input 5 V signals. For complete requirements, see [Serial Port Voltage Levels and Adapter Module Safety](./uart.md).
```

Source code location: `src/rtsmart/examples/peripheral/sbus/test_sbus.c`

## Example Behavior

- Configured via FPIOA:
  - `GPIO21` as button input
  - `PIN50` -> `UART3_TXD`
  - `PIN51` -> `UART3_RXD`
- Sends a set of default frames after initialization
- Cycles through channel values and sends when the button is pressed
- The main loop continuously sends SBUS frames at a fixed period

## Key Interfaces

- `drv_fpioa_set_pin_func()`
- `drv_gpio_inst_create()` / `drv_gpio_value_get()`
- `sbus_create()` / `sbus_destroy()`
- `sbus_set_channel()` / `sbus_send_frame()`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/sbus
make
./test_sbus
```

This example has no command-line arguments.

```{admonition} Tip
SBUS uses UART for transmission. For UART-related parameters and interfaces, please refer to the [UART API Documentation](../../api_reference/peripheral/uart.md).
```
