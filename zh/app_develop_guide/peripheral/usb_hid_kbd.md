# USB HID 键盘示例

## 简介

本示例演示 HID 键盘输入设备的三类读取方式：阻塞读、非阻塞读和 `poll` 事件通知。

源码位置：`src/rtsmart/examples/peripheral/usb_hid_kbd/test_hid.c`

## 示例行为

- 默认设备节点：`/dev/hidk0`
- Test1：阻塞读，等待按键事件帧
- Test2：非阻塞读，验证 `EAGAIN` 分支
- Test3：`poll()` 等待 `POLLIN` 后读取事件
- 打印常见按键名称与按下/释放状态

## 运行参数

```shell
./test_hid [dev_path]
```

- `dev_path`：HID 设备节点，默认 `/dev/hidk0`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/usb_hid_kbd
make
./test_hid
```

```{admonition} 提示
当前 API 参考中暂无独立 HID 键盘页面，可先参考 [外设 API 索引](../../api_reference/peripheral/index.md)。
```
