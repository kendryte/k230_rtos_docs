# How to Flash Firmware

This document describes how to flash firmware to a K230 development board via USB. It applies to both K230 RTOS firmware and CanMV/MicroPython firmware. Whether the firmware runs RTOS or MicroPython does not change how to enter USB flashing mode or use the flashing tool.

All tools flash through `K230 USB Boot Device`. When `SDCARD` is selected as the target medium, the SD card is still written through the development board's USB interface.

## Quick Start

### Tool Selection

| Use Case | Tool | Description |
| --- | --- | --- |
| Initial flashing and daily use | [K230BurningTool](https://github.com/kendryte/k230_burning_tool) | Graphical interface, recommended for most users; also supports flashing multiple devices simultaneously |
| Terminal or CI automation | [k230_flash](https://github.com/kendryte/k230_flash) | C++ command-line tool, no Python environment required |
| Python scripting or secondary development | [k230_flash_py](https://github.com/kendryte/k230_flash_py) | Provides a Python command-line tool and API |

Ordinary users can simply use K230BurningTool. Command-line or Python versions are only needed for unattended flashing, CI integration, or secondary development; please refer to the project links in the table for specific usage instructions.

### K230BurningTool Shortest Workflow

1. Prepare firmware in `*.kdimg` format or an unpacked `*.img` file that matches the development board model, memory configuration, and boot medium.
1. Download and launch the tool from the [K230 Tool Download Page](https://www.kendryte.com/zh/resource/download_tool,k230) or [K230BurningTool Releases](https://github.com/kendryte/k230_burning_tool/releases).
1. Hold down the development board's **BOOT** button, connect the USB cable, and power on. Release **BOOT** after the computer detects the device.
1. If Windows cannot recognize `K230 USB Boot Device`, use Zadig to install the WinUSB driver for the device.
1. Open the firmware in the tool, select the correct target medium, and click **Start** and **Confirm** in order; after completion, reset the development board or power it on again.

If you can complete the steps above, you do not need to read the remaining operational details. Continue reading below when you need to confirm the image format, target medium, driver, or complete GUI steps.

## Detailed Description

### Flashing Preparation

Before starting, please prepare firmware that matches the development board model, memory configuration, and boot medium:

- When compiling with the SDK, the image is usually located in the `output/<defconfig>/images/` directory.
- When using CanMV/MicroPython, you can use an image compiled with the SDK or the corresponding firmware provided by the development board vendor.

#### Image Format

- `*.kdimg`: Contains partition information; it is recommended to use K230BurningTool for direct flashing.
- `*.img`, `*.bin`: Raw images; K230BurningTool supports flashing both.
- `*.gz`, `*.tgz`, `*.zip`: CanMV/MicroPython firmware may be released as compressed archives; decompress it before using K230BurningTool.

> The same development board may provide both RTOS and CanMV/MicroPython firmware. Please verify the firmware name before flashing, and do not write firmware for other board models or other memory (voltage) configurations to the device.

#### Target Media

The commonly used firmware boot media for K230 are as follows:

- `EMMC`: Connected to the eMMC of the K230.
- `SDCARD`: Connected to the SD card of the K230.
- `SPI_NAND`: NAND Flash connected to the SPI bus.
- `SPI_NOR`: NOR Flash connected to the SPI bus.

Before flashing, please confirm the target media based on the development board schematic or board documentation. If the wrong one is selected, the tool usually reports `Device Can't find Medium as Configured`.

In K230BurningTool, when the target is eMMC, SD card, SPI NAND, or SPI NOR, select `EMMC`, `SDCARD`, `SPI_NAND`, or `SPI_NOR`, respectively.

Please use a USB cable that supports data transfer, ensure stable power supply during flashing, and do not unplug the device or storage media.

> If an SD Card/TF Card is used, it needs to be inserted into the board and confirmed to be properly seated (merely placing it in the slot is not sufficient).

### Entering USB Flashing Mode

It is recommended to perform these steps while the development board is powered off:

1. Press and hold the **BOOT** button on the development board.
1. Connect the development board to the computer using a USB cable and power it on.
1. Release the **BOOT** button after the computer detects the device.

If the development board is already powered on, you can also follow the steps below:

1. Press and hold the **BOOT** button.
1. Press the **RESET** button.
1. Release the **RESET** button.
1. Finally, release the **BOOT** button.

After successfully entering flashing mode, `K230 USB Boot Device` will appear in Windows Device Manager. The USB VID of this device is `29f1`, and the PID is `0230`.

<!-- Image placeholder: Label the BOOT, RESET, power supply interface, and USB data interface on the development board, and show the button sequence for entering flashing mode. -->

### Install USB Driver

#### Windows

If Device Manager does not recognize `K230 USB Boot Device`, you need to install the WinUSB driver when using it for the first time:

1. Download and run [Zadig](https://zadig.akeo.ie/).
1. Select **Options > List All Devices**.
1. Select **K230 USB Boot Device** in the device list. The device may also appear as `Unknown Device`; in this case, verify VID `29f1` and PID `0230`.
1. Select **WinUSB** under Driver. If it is already installed, you can choose to reinstall it.
1. Click **Install Driver** and wait for the installation to complete.
1. Unplug and reconnect the device, and confirm that Device Manager displays `K230 USB Boot Device (WinUSB)`.

![zadig](https://www.kendryte.com/api/imagecdn/zh/zadig_intall.png)

> Install the WinUSB driver only for `K230 USB Boot Device`. Do not modify the `CanMV` device driver displayed during normal operation, as this may affect USB communication in CanMV IDE or MicroPython.

#### Linux

Linux typically does not require additional drivers. If a regular user does not have USB access permission, create `/etc/udev/rules.d/99-k230.rules` with the following content:

```text
SUBSYSTEM=="usb", ATTRS{idVendor}=="29f1", ATTRS{idProduct}=="0230", MODE="0666"
```

Reload the rules, then unplug and reconnect the development board:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

#### macOS

macOS usually requires no additional configuration. If the tool indicates that libusb is missing, you can install it using Homebrew:

```bash
brew install libusb
```

### Using K230BurningTool (Recommended)

You can download the version corresponding to your operating system from the following locations:

- [K230 Tool Download Page](https://www.kendryte.com/zh/resource/download_tool,k230)
- [K230BurningTool Releases](https://github.com/kendryte/k230_burning_tool/releases)

Flashing steps:

1. Launch K230BurningTool, click **Open**, and select the image file. The tool supports formats such as `*.kdimg`, `*.img`, and `*.bin`.
1. Select the **Target Media** according to the development board's actual storage. If a `*.kdimg` file is opened, you can also select the partitions to be flashed.
1. Put the development board into USB flashing mode and connect it to the computer. The tool supports waiting for a device to connect, so you can also click **Start** first and then connect the development board.
1. Click **Start** and wait for the progress to complete. Do not disconnect the USB or power supply during flashing.
1. After flashing is complete, click **Confirm**. To run the firmware again, reset the development board or power it on again.

Select the flashing media:
![Select the flashing media](https://www.kendryte.com/api/imagecdn/zh/medium.png)

Complete flashing process:
![K230BurningTool interface](https://www.kendryte.com/api/post/attachment?id=536)

K230BurningTool supports flashing multiple devices connected simultaneously. For custom tool development, refer to the [K230BurningTool source code](https://github.com/kendryte/k230_burning_tool).

## Frequently Asked Questions

### The tool cannot detect the development board

- Enter USB flashing mode again by following the **BOOT + power-on** sequence.
- Windows users should confirm that the device uses the WinUSB driver and verify VID `29f1` and PID `0230`.
- Try a different USB cable, USB port, or computer that supports data transfer.
- Linux users should check the udev rules; they can also temporarily run the command using `sudo` to determine whether it is a permissions issue.

### Prompt `Timeout for Waiting Device Plugin`

The tool did not detect a device in BootROM mode within the waiting period. Press and hold **BOOT**, power on again, and start flashing once more.

### Message `Device Can't find Medium as Configured`

- Check whether the selected target medium matches the development board hardware.
- When flashing the SD card, power off, reinsert the SD card securely, and try again.

### Flashing succeeds but the development board cannot boot

- Confirm that the image matches the current development board model, memory configuration, and runtime environment (RTOS or CanMV/MicroPython).
- Confirm that the boot medium matches the target medium selected during flashing.
- When using an SD card, reinsert the card or replace it with a reliable SD card.
- Reset the development board or power it off and back on.

## Related Tutorials

- [Illustrated Tutorial: A Complete Guide to the K230 USB Flashing Tool](https://www.kendryte.com/answer/questions/10010000000008370)
- [Video Tutorial: Introduction to the K230 USB Flashing Feature](https://www.bilibili.com/video/BV1S2QqYoE7r/)
