# UART 示例

## 简介

本示例是 UART2 与 UART3 的交叉回环测试程序，覆盖多波特率、奇偶校验、停止位、轮询、缓冲区与压力测试。

源码位置：`src/rtsmart/examples/peripheral/uart/test_uart.c`

## 串口电平与转接模块安全

```{warning}
连接任何 USB 转 UART 模块或串口外设前，必须先查阅开发板原理图，确认所用 UART 引脚对应的 I/O 域电压。K230 的 I/O 域可能配置为 **1.8 V** 或 **3.3 V**，不同开发板和不同引脚不一定相同。外部设备的 TX/RX 逻辑电平必须与开发板匹配；不匹配时必须增加电平转换电路，禁止将 **5 V UART 信号**直接接入 K230。

请断电后接线，并确保 TX 接 RX、RX 接 TX、GND 共地。除非开发板文档明确要求，否则不要连接 USB 转串口模块的 VCC/5V 引脚。具体电气限制请参考 [K230 硬件设计指南](https://www.kendryte.com/k230/zh/main/00_hardware/K230_Hardware_Design_Guide.html)。

**禁止使用下图所示带黄色跳帽的 CH340G USB 转串口模块。** 这类劣质模块即使选择 3.3 V 档，部分样品的 TX 高电平仍可能达到约 3.8 V，存在永久损坏 K230 的风险，在 1.8 V I/O 域上尤其危险。此警告针对下图所示模块，并非否定所有采用 CH340G 芯片的产品。应使用电平经过验证的正规模块；首次连接前建议测量模块 TX 空闲高电平。
```

![禁止使用的 CH340G USB 转串口模块](https://www.kendryte.com/api/imagecdn/zh/bad_ch340.jpg)

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
