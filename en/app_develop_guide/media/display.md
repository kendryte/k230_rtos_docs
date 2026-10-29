# Display Demo

## Introduction

The VO (Video Output) module actively reads video and graphics data from the corresponding locations in memory, and outputs video and graphics through the corresponding display devices. The display/write-back devices, video layers, and graphics layers supported by the chip. The VO demo tests these interfaces and functions.

## Function Description

### VO Functions

This example demonstrates the main functions of the VO module:

- **Multi-channel output support**: Supports HDMI, LCD, and other output devices
- **Multi-layer overlay**: Supports overlay display of video layers and graphics layers
- **OSD display**: Supports OSD (On-Screen Display) text and graphics overlay
- **Resolution setting**: Supports multiple output resolutions
- **Refresh rate configuration**: Configurable display refresh rate

### Supported Output Devices

- **HDMI**: HDMI output, supports 1080P and other high resolutions
- **LCD**: LCD screen output, supports multiple LCD panels
- **MIPI**: MIPI interface output

### Video Layer and Graphics Layer

- **Video layer**: Used to display video streams
- **Graphics layer**: Used to display OSD, UI, and other graphics content
- **Blending mode**: Supports multiple layer blending modes

## Code Location

The display-related demos currently available in the SDK are located at:

- `src/rtsmart/examples/mpp/sample_vo_video`
- `src/rtsmart/examples/mpp/sample_vo_osd`
- `src/rtsmart/examples/mpp/sample_vo_mix_order`

## Usage Instructions

### Build Method

In the `K230 RTOS SDK` root directory, first run `make menuconfig`. It is recommended to complete at least two types of configuration before building the firmware:

1. In `MPP Configuration -> Display Configuration`, enable the corresponding display driver, configure the pins, and select the target panel driver.
1. In `RT-Smart UserSpace Examples Configuration`, enable the Display-related samples.

If you are adding a new screen driver, please first refer to [`../../advanced_development_guide/how_to_add_display.md`](../../advanced_development_guide/how_to_add_display.md) to complete the menuconfig and panel integration, then return to this page to run the sample.

### Running Example

```shell
./sample_vo_video.elf <connector_type> [options]
```

### Parameter Description

| Parameter Name  | Description       | Parameter Range                         |
|----------------|-------------------|-----------------------------------------|
| connector_type | Connector type | Based on the board-side `list_connector` output |

### Viewing Results

After the program runs, it will:

1. Initialize the VO module
1. Configure the output device
1. Create video layers and graphic layers
1. Start OSD display
1. Begin video output

Output example:

```text
Display Demo
=============

Initializing VO module...
VO initialized successfully

Configuring output device...
Connector type: 101 (HDMI)
Output resolution: 1920x1080 @ 60Hz

Creating video layers...
Layer 0: Created
Layer 1: Created

Setting up OSD...
OSD configured successfully

Starting video output...
Video output started!
Press Ctrl+C to stop.
```

```{admonition} Tip
Use the `list_connector` command to view the connector types and enumeration values actually supported by the current firmware. When adding a new panel, you should first confirm that it has been enabled in menuconfig and compiled into the image, then use the sample to verify. For the specific interfaces of the VO module, please refer to the [Display Output API Documentation](../../api_reference/mpp/display.md).
```
