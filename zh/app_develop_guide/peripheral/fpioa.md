# FPIOA 示例

## 简介

本示例用于导出当前板级 FPIOA 配置，自动生成可复用的 pinmux 配置代码片段。

源码位置：`src/rtsmart/examples/peripheral/fpioa/test_fpioa.c`

## 示例行为

- 读取 `IO0..IO63` 的寄存器配置
- 按 bank 推断电压域（`BANK_VOL_1V8_MSC` / `BANK_VOL_3V3_MSC`）
- 输出 `board_pinmux_cfg` 数组（可直接用于板级配置代码）
- 对异常配置给出 warning（如 bank 内 msc 不一致）

## 关键接口

- `drv_fpioa_get_pin_cfg()`
- `drv_fpioa_get_pin_func_name()`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/fpioa
make
./test_fpioa
```

该示例无命令行参数，结果输出到标准输出。

```{admonition} 提示
FPIOA 接口说明请参考 [FPIOA API 文档](../../api_reference/peripheral/fpioa.md)。
```
