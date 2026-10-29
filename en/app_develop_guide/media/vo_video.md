# VO Video Output Demo

## Introduction

This example demonstrates how to use the K230's VO (Video Output) module for video output. The VO module supports multiple output devices and display modes.

## Function Description

### VO Functions

This example showcases the main features of VO video output:

- **Multiple Output Devices**: Supports HDMI, LCD, and other outputs
- **Multiple Display Modes**: Supports different display modes
- **Scaling Function**: Supports video scaling
- **Frame Rate Configuration**: Configurable output frame rate
- **Color Space**: Supports multiple color spaces

### Supported Output Devices

- **HDMI Output**: Supports 1080P and other high resolutions
- **LCD Output**: Supports various LCD panels
- **MIPI Output**: MIPI interface output
- **BT1120 Output**: BT1120 digital output

### Display Features

- **Resolution**: Supports multiple resolutions
- **Refresh Rate**: Supports 60Hz, 50Hz, and other refresh rates
- **Aspect Ratio**: Supports 16:9, 4:3, and other aspect ratios
- **Color Space**: Supports BT.601, BT.709, and others

## Code Location

Demo source code location: `src/rtsmart/examples/mpp/sample_vo_video`

## Usage Instructions

### Compilation Method

In the `K230 RTOS SDK` root directory, use `make menuconfig` to configure build options, select to compile the VO video output example into the firmware, and then build the firmware.

### Running the Example

```shell
./sample_vo_video <connector_type> [options]
```

### Parameter Description

| Parameter Name | Description | Parameter Range |
|--------|------|----------|
| connector_type | Connector type | HDMI(101), LCD(20), MIPI, etc. |
| width | Output width | 128-3840 |
| height | Output height | 64-2160 |
| frame_rate | Frame rate | 24-60 |

### Viewing Results

After the program runs, it will:

1. Initialize the VO module
1. Configure the output device
1. Configure output parameters
1. Start video output
1. Support dynamically adjusting output parameters

Output example:

```text
VO Video Output Demo
====================

Initializing VO module...
VO initialized successfully

Configuring output device...
Connector type: 101 (HDMI)
Output resolution: 1920x1080
Frame rate: 60Hz

Starting video output...
Video output started!

Display info:
Resolution: 1920x1080
Refresh rate: 60Hz
Color space: BT.601
Aspect ratio: 16:9

Use keys to change output settings:
[1] Change resolution
[2] Change frame rate
[3] Change color space
[Q] Quit

Press Ctrl+C to exit.
```

```{admonition} Tip
Use the list_connector command to view supported connector types and enum values. VO video output is the final stage of multimedia display and needs to work with modules such as VI and VDEC. For specific interfaces of the VO module, please refer to the [Display Output API Documentation](../../api_reference/mpp/display.md).
```
