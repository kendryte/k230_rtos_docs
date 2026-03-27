# 旋转编码器示例

## 简介

本示例演示旋转编码器事件的阻塞读取流程，包含旋转方向、累计计数与按键长按复位逻辑。

源码位置：`src/rtsmart/examples/peripheral/rotary_encoder/test_rotary_encoder.c`

## 示例行为

- 默认使用如下引脚创建编码器：
  - `clk_pin = 5`
  - `dt_pin = 42`
  - `sw_pin = 43`
- 调用 `rotary_encoder_wait_event()` 阻塞等待事件
- 打印 `delta`、`total_count`、方向、时间戳
- 按键长按 2 秒执行 `rotary_encoder_reset()`

## 运行参数

```shell
./test_rotary_encoder [timeout_ms]
```

- `timeout_ms`：阻塞等待超时，默认 `-1`（由示例逻辑处理）

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/rotary_encoder
make
./test_rotary_encoder
```

## 注意事项

1. 需使能 `CONFIG_ENABLE_ROTARY_ENCODER`，否则示例会提示配置未开启。
1. 引脚为示例默认值，和板卡连线不一致时需修改源码参数。

```{admonition} 提示
当前 API 参考中暂无独立 rotary 页面，可先参考 [外设 API 索引](../../api_reference/peripheral/index.md)。
```
