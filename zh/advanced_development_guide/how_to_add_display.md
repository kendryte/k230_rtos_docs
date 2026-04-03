# 如何新增一个屏幕驱动

本文档介绍当前显示驱动框架下新增屏幕的推荐流程。新框架已经移除了旧版的 `DSI Debugger` 调试路径，新增屏幕时应先在 `make menuconfig` 中完成显示驱动、引脚和面板选择，再按当前 connector/panel 框架补齐代码。

本文档仍以一个 `368(H) x 552(V)` 的 `MIPI DSI` 屏幕为例，说明从 menuconfig 到代码集成的完整过程。

## 总体流程

新增屏幕建议按下面顺序进行：

1. 在 `make menuconfig` 中打开对应显示驱动，并配置引脚。
1. 在 `Display Panel Drivers Configuration` 中选择已有面板，或为新面板添加一个新的 panel driver。
1. 编译并运行显示 sample，使用 `list_connector` 和现有 sample 验证配置是否生效。
1. 如果面板还不在 SDK 中，再按当前框架补充 `connector_type`、`panel_desc`、初始化序列和 CanMV 映射。

## 先在 menuconfig 中完成显示配置

在工程根目录执行：

```bash
make menuconfig
```

进入菜单：

```text
MPP Configuration -> Display Configuration
```

