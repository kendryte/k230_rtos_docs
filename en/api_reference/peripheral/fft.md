# K230 FFT API Reference

## Overview

The user-space access interface for the FFT hardware in the current SDK has been adjusted to an RT-Smart HAL wrapper, with the public header file `drv_fft.h`.

The characteristics of the current interface are as follows:

- Open the `/dev/fft` device via `drv_fft_open()` and obtain the instance handle.
- `drv_fft_open()` pre-allocates input/output MMZ buffers, which by default cover the maximum 4096-point scenario.
- Perform FFT computation via `drv_fft_run()` or `drv_fft_fft()` / `drv_fft_ifft()`.
- The HAL internally handles MMZ buffer allocation, cache synchronization, and ioctl calls; the application layer only needs to provide the input and output arrays.
- Supports querying and adjusting the internal DMA/MMZ buffer sizes of the HAL.
- Supports 64, 128, 256, 512, 1024, 2048, 4096 points.
- Input and output data are in `short` (`int16_t`) format.
- Supports three input formats `RIRI`, `RRRR`, `RR_II`, and two output formats `RIRI_OUT`, `RR_II_OUT`.

## Header File and Linking

- Header file: `drv_fft.h`
- The example project typically introduces the FFT HAL library through `librtsmart_hal.mk`

## API List

