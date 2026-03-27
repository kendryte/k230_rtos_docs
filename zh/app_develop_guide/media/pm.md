# PM Demo

## 简介

本示例用于验证电源管理（PM）用户态接口，支持查询/设置 governor、profile、热保护阈值、时钟与电源开关等操作。

## 代码位置

- `src/rtsmart/examples/mpp/sample_pm`

## 编译方法

在 `make menuconfig` 中使能：

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_pm`

然后执行固件编译。

## 运行示例

```shell
cd /sdcard/app/examples/mpp
./sample_pm.elf
```

程序会输出帮助信息：

```text
Usage: sample_pm func_index [opt]
```

常用示例：

```shell
# 查询 domain=0 的 governor
./sample_pm.elf 5 0

# 设置 domain=0 governor=1 (PERFORMANCE)
./sample_pm.elf 4 0 1

# 查询 domain=0 profile
./sample_pm.elf 7 0
```
