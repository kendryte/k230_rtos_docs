# WLAN Offload 控制示例

## 概述

WLAN offload 框架用于固件负责 802.11 MAC 的 Wi-Fi 设备。RT-Thread WLAN、
NetMgmt 和 lwIP 仍是普通应用接口；`libwlan_offload` 则提供版本化的用户态控制
接口，适用于能力诊断、事件监控和完整 supplicant 集成。

相关源码：

```text
src/rtsmart/rtsmart/kernel/rt-thread/components/drivers/wlan/offload/
src/rtsmart/libs/wlan_offload/
src/rtsmart/examples/peripheral/wlan_offload/
```

支持该框架的驱动可注册：

- `phyN-sta` 和 `phyN-ap`：RT-Thread WLAN 管理设备；
- `wlanN` 和 `wlanNap`：lwIP 网络接口；
- `/dev/wlanctlN`：可选的用户态控制设备。

`N` 由射频注册顺序决定。应用应查询名称，不应假设目标设备始终是
`/dev/wlanctl0`。

## 配置和构建

支持 offload 的 vendor 驱动会选择所需的内核选项。手工集成时相关选项为：

| 配置项 | 作用 |
| :-- | :-- |
| `RT_WLAN_OFFLOAD` | 通用 radio、VIF、命令、事件和 transport 框架 |
| `RT_WLAN_OFFLOAD_CONTROL` | 注册 `/dev/wlanctlN` 控制设备 |
| `RT_WLAN_OFFLOAD_SUPPLICANT` | 启用外部 supplicant 契约 |
| `RT_WLAN_OFFLOAD_EMBEDDED_WPA2` | 内核 WPA/WPA2/WPA3 Personal 路径 |
| `RT_WLAN_OFFLOAD_EMBEDDED_HOSTAPD` | 开放/WPA2-Personal SoftAP authenticator |

在用户态示例配置中启用：

```text
RTSMART_ENABLE_PERIPHERAL_EXAMPLES=y
RTSMART_PERIPHERAL_ENABLE_WLAN_OFFLOAD=y
```

完整构建会生成 `wlan_offload.elf`。也可以单独构建库：

```shell
make -C src/rtsmart/libs/wlan_offload
```

应用只包含安装后的 `wlan_offload_client.h`。不要包含私有的
`wlan_offload_wire.h` 或内核 `wlan_offload_control_protocol.h`。

## 示例命令

先用 RT-Smart shell 查看实际设备：

```shell
wifi devices
```

再运行诊断程序：

```shell
wlan_offload.elf /dev/wlanctl0 names
wlan_offload.elf /dev/wlanctl0 info
wlan_offload.elf /dev/wlanctl0 probe
wlan_offload.elf /dev/wlanctl0 scan
wlan_offload.elf /dev/wlanctl0 monitor
```

只连接一块 radio 时也可省略设备参数，默认使用 `/dev/wlanctl0`：

```shell
wlan_offload.elf info
```

各命令作用如下：

| 命令 | 说明 |
| :-- | :-- |
| `names` | 查询 radio index、control、STA 和 AP 名称 |
| `info` | 读取当前接口能力和固件版本，不主动启动 STA |
| `probe` | 先通过 WLAN 管理路径启用 STA，再读取能力 |
| `scan` | 发起扫描并打印 scan result/done 事件 |
| `monitor` | 启用 STA 后无限阻塞，打印启动命令之后收到的事件 |

开启自动 STA 的驱动中，`probe` 是幂等诊断操作。`monitor` 会持续运行，使用
`Ctrl+C` 结束。

```{note}
控制设备是独占打开的。同一时间只能由一个进程持有；运行 `monitor` 时，其他
诊断程序或用户态 supplicant 无法打开同一个 `/dev/wlanctlN`。
```

## 客户端 API

典型生命周期：

```c
#include <wlan_offload_client.h>

struct wlan_offload_handle *handle;
struct wlan_offload_names names;
struct wlan_offload_info info;

if (wlan_offload_open(&handle, "/dev/wlanctl0") != 0)
    return -1;

wlan_offload_get_names(handle, WLAN_OFFLOAD_INTERFACE_STATION, &names);
wlan_offload_get_info(handle, WLAN_OFFLOAD_INTERFACE_STATION, &info);

wlan_offload_close(handle);
```

公共 API 分组如下：

| 分组 | 接口 |
| :-- | :-- |
| 打开和查询 | `wlan_offload_open()`、`close()`、`get_fd()`、`get_info()`、`get_names()` |
| 接口和扫描 | `set_interface()`、`scan()`、`abort_scan()` |
| 连接控制 | `authenticate()`、`associate()`、`disconnect()` |
| 密钥 | `set_key()`、`delete_key()`、`set_default_key()` |
| 数据帧 | `send_mgmt()`、`send_eapol()` |
| 外部认证 | `external_auth_response()` |
| 事件 | `receive_event()` |

`wlan_offload_receive_event()` 的 `timeout_ms` 为 `-1` 时无限等待，为 `0` 时
非阻塞，大于零时按毫秒超时。收到 external-auth 事件后，supplicant 处理指定
AKM 交换，并把同一个 `request_id` 传给
`wlan_offload_external_auth_response()`。

信道相关结构使用完整 `wlan_offload_channel`，包含频段、主信道、宽度和中心
频率，不能简化为单个信道号。扫描安全类型使用公共
`WLAN_OFFLOAD_SECURITY_*` 常量，不要依赖内核枚举头文件。

## 示例边界

`wlan_offload.elf` 是诊断程序，不实现 WPA supplicant，也不会代替普通应用中的
NetMgmt。日常联网仍使用 `wifi join`、`rt_wlan_*` 或 NetMgmt。需要完整企业认证、
SAE H2E 等功能时，应让成熟的用户态 supplicant 链接 `libwlan_offload`，而不是
在应用中自行编码私有 wire protocol。
