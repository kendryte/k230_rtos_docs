# K230 Sensor API 参考

## 概述

Sensor API 用于完成图像传感器设备的打开、上电、初始化、模式切换、寄存器读写以及运行期参数调节。这组接口主要对应传感器驱动控制面，通常与 VICAP、ISP 一起使用。

当前 API 头文件位于 `src/rtsmart/mpp/userapps/api/mpi_sensor_api.h`，相关数据类型定义位于 `k_sensor_comm.h` 和 `k_vicap_comm.h`。

## 代码位置

- 头文件：`src/rtsmart/mpp/userapps/api/mpi_sensor_api.h`
- 相关类型：`src/rtsmart/mpp/include/comm/k_sensor_comm.h`
- VICAP 相关类型：`src/rtsmart/mpp/include/comm/k_vicap_comm.h`

## 功能分组

### 设备生命周期管理

用于打开、关闭、上电和初始化传感器设备。

- `kd_mpi_sensor_open()`
- `kd_mpi_sensor_close()`
- `kd_mpi_sensor_power_set()`
- `kd_mpi_sensor_init()`
- `kd_mpi_sensor_stream_enable()`

### 设备信息与模式管理

用于获取传感器 ID、能力、当前模式以及枚举可用模式。

- `kd_mpi_sensor_id_get()`
- `kd_mpi_sensor_mode_get()`
- `kd_mpi_sensor_mode_set()`
- `kd_mpi_sensor_mode_enum()`
- `kd_mpi_sensor_caps_get()`
- `kd_mpi_sensor_connection_check()`
- `kd_mpi_sensor_adapt_get()`
- `kd_mpi_adapt_sensor_get()`

### 寄存器访问

用于调试或对接特定传感器时直接访问寄存器。

- `kd_mpi_sensor_reg_read()`
- `kd_mpi_sensor_reg_write()`

### 曝光、增益与帧率控制

用于在运行过程中调整图像采集参数。

- `kd_mpi_sensor_again_set()`
- `kd_mpi_sensor_again_get()`
- `kd_mpi_sensor_dgain_set()`
- `kd_mpi_sensor_dgain_get()`
- `kd_mpi_sensor_intg_time_set()`
- `kd_mpi_sensor_intg_time_get()`
- `kd_mpi_sensor_fps_set()`
- `kd_mpi_sensor_fps_get()`

### ISP / 图像质量相关配置

用于设置或读取与图像质量相关的传感器侧参数。

- `kd_mpi_sensor_isp_status_get()`
- `kd_mpi_sensor_blc_set()`
- `kd_mpi_sensor_wb_set()`
- `kd_mpi_sensor_tpg_get()`
- `kd_mpi_sensor_tpg_set()`
- `kd_mpi_sensor_expand_curve_get()`
- `kd_mpi_sensor_mirror_set()`

### OTP 与对焦控制

用于访问 OTP 数据以及控制支持自动对焦的传感器模组。

- `kd_mpi_sensor_otpdata_get()`
- `kd_mpi_sensor_otpdata_set()`
- `kd_mpi_sensor_set_focus_pos()`
- `kd_mpi_sensor_get_focus_pos()`
- `kd_mpi_sensor_get_focus_caps()`
- `kd_mpi_sensor_set_focus_power()`

## 使用说明

典型调用顺序如下：

1. 调用 `kd_mpi_sensor_open()` 打开指定传感器。
1. 调用 `kd_mpi_sensor_power_set()` 完成上电。
1. 调用 `kd_mpi_sensor_init()` 根据目标模式初始化设备。
1. 根据需要调用 `kd_mpi_sensor_mode_set()`、`kd_mpi_sensor_fps_set()`、`kd_mpi_sensor_again_set()` 等接口调整参数。
1. 调用 `kd_mpi_sensor_stream_enable()` 使能或关闭数据输出。
1. 使用完成后调用 `kd_mpi_sensor_close()` 关闭设备。

## 注意事项

- `fd` 参数由 `kd_mpi_sensor_open()` 返回，后续大部分接口都依赖该句柄。
- 传感器的可用模式、增益范围、是否支持对焦等能力由具体 sensor 驱动决定。
- 这组接口偏向设备控制面，图像采集链路仍需结合 VICAP / ISP 配置。

```{admonition} 提示
如需查看完整参数类型和函数原型，请直接参考 `mpi_sensor_api.h`。如果是具体模组的寄存器或时序要求，请优先查阅对应 Sensor 原厂资料。
```
