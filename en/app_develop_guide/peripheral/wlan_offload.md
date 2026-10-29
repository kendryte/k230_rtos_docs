# WLAN Offload Control Example

## Overview

The WLAN offload framework is intended for Wi-Fi devices whose firmware handles the 802.11 MAC. RT-Thread WLAN, NetMgmt, and lwIP remain ordinary application interfaces; `libwlan_offload` provides a versioned userspace control interface for capability diagnostics, event monitoring, and full supplicant integration.

Related source code:

```text
src/rtsmart/rtsmart/kernel/rt-thread/components/drivers/wlan/offload/
src/rtsmart/libs/wlan_offload/
src/rtsmart/examples/peripheral/wlan_offload/
```

Drivers that support this framework can register:

- `phyN-sta` and `phyN-ap`: RT-Thread WLAN managed devices;
- `wlanN` and `wlanNap`: lwIP network interfaces;
- `/dev/wlanctlN`: an optional userspace control device.

`N` is determined by radio registration order. Applications should query the names and should not assume that the target device is always `/dev/wlanctl0`.

## Configuration and Build

Vendor drivers that support offload select the required kernel options. The relevant options for manual integration are:

| Option | Description |
| :-- | :-- |
| `RT_WLAN_OFFLOAD` | Common radio, VIF, command, event, and transport framework |
| `RT_WLAN_OFFLOAD_CONTROL` | Registers the `/dev/wlanctlN` control device |
| `RT_WLAN_OFFLOAD_SUPPLICANT` | Enables the external supplicant contract |
| `RT_WLAN_OFFLOAD_EMBEDDED_WPA2` | Kernel WPA/WPA2/WPA3 Personal path |
| `RT_WLAN_OFFLOAD_EMBEDDED_HOSTAPD` | Open/WPA2-Personal SoftAP authenticator |

Enable them in the userspace example configuration:

```text
RTSMART_ENABLE_PERIPHERAL_EXAMPLES=y
RTSMART_PERIPHERAL_ENABLE_WLAN_OFFLOAD=y
```

A full build generates `wlan_offload.elf`. The library can also be built separately:

```shell
make -C src/rtsmart/libs/wlan_offload
```

Applications should include only the installed `wlan_offload_client.h`. Do not include the private `wlan_offload_wire.h` or kernel `wlan_offload_control_protocol.h`.

## Example Commands

First, use the RT-Smart shell to inspect the actual devices:

```shell
wifi devices
```

Then run the diagnostic program:

```shell
wlan_offload.elf /dev/wlanctl0 names
wlan_offload.elf /dev/wlanctl0 info
wlan_offload.elf /dev/wlanctl0 probe
wlan_offload.elf /dev/wlanctl0 scan
wlan_offload.elf /dev/wlanctl0 monitor
```

The device argument may also be omitted when only one radio is connected, in which case `/dev/wlanctl0` is used by default:

```shell
wlan_offload.elf info
```

The commands are described as follows:

| Command | Description |
| :-- | :-- |
| `names` | Queries the radio index and control, STA, and AP names |
| `info` | Reads the current interface capabilities and firmware version without actively starting the STA |
| `probe` | Enables the STA through the WLAN management path before reading capabilities |
| `scan` | Initiates a scan and prints scan result/done events |
| `monitor` | Blocks indefinitely after enabling the STA and prints events received after the startup command |

On drivers with automatic STA enabled, `probe` is an idempotent diagnostic operation. `monitor` runs continuously and is terminated with `Ctrl+C`.

```{note}
控制设备是独占打开的。同一时间只能由一个进程持有；运行 `monitor` 时，其他
诊断程序或用户态 supplicant 无法打开同一个 `/dev/wlanctlN`。
```

## Client API

Typical lifecycle:

```c
#include <wlan_offload_client.h>

struct wlan_offload_handle *handle;
struct wlan_offload_names names;
struct wlan_offload_info info;

if (wlan_offload_open(&handle, "/dev/wlanctl0") != 0)
    return -1;

wlan_offload_get_names(handle, WLAN_OFFLOAD_INTERFACE_STATION, &names);
wlan_offload_get_info(handle, WLAN_OFFLOAD_INTERFACE_STATION, &info);

wlan_offload_close(handle);
```

The public APIs are grouped as follows:

| Group | Interfaces |
| :-- | :-- |
| Opening and querying | `wlan_offload_open()`, `close()`, `get_fd()`, `get_info()`, `get_names()` |
| Interface and scanning | `set_interface()`, `scan()`, `abort_scan()` |
| Connection control | `authenticate()`, `associate()`, `disconnect()` |
| Keys | `set_key()`, `delete_key()`, `set_default_key()` |
| Data frames | `send_mgmt()`, `send_eapol()` |
| External authentication | `external_auth_response()` |
| Events | `receive_event()` |

When `timeout_ms` of `wlan_offload_receive_event()` is `-1`, it waits indefinitely; when it is `0`, it is nonblocking; and when it is greater than zero, it times out in milliseconds. After receiving an external-auth event, the supplicant handles the specified AKM exchange and passes the same `request_id` to `wlan_offload_external_auth_response()`.

Channel-related structures use the complete `wlan_offload_channel`, including the band, primary channel, width, and center frequency, and cannot be simplified to a single channel number. Scan security types use the public `WLAN_OFFLOAD_SECURITY_*` constants; do not rely on kernel enumeration header files.

## Example Boundaries

`wlan_offload.elf` is a diagnostic program. It does not implement a WPA supplicant and does not replace NetMgmt in ordinary applications. For routine network connectivity, continue to use `wifi join`, `rt_wlan_*`, or NetMgmt. When full enterprise authentication, SAE H2E, or similar functionality is required, have a mature userspace supplicant link against `libwlan_offload` instead of implementing the private wire protocol in the application.
