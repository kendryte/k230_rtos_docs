# GSDMA Demo

## Introduction

This example demonstrates typical usage of GSDMA, including the GDMA image processing path and the SDMA memory transfer path, covering rotation, mirroring, 1D/2D transfers, and aligned/unaligned scenarios.

## Code Location

- `src/rtsmart/examples/mpp/sample_gsdma`

## Build Method

Enable the following in `make menuconfig`:

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_gsdma`

Then run the firmware build.

## Run Example

```shell
cd /sdcard/app/examples/mpp
./sample_gsdma.elf
```

## Description

This example runs multiple sets of test cases in batch and prints pass/fail statistics, which can be used for board-level functional verification and regression testing.
