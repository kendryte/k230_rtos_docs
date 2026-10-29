# K230 NetMgmt API Reference

## Overview

The Network Management HAL provides Wi-Fi (STA and AP modes), LAN, network device discovery, and default route management
interfaces. Network cards are automatically registered by the driver, and applications access them through logical interfaces or dynamic device names; they should not rely on fixed
hardware device names.

---

## Constant Definitions

### Network Interface Types

```c
enum rt_netif_t {
    RT_NET_DEV_WLAN_STA = 0,  // Wi-Fi Station Mode
    RT_NET_DEV_WLAN_AP  = 1,  // Wi-Fi Access Point Mode
    RT_NET_DEV_LAN      = 2,  // General-purpose LAN (RTL8152/ECM/NCM)

    // Compatible with legacy source code; all are equivalent to RT_NET_DEV_LAN
    RT_NET_DEV_USB_RTL8152 = RT_NET_DEV_LAN,
    RT_NET_DEV_USB_ECM     = RT_NET_DEV_LAN,
    RT_NET_DEV_USB_NCM     = RT_NET_DEV_LAN,
};
```

### WLAN Physical Device Types

```c
enum netmgmt_wlan_device {
    NETMGMT_WLAN_DEVICE_AUTO = 0,
    NETMGMT_WLAN_DEVICE_USB,
    NETMGMT_WLAN_DEVICE_SDIO,
    NETMGMT_WLAN_DEVICE_SPI,
};
```

`AUTO` preferentially retains the device already selected for the current role; when reselection is needed, devices are searched in the order of SDIO, SPI, USB, and unknown transport type. Explicitly specify the type only when the application must fix the physical connection method.

### Maximum Length Limits

```c
#define RT_WLAN_SSID_MAX_LENGTH 32         // SSID最大长度
#define RT_WLAN_PASSWORD_MAX_LENGTH 64     // 密码最大长度
#define RT_WLAN_BSSID_MAX_LENGTH 6         // MAC地址长度
#define RT_WLAN_STA_SCAN_MAX_AP 64         // 扫描结果中AP最大数量
#define NET_DEV_MAX_CNT 8                  // 最大网络设备数量
```

---

## Wi-Fi STA Functionality

### Physical Device Selection

#### `netmgmt_wlan_select_device()`

**Description**: Selects the physical WLAN device used by subsequent role interfaces.
**Parameters**:

- `device`: `NETMGMT_WLAN_DEVICE_AUTO`, `USB`, `SDIO`, or `SPI`;
- `itf`: `RT_NET_DEV_WLAN_STA` or `RT_NET_DEV_WLAN_AP`.

**Return value**: Returns 0 on success, or -1 if the selected device is unavailable or the parameters are invalid.

The selection affects all subsequent STA/AP role-based `netmgmt_wlan_*` and `netmgmt_utils_*`
calls. In a multi-Wi-Fi device environment, select the physical device before performing connection, scanning, or IP configuration.

### Auto Reconnect Management

#### `netmgmt_wlan_sta_get_auto_reconnect()`

**Function**: Get auto reconnect status  
**Parameters**:

- `enable`: Pointer to store status (0=disabled, 1=enabled)  
**Return value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_set_auto_reconnect()`

**Function**: Enable/disable auto reconnect  
**Parameters**:

- `enable`: 0 to disable, 1 to enable  
**Return value**: Returns 0 on success, -1 on failure  

---

### Connection Management

#### `netmgmt_wlan_sta_connect_with_ssid()`

**Function**: Connect to AP using SSID and password
**Parameters**:

- `ssid`: Network SSID
- `password`: Network password
**Return value**: Returns 0 on success, -1 on failure

#### `netmgmt_wlan_sta_connect_with_scan_info()`

**Function**: Connect to AP using scan information
**Parameters**:

- `info`: Pointer to scan result information
- `password`: Network password
**Return value**: Returns 0 on success, -1 on failure

#### `netmgmt_wlan_sta_disconnect_ap()`

**Function**: Disconnect from current AP connection
**Return value**: Returns 0 on success, -1 on failure

#### `netmgmt_wlan_sta_isconnected()`

**Function**: Check connection status
**Parameters**:

- `status`: Pointer to store status (1=connected, 0=not connected)
**Return value**: Returns 0 on success, -1 on failure

---

### AP Information Acquisition

#### `netmgmt_wlan_sta_get_ap_info()`

**Function**: Get information of the connected AP  
**Parameters**:

- `info`: Pointer to store AP information  
**Return Value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_get_rssi()`

