# K230 NetMgmt API 参考

## 概述

网络管理 HAL 提供 Wi-Fi（STA 和 AP 模式）、LAN、网络设备发现与默认路由管理
接口。网卡由驱动自动注册，应用通过逻辑接口或动态设备名访问，不应依赖固定的
硬件设备名。

---

## 常量定义

### 网络接口类型

```c
enum rt_netif_t {
    RT_NET_DEV_WLAN_STA = 0,  // Wi-Fi 站点模式
    RT_NET_DEV_WLAN_AP  = 1,  // Wi-Fi 接入点模式
    RT_NET_DEV_LAN      = 2,  // 通用 LAN（RTL8152/ECM/NCM）

    // 兼容旧源码，均等价于 RT_NET_DEV_LAN
    RT_NET_DEV_USB_RTL8152 = RT_NET_DEV_LAN,
    RT_NET_DEV_USB_ECM     = RT_NET_DEV_LAN,
    RT_NET_DEV_USB_NCM     = RT_NET_DEV_LAN,
};
```

### WLAN 物理设备类型

```c
enum netmgmt_wlan_device {
    NETMGMT_WLAN_DEVICE_AUTO = 0,
    NETMGMT_WLAN_DEVICE_USB,
    NETMGMT_WLAN_DEVICE_SDIO,
    NETMGMT_WLAN_DEVICE_SPI,
};
```

`AUTO` 优先保持当前角色已选择的设备；需要重新选择时，按 SDIO、SPI、USB、
未知传输类型的顺序查找。仅在应用必须固定物理连接方式时显式指定类型。

### 最大长度限制

```c
#define RT_WLAN_SSID_MAX_LENGTH 32         // SSID最大长度
#define RT_WLAN_PASSWORD_MAX_LENGTH 64     // 密码最大长度
#define RT_WLAN_BSSID_MAX_LENGTH 6         // MAC地址长度
#define RT_WLAN_STA_SCAN_MAX_AP 64         // 扫描结果中AP最大数量
#define NET_DEV_MAX_CNT 8                  // 最大网络设备数量
```

---

## Wi-Fi STA功能

### 物理设备选择

#### `netmgmt_wlan_select_device()`

**功能**：选择后续角色接口所使用的物理 WLAN 设备。
**参数**：

- `device`：`NETMGMT_WLAN_DEVICE_AUTO`、`USB`、`SDIO` 或 `SPI`；
- `itf`：`RT_NET_DEV_WLAN_STA` 或 `RT_NET_DEV_WLAN_AP`。

**返回值**：成功返回 0，所选设备不可用或参数无效时返回 -1。

选择会影响后续所有基于 STA/AP 角色的 `netmgmt_wlan_*` 和 `netmgmt_utils_*`
调用。在多 Wi-Fi 设备环境中，先选择物理设备，再执行连接、扫描或 IP 配置。

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

- `itf`: 使用 `RT_NET_DEV_LAN`
- `status`: 存储状态的指针(1=链路已连接且已有有效 IP，0=未连接)
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_lan_get_link_status()`

**功能**: 获取LAN链路状态  
**参数**:

- `itf`: 使用 `RT_NET_DEV_LAN`
- `status`: 存储链路状态的指针
**返回值**: 成功返回0，失败返回-1  

---

### MAC地址管理

#### `netmgmt_lan_get_mac()`

**功能**: 获取LAN MAC地址  
**参数**:

- `itf`: 使用 `RT_NET_DEV_LAN`
- `mac`: 存储MAC地址的缓冲区  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_lan_set_mac()`

**功能**: 设置LAN MAC地址  
**参数**:

- `itf`: 使用 `RT_NET_DEV_LAN`
- `mac`: 要设置的MAC地址  
**返回值**: 成功返回0，失败返回-1  

---

## 网络工具

### 设备管理

#### `netmgmt_utils_get_default_dev()`

**功能**: 获取当前实际生效的默认网络设备
**参数**:

- `name`: 存储设备名称的 32 字节缓冲区；当前没有可用默认上行时得到空字符串
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_utils_set_default_dev()`

**功能**: 设置首选默认上行设备
**参数**:

- `name`: `netmgmt_utils_get_dev_list()` 返回的完整设备名；传入 `NULL` 清除首选
  设备并恢复自动选择
**返回值**: 成功返回0，失败返回-1  

只有 LAN 与 Wi-Fi STA 可以作为默认上行，Wi-Fi AP 和未知类型设备会被拒绝。
设置首选设备不关闭自动故障转移：首选设备未就绪时系统选择其他可用上行，首选
设备恢复后自动切回。

旧拼写 `netmgmt_utils_get_defeault_dev()` 和
`netmgmt_utils_set_defeault_dev()` 仍保留为已弃用别名，新代码应使用正确拼写。

#### `netmgmt_utils_get_dev_list()`

**功能**: 获取网络设备列表  
**参数**:

- `dev_num`: 存储设备数量的指针  
- `names`: 存储设备名称的数组  
**返回值**: 成功返回0，失败返回-1  

设备名是动态分配的完整名称。USB LAN 通常为 `eth0` 到 `eth9`；WLAN STA/AP
通常为 `wlanN`/`wlanNap`，其中 `N` 表示物理射频编号。不要把这些示例名称写死
在应用中。

#### `netmgmt_utils_probe_device()`

**功能**: 探测网络接口可用性  
**参数**:

- `itf`: 接口类型  
- `status`: 存储探测结果的指针  
**返回值**: 成功返回0，失败返回-1  

#### `netmgmt_utils_get_netdev_name()`

**功能**：将逻辑接口解析为当前 netdev 名称。
**参数**：

- `itf`：`RT_NET_DEV_WLAN_STA`、`RT_NET_DEV_WLAN_AP` 或
  `RT_NET_DEV_LAN`；
- `name`：存储名称的 32 字节缓冲区。

**返回值**：成功返回 0，接口当前不可用时返回 -1。

对于 WLAN，该接口返回由最近一次 `netmgmt_wlan_select_device()` 选择的设备；
未选择时会尝试自动选择。

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
1. 调用者必须使用文档规定的缓冲区大小并检查返回值
1. 默认上行必须同时满足接口启用、链路连接、非零 IP 和非零网关；默认 LAN
   metric 为 100，Wi-Fi STA 为 600，因此自动模式优先 LAN
1. `/etc/resolv.conf` 会按当前默认设备优先的顺序汇总所有已注册设备的 DNS；
   设备注册、注销或 DNS 变化时自动更新
1. 网络设备可能热插拔，设备列表和逻辑接口对应的名称应在需要时重新查询
