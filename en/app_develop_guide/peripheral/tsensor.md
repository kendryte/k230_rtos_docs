# Temperature Sensor Example

## Introduction

This example demonstrates the HAL call flow for the K230 **built-in temperature sensor**, periodically reading chip temperature and switching between sampling modes and trim calibration values.

Example source code: `src/rtsmart/examples/peripheral/tsensor/test_tsensor.c`

## Example Capabilities

- Set working mode: single sampling / continuous sampling
- Set and read trim calibration value (range `0..15`)
- Periodically read current temperature (unit: degrees Celsius)
- Supports Ctrl+C to exit

## Key Interfaces

- `drv_tsensor_set_mode()` / `drv_tsensor_get_mode()`
- `drv_tsensor_set_trim()` / `drv_tsensor_get_trim()`
- `drv_tsensor_read_temperature()`

Mode constants (from `drv_tsensor.h`):

- `RT_DEVICE_TS_CTRL_MODE_SINGLE`
- `RT_DEVICE_TS_CTRL_MODE_CONTINUUOS`

## Build and Run

### Build

```shell
cd src/rtsmart/examples/peripheral/tsensor
make
```

### Run

```shell
./test_tsensor
```

This example **does not require command-line arguments**.

## Output Description

The example prints the current mode, trim, and temperature values. A typical output is as follows:

```text
mode = 2, trim = 0
temperature = 43.125000
temperature = 43.187500
temperature = 43.125000
mode = 2, trim = 1
temperature = 43.250000
...
```

Behavioral characteristics:

- Read the temperature 3 times for each trim value
- trim increments and loops (`0..RT_DEVICE_TS_CTRL_MAX_TRIM`)
- When trim approaches the upper limit, the example switches between single/continuous modes

## Differences from Previous Description

This example currently covers only the **K230 built-in tsensor HAL**, and does not include DS18B20, external I2C temperature sensors, Fahrenheit conversion, alarm threshold strategies, or other extended example logic.

```{admonition} Tip
For the complete temperature sensor interface and macro definitions, please refer to the [Temperature Sensor API Documentation](../../api_reference/peripheral/tsensor.md).
```
