# How to Add a New Development Board

This article uses K230 CanMV 01Studio as an example to explain how to add a development board that supports U-Boot, RT-Smart, and CanMV simultaneously to the K230 RTOS SDK. The example consistently uses the following naming:

| Purpose | Name |
| --- | --- |
| Board-level directory name | `k230_canmv_01studio` |
| SDK defconfig | `k230_canmv_01studio_defconfig` |
| SDK Kconfig symbol | `BOARD_K230_CANMV_01STUDIO` |
| U-Boot Kconfig symbol | `TARGET_K230_CANMV_01STUDIO` |
| Firmware filename prefix | `CanMV_K230_01Studio` |

When the directory name, defconfig name, and `CONFIG_BOARD` are consistent, the SDK automatically uses the U-Boot and RT-Smart configuration files with the same name. `CONFIG_UBOOT_CONFIG_FILE` or `CONFIG_RTSMART_CONFIG_FILE` needs to be set in the SDK defconfig only when a subsystem uses a different name.

## Hardware Preparation Information

Before adding the configuration, make sure to confirm the following information:

1. Chip model, DDR type, capacity, bit width, and operating frequency.
1. Boot medium and the connection methods for SDIO0, SDIO1, SPI NOR, or SPI NAND.
1. Debug serial port, baud rate, and corresponding IO multiplexing.
1. Voltage of each IO Bank. Incorrect voltage configuration may damage the chip or peripherals.
1. Camera CSI, I2C, MCLK, RESET, and POWERDOWN connections.
1. On-board peripherals such as LCD, touch, Wi-Fi, and USB, as well as their control GPIOs.
1. Whether PMU_INT0 and PMU_INT4 are pulled up to `VCC_RTC_1V8` through board-level resistors.

Select an existing development board with the closest hardware as a template, but do not directly reuse its DDR, RESET GPIO, MCLK, display, boot medium, or PMU configuration. Automatically generated DTS files often contain only IOMUX sections, so the root node, memory node, and device nodes that need to be enabled must also be added.

Complete adaptation involves the following locations:

| Module | Path | Purpose |
| --- | --- | --- |
| SDK | `boards/Kconfig` | Register the development board and generate `CONFIG_BOARD` and the firmware name |
| SDK | `boards/k230_canmv_01studio/` | U-Boot environment, image layout, and optional prebuilt OpenSBI files |
| SDK | `configs/k230_canmv_01studio_defconfig` | SDK top-level feature configuration |
| U-Boot | `src/uboot/uboot/arch/riscv/Kconfig` | Register the U-Boot target |
| U-Boot | `src/uboot/uboot/board/kendryte/k230_canmv_01studio/` | Board-level initialization and DDR configuration |
| U-Boot | `src/uboot/uboot/arch/riscv/dts/k230_canmv_01studio.dts` | Memory, boot devices, and IOMUX |
| U-Boot | `src/uboot/uboot/configs/k230_canmv_01studio_defconfig` | U-Boot configuration |
| RT-Smart | `src/rtsmart/rtsmart/kernel/bsp/maix3/configs/k230_canmv_01studio_defconfig` | Kernel and driver configuration |
| RT-Smart | `src/rtsmart/rtsmart/kernel/bsp/maix3/board/configs/k230_canmv_01studio/` | Optional RT-Smart pinmux and power-on timing |
| CanMV | `src/canmv/port/boards/k230_canmv_01studio/` | MicroPython/CanMV board information |

## Registering an SDK Development Board

Add the board type to the `choice BOARD` in `boards/Kconfig` and select the correct chip:

```kconfig
config BOARD_K230_CANMV_01STUDIO
    bool "K230 CanMV 01 Studio, Onboard 1GiB LPDDR4"
    select BOARD_CHIP_K230
```

Then add mappings for the directory name, firmware name, and board-level Kconfig:

```kconfig
config BOARD
    string
    default "k230_canmv_01studio" if BOARD_K230_CANMV_01STUDIO

config BOARD_NAME
    string "Board Generate Image Name"
    default "CanMV_K230_01Studio" if BOARD_K230_CANMV_01STUDIO

source "$(SDK_BOARDS_DIR)/k230_canmv_01studio/Kconfig"
```

Create `boards/k230_canmv_01studio/`. Generally, you can copy a development board with the same boot medium and partition layout, then check the following files item by item:

- `Kconfig`: Board-level additional options, including the hardware RTC support status.
- `default.env`: Modify `board`, `board_name`, console, and boot commands.
- `genimage-sdcard.cfg`: Check the offset and size of SPL, U-Boot, RT-Smart, rtapp, and the filesystem.
- `genimage-sdcard-ota.cfg`: Check the OTA partition size and image name.
- `opensbi_fw_jump.bin`: Used when enabling prebuilt OpenSBI.

An example of the board names in `default.env` is as follows:

```text
board=k230_canmv_01studio
board_name=k230_canmv_01studio
console_port=console=ttyS0,115200
```

## Configuring the PMU and RTC

`PMU_INT0` and `PMU_INT4` are inputs used by the RTC/PMU driver. If neither pin is pulled up to `VCC_RTC_1V8` through a board-level resistor, do not enable the RTC/PMU driver, as floating inputs may cause startup failure.

