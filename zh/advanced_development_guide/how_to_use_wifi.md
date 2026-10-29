# Wi-Fi 驱动选择与板级配置

## 驱动概览

RT-Smart 当前可同时构建多种 Wi-Fi 驱动。应用统一使用 RT-Thread WLAN、NetMgmt、
lwIP 和 `wifi` 命令，不能根据旧版固定的 `wlan0` 名称判断实际芯片。

| 驱动 | 传输 | 注册型号 | 主要配置 |
| :-- | :-- | :-- | :-- |
| Realtek RTL8189FTV | SDIO | `rtl8189ftv` | `RT_USING_REALTEK` + `REALTEK_SDIO_RTL8189FTV` |
| Realtek RTL8733BS | SDIO | `rtl8733bs` | `RT_USING_REALTEK` + `REALTEK_SDIO_RTL8733BS` |
| Broadcom brcmfmac | SDIO | `BCM43430A1` | `RT_USING_BRCMFMAC` |
| CYW43xx（旧版） | SDIO | `cyw43438` | `RT_USING_CYW43XX` |
| RW007 | SPI Mode 0 | `rw007` | `RT_USING_RW007` |
| AIC8800 系列（含 DC/DW/DL） | USB、SDIO | 具体芯片型号 | `RT_USING_AIC8800_WIFI` |
| ESP-Hosted-FG/NG | SPI Full-Duplex、SDIO | `esp-hosted-fg/ng` | `RT_USING_ESP_HOSTED_WIFI` |
| ESP-Hosted-MCU | SPI Full/Half-Duplex | `esp-hosted-mcu` | `RT_USING_ESP_HOSTED_MCU` |

AIC8800 和 ESP-Hosted 的 firmware、协议及安全能力差异较多，分别见
[AIC8800 Wi-Fi 驱动使用指南](how_to_use_aic8800.md) 和
[ESP-Hosted Wi-Fi 协处理器使用指南](how_to_use_esp_hosted.md)。

## SDIO 公共板级配置

Realtek、brcmfmac、CYW43xx、AIC8800 SDIO 和 ESP-Hosted SDIO 共用
`SDIO Wi-Fi Board Bus` 配置。选择实际连接的 host，并按原理图设置 REG_ON/Reset：

```text
BSP_WIFI_SDIO_HOST_0=y              # 或 BSP_WIFI_SDIO_HOST_1
BSP_WIFI_SDIO_REG_ON_PIN=<gpio>     # -1 表示使用板级固定接线
BSP_WIFI_SDIO_RESET_ACTIVE_LOW=y
BSP_WIFI_SDIO_RESET_PULSE_MS=200
BSP_WIFI_SDIO_POWER_UP_DELAY_MS=50
```

所选 host 必须启用对应的 `RT_USING_SDIO0` 或 `RT_USING_SDIO1`。公共板级代码只在
探测前复位一次插槽，随后各厂商驱动按 SDIO manufacturer/product ID 匹配，因此
不同厂商的 SDIO 驱动可以同时编译。

## Realtek RTL8189FTV/RTL8733BS

启用 `RT_USING_REALTEK` 后，Realtek module 必须二选一：

```text
REALTEK_SDIO_RTL8189FTV=y           # SDIO ID 024c:f179
# REALTEK_SDIO_RTL8733BS=y          # SDIO ID 024c:b733
```

这两个选项决定编译进镜像的厂商模块，不能同时启用。选错模块时，SDIO host 可能
识别到卡，但不会注册 WLAN。需要厂商交互命令或详细日志时，分别启用
`REALTEK_INTERACTIVE_CMD`、`REALTEK_ENABLE_DEBUG`；正常发布固件建议关闭。

## Broadcom brcmfmac

新配置推荐启用 RT-Smart 原生的 brcmfmac 移植：

```text
RT_USING_BRCMFMAC=y
BRCMFMAC_COUNTRY_CODE="CN"
BRCMFMAC_COUNTRY_REVISION=0
BRCMFMAC_BCM43430A1_NVRAM="nvram.txt"
```

当前随 SDK 提供并验证的目标为 SDIO ID `02d0:a9a6`、芯片版本 A1，注册型号为
`BCM43430A1`。驱动支持 STA、SoftAP 以及单信道 STA + SoftAP 并发，并通过 WLAN
offload 接入 RT-Thread WLAN 和 lwIP。并发模式下，STA 连接期间 SoftAP 可能短暂
停止，连接完成后在 STA 所在信道恢复。

构建系统会把 `fw_bcm43438a1.bin`、`nvram.txt` 和 `nvram_ap6212.txt` 安装到镜像的
`/bin/firmware/brcmfmac`。默认 `nvram.txt` 是 K230 CanMV Linux SDK 使用的
K016-CW43 板级校准；只有模组和射频设计与 AP6212A V1.0.2 校准匹配时，才将
`BRCMFMAC_BCM43430A1_NVRAM` 改为 `nvram_ap6212.txt`。NVRAM 是板级射频校准数据，
不能只根据 SDIO ID 或芯片型号互换。

