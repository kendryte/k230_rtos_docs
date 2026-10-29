# lwIP 2.2.1 使用指南

## 版本支持

RT-Smart 网络组件同时支持 lwIP 2.1.2 和 lwIP 2.2.1。当前默认版本仍为
lwIP 2.1.2；需要使用 2.2.1 时，应在构建配置中显式选择。两个版本共用
RT-Thread netdev、SAL socket、WLAN、DHCP server 和 IPv4 NAT 等上层组件，应用
通常不需要绕过 SAL 直接依赖某个 lwIP 版本。

```{note}
lwIP 2.2.1 与 IPv4 NAT 是两个独立选项。NAT 同时支持当前的 2.1.2 和 2.2.1，
不需要为了使用 NAT 强制切换网络栈版本。
```

## 选择 lwIP 2.2.1

先在 SDK 根目录加载目标板配置，再打开配置界面：

```shell
make <board>_defconfig
make menuconfig
```

进入 `light weight TCP/IP stack`，在 `lwIP version` 中选择 `lwIP v2.2.1`。
也可以在配置界面中搜索 `RT_USING_LWIP221`。保存后，配置应包含：

```text
CONFIG_RT_USING_LWIP=y
# CONFIG_RT_USING_LWIP212 is not set
CONFIG_RT_USING_LWIP221=y
```

然后按正常流程重新编译固件。lwIP 版本选择是互斥项，不要同时写入
`CONFIG_RT_USING_LWIP212=y` 和 `CONFIG_RT_USING_LWIP221=y`。

## RT-Smart 适配内容

SDK 中的 lwIP 2.2.1 基于 `STABLE-2_2_1_RELEASE`，并完成了以下 RT-Smart
适配：

- SAL socket 和 POSIX `poll` 使用 lwIP 2.2.x 的 netconn socket 状态布局；
- netdev 同步 IPv4 地址、网关、掩码、管理状态、链路状态和 IPv6 地址变化；
- DHCP 使用 lwIP 2.2 的 RFC 5227 地址冲突检测；
- 内存分配改用 lwIP 2.2 的 `MEM_CUSTOM_ALLOCATOR` 接口连接 RT-Thread heap；
- 保留全局 DNS 接口，并让 DHCPv4、DHCPv6、RDNSS、PPP 和手动 DNS 配置按
  netdev 同步；只有默认接口更新全局 resolver；
- `SO_SNDBUF` 返回固定的 `TCP_SND_BUF` 容量，并支持查询 `TCP_MAXSEG`。

应用继续使用 POSIX socket 或 SAL 接口即可。直接包含 lwIP 私有头文件、访问
`struct netconn` 或 `struct lwip_sock` 内部字段的代码不具备跨版本兼容性，切换到
2.2.1 前应改用公开 API。

## 运行确认

启动日志会直接打印实际版本。选择成功时可看到类似输出：

```text
lwIP-2.2.1 initialized!
Socket Abstraction Layer initialize success, lwIP 2.2.1.
```

随后使用实际存在的网络接口验证地址、默认路由、DNS 和基本 socket 通信：

```shell
ifconfig
ping <gateway-address>
```

多网卡系统的接口名由探测顺序动态分配。先执行 `wifi devices` 或通过 NetMgmt
查询接口，不要把 `wlan0`、`wlan0ap` 或 `eth0` 写死在应用中。默认路由的选择
规则见 [NetMgmt 示例](../app_develop_guide/peripheral/netmgmt.md)。

## 切换版本时的检查项

1. 清理并重新编译依赖 lwIP 头文件的内核组件和应用，避免混用旧版本对象文件。
1. 确认 SAL 初始化日志显示 2.2.1；只检查 defconfig 不能证明运行镜像已更新。
1. 对使用 `poll`、非阻塞 `connect`、`SO_SNDBUF` 或 `TCP_MAXSEG` 的应用执行回归
   测试。
1. 多网卡场景同时验证地址、网关、DNS、链路切换和默认路由。
1. 需要 SoftAP 共享上行网络时，继续按
   [IPv4 NAT 使用指南](how_to_use_nat.md) 配置和验证。

## 源码位置

- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/lwip-2.2.1/`
- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/sal_socket/`
- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/netdev/`
