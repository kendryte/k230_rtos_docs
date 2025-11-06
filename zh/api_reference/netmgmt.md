# K230 NetMgmt API 参考

## 概述

网络管理HAL提供了全面的网络连接管理接口，包括Wi-Fi(STA和AP模式)、LAN和通用网络工具。本文档描述了可用功能及其使用方法。

---

## 常量定义

### 网络接口类型

```c
enum rt_netif_t {
    RT_NET_DEV_WLAN_STA = 0,  // Wi-Fi站点模式
    RT_NET_DEV_WLAN_AP  = 1,  // Wi-Fi接入点模式
    RT_NET_DEV_USB      = 2   // USB网络接口
};
```

### 最大长度限制

```c
#define RT_WLAN_SSID_MAX_LENGTH 32         // SSID最大长度
#define RT_WLAN_PASSWORD_MAX_LENGTH 32     // 密码最大长度
#define RT_WLAN_BSSID_MAX_LENGTH 6         // MAC地址长度
#define RT_WLAN_STA_SCAN_MAX_AP 64         // 扫描结果中AP最大数量
#define NET_DEV_MAX_CNT 8                  // 最大网络设备数量
```

---

## Wi-Fi STA功能

### 自动重连管理

#### `netmgmt_wlan_sta_get_auto_reconnect()`

**功能**: 获取自动重连状态  
**参数**:

- `enable`: 存储状态的指针(0=禁用，1=启用)  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_sta_set_auto_reconnect()`

**功能**: 启用/禁用自动重连  
**参数**:

- `enable`: 0禁用，1启用  
**返回值**: 成功返回0，失败返回-1  

---

### 连接管理

#### `netmgmt_wlan_sta_connect_with_ssid()`

**功能**: 使用SSID和密码连接AP  
**参数**:

- `ssid`: 网络SSID  
- `password`: 网络密码  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_sta_connect_with_scan_info()`

**功能**: 使用扫描信息连接AP  
**参数**:

- `info`: 扫描结果信息指针  
- `password`: 网络密码  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_sta_disconnect_ap()`

**功能**: 断开当前AP连接  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_sta_isconnected()`

**功能**: 检查连接状态  
**参数**:

- `status`: 存储状态的指针(1=已连接，0=未连接)  
**返回值**: 成功返回0，失败返回-1  

---

### AP信息获取

#### `netmgmt_wlan_sta_get_ap_info()`

**功能**: 获取已连接AP的信息  
**参数**:

- `info`: 存储AP信息的指针  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_sta_get_rssi()`

**功能**: 获取信号强度(RSSI)  
**参数**:

- `rssi`: 存储RSSI值的指针  
**返回值**: 成功返回0，失败返回-1  

---

### 扫描功能

#### `netmgmt_wlan_sta_scan()`

**功能**: 扫描可用AP  
**参数**:

- `ap_num`: 存储发现AP数量的指针  
- `ap_infos`: 存储AP信息的数组  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_sta_scan_with_ssid()`

**功能**: 扫描特定SSID  
**参数**:

- `ssid`: 要搜索的SSID  
- `ap_info`: 存储找到的AP信息的指针  
**返回值**: 找到返回0，否则返回-1  

---

### MAC地址管理

#### `netmgmt_wlan_sta_get_mac()`

**功能**: 获取STA MAC地址  
**参数**:

- `mac`: 存储MAC地址的缓冲区  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_sta_set_mac()`

**功能**: 设置STA MAC地址  
**参数**:

- `mac`: 要设置的MAC地址  
**返回值**: 成功返回0，失败返回-1  

---

## Wi-Fi AP功能

### AP管理

#### `netmgmt_wlan_ap_start_with_ssid()`

**功能**: 使用SSID和密码启动AP  
**参数**:

- `ssid`: AP的SSID  
- `password`: AP密码  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_ap_start_with_info()`

**功能**: 使用配置信息启动AP  
**参数**:

