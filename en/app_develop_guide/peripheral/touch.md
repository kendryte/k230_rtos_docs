# Touch Screen Example

## Introduction

This example demonstrates the touch device point-reading process based on the RT-Smart touch HAL, and includes two modes:

- Read point test using an existing touch device
- Read point test after dynamically creating a device through configuration parameters

Example source code: `src/rtsmart/examples/peripheral/touch/test_touch.c`

## Example Capabilities

- Read and print touch point events (`DOWN`/`MOVE`/`UP`)
- Support multi-touch data reading (example buffer upper limit is 5 points)
- Print device capability information (maximum touch points, coordinate range, etc.)
- Print current touch configuration and default rotation information
- Support Ctrl+C safe exit, and automatically release resources

## Key Interfaces (Corresponding to Actual Code)

- `drv_touch_inst_create()`: Create a touch instance
- `drv_touch_read()`: Read touch point data
- `drv_touch_get_info()`: Query device information
- `drv_touch_get_config()`: Read device configuration
- `drv_touch_get_default_rotate()`: Read default rotation
- `drv_touch_inst_destroy()`: Destroy instance
- `canmv_misc_create_touch_device()`: Dynamically register a touch device
- `canmv_misc_delete_touch_device()`: Delete dynamically registered device

## Compilation and Running

### Compilation

Enable the corresponding example in the SDK root directory and then compile, or compile independently:

```shell
cd src/rtsmart/examples/peripheral/touch
make
```

### Run Mode 1: Test Existing Device

```shell
./test_touch -d 0
```

### Run Mode 2: Test After Dynamically Creating Device

```shell
./test_touch -c --index 1 --range-x 480 --range-y 800 --int-pin 23 --int-value 1 --reset-pin 22 --reset-value 0 --i2c-bus 3 --i2c-speed 400000
```

Note: When the example exits, it will automatically attempt to unregister the touch device created through `-c`.

## Common Parameters

| Parameter | Description |
| --- | --- |
| `-d, --device` | Use an existing touch device ID (default `0`) |
| `-c, --create` | Dynamically create a touch device based on subsequent parameters |
| `--index` | New device index |
| `--range-x`, `--range-y` | Coordinate range |
| `--int-pin`, `--int-value` | Interrupt pin and active level |
| `--reset-pin`, `--reset-value` | Reset pin and active level |
| `--i2c-bus`, `--i2c-speed` | I2C bus number and speed |

## Output Interpretation

The example will print:

- Device basic information: type, vendor, maximum touch points, coordinate range
- Current configuration: I2C, pins, display range, etc.
- Contact details: `event`, `track_id`, `x/y`, `width`, `timestamp`

When there are no events, the example will periodically output `.`, indicating the loop is running normally but currently has no touch data.

```{admonition} Tip
Touch input typically depends on I2C + GPIO (interrupt/reset). It is recommended to confirm pin multiplexing and level configuration first, then perform the touch reading test. For complete interface and call sequence, please refer to the [Touch API Documentation](../../api_reference/peripheral/touch.md).
```