**Function**: Get signal strength (RSSI)  
**Parameters**:

- `rssi`: Pointer to store RSSI value  
**Return Value**: Returns 0 on success, -1 on failure  

---

### Scanning Functions

#### `netmgmt_wlan_sta_scan()`

**Function**: Scan for available APs  
**Parameters**:

- `ap_num`: Pointer to store the number of discovered APs  
- `ap_infos`: Array to store AP information  
**Return Value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_scan_with_ssid()`

**Function**: Scan for a specific SSID  
**Parameters**:

- `ssid`: The SSID to search for  
- `ap_info`: Pointer to store the information of the found AP  
**Return Value**: Returns 0 if found, -1 otherwise  

---

### MAC Address Management

#### `netmgmt_wlan_sta_get_mac()`

**Function**: Get STA MAC address  
**Parameters**:

- `mac`: Buffer to store the MAC address  
**Return Value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_set_mac()`

**Function**: Set STA MAC address  
**Parameters**:

- `mac`: The MAC address to be set  
**Return Value**: Returns 0 on success, -1 on failure  

---

## Wi-Fi AP Functions

### AP Management

#### `netmgmt_wlan_ap_start_with_ssid()`

**Function**: Start AP with SSID and password  
**Parameters**:

- `ssid`: SSID of the AP  
- `password`: AP password  
**Return value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_start_with_info()`

**Function**: Start AP with configuration information  
**Parameters**:

- `info`: AP configuration  
- `password`: AP password  
**Return value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_stop()`

**Function**: Stop the AP  
**Return value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_isactived()`

**Function**: Check whether the AP is active  
**Parameters**:

- `status`: Pointer to store the status (1=active, 0=inactive)  
**Return value**: Returns 0 on success, -1 on failure  

---

### AP Information Acquisition

#### `netmgmt_wlan_ap_get_info()`

**Function**: Get AP configuration information  
**Parameters**:

- `info`: Pointer to store AP information  
**Return Value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_get_sta_info()`

**Function**: Get connected STA clients  
**Parameters**:

- `sta_num`: Pointer to store the number of STAs  
- `sta_infos`: Array to store STA information  
**Return Value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_disconnect_sta()`

**Function**: Disconnect a STA client  
**Parameters**:

- `mac`: MAC address of the STA to disconnect  
**Return Value**: Returns 0 on success, -1 on failure  

---

### Country Code Settings

#### `netmgmt_wlan_ap_get_country()`

**Function**: Get AP country code  
**Parameters**:

- `country`: Pointer to store the country code  
**Return Value**: Returns 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_set_country()`

**Function**: Set AP country code  
**Parameters**:

- `country`: The country code to set  
**Return Value**: Returns 0 on success, -1 on failure  

---

## LAN Functionality

### Connection Status

#### `netmgmt_lan_get_isconnected()`

**Function**: Check whether LAN is connected  
**Parameters**:

- `itf`: Uses `RT_NET_DEV_LAN`
- `status`: Pointer to store the status (1=link connected and a valid IP is available, 0=not connected)  
**Return Value**: Returns 0 on success, -1 on failure

#### `netmgmt_lan_get_link_status()`

**Function**: Get LAN link status  
**Parameters**:

- `itf`: Uses `RT_NET_DEV_LAN`
- `status`: Pointer to store the link status  
**Return Value**: Returns 0 on success, -1 on failure  

---

### MAC Address Management

#### `netmgmt_lan_get_mac()`

**Function**: Get LAN MAC address  
**Parameters**:

- `itf`: Uses `RT_NET_DEV_LAN`
- `mac`: Buffer to store the MAC address  
**Return Value**: Returns 0 on success, -1 on failure

#### `netmgmt_lan_set_mac()`

**Function**: Set LAN MAC address  
**Parameters**:

- `itf`: Use `RT_NET_DEV_LAN`
- `mac`: The MAC address to set  
**Return Value**: Returns 0 on success, -1 on failure  

