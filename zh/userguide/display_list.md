# RTOS Display Support List

## Display / Panel 支持列表

当前 SDK 的显示相关配置位于 `MPP Configuration -> Display Configuration`。

> 注意：支持列表会随 SDK 版本演进持续更新，请以当前源码 `src/rtsmart/mpp/Kconfig` 为准。

### 显示驱动层（Display Driver）

- HDMI 显示驱动：`MPP_ENABLE_DSI_HDMI`
- LCD 显示驱动：`MPP_ENABLE_DSI_LCD`
- 虚拟显示驱动：`MPP_DSI_ENABLE_VIRT`

### 面板/桥接芯片驱动层（Panel Driver）

- HDMI 桥接：LT9611（`MPP_DSI_ENABLE_HDMI_LT9611`）
- LCD 面板：HX8399（`MPP_DSI_ENABLE_LCD_HX8399`）
- LCD 面板：ST7701（`MPP_DSI_ENABLE_LCD_ST7701`）
- LCD 面板：ILI9806（`MPP_DSI_ENABLE_LCD_ILI9806`）
- LCD 面板：ILI9881（`MPP_DSI_ENABLE_LCD_ILI9881`）
- LCD 面板：NT35516（`MPP_DSI_ENABLE_LCD_NT35516`）
- LCD 面板：NT35532（`MPP_DSI_ENABLE_LCD_NT35532`）
- LCD 面板：GC9503（`MPP_DSI_ENABLE_LCD_GC9503`）
- LCD 面板：ST7102（`MPP_DSI_ENABLE_LCD_ST7102`）
- LCD 面板：AML020T（`MPP_DSI_ENABLE_LCD_AML020T`）
- LCD 面板：JD9852（`MPP_DSI_ENABLE_LCD_JD9852`）

## 如何在固件中启用指定显示面板

1. 在 SDK 根目录执行：

```bash
make menuconfig
```

1. 进入：

```text
MPP Configuration -> Dsiplay Configuration
```

1. 根据硬件连接启用显示驱动：

- 走 HDMI 路径：打开 `Enable HDMI Display Driver`
- 走 LCD 路径：打开 `Enable LCD Display Driver`

1. 在同一菜单中选择对应面板驱动：

- HDMI 常见为 `Enable HDMI Display Panel Driver LT9611`
- LCD 选择实际面板（如 HX8399/ST7701/ILI9881 等）

1. 保存配置并重新编译镜像：

```bash
time make log
```

## 如何在 RTOS 侧验证显示配置是否生效

### 1) 先确认已启用并编译了 MPP 示例

在 `RT-Smart UserSpace Examples Configuration` 中，至少启用：

- `Enable MPP examples`
- 一个或多个 VO/显示相关 sample（如 `sample_vo_video`、`sample_vo_osd`）

### 2) 板端查找可执行示例

```bash
cd /sdcard/app/examples
find mpp -name "*.elf" | grep -Ei "vo|vicap|player" | head
```

### 3) 运行显示相关示例

```bash
./mpp/sample_vo_video.elf
```

若你的镜像中示例名称不同，请以 `find` 输出结果为准。

## 常见问题

### 1. 点亮失败（黑屏）

优先排查：

1. 驱动路径是否匹配（HDMI/LCD）
1. 面板型号配置是否正确
1. Reset/Backlight GPIO、I2C 总线是否与硬件一致
1. 板卡供电与屏线连接是否稳定

### 2. 菜单里看不到某个面板选项

可能原因：

1. SDK 版本不包含该面板驱动
1. 当前板卡配置未使能对应显示路径
1. 被其他 Kconfig 依赖项限制

## 参考

- 显示驱动新增/调试：[`advanced_development_guide/how_to_add_display.md`](../advanced_development_guide/how_to_add_display.md)
- 示例运行说明：[`how_to_run_samples.md`](./how_to_run_samples.md)
