# Three-Channel AHD Example

## Introduction

This example demonstrates how to use the K230 chip to implement three-channel AHD (Analog High Definition) video input. AHD is an analog high-definition video transmission technology that supports 1080P resolution analog video transmission.

## Function Description

### AHD Features

This example demonstrates the processing of three-channel AHD video input:

- **Three-Channel Video Input**: Simultaneously capture three channels of AHD video
- **Video Decoding**: Decode AHD analog signals into digital video
- **Video Output**: Output the decoded video to a display device
- **Video Switching**: Support switching display between three channels of video

### AHD Specifications

- **Resolution**: Support 720P, 1080P and other resolutions
- **Frame Rate**: 25fps or 30fps
- **Color Space**: YUV422 or YUV420
- **Signal Type**: AHD, TVI, CVI, etc.

### Main Functions

- AHD video capture
- Video decoding processing
- Video display output
- Multi-channel video switching

## Code Location

Demo source location: `src/rtsmart/examples/integrated_poc/smart_ipc/face_detection`

## Usage Instructions

### Compilation Method

Use `make menuconfig` in the `K230 RTOS SDK` root directory to configure the build options, select to compile the three-way AHD example into the firmware, and then compile the firmware.

### Hardware Preparation

1. Prepare three AHD cameras
1. Connect the three cameras to the AHD input interfaces of the K230
1. Connect a display device (HDMI or LCD)

### Running the Example

```shell
./sample_ahd
```

Output example:

```text
Three-way AHD Demo
=================

Initializing AHD channels...
Channel 1: 1080P @ 30fps
Channel 2: 1080P @ 30fps
Channel 3: 720P @ 25fps

Starting video capture...
Channel 1 active, outputting to display
Use keys 1-3 to switch channels

Press '1' to switch to Channel 1
Press '2' to switch to Channel 2
Press '3' to switch to Channel 3
Press 'q' to quit

Current channel: 1
[Video display...]
```

Users can switch the displayed video of different channels via key presses.

```{admonition} Tip
AHD cameras require dedicated AHD input interfaces; please ensure the hardware supports them. For the specific interfaces of the AHD module, please refer to the [VICAP API documentation](../../api_reference/mpp/vicap.md).
```