- [drv_fft_open](#drv_fft_open)
- [drv_fft_close](#drv_fft_close)
- [drv_fft_set_input_alloc_size](#drv_fft_set_input_alloc_size)
- [drv_fft_set_output_alloc_size](#drv_fft_set_output_alloc_size)
- [drv_fft_get_input_alloc_size](#drv_fft_get_input_alloc_size)
- [drv_fft_get_output_alloc_size](#drv_fft_get_output_alloc_size)
- [drv_fft_run](#drv_fft_run)
- [drv_fft_fft](#drv_fft_fft)
- [drv_fft_ifft](#drv_fft_ifft)

## Function Descriptions

### drv_fft_open

【Description】

Open the FFT device and create a HAL instance.

【Syntax】

```c
int drv_fft_open(drv_fft_inst_t **inst);
```

【Parameters】

| Parameter Name | Description | Input/Output |
| -------- | ---- | --------- |
| inst | Returns the FFT instance handle | Output |

【Return Value】

| Return Value | Description |
| ------ | ---- |
| 0 | Success |
| Negative | Failure, returns a negative errno-style error code |

【Notes】

- After success, `drv_fft_close()` must be called in pairs to release.
- If `/dev/fft` does not exist or the driver is not initialized, opening will fail.
- The current implementation pre-allocates input/output MMZ buffers during the open phase, with the default size being the capacity required for the maximum FFT scenario.

### drv_fft_close

【Description】

Close the FFT device and release the instance.

【Syntax】

```c
void drv_fft_close(drv_fft_inst_t **inst);
```

【Parameters】

| Parameter Name | Description | Input/Output |
| -------- | ---- | --------- |
| inst | Address of the FFT instance handle to close | Input/Output |

【Notes】

- When `NULL` or `*inst == NULL` is passed in, the function returns directly.
- After a successful call, `*inst` will be set to `NULL`.
- `drv_fft_close()` also releases the internal MMZ input/output buffers.

### drv_fft_set_input_alloc_size

【Description】

Adjust the internal input MMZ buffer size of the FFT HAL.

【Syntax】

```c
int drv_fft_set_input_alloc_size(drv_fft_inst_t *inst, uint32_t size);
```

【Parameters】

| Parameter Name | Description | Input/Output |
| -------- | ---- | --------- |
| inst | FFT instance handle | Input |
| size | New input buffer size in bytes | Input |

【Return Value】

| Return Value | Description |
| ------ | ---- |
| 0 | Success |
| Negative | Failure, returns a negative errno-style error code |

【Notes】

- If the current size already equals `size`, the function returns success directly.
- If the adjustment is successful, the old MMZ buffer will be released and replaced with a new one.

### drv_fft_set_output_alloc_size

【Description】

Adjust the internal output MMZ buffer size of the FFT HAL.

【Syntax】

```c
int drv_fft_set_output_alloc_size(drv_fft_inst_t *inst, uint32_t size);
```

【Parameters】

| Parameter Name | Description | Input/Output |
| -------- | ---- | --------- |
| inst | FFT instance handle | Input |
| size | New output buffer size in bytes | Input |

【Return Value】

| Return Value | Description |
| ------ | ---- |
| 0 | Success |
| Negative | Failure, returns a negative errno-style error code |

### drv_fft_get_input_alloc_size

【Description】

Get the current input MMZ buffer size.

【Syntax】

```c
uint32_t drv_fft_get_input_alloc_size(const drv_fft_inst_t *inst);
```

### drv_fft_get_output_alloc_size

【Description】

Get the current output MMZ buffer size.

【Syntax】

```c
uint32_t drv_fft_get_output_alloc_size(const drv_fft_inst_t *inst);
```

【Description】

- When `inst == NULL`, the above query interface returns `0`.
- By default, after opening, the input and output buffers have both been pre-allocated.

### drv_fft_run

【Description】

Directly execute an FFT or IFFT according to the mode specified in `drv_fft_cfg_t`.

【Syntax】

```c
int drv_fft_run(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                const short *in_real, const short *in_imag,
                short *out_real, short *out_imag);
```

【Parameters】

| Parameter Name | Description | Input/Output |
| -------- | ---- | --------- |
| inst | FFT instance handle | Input |
| cfg | FFT configuration structure, see [drv_fft_cfg_t](#drv_fft_cfg_t) | Input |
| in_real | Input real part array, length is `cfg->point` | Input |
| in_imag | Input imaginary part array, length is `cfg->point`; can be `NULL` when `input_mode == RRRR` | Input |
| out_real | Output real part array, length is `cfg->point` | Output |
| out_imag | Output imaginary part array, length is `cfg->point` | Output |

【Return Value】

| Return Value | Description |
| ------ | ---- |
| 0 | Success |
| Negative | Failure, returns a negative errno-style error code |

【Notes】

- `cfg->point` only supports `64/128/256/512/1024/2048/4096`.
- `cfg->mode` determines whether to execute FFT or IFFT.
- Writing `0` to `timeout_ms` means that the FFT timeout reporting is not enabled; the current example uses `0` by default.
- If the required input/output bytes for this run exceed the current internal buffer size, `-ENOMEM` will be returned.
- In `RRRR` input mode, `in_imag` can be `NULL`.

### drv_fft_fft

【Description】

Execute FFT. This interface ignores the `cfg->mode` passed in by the caller and is internally forced to `FFT_MODE`.

【Syntax】

```c
int drv_fft_fft(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                const short *in_real, const short *in_imag,
                short *out_real, short *out_imag);
```

【Parameters】

Same as [drv_fft_run](#drv_fft_run).

### drv_fft_ifft

【Description】

Execute IFFT. This interface ignores the `cfg->mode` passed in by the caller and is internally forced to `IFFT_MODE`.

【Syntax】

```c
int drv_fft_ifft(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                 const short *in_real, const short *in_imag,
                 short *out_real, short *out_imag);
```

【Parameters】

Same as [drv_fft_run](#drv_fft_run).

## Data Types

### drv_fft_inst_t

**Description**

FFT HAL handle type, opaque structure, used only through pointers.

### drv_fft_cfg_t

**Description**

FFT runtime configuration.

**Definition**

```c
typedef struct {
    uint32_t           point;
    k_fft_mode_e       mode;
    k_fft_input_mode_e input_mode;
    k_fft_out_mode_e   output_mode;
    uint16_t           shift;
    uint32_t           timeout_ms;
} drv_fft_cfg_t;
```

**Members**

| Member Name | Description |
| -------- | ---- |
| point | FFT/IFFT point count, supports powers of 2 from `64 ~ 4096` |
| mode | Runtime mode, see [k_fft_mode_e](#k_fft_mode_e) |
| input_mode | Input format, see [k_fft_input_mode_e](#k_fft_input_mode_e) |
| output_mode | Output format, see [k_fft_out_mode_e](#k_fft_out_mode_e) |
| shift | Scaling control bits per stage |
| timeout_ms | Timeout configuration, `0` means timeout reporting is disabled |

### k_fft_mode_e

**Definition**

```c
typedef enum {
    FFT_MODE = 0,
    IFFT_MODE,
} k_fft_mode_e;
```

### k_fft_input_mode_e

**Definition**

```c
typedef enum {
    RIRI = 0,
    RRRR,
    RR_II,
} k_fft_input_mode_e;
```

**Description**

- `RIRI`: Input arranged as `real0, imag0, real1, imag1...`
- `RRRR`: Pure real input, only `in_real` is used
- `RR_II`: All real parts first, then all imaginary parts

### k_fft_out_mode_e

**Definition**

```c
typedef enum {
    RIRI_OUT = 0,
    RR_II_OUT,
} k_fft_out_mode_e;
```

**Description**

- `RIRI_OUT`: Output returned in interleaved format
- `RR_II_OUT`: Output split into `out_real[]` and `out_imag[]`

## Usage Example

```c
#include <stdio.h>
#include <string.h>

#include "drv_fft.h"

int main(void)
{
    drv_fft_inst_t *inst = NULL;
    short in_real[512] = {0};
    short in_imag[512] = {0};
    short out_real[512] = {0};
    short out_imag[512] = {0};
    drv_fft_cfg_t cfg = {
        .point = 512,
        .mode = FFT_MODE,
        .input_mode = RIRI,
        .output_mode = RR_II_OUT,
        .shift = 0x555,
        .timeout_ms = 0,
    };

    if (drv_fft_open(&inst) != 0)
        return -1;

    printf("fft in alloc = %u, out alloc = %u\n",
           drv_fft_get_input_alloc_size(inst),
           drv_fft_get_output_alloc_size(inst));

    if (drv_fft_fft(inst, &cfg, in_real, in_imag, out_real, out_imag) != 0) {
        drv_fft_close(&inst);
        return -1;
    }

    drv_fft_close(&inst);
    return 0;
}
```

## Examples and Related Documentation

- FFT HAL regression example: `src/rtsmart/examples/peripheral/fft/test_fft.c`
- Audio spectrum display example: `src/rtsmart/examples/mpp/sample_fft_display/main.c`
- Peripheral example documentation: [FFT Peripheral Example](../../app_develop_guide/peripheral/fft.md)
- Media example documentation: [FFT Spectrum Display Example](../../app_develop_guide/media/fft.md)

## Buffer Size Recommendations

- By default, `drv_fft_open()` has pre-allocated buffers for the maximum 4096-point scenario, so manual adjustment is usually not required.
- If the subsequent HAL needs to run a fixed-point FFT in a scenario with smaller memory footprint, you can use `drv_fft_set_input_alloc_size()` / `drv_fft_set_output_alloc_size()` to reduce the internal buffers.
- If the buffer has been manually reduced, running an FFT with a larger point count or a larger input layout will cause `drv_fft_run()` to return `-ENOMEM`.