- `info`: AP配置  
- `password`: AP密码  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_ap_stop()`

**功能**: 停止AP  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_ap_isactived()`

**功能**: 检查AP是否活跃  
**参数**:

- `status`: 存储状态的指针(1=活跃，0=不活跃)  
**返回值**: 成功返回0，失败返回-1  

---

### AP信息获取

#### `netmgmt_wlan_ap_get_info()`

**功能**: 获取AP配置信息  
**参数**:

- `info`: 存储AP信息的指针  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_ap_get_sta_info()`

**功能**: 获取连接的STA客户端  
**参数**:

- `sta_num`: 存储STA数量的指针  
- `sta_infos`: 存储STA信息的数组  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_ap_disconnect_sta()`

**功能**: 断开STA客户端  
**参数**:

- `mac`: 要断开STA的MAC地址  
**返回值**: 成功返回0，失败返回-1  

---

### 国家代码设置

#### `netmgmt_wlan_ap_get_country()`

**功能**: 获取AP国家代码  
**参数**:

- `country`: 存储国家代码的指针  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_wlan_ap_set_country()`

**功能**: 设置AP国家代码  
**参数**:

- `country`: 要设置的国家代码  
**返回值**: 成功返回0，失败返回-1  

---

## LAN功能

### 连接状态

#### `netmgmt_lan_get_isconnected()`

**功能**: 检查LAN是否连接  
**参数**:

- `status`: 存储状态的指针(1=已连接，0=未连接)  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_lan_get_link_status()`

**功能**: 获取LAN链路状态  
**参数**:

- `status`: 存储状态的指针(1=链路up，0=链路down)  
**返回值**: 成功返回0，失败返回-1  

---

### MAC地址管理

#### `netmgmt_lan_get_mac()`

**功能**: 获取LAN MAC地址  
**参数**:

- `mac`: 存储MAC地址的缓冲区  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_lan_set_mac()`

**功能**: 设置LAN MAC地址  
**参数**:

- `mac`: 要设置的MAC地址  
**返回值**: 成功返回0，失败返回-1  

---

## 网络工具

### 设备管理

#### `netmgmt_utils_get_defeault_dev()`

**功能**: 获取默认网络设备  
**参数**:

- `name`: 存储设备名称的缓冲区  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_utils_set_defeault_dev()`

**功能**: 设置默认网络设备  
**参数**:

- `name`: 要设置为默认设备的名称  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_utils_get_dev_list()`

**功能**: 获取网络设备列表  
**参数**:

- `dev_num`: 存储设备数量的指针  
- `names`: 存储设备名称的数组  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_utils_probe_device()`

**功能**: 探测网络接口可用性  
**参数**:

- `itf`: 接口类型  
- `status`: 存储探测结果的指针  
**返回值**: 成功返回0，失败返回-1  

---

### IP配置

#### `netmgmt_utils_get_ifconfig()`

**功能**: 获取接口IP配置  
**参数**:

- `itf`: 接口类型  
- `config`: 存储IP配置的指针  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_utils_set_ifconfig_static()`

**功能**: 设置静态IP配置  
**参数**:

- `itf`: 接口类型  
- `config`: 要设置的IP配置  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_utils_set_ifconfig_dhcp()`

**功能**: 为接口启用DHCP  
**参数**:

- `itf`: 接口类型  
**返回值**: 成功返回0，失败返回-1  

---

## 数据结构

### `struct rt_wlan_info_t`

包含Wi-Fi网络信息，包括:

- 安全类型
- 频段(2.4GHz/5GHz)
- 数据速率
- 信道
- RSSI(信号强度)
- SSID
- BSSID(MAC地址)
- 隐藏状态

### `struct ifconfig_t`

包含IP配置信息，包括:

- IP地址
- 网关
- 子网掩码
- DNS服务器

---

## 注意事项

1. 除非另有说明，所有函数成功返回0，失败返回-1
1. 调用者必须检查缓冲区大小以防止溢出
1. 网络操作可能需要时间完成 - 如果需要，延迟后检查状态
