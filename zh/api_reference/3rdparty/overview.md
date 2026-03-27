# K230 第三方库参考

## 概述

K230 RT-Smart SDK 集成了一组常用第三方库，主要用于字体渲染、GUI、TLS/加密、HTTP、MQTT 以及云平台接入。这部分内容以第三方项目原始接口为主，SDK 侧主要负责构建集成、头文件导出和样例工程组织，因此不适合在本手册中重复展开完整 API。

本文档提供的是集成视角的简要说明，帮助用户确认：

- SDK 中集成了哪些第三方组件
- 对应源码位于哪里
- 需要打开哪些 Kconfig 选项
- 可以参考哪些示例
- 应优先阅读哪个官方文档

## 代码位置

- 第三方库源码：`src/rtsmart/libs/3rd-party`
- 第三方库构建入口：`src/rtsmart/libs/3rd-party/Makefile`
- 第三方样例入口：`src/rtsmart/examples/3rd-party/Makefile`
- 第三方库配置：`src/rtsmart/libs/3rd-party/Kconfig`
- 第三方样例配置：`src/rtsmart/examples/3rd-party/Kconfig`

## 已集成库

| 组件 | SDK 目录 | 使能配置 | 可选样例 / 测试 | 官方资料 |
| :-- | :-- | :-- | :-- | :-- |
| FreeType | `libs/3rd-party/freetype` | `RTSMART_3RD_PARTY_ENABLE_FREETYPE` | `examples/3rd-party/freetype/freetype_basic` | [FreeType Docs](https://freetype.org/freetype2/docs/) |
| LVGL | `libs/3rd-party/lvgl` | `RTSMART_3RD_PARTY_ENABLE_LVGL` | `examples/3rd-party/lvgl/lvgl_basic`, `lvgl_sensor` | [LVGL Docs](https://docs.lvgl.io/) |
| Mbed TLS | `libs/3rd-party/mbedtls` | `RTSMART_3RD_PARTY_ENABLE_MBEDTLS` | `RTSMART_3RD_PARTY_ENABLE_MBEDTLS_TESTS` | [Mbed TLS Docs](https://mbed-tls.readthedocs.io/) |
| MQTTClient | `libs/3rd-party/mqttclient` | `RTSMART_3RD_PARTY_ENABLE_MQTTCLIENT` | `RTSMART_LIBS_MQTTCLIENT_ENABLE_TESTS` | [Paho Embedded C](https://github.com/eclipse-paho/paho.mqtt.embedded-c) |
| miniHTTP | `libs/3rd-party/minihttp` | `RTSMART_3RD_PARTY_ENABLE_MINIHTTP` | `examples/3rd-party/minihttp/minihttp_basic`, `minihttp_advanced` | 请参考项目源码仓库与头文件说明 |
| Tuya IoT Core SDK | `libs/3rd-party/tuya-iot-core-sdk` | `RTSMART_3RD_PARTY_ENABLE_TUYALINKSDK` | `examples/3rd-party/tuya/tuya_basic` | [Tuya Developer Docs](https://developer.tuya.com/en/docs/iot-device-dev/TuyaOS-iot_abi?id=Kcoglhn5r7ajr) |
| OpenCV 样例 | SDK OpenCV 集成目录 | 样例配置 `RTSMART_3RD_PARTY_ENABLE_OPENCV_SAMPLES` | `examples/3rd-party/opencv` | [OpenCV Docs](https://www.bing.com/search?q=opencv+docs) |
| OpenBLAS 样例 | SDK OpenBLAS 集成目录 | 样例配置 `RTSMART_3RD_PARTY_ENABLE_OPENBLAS_SAMPLES` | `examples/3rd-party/openblas` | [OpenBLAS Docs](https://www.openblas.net/) |

## 使用建议

### 1. 先看 SDK 集成方式

如果你的目标是把第三方库接入 K230 工程，先阅读以下内容：

- `libs/3rd-party/Kconfig` 中的总开关和依赖关系
- `libs/3rd-party/Makefile` 中的构建子目录组织方式
- 对应样例目录中的 `Makefile`、`CMakeLists.txt` 和示例源码

### 2. 再看第三方官方文档

如果你的目标是学习库本身的 API，请优先阅读官方文档，而不是本 SDK 文档。原因是：

- 第三方库 API 规模通常远大于 SDK 自研接口
- 上游项目的 API 更新频率更高
- 官方文档通常包含更完整的参数、限制和迁移说明

### 3. 关注 SDK 侧差异

使用第三方库时，还需要关注 SDK 侧的几个差异点：

- 是否需要打开对应的 Kconfig 开关
- 是否提供了移植层或平台适配层
- 是否已有 K230 对应的样例可以直接运行
- 是否依赖其他组件，例如 Tuya 依赖 Mbed TLS

## 注意事项

- 本节不重复第三方项目的完整 API 手册，只提供 SDK 集成入口。
- 若官方文档与 SDK 中实际目录不一致，请以当前 SDK 中的头文件、Makefile 和示例工程为准。
- 如果你需要某个第三方库的 K230 专用说明，建议优先查看对应样例目录，因为那里通常最能反映当前可运行方式。

```{admonition} 提示
第三方库文档的最佳阅读顺序通常是：先看 SDK 的 Kconfig 和样例，再查该第三方项目的官方文档与 API 手册。
```
