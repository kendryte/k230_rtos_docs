# FFT HAL Example

## Introduction

This example is a basic regression test program for the FFT HAL, focusing on verifying the round-trip precision of FFT and IFFT as well as the runtime for different point sizes.

The example tests the following point sizes in order:

- 64
- 128
- 256
- 512
- 1024
- 2048
- 4096

For each point size, the program will:

1. Generate a set of fixed test signals.
1. Perform one FFT.
1. Perform one IFFT.
1. Compare the maximum error between the recovered data and the original input.
1. Print the timing statistics for FFT/IFFT.

## Code Location

Source code location: `src/rtsmart/examples/peripheral/fft/test_fft.c`

## Key Interfaces

- `drv_fft_open()`
- `drv_fft_get_input_alloc_size()`
- `drv_fft_get_output_alloc_size()`
- `drv_fft_set_input_alloc_size()`
- `drv_fft_set_output_alloc_size()`
- `drv_fft_fft()`
- `drv_fft_ifft()`
- `drv_fft_close()`

## Current HAL Behavior

In the current version, the FFT HAL pre-allocates the input/output MMZ buffers during `drv_fft_open()`. The default size can cover the maximum 4096-point FFT scenario, so the basic regression example does not need to separately allocate DMA space before each run.

If your application needs to control memory usage, you can also manually query or adjust the internal buffer size:

```c
printf("in=%u out=%u\n",
  drv_fft_get_input_alloc_size(inst),
  drv_fft_get_output_alloc_size(inst));
```

```c
drv_fft_set_input_alloc_size(inst, 4096);
drv_fft_set_output_alloc_size(inst, 8192);
```

Note: If a subsequent run requires a buffer larger than the currently allocated size, the FFT HAL will return `-ENOMEM`.

## Build and Run

### Build

```shell
cd src/rtsmart/examples/peripheral/fft
make
```

### Run

After starting the development board, enter the `/sdcard/app/examples/peripheral` directory and run:

```shell
./fft.elf [verbose]
```

## Parameter Description

| Parameter | Description | Default |
| ------ | ---- | ------ |
| `verbose` | Log verbosity level. `0` outputs only the summary, `1` outputs a summary for each point count, `2` outputs per-point differences | `1` |

## Example Output

```shell
./fft.elf 1
main start verbose=1
before drv_fft_open
after drv_fft_open inst=0x7f9f2030
start point=64
  point   64  fft 133 us  ifft 121 us  max_diff(real=3@45, imag=1@3)  PASS
start point=128
  point  128  fft 121 us  ifft 118 us  max_diff(real=3@15, imag=2@31)  PASS
...
start point=4096
  point 4096  fft 1099 us  ifft 1067 us  max_diff(real=5@4094, imag=2@122)  PASS
before drv_fft_close
done failures=0

7/7 tests passed
```

## Description

- The FFT in the example uses `shift = 0x555` by default.
- The IFFT uses `shift = 0xaaa` by default.
- The current judgment threshold is that the maximum error of both the real part and the imaginary part does not exceed `5`.
- The example directly reuses the MMZ buffer pre-allocated by `drv_fft_open()`, without calling any additional manual adjustment interfaces.

```{admonition} Tip
For the interface definition of the FFT HAL, please refer to the [FFT API documentation](../../api_reference/peripheral/fft.md). For an example of real-time audio spectrum display, please refer to the [Media Chapter FFT Spectrum Display Demo](../media/fft.md).
```
