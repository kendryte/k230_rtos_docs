# SPI ST7789 示例

## 简介

本示例演示了基于 RT-Smart HAL 驱动 ST7789 屏幕的完整流程，包括 SPI 通信、初始化、帧缓冲绘制与刷屏。

## 代码位置

Demo 源码位置：`src/rtsmart/examples/peripheral/spi_st7789`

主文件：`test_spi_st7789.c`

## 当前示例行为

当前版本示例在 `main()` 中完成以下动作：

1. 配置 FPIOA 与 SPI 引脚
1. 创建 LCD 实例（SPI + DC/RST/BL GPIO）
1. 配置分辨率并初始化 ST7789
1. 清屏并绘制三行彩色字符串
1. 刷屏显示，等待 5 秒后退出

显示内容为：

- `RED, Hello World!`
- `GREEN, Hello World!`
- `BLUE, Hello World!`

## 主要接口（以当前源码为准）

- `lcd_create()`
- `lcd_configure()`
- `lcd_init()`
- `lcd_fill()`
- `lcd_draw_string()`
- `lcd_show()`
- `lcd_destroy()`

## 默认引脚与参数（源码内硬编码）

示例默认使用：

- `spi_id = 1`
- `pin_cs = 19`
- `pin_dc = 20`
- `pin_rst = 12`

SPI 时钟在当前代码中配置为 50MHz，模式为 `SPI_HAL_MODE_3`。

## 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 使能对应外设示例后编译固件。

## 运行示例

编译产物名称与目录名一致，运行命令应为：

```shell
cd /sdcard/app/examples/peripheral
./spi_st7789.elf
```

## 注意事项

1. 本示例引脚在源码中写死，需按开发板实际连线修改。
1. ST7789 模块的供电电压、复位极性、背光控制方式可能随模组不同而变化。
1. 使用前请确认 FPIOA 复用配置与所选 SPI 控制器匹配。
