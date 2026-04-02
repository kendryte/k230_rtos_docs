# K230 Sensor API 参考

## 概述

Sensor API 用于完成图像传感器设备的打开、上电、初始化、模式切换、寄存器读写以及运行期参数调节。这组接口主要对应传感器驱动控制面，通常与 VICAP、ISP 一起使用。

当前 API 头文件位于 `src/rtsmart/mpp/userapps/api/mpi_sensor_api.h`，相关数据类型定义位于 `k_sensor_comm.h` 和 `k_vicap_comm.h`。

## 代码位置

- 头文件：`src/rtsmart/mpp/userapps/api/mpi_sensor_api.h`
- 相关类型：`src/rtsmart/mpp/include/comm/k_sensor_comm.h`
- VICAP 相关类型：`src/rtsmart/mpp/include/comm/k_vicap_comm.h`

## 快速索引

### 设备生命周期管理

- [kd_mpi_sensor_open](#kd_mpi_sensor_open)
- [kd_mpi_sensor_close](#kd_mpi_sensor_close)
- [kd_mpi_sensor_power_set](#kd_mpi_sensor_power_set)
- [kd_mpi_sensor_init](#kd_mpi_sensor_init)
- [kd_mpi_sensor_stream_enable](#kd_mpi_sensor_stream_enable)

### 设备信息与模式管理

- [kd_mpi_sensor_id_get](#kd_mpi_sensor_id_get)
- [kd_mpi_sensor_mode_get](#kd_mpi_sensor_mode_get)
- [kd_mpi_sensor_mode_set](#kd_mpi_sensor_mode_set)
- [kd_mpi_sensor_mode_enum](#kd_mpi_sensor_mode_enum)
- [kd_mpi_sensor_caps_get](#kd_mpi_sensor_caps_get)
- [kd_mpi_sensor_connection_check](#kd_mpi_sensor_connection_check)
- [kd_mpi_sensor_adapt_get](#kd_mpi_sensor_adapt_get)

### 寄存器访问

- [kd_mpi_sensor_reg_read](#kd_mpi_sensor_reg_read)
- [kd_mpi_sensor_reg_write](#kd_mpi_sensor_reg_write)

### 曝光与增益控制

- [kd_mpi_sensor_again_set](#kd_mpi_sensor_again_set)
- [kd_mpi_sensor_again_get](#kd_mpi_sensor_again_get)
- [kd_mpi_sensor_dgain_set](#kd_mpi_sensor_dgain_set)
- [kd_mpi_sensor_dgain_get](#kd_mpi_sensor_dgain_get)
- [kd_mpi_sensor_intg_time_set](#kd_mpi_sensor_intg_time_set)
- [kd_mpi_sensor_intg_time_get](#kd_mpi_sensor_intg_time_get)
- [kd_mpi_sensor_get_exposure_time_range](#kd_mpi_sensor_get_exposure_time_range)
- [kd_mpi_sensor_get_gain_range](#kd_mpi_sensor_get_gain_range)

### 帧率控制

- [kd_mpi_sensor_fps_set](#kd_mpi_sensor_fps_set)
- [kd_mpi_sensor_fps_get](#kd_mpi_sensor_fps_get)

### 图像质量控制

- [kd_mpi_sensor_isp_status_get](#kd_mpi_sensor_isp_status_get)
- [kd_mpi_sensor_blc_set](#kd_mpi_sensor_blc_set)
- [kd_mpi_sensor_wb_set](#kd_mpi_sensor_wb_set)
- [kd_mpi_sensor_tpg_set](#kd_mpi_sensor_tpg_set)
- [kd_mpi_sensor_tpg_get](#kd_mpi_sensor_tpg_get)
- [kd_mpi_sensor_expand_curve_get](#kd_mpi_sensor_expand_curve_get)
- [kd_mpi_sensor_mirror_set](#kd_mpi_sensor_mirror_set)

### OTP 与对焦控制

- [kd_mpi_sensor_otpdata_get](#kd_mpi_sensor_otpdata_get)
- [kd_mpi_sensor_otpdata_set](#kd_mpi_sensor_otpdata_set)
- [kd_mpi_sensor_set_focus_pos](#kd_mpi_sensor_set_focus_pos)
- [kd_mpi_sensor_get_focus_pos](#kd_mpi_sensor_get_focus_pos)
- [kd_mpi_sensor_get_focus_caps](#kd_mpi_sensor_get_focus_caps)
- [kd_mpi_sensor_set_focus_power](#kd_mpi_sensor_set_focus_power)

### 信息查询接口

- [kd_mpi_sensor_list_mode](#kd_mpi_sensor_list_mode)
- [kd_mpi_sensor_get_exposure_time_range](#kd_mpi_sensor_get_exposure_time_range)
- [kd_mpi_sensor_get_gain_range](#kd_mpi_sensor_get_gain_range)
- [kd_mpi_sensor_get_focus_caps](#kd_mpi_sensor_get_focus_caps)

---

## 接口详细说明

### 设备生命周期管理

#### kd_mpi_sensor_open

打开传感器设备。

**函数原型**

```c
k_s32 kd_mpi_sensor_open(const char *sensor_name);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `sensor_name` | `const char*` | 传感器名称（如 "gc2093_csi2"） | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `>= 0` | 传感器文件描述符（fd） |
| `< 0` | 失败，返回错误码 |

**注意事项**

- 返回的 fd 用于后续所有 sensor 操作
- 使用完成后必须调用 `kd_mpi_sensor_close()` 关闭设备
- 传感器名称必须与驱动中注册的名称匹配

**示例**

```c
k_s32 fd = kd_mpi_sensor_open("gc2093_csi2");
if (fd < 0) {
    printf("Failed to open sensor\n");
    return -1;
}
// 使用 fd 进行后续操作
kd_mpi_sensor_close(fd);
```

---

#### kd_mpi_sensor_close

关闭传感器设备。

**函数原型**

```c
k_s32 kd_mpi_sensor_close(k_s32 fd);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 关闭后 fd 不再有效
- 必须与 `kd_mpi_sensor_open()` 配对使用

---

#### kd_mpi_sensor_power_set

设置传感器电源状态。

**函数原型**

```c
k_s32 kd_mpi_sensor_power_set(k_s32 fd, k_bool on);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `on` | `k_bool` | K_TRUE: 上电，K_FALSE: 断电 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 上电后才能进行初始化和配置
- 断电前确保已停止数据流

---

#### kd_mpi_sensor_init

初始化传感器设备。

**函数原型**

```c
k_s32 kd_mpi_sensor_init(k_s32 fd, k_sensor_mode mode);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `mode` | `k_sensor_mode` | 传感器工作模式配置 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 必须在上电后调用
- mode 结构体需要正确配置分辨率、帧率等参数

---

#### kd_mpi_sensor_stream_enable

使能或禁用传感器数据流。

**函数原型**

```c
k_s32 kd_mpi_sensor_stream_enable(k_s32 fd, k_s32 enable);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `enable` | `k_s32` | 1: 使能，0: 禁用 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 使能后传感器开始输出图像数据
- 禁用后停止输出，但保持配置

---

### 设备信息与模式管理

#### kd_mpi_sensor_id_get

获取传感器 ID。

**函数原型**

```c
k_s32 kd_mpi_sensor_id_get(k_s32 fd, k_u32 *sensor_id);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `sensor_id` | `k_u32*` | 输出传感器 ID | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_mode_get

获取当前传感器模式配置。

**函数原型**

```c
k_s32 kd_mpi_sensor_mode_get(k_s32 fd, k_sensor_mode *mode);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `mode` | `k_sensor_mode*` | 输出模式配置 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_mode_set

设置传感器工作模式。

**函数原型**

```c
k_s32 kd_mpi_sensor_mode_set(k_s32 fd, k_sensor_mode mode);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `mode` | `k_sensor_mode` | 模式配置 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 某些模式切换可能需要重启数据流

---

#### kd_mpi_sensor_mode_enum

枚举传感器支持的模式。

**函数原型**

```c
k_s32 kd_mpi_sensor_mode_enum(k_s32 fd, k_sensor_enum_mode *enum_mode);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `enum_mode` | `k_sensor_enum_mode*` | 枚举模式信息 | 输入/输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_caps_get

获取传感器能力信息。

**函数原型**

```c
k_s32 kd_mpi_sensor_caps_get(k_s32 fd, k_sensor_caps *caps);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `caps` | `k_sensor_caps*` | 输出能力信息 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_connection_check

检查传感器连接状态。

**函数原型**

```c
k_s32 kd_mpi_sensor_connection_check(k_s32 fd, k_s32 *connection);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `connection` | `k_s32*` | 输出连接状态（1: 已连接，0: 未连接） | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_adapt_get

根据配置获取传感器信息。

**函数原型**

```c
k_s32 kd_mpi_sensor_adapt_get(k_vicap_probe_config *config, k_vicap_sensor_info *info);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `config` | `k_vicap_probe_config*` | 探测配置（CSI 编号、分辨率、帧率） | 输入 |
| `info` | `k_vicap_sensor_info*` | 输出传感器信息 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

### 寄存器访问

#### kd_mpi_sensor_reg_read

读取传感器寄存器。

**函数原型**

```c
k_s32 kd_mpi_sensor_reg_read(k_s32 fd, k_u32 reg_addr, k_u32 *reg_val);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `reg_addr` | `k_u32` | 寄存器地址 | 输入 |
| `reg_val` | `k_u32*` | 输出寄存器值 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 用于调试或特殊配置
- 寄存器地址和位宽因传感器而异

---

#### kd_mpi_sensor_reg_write

写入传感器寄存器。

**函数原型**

```c
k_s32 kd_mpi_sensor_reg_write(k_s32 fd, k_u32 reg_addr, k_u32 reg_val);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `reg_addr` | `k_u32` | 寄存器地址 | 输入 |
| `reg_val` | `k_u32` | 寄存器值 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 错误的寄存器配置可能导致传感器工作异常
- 建议参考传感器数据手册

---

### 曝光与增益控制

#### kd_mpi_sensor_again_set

设置模拟增益（Again）。

**函数原型**

```c
k_s32 kd_mpi_sensor_again_set(k_s32 fd, k_sensor_gain gain);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `gain` | `k_sensor_gain` | 增益值结构体 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 增益值必须在传感器支持范围内
- 建议先调用 `kd_mpi_sensor_get_gain_range()` 获取范围

**示例**

```c
k_sensor_gain gain;
gain.gain[0] = 2.0f;  // 设置增益为 2.0
k_s32 ret = kd_mpi_sensor_again_set(fd, gain);
```

---

#### kd_mpi_sensor_again_get

获取当前模拟增益值。

**函数原型**

```c
k_s32 kd_mpi_sensor_again_get(k_s32 fd, k_sensor_gain *gain);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `gain` | `k_sensor_gain*` | 输出增益值 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_dgain_set

设置数字增益（Dgain）。

**函数原型**

```c
k_s32 kd_mpi_sensor_dgain_set(k_s32 fd, k_sensor_gain gain);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `gain` | `k_sensor_gain` | 增益值结构体 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_dgain_get

获取当前数字增益值。

**函数原型**

```c
k_s32 kd_mpi_sensor_dgain_get(k_s32 fd, k_sensor_gain *gain);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `gain` | `k_sensor_gain*` | 输出增益值 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_intg_time_set

设置积分时间（曝光时间）。

**函数原型**

```c
k_s32 kd_mpi_sensor_intg_time_set(k_s32 fd, k_sensor_intg_time time);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `time` | `k_sensor_intg_time` | 积分时间结构体（单位：秒） | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 积分时间必须在传感器支持范围内
- 建议先调用 `kd_mpi_sensor_get_exposure_time_range()` 获取范围

**示例**

```c
k_sensor_intg_time time;
time.intg_time[0] = 0.01f;  // 10ms
k_s32 ret = kd_mpi_sensor_intg_time_set(fd, time);
```

---

#### kd_mpi_sensor_intg_time_get

获取当前积分时间。

**函数原型**

```c
k_s32 kd_mpi_sensor_intg_time_get(k_s32 fd, k_sensor_intg_time *time);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `time` | `k_sensor_intg_time*` | 输出积分时间 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_get_exposure_time_range

获取曝光时间范围。需要在start之后调用

**函数原型**

```c
k_s32 kd_mpi_sensor_get_exposure_time_range(k_s32 fd, k_sensor_exposure_time_range *range);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `range` | `k_sensor_exposure_time_range*` | 输出曝光范围（单位：微秒） | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**示例**

```c
k_sensor_exposure_time_range range;
k_s32 ret = kd_mpi_sensor_get_exposure_time_range(fd, &range);
if (ret == 0) {
    printf("Exposure range: %.0f - %.0f us\n", 
           range.min_intg_time_us, range.max_intg_time_us);
}
```

---

#### kd_mpi_sensor_get_gain_range

获取增益范围。需要在start之后调用

**函数原型**

```c
k_s32 kd_mpi_sensor_get_gain_range(k_s32 fd, k_sensor_gain_info *range);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `range` | `k_sensor_gain_info*` | 输出增益范围 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**示例**

```c
k_sensor_gain_info range;
k_s32 ret = kd_mpi_sensor_get_gain_range(fd, &range);
if (ret == 0) {
    printf("Gain range: %.2f - %.2f, step: %.6f\n", 
           range.min_gain, range.max_gain, range.step_gain);
}
```

---

### 帧率控制

#### kd_mpi_sensor_fps_set

设置传感器帧率。

**函数原型**

```c
k_s32 kd_mpi_sensor_fps_set(k_s32 fd, k_u32 fps);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `fps` | `k_u32` | 帧率值 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_fps_get

获取当前帧率。

**函数原型**

```c
k_s32 kd_mpi_sensor_fps_get(k_s32 fd, k_u32 *fps);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `fps` | `k_u32*` | 输出帧率 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

### 图像质量控制

#### kd_mpi_sensor_isp_status_get

获取 ISP 状态信息。

**函数原型**

```c
k_s32 kd_mpi_sensor_isp_status_get(k_s32 fd, k_sensor_isp_status *isp_status);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `isp_status` | `k_sensor_isp_status*` | 输出 ISP 状态 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_blc_set

设置黑电平校正（BLC）。

**函数原型**

```c
k_s32 kd_mpi_sensor_blc_set(k_s32 fd, k_sensor_blc blc);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `blc` | `k_sensor_blc` | 黑电平校正值（包含 R/Gr/Gb/B 四个通道） | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_wb_set

设置白平衡（WB）。

**函数原型**

```c
k_s32 kd_mpi_sensor_wb_set(k_s32 fd, k_sensor_white_balance wb);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `wb` | `k_sensor_white_balance` | 白平衡增益（包含 R/Gr/Gb/B 四个通道） | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_tpg_set

设置测试图案发生器（TPG）。

**函数原型**

```c
k_s32 kd_mpi_sensor_tpg_set(k_s32 fd, k_sensor_test_pattern tpg);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `tpg` | `k_sensor_test_pattern` | 测试图案配置（enable/pattern） | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- TPG 用于调试，不依赖真实图像输入

---

#### kd_mpi_sensor_tpg_get

获取 TPG 配置。

**函数原型**

```c
k_s32 kd_mpi_sensor_tpg_get(k_s32 fd, k_sensor_test_pattern *tpg);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `tpg` | `k_sensor_test_pattern*` | 输出 TPG 配置 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_expand_curve_get

获取扩展曲线配置。

**函数原型**

```c
k_s32 kd_mpi_sensor_expand_curve_get(k_s32 fd, k_sensor_compand_curve *curve);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `curve` | `k_sensor_compand_curve*` | 输出扩展曲线配置 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_mirror_set

设置镜像翻转。

**函数原型**

```c
k_s32 kd_mpi_sensor_mirror_set(k_s32 fd, k_vicap_mirror_mode mirror);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `mirror` | `k_vicap_mirror_mode` | 镜像模式配置 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

### OTP 与对焦控制

#### kd_mpi_sensor_otpdata_get

获取 OTP 数据。

**函数原型**

```c
k_s32 kd_mpi_sensor_otpdata_get(k_s32 fd, void *otp_data);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `otp_data` | `void*` | 输出 OTP 数据缓冲区 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_otpdata_set

设置 OTP 数据。

**函数原型**

```c
k_s32 kd_mpi_sensor_otpdata_set(k_s32 fd, void *otp_data);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `otp_data` | `void*` | OTP 数据缓冲区 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- OTP 写入操作需谨慎，可能不可逆

---

#### kd_mpi_sensor_set_focus_pos

设置对焦位置。

**函数原型**

```c
k_s32 kd_mpi_sensor_set_focus_pos(k_s32 fd, k_sensor_focus_pos *focus_pos);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `focus_pos` | `k_sensor_focus_pos*` | 对焦位置配置 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 仅支持带自动对焦功能的传感器模组

---

#### kd_mpi_sensor_get_focus_pos

获取当前对焦位置。

**函数原型**

```c
k_s32 kd_mpi_sensor_get_focus_pos(k_s32 fd, k_sensor_focus_pos *focus_pos);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `focus_pos` | `k_sensor_focus_pos*` | 输出对焦位置 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_get_focus_caps

获取对焦能力信息。

**函数原型**

```c
k_s32 kd_mpi_sensor_get_focus_caps(k_s32 fd, k_sensor_autofocus_caps *caps);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `caps` | `k_sensor_autofocus_caps*` | 输出对焦能力信息 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

#### kd_mpi_sensor_set_focus_power

设置对焦电源状态。

**函数原型**

```c
k_s32 kd_mpi_sensor_set_focus_power(k_s32 fd, k_bool power);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `fd` | `k_s32` | 传感器文件描述符 | 输入 |
| `power` | `k_bool` | K_TRUE: 上电，K_FALSE: 断电 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

---

### 信息查询接口

#### kd_mpi_sensor_list_mode

获取传感器支持的模式列表。

**函数原型**

```c
k_s32 kd_mpi_sensor_list_mode(const char *sensor_name, k_sensor_mode_list *list);
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `sensor_name` | `const char*` | 传感器名称 | 输入 |
| `list` | `k_sensor_mode_list*` | 输出模式列表 | 输出 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `0` | 成功 |
| 非 `0` | 失败，返回错误码 |

**注意事项**

- 最多返回 6 个模式
- 根据 sensor_name 自动匹配对应的 sensor_type 和 csi_num

**示例**

```c
k_sensor_mode_list list;
k_s32 ret = kd_mpi_sensor_list_mode("gc2093_csi2", &list);
if (ret == 0) {
    for (k_u32 i = 0; i < list.count; i++) {
        printf("Mode %u: %ux%u@%ufps\n", 
               i, list.modes[i].width, list.modes[i].height, list.modes[i].fps);
    }
}
```

---

根据传感器名称打开设备。

**函数原型**

```c
```

**参数**

| 参数 | 类型 | 说明 | 输入/输出 |
|------|------|------|-----------|
| `sensor_name` | `const char*` | 传感器名称 | 输入 |

**返回值**

| 返回值 | 说明 |
|--------|------|
| `>= 0` | 传感器文件描述符 |
| `< 0` | 失败，返回错误码 |

**注意事项**

- 该函数是 `kd_mpi_sensor_open()` 的便捷版本
- 内部会查找匹配的传感器配置并打开设备

---

## 典型使用流程

```c
// 1. 打开传感器
k_s32 fd = kd_mpi_sensor_open("gc2093_csi2");
if (fd < 0) {
    printf("Failed to open sensor\n");
    return -1;
}

// 2. 上电
kd_mpi_sensor_power_set(fd, K_TRUE);

// 3. 初始化（配置模式）
k_sensor_mode mode;
// ... 配置 mode 结构体 ...
kd_mpi_sensor_init(fd, mode);

// 4. 调整参数（可选）
kd_mpi_sensor_fps_set(fd, 30);
kd_mpi_sensor_again_set(fd, gain);

// 5. 使能数据流
kd_mpi_sensor_stream_enable(fd, 1);

// ... 使用传感器 ...

// 6. 禁用数据流
kd_mpi_sensor_stream_enable(fd, 0);

// 7. 断电
kd_mpi_sensor_power_set(fd, K_FALSE);

// 8. 关闭设备
kd_mpi_sensor_close(fd);
```

---

## 注意事项

- **fd 管理**：所有操作都依赖 `kd_mpi_sensor_open()` 返回的 fd，使用完成后必须调用 `kd_mpi_sensor_close()` 关闭。

- **调用顺序**：建议按照 上电 → 初始化 → 配置 → 使能流 的顺序调用。

- **参数范围**：设置增益、曝光等参数前，建议先调用对应的 `get_*_range()` 接口获取有效范围。

- **传感器差异**：不同传感器支持的功能和参数范围可能不同，具体能力由驱动决定。

- **并发访问**：避免多个线程同时操作同一个传感器 fd。

- **错误处理**：所有接口返回非 0 值表示失败，应检查返回值并进行相应处理。
