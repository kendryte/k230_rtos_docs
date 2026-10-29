# AIC8800 Wi-Fi 驱动使用指南

## 概述

RT-Smart 已集成 AIC8800 系列 WLAN offload 驱动，支持 USB 和 SDIO 两种传输。
驱动负责固件加载、STA/SoftAP 注册和数据收发，并继续使用 RT-Thread WLAN、
lwIP、`wifi` 命令及 NetMgmt 作为上层接口。

支持范围如下：

| 传输 | 芯片系列 | 说明 |
| :-- | :-- | :-- |
| USB | AIC8800/AIC8801、AIC8800D80/D40、AIC8800D80X2、AIC8800DC/DW/DL | 支持固件下载；部分组合设备还可提供 BLE HCI |
| SDIO | AIC8801、AIC8800D80、AIC8800DC/DW/DL | 支持 Wi-Fi；DC/DW/DL 使用 function 1 数据通道和 function 2 控制/消息通道 |

不同模组的频段、带宽和 BLE 能力不同，不能仅根据 “AIC8800” 商品名称判断。
例如 AIC8800D40 与 D80 可能使用相同 USB ID；D40 板卡必须启用
`AIC8800_WIFI_USB_LIMIT_40MHZ`。

## 源码和固件

驱动源码位于：

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/extdrv/aic8800/
```

固件是 manifest 管理的独立子仓库：

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/extdrv/aic8800/firmware/
```

执行 `repo sync` 时应确保该子仓库已经检出。固件有独立的授权条款，分发镜像前
请阅读固件仓库中的 `README.md` 和许可说明。

当前固件同步自 AIC `aic8800d_linux_sdk_V5.0_2026_0123_5f7be68d`，对应 vendor
仓库提交 `df4c783b663eba1956579c681acd5e45f25c671d`。USB D80X2 同时包含 U03
和 U05 revision 文件。vendor SDK 中额外的 D80N、D80X2 SDIO 文件没有打包，
因为当前 RT-Smart SDIO 驱动尚未实现这些 family 所需的 boot 和 calibration
路径。后续同步时应同时更新 firmware 子仓库的 `README.md`，该文件是固件来源的
最终记录。

构建系统会把固件安装到 `/bin/firmware`。只启用一种传输时，所选传输的系列
目录直接安装到该路径；同时启用 USB 和 SDIO 时会保留 `usb/`、`sdio/` 两级
目录，避免同名固件互相覆盖。不要把 USB FMAC 文件替换为同名 SDIO 文件。

### USB 设备 ID

当前驱动支持的 Wi-Fi USB ID 如下：

| 芯片系列 | Boot ID | Runtime ID |
| :-- | :-- | :-- |
| AIC8800/AIC8801 | `a69c:8800` | `a69c:8801` |
| AIC8800D80 | `a69c:8d80` | `a69c:8d81`、`a69c:8d83`、`a69c:8d84`、`a69c:8d85`、`a69c:8d86`、`a69c:8d88`；`368b:8d81`、`368b:8d83`、`368b:8d84`、`368b:8d85`、`368b:8d86`、`368b:8d88` |
| AIC 88M80 | `1111:1111` factory placeholder，退出 MSC 后为 `a69c:8d80` | `a69c:8d81` composite |
| AIC8800D40 | `a69c:8d40` | `a69c:8d41` |
| AIC8800D80X2 | `368b:8d90` | `368b:8d91`、`368b:8d99` |
| AIC8800DC/DW/DL | `a69c:5721` MSC | `a69c:88dc`、`a69c:88dd` |

`1111:1111` 已在 88M80 实机上验证，但它不是 AIC 分配的 USB-IF identity，而是
模组出厂时使用的通用 placeholder。驱动仅在
`AIC8800_WIFI_USB_MODESWITCH_PLACEHOLDER_ID=y` 时认领该 ID 并发送 88M80 private
SCSI mode-switch command；没有使用 88M80 的产品应关闭该选项，避免认领其他使用
相同 placeholder 的 mass-storage 设备。

