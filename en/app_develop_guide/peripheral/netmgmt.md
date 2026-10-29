# NetMgmt Example

## Introduction

This example is a comprehensive test of the network management HAL, covering WLAN STA, WLAN AP, LAN, physical Wi-Fi
selection, dynamic device name, default NIC, and IP configuration interfaces.

Source location: `src/rtsmart/examples/peripheral/netmgmt/test_netmgmt.c`

## Example Behavior

- UTILS: default NIC, logical interface name resolution, device probing, ifconfig, device list
- WLAN STA: auto-reconnect, connect/disconnect, scan, RSSI, MAC, AP info
- WLAN AP: start/stop, active state, country code, connected STA management
- LAN: link status, MAC, static IP, DHCP switching

The test SSID/password used in the example are macros inside the source code (`TEST_SSID`/`TEST_PASSWORD`); for actual use, please modify the source code according to your local network.

## Key Interfaces

- `netmgmt_utils_*`
- `netmgmt_wlan_select_device()`
- `netmgmt_wlan_sta_*`
- `netmgmt_wlan_ap_*`
- `netmgmt_lan_*`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/netmgmt
make
./test_netmgmt
```

This example takes no command-line arguments.

## Multi-NIC Usage Notes

The driver automatically registers WLAN and USB LAN devices. Applications should first use
`netmgmt_utils_get_dev_list()` to view the current devices; when the logical interface needs to be associated with the actual name,
call `netmgmt_utils_get_netdev_name()` and do not hard-code `eth0` or `wlan0`.

When multiple Wi-Fi devices are present, the physical device can be selected before role operations:

```c
char name[32];

if (netmgmt_wlan_select_device(NETMGMT_WLAN_DEVICE_USB,
                               RT_NET_DEV_WLAN_STA) != 0) {
    /* USB Wi-Fi is currently unavailable */
}
if (netmgmt_utils_get_netdev_name(RT_NET_DEV_WLAN_STA, name) == 0) {
    printf("selected STA netdev: %s\n", name);
}
```

If specific hardware is not required, use `NETMGMT_WLAN_DEVICE_AUTO`. Automatic selection can switch to another Wi-Fi device with the same role after a device is removed.

## Default Route

```c
/* Set the device corresponding to the current logical LAN as the preferred uplink. */
char name[32];
if (netmgmt_utils_get_netdev_name(RT_NET_DEV_LAN, name) == 0) {
    netmgmt_utils_set_default_dev(name);
}

/* Clear the manual preference and restore automatic selection. */
netmgmt_utils_set_default_dev(NULL);
```

The system selects the default route only from enabled LAN/WLAN STA interfaces whose links
are connected and which have acquired a nonzero IP address and gateway. In automatic mode,
selection is based on the metric, with LAN taking precedence over Wi-Fi STA by default. When
the preferred device disconnects, the system temporarily switches to another ready interface
and switches back after recovery.

The default route also serves as the basis for selecting the IPv4 NAT uplink. Build options,
automatic start/stop, and session checks for SoftAP internet sharing are described in the
[IPv4 NAT Usage Guide](../../advanced_development_guide/how_to_use_nat.md).

```{admonition} Tip
For interface descriptions and parameter definitions, refer to the [NetMgmt API Documentation](../../api_reference/peripheral/netmgmt.md).
```
