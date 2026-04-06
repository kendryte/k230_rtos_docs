# USB HID 示例与测试说明

## 概述

RTOS SDK 提供了基于 `drv_input` 的 USB HID 输入访问方式，适用于键盘、鼠标和 USB 触摸类设备。当前仓库中已经提供了键盘与鼠标测试程序，可用于验证：

- 阻塞读取
- 非阻塞读取
- `poll()` 事件通知
- 设备断开后的自动重连流程

相关源码：

- `src/rtsmart/examples/peripheral/usb_hid_kbd/test_hid.c`
- `src/rtsmart/examples/peripheral/usb_hid_mouse/test_hid_mouse.c`

## 设备节点

常见设备节点如下：

- 键盘：`/dev/hidk0`
- 鼠标：`/dev/hidm0`
- USB 触摸：通常也会通过 `drv_input` 指针类接口暴露，具体节点名以系统实际注册结果为准

如果不确定具体节点，可在应用中调用 `drv_input_reconnect_by_type()` 自动查找同类设备。

## 键盘测试

### 源码位置

`src/rtsmart/examples/peripheral/usb_hid_kbd/test_hid.c`

### 示例内容

该示例包含 3 组测试：

1. 阻塞读：先 `drv_input_poll(inst, -1)`，再读取完整键盘帧
1. 非阻塞读：循环读取，验证无数据时的空读路径
1. `poll()` 读：以超时方式等待 `POLLIN`，再持续读出当前帧

### 运行方式

```shell
./test_hid [dev_path]
```

参数：

- `dev_path`：可选，默认 `/dev/hidk0`

### 典型输出

```text
=== Test 1: Blocking Read ===
Opening /dev/hidk0 in blocking mode...
Device opened successfully (fd=3)
Press keys on USB keyboard...
    EV_KEY: G -> PRESSED
    EV_KEY: G -> RELEASED
    EV_SYN: --- frame 1 end ---
```

### 热插拔行为

测试程序在 `poll()` 或 `read()` 返回断开错误时，会循环调用 `drv_input_reconnect_by_type()` 或 `drv_input_reconnect_path()`，直到设备重新出现。

## 鼠标测试

### 源码位置

`src/rtsmart/examples/peripheral/usb_hid_mouse/test_hid_mouse.c`

### 示例内容

鼠标测试同样包含 3 组测试：

1. 阻塞读
1. 非阻塞读
1. `poll()` 读

输出内容包括：

- 按键按下/释放
- 相对位移 `REL_X` / `REL_Y`
- 滚轮 `REL_WHEEL` / `REL_HWHEEL`
- 绝对坐标 `ABS_X` / `ABS_Y`
- 压力 `ABS_PRESSURE`

### 运行方式

```shell
./test_hid_mouse [dev_path]
```

参数：

- `dev_path`：可选，默认通常为 `/dev/hidm0`

### 典型输出

```text
=== Test 3: Poll Read ===
    EV_KEY: LEFT -> PRESSED
    EV_REL: REL_X -> 15
    EV_REL: REL_Y -> -4
    EV_SYN: --- frame end ---
```

## USB 触摸接入建议

`drv_input` 的指针帧结构同时兼容鼠标和 USB 触摸设备，因此如果你的 USB 触摸设备走 HID 协议，可以复用以下接口：

- `drv_input_poll()`
- `drv_input_read_pointer_frame()`
- `drv_input_reconnect_by_type(..., DRV_INPUT_DEV_TOUCH, ...)`

对 USB 触摸，通常重点关注：

- `has_abs`
- `abs_x` / `abs_y`
- `pressure`
- `touch_seen`
- `touch_down`

## 推荐开发流程

1. 先使用示例程序确认设备节点、热插拔和事件格式都正确。
1. 键盘设备使用 `drv_input_read_keyboard_frame()`。
1. 鼠标和 USB 触摸设备使用 `drv_input_read_pointer_frame()`。
1. 正式应用中建议结合 `drv_input_poll()` 与重连逻辑，而不是长时间死等单次读。

## 常见问题

### 键盘按键字符显示错误怎么办？

如果上层应用需要把键码转成字符，请不要假设 `KEY_A` 到 `KEY_Z` 是连续编号。Linux input event keycode 不是按字母顺序连续排列，应该使用显式映射表。

### 设备拔出后应用一直没有数据怎么办？

请在超时轮询或读失败时检查 `drv_input_is_disconnect_error(ret)`，并主动走重连逻辑。

## 相关文档

- [USB HID API 参考](../../api_reference/peripheral/usb_hid.md)
- [USB HID 键盘示例](usb_hid_kbd.md)