`a69c:5721` 是 DC family 进入运行模式前的 MSC 标识。当前 vendor 固件不再提供
独立的 `aic8800dc_fc` patch 分支；设备退出 MSC 并重新枚举为 `88dc`/`88dd` 后，
驱动按实际 silicon revision 选择 `aic8800DC` 中的普通版或 H 版文件。

### SDIO 设备 ID

当前驱动支持的 AIC SDIO ID 如下：

| 芯片系列 | function | manufacturer:product | 用途 |
| :-- | :-- | :-- | :-- |
| AIC8801 | 1 | `5449:0145` | Wi-Fi 数据和控制 |
| AIC8800D80 | 1 | `c8a1:0082` | Wi-Fi |
| AIC8800DC/DW/DL | 1 | `c8a1:c08d` | Wi-Fi 数据 |
| AIC8800DC/DW/DL | 2 | `c8a1:c18d` | 固件控制和消息 |

AIC8800DC/DW/DL 必须同时枚举 function 1 和 function 2；驱动只在两者 ID 都匹配时
启动固件初始化。`c8a1:c18d` 是 WLAN transport 所需的消息 function，不会注册
Bluetooth HCI device。SDIO transport 当前均不提供 Bluetooth HCI backend。

DC/DW/DL 驱动会读取 silicon chip ID、sub-ID 和 MCU ID，自动选择普通 U02 或 H
U02 固件。DL 没有单独的设备 ID 或固件文件名，与 DC/DW 共用 `aic8800DC`。
USB 与 SDIO 同时启用时，文件应位于
`/bin/firmware/sdio/aic8800DC`；仅启用 SDIO 时应位于
`/bin/firmware/aic8800DC`。不要手工把普通版和 H 版文件改成同一个文件名。
USB 和 SDIO 均按 vendor 流程执行匹配的 DPD 校准，普通版和 H 版校准失败都会
终止固件初始化；驱动不再提供强制或跳过 DPD 的 Kconfig 选项。

## 配置

先选择目标板级配置，再进入 RT-Smart 配置：

```shell
make <board>_defconfig
make rtsmart-menuconfig
```

启用 `RT_USING_AIC8800_WIFI`，再至少选择一种传输：

- `AIC8800_WIFI_TRANSPORT_USB`：依赖 CherryUSB Host；
- `AIC8800_WIFI_TRANSPORT_SDIO`：依赖 RT-Thread SDIO；
- 两项可以同时启用，每个实际探测到的设备会注册成独立射频。

在 `Firmware Packaging` 中按实际硬件选择固件系列：

| 配置项 | 打包内容 |
| :-- | :-- |
| `AIC8800_WIFI_FIRMWARE_AIC8800` | AIC8800/AIC8801 |
| `AIC8800_WIFI_FIRMWARE_D80` | AIC8800D80/D40 及兼容的 D8x 设备 |
| `AIC8800_WIFI_FIRMWARE_D80X2` | AIC8800D80X2，仅 USB |
| `AIC8800_WIFI_FIRMWARE_DC_DW` | AIC8800DC/DW/DL |

常用配置项如下：

| 配置项 | 作用 |
| :-- | :-- |
| `AIC8800_WIFI_AUTO_START` | 设备挂载后初始化 STA 和 AP 接口，默认开启 |
| `AIC8800_WIFI_FIRMWARE_PATH` | 固件安装根目录，默认 `/bin/firmware` |
| `AIC8800_WIFI_COUNTRY_CODE` | 两字符国家码，默认 `CN` |
| `AIC8800_WIFI_COUNTRY_TX_POWER_LIMIT` | 将 country table 作为固件发射功率硬限制，默认关闭；关闭时 country table 仍限制信道并用于上报 |
| `AIC8800_WIFI_5GHZ` | 发布 5 GHz 信道；2.4 GHz-only 模组应关闭 |
| `AIC8800_WIFI_POWER_SAVE` | 固件 STA 省电，默认关闭；仅在更重视空闲功耗并完成压力测试后开启 |
| `AIC8800_WIFI_USB_LIMIT_40MHZ` | AIC8800D40L USB 模组必须开启 |
| `AIC8800_WIFI_BLE` | USB 组合设备注册 `/dev/hciN`，默认开启 |
| `AIC8800_WIFI_DEBUG_STATS` | 注册 `aic8800_stat` 调试命令，仅建议诊断时开启 |

