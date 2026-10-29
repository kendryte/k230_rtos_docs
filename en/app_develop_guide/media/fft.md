# FFT Spectrum Display Demo

## Introduction

The FFT example in the current media chapter has been adjusted to a real-time audio spectrum display demo. This example collects mono audio from AI, calls the FFT HAL to perform hardware FFT computation, and then uses the OSD layer to draw the spectrum bar chart on the display screen.

Unlike the older `sample_fft` that only does FFT/IFFT regression tests, the current example focuses more on complete media pipeline integration, covering the following modules:

- Audio capture (AI / I2S)
- FFT HAL call
- VB/MMZ buffer usage
- OSD layer drawing and screen display
- Automatic landscape layout and frequency axis display

If you only want to verify the basic correctness of the FFT HAL, please refer to the [FFT HAL Example](../peripheral/fft.md) in the peripheral chapter.

## Function Description

- Real-time audio data capture and hardware FFT execution
- Automatically use the landscape layout of the display panel to obtain larger spectrum horizontal resolution
- Draw frequency scale and `Hz` axis label at the bottom of the spectrum
- Support custom sampling rate, FFT points, rotation angle, display size, and display gain

## Code Location

Demo source code location: `src/rtsmart/examples/mpp/sample_fft_display/main.c`

## Build and Run

### Build

After building the firmware in the SDK root directory, the example ELF will be generated in the RT-Smart examples directory.

### Run

After starting the development board, enter the `/sdcard/app/examples/mpp` directory and run:

```shell
./sample_fft_display.elf -c <connector_type> [options]
```

For example, a 01Studio 480x800 screen can use:

```shell
./sample_fft_display.elf -c 20 -s 44100 -p 512
```

## Parameter Description

You can view the help by running `./sample_fft_display.elf -h`. The current version supports the following parameters:

| Parameter | Description | Default |
| ------ | ---- | ------ |
| `-c <type>` | Connector type, required; use `list_connector` to check | None |
| `-w <width>` | OSD width | Automatically derived from the rotated panel size |
| `-h <height>` | OSD height | Automatically derived from the rotated panel size |
| `-r <deg>` | Rotation angle, supports `0/90/180/270` | Auto landscape |
| `-s <rate>` | Audio sample rate | `44100` |
| `-p <points>` | FFT points, supports powers of 2 from `64~4096` | `512` |
| `-g <gain>` | Display gain, in dB | `0` |

## Running Effect

After startup, the program will output logs similar to the following:

```shell
./sample_fft_display.elf -c 20 -s 44100 -p 512
FFT Spectrum: connector=20, panel=480x800, OSD=800x480, rotate=90, rate=44100, points=512, gain=0.0 dB
main start connector=20 panel=480x800 osd=800x480 rotate=90 rate=44100 points=512
before drv_fft_open
after drv_fft_open inst=0x7f9f2030
Running... press Ctrl+C to stop
```

At this point, the screen will continuously display:

- Spectrum bar chart
- Frequency axis at the bottom
- Title and real-time refresh rate at the top

Press `Ctrl+C` to exit the example.

```{admonition} Tip
The current example uses the FFT HAL interface `drv_fft_*` and no longer uses the legacy `kd_mpi_fft*` API. For interface details, please refer to the [FFT API Documentation](../../api_reference/peripheral/fft.md).
```
