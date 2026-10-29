# Nonai_2D Demo

## Introduction

Nonai_2D Demo features image overlay functionality and can perform corresponding operations on input files. This functionality has potential application value in scenarios such as image editing and compositing, and can meet the needs of merging and displaying or processing multiple images.

## Feature Description

Nonai_2D performs image overlay operations by reading YUV (I420 format) files. This DEMO is developed based on the kd_mpi_venc series of interfaces, serving as a dedicated demonstration example for the image overlay functionality without other encoding-related features, helping users quickly master the core usage and development logic of image overlay implementation with this series of interfaces.

## Code Location

Demo source code location: `/src/rtsmart/examples/mpp/sample_nonai_2d`.

Assuming you have already compiled this Demo correctly. After starting the development board, enter the `/sdcard/app/examples/mpp` directory, where `sample_nonai_2d.elf` is the test Demo.

## Usage Instructions

The input parameters are as follows:

| Parameter | Description | Default Value |
|--------|------|--------|
| -i     | Input filename | -      |
| -w     | Image width   | -      |
| -h     | Image height   | -      |
| -o     | Output filename | -      |

## Example

```shell
./sample_nonai_2d.elf -i ./foreman_128x64_3frames.yuv -w 128 -h 64 -o ./out_2d.yuv
```

## Viewing Results

The output file can be exported to the local machine and viewed using YUV playback software.
![osd](https://www.kendryte.com/api/post/attachment?id=825)

```{admonition} Tip
For specific interfaces of the nonai_2d module, please refer to [API Documentation](../../api_reference/mpp/nonai_2d.md)
```
