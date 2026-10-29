# 如何添加新开发板

本文以 K230 CanMV 01Studio 为例，说明如何在 K230 RTOS SDK 中添加一块同时支持 U-Boot、RT-Smart 和 CanMV 的开发板。示例统一使用以下命名：

| 用途 | 名称 |
| --- | --- |
| 板级目录名 | `k230_canmv_01studio` |
| SDK defconfig | `k230_canmv_01studio_defconfig` |
| SDK Kconfig 符号 | `BOARD_K230_CANMV_01STUDIO` |
| U-Boot Kconfig 符号 | `TARGET_K230_CANMV_01STUDIO` |
| 固件文件名前缀 | `CanMV_K230_01Studio` |

目录名、defconfig 名和 `CONFIG_BOARD` 保持一致时，SDK 会自动使用同名的 U-Boot 和 RT-Smart 配置文件。只有子系统使用不同名称时，才需要在 SDK defconfig 中设置 `CONFIG_UBOOT_CONFIG_FILE` 或 `CONFIG_RTSMART_CONFIG_FILE`。

## 准备硬件信息

添加配置前，至少需要确认以下信息：

1. 芯片型号、DDR 类型、容量、位宽和运行频率。
1. 启动介质以及 SDIO0、SDIO1、SPI NOR 或 SPI NAND 的连接方式。
1. 调试串口、波特率和对应的 IO 复用。
1. 各 IO Bank 的电压。电压配置错误可能损坏芯片或外设。
1. Camera 的 CSI、I2C、MCLK、RESET 和 POWERDOWN 连接。
1. LCD、触摸、Wi-Fi、USB 等板载外设及其控制 GPIO。
1. PMU_INT0、PMU_INT4 是否通过板级电阻上拉到 `VCC_RTC_1V8`。

选择硬件最接近的现有开发板作为模板，但不要直接沿用 DDR、RESET GPIO、MCLK、屏幕、启动介质和 PMU 配置。自动生成的 DTS 往往只包含 IOMUX 片段，还需要补充根节点、内存节点和需要启用的设备节点。

完整适配涉及以下位置：

| 模块 | 路径 | 作用 |
| --- | --- | --- |
| SDK | `boards/Kconfig` | 注册开发板并生成 `CONFIG_BOARD`、固件名称 |
| SDK | `boards/k230_canmv_01studio/` | U-Boot 环境、镜像布局和可选的 OpenSBI 预编译文件 |
| SDK | `configs/k230_canmv_01studio_defconfig` | SDK 顶层功能配置 |
| U-Boot | `src/uboot/uboot/arch/riscv/Kconfig` | 注册 U-Boot target |
| U-Boot | `src/uboot/uboot/board/kendryte/k230_canmv_01studio/` | 板级初始化和 DDR 配置 |
| U-Boot | `src/uboot/uboot/arch/riscv/dts/k230_canmv_01studio.dts` | 内存、启动设备和 IOMUX |
| U-Boot | `src/uboot/uboot/configs/k230_canmv_01studio_defconfig` | U-Boot 配置 |
| RT-Smart | `src/rtsmart/rtsmart/kernel/bsp/maix3/configs/k230_canmv_01studio_defconfig` | 内核和驱动配置 |
| RT-Smart | `src/rtsmart/rtsmart/kernel/bsp/maix3/board/configs/k230_canmv_01studio/` | 可选的 RT-Smart pinmux 和上电时序 |
| CanMV | `src/canmv/port/boards/k230_canmv_01studio/` | MicroPython/CanMV 板级信息 |

## 注册 SDK 开发板

在 `boards/Kconfig` 的 `choice BOARD` 中增加板型，并选择正确的芯片：

```kconfig
config BOARD_K230_CANMV_01STUDIO
    bool "K230 CanMV 01 Studio, Onboard 1GiB LPDDR4"
    select BOARD_CHIP_K230
```

随后增加目录名、固件名和板级 Kconfig 的映射：

```kconfig
config BOARD
    string
    default "k230_canmv_01studio" if BOARD_K230_CANMV_01STUDIO

config BOARD_NAME
    string "Board Generate Image Name"
    default "CanMV_K230_01Studio" if BOARD_K230_CANMV_01STUDIO

source "$(SDK_BOARDS_DIR)/k230_canmv_01studio/Kconfig"
```

创建 `boards/k230_canmv_01studio/`。通常可复制启动介质和分区布局相同的开发板，再逐项检查以下文件：

- `Kconfig`：板级附加选项，包括硬件 RTC 支持状态。
- `default.env`：修改 `board`、`board_name`、控制台和启动命令。
- `genimage-sdcard.cfg`：检查 SPL、U-Boot、RT-Smart、rtapp 和文件系统的 offset、size。
- `genimage-sdcard-ota.cfg`：检查 OTA 分区大小和镜像名称。
- `opensbi_fw_jump.bin`：启用预编译 OpenSBI 时使用。

`default.env` 中的板名示例如下：

