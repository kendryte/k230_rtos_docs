# Timer HAL 接口文档

## 硬件介绍

K230 内部集成了 6 路硬件定时器（Timer0~Timer5），支持向上计数模式。每个定时器可独立配置频率、周期和工作模式。同时提供软件定时器功能，基于 POSIX timer 实现，可用于对精度要求不高的定时场景。

---

## 数据结构说明

### `rt_hwtimer_info_t`

**描述**：定时器硬件特性信息。

- `maxfreq`：支持的最大计数频率
- `minfreq`：支持的最小计数频率
- `maxcnt`：计数器最大值
- `cntmode`：计数模式（HWTIMER_CNTMODE_UP：向上计数）

### `rt_hwtimer_mode_t`

**描述**：定时器工作模式枚举。

- `HWTIMER_MODE_ONESHOT`：单次触发模式
- `HWTIMER_MODE_PERIOD`：周期触发模式

### `timer_irq_callback`

**描述**：定时器中断回调函数类型。

```c
typedef void (*timer_irq_callback)(void* args);
```

---

## 硬件定时器接口

### `int drv_hard_timer_inst_create(int id, drv_hard_timer_inst_t** inst);`

**功能**：创建硬件定时器实例。

**参数**：

- `id`：定时器编号，范围 `[0, 5]`
- `inst`：用于存储创建的定时器实例指针

**返回值**：

- `0`：成功
- `负值`：失败

---

### `void drv_hard_timer_inst_destroy(drv_hard_timer_inst_t** inst);`

**功能**：销毁硬件定时器实例，释放资源。

**参数**：

- `inst`：定时器实例指针的指针

---

### `int drv_hard_timer_get_info(drv_hard_timer_inst_t* inst, rt_hwtimer_info_t* info);`

**功能**：获取定时器硬件特性信息。

**参数**：

- `inst`：定时器实例指针
- `info`：用于存储定时器信息的结构体指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_hard_timer_set_mode(drv_hard_timer_inst_t* inst, rt_hwtimer_mode_t mode);`

**功能**：设置定时器工作模式。必须在定时器停止状态下设置。

**参数**：

- `inst`：定时器实例指针
- `mode`：工作模式（单次或周期）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_hard_timer_set_freq(drv_hard_timer_inst_t* inst, uint32_t freq);`

**功能**：设置定时器计数频率。必须在定时器停止状态下设置。

**参数**：

- `inst`：定时器实例指针
- `freq`：计数频率（Hz），需在硬件支持的范围内

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_hard_timer_set_period(drv_hard_timer_inst_t* inst, uint32_t period_ms);`

**功能**：设置定时器周期。必须在定时器停止状态下设置。

**参数**：

- `inst`：定时器实例指针
- `period_ms`：定时周期（毫秒）

**返回值**：

- `0`：成功
- `-1`：失败（周期超出范围）

---

### `int drv_hard_timer_get_freq(drv_hard_timer_inst_t* inst, uint32_t* freq);`

**功能**：获取定时器当前计数频率。

**参数**：

- `inst`：定时器实例指针
- `freq`：用于存储频率值的指针（Hz）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_hard_timer_start(drv_hard_timer_inst_t* inst);`

**功能**：启动定时器。

**参数**：

- `inst`：定时器实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_hard_timer_stop(drv_hard_timer_inst_t* inst);`

**功能**：停止定时器。

**参数**：

- `inst`：定时器实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_hard_timer_register_irq(drv_hard_timer_inst_t* inst, timer_irq_callback callback, void* userargs);`

**功能**：注册定时器中断回调函数。必须在定时器停止状态下注册。

**参数**：

- `inst`：定时器实例指针
- `callback`：中断回调函数
- `userargs`：传递给回调函数的用户参数

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_hard_timer_unregister_irq(drv_hard_timer_inst_t* inst);`

**功能**：注销定时器中断回调。必须在定时器停止状态下注销。

**参数**：

- `inst`：定时器实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### 辅助函数

#### `int drv_hard_timer_get_id(drv_hard_timer_inst_t* inst);`

**功能**：获取定时器编号。

#### `int drv_hard_timer_is_started(drv_hard_timer_inst_t* inst);`

**功能**：查询定时器是否已启动。

---

## 软件定时器接口

### `int drv_soft_timer_create(drv_soft_timer_inst_t** inst);`

**功能**：创建软件定时器实例。系统只支持一个软件定时器实例。

**参数**：

- `inst`：用于存储创建的定时器实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `void drv_soft_timer_destroy(drv_soft_timer_inst_t** inst);`

**功能**：销毁软件定时器实例。

**参数**：

- `inst`：定时器实例指针的指针

---

### `int drv_soft_timer_set_mode(drv_soft_timer_inst_t* inst, rt_hwtimer_mode_t mode);`

**功能**：设置软件定时器工作模式。必须在定时器停止状态下设置。

**参数**：

- `inst`：定时器实例指针
- `mode`：工作模式（单次或周期）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_soft_timer_set_period(drv_soft_timer_inst_t* inst, int period_ms);`

**功能**：设置软件定时器周期。必须在定时器停止状态下设置。

**参数**：

- `inst`：定时器实例指针
- `period_ms`：定时周期（毫秒）

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_soft_timer_start(drv_soft_timer_inst_t* inst);`

**功能**：启动软件定时器。

**参数**：

- `inst`：定时器实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_soft_timer_stop(drv_soft_timer_inst_t* inst);`

**功能**：停止软件定时器。

**参数**：

- `inst`：定时器实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_soft_timer_register_irq(drv_soft_timer_inst_t* inst, timer_irq_callback callback, void* userargs);`

**功能**：注册软件定时器回调函数。必须在定时器停止状态下注册。

**参数**：

- `inst`：定时器实例指针
- `callback`：回调函数
- `userargs`：传递给回调函数的用户参数

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_soft_timer_unregister_irq(drv_soft_timer_inst_t* inst);`

**功能**：注销软件定时器回调。必须在定时器停止状态下注销。

**参数**：

- `inst`：定时器实例指针

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_soft_timer_is_started(drv_soft_timer_inst_t* inst);`

**功能**：查询软件定时器是否已启动。

**参数**：

- `inst`：定时器实例指针

**返回值**：

- `1`：已启动
- `0`：未启动

---

## 使用示例
