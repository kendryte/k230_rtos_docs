# 网络设备支持列表

## Wi-Fi

| 型号或方案 | 传输 | 主要特性 |
| :-- | :-- | :-- |
| RTL8189FTV | SDIO | 2.4 GHz Wi-Fi 4，STA/SoftAP；型号名 `rtl8189ftv` |
| RTL8733BS | SDIO | 支持 5 GHz 的 Wi-Fi 4，STA/SoftAP；型号名 `rtl8733bs` |
| Broadcom BCM43430A1 | SDIO | 2.4 GHz Wi-Fi 4，STA/SoftAP 及单信道并发；brcmfmac 型号名 `BCM43430A1` |
| RW007 | SPI Mode 0 | STA/SoftAP；型号名 `rw007` |
| AIC8800/AIC8801 | USB、SDIO | Wi-Fi 6 系列；具体频段取决于芯片和固件 |
| AIC8800D80/D40/D80X2/DC/DW/DL | USB；D80、DC/DW/DL 支持 SDIO | DC/DW/DL SDIO 使用 `c8a1:c08d` 和 `c8a1:c18d` 双 function；USB 组合设备可选 BLE HCI |
| ESP-Hosted-FG/NG | SPI Full-Duplex、SDIO | ESP 作为 Wi-Fi 协处理器，接入 WLAN offload |
| ESP-Hosted-MCU | SPI Full-Duplex、Dual/Quad SPI Half-Duplex | RPC Wi-Fi 控制，可选 BLE HCI |

```{note}
表中的芯片系列不代表所有市售模组都具有相同能力。AIC8800D40 和 D80 可能使用
相同 USB ID；ESP-Hosted 必须选择与从机固件一致的 FG、NG 或 MCU 协议。
```

WLAN 驱动按物理射频注册 STA/AP 设备。管理设备通常为 `phyN-sta`、`phyN-ap`，
netdev 通常为 `wlanN`、`wlanNap`，offload 控制设备为 `/dev/wlanctlN`。编号由
探测顺序分配，应用应通过 `wifi devices` 或 NetMgmt 查询实际名称。

多块 Wi-Fi 同时存在时，可按 USB、SDIO 或 SPI 传输选择。RT-Smart shell 示例：

```shell
wifi devices
wifi -i sdio scan
wifi -i usb join <ssid> <password>
```

全部驱动、SDIO 公共板级配置和 RW007 接线见
[Wi-Fi 驱动选择与板级配置](../advanced_development_guide/how_to_use_wifi.md)。AIC8800
和 ESP-Hosted 的 firmware 细节分别见
[AIC8800 Wi-Fi 驱动使用指南](../advanced_development_guide/how_to_use_aic8800.md) 与
[ESP-Hosted Wi-Fi 协处理器使用指南](../advanced_development_guide/how_to_use_esp_hosted.md)。

## 低功耗蓝牙（BLE）

| Controller 后端 | 传输 | 主要特性 |
| :-- | :-- | :-- |
| AIC8800 系列组合设备 | USB | 注册动态 `/dev/hciN` H:4 device；SCO 音频未实现 |
| ESP-Hosted-MCU | SPI Full/Half-Duplex | 可选 HCI channel；通过 FeatureControl RPC 启停 controller |

RT-Smart HCI framework 只提供 controller transport，GAP、GATT、L2CAP 和 SMP 由
NimBLE 等 host stack 提供。当前 Broadcom brcmfmac 和旧版 CYW43xx 端口都不提供
Bluetooth，Realtek、RW007、AIC SDIO 和 ESP-Hosted-FG/NG 也不提供 HCI backend。配置方式见
[Bluetooth HCI 与 NimBLE 使用指南](../advanced_development_guide/how_to_use_bluetooth.md)。

## USB 以太网适配器

| 型号 | 主要特性 |
| :-- | :-- |
| RTL8152 | USB 2.0 百兆网卡（含兼容芯片） |
| CH397 | USB 2.0 百兆网卡（ECM 通用驱动） |

USB 以太网设备统一作为 LAN 管理，插入时动态分配 `eth0` 到 `eth9` 中的可用
名称。应用应使用 `RT_NET_DEV_LAN` 或 NetMgmt 设备查询接口，不应按芯片型号或
固定设备名选择接口。

CherryUSB Host、RTL8152、CH397 ECM/NCM 的编译选项和运行验证方法见
[USB Host 网卡配置指南](../advanced_development_guide/how_to_use_usb_net.md)。

## 4G LTE USB 模组

| 型号 | 主要特性 |
| :-- | :-- |
| 移远 Quectel EC200 系列 | Cat.1 LTE 模组（兼容系列），ECM 通用驱动 |
| 中移 ML307 | Cat.1 LTE 模组（兼容系列），ECM 通用驱动 |

LTE 模组还需完成 USB 组合模式、SIM、APN 和驻网配置；ECM/NCM 及可选 AT 串口
驱动的选择见 [USB Host 网卡配置指南](../advanced_development_guide/how_to_use_usb_net.md)。
