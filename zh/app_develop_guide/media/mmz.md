# MMZ Demo

## 简介

本示例演示 MMZ 内存管理接口的常见流程：

- 分配 MMZ 内存（缓存/非缓存）
- 释放 MMZ 内存
- 按虚拟地址查询物理信息
- 缓存刷新

## 代码位置

- `src/rtsmart/examples/mpp/sample_mmz`

## 编译方法

在 `make menuconfig` 中使能：

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_mmz`

然后执行固件编译。

## 运行示例

```shell
cd /sdcard/app/examples/mpp
./sample_mmz.elf
```

## 说明

示例运行结束后会打印 `sample mmz test success` 或失败信息，便于快速定位 MMZ 调用链路问题。
