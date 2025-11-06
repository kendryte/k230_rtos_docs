# Network Management HAL API

## Overview

The Network Management HAL provides a comprehensive interface for managing network connections, including Wi-Fi (STA and AP modes), LAN, and general network utilities. This document describes the available functions and their usage.

---

## Constants

### Network Interface Types

```c
enum rt_netif_t {
    RT_NET_DEV_WLAN_STA = 0,  // Wi-Fi Station mode
    RT_NET_DEV_WLAN_AP  = 1,  // Wi-Fi Access Point mode
    RT_NET_DEV_USB      = 2   // USB network interface
};
```

### Maximum Lengths

```c
#define RT_WLAN_SSID_MAX_LENGTH 32         // Maximum SSID length
#define RT_WLAN_PASSWORD_MAX_LENGTH 32     // Maximum password length
#define RT_WLAN_BSSID_MAX_LENGTH 6         // MAC address length
#define RT_WLAN_STA_SCAN_MAX_AP 64         // Maximum APs in scan results
#define NET_DEV_MAX_CNT 8                  // Maximum network devices
```

---

## Wi-Fi Station (STA) Functions

### Auto-Reconnect Management

#### `netmgmt_wlan_sta_get_auto_reconnect()`

**Purpose**: Get auto-reconnect status  
**Parameters**:

- `enable`: Pointer to store status (0 = disabled, 1 = enabled)  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_set_auto_reconnect()`

**Purpose**: Enable/disable auto-reconnect  
**Parameters**:

- `enable`: 0 to disable, 1 to enable  
**Returns**: 0 on success, -1 on failure  

---

### Connection Management

#### `netmgmt_wlan_sta_connect_with_ssid()`

**Purpose**: Connect to AP using SSID and password  
**Parameters**:

- `ssid`: Network SSID  
- `password`: Network password  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_connect_with_scan_info()`

**Purpose**: Connect to AP using scan info  
**Parameters**:

- `info`: Pointer to scan result info  
- `password`: Network password  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_disconnect_ap()`

**Purpose**: Disconnect from current AP  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_isconnected()`

**Purpose**: Check connection status  
**Parameters**:

- `status`: Pointer to store status (1 = connected, 0 = disconnected)  
**Returns**: 0 on success, -1 on failure  

---

### AP Information

#### `netmgmt_wlan_sta_get_ap_info()`

**Purpose**: Get connected AP information  
**Parameters**:

- `info`: Pointer to store AP info  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_get_rssi()`

**Purpose**: Get signal strength (RSSI)  
**Parameters**:

- `rssi`: Pointer to store RSSI value  
**Returns**: 0 on success, -1 on failure  

---

### Scanning

#### `netmgmt_wlan_sta_scan()`

**Purpose**: Scan for available APs  
**Parameters**:

- `ap_num`: Pointer to store number of found APs  
- `ap_infos`: Array to store AP information  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_scan_with_ssid()`

**Purpose**: Scan for specific SSID  
**Parameters**:

- `ssid`: SSID to search for  
- `ap_info`: Pointer to store found AP info  
**Returns**: 0 if found, -1 otherwise  

---

### MAC Address Management

#### `netmgmt_wlan_sta_get_mac()`

**Purpose**: Get STA MAC address  
**Parameters**:

- `mac`: Buffer to store MAC address  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_sta_set_mac()`

**Purpose**: Set STA MAC address  
**Parameters**:

- `mac`: MAC address to set  
**Returns**: 0 on success, -1 on failure  

---

## Wi-Fi Access Point (AP) Functions

### AP Management

#### `netmgmt_wlan_ap_start_with_ssid()`

**Purpose**: Start AP with SSID and password  
**Parameters**:

- `ssid`: AP SSID  
- `password`: AP password  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_start_with_info()`

**Purpose**: Start AP with configuration info  
**Parameters**:

- `info`: AP configuration  
- `password`: AP password  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_stop()`

**Purpose**: Stop AP  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_isactived()`

