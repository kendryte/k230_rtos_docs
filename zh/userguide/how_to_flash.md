# 如何烧录固件

本文介绍如何通过 USB 将固件烧录到 K230 开发板，同时适用于 K230 RTOS 固件和 CanMV/MicroPython 固件。固件中运行的是 RTOS 还是 MicroPython，不会改变进入 USB 烧录模式和使用烧录工具的方法。

所有工具均通过 `K230 USB Boot Device` 烧录。选择 `SDCARD` 作为目标介质时，仍然是通过开发板的 USB 接口写入 SD 卡。

## 快速开始

### 选择工具

| 使用场景 | 工具 | 说明 |
| --- | --- | --- |
| 首次烧录、日常使用 | [K230BurningTool](https://github.com/kendryte/k230_burning_tool) | 图形界面，推荐大多数用户使用，也支持同时烧录多台设备 |
| 终端或 CI 自动化 | [k230_flash](https://github.com/kendryte/k230_flash) | C++ 命令行工具，无需 Python 环境 |
| Python 脚本或二次开发 | [k230_flash_py](https://github.com/kendryte/k230_flash_py) | 提供 Python 命令行工具和 API |

普通用户直接使用 K230BurningTool 即可。只有需要无人值守烧录、CI 集成或二次开发时，才需要选择命令行或 Python 版本；具体用法请查看表中的项目链接。

### K230BurningTool 最短流程

1. 准备与开发板型号、内存配置和启动介质匹配的 `*.kdimg` 或已解压的 `*.img` 固件。
1. 从 [K230 工具下载页面](https://www.kendryte.com/zh/resource/download_tool,k230) 或 [K230BurningTool Releases](https://github.com/kendryte/k230_burning_tool/releases) 下载并启动工具。
1. 按住开发板的 **BOOT** 按键，插入 USB 线并上电，电脑检测到设备后松开 **BOOT**。
1. 如果 Windows 无法识别 `K230 USB Boot Device`，使用 Zadig 为该设备安装 WinUSB 驱动。
1. 在工具中打开固件，选择正确的目标介质，依次点击 **开始** 和 **确认**；完成后复位开发板或重新上电。

能够完成以上步骤时，无需阅读其余操作细节。需要确认镜像格式、目标介质、驱动或完整图形界面步骤时，请继续阅读下文。

## 详细说明

### 烧录前准备

开始前，请准备与开发板型号、内存配置和启动介质匹配的固件：

- 使用 SDK 编译时，镜像通常位于 `output/<defconfig>/images/` 目录。
- 使用 CanMV/MicroPython 时，可以使用 SDK 编译生成的镜像，也可以使用开发板厂商提供的对应固件。

#### 镜像格式

- `*.kdimg`：包含分区信息，推荐使用 K230BurningTool 直接烧录。
- `*.img`、`*.bin`：原始镜像，K230BurningTool 均支持烧录。
- `*.gz`、`*.tgz`、`*.zip`：CanMV/MicroPython 固件可能以压缩包发布，使用 K230BurningTool 前请先解压。

> 同一开发板可能同时提供 RTOS 和 CanMV/MicroPython 固件。烧录前请核对固件名称，不要将其他板型或其他内存（电压）配置的固件写入设备。

#### 目标介质

K230 常用的固件启动介质如下：

- `EMMC`：连接到 K230 的 eMMC 。
- `SDCARD`：连接到 K230 的 SD 卡。
- `SPI_NAND`：连接到 SPI 总线的 NAND Flash。
- `SPI_NOR`：连接到 SPI 总线的 NOR Flash。

烧录前请根据开发板原理图或板卡说明确认目标介质。选择错误时，工具通常会报告 `Device Can't find Medium as Configured`。

在 K230BurningTool 中，目标为 eMMC、SD 卡、SPI NAND 或 SPI NOR 时，请分别选择 `EMMC`、`SDCARD`、`SPI_NAND` 或 `SPI_NOR`。

请使用支持数据传输的 USB 线，并确保烧录期间供电稳定，不要拔出设备或存储介质。

> 如果使用的 SD Card/TF Card 需要将其插入板子，并确认插好（并不是放进卡槽就可以的）。

### 进入 USB 烧录模式

推荐在开发板断电时操作：

1. 按住开发板上的 **BOOT** 按键。
1. 插入 USB 线，将开发板连接到电脑并上电。
1. 电脑检测到设备后松开 **BOOT** 按键。

开发板已经上电时，也可以按以下顺序操作：

1. 按住 **BOOT** 按键。
1. 按下 **RESET** 按键。
1. 松开 **RESET** 按键。
1. 最后松开 **BOOT** 按键。

成功进入烧录模式后，Windows 设备管理器中会出现 `K230 USB Boot Device`。该设备的 USB VID 为 `29f1`，PID 为 `0230`。

<!-- 图片占位：标注开发板的 BOOT、RESET、供电接口和 USB 数据接口，并展示进入烧录模式的按键顺序。 -->

### 安装 USB 驱动

#### Windows

如果设备管理器无法识别 `K230 USB Boot Device`，首次使用时需要安装 WinUSB 驱动：

1. 下载并运行 [Zadig](https://zadig.akeo.ie/)。
1. 选择 **Options > List All Devices**。
1. 在设备列表中选择 **K230 USB Boot Device**。设备也可能显示为 `Unknown Device`，此时请核对 VID `29f1` 和 PID `0230`。
1. 在 Driver 中选择 **WinUSB**。如果已经安装，可以选择重新安装。
1. 点击 **Install Driver**，等待安装完成。
1. 重新插拔设备，并确认设备管理器显示 `K230 USB Boot Device (WinUSB)`。

![zadig](https://www.kendryte.com/api/imagecdn/zh/zadig_intall.png)

> 只为 `K230 USB Boot Device` 安装 WinUSB 驱动。不要修改正常运行时显示的 `CanMV` 设备驱动，否则可能影响 CanMV IDE 或 MicroPython 的 USB 通信。

#### Linux

Linux 通常不需要安装额外驱动。若普通用户没有 USB 访问权限，请创建 `/etc/udev/rules.d/99-k230.rules`，内容如下：

```text
SUBSYSTEM=="usb", ATTRS{idVendor}=="29f1", ATTRS{idProduct}=="0230", MODE="0666"
```

重新加载规则，然后重新插拔开发板：

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

#### macOS

macOS 通常无需额外配置。如果工具提示缺少 libusb，可以使用 Homebrew 安装：

```bash
brew install libusb
```

### 使用 K230BurningTool（推荐）

可从以下位置下载与操作系统对应的版本：

- [K230 工具下载页面](https://www.kendryte.com/zh/resource/download_tool,k230)
- [K230BurningTool Releases](https://github.com/kendryte/k230_burning_tool/releases)

烧录步骤：

1. 启动 K230BurningTool，点击 **打开** 并选择镜像文件。工具支持 `*.kdimg`、`*.img` 和 `*.bin` 等格式。
1. 根据开发板实际存储器选择 **目标介质**。如果打开的是 `*.kdimg`，还可以选择需要烧录的分区。
1. 使开发板进入 USB 烧录模式并连接电脑。工具支持等待设备接入，因此也可以先点击 **开始**，再连接开发板。
1. 点击 **开始**，等待进度完成。烧录过程中不要断开 USB 或电源。
1. 烧录完成后点击 **确认**。需要重新运行固件时，复位开发板或重新上电。

选择烧录介质：
![选择烧录介质](https://www.kendryte.com/api/imagecdn/zh/medium.png)

烧录完整流程：
![K230BurningTool 界面](https://www.kendryte.com/api/post/attachment?id=536)

K230BurningTool 支持同时连接多台设备进行烧录。需要定制工具时，可参考 [K230BurningTool 源码](https://github.com/kendryte/k230_burning_tool)。

## 常见问题

### 工具检测不到开发板

- 重新按照 **BOOT + 上电** 的顺序进入 USB 烧录模式。
- Windows 用户确认设备使用 WinUSB 驱动，并核对 VID `29f1`、PID `0230`。
- 更换支持数据传输的 USB 线、USB 接口或电脑。
- Linux 用户检查 udev 规则；也可临时使用 `sudo` 运行命令，以确认是否为权限问题。

### 提示 `Timeout for Waiting Device Plugin`

工具在等待时间内没有检测到处于 BootROM 模式的设备。按住 **BOOT** 重新上电，再次开始烧录。

### 提示 `Device Can't find Medium as Configured`

- 检查所选目标介质是否与开发板硬件一致。
- 烧录 SD 卡时，断电后重新插紧 SD 卡，再次尝试。

### 烧录成功但开发板无法启动

- 确认镜像对应当前开发板型号、内存配置和运行环境（RTOS 或 CanMV/MicroPython）。
- 确认启动介质与烧录时选择的目标介质一致。
- 使用 SD 卡时，重新插卡或更换可靠的 SD 卡。
- 复位开发板或断电后重新上电。

## 相关教程

- [图文教程：K230 USB 烧录工具全攻略](https://www.kendryte.com/answer/questions/10010000000008370)
- [视频教程：K230 USB 烧录功能介绍](https://www.bilibili.com/video/BV1S2QqYoE7r/)
