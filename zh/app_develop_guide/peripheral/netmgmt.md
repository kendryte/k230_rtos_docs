# NetMgmt 示例

## 简介

本示例是网络管理 HAL 的综合测试，覆盖 WLAN STA、WLAN AP、LAN、默认网卡与 IP 配置接口。

源码位置：`src/rtsmart/examples/peripheral/netmgmt/test_netmgmt.c`

## 示例行为

- UTILS：默认网卡、设备探测、ifconfig、设备列表
- WLAN STA：自动重连、连接/断开、扫描、RSSI、MAC、AP 信息
- WLAN AP：启动/停止、激活状态、国家码、连接 STA 管理
- LAN：链路状态、MAC、静态 IP、DHCP 切换

示例中测试 SSID/密码为源码内宏（`TEST_SSID`/`TEST_PASSWORD`），实际使用请按现场网络修改源码。

## 关键接口

- `netmgmt_utils_*`
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

```{admonition} 提示
接口说明与参数定义请参考 [NetMgmt API 文档](../../api_reference/peripheral/netmgmt.md)。
```