This hardware design should refer to 01Studio and declare that hardware RTC is not supported in the board-level `boards/<board>/Kconfig`:

```kconfig
if BOARD_K230_CANMV_01STUDIO
    config BOARD_NOT_SUPPORT_HW_RTC
        def_bool y
endif
```

The corresponding RT-Smart defconfig should not include:

```kconfig
CONFIG_RT_USING_RTC_PMU=y
```

If the application still requires a system clock, the software RTC can be used:

```kconfig
CONFIG_RT_USING_SOFT_RTC=y
```

Only remove `BOARD_NOT_SUPPORT_HW_RTC` and enable `CONFIG_RT_USING_RTC_PMU=y` after the schematic confirms that `PMU_INT0` and `PMU_INT4` have stable external pull-ups to `VCC_RTC_1V8`.

## Selecting Prebuilt Components

When adding a new development board, U-Boot must be compiled from source. Do not enable the following in the SDK defconfig:

```kconfig
CONFIG_UBOOT_USE_PREBUILT=y
```

The prebuilt U-Boot has already fixed the DDR, DTS, IOMUX, and board initialization logic. Using it bypasses U-Boot source code modifications for the new development board. Even if `u-boot-spl.bin` and `u-boot.bin` exist in the reference board directory, do not copy them to the new development board directory.

OpenSBI's `fw_jump.bin` can be copied from a verified reference board. The reference board and the new board must use the same chip, memory layout, jump address, and console UART. For example:

```shell
cp boards/k230_canmv_01studio/opensbi_fw_jump.bin \
   boards/<new_board>/opensbi_fw_jump.bin
```

Then enable the following in the new board's SDK defconfig:

```kconfig
# CONFIG_UBOOT_USE_PREBUILT is not set
CONFIG_OPENSBI_USE_PREBUILT_FW_JUMP=y
```

If the OpenSBI jump address, memory reservation area, or console UART has been modified, OpenSBI must be recompiled, and the copied file must no longer be used.

## Adding the SDK defconfig

Create `configs/k230_canmv_01studio_defconfig`, retain the minimum configuration first, and then add Camera, display, network, and other peripherals according to the schematic:

```kconfig
CONFIG_BOARD_CONFIG_NAME="k230_canmv_01studio_defconfig"
CONFIG_BOARD_K230_CANMV_01STUDIO=y
# CONFIG_UBOOT_USE_PREBUILT is not set
CONFIG_OPENSBI_USE_PREBUILT_FW_JUMP=y
CONFIG_SDK_ENABLE_CANMV=y
```

The Camera `CONFIG_MPP_CSI_DEVx_RESET`, `CONFIG_MPP_CSI_DEVx_POWER`, and MCLK options must be filled in according to the schematic. The generic `GPIOxx` comments in the DTS cannot prove that the GPIO is the Sensor RESET. When using an external clock, retain the default `MPP_CSI_DEVx_MCLK_INVALID`.

After running `make k230_canmv_01studio_defconfig`, you can use `make menuconfig` to adjust the configuration, and use `make savedefconfig` to write it back to the SDK defconfig.

## Add U-Boot Support

### Register target

In the target choice in `src/uboot/uboot/arch/riscv/Kconfig`, add:

```kconfig
config TARGET_K230_CANMV_01STUDIO
    bool "Support k230_CANMV(01STUDIO)"
    select SYS_CACHE_SHIFT_6
```

And add the following to the board-level `source` list:

```kconfig
source "board/kendryte/k230_canmv_01studio/Kconfig"
```

### Add Board-Level Directory

Create `src/uboot/uboot/board/kendryte/k230_canmv_01studio/`, containing `Kconfig`, `Makefile`, `board.c`, and the board-level DDR initialization file. The key mappings in Kconfig are as follows:

```kconfig
if TARGET_K230_CANMV_01STUDIO

config SYS_CPU
    default "k230"

config SYS_VENDOR
    default "kendryte"

config SYS_BOARD
    default "k230_canmv_01studio"

config SYS_CONFIG_NAME
    default "k230_common"

config BOARD_SPECIFIC_OPTIONS
    def_bool y
    select KENDRYTE_K230

endif
```

DDR initialization parameters must come from the hardware validation results of the chip and DDR; they cannot simply be copied based on capacity. If the board has power sequencing, reset, or boot medium mandatory selection, add the corresponding logic in `board_early_init_f()` or `board_late_init()`.

### Adding DTS

Place the configuration generated by the IOMUX tool in `src/uboot/uboot/arch/riscv/dts/`. In addition to pinctrl, at least add the board identity, memory, and boot device:

```dts
#include "k230.dtsi"
#include "k230_canmv_01studio_iomux.dtsi"

/ {
    model = "kendryte k230 canmv 01studio sdcard";
    compatible = "kendryte,k230_canmv_01studio_sdcard";

    memory@0 {
        device_type = "memory";
        reg = <0x0 0x0 0x0 0x40000000>;
    };
};

&mmc0 {
    status = "okay";
};
```

Notes:

