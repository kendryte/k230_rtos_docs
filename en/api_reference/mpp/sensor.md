# K230 Sensor API Reference

## Overview

The Sensor API is used to complete image sensor device operations including opening, powering on, initializing, mode switching, register read/write, and runtime parameter adjustment. This set of interfaces primarily corresponds to the sensor driver control surface and is typically used together with VICAP and ISP.

The current API header file is located at `src/rtsmart/mpp/userapps/api/mpi_sensor_api.h`, and the related data type definitions are located in `k_sensor_comm.h` and `k_vicap_comm.h`.

## Code Location

- Header file: `src/rtsmart/mpp/userapps/api/mpi_sensor_api.h`
- Related types: `src/rtsmart/mpp/include/comm/k_sensor_comm.h`
- VICAP-related types: `src/rtsmart/mpp/include/comm/k_vicap_comm.h`

## Quick Index

### Device Lifecycle Management

- [kd_mpi_sensor_open](#kd_mpi_sensor_open)
- [kd_mpi_sensor_close](#kd_mpi_sensor_close)
- [kd_mpi_sensor_power_set](#kd_mpi_sensor_power_set)
- [kd_mpi_sensor_init](#kd_mpi_sensor_init)
- [kd_mpi_sensor_stream_enable](#kd_mpi_sensor_stream_enable)

### Device Information and Mode Management

- [kd_mpi_sensor_id_get](#kd_mpi_sensor_id_get)
- [kd_mpi_sensor_mode_get](#kd_mpi_sensor_mode_get)
- [kd_mpi_sensor_mode_set](#kd_mpi_sensor_mode_set)
- [kd_mpi_sensor_mode_enum](#kd_mpi_sensor_mode_enum)
- [kd_mpi_sensor_caps_get](#kd_mpi_sensor_caps_get)
- [kd_mpi_sensor_connection_check](#kd_mpi_sensor_connection_check)
- [kd_mpi_sensor_adapt_get](#kd_mpi_sensor_adapt_get)
- [kd_mpi_sensor_adapt_get_ex](#kd_mpi_sensor_adapt_get_ex)

### Register Access

- [kd_mpi_sensor_reg_read](#kd_mpi_sensor_reg_read)
- [kd_mpi_sensor_reg_write](#kd_mpi_sensor_reg_write)

### Exposure and Gain Control

- [kd_mpi_sensor_again_set](#kd_mpi_sensor_again_set)
- [kd_mpi_sensor_again_get](#kd_mpi_sensor_again_get)
- [kd_mpi_sensor_dgain_set](#kd_mpi_sensor_dgain_set)
- [kd_mpi_sensor_dgain_get](#kd_mpi_sensor_dgain_get)
- [kd_mpi_sensor_intg_time_set](#kd_mpi_sensor_intg_time_set)
- [kd_mpi_sensor_intg_time_get](#kd_mpi_sensor_intg_time_get)
- [kd_mpi_sensor_get_exposure_time_range](#kd_mpi_sensor_get_exposure_time_range)
- [kd_mpi_sensor_get_gain_range](#kd_mpi_sensor_get_gain_range)

### Frame Rate Control

- [kd_mpi_sensor_fps_set](#kd_mpi_sensor_fps_set)
- [kd_mpi_sensor_fps_get](#kd_mpi_sensor_fps_get)

### Image Quality Control

- [kd_mpi_sensor_isp_status_get](#kd_mpi_sensor_isp_status_get)
- [kd_mpi_sensor_blc_set](#kd_mpi_sensor_blc_set)
- [kd_mpi_sensor_wb_set](#kd_mpi_sensor_wb_set)
- [kd_mpi_sensor_tpg_set](#kd_mpi_sensor_tpg_set)
- [kd_mpi_sensor_tpg_get](#kd_mpi_sensor_tpg_get)
- [kd_mpi_sensor_expand_curve_get](#kd_mpi_sensor_expand_curve_get)
- [kd_mpi_sensor_mirror_set](#kd_mpi_sensor_mirror_set)

### OTP and Focus Control

- [kd_mpi_sensor_otpdata_get](#kd_mpi_sensor_otpdata_get)
- [kd_mpi_sensor_otpdata_set](#kd_mpi_sensor_otpdata_set)
- [kd_mpi_sensor_set_focus_pos](#kd_mpi_sensor_set_focus_pos)
- [kd_mpi_sensor_get_focus_pos](#kd_mpi_sensor_get_focus_pos)
- [kd_mpi_sensor_get_focus_caps](#kd_mpi_sensor_get_focus_caps)
- [kd_mpi_sensor_set_focus_power](#kd_mpi_sensor_set_focus_power)

### Information Query Interfaces

- [kd_mpi_sensor_list_mode](#kd_mpi_sensor_list_mode)
- [kd_mpi_sensor_get_exposure_time_range](#kd_mpi_sensor_get_exposure_time_range)
- [kd_mpi_sensor_get_gain_range](#kd_mpi_sensor_get_gain_range)
- [kd_mpi_sensor_get_focus_caps](#kd_mpi_sensor_get_focus_caps)

---

## Interface Detailed Description

### Device Lifecycle Management

#### kd_mpi_sensor_open

Open the sensor device.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_open(const char *sensor_name);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `sensor_name` | `const char*` | Sensor name (e.g., "gc2093_csi2") | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `>= 0` | Sensor file descriptor (fd) |
| `< 0` | Failure, returns error code |

**Notes**

- The returned fd is used for all subsequent sensor operations
- `kd_mpi_sensor_close()` must be called after use to close the device
- The sensor name must match the name registered in the driver

**Example**

```c
k_s32 fd = kd_mpi_sensor_open("gc2093_csi2");
if (fd < 0) {
    printf("Failed to open sensor\n");
    return -1;
}
// Use fd for subsequent operations
kd_mpi_sensor_close(fd);
```

---

#### kd_mpi_sensor_close

Close the sensor device.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_close(k_s32 fd);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non `0` | Failure, returns error code |

**Notes**

- The fd is no longer valid after closing
- Must be used in pair with `kd_mpi_sensor_open()`

---

#### kd_mpi_sensor_power_set

Set the sensor power state.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_power_set(k_s32 fd, k_bool on);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `on` | `k_bool` | K_TRUE: power on, K_FALSE: power off | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non `0` | Failure, returns error code |

**Notes**

- Initialization and configuration can only be performed after power on
- Ensure the data stream has been stopped before power off

---

#### kd_mpi_sensor_init

Initialize the sensor device.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_init(k_s32 fd, k_sensor_mode mode);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `mode` | `k_sensor_mode` | Sensor working mode configuration | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non `0` | Failure, returns error code |

**Notes**

- Must be called after power on
- The mode structure needs to be correctly configured with parameters such as resolution and frame rate

---

#### kd_mpi_sensor_stream_enable

Enable or disable the sensor data stream.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_stream_enable(k_s32 fd, k_s32 enable);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `enable` | `k_s32` | 1: enable, 0: disable | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non `0` | Failure, returns error code |

**Notes**

- The sensor starts outputting image data after being enabled
- Output stops after being disabled, but the configuration is retained

---

### Device Information and Mode Management

#### kd_mpi_sensor_id_get

Get sensor ID.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_id_get(k_s32 fd, k_u32 *sensor_id);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `sensor_id` | `k_u32*` | Output sensor ID | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_mode_get

Get current sensor mode configuration.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_mode_get(k_s32 fd, k_sensor_mode *mode);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `mode` | `k_sensor_mode*` | Output mode configuration | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_mode_set

Set sensor working mode.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_mode_set(k_s32 fd, k_sensor_mode mode);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `mode` | `k_sensor_mode` | Mode configuration | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- Some mode switches may require restarting the data stream

---

#### kd_mpi_sensor_mode_enum

Enumerate the modes supported by the sensor.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_mode_enum(k_s32 fd, k_sensor_enum_mode *enum_mode);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `enum_mode` | `k_sensor_enum_mode*` | Enum mode information | Input/Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_caps_get

Get sensor capability information.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_caps_get(k_s32 fd, k_sensor_caps *caps);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `caps` | `k_sensor_caps*` | Output capability information | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_connection_check

Check sensor connection status.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_connection_check(k_s32 fd, k_s32 *connection);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `connection` | `k_s32*` | Output connection status (1: connected, 0: disconnected) | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_adapt_get

Get sensor information based on configuration.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_adapt_get(k_vicap_probe_config *config, k_vicap_sensor_info *info);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `config` | `k_vicap_probe_config*` | Probe configuration (CSI number, resolution, frame rate) | Input |
| `info` | `k_vicap_sensor_info*` | Output sensor information | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_adapt_get_ex

Obtains sensor information according to the configuration and explicitly specified MIPI lane preference. `k_vicap_probe_config` contains only probe conditions such as CSI, resolution, and frame rate, while the lane preference is passed through the third parameter. The legacy interface `kd_mpi_sensor_adapt_get` retains compatibility and always probes with `VICAP_MIPI_LANE_PREF_ANY`.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_adapt_get_ex(k_vicap_probe_config *config,
                                  k_vicap_sensor_info *info,
                                  k_vicap_mipi_lane_pref lane_pref);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `config` | `k_vicap_probe_config*` | Probe configuration (CSI number, resolution, frame rate) | Input |
| `info` | `k_vicap_sensor_info*` | Output sensor information | Output |
| `lane_pref` | `k_vicap_mipi_lane_pref` | `ANY`, `2LANE`, or `4LANE` probe preference | Input |

**Description**

- `ANY` does not filter by lane; at the same resolution, firmware sorting prioritizes 2LANE.
- An invalid `lane_pref` is treated as `ANY`.
- 4LANE is supported only on CSI0; passing `VICAP_MIPI_LANE_PREF_4LANE` on CSI1/CSI2 will fail.

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure; an error code is returned |

**Example**

```c
k_vicap_probe_config probe_cfg = {0};
k_vicap_sensor_info sensor_info = {0};
probe_cfg.csi_num = 0;
probe_cfg.width = 2592;
probe_cfg.height = 1944;
probe_cfg.fps = 30;

k_s32 ret = kd_mpi_sensor_adapt_get_ex(
    &probe_cfg, &sensor_info, VICAP_MIPI_LANE_PREF_4LANE);
```

---

### Register Access

#### kd_mpi_sensor_reg_read

Reads a sensor register.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_reg_read(k_s32 fd, k_u32 reg_addr, k_u32 *reg_val);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `reg_addr` | `k_u32` | Register address | Input |
| `reg_val` | `k_u32*` | Output register value | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- Used for debugging or special configuration
- Register addresses and bit widths vary by sensor

---

#### kd_mpi_sensor_reg_write

Writes to a sensor register.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_reg_write(k_s32 fd, k_u32 reg_addr, k_u32 reg_val);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `reg_addr` | `k_u32` | Register address | Input |
| `reg_val` | `k_u32` | Register value | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- Incorrect register configuration may cause sensor malfunction
- Refer to the sensor datasheet for details

---

### Exposure and Gain Control

#### kd_mpi_sensor_again_set

Set analog gain (Again).

**Function Prototype**

```c
k_s32 kd_mpi_sensor_again_set(k_s32 fd, k_sensor_gain gain);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `gain` | `k_sensor_gain` | Gain value structure | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- The gain value must be within the supported range of the sensor
- It is recommended to call `kd_mpi_sensor_get_gain_range()` first to obtain the range

**Example**

```c
k_sensor_gain gain;
gain.gain[0] = 2.0f;  // Set gain to 2.0
k_s32 ret = kd_mpi_sensor_again_set(fd, gain);
```

---

#### kd_mpi_sensor_again_get

Get the current analog gain value.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_again_get(k_s32 fd, k_sensor_gain *gain);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `gain` | `k_sensor_gain*` | Output gain value | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_dgain_set

Set digital gain (Dgain).

**Function Prototype**

```c
k_s32 kd_mpi_sensor_dgain_set(k_s32 fd, k_sensor_gain gain);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `gain` | `k_sensor_gain` | Gain value structure | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_dgain_get

Get the current digital gain value.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_dgain_get(k_s32 fd, k_sensor_gain *gain);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `gain` | `k_sensor_gain*` | Output gain value | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_intg_time_set

Set integration time (exposure time).

**Function Prototype**

```c
k_s32 kd_mpi_sensor_intg_time_set(k_s32 fd, k_sensor_intg_time time);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `time` | `k_sensor_intg_time` | Integration time structure (unit: seconds) | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- The integration time must be within the supported range of the sensor
- It is recommended to call `kd_mpi_sensor_get_exposure_time_range()` first to obtain the range

**Example**

```c
k_sensor_intg_time time;
time.intg_time[0] = 0.01f;  // 10ms
k_s32 ret = kd_mpi_sensor_intg_time_set(fd, time);
```

---

#### kd_mpi_sensor_intg_time_get

Get the current integration time.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_intg_time_get(k_s32 fd, k_sensor_intg_time *time);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `time` | `k_sensor_intg_time*` | Output integration time | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_get_exposure_time_range

Get the exposure time range. Must be called after start.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_get_exposure_time_range(k_s32 fd, k_sensor_exposure_time_range *range);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `range` | `k_sensor_exposure_time_range*` | Output exposure range (unit: microseconds) | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Example**

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

Get the gain range. Must be called after start.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_get_gain_range(k_s32 fd, k_sensor_gain_info *range);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `range` | `k_sensor_gain_info*` | Output gain range | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Example**

```c
k_sensor_gain_info range;
k_s32 ret = kd_mpi_sensor_get_gain_range(fd, &range);
if (ret == 0) {
    printf("Gain range: %.2f - %.2f, step: %.6f\n", 
           range.min_gain, range.max_gain, range.step_gain);
}
```

---

### Frame Rate Control

#### kd_mpi_sensor_fps_set

Set the sensor frame rate.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_fps_set(k_s32 fd, k_u32 fps);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `fps` | `k_u32` | Frame rate value | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_fps_get

Get the current frame rate.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_fps_get(k_s32 fd, k_u32 *fps);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `fps` | `k_u32*` | Output frame rate | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

### Image Quality Control

#### kd_mpi_sensor_isp_status_get

Get ISP status information.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_isp_status_get(k_s32 fd, k_sensor_isp_status *isp_status);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `isp_status` | `k_sensor_isp_status*` | Output ISP status | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_blc_set

Set Black Level Correction (BLC).

**Function Prototype**

```c
k_s32 kd_mpi_sensor_blc_set(k_s32 fd, k_sensor_blc blc);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `blc` | `k_sensor_blc` | Black level correction value (includes R/Gr/Gb/B four channels) | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_wb_set

Set White Balance (WB).

**Function Prototype**

```c
k_s32 kd_mpi_sensor_wb_set(k_s32 fd, k_sensor_white_balance wb);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `wb` | `k_sensor_white_balance` | White balance gain (includes R/Gr/Gb/B four channels) | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_tpg_set

Set Test Pattern Generator (TPG).

**Function Prototype**

```c
k_s32 kd_mpi_sensor_tpg_set(k_s32 fd, k_sensor_test_pattern tpg);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `tpg` | `k_sensor_test_pattern` | Test pattern configuration (enable/pattern) | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- TPG is used for debugging and does not depend on real image input

---

#### kd_mpi_sensor_tpg_get

Get TPG configuration.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_tpg_get(k_s32 fd, k_sensor_test_pattern *tpg);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `tpg` | `k_sensor_test_pattern*` | Output TPG configuration | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_expand_curve_get

Get expand curve configuration.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_expand_curve_get(k_s32 fd, k_sensor_compand_curve *curve);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `curve` | `k_sensor_compand_curve*` | Output expand curve configuration | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_mirror_set

Set mirror flip.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_mirror_set(k_s32 fd, k_vicap_mirror_mode mirror);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `mirror` | `k_vicap_mirror_mode` | Mirror mode configuration | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

### OTP and Focus Control

#### kd_mpi_sensor_otpdata_get

Get OTP data.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_otpdata_get(k_s32 fd, void *otp_data);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `otp_data` | `void*` | Output OTP data buffer | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_otpdata_set

Set OTP data.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_otpdata_set(k_s32 fd, void *otp_data);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `otp_data` | `void*` | OTP data buffer | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- OTP write operations should be performed with caution, as they may be irreversible

---

#### kd_mpi_sensor_set_focus_pos

Set focus position.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_set_focus_pos(k_s32 fd, k_sensor_focus_pos *focus_pos);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `focus_pos` | `k_sensor_focus_pos*` | Focus position configuration | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- Only sensor modules with autofocus capability are supported

---

#### kd_mpi_sensor_get_focus_pos

Get the current focus position.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_get_focus_pos(k_s32 fd, k_sensor_focus_pos *focus_pos);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `focus_pos` | `k_sensor_focus_pos*` | Output focus position | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_get_focus_caps

Get focus capability information.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_get_focus_caps(k_s32 fd, k_sensor_autofocus_caps *caps);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `caps` | `k_sensor_autofocus_caps*` | Output focus capability information | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

#### kd_mpi_sensor_set_focus_power

Set the focus power state.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_set_focus_power(k_s32 fd, k_bool power);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `fd` | `k_s32` | Sensor file descriptor | Input |
| `power` | `k_bool` | K_TRUE: power on, K_FALSE: power off | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

---

### Information Query Interface

#### kd_mpi_sensor_list_mode

Gets the list of modes supported by the sensor.

**Function Prototype**

```c
k_s32 kd_mpi_sensor_list_mode(const char *sensor_name, k_sensor_mode_list *list);
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `sensor_name` | `const char*` | Sensor name | Input |
| `list` | `k_sensor_mode_list*` | Output mode list | Output |

**Return Value**

| Return Value | Description |
|--------|------|
| `0` | Success |
| Non-`0` | Failure, returns error code |

**Notes**

- Returns up to 6 modes
- Automatically matches the corresponding sensor_type and csi_num based on sensor_name

**Example**

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

Opens the device based on the sensor name.

**Function Prototype**

```c
```

**Parameters**

| Parameter | Type | Description | Input/Output |
|------|------|------|-----------|
| `sensor_name` | `const char*` | Sensor name | Input |

**Return Value**

| Return Value | Description |
|--------|------|
| `>= 0` | Sensor file descriptor |
| `< 0` | Failure, returns error code |

**Notes**

- This function is a convenience version of `kd_mpi_sensor_open()`
- Internally, it finds the matching sensor configuration and opens the device

---

## Typical Usage Flow

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

## Notes

- **fd Management**: All operations depend on the fd returned by `kd_mpi_sensor_open()`. You must call `kd_mpi_sensor_close()` to close it after use.

- **Call Sequence**: It is recommended to follow the order: Power on → Initialize → Configure → Enable stream.

- **Parameter Range**: Before setting parameters such as gain and exposure, it is recommended to call the corresponding `get_*_range()` interface to obtain the valid range.

- **Sensor Differences**: Different sensors may support different functions and parameter ranges, with specific capabilities determined by the driver.

- **Concurrent Access**: Avoid multiple threads operating on the same sensor fd simultaneously.

- **Error Handling**: All interfaces returning a non-zero value indicates failure. You should check the return value and handle it accordingly.
