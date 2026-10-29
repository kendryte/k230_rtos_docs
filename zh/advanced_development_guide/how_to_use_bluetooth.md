# Bluetooth HCI 与 NimBLE 使用指南

## 架构

RT-Smart 的 `RT_USING_BT_HCI` 提供传输无关的 Bluetooth HCI device framework。
controller 驱动注册动态 `/dev/hciN` 字符设备，数据采用 H:4 framing；GAP、GATT、
L2CAP 和 SMP 不在内核 HCI 层实现，应由 NimBLE 等成熟 host stack 提供。

当前 controller backend：

| 后端 | 传输 | 配置 | 说明 |
| :-- | :-- | :-- | :-- |
| AIC8800 系列组合设备 | USB | `AIC8800_WIFI_BLE` | USB Bluetooth interface；SCO 音频未实现 |
| ESP-Hosted-MCU | SPI Full/Half-Duplex | `ESP_HOSTED_BLE` | HCI 复用 ESP transport，启停使用 FeatureControl RPC |

Realtek RTL8189FTV/RTL8733BS、Broadcom brcmfmac、旧版 CYW43xx、RW007、
AIC8800 SDIO 以及 ESP-Hosted-FG/NG 不会注册 HCI device。当前集成面向 BLE，
不支持 Bluetooth Classic 或蓝牙音频。

## RT-Smart 配置

`AIC8800_WIFI_BLE` 与 `ESP_HOSTED_BLE` 都会自动选择 `RT_USING_BT_HCI`。典型配置：

```text
# AIC8800 USB
RT_USING_AIC8800_WIFI=y
AIC8800_WIFI_TRANSPORT_USB=y
AIC8800_WIFI_BLE=y

# 或 ESP-Hosted-MCU
RT_USING_ESP_HOSTED_MCU=y
ESP_HOSTED_BLE=y
```

AIC8800 BLE 只适用于 USB transport。AIC8800DC 必须先完成 Bluetooth patch。
ESP-Hosted-MCU 的 ESP firmware 必须启用 HCI，并与主机的 protocol、SPI mode、
bus width 和 checksum 配置一致。

controller 注册时自动使用下一个可用名称，例如 `/dev/hci0`、`/dev/hci1`。编号由
探测顺序决定，应用不得假设某个型号始终对应 `hci0`。

## HCI device 边界

HCI device 是非阻塞 H:4 packet stream：

- 写入包含一个完整 H:4 command 或 ACL packet；
- 读取返回 controller event 或 ACL 的 H:4 byte stream，一次 `read()` 可能只返回
  packet 的一部分，host stack 负责重组；
- framework 校验接收 packet，并以完整 packet 为单位写入 ring buffer；空间不足时
  丢弃整个 packet，不把半个 packet 写入队列；
- 同一个 controller 应只由一个 host stack 持有。

HCI 层用于衔接 host stack，不建议应用直接实现 GAP/GATT 或私有解析。原生应用可
使用 `drivers/bt_hci.h` 中的注册接口适配新的 controller；用户态 BLE 应链接
NimBLE。

## 原生 RT-Smart NimBLE

NimBLE 源码是 manifest 管理的独立子仓库，RT-Smart 用户态移植和示例位于：

```text
src/rtsmart/libs/3rd-party/nimble/
src/rtsmart/examples/3rd-party/nimble/ble_peripheral/
```

启用 host stack 和示例：

```text
RTSMART_3RD_PARTY_ENABLE_NIMBLE=y
RTSMART_3RD_PARTY_ENABLE_NIMBLE_SAMPLES=y
```

第一项同时选择 Mbed TLS，并生成 `libnimble.a`；第二项生成
`ble_peripheral.elf`。示例自动扫描 `/dev/hci0` 到 `/dev/hci63`，也可明确指定：

```shell
ble_peripheral.elf /dev/hci1
```

使用手机 BLE 工具扫描 `K230-NimBLE`。示例注册 service
`6e400001-b5a3-f393-e0a9-e50e24dcca9e`，其中可读写 characteristic 为
`6e400002-b5a3-f393-e0a9-e50e24dcca9e`。

原生应用如需固定 controller，应在 `nimble_port_init()` 前调用
`rtsmart_nimble_hci_set_device("/dev/hciN")`；传入 `NULL` 恢复自动选择。初始化后
可通过 `rtsmart_nimble_hci_get_device()` 查询实际路径。

## CanMV NimBLE

CanMV 在顶层额外启用：

```text
ENABLE_BLUETOOTH=y
```

构建后，MicroPython `bluetooth.BLE()` 使用 NimBLE，并自动打开第一个可用的
`/dev/hciN`。当前 CanMV 端口启用 central、peripheral、GATT client/server 和
L2CAP；实际功能还受 controller 及其 firmware 约束。

```python
import bluetooth

ble = bluetooth.BLE()
ble.active(True)
print(ble.config("mac"))
ble.gap_scan(5000, 30000, 30000, True)
```

使用完成后执行 `ble.active(False)`，让 NimBLE 关闭 HCI device。ESP-Hosted-MCU
会随 device close 停用远端 controller，之后仍可重新打开。

## 验证与排错

1. 启动后没有 `/dev/hciN`：检查 controller backend、物理 transport 和对应 BLE
   Kconfig；仅启用 `RT_USING_BT_HCI` 不会凭空创建 controller。
1. `ble_peripheral.elf` 未生成：确认同时启用 NimBLE library 和 sample 两个配置项，
   并确认 manifest 已检出 `libs/3rd-party/nimble/nimble` 子仓库。
1. CanMV `import bluetooth` 失败：确认 `ENABLE_BLUETOOTH=y`。
1. `bluetooth.BLE().active(True)` 失败：确认至少一个 HCI device 已注册且未被其他
   进程占用。
1. AIC USB WLAN 正常但没有 HCI：检查 USB 组合接口、设备 ID、BLE 配置和型号
   firmware/patch；AIC SDIO 不提供此 HCI backend。
1. ESP HCI 没有注册：确认使用 ESP-Hosted-MCU firmware，且协处理器发布 BLE
   capability；FG/NG personality 不适用于当前 HCI backend。
1. 多个 controller 时使用了错误设备：CanMV 当前自动打开第一个 `/dev/hciN`，
   固件中只保留目标 backend，或在原生应用中明确选择 device。

AIC 和 ESP 的 transport 细节分别见 [AIC8800 Wi-Fi 驱动使用指南](how_to_use_aic8800.md)
与 [ESP-Hosted Wi-Fi 协处理器使用指南](how_to_use_esp_hosted.md)。
