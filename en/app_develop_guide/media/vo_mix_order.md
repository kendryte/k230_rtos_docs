# VO Mix Sorting Demo

## Introduction

This example demonstrates how to use the K230's VO (Video Output) module for multi-channel video mixing and sorting display. This functionality is commonly used in scenarios such as multi-channel monitoring and picture-in-picture.

## Feature Description

### VO Mix Sorting Function

This example showcases the VO's mix sorting capabilities:

- **Multi-channel video input**: Supports simultaneous input of multiple video streams
- **Video mixing**: Mixes multiple video streams for display
- **Picture-in-picture**: Supports picture-in-picture functionality
- **Layer management**: Manages the display priority of different video layers
- **Region settings**: Sets the display region for each video stream

### Supported Features

- **Multi-channel input**: Supports multiple video input channels
- **Mix mode**: Supports multiple mix modes
- **Scaling**: Supports video scaling
- **Position adjustment**: Adjustable video display position

## Code Location

Demo source location: `src/rtsmart/examples/mpp/sample_vo_mix_order`

## Usage Instructions

### Compilation Method

In the `K230 RTOS SDK` root directory, use `make menuconfig` to configure the compilation options, select to compile the VO mix order example into the firmware, and then compile the firmware.

### Running the Example

```shell
./sample_vo_mix_order
```

### Viewing Results

After the program runs, it will:

1. Initialize the VO module
1. Configure multiple video inputs
1. Set video mix parameters
1. Start mixed display
1. Support dynamic adjustment of video position and layer

Output example:

```text
VO Mix Order Demo
===================

Initializing VO module...
VO initialized successfully

Configuring video mix...
Channel 0: Main video, 1920x1080, Full screen
Channel 1: Sub video 1, 640x480, Position(100,100)
Channel 2: Sub video 2, 640x480, Position(1200,100)
Channel 3: Sub video 3, 640x480, Position(100,600)

Starting video mix...
Video mix started!

Display info:
Main: 1920x1080 @ 30fps
Sub1: 640x480 @ 30fps
Sub2: 640x480 @ 30fps
Sub3: 640x480 @ 30fps

Use keys to adjust video order:
[1] Move sub1 forward
[2] Move sub1 backward
[3] Move sub2 forward
[4] Move sub2 backward
...
[Q] Quit

Press Ctrl+C to exit.
```

```{admonition} Tip
The VO mix order function can be used in application scenarios such as multi-channel monitoring and picture-in-picture. For specific interfaces of the VO module, please refer to the [Display Output API Documentation](../../api_reference/mpp/display.md).
```
