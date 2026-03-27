# PWM 示例

## 简介

本示例是 PWM HAL 功能测试程序，重点验证多通道同时输出、频率/占空比动态调整与读回校验。

源码位置：`src/rtsmart/examples/peripheral/pwm/test_pwm.c`

## 示例行为

- 将 `PWM0`/`PWM1` 分别映射到 `PIN42`/`PIN43`
- 初始化 PWM 后进行双通道同步输出测试
- 在运行时动态调整频率与占空比
- 执行同步/独立/快速切换等频率测试场景
- 最后禁用通道并反初始化

## 关键接口

- `drv_pwm_init()` / `drv_pwm_deinit()`
- `drv_pwm_set_freq()` / `drv_pwm_get_freq()`
- `drv_pwm_set_duty()` / `drv_pwm_get_duty()`
- `drv_pwm_enable()` / `drv_pwm_disable()`
- `drv_fpioa_set_pin_func()`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/pwm
make
./test_pwm
```

该示例无命令行参数。

```{admonition} 提示
PWM 接口细节请参考 [PWM API 文档](../../api_reference/peripheral/pwm.md)。
```