```text
board=k230_canmv_01studio
board_name=k230_canmv_01studio
console_port=console=ttyS0,115200
```

## 配置 PMU 和 RTC

`PMU_INT0` 和 `PMU_INT4` 是 RTC/PMU 驱动使用的输入。若这两个引脚都没有通过板级电阻上拉到 `VCC_RTC_1V8`，不要启用 RTC/PMU 驱动，否则悬空输入可能导致启动失败。

这种硬件设计应参考 01Studio，在板级 `boards/<board>/Kconfig` 中声明不支持硬件 RTC：

```kconfig
if BOARD_K230_CANMV_01STUDIO
    config BOARD_NOT_SUPPORT_HW_RTC
        def_bool y
endif
```

对应的 RT-Smart defconfig 不要包含：

```kconfig
CONFIG_RT_USING_RTC_PMU=y
```

如果应用仍需要系统时钟，可使用软件 RTC：

```kconfig
CONFIG_RT_USING_SOFT_RTC=y
```

只有原理图确认 `PMU_INT0`、`PMU_INT4` 有稳定的 `VCC_RTC_1V8` 外部上拉才移除 `BOARD_NOT_SUPPORT_HW_RTC` 并启用 `CONFIG_RT_USING_RTC_PMU=y`。

## 选择预编译组件

新增开发板时必须从源码编译 U-Boot，不要在 SDK defconfig 中启用：

```kconfig
CONFIG_UBOOT_USE_PREBUILT=y
```

预编译 U-Boot 已经固化了 DDR、DTS、IOMUX 和板级初始化逻辑。使用它会绕过新开发板的 U-Boot 源码修改。即使参考板目录中存在 `u-boot-spl.bin` 和 `u-boot.bin`，也不要将它们复制到新开发板目录。

OpenSBI 的 `fw_jump.bin` 可以从已验证的参考板复制。参考板与新板必须使用相同芯片、内存布局、跳转地址和控制台 UART。例如：

```shell
cp boards/k230_canmv_01studio/opensbi_fw_jump.bin \
   boards/<new_board>/opensbi_fw_jump.bin
```

然后在新板的 SDK defconfig 中启用：

```kconfig
# CONFIG_UBOOT_USE_PREBUILT is not set
CONFIG_OPENSBI_USE_PREBUILT_FW_JUMP=y
```

若修改了 OpenSBI 跳转地址、内存保留区或控制台 UART，应重新编译 OpenSBI，不能继续使用复制的文件。

## 添加 SDK defconfig

创建 `configs/k230_canmv_01studio_defconfig`，先保留最少配置，再根据原理图增加 Camera、显示、网络和其他外设：

```kconfig
CONFIG_BOARD_CONFIG_NAME="k230_canmv_01studio_defconfig"
CONFIG_BOARD_K230_CANMV_01STUDIO=y
# CONFIG_UBOOT_USE_PREBUILT is not set
CONFIG_OPENSBI_USE_PREBUILT_FW_JUMP=y
CONFIG_SDK_ENABLE_CANMV=y
```

Camera 的 `CONFIG_MPP_CSI_DEVx_RESET`、`CONFIG_MPP_CSI_DEVx_POWER` 和 MCLK 选项必须依据原理图填写。DTS 中的通用 `GPIOxx` 注释不能证明该 GPIO 就是 Sensor RESET。使用外部时钟时保留默认的 `MPP_CSI_DEVx_MCLK_INVALID`。

运行 `make k230_canmv_01studio_defconfig` 后，可以用 `make menuconfig` 调整配置，并使用 `make savedefconfig` 回写 SDK defconfig。

## 添加 U-Boot 支持

### 注册 target

在 `src/uboot/uboot/arch/riscv/Kconfig` 的 target choice 中增加：

```kconfig
config TARGET_K230_CANMV_01STUDIO
    bool "Support k230_CANMV(01STUDIO)"
    select SYS_CACHE_SHIFT_6
```

并在板级 `source` 列表中增加：

```kconfig
source "board/kendryte/k230_canmv_01studio/Kconfig"
```

### 添加板级目录

创建 `src/uboot/uboot/board/kendryte/k230_canmv_01studio/`，包含 `Kconfig`、`Makefile`、`board.c` 和板级 DDR 初始化文件。Kconfig 的关键映射如下：

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

DDR 初始化参数必须来自芯片和 DDR 的硬件验证结果，不能仅按容量复制。板上存在电源时序、复位或启动介质强制选择时，在 `board_early_init_f()` 或 `board_late_init()` 中增加对应逻辑。

### 添加 DTS

将 IOMUX 工具生成的配置放入 `src/uboot/uboot/arch/riscv/dts/`。除 pinctrl 外，至少补充板级身份、内存和启动设备：

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

注意事项：

