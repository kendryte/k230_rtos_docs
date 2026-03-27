# GSDMA Demo

## 简介

本示例演示 GSDMA 的典型使用，包括 GDMA 图像处理路径与 SDMA 内存搬运路径，覆盖旋转、镜像、1D/2D 传输及对齐/非对齐场景。

## 代码位置

- `src/rtsmart/examples/mpp/sample_gsdma`

## 编译方法

在 `make menuconfig` 中使能：

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_gsdma`

然后执行固件编译。

## 运行示例

```shell
cd /sdcard/app/examples/mpp
./sample_gsdma.elf
```

## 说明

该示例会批量执行多组测试用例并打印通过/失败统计信息，可用于板级功能验证与回归测试。