驱动映射表还包含其他 Broadcom/Cypress 芯片，但 SDK 当前没有随附这些目标的
firmware、NVRAM 和可选 CLM blob。适配新模组时，必须提供 Linux brcmfmac 对应的
文件并把它们安装到 `BRCMFMAC_FIRMWARE_PATH` 指定的目录。

旧版 `RT_USING_CYW43XX` 仍可用于现有板级配置，但它与 `RT_USING_BRCMFMAC`
互斥，因为两者会匹配相同的 Broadcom SDIO ID。两个端口都只提供 Wi-Fi，不注册
Bluetooth HCI device。

## RW007

RW007 依赖 RT-Thread SPI。启用 `RT_USING_RW007` 后，按板级接线配置：

```text
RW007_SPI_BUS_NAME="spi0"
RW007_SPI_MAX_HZ=25000000
RW007_RST_PIN=20
RW007_CS_PIN=63
RW007_INT_BUSY_PIN=62
```

驱动使用 SPI Mode 0、8-bit、单数据线，并把从设备注册为 `wspi`。以上 GPIO 和
25 MHz 是默认值，不代表所有开发板接线；初始化失败时先降低频率，并核对 Reset、
CS、INT/BUSY 和 FPIOA。

## 默认配置

- `k230_canmv_defconfig` 启用 brcmfmac 和 Realtek；
- 多数带板载 SDIO Wi-Fi 的 CanMV defconfig 启用 Realtek，默认选择 RTL8189FTV；
- `k230_canmv_rtt_evb_defconfig` 启用 RW007；
- `k230_canmv_01studio_defconfig` 已启用 AIC8800 USB/SDIO，
  `k230_canmv_v3p0_defconfig` 已启用 AIC8800 SDIO；DC/DW/DL SDIO 卡使用
  `c8a1:c08d` 和 `c8a1:c18d` 两个 function，详情见其独立指南；
- ESP-Hosted 没有通用接线，通常在自定义 defconfig 中启用。

defconfig 只描述该固件的构建选项。更换同接口模组后仍需核对芯片、SDIO ID、
供电、复位和引脚，不能只根据开发板名称判断驱动。

## 网络栈与网络共享

RT-Smart 当前可在 lwIP 2.1.2 与 2.2.1 之间选择，默认仍为 2.1.2。版本选择、
SAL/netdev 适配和运行确认见 [lwIP 2.2.1 使用指南](how_to_use_lwip.md)。

需要让 SoftAP 客户端通过 STA 或 LAN 上网时，启用 DHCP server 与
`LWIP_USING_NAT`。NAT 编译进固件后由 WLAN 层随 SoftAP 自动启停，配置、状态
命令和功能限制见 [IPv4 NAT 使用指南](how_to_use_nat.md)。

## 设备发现和选择

每块物理射频会注册 STA/AP 管理设备与动态 netdev。执行：

```shell
wifi devices
```

输出中的 model、transport、role 和 netdev 可用于确认实际绑定结果。编号由探测
顺序决定，应用不要写死 `phy0-sta` 或 `wlan0`。

只有一块 Wi-Fi 时通常使用自动选择；存在多块设备时可按传输指定：

```shell
wifi -i sdio scan
wifi -i spi join <ssid> <password>
wifi -i usb status
```

传输选择不能区分同一 SDIO 或 SPI 类型上的不同厂商设备。需要精确指定时，使用
`wifi devices` 输出的管理设备或 netdev 名称。

## 故障排查

1. 没有任何 WLAN：确认 `RT_USING_WIFI`、host controller、供电和板级复位配置。
1. SDIO 能枚举但没有 WLAN：核对 manufacturer/product ID 和实际编译的厂商驱动；
   Realtek 还要确认 RTL8189FTV/RTL8733BS 选择。
1. AIC8800DC/DW/DL 只枚举 `c8a1:c08d` 或 `c8a1:c18d` 中的一个 function：检查
   供电、复位和 host 配置；该卡需要两个 function 同时工作。
1. brcmfmac 报告 firmware 或 NVRAM 不存在：确认镜像中存在
   `/bin/firmware/brcmfmac`，并核对 `BRCMFMAC_BCM43430A1_NVRAM` 与实际板卡。
1. RW007 没有打印版本：核对 `RW007_SPI_BUS_NAME`、SPI Mode 0、频率和三个 GPIO。
1. WLAN 已注册但连接失败：先用 `wifi devices` 确认 model，再按该厂商 firmware
   支持范围检查安全模式、国家码和信道。
1. 同时编译多驱动后选错设备：用 `wifi -i <管理设备或 netdev>` 精确指定，且不要
   依赖动态编号在不同启动之间保持不变。
