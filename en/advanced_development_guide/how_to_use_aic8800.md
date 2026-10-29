# AIC8800 Wi-Fi Driver Usage Guide

## Overview

RT-Smart has integrated the AIC8800 series WLAN offload driver, supporting both USB and SDIO transports.
The driver handles firmware loading, STA/SoftAP registration, and data transmission and reception, while continuing to use RT-Thread WLAN,
lwIP, the `wifi` command, and NetMgmt as upper-layer interfaces.

The supported range is as follows:

| Transport | Chip Series | Description |
| :-- | :-- | :-- |
| USB | AIC8800/AIC8801, AIC8800D80/D40, AIC8800D80X2, AIC8800DC/DW/DL | Supports firmware downloading; some combination devices can also provide BLE HCI |
| SDIO | AIC8801, AIC8800D80, AIC8800DC/DW/DL | Supports Wi-Fi; DC/DW/DL use function 1 data channel and function 2 control/message channel |

Different modules have different frequency bands, bandwidths, and BLE capabilities, so they cannot be identified solely by the “AIC8800” product name.
For example, AIC8800D40 and D80 may use the same USB ID; D40 boards must enable
`AIC8800_WIFI_USB_LIMIT_40MHZ`.

## Source Code and Firmware

The driver source code is located at:

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/extdrv/aic8800/
```

The firmware is a separate subrepository managed by a manifest:

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/extdrv/aic8800/firmware/
```

When running `repo sync`, ensure that this subrepository has been checked out. The firmware is subject to separate licensing terms; before distributing images, read
the `README.md` and license notices in the firmware repository.

The current firmware is synchronized from AIC `aic8800d_linux_sdk_V5.0_2026_0123_5f7be68d`, corresponding to vendor
repository commit `df4c783b663eba1956579c681acd5e45f25c671d`. USB D80X2 includes both U03
and U05 revision files. The additional D80N and D80X2 SDIO files in the vendor SDK are not packaged
because the current RT-Smart SDIO driver has not yet implemented the boot and calibration
paths required by these families. The `README.md` of the firmware subrepository should be updated simultaneously during subsequent synchronizations; this file is the
authoritative record of the firmware source.

The build system installs the firmware into `/bin/firmware`. When only one transport is enabled, the family directory
of the selected transport is installed directly to this path; when both USB and SDIO are enabled, the `usb/` and `sdio/` directory levels are retained to
prevent firmware with the same name from overwriting each other. Do not replace a USB FMAC file with an SDIO file of the same name.

### USB Device IDs

The Wi-Fi USB IDs currently supported by the driver are as follows:

| Chip Series | Boot ID | Runtime ID |
| :-- | :-- | :-- |
| AIC8800/AIC8801 | `a69c:8800` | `a69c:8801` |
| AIC8800D80 | `a69c:8d80` | `a69c:8d81`, `a69c:8d83`, `a69c:8d84`, `a69c:8d85`, `a69c:8d86`, `a69c:8d88`; `368b:8d81`, `368b:8d83`, `368b:8d84`, `368b:8d85`, `368b:8d86`, `368b:8d88` |
| AIC 88M80 | `1111:1111` factory placeholder, `a69c:8d80` after exiting MSC | `a69c:8d81` composite |
| AIC8800D40 | `a69c:8d40` | `a69c:8d41` |
| AIC8800D80X2 | `368b:8d90` | `368b:8d91`, `368b:8d99` |
| AIC8800DC/DW/DL | `a69c:5721` MSC | `a69c:88dc`, `a69c:88dd` |

`1111:1111` has been verified on an actual 88M80 device, but it is not a USB-IF identity assigned by AIC; it is a
generic placeholder used when the module leaves the factory. The driver claims this ID and sends the 88M80 private
SCSI mode-switch command only when `AIC8800_WIFI_USB_MODESWITCH_PLACEHOLDER_ID=y` is set; products that do not use the 88M80 should disable this option to avoid claiming other mass-storage devices that use
the same placeholder.

