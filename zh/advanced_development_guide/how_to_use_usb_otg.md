# K230D USB OTG 使用指南

## 一、OTG 功能说明

K230D 现已支持 USB OTG，K230 本身有两个 USB 口，暂不支持 OTG。

开启 OTG 后，系统可以根据 USB ID 状态在 Device 和 Host 之间切换。同一个 USB 控制器既可以作为 USB Device 使用，也可以在切换后作为 USB Host 使用。默认 OTG 功能不打开，需要自己手动打开。

## 二、OTG 配置说明

### 参考配置

使用如下 defconfig 举例：

```bash
make k230d_canmv_bpi_zero_defconfig
```

然后进入 menuconfig：

```bash
make rtsmart-menuconfig
```

### 打开 OTG

在 menuconfig 中进入如下路径：

```text
Components Configuration
    -> Enable CherryUSB
        -> Enable CherryUSB OTG
```

`Enable CherryUSB OTG` 仅在 K230D 配置下可见。

### 打开 Host 侧必要配置

如果希望 OTG 切换到 Host 后在 CanMV/MPY 环境下正常使用，还需要同时打开以下两个配置。

第一项：

```text
Components Configuration
    -> Enable CherryUSB
        -> Enable CherryUSB Host
            -> CherryUSB Host Controller Driver
                -> Using DesignWare Driver
                    -> Enable descriptor DMA mode
```

第二项：

```text
Components Configuration
    -> Enable CherryUSB
        -> Enable CherryUSB Host
            -> Enable USB Host for CanMV(Some USB Host Drivers)
```

## 三、推荐配置步骤

推荐按下面顺序配置：

```bash
make k230d_canmv_bpi_zero_defconfig
make rtsmart-menuconfig
```

然后在 menuconfig 中执行：

1. 打开 `Components Configuration -> Enable CherryUSB -> Enable CherryUSB OTG`
1. 进入 `Components Configuration -> Enable CherryUSB -> Enable CherryUSB Host -> CherryUSB Host Controller Driver -> Using DesignWare Driver`，打开 `Enable descriptor DMA mode`
1. 进入 `Components Configuration -> Enable CherryUSB -> Enable CherryUSB Host`，打开 `Enable USB Host for CanMV(Some USB Host Drivers)`

配置完成后再重新编译固件。

## 四、硬件设计参考

K230D 的 OTG 切换除了软件配置外，还依赖板级 USB_ID 的硬件设计。不同开发板的实现方式不同，可以按自己的需求选型。

### 方案一：CC 脚联动 USB_ID

`k230d_canmv_bpi_zero_defconfig` 对应的 BPI Zero K230D 板卡采用了这种做法。

该方案中，Type-C 的 CC 脚接到了 USB_ID：

1. 默认情况下，USB_ID 被上拉为高电平，系统工作在 Device 模式
1. 接入 OTG cable 后，USB_ID 被拉低，系统动态切换到 Host 模式

这种方式的特点是可以通过插拔 OTG cable 直接触发动态切换。

但它也有一个限制：由于该 CC 脚没有下拉电阻，这个 Type-C 口就无法再作为供电口使用。

### 方案二：GPIO 控制 USB_ID

庐山派（K230D 版本）采用这种做法。

该方案中，不是依靠 OTG cable 自动改变 USB_ID，而是由一个 GPIO 主动控制 USB_ID 引脚状态：

1. 通过软件控制 GPIO，进而控制 USB_ID 为高或低
1. USB_ID 为高时工作在 Device 模式
1. USB_ID 为低时切换到 Host 模式

这种方式的特点是：

1. 不能单纯依靠插拔 OTG cable 做动态切换
1. 角色切换依赖 GPIO 控制
1. 但该 Type-C 口可以保留为供电口使用

### 方案选择建议

如果你的需求更偏向“插上线就自动切 Host，拔线就回 Device”，可以参考 BPI Zero 这类基于 CC/USB_ID 联动的方案。

如果你的需求更偏向“保留 Type-C 供电能力，同时允许软件控制 Host/Device 角色”，可以参考庐山派（K230D 版本）这类 GPIO 控制 USB_ID 的方案。

## 五、注意事项

1. 只打开 `Enable CherryUSB OTG` 还不够，若未同时打开 `Enable descriptor DMA mode`，Host 模式下的性能会受影响。
1. 若未打开 `Enable USB Host for CanMV(Some USB Host Drivers)`，则 CanMV/MPY 环境下依赖的部分 USB Host 驱动不会编译进固件，切换到 Host 后会出现“Host 不能用”的现象。
1. OTG 的实际切换依赖板级 USB ID 设计，软件侧只负责根据 ID 状态执行角色切换。
1. 若业务上还需要使用 U 盘、UVC、HID、网卡或串口类 Host 设备，还需要根据实际外设再打开对应的 USB Host Class Driver。
