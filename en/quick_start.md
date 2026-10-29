# Quick Start Guide

## What You Will Accomplish

The goal of this page is to help you complete a "verifiably successful" process in the shortest amount of time:

1. Download the SDK source code
1. Select the board configuration and build the image
1. Flash it to the development board
1. Log in via serial port and run the first example

If you want to see the full instructions, please go to the user guide:

- [How to Build Firmware](./userguide/how_to_build.md)
- [How to Flash Firmware](./userguide/how_to_flash.md)
- [How to Run Sample Programs](./userguide/how_to_run_samples.md)

## Prerequisites

- Host system: Ubuntu 20.04 x86_64 (recommended)
- Development board, serial cable, USB cable (or SD card reader) connected
- Available network (for `repo sync` and toolchain download)

```{warning}
If using an external USB-to-serial module to connect to the board's UART, first read [Serial Levels and Interface Module Safety](./app_develop_guide/peripheral/uart.md). The board's I/O voltage level must match either 1.8 V or 3.3 V. Using 5 V signals and inferior CH340G modules shown in the images in the document is prohibited.
```

## 15-Minute Onboarding Path

### 1. Download the Source Code

```bash
mkdir -p ~/rtos_k230 && cd ~/rtos_k230
repo init -u git@gitee.com:canmv-k230/manifest.git --repo-url=git@gitee.com:canmv-k230/git-repo.git
repo sync -j $(nproc)
```

### 2. Download the Toolchain (First Time Only)

```bash
make dl_toolchain
```

### 3. Select the Board Configuration

```bash
# View available configurations
make list-def

# Example: 01Studio
make k230_rtos_01studio_defconfig
```

If your board only has `k230_canmv_*_defconfig`, you can also select it first, then use `menuconfig` to disable CanMV and enable RTOS-side capabilities (see the section "How to Build an RTOS Image When Only CanMV defconfig Is Available" in [How to Build Firmware](./userguide/how_to_build.md)).

### 4. Build the Image

```bash
time make log
```

Build results are typically located at:

```text
output/<defconfig>/images/
```

Common files:

- `*.kdimg`: Recommended for K230BurningTool (USB)
- `*.img`: Commonly used for SD card imaging or command-line flashing

### 5. Flash and Boot

It is recommended to first use K230BurningTool to flash `*.kdimg`. See [How to Flash Firmware](./userguide/how_to_flash.md) for the steps.

After booting, use a serial port tool to connect to the development board (commonly 115200 baud rate) and enter the RT-Smart shell.

### 6. Run the First Example

```bash
cd /sdcard/app/examples
find . -name "*.elf" | head
./integrated_poc/smart_ipc.elf
```

If the example path is different, please refer to the output of `find`.

## Common Entry Points

- Add/Modify Applications: [`userguide/helloworld.md`](./userguide/helloworld.md)
- View Supported Sensors and Enable Methods: [`hardware_compatibility/sensor_list.md`](./hardware_compatibility/sensor_list.md)
- Application Development Guide: [`app_develop_guide/index.md`](./app_develop_guide/index.md)
- API Reference: [`api_reference/index.md`](./api_reference/index.md)

## Next Steps

1. First, run through an existing example to confirm that the toolchain, flashing, and serial port link are all working properly
1. Then enable/trim the examples and application switches you need
1. Finally, solidify it into a unified team defconfig to avoid configuration drift