---

## Network Tools

### Device Management

#### `netmgmt_utils_get_default_dev()`

**Function**: Get the currently effective default network device  
**Parameters**:

- `name`: 32-byte buffer for storing the device name; gets an empty string when no default uplink is currently available  
**Return Value**: Returns 0 on success, -1 on failure

#### `netmgmt_utils_set_default_dev()`

**Function**: Set the preferred default uplink device  
**Parameters**:

- `name`: Full device name returned by `netmgmt_utils_get_dev_list()`; passing `NULL` clears the preferred
  device and restores automatic selection
**Return Value**: Returns 0 on success, -1 on failure  

Only LAN and Wi-Fi STA can serve as the default uplink. Wi-Fi AP and unknown device types are rejected.
Setting a preferred device does not disable automatic failover: the system selects another available uplink when the preferred device is not ready, and automatically switches back when the preferred
device recovers.

The old spellings `netmgmt_utils_get_defeault_dev()` and
`netmgmt_utils_set_defeault_dev()` are still retained as deprecated aliases. New code should use the correct spelling.

#### `netmgmt_utils_get_dev_list()`

**Function**: Get network device list  
**Parameters**:

- `dev_num`: Pointer to store device count  
- `names`: Array to store device names  
**Return Value**: Returns 0 on success, -1 on failure  

Device names are dynamically allocated full names. USB LAN typically uses `eth0` through `eth9`; WLAN STA/AP
typically uses `wlanN`/`wlanNap`, where `N` denotes the physical radio number. Do not hard-code these example names
in the application.

#### `netmgmt_utils_probe_device()`

**Function**: Probe network interface availability  
**Parameters**:

- `itf`: Interface type  
- `status`: Pointer to store probe result  
**Return Value**: Returns 0 on success, -1 on failure

#### `netmgmt_utils_get_netdev_name()`

**Function**: Resolves a logical interface to the current netdev name.
**Parameters**:

- `itf`: `RT_NET_DEV_WLAN_STA`, `RT_NET_DEV_WLAN_AP`, or
  `RT_NET_DEV_LAN`;
- `name`: A 32-byte buffer that stores the name.

**Return value**: Returns 0 on success, or -1 when the interface is currently unavailable.

For WLAN, this function returns the device selected by the most recent `netmgmt_wlan_select_device()`;
if no device has been selected, it attempts to select one automatically.

---

### IP Configuration

#### `netmgmt_utils_get_ifconfig()`

**Function**: Get interface IP configuration  
**Parameters**:

- `itf`: Interface type  
- `config`: Pointer to store IP configuration  
**Return Value**: Returns 0 on success, -1 on failure  

#### `netmgmt_utils_set_ifconfig_static()`

**Function**: Set static IP configuration  
**Parameters**:

- `itf`: Interface type  
- `config`: IP configuration to set  
**Return Value**: Returns 0 on success, -1 on failure  

#### `netmgmt_utils_set_ifconfig_dhcp()`

**Function**: Enable DHCP for the interface  
**Parameters**:

- `itf`: Interface type  
**Return Value**: Returns 0 on success, -1 on failure  

---

## Data Structures

### `struct rt_wlan_info_t`

Contains Wi-Fi network information, including:

- Security type
- Frequency band (2.4GHz/5GHz)
- Data rate
- Channel
- RSSI (Signal strength)
- SSID
- BSSID (MAC address)
- Hidden status

### `struct ifconfig_t`

Contains IP configuration information, including:

- IP address
- Gateway
- Subnet mask
- DNS server

---

## Notes

1. Unless otherwise specified, all functions return 0 on success and -1 on failure
1. Callers must use the buffer size specified in the documentation and check the return value
1. The default uplink must simultaneously satisfy interface enablement, link connectivity, a non-zero IP, and a non-zero gateway; the default LAN metric is 100, and the Wi-Fi STA metric is 600, so automatic mode prioritizes LAN
1. `/etc/resolv.conf` aggregates the DNS of all registered devices in the priority order of the current default device; it is automatically updated when devices are registered or unregistered, or when DNS changes
1. Network devices may be hot-swapped; the device list and the names corresponding to logical interfaces should be re-queried when needed