DC/DW/DL transport 更新后，性能相关默认值如下：

| 配置项 | 默认值 |
| :-- | :-- |
| `AIC8800_WIFI_DATA_RX_URBS` | descriptor DMA 为 4，其他模式为 20 |
| `AIC8800_WIFI_MESSAGE_RX_URBS` | descriptor DMA 为 1，其他模式为 20 |
| `AIC8800_WIFI_DATA_TX_URBS` | 2 |
| `AIC8800_WIFI_USB_TX_AGGREGATION` | 关闭 |
| `AIC8800_WIFI_SDIO_TX_AGGREGATE_WAIT_MS` | 0 ms |

descriptor DMA 只在 non-periodic descriptor chain 的最后一个 descriptor 完成时
产生完成处理。独立 message endpoint 的流量较稀疏，因此默认只保持一个 message
RX URB 持续 armed，避免 command reply 被空闲 chain 延迟。除非正在诊断特定
controller 或 firmware，不建议修改 `AIC8800_WIFI_MESSAGE_RX_URBS`。

firmware station power save 由开启改为关闭，是因为 DC/DW 固件在持续流量下可能
停止处理 best-effort TX queue，并触发 AC1 timer assertion。USB RX 队列深度和
SDIO aggregate wait 也已变化；依赖旧配置的板级 defconfig 应显式固定所需值。
不要仅为提高吞吐量而增大 USB TX URB，CherryUSB DWC2 的 URB/QTD pool 由控制器
上的所有设备和 endpoint 共享。

SDIO 模组还需在 `SDIO Wi-Fi Board Bus` 中选择实际 host，并按板级接线配置
`BSP_WIFI_SDIO_REG_ON_PIN`。驱动使用最高 50 MHz 的四线 SDIO high-speed；未完成
UHS 调谐时不要把该链路强制提高到 100 MHz。

`k230_canmv_01studio_defconfig` 已同时启用 AIC8800 USB 和 SDIO，
`k230_canmv_01studio_emmc_defconfig` 与 `k230_canmv_lckfb_defconfig` 已启用 USB，
`k230_canmv_v3p0_defconfig` 已启用 SDIO host 0。01Studio 的 SDIO Wi-Fi 有效配置
为 host 1、REG_ON GPIO 53。其他板级配置需按硬件自行启用。AIC8800DC 是
2.4 GHz-only 模组，使用该卡时应关闭 `AIC8800_WIFI_5GHZ`。

## 设备命名和选择

每块物理射频会注册一组动态名称：

| 类型 | 名称示例 |
| :-- | :-- |
| WLAN 管理设备 | `phy0-sta`、`phy0-ap` |
| lwIP netdev | `wlan0`、`wlan0ap` |
| offload 控制设备 | `/dev/wlanctl0` |

编号由探测顺序决定，不要在应用中假设 AIC8800 一定是 `wlan0`。使用以下命令
查看型号、总线、角色和动态 netdev：

```shell
wifi devices
```

有多块 Wi-Fi 时可按总线选择，也可传入管理设备或 netdev 名：

```shell
wifi -i usb scan
wifi -i sdio join <ssid> <password>
wifi -i wlan0 status
```

原生 RT-Smart 应用应使用 NetMgmt 选择物理传输，再调用现有 STA/AP 接口：

```c
netmgmt_wlan_select_device(NETMGMT_WLAN_DEVICE_SDIO,
                           RT_NET_DEV_WLAN_STA);
netmgmt_wlan_sta_connect_with_ssid("my-ap", "12345678");
```

选择与后续操作是两个独立调用；多个线程共享 NetMgmt 时，应用需要串行化
“选择并操作”的组合。

## STA 和 SoftAP

基本验证流程：

```shell
wifi devices
wifi -i auto scan
wifi -i auto join <ssid> <password>
wifi -i auto status
ifconfig
ping <gateway-address>
```

STA 支持开放、WEP、WPA/WPA2 Personal 以及受限的 WPA3-SAE Personal 路径。
WPA3 当前使用 SAE group 19、hunting-and-pecking 和 BIP-CMAC-128；SAE H2E、
Enterprise/802.1X 等模式需要完整的外部 supplicant。

