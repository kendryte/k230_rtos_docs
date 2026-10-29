# Vdec_demo

## Vdec_demo Introduction

Vdec demo implements the function of video decoding. The decoding function supports H.264/H.265/JPEG decoding. The supported input data formats are .264/.265/.jpeg.

## Feature Description

Vdec demo performs decoding by reading stream files. The decoding output results are displayed on the screen.

## Dependent Resources

None.

## Usage Instructions

### Execution

Execute `./sample_vdec.elf -help`, you can see the configurable parameters and descriptions, the default values are shown in the table below:

| Parameter | Description                                                                                | Default |
| ------ | ----------------------------------------------------------------------------------- | ------ |
| i      | Input file name, with suffixes of .264/.265/.jpg respectively                                          | -      |
| type   | LCD(20), HDMI(101) | 0      |

Example:

`./sample_vdec.elf -type 20 -i out.h265`

### View Results

The decoding results can be viewed on the screen.
