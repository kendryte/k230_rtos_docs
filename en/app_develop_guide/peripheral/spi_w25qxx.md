# SPI W25QXX Example

## Introduction

This example demonstrates how to use the K230's SPI peripheral to access SPI NOR Flash (W25QXX and compatible devices), and perform device identification, erase/write verification, boundary testing, and performance testing.

## Function Description

### Features

The current version of the sample has the following capabilities:

- **Device Identification**: Read the JEDEC ID and match parameters in the device table
- **Address Mode**: Automatically handle 3-byte/4-byte address mode based on capacity
- **Read/Write Verification**: Erase, write, read back and compare
- **Boundary Testing**: Read/write testing of critical boundary addresses
- **Performance Testing**: Erase/write/read rate statistics
- **Command Line Parameters**: SPI controller, CS pin, baud rate, test type, address and size can be specified

### Hardware Connection

The W25QXX Flash chip is connected to the K230 via the SPI interface:

| W25QXX Pin | K230 Pin | Function Description |
|-------------|-----------|----------|
| VCC | 3.3V | Power supply positive |
| GND | GND | Power supply ground |
| CLK | SPI SCLK pin | SPI clock line |
| DO | SPI MISO pin | SPI data output line |
| DI | SPI MOSI pin | SPI data input line |
| CS | SPI CS pin | Chip select signal |
| WP/HOLD | 3.3V | Write protect/Hold (tied high to disable) |

Note: The current sample supports selecting the SPI controller via parameters, the common default configuration is QSPI1.

### Flash Specifications

- Interface: Standard SPI (sample default `SPI_HAL_MODE_0`)
- Capacity: W25Q16 (2MB), W25Q32 (4MB), W25Q64 (8MB), W25Q128 (16MB), etc.
- Page Size: 256 bytes
- Sector Size: 4KB
- Block Size: 32KB/64KB

### Common Instructions Covered by the Sample

| Instruction | Description |
|------|------|
| 0x05 | Read Status Register |
| 0x06 | Write Enable |
| 0x20 | Sector Erase (4KB) |
| 0x52 | Block Erase (32KB) |
| 0xD8 | Block Erase (64KB) |
| 0xC7 | Chip Erase |
| 0x02 | Page Program (256 bytes) |
| 0x03 | Read Data |
| 0x9F | Read JEDEC ID |

### Main Functions (Current Source)

- `flash_create()`
- `flash_detect_device()`
- `flash_erase_sector()`
- `flash_write()`
- `flash_read_data()`
- `test_read_write_with_params()`
- `test_performance_with_params()`

## Code Location

Demo source location: `src/rtsmart/examples/peripheral/spi_w25qxx`

Main file: `test_spi_wq128.c`

## Usage Instructions

### Compilation Method

#### Firmware Compilation

In the `K230 RTOS SDK` root directory, use `make menuconfig` to configure the compilation options, select to compile the SPI W25QXX example into the firmware, and then compile the firmware.

#### Standalone Compilation

Enter the SPI W25QXX example directory and use the Makefile to compile:

```shell
cd src/rtsmart/examples/peripheral/spi_w25qxx
make
```

After successful compilation, an executable file will be generated.

### Hardware Preparation

1. Prepare a W25QXX series Flash chip module
1. Connect the Flash to the K230 development board according to the pin connection table above
1. Ensure the power connection is correct

### Running the Example

Copy the compiled executable file to the development board, navigate to the storage directory, and run:

```shell
cd /sdcard/app/examples/peripheral
./spi_w25qxx.elf
```

### Command Line Parameters

This example supports the following command line parameters:

| Parameter | Abbreviation | Type | Default Value | Description |
|------|------|------|--------|------|
| `--help` | `-h` | None | - | Display help information |
| `--spi-id` | `-i` | Integer | 2 | SPI controller ID (0: OSPI, 1: QSPI0, 2: QSPI1) |
| `--cs-pin` | `-c` | Integer | 11 | CS chip select GPIO pin number |
| `--baudrate` | `-b` | Integer | 10 | SPI baud rate, unit MHz |
| `--test` | `-t` | String | all | Run specified test: info/basic/rw/boundary/perf/all |
| `--address` | `-a` | Hexadecimal | auto | Test start address, hexadecimal format |
| `--size` | `-s` | Integer | auto | Test size, unit KB |

#### Test Parameter Options Description

- `info` - Only display device information (JEDEC ID, capacity, address mode, etc.)
- `basic` - Basic function test (write enable, write disable, etc.)
- `rw` - Read/write function test (erase, write, read-back verification)
- `boundary` - Boundary address test (read/write verification of key address boundaries)
- `perf` - Performance test (erase/read rate statistics)
- `all` - Run all tests (default)

#### SPI Controller ID Description

| ID | Controller | Description |
|----|--------|------|
| 0 | OSPI | Ok Spi general controller |
| 1 | QSPI0 | Quick SPI controller 0 |
| 2 | QSPI1 | Quick SPI controller 1 (default) |

#### Address and Size Description

- `--address` parameter is in hexadecimal format, examples: `0x100000`, `0x200000`
- `--size` parameter is in decimal, unit is KB, examples: `64`, `128`
- When address and size are not specified, the program automatically selects a safe test area

### View Help

```shell
./spi_w25qxx.elf -h
```

### Usage Examples

```shell
# Run all tests with default parameters
./spi_w25qxx.elf

# Specify QSPI0, CS14, 5MHz, run all tests
./spi_w25qxx.elf -i 1 -c 14 -b 5

# Run only performance test, address 0x100000, size 64KB
./spi_w25qxx.elf -t perf -a 0x100000 -s 64

# Run device info test, specify OSPI controller
./spi_w25qxx.elf -i 0 -t info

# Run basic function test, use QSPI0, baud rate 20MHz
./spi_w25qxx.elf -i 1 -t basic -b 20
```

### View Results

The program will execute the corresponding tests according to the parameters and print a result summary, including:

1. Device information (model, capacity, address mode)
1. Basic function test (write enable/write disable)
1. Read/write test (erase-write-readback verification)
1. Boundary test
1. Performance test

Finally, it will output `ALL TESTS PASSED` or failure information.

```{admonition} Tip
Before using SPI, you need to complete the FPIOA pin multiplexing configuration first. Before writing, ensure that the target area has been erased (usually 0xFF), and note that devices with different capacities may involve 4-byte address mode switching.
```
