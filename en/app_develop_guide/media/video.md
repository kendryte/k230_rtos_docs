# Video Demo

## Introduction

This example demonstrates how to use the K230's video codec module (VENC/VDEC) to implement video encoding and decoding functions.

## Function Description

### VENC Function

Video encoding module functions:

- **Encoding Format Support**: Supports H.264, H.265 and other formats
- **Resolution Configuration**: Supports multiple resolutions
- **Bitrate Control**: Supports CBR, VBR and other bitrate control modes
- **Frame Rate Setting**: Configurable output frame rate
- **GOP Configuration**: Supports GOP size setting

### VDEC Function

Video decoding module functions:

- **Decoding Format Support**: Supports H.264, H.265 and other formats
- **Hardware Acceleration**: Hardware-accelerated decoding
- **Multi-channel Decoding**: Supports simultaneous multi-channel decoding
- **Frame Output**: Direct output to VO display

## Code Location

Demo source code location: `src/rtsmart/examples/mpp/sample_venc`

## Usage Instructions

### Compilation Method

In the `K230 RTOS SDK` root directory, use `make menuconfig` to configure compilation options, select to compile the Video example into the firmware, and then compile the firmware.

### Running the Example

```shell
./sample_venc.elf [options]
```

### Parameter Description

| Parameter Name | Description | Default Value |
|--------|------|--------|
| Encoding Type | h264/h265 | h265 |
| Width | Image width | 1920 |
| Height | Image height | 1080 |
| Frame Rate | Frame rate | 30 |
| Bitrate | Encoding bitrate | 4000 |

### Viewing Results

After the program runs, it will:

1. Initialize the video encoder
1. Configure encoding parameters
1. Start encoding loop
1. Output the encoded bitstream

Output example:

```text
Video Encoder Demo
=================

Initializing VENC module...
VENC initialized successfully

Configuring encoder...
Codec: H.265
Resolution: 1920x1080
Frame rate: 30fps
Bitrate: 4000Kbps

Starting encoding...
Encoding frames...
Frame 1 encoded
Frame 2 encoded
Frame 3 encoded
...

Encoding statistics:
Total frames: 1000
Total bytes: 52428800
Bitrate: 4000Kbps (actual)

Press Ctrl+C to stop.
```

```{admonition} Tip
Video encoding and decoding is a core function of multimedia processing, and appropriate encoding parameters need to be selected based on actual application scenarios. For the specific interface of the video encoding and decoding module, please refer to [Video Encoding and Decoding API Documentation](../../api_reference/mpp/video.md).
```
