# SPI ST7789 Example

## Introduction

This example demonstrates the complete process of driving an ST7789 screen based on the RT-Smart HAL driver, including SPI communication, initialization, frame buffer drawing, and screen refresh.

## Code Location

Demo source location: `src/rtsmart/examples/peripheral/spi_st7789`

Main file: `test_spi_st7789.c`

## Current Example Behavior

In the current version of the example, `main()` performs the following actions:

1. Configure FPIOA and SPI pins
1. Create the LCD instance (SPI + DC/RST/BL GPIO)
1. Configure resolution and initialize ST7789
1. Clear the screen and draw three lines of colored strings
1. Refresh the display, wait 5 seconds, then exit

The display content is:

- `RED, Hello World!`
- `GREEN, Hello World!`
- `BLUE, Hello World!`

## Main Interfaces (Based on Current Source Code)

- `lcd_create()`
- `lcd_configure()`
- `lcd_init()`
- `lcd_fill()`
- `lcd_draw_string()`
- `lcd_show()`
- `lcd_destroy()`

## Default Pins and Parameters (Hard-coded in Source)

The example uses the following defaults:

- `spi_id = 1`
- `pin_cs = 19`
- `pin_dc = 20`
- `pin_rst = 12`

The SPI clock is configured to 50MHz in the current code, and the mode is `SPI_HAL_MODE_3`.

## Build Method

In the root directory of the `K230 RTOS SDK`, use `make menuconfig` to enable the corresponding peripheral example, then build the firmware.

## Running the Example

The build product name matches the directory name. The run command should be:

```shell
cd /sdcard/app/examples/peripheral
./spi_st7789.elf
```

## Notes

1. The pins in this example are hard-coded in the source code and need to be modified according to the actual wiring on the development board.
1. The supply voltage, reset polarity, and backlight control method of the ST7789 module may vary depending on the module.
1. Please confirm that the FPIOA multiplexing configuration matches the selected SPI controller before use.
