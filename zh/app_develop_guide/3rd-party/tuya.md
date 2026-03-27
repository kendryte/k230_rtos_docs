# Tuya 基础示例

## 简介

本示例展示 Tuya IoT Core SDK 的基础连接与数据模型调用流程，包含：

- MQTT 初始化与连接
- 上线回调处理
- 属性上报与事件上报
- 消息回调处理

## 代码位置

- `src/rtsmart/examples/3rd-party/tuya/tuya_basic`

## 编译方法

在 `make menuconfig` 中使能相关 3rd-party 示例后，执行固件编译。

## 运行示例

```shell
cd /sdcard/app/examples/3rd-party/tuya
./tuya_basic.elf
```

## 使用前准备

请先在示例源码中配置有效设备信息：

- `productId`
- `deviceId`
- `deviceSecret`

对应位置见：

- `src/rtsmart/examples/3rd-party/tuya/tuya_basic/data_model_basic_demo.c`

## 说明

程序连接成功后会在回调中执行数据模型读取、期望值读取、属性上报与事件上报等演示逻辑。
