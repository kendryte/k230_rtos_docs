# MPP Log Demo

## Introduction

This example demonstrates the basic usage of the MPP log interface, including:

- Setting the module log level
- Reading the module log level
- Setting the log read wait strategy
- Reading the log buffer

## Code Location

- `src/rtsmart/examples/mpp/sample_log`

## Build Method

Enable the following in `make menuconfig`:

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_log`

Then execute firmware compilation.

## Run Example

```shell
cd /sdcard/app/examples/mpp
./sample_log.elf
```

## Related Interfaces

- `kd_mpi_log_set_level_conf`
- `kd_mpi_log_get_level_conf`
- `kd_mpi_log_set_wait_flag`
- `kd_mpi_log_read`
