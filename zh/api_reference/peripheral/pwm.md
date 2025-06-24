# PWM HAL 接口文档

## 硬件介绍

K230 内部集成了 PWM 控制器，提供 2 路 PWM，共 6 个 Channel。其中 Channel 0 ~ 2 属于一路 PWM，Channel 3 ~5 属于另一路 PWM。**注意，同一路 PWM 只能使用相同的频率，但是占空比可以不同**。

---

## 函数接口说明

### `int drv_pwm_init(void);`

**功能**：初始化 PWM 驱动。

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_pwm_deinit(void);`

**功能**：反初始化 PWM 驱动，关闭设备。

**返回值**：

- `0`：成功

---

### `int drv_pwm_set_freq(int channel, uint32_t freq);`

**功能**：设置指定通道的 PWM 频率。设置频率时会保持当前占空比不变。

**参数**：

- `channel`：PWM 通道号，范围 `[0, 5]`
- `freq`：频率值（Hz），不能为 0

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_pwm_get_freq(int channel, uint32_t* freq);`

**功能**：获取指定通道的 PWM 频率。

**参数**：

- `channel`：PWM 通道号，范围 `[0, 5]`
- `freq`：用于存储频率值的指针（Hz）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_pwm_set_duty(int channel, uint32_t duty);`

**功能**：设置指定通道的 PWM 占空比。

**参数**：

- `channel`：PWM 通道号，范围 `[0, 5]`
- `duty`：占空比（%），范围 `[0, 100]`

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_pwm_get_duty(int channel, uint32_t* duty);`

**功能**：获取指定通道的 PWM 占空比。

**参数**：

- `channel`：PWM 通道号，范围 `[0, 5]`
- `duty`：用于存储占空比值的指针（%）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_pwm_enable(int channel);`

**功能**：使能指定通道的 PWM 输出。

**参数**：

- `channel`：PWM 通道号，范围 `[0, 5]`

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_pwm_disable(int channel);`

**功能**：禁用指定通道的 PWM 输出。

**参数**：

- `channel`：PWM 通道号，范围 `[0, 5]`

**返回值**：

- `0`：成功
- `-1`：失败

---

## 使用示例

请参考`src/rtsmart/libs/testcases/rtsmart_hal/test_pwm.c`

**注意事项**：

1. 使用 PWM 前需要通过 FPIOA 将对应引脚配置为 PWM 功能。
1. 同一路 PWM 只能使用相同的频率，但是占空比可以不同。