SoftAP 支持开放网络和 WPA2-PSK/CCMP：

```shell
wifi -i auto ap <ssid>
wifi -i auto ap <ssid> <password> 2g 6
wifi -i auto ap <ssid> <password> 5g 149
wifi -i auto list_sta
wifi -i auto ap_stop
```

AIC 固件只有一个信道上下文。STA 与 AP 并发时必须使用相同主信道；请求不同
主信道会返回忙，而不会静默中断另一个接口。SoftAP 不支持 WPA3、Enterprise、
WPS、DFS/CAC 或动态 VLAN。

## 带宽和吞吐验证

SDIO host 日志中的 `clock=50000 kHz` 表示 K230 与模组之间的 SDIO 总线时钟，
与 20/40/80 MHz Wi-Fi 射频信道宽度不是同一个参数。判断 80 MHz 支持和实际连接
带宽时应区分以下两条日志：

- `ME capabilities ... max-bw=80 MHz`：芯片/固件向主机报告的最大能力；
- `association channel ... width=80 MHz`：本次 STA 关联实际采用的射频带宽。

`wifi status` 可查看当前链路信息。已启用 `AIC8800_WIFI_DEBUG_STATS` 时，还可执行
`aic8800_stat` 查看 USB、SDIO、WLAN、RX reorder 和 firmware rate-control 统计。
该选项会增加逐帧统计和 ICMP checksum 诊断，性能基准镜像通常应保持关闭。

冷启动后的短测试不能代表稳定吞吐。若第一轮结果偏低、等待约 20 秒后恢复，先用
30～60 秒测试并按秒记录吞吐、重传和 RSSI，再比较 USB/SDIO transport 或固件
版本。连接已建立且吞吐随后稳定，本身不能证明 DPD 校准失败；真正的 DPD 失败会
在固件初始化阶段打印错误并阻止 WLAN 注册。

## BLE

USB 传输启用 `AIC8800_WIFI_BLE` 后，Bluetooth 接口注册为动态 `/dev/hciN`。
它提供 H:4 控制器传输，不包含 GAP/GATT 协议栈；RT-Smart 应用可使用 NimBLE，
CanMV 固件可启用其 MicroPython NimBLE 模块。SCO 音频未实现。

完整的 host/controller 配置和限制见
[Bluetooth HCI 与 NimBLE 使用指南](how_to_use_bluetooth.md)。

## 故障排查

1. `wifi devices` 没有 AIC 设备：先检查 USB/SDIO host、供电和对应传输配置。
1. 日志提示固件文件不存在：确认 firmware 子仓库已同步，并检查镜像中的
   `/bin/firmware` 布局。
1. 日志显示 function 1/2 为 `c8a1:c08d`、`c8a1:c18d`，但随后提示
   `no driver for SDIO function`：当前镜像仍是旧版驱动，需重新构建并更新 RT-Smart
   系统镜像。
1. DC/DW/DL 只枚举出一个 function：检查模组供电、复位、SDIO 信号和 host 配置；
   两个 function 都存在时驱动才会初始化。
1. DC/DW/DL patch 或校准固件加载失败：按启用的 transport 检查
   `/bin/firmware/sdio/aic8800DC` 或 `/bin/firmware/aic8800DC`；若日志明确显示
   DPD calibration 失败，还应检查供电、复位时序和日志中的 silicon revision。
1. D40 可以连接但速率异常：确认 `AIC8800_WIFI_USB_LIMIT_40MHZ=y`。
1. SDIO 出现 CRC 错误：先恢复 50 MHz、四线 high-speed 配置并检查走线。
1. USB 压力测试异常：开启 `AIC8800_WIFI_DEBUG_STATS` 后查看
   `aic8800_stat`；不要先盲目增大 URB 和队列深度。
1. 只有刚关联后的首轮吞吐偏低：延长测试并分段记录结果；若 20 秒后恢复正常，
   应先排查固件速率控制和 AP 协商过程，而不是修改 DPD 或 SDIO host clock。

底层 offload 控制设备的诊断方式见
[WLAN Offload 控制示例](../app_develop_guide/peripheral/wlan_offload.md)。
