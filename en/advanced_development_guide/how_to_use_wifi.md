# Wi-Fi Driver Selection and Board-Level Configuration

## Driver Overview

RT-Smart can currently build multiple Wi-Fi drivers simultaneously. Applications uniformly use RT-Thread WLAN, NetMgmt,
lwIP, and the `wifi` command; the actual chip cannot be determined based on the legacy fixed `wlan0` name.

| Driver | Transport | Registered Model | Main Configuration |
| :-- | :-- | :-- | :-- |
| Realtek RTL8189FTV | SDIO | `rtl8189ftv` | `RT_USING_REALTEK` + `REALTEK_SDIO_RTL8189FTV` |
| Realtek RTL8733BS | SDIO | `rtl8733bs` | `RT_USING_REALTEK` + `REALTEK_SDIO_RTL8733BS` |
| Broadcom brcmfmac | SDIO | `BCM43430A1` | `RT_USING_BRCMFMAC` |
| CYW43xx (legacy) | SDIO | `cyw43438` | `RT_USING_CYW43XX` |
| RW007 | SPI Mode 0 | `rw007` | `RT_USING_RW007` |
| AIC8800 series (including DC/DW/DL) | USB, SDIO | Specific chip model | `RT_USING_AIC8800_WIFI` |
| ESP-Hosted-FG/NG | SPI Full-Duplex, SDIO | `esp-hosted-fg/ng` | `RT_USING_ESP_HOSTED_WIFI` |
| ESP-Hosted-MCU | SPI Full/Half-Duplex | `esp-hosted-mcu` | `RT_USING_ESP_HOSTED_MCU` |

AIC8800 and ESP-Hosted differ considerably in firmware, protocols, and security capabilities. See
[AIC8800 Wi-Fi Driver User Guide](how_to_use_aic8800.md) and
[ESP-Hosted Wi-Fi Coprocessor User Guide](how_to_use_esp_hosted.md), respectively.

## Common SDIO Board-Level Configuration

Realtek, brcmfmac, CYW43xx, AIC8800 SDIO, and ESP-Hosted SDIO share the
`SDIO Wi-Fi Board Bus` configuration. Select the connected host and configure REG_ON/Reset according to the schematic:

```text
BSP_WIFI_SDIO_HOST_0=y              # or BSP_WIFI_SDIO_HOST_1
BSP_WIFI_SDIO_REG_ON_PIN=<gpio>     # -1 indicates use of the board's fixed wiring
BSP_WIFI_SDIO_RESET_ACTIVE_LOW=y
BSP_WIFI_SDIO_RESET_PULSE_MS=200
BSP_WIFI_SDIO_POWER_UP_DELAY_MS=50
```

The selected host must enable the corresponding `RT_USING_SDIO0` or `RT_USING_SDIO1`. The common board-level code resets
the slot only once before probing. Each vendor driver subsequently matches by SDIO manufacturer/product ID, so SDIO drivers
from different vendors can be compiled simultaneously.

## Realtek RTL8189FTV/RTL8733BS

After enabling `RT_USING_REALTEK`, exactly one Realtek module must be selected:

```text
REALTEK_SDIO_RTL8189FTV=y           # SDIO ID 024c:f179
# REALTEK_SDIO_RTL8733BS=y          # SDIO ID 024c:b733
```

These options determine the vendor module compiled into the image and cannot be enabled simultaneously. If the wrong module
is selected, the SDIO host may recognize the card but will not register WLAN. To use vendor interactive commands or obtain
detailed logs, enable `REALTEK_INTERACTIVE_CMD` and `REALTEK_ENABLE_DEBUG` respectively; they are recommended to be disabled
for production firmware.

## Broadcom brcmfmac

The new configuration recommends enabling the native RT-Smart brcmfmac port:

```text
RT_USING_BRCMFMAC=y
BRCMFMAC_COUNTRY_CODE="CN"
BRCMFMAC_COUNTRY_REVISION=0
BRCMFMAC_BCM43430A1_NVRAM="nvram.txt"
```

The target currently provided and verified with the SDK is SDIO ID `02d0:a9a6`, chip revision A1, with registered model
`BCM43430A1`. The driver supports STA, SoftAP, and concurrent single-channel STA + SoftAP, and integrates with RT-Thread
WLAN and lwIP through WLAN offload. In concurrent mode, SoftAP may pause briefly while the STA connects and resumes on the
STA's channel after the connection is established.

The build system installs `fw_bcm43438a1.bin`, `nvram.txt`, and `nvram_ap6212.txt` into the image's
`/bin/firmware/brcmfmac` directory. The default `nvram.txt` is the K016-CW43 board calibration used by the K230 CanMV Linux
SDK. Change `BRCMFMAC_BCM43430A1_NVRAM` to `nvram_ap6212.txt` only when the module and RF design match the AP6212A
V1.0.2 calibration. NVRAM is board-level RF calibration data and cannot be exchanged solely based on the SDIO ID or chip
model.

