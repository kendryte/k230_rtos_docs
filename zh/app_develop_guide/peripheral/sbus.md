# SBUS 示例

## 简介

本示例通过 UART3 发送 SBUS 帧，并在按键触发时动态修改通道值。

```{warning}
SBUS 使用物理 UART 引脚。接线前必须确认开发板 I/O 域和接收机信号使用相同的 1.8 V 或 3.3 V 电平，禁止输入 5 V 信号。完整要求见 [串口电平与转接模块安全](./uart.md)。
```

源码位置：`src/rtsmart/examples/peripheral/sbus/test_sbus.c`

## 示例行为

- 通过 FPIOA 配置：
  - `GPIO21` 作为按键输入
  - `PIN50` -> `UART3_TXD`
  - `PIN51` -> `UART3_RXD`
- 初始化后先发送一组默认帧
- 按键按下时轮换通道值并发送
- 主循环持续以固定周期发送 SBUS 帧

## 关键接口

- `drv_fpioa_set_pin_func()`
- `drv_gpio_inst_create()` / `drv_gpio_value_get()`
- `sbus_create()` / `sbus_destroy()`
- `sbus_set_channel()` / `sbus_send_frame()`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/sbus
make
./test_sbus
```

该示例无命令行参数。

```{admonition} 提示
SBUS 使用 UART 发送，UART 相关参数与接口请参考 [UART API 文档](../../api_reference/peripheral/uart.md)。
```
