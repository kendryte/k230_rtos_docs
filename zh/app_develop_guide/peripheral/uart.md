# UART 示例

## 简介

本示例是 UART2 与 UART3 的交叉回环测试程序，覆盖多波特率、奇偶校验、停止位、轮询、缓冲区与压力测试。

源码位置：`src/rtsmart/examples/peripheral/uart/test_uart.c`

## 示例行为

- 固定引脚映射：
  - UART2: TX=11, RX=12
  - UART3: TX=50, RX=51
- 自动配置多组参数进行批量测试（波特率/校验/停止位）
- 执行基础收发、poll、recv_available、配置读写、随机压力测试
- 汇总每组配置通过/失败情况

## 关键接口

- `drv_uart_inst_create()` / `drv_uart_inst_destroy()`
- `drv_uart_set_config()` / `drv_uart_get_config()`
- `drv_uart_write()` / `drv_uart_read()`
- `drv_uart_poll()` / `drv_uart_recv_available()`
- `drv_uart_configure_buffer_size()`
- `drv_fpioa_set_pin_func()`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/uart
make
./test_uart
```

该示例无命令行参数。

```{admonition} 提示
UART 接口细节请参考 [UART API 文档](../../api_reference/peripheral/uart.md)。
```
