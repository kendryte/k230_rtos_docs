# Rotary Encoder Example

## Introduction

This example demonstrates the blocking read flow for rotary encoder events, including rotation direction, cumulative count, and key long-press reset logic.

Source location: `src/rtsmart/examples/peripheral/rotary_encoder/test_rotary_encoder.c`

## Example Behavior

- By default, the encoder is created using the following pins:
  - `clk_pin = 5`
  - `dt_pin = 42`
  - `sw_pin = 43`
- Call `rotary_encoder_wait_event()` to block and wait for events
- Print `delta`, `total_count`, direction, and timestamp
- Press and hold the key for 2 seconds to execute `rotary_encoder_reset()`

## Run Parameters

```shell
./test_rotary_encoder [timeout_ms]
```

- `timeout_ms`: blocking wait timeout, default `-1` (handled by example logic)

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/rotary_encoder
make
./test_rotary_encoder
```

## Notes

1. `CONFIG_ENABLE_ROTARY_ENCODER` must be enabled, otherwise the example will prompt that the configuration is not turned on.
1. The pins are example default values; if they do not match the board wiring, modify the source code parameters accordingly.

```{admonition} Tip
There is currently no standalone rotary page in the API reference. You may refer to the [Peripheral API Index](../../api_reference/peripheral/index.md) first.
```
