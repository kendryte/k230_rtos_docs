# lwIP 2.2.1 Usage Guide

## Version Support

The RT-Smart network component supports both lwIP 2.1.2 and lwIP 2.2.1. The current default version remains
lwIP 2.1.2; when 2.2.1 is needed, it should be explicitly selected in the build configuration. Both versions share
upper-layer components such as RT-Thread netdev, SAL socket, WLAN, DHCP server, and IPv4 NAT, so applications
usually do not need to bypass SAL and depend directly on a specific lwIP version.

```{note}
lwIP 2.2.1 and IPv4 NAT are two independent options. NAT supports both the current 2.1.2 and 2.2.1,
and there is no need to force a network stack version switch to use NAT.
```

## Selecting lwIP 2.2.1

First, load the target board configuration in the SDK root directory, and then open the configuration interface:

```shell
make <board>_defconfig
make menuconfig
```

Enter `light weight TCP/IP stack` and select `lwIP v2.2.1` under `lwIP version`.
You can also search for `RT_USING_LWIP221` in the configuration interface. After saving, the configuration should contain:

```text
CONFIG_RT_USING_LWIP=y
# CONFIG_RT_USING_LWIP212 is not set
CONFIG_RT_USING_LWIP221=y
```

Then rebuild the firmware using the normal process. lwIP version selection is mutually exclusive; do not write both
`CONFIG_RT_USING_LWIP212=y` and `CONFIG_RT_USING_LWIP221=y` at the same time.

## RT-Smart Adaptation

The lwIP 2.2.1 in the SDK is based on `STABLE-2_2_1_RELEASE`, and the following RT-Smart adaptations have been
completed:

- SAL socket and POSIX `poll` use the netconn socket state layout from lwIP 2.2.x;
- netdev synchronizes changes to IPv4 addresses, gateways, masks, administrative status, link status, and IPv6 addresses;
- DHCP uses the RFC 5227 address conflict detection from lwIP 2.2;
- Memory allocation now uses the lwIP 2.2 `MEM_CUSTOM_ALLOCATOR` interface to connect to the RT-Thread heap;
- The global DNS interface is retained, and DHCPv4, DHCPv6, RDNSS, PPP, and manual DNS configurations are synchronized
  according to netdev; only the default interface updates the global resolver;
- `SO_SNDBUF` returns the fixed `TCP_SND_BUF` capacity and supports querying `TCP_MAXSEG`.

Applications can continue using POSIX sockets or the SAL interface. Code that directly includes private lwIP headers or accesses
internal fields of `struct netconn` or `struct lwip_sock` is not cross-version compatible and should be changed to use public APIs
before switching to 2.2.1.

## Runtime Verification

The startup log directly prints the actual version. When the selection succeeds, output similar to the following can be seen:

```text
lwIP-2.2.1 initialized!
Socket Abstraction Layer initialize success, lwIP 2.2.1.
```

Then use an actually existing network interface to verify addresses, the default route, DNS, and basic socket communication:

```shell
ifconfig
ping <gateway-address>
```

Interface names in multi-NIC systems are dynamically assigned according to the probing order. First run `wifi devices` or query
interfaces through NetMgmt; do not hard-code `wlan0`, `wlan0ap`, or `eth0` in applications. For the default route selection
rules, see [NetMgmt Examples](../app_develop_guide/peripheral/netmgmt.md).

## Checklist When Switching Versions

1. Clean and rebuild kernel components and applications that depend on lwIP headers to avoid mixing object files from old versions.
1. Confirm that the SAL initialization log shows 2.2.1; checking defconfig alone cannot prove that the runtime image has been updated.
1. Perform regression testing on applications that use `poll`, non-blocking `connect`, `SO_SNDBUF`, or `TCP_MAXSEG`.
1. In multi-NIC scenarios, simultaneously verify addresses, gateways, DNS, link switching, and the default route.
1. When SoftAP sharing of an upstream network is needed, continue to configure and verify it according to
   [IPv4 NAT Usage Guide](how_to_use_nat.md).

## Source Locations

- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/lwip-2.2.1/`
- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/sal_socket/`
- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/netdev/`
