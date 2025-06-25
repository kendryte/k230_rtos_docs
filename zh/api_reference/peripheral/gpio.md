# GPIO HAL 接口文档

## 硬件介绍

k230 共有 2 路 gpio ，每路 gpio 包含 32 个gpio端口，共 64 个 gpio 端口，每个 gpio 端口均支持输入输出功能，支持上升沿中断，下降沿中断，高低电平中断，和双边沿中断。 k230 的每个 gpio 端口的中断相互独立互不影响。

---

## 数据结构说明

### `gpio_pin_edge_t`

**描述**：GPIO 中断触发边沿类型枚举。

- `GPIO_PE_RISING`：上升沿触发
- `GPIO_PE_FALLING`：下降沿触发
- `GPIO_PE_BOTH`：双边沿触发
- `GPIO_PE_HIGH`：高电平触发
- `GPIO_PE_LOW`：低电平触发

### `gpio_drive_mode_t`

**描述**：GPIO 驱动模式枚举。

- `GPIO_DM_OUTPUT`：输出模式
- `GPIO_DM_INPUT`：输入模式

### `gpio_pin_value_t`

**描述**：GPIO 引脚电平值枚举。

- `GPIO_PV_LOW`：低电平
- `GPIO_PV_HIGH`：高电平

### `drv_gpio_inst_t`

**描述**：GPIO 实例结构体，包含引脚配置和状态信息。

---

## 函数接口说明

### `int drv_gpio_inst_create(int pin, drv_gpio_inst_t** inst);`

**功能**：创建 GPIO 实例。创建前需确保对应引脚已通过 FPIOA 配置为 GPIO 功能。

**参数**：

- `pin`：GPIO 引脚编号，范围 `[0, 71]`
- `inst`：用于存储创建的 GPIO 实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `void drv_gpio_inst_destroy(drv_gpio_inst_t** inst);`

**功能**：销毁 GPIO 实例，释放资源。

**参数**：

- `inst`：GPIO 实例指针的指针

---

### `int drv_gpio_value_set(drv_gpio_inst_t* inst, gpio_pin_value_t val);`

**功能**：设置 GPIO 输出值（仅在输出模式下有效）。

**参数**：

- `inst`：GPIO 实例指针
- `val`：要设置的电平值（`GPIO_PV_LOW` 或 `GPIO_PV_HIGH`）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `gpio_pin_value_t drv_gpio_value_get(drv_gpio_inst_t* inst);`

**功能**：获取 GPIO 引脚当前电平值。

**参数**：

- `inst`：GPIO 实例指针

**返回值**：

- `GPIO_PV_LOW`：低电平
- `GPIO_PV_HIGH`：高电平

---

### `int drv_gpio_mode_set(drv_gpio_inst_t* inst, gpio_drive_mode_t mode);`

**功能**：设置 GPIO 工作模式。

**参数**：

- `inst`：GPIO 实例指针
- `mode`：工作模式（`GPIO_DM_OUTPUT` 或 `GPIO_DM_INPUT`）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `gpio_drive_mode_t drv_gpio_mode_get(drv_gpio_inst_t* inst);`

**功能**：获取 GPIO 当前工作模式。

**参数**：

- `inst`：GPIO 实例指针

**返回值**：

- `GPIO_DM_OUTPUT`：输出模式
- `GPIO_DM_INPUT`：输入模式
- `GPIO_DM_MAX`：获取失败

---

### `int drv_gpio_register_irq(drv_gpio_inst_t* inst, gpio_pin_edge_t mode, int debounce, gpio_irq_callback callback, void* userargs);`

**功能**：注册 GPIO 中断处理函数。仅支持引脚 0-63。

**参数**：

- `inst`：GPIO 实例指针
- `mode`：中断触发模式
- `debounce`：防抖时间（单位：ms，最小值为 10）
- `callback`：中断回调函数
- `userargs`：传递给回调函数的用户参数

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_gpio_unregister_irq(drv_gpio_inst_t* inst);`

**功能**：注销 GPIO 中断。

**参数**：

- `inst`：GPIO 实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_gpio_set_irq(drv_gpio_inst_t* inst, int enable);`

**功能**：使能或禁用 GPIO 中断。

**参数**：

- `inst`：GPIO 实例指针
- `enable`：`1` 使能，`0` 禁用

**返回值**：

- `0`：成功
- `-1`：失败

---

### 辅助函数

#### `int drv_gpio_get_pin_id(drv_gpio_inst_t* inst);`

**功能**：获取 GPIO 实例对应的引脚编号。

#### `int drv_gpio_toggle(drv_gpio_inst_t* inst);`

**功能**：翻转 GPIO 输出电平。

#### `int drv_gpio_enable_irq(drv_gpio_inst_t* inst);`

**功能**：使能 GPIO 中断（等同于 `drv_gpio_set_irq(inst, 1)`）。

#### `int drv_gpio_disable_irq(drv_gpio_inst_t* inst);`

**功能**：禁用 GPIO 中断（等同于 `drv_gpio_set_irq(inst, 0)`）。

**注意事项**：

1. 使用 GPIO 前必须先通过 FPIOA 将对应引脚配置为 GPIO 功能
1. 中断功能仅支持引脚 0-63
1. 防抖时间最小为 10ms

---

## 使用示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_gpio.c`
