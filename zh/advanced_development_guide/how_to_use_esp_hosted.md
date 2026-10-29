# ESP-Hosted Wi-Fi 协处理器使用指南

## 概述

RT-Smart 提供两套相互独立的 ESP-Hosted 驱动。选择时必须先确认 ESP 从机烧录的
固件协议，名称相似并不表示协议兼容。

| RT-Smart 驱动 | Kconfig | ESP 固件 | 传输 | 特点 |
| :-- | :-- | :-- | :-- | :-- |
| ESP-Hosted-FG/NG | `RT_USING_ESP_HOSTED_WIFI` | ESP-Hosted-FG 或 ESP-Hosted-NG | SPI Full-Duplex、SDIO | 接入 WLAN offload；FG 在固件处理连接，NG 支持主机认证 |
| ESP-Hosted-MCU | `RT_USING_ESP_HOSTED_MCU` | ESP-Hosted-MCU | SPI Full-Duplex、SPI Half-Duplex | RPC Wi-Fi 控制，可选 BLE HCI 和完整 RPC |

两套驱动都向 RT-Thread WLAN 和 lwIP 注册 STA/SoftAP，因此上层继续使用
`wifi`、NetMgmt 或 CanMV `network.WLAN`。协议、传输和从机配置必须与主机端
Kconfig 完全一致。

