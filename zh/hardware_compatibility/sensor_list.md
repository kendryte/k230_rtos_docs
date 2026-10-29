# 图像传感器支持列表

当前 SDK 中已内置了多种不同型号图像传感器的驱动支持，列表如下（Timing 以各 Sensor 的 `sensor_csi*_mode_list.c` 为准）：

| 型号 | 支持 Timing List |
| :--- | :--- |
| GC2093 | 1920x1080@30、1920x1080@60、1280x960@90、1280x720@90 |
| OV5647 | 2592x1944@15、1920x1080@30、1280x960@45、1280x720@60、640x480@90、640x480@60 |
| IMX290 | 1920x1080@30 |
| IMX335 | 1920x1080@30（2-lane）、2592x1944@30（2-lane / 4-lane；4-lane 需 `CSI0 LANE NUM=4LANE` 并打开 `Enable 4LANE Configure`） |
| IMX415 | 3840x2160@30（仅 4-lane；需 `CSI0 LANE NUM=4LANE`） |
| IMX675 | 2592x1944@30 |
| SC130GS | 1280x1024@90（MONO） |
| SC132GS | 1080x1280@120、640x480@240（MONO） |
| XS9950 | 1280x720@25（YUV422） |
| BF3238 | 1920x1080@30、1280x960@30 |
| OV13850 | 3840x2160@7（2-lane）；4-lane：3840x2160@27、1920x1080@30、1920x1080@60、2112x1568@30、2112x1568@60（需 `CSI0 LANE NUM=4LANE` 并打开 `Enable 4LANE Configure`） |

> 注意：
>
> - 支持列表会随着代码迭代持续更新；板端以 `list_sensor` 输出为准
> - CSI0 默认 **2LANE**；选 **4LANE** 后可编入 CSI0 4-lane 模式。`Enable CSI1` 可继续编译，但运行时 CSI0 4LANE 与 CSI1 不能同时初始化（原厂接线仍共用 PHY）
> - 同分辨率 2L/4L 运行时用 `sample_vicap_sensor -lane 2|4`（或 `-stype`）区分，详见 [如何配置 Sensor](../userguide/how_to_configure_sensor.md)
> - 4K Sensor 限制：采集超过约 3072×2160 的 **YUV/RGB 预览**需 `VICAP_WORK_SW_TILE_MODE`，且通常仅一路 Sensor；`sample_vicap_sensor -ofmt 3`（RAW Dump）默认走 **ONLINE**（可用 `-tile 1` 强制 SW_TILE）。详见 [VICAP Sensor Demo](../app_develop_guide/media/vicap.md)。

## 相关文档

- [如何配置 Sensor](../userguide/how_to_configure_sensor.md)：menuconfig（含 **CSI0 LANE NUM**）、CSI/4LANE、应用层 `-lane` 匹配、ISP bin/XML 切换、`list_sensor` 验证
- [VICAP Sensor Demo](../app_develop_guide/media/vicap.md)：`sample_vicap_sensor` 参数、工作模式（含 `-ofmt 3` ONLINE）、Dump 用法
- [如何增加 Sensor](../advanced_development_guide/how_to_add_sensor.md)：从零接入新型号驱动、模式表、应用层对接
- [如何进行 ISP 标定](../advanced_development_guide/how_to_calibrate_isp.md)
- [如何进行 ISP 调优](../advanced_development_guide/how_to_tune_isp.md)

## 板端验证

确认镜像中已启用目标 Sensor 驱动后，可在板端执行 `list_sensor` 查看已支持的摄像头和模式，再运行对应的 VICAP/Sensor 示例进行验证。配置步骤详见 [如何配置 Sensor](../userguide/how_to_configure_sensor.md)。
