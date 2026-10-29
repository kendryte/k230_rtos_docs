# Nonai_csc Demo

## Introduction

The nonai_csc Demo is an example program that integrates **Color Space Conversion (CSC)** with **OSD (On-Screen Display) overlay** functionality. This Demo demonstrates how to use the nonai_2d module to perform format conversion on video frames and dynamically overlay OSD graphics and borders before encoding. It is suitable for embedded vision application scenarios that require real-time video processing, graphics overlay, and encoding output.

## Functionality Description

- **Color Space Conversion (CSC)**: Supports converting input images (such as RGB888, YUV420, etc.) to different pixel formats (such as RGB565, NV12, etc.), facilitating subsequent processing or display.
- **OSD Overlay**: Through the 2D acceleration function of the VENC module, an OSD layer in ARGB8888 format is inserted into the H.265 encoding stream, with configurable parameters such as transparency, position, and background color.
- **Border Drawing**: Supports drawing colored borders in specified areas, used to highlight or mark specific regions.
- **Multi-channel Parallel Processing**: The Demo creates multiple nonai_2d channels, respectively used for binding paths, RGB888 conversion, and RGB565 conversion, achieving flexible data flow processing.
- **Video Capture + Encoding + Display Integration**: Integrates VICAP video capture, NONAI_2D processing, VENC encoding, and VO display modules to form a complete media processing pipeline.

## Code Location

Demo source code path:
/src/rtsmart/examples/mpp/sample_csc

Assuming you have correctly compiled this Demo.

After starting the development board, enter the /sdcard/app/examples/mpp directory. The executable file is:
sample_csc.elf

## Usage Instructions

The input parameters are as follows:

| Parameter | Description | Default Value |
|--------|------|--------|
| -o     | Encoded 265 file | -      |
| -vo     | Display device type   | -      |

## Example

./sample_csc.elf -o /data/test.265 -vo 101

After running:

- The real-time camera image will be displayed on HDMI;
- Starting from the 90th frame of the encoding stream, the OSD and border positions are dynamically updated;
- Meanwhile, the processed RGB888 and RGB565 frames are saved as /data/out_2d_rgb888.rgb and /data/out_2d_rgb565.rgb;
- The video is output to the specified display;
- Press the q key on the keyboard to exit the program.

## Viewing Results

- **Encoded stream**: Export the generated .h265 file to a PC and view it using a player such as VLC or Elecard StreamEye. You can observe the OSD icons and borders.
![265](https://www.kendryte.com/api/post/attachment?id=828)
- **RGB output files**: Use a Raw RGB viewing tool (such as YUVPlayer which supports RGB mode) to load out_2d_rgb888.rgb (1280×720, RGB888) or out_2d_rgb565.rgb (1280×720, RGB565) to verify the color conversion results.
![RGB565](https://www.kendryte.com/api/post/attachment?id=826)
![RGB888](https://www.kendryte.com/api/post/attachment?id=827)

```{admonition} Tip
For the specific interfaces of the nonai_2d module, please refer to the [API Documentation](../../api_reference/mpp/nonai_2d.md)
```
