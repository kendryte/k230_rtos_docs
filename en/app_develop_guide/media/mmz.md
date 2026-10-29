# MMZ Demo

## Introduction

This example demonstrates the common flow of the MMZ memory management interface:

- Allocate MMZ memory (cached/non-cached)
- Free MMZ memory
- Query physical information by virtual address
- Cache flush

## Code Location

- `src/rtsmart/examples/mpp/sample_mmz`

## Compilation Method

Enable the following in `make menuconfig`:

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_mmz`

Then execute the firmware compilation.

## Running the Example

```shell
cd /sdcard/app/examples/mpp
./sample_mmz.elf
```

## Description

After the example finishes running, it will print `sample mmz test success` or failure information, making it easy to quickly locate issues in the MMZ call chain.
