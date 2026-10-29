# PM Demo

## Introduction

This example is used to verify the power management (PM) user-space interface, supporting operations such as querying/setting governor, profile, thermal protection threshold, clock and power switch, etc.

## Code Location

- `src/rtsmart/examples/mpp/sample_pm`

## Compilation Method

In `make menuconfig`, enable:

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_pm`

Then execute firmware compilation.

## Running Example

```shell
cd /sdcard/app/examples/mpp
./sample_pm.elf
```

The program will output help information:

```text
Usage: sample_pm func_index [opt]
```

Common examples:

```shell
# Query governor of domain=0
./sample_pm.elf 5 0

# Set domain=0 governor=1 (PERFORMANCE)
./sample_pm.elf 4 0 1

# Query profile of domain=0
./sample_pm.elf 7 0
```
