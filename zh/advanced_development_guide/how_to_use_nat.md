# IPv4 NAT 使用指南

## 功能说明

RT-Smart 提供基于 lwIP 的有状态 IPv4 NAPT，可让内部接口上的客户端通过系统
选择的上行接口访问外部网络。当前支持 TCP、UDP 和 ICMP Echo。典型场景是
Wi-Fi STA 连接上级路由器，同时由 Wi-Fi SoftAP 为终端提供 DHCP 和网络共享：

```text
SoftAP 客户端
    |
    | 192.168.169.0/24（默认）
    v
K230 SoftAP（内部接口） -> IPv4 NAPT -> 默认上行（WLAN STA 或 LAN）
```

NAT 使用实际路由结果选择外部接口，并将源地址改写为该外部接口的 IPv4 地址。
因此上行接口必须已取得非零 IP、网关和默认路由。默认路由切换后，新建会话可
使用新的上行接口；已有会话绑定原外部接口，切换网络时应允许应用重连。

## 编译配置

在 SDK 根目录加载目标板配置并执行：

```shell
make <board>_defconfig
make menuconfig
```

在 `light weight TCP/IP stack` 中确认以下配置：

```text
CONFIG_RT_USING_LWIP=y
CONFIG_RT_USING_WIFI=y
CONFIG_RT_LWIP_TCP=y
CONFIG_RT_LWIP_UDP=y
CONFIG_RT_LWIP_ICMP=y
CONFIG_LWIP_USING_DHCPD=y
CONFIG_DHCPD_USING_ROUTER=y
CONFIG_LWIP_USING_NAT=y
```

`LWIP_USING_NAT` 依赖 TCP 和 UDP；ICMP 选项用于支持 Echo 转换和 `ping` 验证。
启用 Wi-Fi 与 DHCP server 时，NAT 选项默认启用，但升级已有配置后仍应在最终
`.config` 中确认。`DHCPD_USING_ROUTER` 让 DHCP server 向 SoftAP 客户端下发
网关地址；默认 server 地址为 `192.168.169.1`，掩码为 `255.255.255.0`。

NAT 可与 lwIP 2.1.2 或 2.2.1 配合使用。网络栈版本的选择和验证见
[lwIP 2.2.1 使用指南](how_to_use_lwip.md)。

### 容量和超时

`LWIP_USING_NAT` 下的参数均在编译时确定：

| Kconfig 选项 | 默认值 | 作用 |
| --- | ---: | --- |
| `LWIP_NAT_TABLE_SIZE` | 256 | 最大 NAT 会话数 |
| `LWIP_NAT_MAX_INTERFACES` | 2 | 可启用 NAT 的内部接口数 |
| `LWIP_NAT_PORT_MIN` | 40000 | 转换源端口起始值 |
| `LWIP_NAT_PORT_MAX` | 45000 | 转换源端口结束值 |
| `LWIP_NAT_TCP_TIMEOUT_SECONDS` | 1800 | 已建立 TCP 会话空闲超时 |
| `LWIP_NAT_TCP_CLOSE_SECONDS` | 30 | 正在关闭的 TCP 会话超时 |
| `LWIP_NAT_UDP_TIMEOUT_SECONDS` | 120 | UDP 会话空闲超时 |
| `LWIP_NAT_ICMP_TIMEOUT_SECONDS` | 30 | ICMP Echo 会话空闲超时 |

会话表是静态分配的。表满时会复用最久未活动的表项；并发连接较多时，应根据
可用内存增大表项数，同时保证端口范围足够。

## SoftAP 自动启停

编译 `LWIP_USING_NAT` 后，RT-Thread WLAN 层会在 SoftAP 进入连接状态时自动把
其 lwIP netif 注册为内部接口，并在 SoftAP 停止或设备注销时关闭 NAT、清理涉及
该接口的会话。DHCP server 也随 SoftAP 启停。

先让 STA 或 LAN 上行取得地址和默认路由，再启动 SoftAP。例如：

```shell
wifi devices
wifi join <uplink-ssid> <uplink-password>
wifi ap <ap-ssid> <ap-password>
ifconfig
nat
```

多块 Wi-Fi 同时存在时，通过 `wifi devices` 找到目标管理设备，再使用
`wifi -i <管理设备或 netdev> ...` 选择接口。上行和 SoftAP 可以来自同一块支持
STA/AP 并发的射频，也可以来自不同网络设备。

`nat` 命令只显示状态，不修改配置。正常输出类似：

```text
internal interface: wlan0ap
NAT: enabled, sessions: 3/256 (TCP 2, UDP 1, ICMP 0)
```

NAT 会话属于转发状态，不是本机 socket，因此不会出现在 `netstat` 的本地 TCP、
UDP PCB 列表中。

## 为其他内部接口启用 NAT

WLAN SoftAP 已自动管理 NAT 生命周期。其他内部接口可在非 lwIP core 线程中调用
线程安全接口：

```c
#include <ipv4_nat.h>

err_t result;

result = ip_nat_set_enabled(internal_netif, 1);
if (result != ERR_OK) {
    /* 参数无效或内部接口槽位已满。 */
}

/* 接口停止或注销前关闭 NAT，并清理相关会话。 */
ip_nat_set_enabled(internal_netif, 0);
```

`internal_netif` 必须是有效的 `struct netif *`，并且其生命周期覆盖启用期间。该
接口只声明“内部侧”；外部侧仍由 lwIP 路由表选择。不要把上行接口也注册为内部
接口。

## 限制

- 只支持 IPv4，不提供 IPv6 NAT 或 NAT64；
- 只转换 TCP、UDP 和 ICMP Echo，不转换其他 IP 协议；
- 不支持 IPv4 分片、端口转发和 ICMP error payload 转换；
- 不接受没有现有会话匹配的外部入站连接；
- NAT 不是应用层代理，也不会修正协议负载中携带的 IP 地址或端口；
- NAT 不等同于完整防火墙，产品仍需在服务监听、访问控制和上行网络侧实施安全
  策略。

## 故障排查

1. `nat` 显示 `disabled`：确认最终配置包含 `CONFIG_LWIP_USING_NAT=y`，并确认
   SoftAP 已成功启动，而不是仅注册了 AP 设备。
1. 客户端拿不到地址或网关：确认 `LWIP_USING_DHCPD` 和
   `DHCPD_USING_ROUTER` 已启用，并检查 SoftAP netif 的 `192.168.169.1/24` 地址。
1. 客户端有地址但不能访问外网：先在 K230 本机检查上行 IP、网关、DNS 和默认
   路由，再确认上行接口不是 NAT 内部接口。
1. `ping` 可用但 TCP/UDP 不稳定：执行 `nat` 检查表项使用量，并核对端口范围和
   各协议超时是否适合并发量。
1. 大包或部分协议失败：抓包检查 IPv4 分片或负载内嵌地址；这些场景不在当前
   NAT 支持范围内。

## 源码位置

- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/lwip_nat/`
- `src/rtsmart/rtsmart/kernel/rt-thread/components/drivers/wlan/wlan_lwip.c`
- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/lwip_dhcpd/`
