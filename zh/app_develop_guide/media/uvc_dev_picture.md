# UVC Device Picture Demo

## 简介

本示例演示 UVC Device 设备端流程：

- 初始化 UVC Device
- 创建 UVC 输出缓冲池
- 将内置 JPEG 数据循环送入 UVC
- 持续输出并统计帧率

该示例适合用于验证设备端 UVC 链路，不依赖本地传感器采集。

## 代码位置

- `src/rtsmart/examples/mpp/sample_uvc_dev_picture`

## 编译方法

在 `make menuconfig` 中使能：

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_uvc_dev_picture`

然后执行固件编译。

## 运行示例

```shell
cd /sdcard/app/examples/mpp
./sample_uvc_dev_picture.elf
```

## 说明

- 程序启动后会持续推送内置 JPEG 数据。
- 使用 `Ctrl+C` 可触发优雅退出并打印统计信息。
