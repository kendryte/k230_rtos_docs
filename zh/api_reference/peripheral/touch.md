# K230 Touch API 参考

## 概述

K230 的触摸能力由两部分组成：

- 触摸设备管理：通过 canmv_misc 动态注册/删除触摸设备
- 触摸读写 HAL：通过 drv_touch 实例读取触摸点与设备信息

相关头文件：

- `src/rtsmart/libs/rtsmart_hal/components/canmv_misc/canmv_misc.h`
- `src/rtsmart/libs/rtsmart_hal/drivers/touch/drv_touch.h`

## 关键数据结构

### `struct drv_touch_config_t`

用于创建触摸设备时传入硬件配置：

- `touch_dev_index`：设备索引
- `range_x` / `range_y`：坐标范围（0 可交由系统默认）
- `pin_intr` / `intr_value`：中断引脚与有效电平（无中断时可用 `-1`）
- `pin_reset` / `reset_value`：复位引脚与有效电平（无复位时可用 `-1`）
- `i2c_bus_index` / `i2c_bus_speed`：I2C 总线号与速率

### `struct drv_touch_data`

单个触点数据：

- `event`：事件类型（`NONE`/`UP`/`DOWN`/`MOVE`）
- `track_id`：触点追踪 ID
- `x_coordinate` / `y_coordinate`：触点坐标
- `width`：触点宽度
- `timestamp`：时间戳

### `struct drv_touch_info`

设备能力信息：

- `type`：触摸类型
- `vendor`：厂商信息
- `point_num`：最大触点数
- `range_x` / `range_y`：坐标范围

## 设备管理 API（canmv_misc）

### `canmv_misc_create_touch_device`

```c
int canmv_misc_create_touch_device(struct drv_touch_config_t* cfg);
```

按 `cfg` 注册一个触摸设备。

- 返回值：`0` 成功，非 `0` 失败。

### `canmv_misc_delete_touch_device`

```c
int canmv_misc_delete_touch_device(int index);
```

按索引注销触摸设备。

- 返回值：`0` 成功，非 `0` 失败。

## 读写 HAL API（drv_touch）

### `drv_touch_inst_create`

```c
int drv_touch_inst_create(int id, drv_touch_inst_t** inst);
```

创建触摸实例。

- 常见错误：`-1` 参数错误，`-2` 设备 ID 无效，`-3` 内存不足。

### `drv_touch_inst_destroy`

```c
void drv_touch_inst_destroy(drv_touch_inst_t** inst);
```

销毁实例并释放资源。

### `drv_touch_read`

```c
int drv_touch_read(drv_touch_inst_t* inst, struct drv_touch_data* touch_data, int max_points);
```

读取触摸点。

- 返回值：`>0` 表示触点数量，`0` 无事件，`<0` 错误（常见 `-1/-2`）。

### `drv_touch_get_info`

```c
int drv_touch_get_info(drv_touch_inst_t* inst, struct drv_touch_info* info);
```

查询设备能力信息。

### `drv_touch_get_config`

```c
int drv_touch_get_config(drv_touch_inst_t* inst, struct drv_touch_config_t* cfg);
```

查询当前设备配置。

### `drv_touch_reset`

```c
int drv_touch_reset(drv_touch_inst_t* inst);
```

执行触摸设备复位。

### `drv_touch_get_default_rotate`

```c
int drv_touch_get_default_rotate(drv_touch_inst_t* inst, int* rotate);
```

读取默认旋转配置（`0/90/180/270/swap_xy`）。

## 推荐调用流程

1. 如需动态创建设备，先调用 `canmv_misc_create_touch_device()`。
1. 调用 `drv_touch_inst_create()` 打开实例。
1. 先调用 `drv_touch_get_info()` / `drv_touch_get_config()` 确认能力与坐标范围。
1. 循环调用 `drv_touch_read()` 读取触点事件。
1. 退出时调用 `drv_touch_inst_destroy()`。
1. 若是动态创建的设备，最后调用 `canmv_misc_delete_touch_device()`。

## 参考示例

- `src/rtsmart/examples/peripheral/touch/test_touch.c`
