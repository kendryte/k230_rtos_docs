# FFT API Reference

## Overview

The current SDK exposes FFT to user applications through the RT-Smart HAL wrapper in `drv_fft.h`. The older public API described as `kd_mpi_fft*` and `mpi_fft_api.h` is no longer the application-facing interface in the current tree.

The current flow is:

1. Open the device with `drv_fft_open()`.
1. Fill a `drv_fft_cfg_t` configuration.
1. Run FFT or IFFT through `drv_fft_run()`, `drv_fft_fft()`, or `drv_fft_ifft()`.
1. Close the instance with `drv_fft_close()`.

The HAL hides MMZ allocation, cache maintenance, and ioctl details from applications.

## Header

- Header file: `drv_fft.h`

## Public Types

### drv_fft_cfg_t

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

### k_fft_mode_e

```c
typedef enum {
    FFT_MODE = 0,
    IFFT_MODE,
} k_fft_mode_e;
```

### k_fft_input_mode_e

```c
typedef enum {
    RIRI = 0,
    RRRR,
    RR_II,
} k_fft_input_mode_e;
```

### k_fft_out_mode_e

```c
typedef enum {
    RIRI_OUT = 0,
    RR_II_OUT,
} k_fft_out_mode_e;
```

## Public Functions

### drv_fft_open

```c
int drv_fft_open(drv_fft_inst_t **inst);
```

Opens `/dev/fft` and returns an FFT instance handle.

### drv_fft_close

```c
void drv_fft_close(drv_fft_inst_t **inst);
```

Closes the instance and clears the caller's handle.

### drv_fft_run

```c
int drv_fft_run(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                const short *in_real, const short *in_imag,
                short *out_real, short *out_imag);
```

Runs one FFT or IFFT according to `cfg->mode`.

### drv_fft_fft

```c
int drv_fft_fft(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                const short *in_real, const short *in_imag,
                short *out_real, short *out_imag);
```

Convenience wrapper that forces `FFT_MODE`.

### drv_fft_ifft

```c
int drv_fft_ifft(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                 const short *in_real, const short *in_imag,
                 short *out_real, short *out_imag);
```

Convenience wrapper that forces `IFFT_MODE`.

## Notes

- Supported point sizes are `64, 128, 256, 512, 1024, 2048, 4096`.
- `in_imag` may be `NULL` only when `input_mode == RRRR`.
- `timeout_ms = 0` disables timeout reporting and is the default used by current samples.
- Return values follow negative errno-style error codes on failure.

## Examples

- HAL roundtrip test: `src/rtsmart/examples/peripheral/fft/test_fft.c`
- Audio spectrum display demo: `src/rtsmart/examples/mpp/sample_fft_display/main.c`
