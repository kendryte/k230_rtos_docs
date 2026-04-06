# USB HID API 参考

## 概述

RTOS SDK 中的 USB HID 输入接口由 `drv_input` 提供，统一抽象键盘、鼠标和 USB 触摸类输入设备。

头文件位置：

```c
#include "drv_input.h"
```

对应源码：

- `src/rtsmart/libs/rtsmart_hal/drivers/input/drv_input.h`
- `src/rtsmart/libs/rtsmart_hal/drivers/input/drv_input.c`

## 设备类型

```c
enum drv_input_device_type {
    DRV_INPUT_DEV_UNKNOWN = 0,
    DRV_INPUT_DEV_KEYBOARD,
    DRV_INPUT_DEV_MOUSE,
    DRV_INPUT_DEV_TOUCH,
};
```

## 关键数据结构

### `struct drv_input_info`

设备能力信息：

- `kind`：设备类型
- `ev_bits`：支持的事件位图
- `key_bits`：支持的按键位图
- `rel_bits`：支持的相对坐标位图
- `abs_bits`：支持的绝对坐标位图
- `name`：设备名称

### `drv_input_inst_t`

输入设备实例句柄，包含：

- `id`：设备编号
- `fd`：设备文件描述符
- `button_state`：当前按钮状态位
- `path`：设备路径

应用层只应把它当作句柄使用，不建议直接修改成员。

### `struct drv_keyboard_frame`

键盘帧：

- `keycodes[]`：按键码数组
- `values[]`：按键值数组，对应 `KEY_PRESSED` / `KEY_RELEASED` / `KEY_REPEAT`
- `count`：本帧事件数量
- `complete`：是否读到了同步结束事件

### `struct drv_pointer_frame`

指针帧，适用于鼠标和 USB 触摸设备：

- `complete`
- `has_rel`
- `has_abs`
- `touch_seen`
- `touch_down`
- `rel_x` / `rel_y`
- `wheel` / `hwheel`
- `abs_x` / `abs_y`
- `pressure`
- `buttons`
- `pressed_mask`
- `released_mask`

## 基础实例 API

### `drv_input_inst_create`

```c
int drv_input_inst_create(int id, drv_input_inst_t **inst);
```

按事件编号打开输入设备，例如 `event0`。

### `drv_input_inst_create_path`

```c
int drv_input_inst_create_path(const char *path, drv_input_inst_t **inst);
```

按路径打开输入设备，例如 `/dev/hidk0`。

### `drv_input_inst_destroy`

```c
void drv_input_inst_destroy(drv_input_inst_t **inst);
```

关闭并销毁实例。

## 读写 API

### `drv_input_poll`

```c
int drv_input_poll(drv_input_inst_t *inst, int timeout_ms);
```

等待输入事件。

返回值：

- `> 0`：有事件
- `0`：超时
- `< 0`：错误码

### `drv_input_read_event`

```c
int drv_input_read_event(drv_input_inst_t *inst, struct input_event *event);
```

读取单个原始 `input_event`。

### `drv_input_read_frame`

```c
int drv_input_read_frame(drv_input_inst_t *inst, struct drv_input_frame *frame);
```

读取一帧原始输入事件，直到遇到同步事件或无更多数据。

### `drv_input_read_keyboard_frame`

```c
int drv_input_read_keyboard_frame(drv_input_inst_t *inst, struct drv_keyboard_frame *frame);
```

读取键盘帧。

返回值：

- `> 0`：帧内键值对数量
- `0`：当前无完整键盘事件
- `< 0`：错误码

### `drv_input_read_pointer_frame`

```c
int drv_input_read_pointer_frame(drv_input_inst_t *inst, struct drv_pointer_frame *frame);
```

读取指针帧，用于鼠标和 USB 触摸。

## 信息与发现 API

### `drv_input_get_info`

```c
int drv_input_get_info(drv_input_inst_t *inst, struct drv_input_info *info);
```

查询设备能力信息。

### `drv_input_find_first_by_type`

```c
int drv_input_find_first_by_type(uint32_t kind,
                                 char *path,
                                 size_t path_size,
                                 struct drv_input_info *info);
```

查找首个指定类型输入设备，并返回路径与能力信息。

适用于以下场景：

- 启动时自动发现 USB 键盘
- 热插拔后重新绑定同类设备

## 热插拔相关 API

### `drv_input_is_disconnect_error`

```c
bool drv_input_is_disconnect_error(int ret);
```

判断某个错误码是否表示设备已断开。

当前主要识别以下错误：

- `-ENODEV`
- `-EIO`
- `-ENXIO`

### `drv_input_reconnect_path`

```c
int drv_input_reconnect_path(drv_input_inst_t **inst,
                             const char *path,
                             struct drv_input_info *info);
```

按固定路径重新打开设备。

### `drv_input_reconnect_by_type`

```c
int drv_input_reconnect_by_type(drv_input_inst_t **inst,
                                uint32_t kind,
                                char *path,
                                size_t path_size,
                                struct drv_input_info *info);
```

按设备类型重新发现并重连设备。

这是 USB HID 热插拔场景中最常用的接口。

## 事件辅助判断 API

### `drv_input_is_key_event`

```c
bool drv_input_is_key_event(const struct input_event *event);
```

### `drv_input_is_rel_event`

```c
bool drv_input_is_rel_event(const struct input_event *event);
```

### `drv_input_is_abs_event`

```c
bool drv_input_is_abs_event(const struct input_event *event);
```

### `drv_input_is_sync_event`

```c
bool drv_input_is_sync_event(const struct input_event *event);
```

用于判断原始 `input_event` 类型。

## 推荐调用流程

### 键盘

1. 使用 `drv_input_inst_create_path()` 或 `drv_input_reconnect_by_type()` 打开设备
1. 调用 `drv_input_poll()` 等待数据
1. 调用 `drv_input_read_keyboard_frame()` 读取帧
1. 如果返回错误，使用 `drv_input_is_disconnect_error()` 判断是否需要重连
1. 退出时调用 `drv_input_inst_destroy()`

### 鼠标 / USB 触摸

1. 打开输入实例
1. 调用 `drv_input_poll()` 等待数据
1. 调用 `drv_input_read_pointer_frame()` 读取指针帧
1. 使用 `has_rel` / `has_abs` / `buttons` / `touch_down` 等字段处理输入
1. 断开时执行重连

## 示例代码片段

```c
drv_input_inst_t *inst = NULL;
struct drv_input_info info;

if (drv_input_reconnect_by_type(&inst,
                                DRV_INPUT_DEV_KEYBOARD,
                                NULL,
                                0,
                                &info) == 0) {
    printf("keyboard ready: %s\n", info.name);
}
```

```c
struct drv_keyboard_frame frame;
int ret = drv_input_read_keyboard_frame(inst, &frame);
if (ret > 0) {
    for (size_t i = 0; i < frame.count; i++) {
        printf("key=%u value=%d\n", frame.keycodes[i], frame.values[i]);
    }
}
```

## 注意事项

1. 不要把 Linux input keycode 当作连续字符编号处理，特别是字母键。
1. 对热插拔设备，建议始终结合 `drv_input_is_disconnect_error()` 和 `drv_input_reconnect_by_type()`。
1. 键盘和指针设备的读取接口不同，不要混用 `drv_input_read_keyboard_frame()` 与 `drv_input_read_pointer_frame()`。

## 相关文档

- [USB HID 示例与测试说明](../../app_develop_guide/peripheral/usb_hid.md)