![display](https://www.kendryte.com/api/post/attachment?id=866)

### 选择显示驱动类型

根据硬件连接方式，先启用正确的显示驱动：

- `Enable HDMI Display Driver`
- `Enable LCD Display Driver`
- `Enable SPI LCD Display Driver`
- `Enable QSPI LCD Display Driver`
- `Enable OSPI LCD Display Driver`

如果屏幕是 `MIPI DSI LCD`，通常需要打开 `Enable LCD Display Driver`。

### 配置显示相关引脚

在同一个菜单中配置当前板卡使用的引脚。

对于 `MIPI DSI LCD`，至少需要确认：

- `DSI-LCD Reset GPIO`
- `DSI-LCD BackLight GPIO`

对于 `HDMI`，需要确认：

- `DSI-HDMI Reset GPIO`
- `DSI-HDMI I2c Bus`

对于 `SPI/QSPI/OSPI LCD`，除了 reset/backlight 外，还需要确认总线和 FPIOA 相关配置，例如：

- `Data/Command GPIO`
- `Chip Select GPIO`
- `Reset GPIO`
- `Backlight GPIO`
- `Clock Pin`
- `Data0/MOSI Pin`
- `QSPI Bus`

![display](https://www.kendryte.com/api/post/attachment?id=865)

### 选择面板驱动

完成驱动类型和引脚配置后，继续在下面的菜单中选择面板驱动：

```text
Display Panel Drivers Configuration
```

当前 SDK 中可以直接选择的面板/桥接芯片驱动包括：

- `Enable HDMI Display Panel Driver LT9611`
- `Enable LCD Display Panel Driver HX8399`
- `Enable LCD Display Panel Driver ST7701`
- `Enable LCD Display Panel Driver ili9806`
- `Enable LCD Display Panel Driver ili9881`
- `Enable LCD Display Panel Driver nt35516`
- `Enable LCD Display Panel Driver nt35532`
- `Enable LCD Display Panel Driver gc9503`
- `Enable LCD Display Panel Driver st7102`
- `Enable LCD Display Panel Driver aml020t`
- `Enable LCD Display Panel Driver JD9852`
- `Enable SPI LCD Panel Driver ST7789`

如果你的屏幕型号已经在这里，先直接使能对应项验证引脚和显示链路。如果这里没有对应型号，再继续下面的“在工程代码中添加屏幕”。

![display](https://www.kendryte.com/api/post/attachment?id=866)

保存配置后重新编译固件。

## 验证当前配置是否生效

建议先验证 menuconfig 配置没有问题，再开始新增代码。

### 使能并编译显示相关 sample

在 `RT-Smart UserSpace Examples Configuration` 中，至少使能：

- `Enable MPP examples`
- 一个或多个 VO/显示相关 sample，例如 `sample_vo_video`、`sample_vo_osd`

重新编译镜像后，在板端查找 sample：

### 查看当前固件支持的 connector

进入板端 shell 后，可以先执行：

```shell
list_connector
```

这个命令可以列出当前固件已经编进镜像的 connector 类型和枚举值。它能帮助你确认：

- menuconfig 里选择的 panel driver 是否已经生效
- 新增的 panel driver 是否已经进入最终镜像
- sample 运行时应传入哪个 `connector_type`

### 运行显示 sample

例如：

```shell
./mpp/sample_vo_video.elf <connector_type>
```

如果 sample 可以点亮已经使能的面板，说明当前显示链路、引脚和基础时序已经通了；这时再开始新增面板代码，定位会更清晰。

## 准备新增面板前需要拿到的信息

新增一个 panel driver 之前，通常需要准备两类信息：

1. 屏幕时序参数
1. 屏幕厂家提供的初始化序列

这两类信息最终会进入 panel driver 源码，而不是像旧版流程那样写到 SDCard 配置文件里。

### 屏幕时序

以本文档示例屏幕为例，时序信息通常包括：

```shell
pclk_hz=27000000
fps=60
lane_num=2

hactive=368
hsync=8
hbp=16
hfp=16

vactive=552
vsync=48
vbp=250
vfp=250
```

这些值会对应到 `panel_desc` 里的 `timing` 字段，例如：

- `pclk_hz` / `pclk_khz`
- `hactive`
- `hsync_len`
- `hback_porch`
- `hfront_porch`
- `vactive`
- `vsync_len`
- `vback_porch`
- `vfront_porch`

工程里仍然可以使用时序计算工具辅助计算：

[K230 MIPI DSI Connector Info Generator](https://kendryte-download.canaan-creative.com/developer/common/K230_MIPI_DSI_Connector_Info_Generator.html)

> 仅可以验证时序是否能够生成

### 初始化序列

厂家往往会提供一组寄存器初始化表，例如：

```shell
{0xFF,5,{0x77,0x01,0x00,0x00,0x13}},
{0xEF,1,{0x08}},
{0xFF,5,{0x77,0x01,0x00,0x00,0x10}},
{0xC0,2,{0x44,0x00}},
{0xC1,2,{0x0B,0x02}},
{0xC2,2,{0x07,0x1F}},
```

在当前框架里，这些数据一般会被转换成 panel 源文件中的命令序列数组，例如 `mipi_st7701.c` 中的：

```c
const k_u8 init_sequence[] = {
    0x39, 0, 6, 0xFF, 0x77, 0x01, 0x00, 0x00, 0x13,
    0x15, 0, 2, 0xEF, 0x08,
    0x39, 0, 3, 0xC0, 0x44, 0x00,
};
```

命令格式仍然是：

```text
cmd_type, delay_ms, cmd_data_length, cmd_data0 ... cmd_dataN
```

当前常用的 `cmd_type` 有：

- `0x05`：单字节命令，无参数
- `0x15`：单字节命令，带一个参数
- `0x39`：长命令，带多个参数

我们仍然举两个转换例子：

```shell
{0xB0,16,{0x0F,0x1E,0x25,0x0D,0x11,0x06,0x12,0x08,0x08,0x2A,0x05,0x12,0x10,0x2B,0x32,0x1F}},

# 去掉外层 {}
# 0xB0 是命令，后面 16 个字节是参数，因此使用 0x39
# 长度 = 1 个命令字节 + 16 个参数字节 = 17

0x39,0,17,0xB0,0x0F,0x1E,0x25,0x0D,0x11,0x06,0x12,0x08,0x08,0x2A,0x05,0x12,0x10,0x2B,0x32,0x1F
```

```shell
{0x11,0,{0x00}},
{REGFLAG_DELAY,120,{}},

# 这一组也可以转换到 init_sequence 数组中
# 如果按“1 个命令 + 1 个参数”处理，可以写成：

0x15,120,2,0x11,0x00
```

## 在工程代码中添加屏幕

当前框架不是简单复制一份旧面板文件再改名字，而是围绕 `connector_type`、`panel_desc`、`panel_ops` 和 `panel_drv` 组织。

### 1. 先定义或确认 `connector_type`

屏幕类型定义位于：

- `src/rtsmart/mpp/include/comm/k_connector_comm.h`

当前工程使用 `K_CONN_TYPE(chip, bus, w, h, ver)` 生成 `k_connector_type`。新增面板时，先为新型号补一个新的类型常量，命名风格参考现有定义：

- `ST7701_480_800_DSI_V1`
- `ST7701_480_854_DSI_V1`
- `ST7701_480_640_DSI_V1`
- `ST7701_368_544_DSI_V1`

如果只是为现有芯片增加一个新分辨率变体，也应优先沿用现有芯片命名方式，而不是单独发明一套类型编码。

### 2. 在 panel 源文件中补齐初始化和描述符

DSI 面板的实现通常位于：

- `src/rtsmart/mpp/kernel/connector/src/panels/`

例如 ST7701 的实现文件：

- `src/rtsmart/mpp/kernel/connector/src/panels/mipi_st7701.c`

一个新 panel 通常至少需要这些内容：

1. 一个 `init_sequence` 对应的初始化函数
1. 一个 `panel_ops`
1. 一个 `panel_desc`
1. 一个 `panel_drv` 或一个新的 variant 挂到现有 `panel_drv` 下

`panel_desc` 的关键字段包括：

- `name`
- `connector_type`
- `bus_type`
- `timing`
- `gpio`
- `bus`
- `bus_ops`
- `ops`

以 DSI 面板为例，`gpio` 中通常会引用 menuconfig 配置出来的引脚：

```c
.gpio = {
    .reset_pin = CONFIG_MPP_DSI_LCD_RESET_PIN,
    .backlight_pin = CONFIG_MPP_DSI_LCD_BACKLIGHT_PIN,
    .reset_delay_ms = 10,
    .backlight_delay_ms = 0,
    .reset_active_low = K_TRUE,
    .backlight_active_low = K_FALSE,
},
```

这也是为什么新增屏幕之前，应该先在 `Display Configuration` 中把引脚配置清楚。

### 3. 把新 panel 挂到当前驱动框架中

connector 核心会从 `connector_drv_list[]` 里查找可用 panel。相关逻辑位于：

- `src/rtsmart/mpp/kernel/connector/src/connector_dev.c`

当前查找流程是：

1. 遍历 `connector_drv_list[]`
1. 遍历每个驱动中的 `panel_variants`
1. 通过 `connector_type` 匹配目标 panel

因此新增面板时，需要确保新 panel 最终能进入某个 `panel_drv` 的 `panel_variants`，并且该驱动本身会被编译进镜像。

### 4. 在 Kconfig 和 Makefile 中接入新 panel

完成 panel 源码后，还需要把它接进构建系统。

相关文件：

- `src/rtsmart/mpp/Kconfig`
- `src/rtsmart/mpp/kernel/connector/Makefile`

Kconfig 负责把新 panel 暴露到：

```text
MPP Configuration -> Display Configuration -> Display Panel Drivers Configuration
```

Makefile 负责根据 Kconfig 选项决定是否编译对应源文件。例如当前 DSI 面板的接入方式是：

```make
src-$(CONFIG_MPP_DSI_ENABLE_LCD_ST7701) += src/panels/mipi_st7701.c
```

新增面板时，应按同样方式补一项，并在 `Kconfig` 中增加一个对应的 `config` 条目。

### 5. 如需 CanMV Python 接口支持，再补充映射

如果该面板不仅在 C sample 中使用，也希望在 CanMV Python 接口中可选，还需要同步修改：

- `src/canmv/port/modules/modmedia.display.c`

这里主要有两部分：

1. `PY_PANEL_TYPE_*` 枚举
1. `py_display_panel_map[]` 映射表

只有当新的 `connector_type` 被映射到 `py_display_panel_map[]` 后，CanMV Python 层才能按面板类型和分辨率选择它。

## 新增屏幕的最小检查清单

提交代码前，建议至少检查下面几项：

1. `make menuconfig` 中能看到新的 panel 选项。
1. `Display Configuration` 里的 reset/backlight/bus 引脚与实际硬件一致。
1. `Makefile` 已经根据新的 Kconfig 选项编译对应面板源文件。
1. `connector_type` 在 `k_connector_comm.h` 中已经定义。
1. `panel_desc` 的时序、lane 数、GPIO 和初始化序列都已填写。
1. `connector_drv_list[]` 查找路径可以命中新 panel。
1. 板端 `list_connector` 可以看到新 panel。
1. `sample_vo_video` 或其他显示 sample 可以点亮屏幕。
1. 如果需要 Python 支持，`py_display_panel_map[]` 已同步更新。

## 常见问题

### 1. menuconfig 中看不到某个 panel 选项

优先检查：

1. 是否先使能了对应显示驱动，例如 `Enable LCD Display Driver` 或 `Enable SPI LCD Display Driver`
1. Kconfig 条目是否 `depends on` 了某个上层驱动开关
1. 新 panel 对应的 Kconfig 配置是否已经接入

### 2. 已经编译通过，但 `list_connector` 看不到新 panel

优先检查：

1. `Makefile` 是否已经编译对应 panel 源文件
1. `connector_dev.c` 中的驱动列表是否能包含该 panel 对应的 `panel_drv`
1. `panel_variants` 里是否真正挂入了新的 `panel_desc`

> `list_connector` 仅在 RTOS SDK 中被编译

### 3. 屏幕上电但不显示图像

优先检查：

1. reset/backlight GPIO 是否正确
1. DSI lane、pixel clock、porch、sync 参数是否正确
1. 厂家初始化序列是否完整，延时是否保留
1. sample 使用的 `connector_type` 是否与新增 panel 一致
1. 检查串口日志，如果依然不能解决，可以去论坛发帖请教

## 参考

- 当前显示驱动开关与面板列表：[`../userguide/display_list.md`](../userguide/display_list.md)
- 显示 sample 使用说明：[`../app_develop_guide/media/display.md`](../app_develop_guide/media/display.md)
- VO/显示 API 说明：[`../api_reference/mpp/display.md`](../api_reference/mpp/display.md)