`a69c:5721` is the MSC identifier used by the DC family before entering runtime mode. The current vendor firmware no longer provides a
separate `aic8800dc_fc` patch branch; after the device exits MSC and is re-enumerated as `88dc`/`88dd`, the
driver selects the standard or H-version file in `aic8800DC` based on the actual silicon revision.

### SDIO Device IDs

The AIC SDIO IDs currently supported by the driver are as follows:

| Chip Series | function | manufacturer:product | Purpose |
| :-- | :-- | :-- | :-- |
| AIC8801 | 1 | `5449:0145` | Wi-Fi data and control |
| AIC8800D80 | 1 | `c8a1:0082` | Wi-Fi |
| AIC8800DC/DW/DL | 1 | `c8a1:c08d` | Wi-Fi data |
| AIC8800DC/DW/DL | 2 | `c8a1:c18d` | Firmware control and messages |

AIC8800DC/DW/DL must enumerate both function 1 and function 2; the driver starts firmware initialization only when the IDs of both match.
`c8a1:c18d` is the message function required by the WLAN transport and does not register a
Bluetooth HCI device. The SDIO transport currently does not provide a Bluetooth HCI backend.

The DC/DW/DL driver reads the silicon chip ID, sub-ID, and MCU ID, and automatically selects the standard U02 or H
U02 firmware. DL has no separate device ID or firmware filename and shares `aic8800DC` with DC/DW.
When USB and SDIO are enabled simultaneously, the files should be located in
`/bin/firmware/sdio/aic8800DC`; when only SDIO is enabled, they should be located in
`/bin/firmware/aic8800DC`. Do not manually rename the standard and H-version files to the same filename.
Both USB and SDIO perform matching DPD calibration according to the vendor process; calibration failures for either the standard or H version will
terminate firmware initialization; the driver no longer provides Kconfig options to force or skip DPD.

## Configuration

First select the target board configuration, then enter RT-Smart configuration:

```shell
make <board>_defconfig
make rtsmart-menuconfig
```

Enable `RT_USING_AIC8800_WIFI`, then select at least one transport:

- `AIC8800_WIFI_TRANSPORT_USB`: Depends on CherryUSB Host;
- `AIC8800_WIFI_TRANSPORT_SDIO`: Depends on RT-Thread SDIO;
- Both can be enabled simultaneously, and each physical device detected will be registered as an independent radio.

In `Firmware Packaging`, select the firmware series according to the actual hardware:

| Configuration option | Packaged content |
| :-- | :-- |
| `AIC8800_WIFI_FIRMWARE_AIC8800` | AIC8800/AIC8801 |
| `AIC8800_WIFI_FIRMWARE_D80` | AIC8800D80/D40 and compatible D8x devices |
| `AIC8800_WIFI_FIRMWARE_D80X2` | AIC8800D80X2, USB only |
| `AIC8800_WIFI_FIRMWARE_DC_DW` | AIC8800DC/DW/DL |

Common configuration options are as follows:

| Configuration option | Description |
| :-- | :-- |
| `AIC8800_WIFI_AUTO_START` | Initializes the STA and AP interfaces after the device is mounted; enabled by default |
| `AIC8800_WIFI_FIRMWARE_PATH` | Firmware installation root directory; defaults to `/bin/firmware` |
| `AIC8800_WIFI_COUNTRY_CODE` | Two-character country code; defaults to `CN` |
| `AIC8800_WIFI_COUNTRY_TX_POWER_LIMIT` | Uses the country table as a hard firmware transmit power limit; disabled by default. When disabled, the country table still restricts channels and is used for reporting |
| `AIC8800_WIFI_5GHZ` | Publishes 5 GHz channels; should be disabled for 2.4 GHz-only modules |
| `AIC8800_WIFI_POWER_SAVE` | Firmware STA power saving; disabled by default. Enable only when idle power consumption is more important and after stress testing |
| `AIC8800_WIFI_USB_LIMIT_40MHZ` | Must be enabled for AIC8800D40L USB modules |
| `AIC8800_WIFI_BLE` | USB composite devices register `/dev/hciN`; enabled by default |
| `AIC8800_WIFI_DEBUG_STATS` | Registers the `aic8800_stat` debug command; recommended to enable only for diagnostics |

