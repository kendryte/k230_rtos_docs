# USB Host 网卡配置指南

## 功能概述

K230 RT-Smart 使用 CherryUSB Host 驱动 USB 网卡，并将识别到的接口注册到 lwIP
和 RT-Thread netdev。当前支持的主要设备类型如下：

| 设备 | USB 驱动 | 典型用途 |
| :-- | :-- | :-- |
| RTL8152 及兼容网卡 | RTL8152 专用驱动 | USB 有线网卡 |
| CH397 | CDC ECM 或 CDC NCM | USB 有线网卡 |
| LTE 模组 | CDC ECM 或 CDC NCM | EC200、ML307 等模组的数据网口 |

USB 网卡按探测顺序使用第一个空闲名称，范围为 `eth0` 到 `eth9`。接口名不与
芯片型号绑定；同时使用多个网络设备时，应先通过 `ifconfig` 确认实际名称。

```{note}
本文配置的是 USB Host 侧的网络接口。LTE 模组的 SIM 卡、APN、驻网和拨号参数
仍需按模组厂商文档配置，并确保模组当前 USB 组合模式会枚举出 ECM 或 NCM
接口。
```

## 公共配置

先在 SDK 根目录加载目标板配置，再进入 RT-Smart 配置界面：

```shell
make <board>_defconfig
make rtsmart-menuconfig
```

进入以下路径：

```text
Components Configuration
    -> Enable CherryUSB
        -> Enable CherryUSB Host
```

完成以下公共设置：

1. 打开 `Enable CherryUSB Host`。
1. 在 `CherryUSB Host Use Device` 中选择网卡实际连接的 USB 控制器。
1. 打开 `Enable CherryUSB Host Class Driver`。
1. 打开 `Enable USB Host for CanMV(Some USB Host Drivers)`。

最后一项不仅选择部分 CanMV USB 驱动，还会让 `app_canmv` 初始化 Host 控制器，
因此在非 OTG 配置中不能省略。该选项会自动选择 RTL8152 驱动，所以仅使用
ECM/NCM 设备时，在最终配置中看到 RTL8152 选项同时开启属于正常现象。

如果固件还启用了 USB Device，Host 与 Device 必须选择不同的控制器。开发板的
USB 接口、控制器编号和 VBUS 使能 GPIO 均与硬件设计有关，应保留目标板
defconfig 中已有的 `CanMV USB Host Power Control GPIO` 设置，不能直接套用其他
开发板的 GPIO 值。

