# SPI HAL 接口文档

## 硬件介绍

K230 内部集成了 3 路 SPI 控制器（SPI0~SPI2），支持主机模式。支持标准 SPI 模式（MODE0~MODE3），数据位宽 4-32 位可配置。支持单线、双线、四线和八线（仅 SPI0）传输模式。支持 QSPI 扩展功能，包括指令、地址、dummy cycles 等阶段配置。

---

## 数据结构说明

### SPI 模式定义

- `SPI_HAL_MODE_0`：CPOL = 0, CPHA = 0
- `SPI_HAL_MODE_1`：CPOL = 0, CPHA = 1
- `SPI_HAL_MODE_2`：CPOL = 1, CPHA = 0
- `SPI_HAL_MODE_3`：CPOL = 1, CPHA = 1

### 数据线配置

- `SPI_HAL_DATA_LINE_1`：单线 SPI
- `SPI_HAL_DATA_LINE_2`：双线 SPI
- `SPI_HAL_DATA_LINE_4`：四线 QSPI
- `SPI_HAL_DATA_LINE_8`：八线 SPI（仅 SPI0 支持）

### `drv_spi_inst_t`

**描述**：SPI 实例句柄类型。

### `rt_spi_message`

**描述**：SPI 消息结构体。

- `send_buf`：发送数据缓冲区
- `recv_buf`：接收数据缓冲区
- `length`：数据长度
- `next`：下一个消息（链表）
- `cs_take`：是否拉低片选
- `cs_release`：是否释放片选

### `rt_qspi_message`

**描述**：QSPI 扩展消息结构体，继承自 `rt_spi_message`。

- `instruction`：指令阶段配置
- `address`：地址阶段配置
- `alternate_bytes`：交替字节阶段配置
- `dummy_cycles`：dummy 周期数
- `qspi_data_lines`：数据阶段使用的数据线数

---

## 函数接口说明

### `int drv_spi_inst_create(int spi_id, bool active_low, int mode, uint32_t baudrate, uint8_t data_bits, int cs_pin, uint8_t data_line, drv_spi_inst_t *inst);`

**功能**：创建 SPI 实例。

**参数**：

- `spi_id`：SPI 控制器编号，范围 `[0, 2]`
- `active_low`：片选信号极性，`true` 为低电平有效，`false` 为高电平有效
- `mode`：SPI 模式（`SPI_HAL_MODE_0` ~ `SPI_HAL_MODE_3`）
- `baudrate`：时钟频率（Hz）
- `data_bits`：数据位宽，范围 `[4, 32]`
- `cs_pin`：片选引脚编号，范围 `[0, 63]`，`-1` 表示片选由外部控制
- `data_line`：数据线数量（1/2/4/8）
- `inst`：用于存储创建的 SPI 实例指针

**返回值**：

- `0`：成功
- `负值`：失败

---

### `void drv_spi_inst_destroy(drv_spi_inst_t *inst);`

**功能**：销毁 SPI 实例，释放资源。

**参数**：

- `inst`：SPI 实例指针的指针

---

### `int drv_spi_transfer(drv_spi_inst_t inst, const void *tx_data, void *rx_data, size_t len, bool cs_change);`

**功能**：全双工 SPI 传输。

**参数**：

- `inst`：SPI 实例
- `tx_data`：发送数据缓冲区，`NULL` 表示只读
- `rx_data`：接收数据缓冲区，`NULL` 表示只写
- `len`：数据长度（字节）
- `cs_change`：`true` 表示传输后释放片选，`false` 表示保持片选

**返回值**：

- `正值`：实际传输的字节数
- `负值`：失败

---

### `int drv_spi_read(drv_spi_inst_t inst, void *rx_data, size_t len, bool cs_change);`

**功能**：SPI 读操作。

**参数**：

- `inst`：SPI 实例
- `rx_data`：接收数据缓冲区
- `len`：读取长度（字节）
- `cs_change`：`true` 表示传输后释放片选，`false` 表示保持片选

**返回值**：

- `正值`：实际读取的字节数
- `负值`：失败

---

### `int drv_spi_write(drv_spi_inst_t inst, const void *tx_data, size_t len, bool cs_change);`

**功能**：SPI 写操作。

**参数**：

- `inst`：SPI 实例
- `tx_data`：发送数据缓冲区
- `len`：写入长度（字节）
- `cs_change`：`true` 表示传输后释放片选，`false` 表示保持片选

**返回值**：

- `正值`：实际写入的字节数
- `负值`：失败

---

### `int drv_spi_transfer_message(drv_spi_inst_t inst, struct rt_qspi_message *msg);`

**功能**：高级 QSPI 传输，支持指令、地址、dummy cycles 等配置。

**参数**：

- `inst`：SPI 实例
- `msg`：QSPI 消息结构体

**返回值**：

- `正值`：实际传输的字节数
- `负值`：失败

---

## 使用示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_spi_st7789.c`和`src/rtsmart/libs/testcases/rtsmart_hal/test_spi_wq128.c`

**注意事项**：

1. 使用 SPI 前需要通过 FPIOA 配置相应的引脚功能（CLK、MOSI、MISO等）。
1. 8 线模式仅 SPI0 支持。
1. 片选引脚设为 -1 时，需要外部控制片选信号，`cs_change` 参数将不起作用。
1. drv_spi_transfer_message支持硬件片选，其他hal接口仅支持软件片选。