The driver mapping table also includes other Broadcom/Cypress chips, but the SDK currently does not include the firmware,
NVRAM, or optional CLM blob for these targets. When adapting a new module, the corresponding files for Linux brcmfmac must be
provided and installed in the directory specified by `BRCMFMAC_FIRMWARE_PATH`.

The legacy `RT_USING_CYW43XX` remains available for existing board-level configurations, but it is mutually exclusive with
`RT_USING_BRCMFMAC` because both match the same Broadcom SDIO ID. Both ports provide only Wi-Fi and do not register a
Bluetooth HCI device.

## RW007

RW007 depends on RT-Thread SPI. After enabling `RT_USING_RW007`, configure it according to the board wiring:

```text
RW007_SPI_BUS_NAME="spi0"
RW007_SPI_MAX_HZ=25000000
RW007_RST_PIN=20
RW007_CS_PIN=63
RW007_INT_BUSY_PIN=62
```

The driver uses SPI Mode 0, 8-bit, single data line, and registers the slave device as `wspi`. The GPIO values and
25 MHz above are defaults and do not represent the wiring on all development boards. If initialization fails, first lower the
frequency and verify Reset, CS, INT/BUSY, and FPIOA.

## Default Configuration

- `k230_canmv_defconfig` enables brcmfmac and Realtek;
- Most CanMV defconfigs with onboard SDIO Wi-Fi enable Realtek and select RTL8189FTV by default;
- `k230_canmv_rtt_evb_defconfig` enables RW007;
- `k230_canmv_01studio_defconfig` enables AIC8800 USB/SDIO, and
  `k230_canmv_v3p0_defconfig` enables AIC8800 SDIO; DC/DW/DL SDIO cards use the two functions
  `c8a1:c08d` and `c8a1:c18d`. See their dedicated guide for details;
- ESP-Hosted has no universal wiring and is usually enabled in a custom defconfig.

A defconfig describes only the build options for that firmware. After replacing a module with the same interface, the chip,
SDIO ID, power supply, reset, and pins must still be verified; the driver cannot be determined solely by the development
board name.

## Network Stack and Network Sharing

RT-Smart currently allows selection between lwIP 2.1.2 and 2.2.1, with 2.1.2 remaining the default. See the
[lwIP 2.2.1 User Guide](how_to_use_lwip.md) for version selection, SAL/netdev adaptation, and runtime verification.

To allow SoftAP clients to access the Internet through the STA or LAN, enable the DHCP server and
`LWIP_USING_NAT`. Once NAT is compiled into the firmware, the WLAN layer automatically starts and stops it with SoftAP. See
the [IPv4 NAT User Guide](how_to_use_nat.md) for configuration, status commands, and feature limitations.

## Device Discovery and Selection

Each physical radio registers STA/AP management devices and dynamic netdevs. Run:

```shell
wifi devices
```

The model, transport, role, and netdev in the output can be used to confirm the actual binding result. The numbering is
determined by the probing order; applications must not hard-code `phy0-sta` or `wlan0`.

When there is only one Wi-Fi device, automatic selection is usually used; when multiple devices are present, selection by
transport is available:

```shell
wifi -i sdio scan
wifi -i spi join <ssid> <password>
wifi -i usb status
```

Transport selection cannot distinguish between devices from different vendors on the same SDIO or SPI type. For precise
selection, use the management device or netdev name shown in the `wifi devices` output.

## Troubleshooting

1. No WLAN at all: Verify `RT_USING_WIFI`, the host controller, power supply, and board-level reset configuration.
1. SDIO is enumerated but no WLAN is available: Check the manufacturer/product ID and the vendor driver actually compiled;
   for Realtek, also verify the RTL8189FTV/RTL8733BS selection.
1. AIC8800DC/DW/DL enumerates only one of the `c8a1:c08d` or `c8a1:c18d` functions: Check the
   power supply, reset, and host configuration; the card requires both functions to operate simultaneously.
1. brcmfmac reports that firmware or NVRAM does not exist: Confirm that `/bin/firmware/brcmfmac` exists in the image and
   verify `BRCMFMAC_BCM43430A1_NVRAM` against the actual board.
1. RW007 does not print its version: Check `RW007_SPI_BUS_NAME`, SPI Mode 0, frequency, and the three GPIOs.
1. WLAN is registered but the connection fails: First use `wifi devices` to confirm the model, then check the security mode,
   country code, and channel against that vendor's firmware support range.
1. The wrong device is selected after compiling multiple drivers: Specify it precisely with `wifi -i <management device or netdev>`, and
   do not rely on dynamic numbering remaining unchanged between boots.
