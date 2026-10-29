# 显示屏幕支持列表

当前 SDK 的显示相关配置位于 `MPP Configuration -> Display Configuration`。

> 注意：支持列表会随 SDK 版本演进持续更新，请以当前源码 `src/rtsmart/mpp/Kconfig` 为准。

## 面板 / 桥接芯片驱动层（Panel Driver）

当前 SDK 已内置对多种显示面板与桥接芯片的支持，涵盖 DSI、SPI 以及 HDMI 等输出路径。

每种显示方案通常由两部分组成：

- 面板驱动（Panel）：负责 LCD/屏幕本体的初始化与显示参数配置
- 桥接芯片驱动（Bridge）：用于将 DSI/其他接口转换为 HDMI 或其他显示接口

当前驱动已适配多种面板与桥接芯片，并提供不同分辨率配置选项。系统最大支持 1920×1080@60Hz 或同等级别带宽能力的显示输出。

| 面板/桥接芯片 | 配置宏 |
| :--- | :--- |
| HDMI 桥接：LT9611 | `MPP_DSI_ENABLE_HDMI_LT9611` |
| LCD 面板：HX8399 | `MPP_DSI_ENABLE_LCD_HX8399` |
| LCD 面板：ST7701 | `MPP_DSI_ENABLE_LCD_ST7701` |
| LCD 面板：ILI9806 | `MPP_DSI_ENABLE_LCD_ILI9806` |
| LCD 面板：ILI9881 | `MPP_DSI_ENABLE_LCD_ILI9881` |
| LCD 面板：NT35516 | `MPP_DSI_ENABLE_LCD_NT35516` |
| LCD 面板：NT35532 | `MPP_DSI_ENABLE_LCD_NT35532` |
| LCD 面板：GC9503 | `MPP_DSI_ENABLE_LCD_GC9503` |
| LCD 面板：ST7102 | `MPP_DSI_ENABLE_LCD_ST7102` |
| LCD 面板：AML020T | `MPP_DSI_ENABLE_LCD_AML020T` |
| LCD 面板：JD9852 | `MPP_DSI_ENABLE_LCD_JD9852` |
| SPI LCD 面板：ST7789 | `MPP_SPI_ENABLE_LCD_ST7789` |

## 如何适配一个新屏幕

屏幕的 menuconfig 引脚配置、面板驱动注册、初始化序列添加等完整流程，请参考：

- [如何新增一个屏幕驱动](../advanced_development_guide/how_to_add_display.md)