After updating DC/DW/DL transports, the performance-related defaults are as follows:

| Configuration option | Default value |
| :-- | :-- |
| `AIC8800_WIFI_DATA_RX_URBS` | 4 for descriptor DMA, 20 for other modes |
| `AIC8800_WIFI_MESSAGE_RX_URBS` | 1 for descriptor DMA, 20 for other modes |
| `AIC8800_WIFI_DATA_TX_URBS` | 2 |
| `AIC8800_WIFI_USB_TX_AGGREGATION` | Disabled |
| `AIC8800_WIFI_SDIO_TX_AGGREGATE_WAIT_MS` | 0 ms |

Descriptor DMA completion handling is generated only when the last descriptor of a
non-periodic descriptor chain completes. Traffic on the dedicated message endpoint is
relatively sparse, so only one message RX URB is kept armed by default to prevent command
replies from being delayed by idle chains. Modifying `AIC8800_WIFI_MESSAGE_RX_URBS` is not
recommended unless diagnosing a specific controller or firmware.

Firmware station power save was changed from enabled to disabled because DC/DW firmware may
stop processing the best-effort TX queue under sustained traffic and trigger an AC1 timer
assertion. USB RX queue depth and SDIO aggregate wait have also changed; board defconfigs
that rely on the old configuration should explicitly pin the required values.
Do not increase the USB TX URB merely to improve throughput, as the CherryUSB DWC2 URB/QTD
pool is shared by all devices and endpoints on the controller.

SDIO modules also require selecting the actual host in `SDIO Wi-Fi Board Bus` and configuring
`BSP_WIFI_SDIO_REG_ON_PIN` according to the board wiring. The driver uses four-wire SDIO
high-speed at up to 50 MHz; do not force the link to 100 MHz before completing UHS tuning.

`k230_canmv_01studio_defconfig` enables both AIC8800 USB and SDIO,
`k230_canmv_01studio_emmc_defconfig` and `k230_canmv_lckfb_defconfig` enable USB, and
`k230_canmv_v3p0_defconfig` enables SDIO host 0. The effective SDIO Wi-Fi configuration for
01Studio is host 1 and REG_ON GPIO 53. Other board configurations must be enabled as
required by the hardware. AIC8800DC is a 2.4 GHz-only module, so `AIC8800_WIFI_5GHZ` should
be disabled when using this card.

## Device Naming and Selection

Each physical radio registers a set of dynamically assigned names:

| Type | Example name |
| :-- | :-- |
| WLAN management device | `phy0-sta`, `phy0-ap` |
| lwIP netdev | `wlan0`, `wlan0ap` |
| Offload control device | `/dev/wlanctl0` |

Numbering depends on detection order, so do not assume that AIC8800 will always be `wlan0` in applications. Use the following command
to view the model, bus, role, and dynamic netdev:

```shell
wifi devices
```

When multiple Wi-Fi devices are present, you can select one by bus, or pass a management device or netdev name:

```shell
wifi -i usb scan
wifi -i sdio join <ssid> <password>
wifi -i wlan0 status
```

Native RT-Smart applications should use NetMgmt to select the physical transport, then call the existing STA/AP interfaces:

```c
netmgmt_wlan_select_device(NETMGMT_WLAN_DEVICE_SDIO,
                           RT_NET_DEV_WLAN_STA);
netmgmt_wlan_sta_connect_with_ssid("my-ap", "12345678");
```

Selection and subsequent operations are two independent calls; when multiple threads share NetMgmt, the application must serialize
the “select and operate” combination.

## STA and SoftAP

Basic verification procedure:

```shell
wifi devices
wifi -i auto scan
wifi -i auto join <ssid> <password>
wifi -i auto status
ifconfig
ping <gateway-address>
```

STA supports open, WEP, WPA/WPA2 Personal, and the restricted WPA3-SAE Personal path.
WPA3 currently uses SAE group 19, hunting-and-pecking, and BIP-CMAC-128; SAE H2E,
Enterprise/802.1X, and other modes require a full external supplicant.

