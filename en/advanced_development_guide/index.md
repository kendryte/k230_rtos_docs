# Advanced Development Guide

This chapter is intended for SDK secondary development and platform adaptation, covering advanced topics such as board-level configuration extension, driver porting, debugging tools, memory layout, and OTA.

This chapter will elaborate in detail on how to add configuration files and support for new development boards based on the K230_SDK. When developers design a new development board based on the K230 or K230D chip, the SDK package needs to be adjusted and adapted accordingly. This chapter will walk through step by step how to add a new defconfig.

If your goal is to "add a usable Sensor", it is recommended to follow three steps:

1. **Driver Integration**: First complete the Sensor driver and board-level configuration integration (main document: [`How to Add Sensor`](./how_to_add_sensor.md))
1. **Calibration**: Complete BLC/LSC/CC calibration (`how_to_calibrate_isp.md`)
1. **Tuning**: Perform ISP parameter tuning according to business objectives (`how_to_tune_isp.md`)

For enabling existing models and switching menuconfig / 4LANE / ISP, see the User's Guide: [How to Configure Sensor](../userguide/how_to_configure_sensor.md).

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
how_to_use_cklink_gdb.md
how_to_use_wifi.md
how_to_use_lwip.md
how_to_use_nat.md
how_to_use_aic8800.md
how_to_use_esp_hosted.md
how_to_use_bluetooth.md
how_to_use_k230_ota.md
how_to_use_secureboot.md
how_to_use_usb_otg.md
how_to_use_usb_net.md
how_to_use_uvc_device.md
```
