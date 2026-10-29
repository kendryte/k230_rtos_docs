# Tuya Basic Example

## Introduction

This example demonstrates the basic connection and data model invocation flow of the Tuya IoT Core SDK, including:

- MQTT initialization and connection
- Online callback handling
- Property reporting and event reporting
- Message callback handling

## Code Location

- `src/rtsmart/examples/3rd-party/tuya/tuya_basic`

## Compilation Method

After enabling the relevant 3rd-party examples in `make menuconfig`, execute firmware compilation.

## Running the Example

```shell
cd /sdcard/app/examples/3rd-party/tuya
./tuya_basic.elf
```

## Prerequisites

Please configure valid device information in the example source code first:

- `productId`
- `deviceId`
- `deviceSecret`

See the corresponding location at:

- `src/rtsmart/examples/3rd-party/tuya/tuya_basic/data_model_basic_demo.c`

## Description

After the program connects successfully, it will execute demo logic such as data model reading, expected value reading, property reporting, and event reporting in the callback.
