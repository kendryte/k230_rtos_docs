# WDT 示例

## 简介

本示例演示看门狗基础流程：设置超时、启动、周期喂狗，以及退出时停止或保持运行。

源码位置：`src/rtsmart/examples/peripheral/wdt/test_wdt.c`

## 示例行为

- 设置超时时间（1~60 秒）
- 启动 WDT 并周期调用 `wdt_feed()`
- Ctrl+C 退出时：
  - 默认执行 `wdt_stop()`
  - 若传入 `--no-stop`，则退出前仅喂狗不停止

## 关键接口

- `wdt_set_timeout()` / `wdt_get_timeout()`
- `wdt_start()` / `wdt_stop()`
- `wdt_feed()`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/wdt
make
```

运行：

```shell
./test_wdt <timeout_sec> [--no-stop]
```

示例：

```shell
./test_wdt 5
./test_wdt 10 --no-stop
```

```{admonition} 提示
WDT 接口细节请参考 [WDT API 文档](../../api_reference/peripheral/wdt.md)。
```
