# FPIOA Example

## Introduction

This example is used to export the current board-level FPIOA configuration and automatically generate reusable pinmux configuration code snippets.

Source code location: `src/rtsmart/examples/peripheral/fpioa/test_fpioa.c`

## Example Behavior

- Read the register configuration of `IO0..IO63`
- Infer the voltage domain by bank (`BANK_VOL_1V8_MSC` / `BANK_VOL_3V3_MSC`)
- Output the `board_pinmux_cfg` array (can be directly used in board-level configuration code)
- Issue warnings for abnormal configurations (e.g., inconsistent msc within a bank)

## Key Interfaces

- `drv_fpioa_get_pin_cfg()`
- `drv_fpioa_get_pin_func_name()`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/fpioa
make
./test_fpioa
```

This example has no command-line arguments, and the result is output to standard output.

```{admonition} Tip
For FPIOA interface description, please refer to the [FPIOA API Documentation](../../api_reference/peripheral/fpioa.md).
```
