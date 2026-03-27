# OTA 示例

## 简介

本示例演示将 `kdimg` 镜像文件分块写入 OTA 设备的基础流程。

源码位置：`src/rtsmart/examples/peripheral/ota/test_ota.c`

## 示例行为

- 默认镜像路径：`/data/ota_test.kdimg`
- 可通过命令行传入镜像路径覆盖默认值
- 以 `64KB` 块大小循环读取镜像并调用 `k230_ota_update()` 写入
- 写入完成后释放资源并退出

## 关键接口

- `k230_ota_create()`
- `k230_ota_update()`
- `k230_ota_destroy()`

## 编译与运行

```shell
cd src/rtsmart/examples/peripheral/ota
make
```

运行：

```shell
./test_ota [image_path]
```

示例：

```shell
./test_ota
./test_ota /sdcard/update.kdimg
```

## 注意事项

1. 示例本身不负责网络下载、签名校验与版本策略，这些应在上层流程中完成。
1. OTA 写入过程请避免断电。

```{admonition} 提示
OTA 接口与推荐调用顺序请参考 [OTA API 文档](../../api_reference/peripheral/ota.md)。
```
