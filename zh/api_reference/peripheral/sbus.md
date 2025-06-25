# SBUS HAL 接口文档

## 硬件介绍

K230 支持通过 UART 接口实现 SBUS（Serial Bus）协议。SBUS 是一种常用于遥控器接收机的串行通信协议，使用 100kbps 波特率，8 位数据位，2 位停止位，偶校验。支持 16 个通道（每通道 11 位精度），以及帧丢失和故障安全标志位。

---

## 数据结构说明

### `sbus_flag_t`

**描述**：SBUS 标志位结构体。

- `ch17`：数字通道 17 状态
- `ch18`：数字通道 18 状态
- `frame_lost`：帧丢失标志
- `failsafe`：故障安全标志

### `sbus_dev_t`

**描述**：SBUS 设备句柄类型。

---

## 函数接口说明

### `sbus_dev_t sbus_create(const char *uart);`

**功能**：创建 SBUS 设备实例，配置 UART 参数。

**参数**：

- `uart`：UART 设备路径，支持 "/dev/uart1" ~ "/dev/uart4"

**返回值**：

- 成功：返回 SBUS 设备句柄
- 失败：返回 `NULL`

---

### `void sbus_destroy(sbus_dev_t dev);`

**功能**：销毁 SBUS 设备实例，释放资源。

**参数**：

- `dev`：SBUS 设备句柄

---

### `int sbus_set_channel(sbus_dev_t dev, uint8_t channel_index, uint16_t value);`

**功能**：设置指定通道的值。

**参数**：

- `dev`：SBUS 设备句柄
- `channel_index`：通道索引，范围 `[0, 15]`
- `value`：通道值，11 位精度，典型范围 `[172, 1811]`，中位值 1024

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int sbus_set_all_channels(sbus_dev_t dev, uint16_t *channels);`

**功能**：设置所有 16 个通道的值。

**参数**：

- `dev`：SBUS 设备句柄
- `channels`：包含 16 个通道值的数组

**返回值**：

- `0`：成功
- `-1`：失败

---

### `void sbus_set_flags(sbus_dev_t dev, const sbus_flag_t *flags);`

**功能**：设置 SBUS 标志位。

**参数**：

- `dev`：SBUS 设备句柄
- `flags`：标志位结构体指针

---

### `void sbus_get_flags(sbus_dev_t dev, sbus_flag_t *flags_out);`

**功能**：获取当前 SBUS 标志位。

**参数**：

- `dev`：SBUS 设备句柄
- `flags_out`：用于存储标志位的结构体指针

---

### `void sbus_send_frame(sbus_dev_t dev);`

**功能**：发送 SBUS 数据帧。将当前设置的通道值和标志位编码成 25 字节的 SBUS 帧并通过 UART 发送。

**参数**：

- `dev`：SBUS 设备句柄

---

### `void sbus_set_debug(sbus_dev_t dev, bool val);`

**功能**：设置调试模式。调试模式下发送帧时会打印解码后的通道值和标志位。

**参数**：

- `dev`：SBUS 设备句柄
- `val`：`true` 开启调试，`false` 关闭调试

---

## 使用示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_sbus.c`

**注意事项**：

1. 使用前需要通过 FPIOA 配置相应的 UART TX 引脚