**Purpose**: Check if AP is active  
**Parameters**:

- `status`: Pointer to store status (1 = active, 0 = inactive)  
**Returns**: 0 on success, -1 on failure  

---

### AP Information

#### `netmgmt_wlan_ap_get_info()`

**Purpose**: Get AP configuration info  
**Parameters**:

- `info`: Pointer to store AP info  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_get_sta_info()`

**Purpose**: Get connected STA clients  
**Parameters**:

- `sta_num`: Pointer to store number of STAs  
- `sta_infos`: Array to store STA info  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_disconnect_sta()`

**Purpose**: Disconnect STA client  
**Parameters**:

- `mac`: MAC address of STA to disconnect  
**Returns**: 0 on success, -1 on failure  

---

### Country Code

#### `netmgmt_wlan_ap_get_country()`

**Purpose**: Get AP country code  
**Parameters**:

- `country`: Pointer to store country code  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_wlan_ap_set_country()`

**Purpose**: Set AP country code  
**Parameters**:

- `country`: Country code to set  
**Returns**: 0 on success, -1 on failure  

---

## LAN Functions

### Connection Status

#### `netmgmt_lan_get_isconnected()`

**Purpose**: Check if LAN is connected  
**Parameters**:

- `status`: Pointer to store status (1 = connected, 0 = disconnected)  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_lan_get_link_status()`

**Purpose**: Get LAN link status  
**Parameters**:

- `status`: Pointer to store status (1 = up, 0 = down)  
**Returns**: 0 on success, -1 on failure  

---

### MAC Address Management

#### `netmgmt_lan_get_mac()`

**Purpose**: Get LAN MAC address  
**Parameters**:

- `mac`: Buffer to store MAC address  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_lan_set_mac()`

**Purpose**: Set LAN MAC address  
**Parameters**:

- `mac`: MAC address to set  
**Returns**: 0 on success, -1 on failure  

---

## Network Utilities

### Device Management

#### `netmgmt_utils_get_defeault_dev()`

**Purpose**: Get default network device  
**Parameters**:

- `name`: Buffer to store device name  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_utils_set_defeault_dev()`

**Purpose**: Set default network device  
**Parameters**:

- `name`: Device name to set as default  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_utils_get_dev_list()`

**Purpose**: Get list of network devices  
**Parameters**:

- `dev_num`: Pointer to store number of devices  
- `names`: Array to store device names  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_utils_probe_device()`

**Purpose**: Probe network interface availability  
**Parameters**:

- `itf`: Interface type  
- `status`: Pointer to store probe result  
**Returns**: 0 on success, -1 on failure  

---

### IP Configuration

#### `netmgmt_utils_get_ifconfig()`

**Purpose**: Get interface IP configuration  
**Parameters**:

- `itf`: Interface type  
- `config`: Pointer to store IP config  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_utils_set_ifconfig_static()`

**Purpose**: Set static IP configuration  
**Parameters**:

- `itf`: Interface type  
- `config`: IP configuration to set  
**Returns**: 0 on success, -1 on failure  

#### `netmgmt_utils_set_ifconfig_dhcp()`

**Purpose**: Enable DHCP for interface  
**Parameters**:

- `itf`: Interface type  
**Returns**: 0 on success, -1 on failure  

---

## Data Structures

### `struct rt_wlan_info_t`

Contains Wi-Fi network information including:

- Security type
- Band (2.4GHz/5GHz)
- Data rate
- Channel
- RSSI (signal strength)
- SSID
- BSSID (MAC address)
- Hidden status

### `struct ifconfig_t`

Contains IP configuration including:

- IP address
- Gateway
- Netmask
- DNS server

---

## Notes

1. All functions return 0 on success and -1 on failure unless otherwise noted
1. Buffer sizes must be checked by caller to prevent overflow
1. Network operations may take time to complete - check status after delay if needed