## 源码位置

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/extdrv/esp_hosted/      # FG/NG
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/extdrv/esp_hosted_mcu/  # MCU
```

## 选择驱动

### ESP-Hosted-FG

FG 通过 RPC 将扫描、连接和 SoftAP 管理交给 ESP 固件。它适合希望由协处理器
完成 WPA 管理的场景。可选 `/dev/wlanctlN` 用于能力查询和诊断，但 FG 不发布
外部 supplicant 能力。

### ESP-Hosted-NG

NG 向主机提供认证、关联、EAPOL、密钥和管理帧接口。RT-Smart 的嵌入式路径可
完成常见 WPA/WPA2 STA 和开放/WPA2 SoftAP；更完整的安全模式可通过
`/dev/wlanctlN` 接入用户态 supplicant。

### ESP-Hosted-MCU

MCU 驱动使用生成的 protobuf-c schema 和 RPC。除 STA/SoftAP 外，还可把远端
Bluetooth controller 注册为 `/dev/hciN`，并向原生应用提供 typed RPC、OTA、
配置和事件接口。当前 MCU 驱动只实现 SPI 后端，不支持 SDIO。

## 通用硬件要求

所有连接都必须共地并满足相同 I/O 电压。K230 GPIO 编号不是开发板排针编号，
接线前应核对原理图和 FPIOA 能力。

SPI Full-Duplex 使用以下信号：

| K230 | ESP | 方向 |
| :-- | :-- | :-- |
| CLK | SPI CLK | K230 到 ESP |
| D0/MOSI | MOSI | K230 到 ESP |
| D1/MISO | MISO | ESP 到 K230 |
| CS | CS | K230 到 ESP |
| Handshake | HS | ESP 到 K230 |
| Data Ready | DR | ESP 到 K230 |
| Reset | EN/Reset | K230 到 ESP |

ESP-Hosted-MCU SPI Half-Duplex 不使用 Handshake。D0、D1 为双向数据线；Quad
模式还需要 D2、D3。Half-Duplex 可使用 DR 中断，也可把 DR 配置为 `-1` 后
轮询状态寄存器。

```{warning}
SPI 模式、频率、校验和、总线宽度、HS/DR 有效电平及所有引脚必须与 ESP 从机
固件一致。量产硬件建议连接 Reset；否则主机与从机应同时复位。
```

## 配置 FG/NG

执行：

```shell
make <board>_defconfig
make rtsmart-menuconfig
```

启用 `RT_USING_ESP_HOSTED_WIFI`，然后选择：

1. `ESP_HOSTED_WIFI_FG` 或 `ESP_HOSTED_WIFI_NG`；
1. `ESP_HOSTED_WIFI_TRANSPORT_SPI` 或 `ESP_HOSTED_WIFI_TRANSPORT_SDIO`；
1. 与从机一致的校验和、SPI/SDIO 参数和频段。

SPI 默认使用 `spi0`、Mode 3、5 MHz，以及 GPIO 14 到 17、Handshake 20、
Data Ready 21。Reset 默认 `-1`。这些只是驱动默认值，不能代替板级接线配置。

SDIO 当前支持 ESP 常用 ID `6666:2222`、`6666:3333`、`0092:6666` 和
`0092:7777`，但一次驱动注册只能配置一组 ID。通过
`ESP_HOSTED_WIFI_SDIO_MANUFACTURER` 和 `ESP_HOSTED_WIFI_SDIO_PRODUCT` 选择从机
实际发布的 ID。

`ESP_HOSTED_WIFI_AUTO_START` 默认开启。探测工作在线程中等待固件 boot event，
没有连接 ESP 时不会阻塞 RT-Smart 初始化；失败后 `/dev/wlanctlN` 仍可保留用于
手动重试和诊断。

## 配置 ESP-Hosted-MCU

启用 `RT_USING_ESP_HOSTED_MCU`，再选择一种传输：

- `ESP_HOSTED_TRANSPORT_SPI_FD`：Full-Duplex，必须连接 HS 和 DR，Mode 0 不可用；
- `ESP_HOSTED_TRANSPORT_SPI_HD`：Half-Duplex，选择 2 线或 4 线，Mode 0 到 3
  均可用。

当前默认值是 `spi0`、Mode 3、5 MHz、CS 14、CLK 15、D0 16、D1 17；
Full-Duplex 的 HS 为 20、DR 为 21；Reset 默认为 `-1`。Quad SPI 还需配置
D2 18 和 D3 19。SPI-HD 四线主机会先按两线启动，收到协处理器能力包后才切换
到四线。

常用运行配置：

| 配置项 | 说明 |
| :-- | :-- |
| `ESP_HOSTED_CHECKSUM` | 生成并验证 transport checksum，主从必须一致 |
| `ESP_HOSTED_RPC_TIMEOUT_MS` | RPC 超时时间，默认 10000 ms |
| `ESP_HOSTED_MAX_SCAN_RESULTS` | 扫描结果上限，默认 20 |
| `ESP_HOSTED_WIFI_MAX_TX_POWER` | 0.25 dBm 单位的请求值，默认 84（20 dBm） |
| `ESP_HOSTED_BLE` | 注册动态 `/dev/hciN` Bluetooth H:4 设备 |
| `ESP_HOSTED_SPI_HD_STATS` | 注册 `esp_spi_hd_stats`，仅用于诊断 |

主从应使用兼容的 ESP-Hosted-MCU schema。启动时主机必须收到新的
`Event_ESPInit` 才启用 RPC，从而避免把上次会话遗留的 SPI-HD 寄存器状态当成
有效连接。

## 启动和验证

先检查启动日志中是否出现 transport ready、实际引脚、固件版本和协商宽度。
然后执行：

```shell
wifi devices
wifi -i spi scan
wifi -i spi join <ssid> <password>
wifi -i spi status
ifconfig
ping <gateway-address>
```

SoftAP 验证：

```shell
wifi -i spi ap <ssid> <password>
wifi -i spi list_sta
wifi -i spi ap_stop
```

仅启用 STA 与 SoftAP 不会无条件提供网络共享。固件还需启用 DHCP server 和
`LWIP_USING_NAT`；满足配置后，WLAN 层会随 SoftAP 自动启停 NAT。配置和限制见
[IPv4 NAT 使用指南](how_to_use_nat.md)。

FG/NG 启用控制设备后，可使用
[WLAN Offload 控制示例](../app_develop_guide/peripheral/wlan_offload.md) 查询实际
控制设备名、能力和事件。

## BLE 和 RPC

MCU 驱动启用 `ESP_HOSTED_BLE` 后会注册 `/dev/hciN`。该设备只提供 H:4
controller transport；GAP、GATT、L2CAP 和 SMP 由 NimBLE 等 host stack 提供。
打开设备时驱动通过 FeatureControl RPC 初始化并启用远端控制器，关闭时执行
禁用和反初始化。

完整的 host/controller 配置和限制见
[Bluetooth HCI 与 NimBLE 使用指南](how_to_use_bluetooth.md)。

原生 C 应用需要完整 RPC 时，可包含 `esp_hosted_rpc.h`；需要生成的 protobuf-c
类型时包含 `esp_hosted_rpc_schema.h`。新代码优先使用
`rt_esp_hosted_rpc_call_message()`，它会验证请求和响应 descriptor。RPC 是否
可用仍取决于 ESP 芯片、ESP-IDF 版本和从机编译选项。

## 故障排查

1. 没有 transport ready：先查电源、共地、SPI mode、CS、HS/DR 电平和从机
   firmware personality，不要先排查 lwIP。
1. SPI 一直读到 `0xff`：重点检查 D1/MISO、从机供电和固件是否已运行。
1. 主机单独重启后失败：连接 Reset，或确保两端同时复位。
1. FG/NG SDIO 不探测：核对从机实际 manufacturer/product ID 和所选 host。
1. SPI-HD 启动但没有 RPC：确认收到新 `Event_ESPInit`，并核对 schema 与 checksum。
1. 5 MHz 是连通性验证频率，不是性能目标；逐级提高频率并在每一级验证信号
   完整性。
