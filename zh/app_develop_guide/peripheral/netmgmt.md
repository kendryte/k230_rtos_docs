# NetMgmt 示例

## 简介

本示例是网络管理 HAL 的综合测试，覆盖 WLAN STA、WLAN AP、LAN、物理 Wi-Fi
选择、动态设备名、默认网卡与 IP 配置接口。

源码位置：`src/rtsmart/examples/peripheral/netmgmt/test_netmgmt.c`

## 示例行为

- UTILS：默认网卡、逻辑接口名称解析、设备探测、ifconfig、设备列表
- WLAN STA：自动重连、连接/断开、扫描、RSSI、MAC、AP 信息
- WLAN AP：启动/停止、激活状态、国家码、连接 STA 管理
- LAN：链路状态、MAC、静态 IP、DHCP 切换

示例中测试 SSID/密码为源码内宏（`TEST_SSID`/`TEST_PASSWORD`），实际使用请按现场网络修改源码。

## 关键接口

- `netmgmt_utils_*`
- `netmgmt_wlan_select_device()`
- `netmgmt_wlan_sta_*`
- `netmgmt_wlan_ap_*`
- `netmgmt_lan_*`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/netmgmt
make
./test_netmgmt
```

该示例无命令行参数。

## 多网卡使用要点

驱动会自动注册 WLAN 与 USB LAN 设备。应用先使用
`netmgmt_utils_get_dev_list()` 查看当前设备；需要将逻辑接口与实际名称关联时，
调用 `netmgmt_utils_get_netdev_name()`，不要写死 `eth0` 或 `wlan0`。

多块 Wi-Fi 同时存在时，可在角色操作前选择物理设备：

```c
char name[32];

if (netmgmt_wlan_select_device(NETMGMT_WLAN_DEVICE_USB,
                               RT_NET_DEV_WLAN_STA) != 0) {
    /* USB Wi-Fi 当前不可用 */
}
if (netmgmt_utils_get_netdev_name(RT_NET_DEV_WLAN_STA, name) == 0) {
    printf("selected STA netdev: %s\n", name);
}
```

如果不要求固定硬件，使用 `NETMGMT_WLAN_DEVICE_AUTO`。自动选择可在设备移除后
切换到同角色的其他 Wi-Fi 设备。

## 默认路由

```c
/* 将当前逻辑 LAN 对应设备设为首选上行。 */
char name[32];
if (netmgmt_utils_get_netdev_name(RT_NET_DEV_LAN, name) == 0) {
    netmgmt_utils_set_default_dev(name);
}

/* 清除人工首选，恢复自动选择。 */
netmgmt_utils_set_default_dev(NULL);
```

系统仅从已启用、链路已连接并取得非零 IP 与网关的 LAN/WLAN STA 中选择默认
路由。自动模式按 metric 选择，LAN 默认优先于 Wi-Fi STA。首选设备断开时会
临时切换到其他已就绪接口，恢复后再切回。

默认路由也是 IPv4 NAT 的上行选择依据。SoftAP 网络共享的编译选项、自动启停
和会话检查见 [IPv4 NAT 使用指南](../../advanced_development_guide/how_to_use_nat.md)。

```{admonition} 提示
接口说明与参数定义请参考 [NetMgmt API 文档](../../api_reference/peripheral/netmgmt.md)。
```
