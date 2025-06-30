# UART Hal 接口文档

## 硬件介绍

K230 内部集成了五个 UART（通用异步收发传输器）硬件模块，其中rtsmart系统占用一个串口（默认占用串口 0），其他串口可以供用户使用。

---

## 数据结构说明

### `struct uart_configure`

UART 配置结构体，包含以下成员：

* `baud_rate`：波特率
* `data_bits`：数据位数（5-9）
* `stop_bits`：停止位（0-3 对应 1-4 个停止位）
* `parity`：校验位（0：无校验，1：奇校验，2：偶校验）
* `bit_order`：位顺序（0：LSB 优先，1：MSB 优先）
* `invert`：信号反转（0：正常模式，1：反转模式）
* `bufsz`：缓冲区大小
* `reserved`：保留字段

---

## 函数接口说明

### `int drv_uart_inst_create(int id, drv_uart_inst_t** inst);`

**功能**：创建 UART 驱动实例。

**参数**：

* `id`：UART 接口 ID，范围 `[0, KD_HARD_UART_MAX_NUM-1]`
* `inst`：双重指针，用于存储创建的实例

**返回值**：

* `0`：创建成功
* `-1`：参数无效
* `-2`：UART ID 无效
* `-3`：内存分配失败

---

### `void drv_uart_inst_destroy(drv_uart_inst_t** inst);`

**功能**：销毁 UART 驱动实例。

**参数**：

* `inst`：双重指针，指向要销毁的实例

---

### `size_t drv_uart_read(drv_uart_inst_t* inst, const uint8_t* buffer, size_t size);`

**功能**：从 UART 读取数据。

**参数**：

* `inst`：UART 实例
* `buffer`：存储读取数据的缓冲区
* `size`：要读取的字节数

**返回值**：

* 成功时：实际读取的字节数
* `-1`：参数无效
* `-2`：读取错误

---

### `size_t drv_uart_write(drv_uart_inst_t* inst, uint8_t* buffer, size_t size);`

**功能**：向 UART 写入数据。

**参数**：

* `inst`：UART 实例
* `buffer`：要写入的数据
* `size`：要写入的字节数

**返回值**：

* 成功时：实际写入的字节数
* `-1`：参数无效
* `-2`：写入错误

---

### `int drv_uart_poll(drv_uart_inst_t* inst, int timeout_ms);`

**功能**：轮询 UART 读取可用性。

**参数**：

* `inst`：UART 实例
* `timeout_ms`：超时时间（毫秒），`-1` 表示无限等待，`0` 表示非阻塞

**返回值**：

* `>0`：有数据可读
* `0`：超时
* `-1`：参数无效
* `-errno`：轮询错误（负的 errno 值）
* `-EIO`：设备错误

---

### `size_t drv_uart_recv_available(drv_uart_inst_t* inst);`

**功能**：检查可读取的字节数。

**参数**：

* `inst`：UART 实例

**返回值**：

* 成功时：可读取的字节数
* `-1`：参数无效
* `-2`：IOCTL 错误

---

### `int drv_uart_send_break(drv_uart_inst_t* inst);`

**功能**：在 UART TX 线上发送中断信号。将 TX 线强制拉低一段时间，用于特殊事件信号（如 LIN 同步、注意请求、软复位等）。

**参数**：

* `inst`：UART 实例

**返回值**：

* `0`：成功
* `-1`：实例无效或未打开
* `-2`：IOCTL 调用失败

---

### `int drv_uart_set_config(drv_uart_inst_t* inst, struct uart_configure* cfg);`

**功能**：设置 UART 配置。

**参数**：

* `inst`：UART 实例
* `cfg`：配置结构体

**返回值**：

* `0`：成功
* `-1`：参数无效
* `-2`：IOCTL 错误

**注意**：此函数不能修改 `bufsz`，请使用 `drv_uart_configure_buffer_size` 修改缓冲区大小。

---

### `int drv_uart_get_config(drv_uart_inst_t* inst, struct uart_configure* cfg);`

**功能**：获取当前 UART 配置。

**参数**：

* `inst`：UART 实例
* `cfg`：用于存储配置的结构体

**返回值**：

* `0`：成功
* `-1`：参数无效
* `-2`：IOCTL 错误

---

### `int drv_uart_configure_buffer_size(int id, uint16_t size);`

**功能**：配置指定 UART 设备的缓冲区大小。

**参数**：

* `id`：UART 设备 ID（如 0 表示 UART0，1 表示 UART1 等）
* `size`：要设置的缓冲区大小

**返回值**：

* `0`：成功
* `-1`：UART ID 无效或状态错误
* `-2`：设备未找到或配置失败

**注意**：应在创建实例之前调用此函数。

---

### `int drv_uart_get_id(drv_uart_inst_t *inst);`

**功能**：获取 UART 实例的 ID。

**参数**：

* `inst`：UART 实例

**返回值**：

* 有效时：UART ID
* 无效时：`-1`

---

### `int drv_uart_get_fd(drv_uart_inst_t *inst);`

**功能**：获取 UART 实例的文件描述符。

**参数**：

* `inst`：UART 实例

**返回值**：

* 有效时：文件描述符
* 无效时：`-1`

---

## 示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_uart.c`

---

## 注意事项

1. `struct uart_configure` 的 `bufsz` 字段只能通过 `drv_uart_configure_buffer_size` 接口修改，使用 `drv_uart_set_config` 无法修改`bufsz`。一般做法是先调用 `drv_uart_get_config` 获取当前配置，修改除 `bufsz` 外的其他参数，然后调用 `drv_uart_set_config`。

1. `drv_uart_configure_buffer_size` 必须在创建实例之前调用。

1. invert 字段在 K230 上不支持。
