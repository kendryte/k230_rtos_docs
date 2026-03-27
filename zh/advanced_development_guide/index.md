# 高级开发指南

本章节面向 SDK 二次开发与平台适配，包含板级配置扩展、驱动移植、调试工具、内存布局和 OTA 等进阶主题。

本章将详细阐述如何基于 K230_SDK 增加新的开发板的配置文件和支持。当开发者基于 K230 或 K230D 芯片进行新开发板的研制时，SDK 包需要进行相应的调整与适配，本章将一步一步详细讲述如何增加新的defconfig。

若你的目标是“新增一个可用 Sensor”，建议按三步走：

1. **驱动接入**：先完成 Sensor 驱动和板级配置接入（主文档：`how_to_add_sensor.md`）
1. **标定**：完成 BLC/LSC/CC 标定（`how_to_calibrate_isp.md`）
1. **调优**：按业务目标做 ISP 参数调优（`how_to_tune_isp.md`）

```{toctree}
:maxdepth: 1

how_to_add_newconfig_file.md
how_to_change_otp.md
how_to_add_display.md
how_to_add_sensor.md
how_to_calibrate_isp.md
how_to_tune_isp.md
memory.md
how_to_use_adb.md
how_to_use_uvc_device.md
how_to_use_k230_ota.md
how_to_add_sensor.md
how_to_calibrate_isp.md
```