1. `0x40000000` 表示 1 GiB，必须与实际 DDR 和 SDK 内存布局一致。
1. 只启用实际存在的 `mmc0`、`mmc1`、`usbotg0` 等节点。
1. 更换控制台时，U-Boot、RT-Smart、OpenSBI 和 `default.env` 必须同步修改。
1. 每个 IO Bank 的电压必须与原理图一致。
1. DTS 和板级 DDR 初始化代码都必须参与源码编译，不能由预编译 U-Boot 替代。

### 添加 U-Boot defconfig

创建 `src/uboot/uboot/configs/k230_canmv_01studio_defconfig`。可复制同芯片、同 DDR 和同启动介质的配置，并至少修改：

```kconfig
CONFIG_DEFAULT_DEVICE_TREE="k230_canmv_01studio"
CONFIG_TARGET_K230_CANMV_01STUDIO=y
```

SDK defconfig 保持 `CONFIG_UBOOT_USE_PREBUILT` 关闭后，构建系统会使用该 defconfig 编译 U-Boot。

## 添加 RT-Smart 支持

创建 `src/rtsmart/rtsmart/kernel/bsp/maix3/configs/k230_canmv_01studio_defconfig`。建议通过以下命令修改配置：

```shell
make k230_canmv_01studio_defconfig
make rtsmart-menuconfig
```

需要根据硬件检查：

- `CONFIG_RT_CONSOLE_DEVICE_NAME` 与 SDK 的 `CONFIG_RTT_CONSOLE_UARTx`。
- SDIO0、SDIO1 的用途、电压和总线宽度。
- Wi-Fi 使用的 SDIO Host 和 REG_ON GPIO。
- I2C、SPI、USB Device/Host、触摸和显示驱动。
- PMU 引脚没有外部上拉时，使用 `CONFIG_RT_USING_SOFT_RTC=y`，不要启用 `CONFIG_RT_USING_RTC_PMU`。
- 强制启动介质 `CONFIG_DRV_SYSCTL_BOOT_FORCE_MODE` 是否确实需要。

U-Boot 配置的 IOMUX 会保留到 RT-Smart。只有 RT-Smart 需要重新配置全部 pinmux 或执行板级上电时序时，才启用 `CONFIG_RT_BOARD_ENABLE_PINMUX` 或 `CONFIG_RT_BOARD_ENABLE_PIN_INIT_SEQUENCE`，并创建：

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/board/configs/k230_canmv_01studio/pinmux_config.c
```

该文件的 IO 选择、电压、IE、OE、上下拉、驱动能力和施密特触发配置必须与 U-Boot DTS 保持一致。

## 添加 CanMV 支持

创建 `src/canmv/port/boards/k230_canmv_01studio/manifest.py`：

```python
include("../manifest.py")
```

创建 `src/canmv/port/boards/k230_canmv_01studio/mpconfigboard.h`：

```c
#define MICROPY_HW_BOARD_NAME               CONFIG_BOARD
#define MICROPY_HW_MCU_NAME                 "K230"
#define OMV_ARCH_STR                        ""
#define OMV_BOARD_TYPE                      "CanMV K230 01Studio - %d%c"
```

SDK 的 `CONFIG_BOARD` 会自动选择同名的 CanMV 板级目录，不需要修改 CanMV 的公共 Makefile。

## 配置和编译验证

首先确认新配置可被发现并正确展开：

```shell
make list-def
make k230_canmv_01studio_defconfig
grep -E 'CONFIG_(BOARD|UBOOT_USE_PREBUILT|OPENSBI_USE_PREBUILT)' .config
```

新开发板的关键结果应包含：

```text
CONFIG_BOARD_K230_CANMV_01STUDIO=y
CONFIG_BOARD="k230_canmv_01studio"
# CONFIG_UBOOT_USE_PREBUILT is not set
CONFIG_OPENSBI_USE_PREBUILT_FW_JUMP=y
```

然后分阶段编译，便于定位问题：

```shell
make uboot
make rtsmart
make opensbi
make canmv
make
```

最终镜像位于：

```text
output/k230_canmv_01studio_defconfig/CanMV_K230_01Studio_*.img
```

烧录前还应检查：

1. U-Boot 日志确认使用了新板的 defconfig、DTS 和 DDR 初始化代码。
1. SPL、U-Boot、OpenSBI 和 RT-Smart 均从预期 UART 输出日志。
1. 系统识别到正确的 DDR 容量和启动介质。
1. Sensor I2C 可以探测，RESET、POWERDOWN 和 MCLK 时序正确。
1. 不支持硬件 RTC 的板上没有注册 RTC/PMU 驱动，软件 RTC 工作正常。
1. 镜像各分区没有超出 `genimage-sdcard.cfg` 定义的大小。

## 多仓库变更检查

该 SDK 使用 `repo` 管理多个 Git 项目。新增开发板通常同时修改 superproject、U-Boot、RT-Smart 和 CanMV。提交前使用：

```shell
repo status
git status --short
git -C src/uboot/uboot status --short
git -C src/rtsmart/rtsmart status --short
git -C src/canmv status --short
```

确认所有新文件都位于正确的 Git 项目中，且没有把构建产物或本地 `.config` 一并提交。
