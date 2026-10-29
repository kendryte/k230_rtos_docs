# UVC Device Picture Demo

## Introduction

This example demonstrates the UVC Device device-side flow:

- Initialize UVC Device
- Create UVC output buffer pool
- Loop built-in JPEG data into UVC
- Continuously output and count frame rate

This example is suitable for verifying the device-side UVC link and does not rely on local sensor capture.

## Code Location

- `src/rtsmart/examples/mpp/sample_uvc_dev_picture`

## Build Method

Enable the following in `make menuconfig`:

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_uvc_dev_picture`

Then execute firmware compilation.

## Running the Example

```shell
cd /sdcard/app/examples/mpp
./sample_uvc_dev_picture.elf
```

## Description

- After the program starts, it will continuously push built-in JPEG data.
- Use `Ctrl+C` to trigger a graceful exit and print statistics.