1. `0x40000000` represents 1 GiB and must match the actual DDR and SDK memory layout.
1. Enable only the nodes that actually exist, such as `mmc0`, `mmc1`, and `usbotg0`.
1. When changing the console, U-Boot, RT-Smart, OpenSBI, and `default.env` must be modified in sync.
1. The voltage of each IO Bank must match the schematic.
1. Both the DTS and the board-level DDR initialization code must participate in source compilation and cannot be replaced by a precompiled U-Boot.

### Add U-Boot defconfig

Create `src/uboot/uboot/configs/k230_canmv_01studio_defconfig`. You may copy the configuration for the same chip, DDR, and boot medium, and at minimum modify:

```kconfig
CONFIG_DEFAULT_DEVICE_TREE="k230_canmv_01studio"
CONFIG_TARGET_K230_CANMV_01STUDIO=y
```

After keeping `CONFIG_UBOOT_USE_PREBUILT` disabled in the SDK defconfig, the build system will use this defconfig to compile U-Boot.

## Add RT-Smart Support

Create `src/rtsmart/rtsmart/kernel/bsp/maix3/configs/k230_canmv_01studio_defconfig`. It is recommended to modify the configuration using the following commands:

```shell
make k230_canmv_01studio_defconfig
make rtsmart-menuconfig
```

The following must be checked according to the hardware:

- `CONFIG_RT_CONSOLE_DEVICE_NAME` and the SDK's `CONFIG_RTT_CONSOLE_UARTx`.
- The purposes, voltages, and bus widths of SDIO0 and SDIO1.
- The SDIO Host and REG_ON GPIO used by Wi-Fi.
- I2C, SPI, USB Device/Host, touch, and display drivers.
- When the PMU pins have no external pull-up, use `CONFIG_RT_USING_SOFT_RTC=y` and do not enable `CONFIG_RT_USING_RTC_PMU`.
- Whether the forced boot medium `CONFIG_DRV_SYSCTL_BOOT_FORCE_MODE` is actually needed.

The IOMUX configured in U-Boot will be retained in RT-Smart. Enable `CONFIG_RT_BOARD_ENABLE_PINMUX` or `CONFIG_RT_BOARD_ENABLE_PIN_INIT_SEQUENCE` and create the following only when RT-Smart needs to reconfigure all pinmux or perform the board power-on sequence:

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/board/configs/k230_canmv_01studio/pinmux_config.c
```

The file's IO selection, voltage, IE, OE, pull-up/pull-down, drive strength, and Schmitt trigger settings must be consistent with the U-Boot DTS.

## Add CanMV Support

Create `src/canmv/port/boards/k230_canmv_01studio/manifest.py`:

```python
include("../manifest.py")
```

Create `src/canmv/port/boards/k230_canmv_01studio/mpconfigboard.h`:

```c
#define MICROPY_HW_BOARD_NAME               CONFIG_BOARD
#define MICROPY_HW_MCU_NAME                 "K230"
#define OMV_ARCH_STR                        ""
#define OMV_BOARD_TYPE                      "CanMV K230 01Studio - %d%c"
```

The SDK's `CONFIG_BOARD` automatically selects the CanMV board directory with the same name. There is no need to modify CanMV's common Makefile.

## Configuration and Build Verification

First, confirm that the new configuration can be discovered and expanded correctly:

```shell
make list-def
make k230_canmv_01studio_defconfig
grep -E 'CONFIG_(BOARD|UBOOT_USE_PREBUILT|OPENSBI_USE_PREBUILT)' .config
```

The key results for the new development board should include:

```text
CONFIG_BOARD_K230_CANMV_01STUDIO=y
CONFIG_BOARD="k230_canmv_01studio"
# CONFIG_UBOOT_USE_PREBUILT is not set
CONFIG_OPENSBI_USE_PREBUILT_FW_JUMP=y
```

Then, build in stages to facilitate issue identification:

```shell
make uboot
make rtsmart
make opensbi
make canmv
make
```

The final image is located at:

```text
output/k230_canmv_01studio_defconfig/CanMV_K230_01Studio_*.img
```

Before flashing, the following should also be checked:

1. The U-Boot logs confirm that the new board's defconfig, DTS, and DDR initialization code are being used.
1. SPL, U-Boot, OpenSBI, and RT-Smart all output logs through the expected UART.
1. The system recognizes the correct DDR capacity and boot medium.
1. Sensor I2C can be detected, and the RESET, POWERDOWN, and MCLK timing is correct.
1. On boards without hardware RTC support, no RTC/PMU driver is registered, and the software RTC works correctly.
1. None of the image partitions exceed the sizes defined in `genimage-sdcard.cfg`.

## Multi-Repository Change Check

This SDK uses `repo` to manage multiple Git projects. Adding a new development board usually involves modifying the superproject, U-Boot, RT-Smart, and CanMV simultaneously. Before committing, use:

```shell
repo status
git status --short
git -C src/uboot/uboot status --short
git -C src/rtsmart/rtsmart status --short
git -C src/canmv status --short
```

Confirm that all new files are located in the correct Git projects and that no build artifacts or local `.config` files have been committed along with them.
