# ESP-Hosted Wi-Fi Coprocessor User Guide

## Overview

RT-Smart provides two mutually independent ESP-Hosted drivers. Before selecting one, you must confirm the firmware protocol flashed onto the ESP slave; similar names do not indicate protocol compatibility.

| RT-Smart Driver | Kconfig | ESP Firmware | Transport | Features |
| :-- | :-- | :-- | :-- | :-- |
| ESP-Hosted-FG/NG | `RT_USING_ESP_HOSTED_WIFI` | ESP-Hosted-FG or ESP-Hosted-NG | SPI Full-Duplex, SDIO | WLAN offload integration; FG handles connections in the firmware, while NG supports host authentication |
| ESP-Hosted-MCU | `RT_USING_ESP_HOSTED_MCU` | ESP-Hosted-MCU | SPI Full-Duplex, SPI Half-Duplex | RPC Wi-Fi control, with optional BLE HCI and full RPC |

Both drivers register STA/SoftAP with RT-Thread WLAN and lwIP, so the upper layer continues to use
`wifi`, NetMgmt, or CanMV `network.WLAN`. The protocol, transport, and slave configuration must be fully consistent with the host-side
Kconfig.

## Source Code Location

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/extdrv/esp_hosted/      # FG/NG
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/extdrv/esp_hosted_mcu/  # MCU
```

## Driver Selection

### ESP-Hosted-FG

FG delegates scanning, connection, and SoftAP management to the ESP firmware through RPC. It is suitable for scenarios where WPA management is intended to be performed by the coprocessor. An optional `/dev/wlanctlN` can be used for capability queries and diagnostics, but FG does not expose external supplicant capabilities.

### ESP-Hosted-NG

NG provides the host with authentication, association, EAPOL, key, and management frame interfaces. RT-Smart's embedded path supports common WPA/WPA2 STA and open/WPA2 SoftAP configurations; more complete security modes can be accessed through a userspace supplicant via `/dev/wlanctlN`.

### ESP-Hosted-MCU

The MCU driver uses the generated protobuf-c schema and RPC. In addition to STA/SoftAP, it can register a remote Bluetooth controller as `/dev/hciN` and provide typed RPC, OTA, configuration, and event interfaces to native applications. The current MCU driver implements only the SPI backend and does not support SDIO.

## General Hardware Requirements

All connections must share a common ground and satisfy the same I/O voltage. K230 GPIO numbers are not the development board header pin numbers;
check the schematic and FPIOA capabilities before wiring.

SPI Full-Duplex uses the following signals:

| K230 | ESP | Direction |
| :-- | :-- | :-- |
| CLK | SPI CLK | K230 to ESP |
| D0/MOSI | MOSI | K230 to ESP |
| D1/MISO | MISO | ESP to K230 |
| CS | CS | K230 to ESP |
| Handshake | HS | ESP to K230 |
| Data Ready | DR | ESP to K230 |
| Reset | EN/Reset | K230 to ESP |

ESP-Hosted-MCU SPI Half-Duplex does not use Handshake. D0 and D1 are bidirectional data lines; Quad
mode also requires D2 and D3. Half-Duplex can use the DR interrupt, or DR can be configured as `-1` and the
status register polled.

```{warning}
SPI 模式、频率、校验和、总线宽度、HS/DR 有效电平及所有引脚必须与 ESP 从机
固件一致。量产硬件建议连接 Reset；否则主机与从机应同时复位。
```

## Configuring FG/NG

Run:

```shell
make <board>_defconfig
make rtsmart-menuconfig
```

Enable `RT_USING_ESP_HOSTED_WIFI`, and then select:

1. `ESP_HOSTED_WIFI_FG` or `ESP_HOSTED_WIFI_NG`;
1. `ESP_HOSTED_WIFI_TRANSPORT_SPI` or `ESP_HOSTED_WIFI_TRANSPORT_SDIO`;
1. The checksum, SPI/SDIO parameters, and frequency band that match the slave.

SPI uses `spi0`, Mode 3, 5 MHz, and GPIO 14 through 17, Handshake 20,
and Data Ready 21 by default. Reset defaults to `-1`. These are only driver defaults and cannot replace board-level wiring configuration.

SDIO currently supports the common ESP IDs `6666:2222`, `6666:3333`, `0092:6666`, and
`0092:7777`, but only one set of IDs can be configured per driver registration. Select the ID actually advertised by the slave through
`ESP_HOSTED_WIFI_SDIO_MANUFACTURER` and `ESP_HOSTED_WIFI_SDIO_PRODUCT`.

`ESP_HOSTED_WIFI_AUTO_START` is enabled by default. The probe task waits for the firmware boot event in a thread and
does not block RT-Smart initialization when no ESP is connected; after a failure, `/dev/wlanctlN` can still be retained for
manual retry and diagnostics.

## Configuring ESP-Hosted-MCU

Enable `RT_USING_ESP_HOSTED_MCU`, and then select a transport:

- `ESP_HOSTED_TRANSPORT_SPI_FD`: Full-Duplex; HS and DR must be connected, and Mode 0 is unavailable;
- `ESP_HOSTED_TRANSPORT_SPI_HD`: Half-Duplex; select 2-wire or 4-wire, with Modes 0 through 3
  all available.

The current defaults are `spi0`, Mode 3, 5 MHz, CS 14, CLK 15, D0 16, and D1 17;
the HS for Full-Duplex is 20 and the DR is 21; Reset defaults to `-1`. Quad SPI also requires configuring
D2 18 and D3 19. The SPI-HD four-wire master initially starts in two-wire mode and switches to
four-wire mode only after receiving the coprocessor capability packet.

Common runtime configurations:

| Configuration Item | Description |
| :-- | :-- |
| `ESP_HOSTED_CHECKSUM` | Generates and verifies the transport checksum; master and slave must match |
| `ESP_HOSTED_RPC_TIMEOUT_MS` | RPC timeout, 10000 ms by default |
| `ESP_HOSTED_MAX_SCAN_RESULTS` | Maximum number of scan results, 20 by default |
| `ESP_HOSTED_WIFI_MAX_TX_POWER` | Requested value in units of 0.25 dBm, 84 (20 dBm) by default |
| `ESP_HOSTED_BLE` | Registers a dynamic `/dev/hciN` Bluetooth H:4 device |
| `ESP_HOSTED_SPI_HD_STATS` | Registers `esp_spi_hd_stats` for diagnostics only |

The master and slave should use compatible ESP-Hosted-MCU schemas. At startup, the master must receive a new
`Event_ESPInit` before enabling RPC, thereby avoiding treating leftover SPI-HD register state from a previous session as a
valid connection.

## Startup and Verification

First, check whether the startup log contains transport ready, the actual pins, the firmware version, and the negotiated width.
Then run:

```shell
wifi devices
wifi -i spi scan
wifi -i spi join <ssid> <password>
wifi -i spi status
ifconfig
ping <gateway-address>
```

SoftAP verification:

```shell
wifi -i spi ap <ssid> <password>
wifi -i spi list_sta
wifi -i spi ap_stop
```

Enabling only STA and SoftAP does not unconditionally provide network sharing. The firmware must also enable the DHCP server and
`LWIP_USING_NAT`; once these conditions are met, the WLAN layer automatically starts and stops NAT with the SoftAP. For configuration and limitations, see
[IPv4 NAT Usage Guide](how_to_use_nat.md).

After enabling the control device in FG/NG, you can use the
[WLAN Offload Control Example](../app_develop_guide/peripheral/wlan_offload.md) to query the actual
control device name, capabilities, and events.

## BLE and RPC

After the MCU driver enables `ESP_HOSTED_BLE`, it registers `/dev/hciN`. This device provides only the H:4
controller transport; GAP, GATT, L2CAP, and SMP are provided by host stacks such as NimBLE. When the device is opened, the driver initializes and enables the remote controller through the FeatureControl RPC; when it is closed, the driver performs
disabling and deinitialization.

For complete host/controller configuration and limitations, see
[Bluetooth HCI and NimBLE Usage Guide](how_to_use_bluetooth.md).

Native C applications that require the complete RPC can include `esp_hosted_rpc.h`; include `esp_hosted_rpc_schema.h` when generated protobuf-c
types are needed. New code should preferably use
`rt_esp_hosted_rpc_call_message()`, which validates the request and response descriptors. Whether RPC is
available still depends on the ESP chip, ESP-IDF version, and slave compilation options.

## Troubleshooting

1. No transport ready: first check the power, common ground, SPI mode, CS, HS/DR levels, and slave
   firmware personality; do not troubleshoot lwIP first.
1. SPI consistently reads `0xff`: focus on checking D1/MISO, slave power, and whether the firmware is running.
1. Failure after restarting the master alone: connect Reset, or ensure that both ends are reset simultaneously.
1. FG/NG SDIO is not detected: verify the slave's actual manufacturer/product ID and the selected host.
1. SPI-HD starts but there is no RPC: confirm that a new `Event_ESPInit` was received, and verify the schema and checksum.
1. 5 MHz is the connectivity verification frequency, not the performance target; increase the frequency step by step and verify signal
   integrity at each step.
