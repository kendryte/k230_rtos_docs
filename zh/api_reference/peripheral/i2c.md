# I2C HAL 接口文档

## 硬件介绍

K230 共有 5 路 i2c，i2c 模块支持主从模式，支持DMA，支持7/10比特寻址，支持中断，i2c 模块传输速率支持100k/400k/1M/3.4M。

---

## 数据结构说明

### `drv_i2c_inst_t`

**描述**：I2C 主机实例结构体，包含 I2C 配置和状态信息。

### `i2c_msg_t`

**描述**：I2C 消息结构体。

- `addr`：设备地址
- `flags`：传输标志（读/写、10位地址等）
- `len`：数据长度
- `buf`：数据缓冲区指针

### `drv_i2c_slave_inst_t`

**描述**：I2C 从机实例结构体。

### I2C 传输标志

- `DRV_I2C_WR`：写操作
- `DRV_I2C_RD`：读操作
- `DRV_I2C_ADDR_10BIT`：10 位地址模式
- `DRV_I2C_NO_START`：不发送起始信号
- `DRV_I2C_IGNORE_NACK`：忽略 NACK
- `DRV_I2C_NO_READ_ACK`：读取时不发送 ACK
- `DRV_I2C_NO_STOP`：不发送停止信号

---

## I2C 主机模式接口

### `int drv_i2c_inst_create(int id, uint32_t freq, uint32_t timeout_ms, uint8_t scl, uint8_t sda, drv_i2c_inst_t** inst);`

**功能**：创建 I2C 主机实例。

**参数**：

- `id`：I2C 编号，0-4 为硬件 I2C，大于 4 为软件 I2C
- `freq`：I2C 时钟频率（Hz）
- `timeout_ms`：超时时间（毫秒）
- `scl`：SCL 引脚编号（软件 I2C 时有效，需小于 64）
- `sda`：SDA 引脚编号（软件 I2C 时有效，需小于 64）
- `inst`：用于存储创建的 I2C 实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `void drv_i2c_inst_destroy(drv_i2c_inst_t** inst);`

**功能**：销毁 I2C 主机实例，释放资源。

**参数**：

- `inst`：I2C 实例指针的指针

---

### `int drv_i2c_set_7b_addr(drv_i2c_inst_t* inst);`

**功能**：设置 I2C 为 7 位地址模式。

**参数**：

- `inst`：I2C 实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_i2c_set_10b_addr(drv_i2c_inst_t* inst);`

**功能**：设置 I2C 为 10 位地址模式。

**参数**：

- `inst`：I2C 实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_i2c_set_freq(drv_i2c_inst_t* inst, uint32_t freq);`

**功能**：设置 I2C 时钟频率。

**参数**：

- `inst`：I2C 实例指针
- `freq`：时钟频率（Hz）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_i2c_set_timeout(drv_i2c_inst_t* inst, uint32_t timeout_ms);`

**功能**：设置 I2C 超时时间。

**参数**：

- `inst`：I2C 实例指针
- `timeout_ms`：超时时间（毫秒）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_i2c_transfer(drv_i2c_inst_t* inst, i2c_msg_t* msgs, int msg_cnt);`

**功能**：执行 I2C 传输操作。

**参数**：

- `inst`：I2C 实例指针
- `msgs`：消息数组
- `msg_cnt`：消息数量

**返回值**：

- `0`：成功
- `-1`：失败

---

### I2C 主机属性获取函数

以下函数用于获取 I2C 主机实例的各种属性：

- `uint32_t drv_i2c_master_get_type(drv_i2c_inst_t* inst);` - 获取 I2C 类型（硬件/软件）
- `int drv_i2c_master_get_id(drv_i2c_inst_t* inst);` - 获取 I2C 编号
- `int drv_i2c_master_get_fd(drv_i2c_inst_t* inst);` - 获取文件描述符
- `uint32_t drv_i2c_master_get_freq(drv_i2c_inst_t* inst);` - 获取时钟频率
- `uint32_t drv_i2c_master_get_timeout_ms(drv_i2c_inst_t* inst);` - 获取超时时间
- `uint8_t drv_i2c_master_get_pin_scl(drv_i2c_inst_t* inst);` - 获取 SCL 引脚编号
- `uint8_t drv_i2c_master_get_pin_sda(drv_i2c_inst_t* inst);` - 获取 SDA 引脚编号

---

## I2C 从机模式接口

### `int drv_i2c_slave_inst_create(int id, uint32_t buffer_size, uint16_t slave_address, uint8_t scl, uint8_t sda, drv_i2c_slave_inst_t** inst);`

**功能**：创建 I2C 从机实例。

**参数**：

- `id`：I2C 编号
- `buffer_size`：缓冲区大小
- `slave_address`：从机地址
- `scl`：SCL 引脚编号
- `sda`：SDA 引脚编号
- `inst`：用于存储创建的从机实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### I2C 从机属性获取函数

- `int drv_i2c_slave_get_id(drv_i2c_slave_inst_t* inst);` - 获取 I2C 编号
- `int drv_i2c_slave_get_fd(drv_i2c_slave_inst_t* inst);` - 获取文件描述符
- `uint8_t drv_i2c_slave_get_pin_scl(drv_i2c_slave_inst_t* inst);` - 获取 SCL 引脚编号
- `uint8_t drv_i2c_slave_get_pin_sda(drv_i2c_slave_inst_t* inst);` - 获取 SDA 引脚编号
- `uint32_t drv_i2c_slave_get_buffer_size(drv_i2c_slave_inst_t* inst);` - 获取缓冲区大小
- `uint16_t drv_i2c_slave_get_slave_address(drv_i2c_slave_inst_t* inst);` - 获取从机地址

---

## 使用示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_i2c_ssd1306.c`

**注意事项**：

1. 使用硬件 I2C 前需要通过 FPIOA 配置相应引脚功能
