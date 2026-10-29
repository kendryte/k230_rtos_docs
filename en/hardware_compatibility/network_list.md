# Supported Network Devices

## Wi-Fi

| Model or Solution | Transport | Main Features |
| :-- | :-- | :-- |
| RTL8189FTV | SDIO | 2.4 GHz Wi-Fi 4, STA/SoftAP; model name `rtl8189ftv` |
| RTL8733BS | SDIO | Wi-Fi 4 with 5 GHz support, STA/SoftAP; model name `rtl8733bs` |
| Broadcom BCM43430A1 | SDIO | 2.4 GHz Wi-Fi 4, STA/SoftAP and single-channel concurrency; brcmfmac model name `BCM43430A1` |
| RW007 | SPI Mode 0 | STA/SoftAP; model name `rw007` |
| AIC8800/AIC8801 | USB, SDIO | Wi-Fi 6 series; specific frequency bands depend on the chip and firmware |
| AIC8800D80/D40/D80X2/DC/DW/DL | USB; D80, DC/DW/DL support SDIO | DC/DW/DL SDIO use `c8a1:c08d` and `c8a1:c18d` dual function; USB composite devices optionally support BLE HCI |
| ESP-Hosted-FG/NG | SPI Full-Duplex, SDIO | ESP serves as a Wi-Fi coprocessor and connects to WLAN offload |
| ESP-Hosted-MCU | SPI Full-Duplex, Dual/Quad SPI Half-Duplex | RPC Wi-Fi control, optional BLE HCI |

```{note}
The chip families in the table do not mean that all commercially available modules have the same capabilities. AIC8800D40 and D80 may use
the same USB ID; ESP-Hosted must select the FG, NG, or MCU protocol consistent with the slave firmware.
```

The WLAN driver registers STA/AP devices by physical radio. Management devices are typically `phyN-sta` and `phyN-ap`,
netdevs are typically `wlanN` and `wlanNap`, and the offload control device is `/dev/wlanctlN`. Numbers are assigned by
probe order, and applications should query the actual names through `wifi devices` or NetMgmt.

When multiple Wi-Fi devices are present, selection can be based on USB, SDIO, or SPI transport. RT-Smart shell examples:

```shell
wifi devices
wifi -i sdio scan
wifi -i usb join <ssid> <password>
```

See all drivers, common SDIO board-level configuration, and RW007 wiring in the
[Wi-Fi Driver Selection and Board-Level Configuration](../advanced_development_guide/how_to_use_wifi.md). For firmware details on
AIC8800 and ESP-Hosted, see
[AIC8800 Wi-Fi Driver User Guide](../advanced_development_guide/how_to_use_aic8800.md) and
[ESP-Hosted Wi-Fi Coprocessor User Guide](../advanced_development_guide/how_to_use_esp_hosted.md), respectively.

## Low-Power Bluetooth (BLE)

| Controller Backend | Transport | Main Features |
| :-- | :-- | :-- |
| AIC8800 series composite devices | USB | Registers a dynamic `/dev/hciN` H:4 device; SCO audio is not implemented |
| ESP-Hosted-MCU | SPI Full/Half-Duplex | Optional HCI channel; starts and stops the controller through FeatureControl RPC |

The RT-Smart HCI framework only provides controller transport, while GAP, GATT, L2CAP, and SMP are provided by
host stacks such as NimBLE. Neither the current Broadcom brcmfmac nor the legacy CYW43xx port provides
Bluetooth, and Realtek, RW007, AIC SDIO, and ESP-Hosted-FG/NG do not provide an HCI backend. For configuration, see
[Bluetooth HCI and NimBLE User Guide](../advanced_development_guide/how_to_use_bluetooth.md).

## USB Ethernet Adapters

| Model | Main Features |
| :-- | :-- |
| RTL8152 | USB 2.0 100 Mbps NIC (including compatible chips) |
| CH397 | USB 2.0 100 Mbps NIC (ECM generic driver) |

USB Ethernet devices are uniformly managed as LAN devices, and an available name from `eth0` to `eth9` is dynamically
assigned upon connection. Applications should use the `RT_NET_DEV_LAN` or NetMgmt device query interface and should not
select an interface based on the chip model or a fixed device name.

For compilation options and runtime verification methods for CherryUSB Host, RTL8152, and CH397 ECM/NCM, see the
[USB Host NIC Configuration Guide](../advanced_development_guide/how_to_use_usb_net.md).

## 4G LTE USB Modules

| Model | Main Features |
| :-- | :-- |
| Quectel EC200 series | Cat.1 LTE module (compatible series), ECM generic driver |
| China Mobile ML307 | Cat.1 LTE module (compatible series), ECM generic driver |

LTE modules also require USB composite mode, SIM, APN, and network registration configuration. For selection of ECM/NCM and optional AT serial port
drivers, see [USB Host NIC Configuration Guide](../advanced_development_guide/how_to_use_usb_net.md).
