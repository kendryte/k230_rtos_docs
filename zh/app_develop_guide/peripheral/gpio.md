# GPIO 示例

## 简介

本示例是 GPIO HAL 回归测试程序，覆盖实例创建、模式切换、电平读写、翻转与中断注册等核心能力。

源码位置：`src/rtsmart/examples/peripheral/gpio/test_gpio.c`

## 示例行为

- 使用 FPIOA 将测试引脚映射为 GPIO 功能
- 测试 GPIO 实例创建/销毁及异常参数
- 测试输入/输出模式切换与状态读取
- 测试高低电平写入与 `toggle`
- 测试中断注册、触发与反注册流程

## 关键接口

- `drv_fpioa_set_pin_func()`
- `drv_gpio_inst_create()` / `drv_gpio_inst_destroy()`
- `drv_gpio_mode_set()` / `drv_gpio_mode_get()`
- `drv_gpio_value_set()` / `drv_gpio_value_get()` / `drv_gpio_toggle()`
- `drv_gpio_register_irq()` / `drv_gpio_unregister_irq()`（由示例中断测试覆盖）

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/gpio
make
./test_gpio
```

该示例无命令行参数。

```{admonition} 提示
GPIO 接口细节请参考 [GPIO API 文档](../../api_reference/peripheral/gpio.md)。
```