SoftAP supports open networks and WPA2-PSK/CCMP:

```shell
wifi -i auto ap <ssid>
wifi -i auto ap <ssid> <password> 2g 6
wifi -i auto ap <ssid> <password> 5g 149
wifi -i auto list_sta
wifi -i auto ap_stop
```

AIC firmware has only one channel context. When STA and AP run concurrently, they must use the same primary channel; requesting a different
primary channel returns busy and does not silently interrupt the other interface. SoftAP does not support WPA3, Enterprise,
WPS, DFS/CAC, or dynamic VLAN.

## Bandwidth and Throughput Validation

`clock=50000 kHz` in the SDIO host log indicates the SDIO bus clock between the K230 and the module,
and is not the same parameter as the 20/40/80 MHz Wi-Fi RF channel width. When determining 80 MHz support and the actual connection
bandwidth, distinguish between the following two log messages:

- `ME capabilities ... max-bw=80 MHz`: The maximum capability reported to the host by the chip/firmware;
- `association channel ... width=80 MHz`: The actual RF bandwidth used for this STA association.

`wifi status` shows current link information. When `AIC8800_WIFI_DEBUG_STATS` is enabled, you can also run
`aic8800_stat` to view USB, SDIO, WLAN, RX reorder, and firmware rate-control statistics.
This option adds per-frame statistics and ICMP checksum diagnostics, and should usually remain disabled in performance benchmark images.

Short tests immediately after a cold boot do not represent stable throughput. If the first round of results is low but recovers after waiting approximately 20 seconds, first
run a 30–60 second test and record throughput, retransmissions, and RSSI per second before comparing USB/SDIO transports or firmware
versions. The mere fact that a connection has been established and throughput subsequently stabilizes does not prove that DPD calibration has failed; an actual DPD failure
prints an error during firmware initialization and prevents WLAN registration.

## BLE

After the USB transport enables `AIC8800_WIFI_BLE`, the Bluetooth interface registers as a dynamic `/dev/hciN`.
It provides an H:4 controller transport but does not include a GAP/GATT protocol stack; RT-Smart applications can use NimBLE,
while CanMV firmware can enable its MicroPython NimBLE module. SCO audio is not implemented.

See the [Bluetooth HCI and NimBLE Usage Guide](how_to_use_bluetooth.md) for complete
host/controller configuration and limitations.

## Troubleshooting

1. `wifi devices` does not show an AIC device: First check the USB/SDIO host, power supply, and corresponding transport configuration.
1. The log indicates that the firmware file does not exist: Confirm that the firmware subrepository has been synchronized and check the
   `/bin/firmware` layout in the image.
1. The log shows functions 1/2 as `c8a1:c08d`, `c8a1:c18d`, but subsequently reports
   `no driver for SDIO function`: The current image still uses the old driver and must be rebuilt and the RT-Smart
   system image updated.
1. DC/DW/DL enumerates only one function: Check the module power supply, reset, SDIO signals, and host configuration;
   the driver initializes only when both functions are present.
1. DC/DW/DL patch or calibration firmware fails to load: Depending on the enabled transport, check
   `/bin/firmware/sdio/aic8800DC` or `/bin/firmware/aic8800DC`. If the log explicitly shows
   DPD calibration failure, also check the power supply, reset timing, and silicon revision in the log.
1. D40 can connect but has an abnormal rate: Confirm that `AIC8800_WIFI_USB_LIMIT_40MHZ=y`.
1. CRC errors occur on SDIO: First restore the 50 MHz, four-wire high-speed configuration and check the routing.
1. USB stress tests are abnormal: Enable `AIC8800_WIFI_DEBUG_STATS` and view
   `aic8800_stat`; do not blindly increase the URB and queue depths first.
1. Throughput is low only in the first round immediately after association: Extend the test and record the results in segments. If it returns to normal after 20 seconds,
   investigate firmware rate control and the AP negotiation process before modifying DPD or the SDIO host clock.

For diagnostic methods involving the underlying offload control device, see
[WLAN Offload Control Example](../app_develop_guide/peripheral/wlan_offload.md).
