# K230 Third-Party Libraries Reference

## Overview

The K230 RT-Smart SDK integrates a set of commonly used third-party libraries, primarily used for font rendering, GUI, TLS/encryption, HTTP, MQTT, and cloud platform access. This section focuses on the original interfaces of the third-party projects, with the SDK side mainly responsible for build integration, header file export, and sample project organization. Therefore, it is not appropriate to repeat the complete API in this manual.

This document provides a brief explanation from an integration perspective, helping users confirm:

- Which third-party components are integrated in the SDK
- Where the corresponding source code is located
- Which Kconfig options need to be enabled
- Which examples can be referenced
- Which official documentation should be read first

## Code Location

- Third-party library source: `src/rtsmart/libs/3rd-party`
- Third-party library build entry: `src/rtsmart/libs/3rd-party/Makefile`
- Third-party sample entry: `src/rtsmart/examples/3rd-party/Makefile`
- Third-party library configuration: `src/rtsmart/libs/3rd-party/Kconfig`
- Third-party sample configuration: `src/rtsmart/examples/3rd-party/Kconfig`

## Integrated Libraries

| Component | SDK Directory | Enable Configuration | Optional Samples / Tests | Official Resources |
| :-- | :-- | :-- | :-- | :-- |
| NimBLE | `libs/3rd-party/nimble` | `RTSMART_3RD_PARTY_ENABLE_NIMBLE` | `examples/3rd-party/nimble/ble_peripheral` | [Bluetooth HCI and NimBLE Usage Guide](../../advanced_development_guide/how_to_use_bluetooth.md) |
| FreeType | `libs/3rd-party/freetype` | `RTSMART_3RD_PARTY_ENABLE_FREETYPE` | `examples/3rd-party/freetype/freetype_basic` | [FreeType Docs](https://freetype.org/freetype2/docs/) |
| cJSON | `libs/3rd-party/cjson` | `RTSMART_3RD_PARTY_ENABLE_CJSON` | `examples/3rd-party/cjson/cjson_basic` | [cJSON GitHub](https://github.com/DaveGamble/cJSON) |
| LVGL | `libs/3rd-party/lvgl` | `RTSMART_3RD_PARTY_ENABLE_LVGL` | `lvgl_basic`, `lvgl_sensor`, `lvgl_hid`, `lvgl_image_convert_test` | [LVGL Docs](https://docs.lvgl.io/) |
| VG-Lite HAL | `libs/rtsmart_hal/components/vg_lite` | `RTSMART_HAL_ENABLE_VG_LITE` | `examples/peripheral/vglite_tiger` | SDK built-in `vg_lite.h` |
| Mbed TLS | `libs/3rd-party/mbedtls` | `RTSMART_3RD_PARTY_ENABLE_MBEDTLS` | `RTSMART_3RD_PARTY_ENABLE_MBEDTLS_TESTS` | [Mbed TLS Docs](https://mbed-tls.readthedocs.io/) |
| libpeer (WebRTC) | `libs/3rd-party/libpeer` | `RTSMART_3RD_PARTY_ENABLE_LIBPEER` | `examples/mpp/sample_webrtc` (LAN camera) | [WebRTC](https://webrtc.org/) |
| libwebsockets | `libs/3rd-party/libwebsockets` | `RTSMART_3RD_PARTY_ENABLE_LIBWEBSOCKETS` | `examples/3rd-party/libwebsockets/ws_server`, `ws_client`, `ws_poll_test` | [libwebsockets Docs](https://libwebsockets.org/) |
| MQTTClient | `libs/3rd-party/mqttclient` | `RTSMART_3RD_PARTY_ENABLE_MQTTCLIENT` | `RTSMART_LIBS_MQTTCLIENT_ENABLE_TESTS` | [Paho Embedded C](https://github.com/eclipse-paho/paho.mqtt.embedded-c) |
| miniHTTP | `libs/3rd-party/minihttp` | `RTSMART_3RD_PARTY_ENABLE_MINIHTTP` | `examples/3rd-party/minihttp/minihttp_basic`, `minihttp_advanced` | Please refer to the project source repository and header file documentation |
| Tuya IoT Core SDK | `libs/3rd-party/tuya-iot-core-sdk` | `RTSMART_3RD_PARTY_ENABLE_TUYALINKSDK` | `examples/3rd-party/tuya/tuya_basic` | [Tuya Developer Docs](https://developer.tuya.com/en/docs/iot-device-dev/TuyaOS-iot_abi?id=Kcoglhn5r7ajr) |
| OpenCV Samples | SDK OpenCV integration directory | Sample configuration `RTSMART_3RD_PARTY_ENABLE_OPENCV_SAMPLES` | `examples/3rd-party/opencv` | [OpenCV Docs](https://www.bing.com/search?q=opencv+docs) |
| OpenBLAS Samples | SDK OpenBLAS integration directory | Sample configuration `RTSMART_3RD_PARTY_ENABLE_OPENBLAS_SAMPLES` | `examples/3rd-party/openblas` | [OpenBLAS Docs](http://www.openmathlib.org/OpenBLAS//) |

## Usage Recommendations

### 1. First Review the SDK Integration Approach

If your goal is to integrate a third-party library into a K230 project, please read the following content first:

- The master switches and dependency relationships in `libs/3rd-party/Kconfig`
- The build subdirectory organization in `libs/3rd-party/Makefile`
- The `Makefile`, `CMakeLists.txt`, and sample source code in the corresponding sample directories

### 2. Then Review the Third-Party Official Documentation

If your goal is to learn the API of the library itself, please prioritize the official documentation over this SDK documentation. The reasons are:

- Third-party library APIs are typically much larger in scale than SDK's proprietary interfaces
- Upstream project APIs are updated more frequently
- Official documentation usually contains more complete parameters, limitations, and migration notes

### 3. Pay Attention to SDK-side Differences

When using third-party libraries, you also need to pay attention to several SDK-side differences:

- Whether the corresponding Kconfig switch needs to be enabled
- Whether a porting layer or platform adaptation layer is provided
- Whether K230-specific samples are available and can be run directly
- Whether there are dependencies on other components, for example, Tuya depends on Mbed TLS

## Notes

- This section does not duplicate the complete API manual of third-party projects; it only provides SDK integration entry points.
- If the official documentation is inconsistent with the actual directories in the SDK, please refer to the header files, Makefile, and example projects in the current SDK.
- If you need K230-specific documentation for a third-party library, it is recommended to check the corresponding sample directory first, as it usually best reflects the current runnable approach.

```{admonition} Tip
The best reading order for third-party library documentation is usually: first look at the SDK's Kconfig and samples, then check the official documentation and API manual of the third-party project.
```
