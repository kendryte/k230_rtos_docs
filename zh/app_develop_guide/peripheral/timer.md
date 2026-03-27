# Timer 示例

## 简介

本示例是定时器驱动测试程序，覆盖硬件定时器与软件定时器的创建、参数配置、中断回调与启停流程。

源码位置：`src/rtsmart/examples/peripheral/timer/test_timer.c`

## 示例行为

- 硬件定时器测试：
  - 创建实例
  - 设置模式/频率/周期
  - 注册回调并验证触发次数
  - 查询运行状态与 ID
  - 停止并销毁
- 软件定时器测试：
  - oneshot 与 periodic 两种模式
  - 注册回调并验证触发
  - 停止、反注册并销毁

## 关键接口

- `drv_hard_timer_inst_create()` / `drv_hard_timer_inst_destroy()`
- `drv_hard_timer_set_mode()` / `drv_hard_timer_set_freq()` / `drv_hard_timer_set_period()`
- `drv_hard_timer_register_irq()` / `drv_hard_timer_start()` / `drv_hard_timer_stop()`
- `drv_soft_timer_create()` / `drv_soft_timer_destroy()`
- `drv_soft_timer_set_mode()` / `drv_soft_timer_set_period()`
- `drv_soft_timer_register_irq()` / `drv_soft_timer_start()` / `drv_soft_timer_stop()`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/timer
make
./test_timer
```

该示例无命令行参数。

```{admonition} 提示
定时器接口细节请参考 [Timer API 文档](../../api_reference/peripheral/timer.md)。
```
