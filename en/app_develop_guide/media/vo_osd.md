# VO OSD Demo

## Introduction

This example demonstrates how to use the OSD (On-Screen Display) function of the K230's VO (Video Output) module. OSD can overlay text, graphics, time, and other information on the video screen.

## Function Description

### OSD Functions

This example demonstrates the main functions of OSD:

- **Text Display**: Overlay text information on the video screen
- **Graphics Drawing**: Draw graphics on the video screen
- **Time Display**: Display the current time
- **Region Setting**: Set the OSD display region
- **Transparency Control**: Support OSD transparency adjustment

### Supported OSD Types

- **Text OSD**: Display text information
- **Graphics OSD**: Display graphic elements
- **Time OSD**: Display time and date
- **LOGO Display**: Display company LOGO

### OSD Features

- **Multi-layer Support**: Support multiple OSD layers
- **Color Configuration**: Support multiple color settings
- **Font Configuration**: Support different font sizes
- **Dynamic Update**: Support dynamic OSD content updates

## Code Location

Demo source location: `src/rtsmart/examples/mpp/sample_vo_osd`

## Usage Instructions

### Build Method

Under the `K230 RTOS SDK` root directory, use `make menuconfig` to configure build options, select to compile the VO OSD example into the firmware, then build the firmware.

### Run Example

```shell
./sample_vo_osd
```

### View Results

After the program runs, it will:

1. Initialize VO module
1. Configure video output
1. Create OSD layer
1. Configure OSD parameters
1. Start displaying OSD content

Output example:

```text
VO OSD Demo
=============

Initializing VO module...
VO initialized successfully

Configuring OSD layer...
OSD layer created

Setting OSD content...
Text: "K230 RTOS Demo"
Color: White
Position: Top left
Font: Large

Starting OSD display...
OSD display started!

Display info:
Video: 1920x1080 @ 30fps
OSD layer 1: Active
Text: "K230 RTOS Demo"
Time: 2025-02-03 18:30:00

Use keys to change OSD content:
[1] Change text
[2] Change color
[3] Change position
[T] Update time
[C] Clear OSD
[Q] Quit

Press Ctrl+C to exit.
```

```{admonition} Tip
The OSD function can be used to display status information, LOGO, time, etc. It supports dynamic update of OSD content and is suitable for various monitoring and display scenarios. For the specific interfaces of the OSD module, please refer to the [Display Output API Documentation](../../api_reference/mpp/display.md).
```
