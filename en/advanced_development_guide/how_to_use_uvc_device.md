# K230 UVC Device Usage Guide

## UVC Device Function Description

K230 supports emulating the development board as a UVC device. When the K230 development board is connected to a computer, the computer will recognize a UVC camera.

## UVC Device Configuration Description

The following configuration is required to use UVC Device

```bash
make rtsmart-menuconfig

# 1 Find the corresponding configuration item
 > Components Configuration > Enable CherryUSB > Enable CherryUSB Device
        -> USB Device Function # Select UVC

# 2 After selecting the UVC function, Enable UVC will be configured by default. Under this configuration item, configure the width, height, and frame rate
> Components Configuration > Enable CherryUSB > Enable CherryUSB Device > Enable CherryUSB Device Class Driver
        -> Enable UVC
```

![UVC FUNC](https://www.kendryte.com/api/post/attachment?id=777)

![UVC CONFIG](https://www.kendryte.com/api/post/attachment?id=776)

## UVC Device Examples

We have prepared two example programs.

```bash
src/rtsmart/examples/mpp/sample_uvc_dev_picture # The data source for this example is a static JPEG image
src/rtsmart/examples/mpp/sample_uvc_dev_vicap   # The data source for this example is the COMS camera on the board. Please connect the camera before use

To use the above two example programs, you need to enable the following configuration:

make menuconfig
        > RT-Smart UserSpace Examples Configuration > Enable MPP examples
                -> Enable Build sample_uvc_dev_picture # Select this configuration
                -> Enable Build sample_uvc_dev_vicap
```

After completing the above configuration, you can run the example program on the board

```bash
msh />/sdcard/app/examples/mpp/sample_uvc_dev_picture.elf
or
msh />/sdcard/app/examples/mpp/sample_uvc_dev_vicap.elf
```

## Troubleshooting

1. First check whether the file `/dev/video` exists. If it does not exist, the modified configuration was not compiled into the firmware.
1. If running the example program `sample_uvc_dev_vicap.elf`, make sure the COMS camera is connected to the board.
