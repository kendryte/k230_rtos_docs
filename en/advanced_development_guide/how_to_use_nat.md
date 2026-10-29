# IPv4 NAT User Guide

## Description

RT-Smart provides stateful IPv4 NAPT based on lwIP, allowing clients on internal
interfaces to access external networks through the uplink interface selected by
the system. TCP, UDP, and ICMP Echo are currently supported. A typical scenario
has a Wi-Fi STA connected to an upstream router while a Wi-Fi SoftAP provides
DHCP and network sharing for terminals:

```text
SoftAP client
    |
    | 192.168.169.0/24 (default)
    v
K230 SoftAP (internal interface) -> IPv4 NAPT -> default uplink (WLAN STA or LAN)
```

NAT uses the actual routing result to select the external interface and rewrites
the source address to the IPv4 address of that external interface. Therefore,
the uplink interface must have acquired a non-zero IP address, gateway, and
default route. After the default route changes, new sessions may use the new
uplink interface; existing sessions remain bound to the original external
interface, and applications should be allowed to reconnect when switching
networks.

## Build Configuration

Load the target board configuration in the SDK root directory and run:

```shell
make <board>_defconfig
make menuconfig
```

Confirm the following configurations under `light weight TCP/IP stack`:

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

`LWIP_USING_NAT` depends on TCP and UDP; the ICMP option is used to support Echo
translation and `ping` verification. When Wi-Fi and the DHCP server are enabled,
the NAT option is enabled by default, but it should still be confirmed in the
final `.config` after upgrading an existing configuration. `DHCPD_USING_ROUTER`
makes the DHCP server deliver the gateway address to SoftAP clients; the default
server address is `192.168.169.1`, and the subnet mask is `255.255.255.0`.

NAT can be used with lwIP 2.1.2 or 2.2.1. For information on selecting and
verifying the network stack version, see the
[lwIP 2.2.1 User Guide](how_to_use_lwip.md).

### Capacity and Timeouts

The parameters under `LWIP_USING_NAT` are determined at build time:

| Kconfig Option | Default | Description |
| --- | ---: | --- |
| `LWIP_NAT_TABLE_SIZE` | 256 | Maximum number of NAT sessions |
| `LWIP_NAT_MAX_INTERFACES` | 2 | Number of internal interfaces on which NAT can be enabled |
| `LWIP_NAT_PORT_MIN` | 40000 | Starting value of the translated source port |
| `LWIP_NAT_PORT_MAX` | 45000 | Ending value of the translated source port |
| `LWIP_NAT_TCP_TIMEOUT_SECONDS` | 1800 | Idle timeout for established TCP sessions |
| `LWIP_NAT_TCP_CLOSE_SECONDS` | 30 | Timeout for closing TCP sessions |
| `LWIP_NAT_UDP_TIMEOUT_SECONDS` | 120 | Idle timeout for UDP sessions |
| `LWIP_NAT_ICMP_TIMEOUT_SECONDS` | 30 | Idle timeout for ICMP Echo sessions |

The session table is statically allocated. When the table is full, the least
recently active entry is reused; when there are many concurrent connections,
the number of entries should be increased according to available memory while
ensuring that the port range is sufficient.

## SoftAP Automatic Start/Stop

After compiling `LWIP_USING_NAT`, the RT-Thread WLAN layer automatically registers
its lwIP netif as an internal interface when SoftAP enters the connected state, and disables NAT and cleans up sessions involving
that interface when SoftAP stops or the device is deregistered. The DHCP server also starts and stops with SoftAP.

First, allow STA or the LAN uplink to obtain an address and default route, and then start SoftAP. For example:

```shell
wifi devices
wifi join <uplink-ssid> <uplink-password>
wifi ap <ap-ssid> <ap-password>
ifconfig
nat
```

When multiple Wi-Fi devices are present, use `wifi devices` to find the target management device, and then use
`wifi -i <管理设备或 netdev> ...` to select the interface. The uplink and SoftAP can come from the same radio supporting
concurrent STA/AP operation, or from different network devices.

The `nat` command only displays status and does not modify the configuration. Typical output is similar to:

```text
internal interface: wlan0ap
NAT: enabled, sessions: 3/256 (TCP 2, UDP 1, ICMP 0)
```

NAT sessions belong to the forwarding state rather than local sockets, so they do not appear in the local TCP or
UDP PCB lists in `netstat`.

## Enabling NAT for Other Internal Interfaces

The WLAN SoftAP automatically manages the NAT lifecycle. Other internal interfaces can call the
thread-safe interface in a non-lwIP core thread:

```c
#include <ipv4_nat.h>

err_t result;

result = ip_nat_set_enabled(internal_netif, 1);
if (result != ERR_OK) {
    /* Invalid argument or no internal interface slots remaining. */
}

/* Disable NAT before the interface stops or is deregistered, and clean up related sessions. */
ip_nat_set_enabled(internal_netif, 0);
```

`internal_netif` must be a valid `struct netif *`, and its lifetime must cover the enabled period. This
interface only declares the “internal side”; the external side is still selected by the lwIP routing table. Do not register the uplink interface as an internal
interface as well.

## Limitations

- Only IPv4 is supported; IPv6 NAT and NAT64 are not provided;
- Only TCP, UDP, and ICMP Echo are translated; other IP protocols are not translated;
- IPv4 fragmentation, port forwarding, and ICMP error payload conversion are not supported;
- External inbound connections without a matching existing session are not accepted;
- NAT is not an application-layer proxy and does not correct IP addresses or ports carried in protocol payloads;
- NAT is not equivalent to a full firewall, and products still need to implement security policies in service listening, access control, and the uplink network side.

## Troubleshooting

1. `nat` shows `disabled`: Confirm that the final configuration contains `CONFIG_LWIP_USING_NAT=y`, and confirm
   that SoftAP has started successfully rather than merely having the AP device registered.
1. The client cannot obtain an address or gateway: Confirm that `LWIP_USING_DHCPD` and
   `DHCPD_USING_ROUTER` are enabled, and check the `192.168.169.1/24` address of the SoftAP netif.
1. The client has an address but cannot access the Internet: First check the uplink IP, gateway, DNS, and default
   route on the K230 itself, and then confirm that the uplink interface is not a NAT internal interface.
1. `ping` works, but TCP/UDP is unstable: Run `nat` to check table entry usage, and verify that the port ranges and
   per-protocol timeouts are suitable for the concurrency level.
1. Large packets or some protocols fail: Capture packets to check for IPv4 fragmentation or addresses embedded in payloads; these scenarios are outside the current
   NAT support scope.

## Source Locations

- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/lwip_nat/`
- `src/rtsmart/rtsmart/kernel/rt-thread/components/drivers/wlan/wlan_lwip.c`
- `src/rtsmart/rtsmart/kernel/rt-thread/components/net/lwip_dhcpd/`
