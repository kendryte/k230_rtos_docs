# MPP Log Demo

## 简介

本示例演示 MPP 日志接口的基本用法，包括：

- 设置模块日志等级
- 读取模块日志等级
- 设置日志读取等待策略
- 读取日志缓冲

## 代码位置

- `src/rtsmart/examples/mpp/sample_log`

## 编译方法

在 `make menuconfig` 中使能：

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_log`

然后执行固件编译。

## 运行示例

```shell
cd /sdcard/app/examples/mpp
./sample_log.elf
```

## 相关接口

- `kd_mpi_log_set_level_conf`
- `kd_mpi_log_get_level_conf`
- `kd_mpi_log_set_wait_flag`
- `kd_mpi_log_read`
