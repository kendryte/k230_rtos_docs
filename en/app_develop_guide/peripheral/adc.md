# ADC Example

## Introduction

This example demonstrates the basic usage of the K230 ADC HAL: initializing the ADC, reading raw values from a specified channel, and converting them to voltage values based on the reference voltage.

Source code location: `src/rtsmart/examples/peripheral/adc/test_adc.c`

## Example Behavior

- Supports command-line arguments to select the ADC channel
- Supports selecting the reference voltage (only `1.8V` or `3.6V`)
- Outputs the raw value and converted voltage once per second
- Supports Ctrl+C to exit and deinitialize the ADC

## Key Interfaces

- `drv_adc_init()`
- `drv_adc_read(channel)`
- `drv_adc_read_uv(channel, ref_uv)`
- `drv_adc_deinit()`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/adc
make
```

Run:

```shell
./test_adc [channel] [ref_uv]
```

Parameter description:

- `channel`: ADC channel number, range `0..DRV_ADC_MAX_CHANNEL-1`, default `0`
- `ref_uv`: Reference voltage (microvolts), only `1800000` or `3600000` are supported, default `DRV_ADC_DEFAULT_REF_UV`

Examples:

```shell
./test_adc
./test_adc 1 1800000
./test_adc 2 3600000
```

## Output Example

```text
ADC Test Application
Reading channel 0 with reference 1.80V
Press Ctrl+C to stop...

Channel 0: Raw=0x123 ( 291), Voltage=1.0245V (1024500 uV)
```

```{admonition} Tip
For details on the ADC interface, please refer to the [ADC API Documentation](../../api_reference/peripheral/adc.md).
```