![img](https://www.kendryte.com/api/imagecdn/zh/rtsmart_cherry_usb_cofig.jpg)

## 选择网卡驱动

### RTL8152

在 `Enable CherryUSB Host Class Driver` 下打开：

```text
Enable net RTL8152
    -> Enable Link Down Check
```

`Enable USB Host for CanMV(Some USB Host Drivers)` 已自动选择
`Enable net RTL8152`。建议同时打开 `Enable Link Down Check`，使插拔网线后的
链路状态可以及时同步到 netdev。

对应的关键配置项为：

```text
CONFIG_CHERRY_USB_HOST_ENABLE_CLASS_NET_RTL8152=y
CONFIG_CHERRY_USB_RTL8152_LINKCHECK=y
```

### CH397

CH397（USB VID/PID `1a86:5397`）提供 Vendor、ECM 和 NCM 三套 USB
configuration。Host 驱动会根据 `CH397 Mode` 选择其中一套，因此所选模式必须和
编译进固件的 CDC 驱动一致。

推荐优先使用 ECM：

```text
Enable CherryUSB Host Class Driver
    -> Enable cdc ECM
    -> CH397 Mode
        -> ECM
```

对应配置为：

```text
CONFIG_CHERRY_USB_HOST_ENABLE_CLASS_CDC_ECM=y
CONFIG_CHERRY_USB_HOST_CH397_MODE_ECM=y
```

如需使用 NCM，则打开 `Enable cdc NCM`，并在 `CH397 Mode` 中选择 `NCM`：

```text
CONFIG_CHERRY_USB_HOST_ENABLE_CLASS_CDC_NCM=y
CONFIG_CHERRY_USB_HOST_CH397_MODE_NCM=y
```

不能只切换 `CH397 Mode` 而不启用对应的 CDC ECM/NCM 驱动。ECM 与 NCM 驱动可以
同时编译，但 CH397 每次枚举只能选择其中一种模式。

![img](https://www.kendryte.com/api/imagecdn/zh/rtsmart_ch397_config.jpg)

### LTE 模组

先确认模组当前 USB 组合模式所提供的网络接口类型，然后启用对应驱动：

| 模组枚举接口 | 需要打开的选项 | 配置项 |
| :-- | :-- | :-- |
| CDC ECM | `Enable cdc ECM` | `CHERRY_USB_HOST_ENABLE_CLASS_CDC_ECM` |
| CDC NCM | `Enable cdc NCM` | `CHERRY_USB_HOST_ENABLE_CLASS_CDC_NCM` |

EC200、ML307 等模组常见配置使用 ECM，但同一系列不同固件或 USB 组合模式可能
不同，应以实际 USB 描述符和厂商手册为准。`CH397 Mode` 只对 VID/PID 为
`1a86:5397` 的 CH397 生效，不会改变 LTE 模组的模式。

若还需要通过 AT 口设置 APN、查询驻网状态或切换 USB 组合模式，可同时打开：

```text
Enable CherryUSB Host Class Driver
    -> Enable SERIAL
        -> Enable serial EC200M/A7680C or Other Compatible
```

兼容的 Vendor Serial 端口通常注册为 `/dev/ttyUSBx`。如果模组提供标准 CDC ACM
端口，则还需打开 `Enable cdc ACM`，设备通常注册为 `/dev/ttyACMx`。串口驱动与
ECM/NCM 网络驱动相互独立；打开串口驱动本身不会建立蜂窝数据连接。

![img](https://www.kendryte.com/api/imagecdn/zh/rtsmart_lte_ec200m.jpg)

## 网络栈配置

USB 网卡依赖 lwIP 和 netdev。确认配置中已经启用：

```text
CONFIG_RT_USING_LWIP=y
CONFIG_RT_LWIP_DHCP=y
CONFIG_RT_USING_NETDEV=y
CONFIG_NETDEV_USING_IFCONFIG=y
```

`RT_USING_NETDEV` 通常由 SAL 自动选择，DHCP 和 `ifconfig` 默认开启。需要手动
检查时，可在 menuconfig 中搜索上述配置项。

保存配置后重新编译并烧录固件。若要把修改固化到目标板 defconfig，再按 SDK
的板级配置维护流程执行 `make savedefconfig`。

## 运行验证

插入设备后先检查 USB 枚举日志。成功绑定时会出现 RTL8152、CDC ECM 或 CDC NCM
类驱动的注册信息，随后出现类似日志：

```text
registered LAN interface as eth0
```

执行以下命令查看链路、地址、网关和 DNS：

```shell
ifconfig
```

启用 `RT_LWIP_DHCP` 后，接口注册时会启动 DHCP。若链路建立后仍没有地址，可按
`ifconfig` 显示的实际接口名重新触发 DHCP：

```shell
ifconfig eth0 dhcp
```

也可以临时配置静态 IPv4 地址：

```shell
ifconfig eth0 <ip-address> <gateway-address> <netmask>
```

最后验证网关和外部地址：

```shell
ping <gateway-address>
ping <external-ip-address>
```

多网卡环境中，`ifconfig` 标记为 `Default` 的接口承担默认路由。不要假定 USB
网卡始终为 `eth0` 或默认接口；应用可通过 NetMgmt 的 `RT_NET_DEV_LAN` 查询 LAN
接口。

## 故障排查

1. **USB 设备完全没有枚举**：确认选择了实际连接的 Host 控制器，检查 VBUS
   供电、线缆以及板级 `CANMV_USB_PWR_PIN` 配置。
1. **有 USB VID/PID，但没有 `ethN`**：确认打开了与设备描述符匹配的 RTL8152、
   CDC ECM 或 CDC NCM 驱动，以及 `Enable USB Host for CanMV`。
1. **CH397 枚举后没有绑定网络驱动**：检查 `CH397 Mode` 与启用的 ECM/NCM 驱动
   是否一致。枚举日志中的 `The device selects config 1` 表示 ECM，`config 2`
   表示 NCM。
1. **LTE 模组只有串口、没有网卡**：模组当前 USB 组合模式未提供 ECM/NCM，或
   蜂窝数据会话尚未建立。先通过 AT 口核对 USB 模式、SIM、APN 和驻网状态。
1. **接口有链路但没有 IPv4 地址**：确认 DHCP 已启用，执行
   `ifconfig ethN dhcp`，并检查上游路由器或 LTE 模组是否提供 DHCP 服务。
1. **插拔网线后状态不更新**：RTL8152 打开 `Enable Link Down Check`；ECM/NCM
   设备还需确认其 USB notification 正确上报网络连接状态。

## 源码位置

- USB Host 配置：`src/rtsmart/rtsmart/kernel/bsp/maix3/components/Kconfig`
- RT-Smart 网卡适配：`src/rtsmart/rtsmart/kernel/bsp/maix3/components/canmv_usb/`
- CherryUSB Class 驱动：`src/rtsmart/rtsmart/kernel/bsp/maix3/components/CherryUSB/class/`
