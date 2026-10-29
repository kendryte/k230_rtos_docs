# Sensor Demo

## Introduction

This example demonstrates how to use the K230's Sensor module for image acquisition. The Sensor module supports various types of cameras and sensors, enabling video input, image capture, and other functions.

## Function Description

### Sensor Functions

This example showcases the main features of the Sensor module:

- **Camera Initialization**: Initialize the camera sensor
- **Image Acquisition**: Real-time image data acquisition
- **Resolution Configuration**: Support for multiple resolution settings
- **Frame Rate Control**: Configurable acquisition frame rate
- **Exposure Control**: Support for automatic and manual exposure
- **White Balance**: Support for white balance adjustment

### Supported Sensor Types

- **MIPI CSI**: MIPI interface camera
- **DVP**: Parallel interface camera
- **TVP**: TVP series adapter chip

## Code Location

The current SDK does not provide an independent `sample_sensor` example.

You can refer to the sensor acquisition-related Demo: `src/rtsmart/examples/mpp/sample_uvc_dev_vicap`

## Usage Instructions

### Compilation Method

In the root directory of `K230 RTOS SDK`, use `make menuconfig` to configure the compilation options, select to compile the Sensor example into the firmware, and then compile the firmware.

### Running the Example

```shell
./sample_uvc_dev_vicap.elf
```

### Viewing Results

After the program runs, it will:

1. Enumerate and initialize the camera
1. Configure acquisition parameters
1. Start image acquisition
1. Output the image to a display device or save it to a file

Output example:

```text
Sensor Demo
============

Enumerating sensors...
Sensor 1: IMX335 (MIPI CSI)
Sensor 2: OV5640 (MIPI CSI)
Sensor 3: TVP5150 (DVP)

Selecting sensor: IMX335
Sensor initialized!

Configuring capture...
Resolution: 1920x1080
Frame rate: 30fps
Exposure: Auto
White balance: Auto

Starting capture...
Capturing frames...
Frame 1 captured
Frame 2 captured
Frame 3 captured
...

Press Ctrl+C to stop.
```

```{admonition} Note
The Sensor module is the foundation of video input. Before use, corresponding parameters need to be configured according to the camera type. For the specific interfaces of the Sensor module, please refer to the [Sensor API Documentation](../../api_reference/mpp/sensor.md).
```
