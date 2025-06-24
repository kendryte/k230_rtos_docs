# FPIOA HAL 接口文档

## 硬件介绍

K230 内部集成了 FPIOA（Field Programmable IO Array）控制器，用于管理芯片引脚的功能复用。该控制器支持最多 64 个引脚，每个引脚可配置多种不同的功能，包括但不限于 GPIO、UART、SPI、I2C、PWM 等外设功能。

---

## 数据结构说明

### `fpioa_func_t`

**描述**：定义所有可用的引脚功能，包括 GPIO0~GPIO63 以及各种外设功能（UART、SPI、I2C、PWM等）。

### `fpioa_iomux_cfg_t`

**描述**：引脚配置结构体，包含以下配置位：

- `st`：输入施密特触发器控制使能
- `ds`：驱动电流控制（4位）
- `pd`：下拉使能
- `pu`：上拉使能
- `oe`：输出使能
- `ie`：输入使能
- `msc`：电压选择
- `io_sel`：复用功能选择（3位）
- `di`：当前PAD输入数据

---

## 函数接口说明

### `int drv_fpioa_get_pin_cfg(int pin, uint32_t* value);`

**功能**：获取指定引脚的配置寄存器值。

**参数**：

- `pin`：引脚编号，范围 `[0, 63]`
- `value`：用于存储配置值的指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_fpioa_set_pin_cfg(int pin, uint32_t value);`

**功能**：设置指定引脚的配置寄存器值。

**参数**：

- `pin`：引脚编号，范围 `[0, 63]`
- `value`：要设置的配置值

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_fpioa_get_pin_func(int pin, fpioa_func_t* func);`

**功能**：获取指定引脚当前配置的功能。

**参数**：

- `pin`：引脚编号，范围 `[0, 63]`
- `func`：用于存储功能类型的指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_fpioa_set_pin_func(int pin, fpioa_func_t func);`

**功能**：设置指定引脚的功能。如果该功能已经分配给其他引脚，会先取消其他引脚的配置。

**参数**：

- `pin`：引脚编号，范围 `[0, 63]`
- `func`：要设置的功能类型

**返回值**：

- `0`：成功
- `-1`：失败（引脚不支持该功能）

---

### `int drv_fpioa_func_available_pins(fpioa_func_t func, int pins[FPIOA_PIN_FUNC_ALT_NUM]);`

**功能**：获取指定功能可以分配到的所有引脚。

**参数**：

- `func`：功能类型
- `pins`：用于存储引脚编号的数组，最多4个

**返回值**：

- 可用引脚的数量

---

### `int drv_fpioa_pin_supported_funcs(int pin, fpioa_func_t funcs[FPIOA_PIN_MAX_FUNCS]);`

**功能**：获取指定引脚支持的所有功能。

**参数**：

- `pin`：引脚编号，范围 `[0, 63]`
- `funcs`：用于存储功能类型的数组，最多5个

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_fpioa_get_func_name(fpioa_func_t func, char* buf, size_t buf_size);`

**功能**：获取指定功能的名称字符串。

**参数**：

- `func`：功能类型
- `buf`：用于存储名称的缓冲区
- `buf_size`：缓冲区大小

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_fpioa_get_pin_func_name(int pin, char* buf, size_t buf_size);`

**功能**：获取指定引脚当前功能的名称。

**参数**：

- `pin`：引脚编号
- `buf`：用于存储名称的缓冲区
- `buf_size`：缓冲区大小

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_fpioa_get_pin_alt_func_names(int pin, char* buf, size_t buf_size);`

**功能**：获取指定引脚所有可选功能的名称，以 "/" 分隔。

**参数**：

- `pin`：引脚编号
- `buf`：用于存储名称的缓冲区
- `buf_size`：缓冲区大小

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_fpioa_get_func_assigned_pin(fpioa_func_t func);`

**功能**：获取指定功能当前分配到的引脚编号。

**参数**：

- `func`：功能类型

**返回值**：

- `>=0`：分配该功能的引脚编号
- `-1`：该功能未分配或无效

---

### 引脚参数配置函数

以下函数用于配置引脚的电气特性参数：

#### `int drv_fpioa_set_pin_st(int pin, int value);`

**功能**：设置引脚的施密特触发器使能。

#### `int drv_fpioa_get_pin_st(int pin);`

**功能**：获取引脚的施密特触发器使能状态。

#### `int drv_fpioa_set_pin_ds(int pin, int value);`

**功能**：设置引脚的驱动电流强度（0-15）。

#### `int drv_fpioa_get_pin_ds(int pin);`

**功能**：获取引脚的驱动电流强度。

#### `int drv_fpioa_set_pin_pd(int pin, int value);`

**功能**：设置引脚的下拉电阻使能。

#### `int drv_fpioa_get_pin_pd(int pin);`

**功能**：获取引脚的下拉电阻使能状态。

#### `int drv_fpioa_set_pin_pu(int pin, int value);`

**功能**：设置引脚的上拉电阻使能。

#### `int drv_fpioa_get_pin_pu(int pin);`

**功能**：获取引脚的上拉电阻使能状态。

#### `int drv_fpioa_set_pin_oe(int pin, int value);`

**功能**：设置引脚的输出使能。

#### `int drv_fpioa_get_pin_oe(int pin);`

**功能**：获取引脚的输出使能状态。

#### `int drv_fpioa_set_pin_ie(int pin, int value);`

**功能**：设置引脚的输入使能。

#### `int drv_fpioa_get_pin_ie(int pin);`

**功能**：获取引脚的输入使能状态。

**参数**：

- `pin`：引脚编号，范围 `[0, 63]`
- `value`：要设置的值（0 或 1，ds 为 0-15）

**返回值**：

- `>=0`：成功（get 函数返回当前值）
- `-1`：失败

---

## 使用示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_fpioa.c`
