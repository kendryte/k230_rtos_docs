# Bluetooth HCI and NimBLE Guide

## Architecture

RT-Smart's `RT_USING_BT_HCI` provides a transport-independent Bluetooth HCI device framework.
Controller drivers register dynamic `/dev/hciN` character devices, with data using H:4 framing; GAP, GATT,
L2CAP, and SMP are not implemented in the kernel HCI layer and should be provided by mature host stacks such as NimBLE.

Current controller backends:

| Backend | Transport | Configuration | Description |
| :-- | :-- | :-- | :-- |
| AIC8800 series combo devices | USB | `AIC8800_WIFI_BLE` | USB Bluetooth interface; SCO audio is not implemented |
| ESP-Hosted-MCU | SPI Full/Half-Duplex | `ESP_HOSTED_BLE` | HCI multiplexes the ESP transport; start and stop use FeatureControl RPC |

Realtek RTL8189FTV/RTL8733BS, Broadcom brcmfmac, legacy CYW43xx, RW007,
AIC8800 SDIO, and ESP-Hosted-FG/NG do not register an HCI device. The current integration targets BLE
and does not support Bluetooth Classic or Bluetooth audio.

## RT-Smart Configuration

Both `AIC8800_WIFI_BLE` and `ESP_HOSTED_BLE` automatically select `RT_USING_BT_HCI`. Typical configuration:

```text
# AIC8800 USB
RT_USING_AIC8800_WIFI=y
AIC8800_WIFI_TRANSPORT_USB=y
AIC8800_WIFI_BLE=y

# or ESP-Hosted-MCU
RT_USING_ESP_HOSTED_MCU=y
ESP_HOSTED_BLE=y
```

AIC8800 BLE only supports the USB transport. AIC8800DC must have the Bluetooth patch applied first.
The ESP firmware for ESP-Hosted-MCU must enable HCI and match the host's protocol, SPI mode,
bus width, and checksum configuration.

When a controller is registered, the next available name is automatically used, such as `/dev/hci0` or `/dev/hci1`. The number is determined by
the probing order, and applications must not assume that a particular model always corresponds to `hci0`.

## HCI Device Boundary

An HCI device is a non-blocking H:4 packet stream:

- Writes contain one complete H:4 command or ACL packet;
- Reads return an H:4 byte stream of controller events or ACL data. A single `read()` may return only
  part of a packet, and the host stack is responsible for reassembly;
- The framework validates received packets and writes them to the ring buffer as complete packets. If there is insufficient space, it
  discards the entire packet and does not enqueue half a packet;
- A given controller should be owned by only one host stack.

The HCI layer is used to connect the host stack; applications are not recommended to directly implement GAP/GATT or private parsing. Native applications can
use the registration interface in `drivers/bt_hci.h` to adapt a new controller; userspace BLE should link
against NimBLE.

## Native RT-Smart NimBLE

The NimBLE source code is an independent subrepository managed by the manifest. The RT-Smart userspace port and examples are located at:

```text
src/rtsmart/libs/3rd-party/nimble/
src/rtsmart/examples/3rd-party/nimble/ble_peripheral/
```

Enable the host stack and examples:

```text
RTSMART_3RD_PARTY_ENABLE_NIMBLE=y
RTSMART_3RD_PARTY_ENABLE_NIMBLE_SAMPLES=y
```

The first option also selects Mbed TLS and generates `libnimble.a`; the second generates
`ble_peripheral.elf`. The example automatically scans `/dev/hci0` through `/dev/hci63`, or you can specify one explicitly:

```shell
ble_peripheral.elf /dev/hci1
```

Use a mobile BLE tool to scan for `K230-NimBLE`. The example registers the service
`6e400001-b5a3-f393-e0a9-e50e24dcca9e`, with the readable and writable characteristic
`6e400002-b5a3-f393-e0a9-e50e24dcca9e`.

If a native application needs to specify a controller, it should call `rtsmart_nimble_hci_set_device("/dev/hciN")` before `nimble_port_init()`; passing `NULL` restores automatic selection. After initialization,
the actual path can be queried through `rtsmart_nimble_hci_get_device()`.

## CanMV NimBLE

CanMV additionally enables the following at the top level:

```text
ENABLE_BLUETOOTH=y
```

After the build, MicroPython `bluetooth.BLE()` uses NimBLE and automatically opens the first available
`/dev/hciN`. The current CanMV port enables central, peripheral, GATT client/server, and
L2CAP; the actual functionality is also constrained by the controller and its firmware.

```python
import bluetooth

ble = bluetooth.BLE()
ble.active(True)
print(ble.config("mac"))
ble.gap_scan(5000, 30000, 30000, True)
```

After use, execute `ble.active(False)` to have NimBLE close the HCI device. ESP-Hosted-MCU
deactivates the remote controller when the device is closed and can be opened again later.

## Verification and Troubleshooting

1. No `/dev/hciN` after startup: Check the controller backend, physical transport, and corresponding BLE
   Kconfig; enabling only `RT_USING_BT_HCI` will not create a controller out of thin air.
1. `ble_peripheral.elf` was not generated: Confirm that both the NimBLE library and sample options are enabled,
   and confirm that the manifest has checked out the `libs/3rd-party/nimble/nimble` subrepository.
1. CanMV `import bluetooth` fails: Confirm that `ENABLE_BLUETOOTH=y`.
1. `bluetooth.BLE().active(True)` fails: Confirm that at least one HCI device has been registered and is not occupied by another
   process.
1. AIC USB WLAN works but there is no HCI: Check the USB combo interface, device ID, BLE configuration, and model
   firmware/patch; AIC SDIO does not provide this HCI backend.
1. ESP HCI was not registered: Confirm that ESP-Hosted-MCU firmware is being used and that the coprocessor reports BLE
   capability; FG/NG personalities are not supported by the current HCI backend.
1. The wrong device is used when multiple controllers are present: CanMV currently automatically opens the first `/dev/hciN`;
   retain only the target backend in the firmware, or explicitly select the device in a native application.

For transport details on AIC and ESP, see [AIC8800 Wi-Fi Driver Guide](how_to_use_aic8800.md)
and [ESP-Hosted Wi-Fi Coprocessor Guide](how_to_use_esp_hosted.md).
