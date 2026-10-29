# K230 VICAP API Reference

## Overview

### Overview

The VICAP subsystem is the subsystem responsible for video image input capture and processing in the K230 SOC. By performing real-time processing on the signal output from the sensor, the restored and enhanced digital image is obtained, making it closer to the image seen by the human eye in reality. It mainly includes MIPI RxDphy, MIPI CSI, ISP, and DW. MIPI is used to receive high-speed differential signals from the sensor and convert them to the DVP interface for ISP processing; ISP is used for image information processing; DW is used for fisheye correction and multi-channel resize output.

This document mainly describes the VICAP module application programming interface, which provides application developers with the operation interfaces and configuration parameters for capturing video image data through the VICAP module.

### Function Description

#### VICAP

The VICAP module is an abstract description of the entire image acquisition and processing unit.

The VICAP hardware consists of four major modules: Sensor, VI, ISP, and Dewarp (as shown in Figure 1-1 below). It supports up to 3 sensor inputs simultaneously. The ISP internally uses the MCM module to achieve time-division multiplexing management of multiple sensors. The output data of multiple sensors is written to DDR through the MCM's Memory Interface Write interface, and then read through the Read interface and loaded into the ISP Pipeline for processing.

![Illustration description automatically generated](https://download.kendryte.com/developer/pictures/745a46d8e083d93521d0c5233bdaccdd.png)、

Figure 1-1 VICAP Hardware Architecture Diagram

The VICAP software architecture is shown in Figure 1-2. From top to bottom, it is: application interface layer, media interface layer, system framework layer, driver layer, and hardware layer.

- Application Layer Interface: Provides API interfaces in the form of kd_mapi_vicap_xxx and usage instructions. It is a further encapsulation of the functional interfaces provided by each submodule of the media interface layer, simplifying the application development process.
- Media Interface Layer: This layer consists of various submodules of VICAP, and each submodule provides its own media interface API encapsulation.
- Framework Layer: Responsible for the control and management of VICAP's entire system software functions and business logic. By integrating the interfaces and functions provided by each submodule, a complete set of VICAP system control logic and process is formed.
- Driver Layer: A collection of kernel driver functions for each hardware module of VICAP.

Hardware Layer: A collection of specific hardware modules of VICAP, including sensors.

![Graphical user interface, text, application description automatically generated](https://download.kendryte.com/developer/pictures/250b6c36cbd4447bd8c734548fc3b890.png)

#### Sensor

The Sensor module is one of the data sources for images captured by VICAP, responsible for configuring the operating parameters and working modes of the image sensing unit.

The K230 platform supports sensors of various interface types. We use the most commonly used MIPI CSI interface sensor as an example for explanation. The schematic diagram of the hardware connection between the sensor and the main control platform is as follows:

![Illustration description automatically generated](https://download.kendryte.com/developer/pictures/e20100e34c268ad615e69966cb28e5a6.png)

Figure 1-3

The main control sends configuration registers through the I2C interface to control the working mode of the sensor, and the sensor sends image data to the main control SOC through the MIPI CSI interface.

The system architecture of the Sensor module is shown in Figure 1-4 below:

![Graphical user interface, application, email description automatically generated](https://download.kendryte.com/developer/pictures/camera_sensor_arch.png)

Figure 1-4 sensor system architecture diagram

From top to bottom: media interface layer, hardware driver layer, and hardware layer

- Media Interface Layer: Provides kd_mpi_sensor_xxx interfaces for external modules to operate and access sensor devices.
- Driver Layer: This layer mainly includes two parts: sensor_dev and sensor_drv.
- sensor_dev: Responsible for the registration of device driver files, providing the implementation process of file operation interfaces. By registering the device file node /dev/sensorxx, the user space program can access the kernel driver.
- sensor_drv: The hardware driver for a specific sensor, which encapsulates operations on the sensor into a unified interface.
- Hardware Layer: The sensor module hardware. The current system supports up to three hardware sensors simultaneously.

## API Reference

### VICAP

This functional module provides the following APIs:

VICAP APIs are categorized by function as follows:

#### Device Configuration and Management

- [kd_mpi_vicap_get_sensor_info](#kd_mpi_vicap_get_sensor_info) - Get sensor configuration information
- [kd_mpi_vicap_set_dev_attr](#kd_mpi_vicap_set_dev_attr) - Set VICAP device attributes
- [kd_mpi_vicap_get_dev_attr](#kd_mpi_vicap_get_dev_attr) - Get VICAP device attributes
- [kd_mpi_vicap_set_chn_attr](#kd_mpi_vicap_set_chn_attr) - Set channel attributes
- [kd_mpi_vicap_get_chn_attr](#kd_mpi_vicap_get_chn_attr) - Get channel attributes
- [kd_mpi_vicap_init](#kd_mpi_vicap_init) - Initialize the VICAP device
- [kd_mpi_vicap_deinit](#kd_mpi_vicap_deinit) - Deinitialize the VICAP device
- [kd_mpi_vicap_register_scene](#kd_mpi_vicap_register_scene) - Register scene configuration
- [kd_mpi_vicap_load_scene](#kd_mpi_vicap_load_scene) - Load the specified scene configuration
- [kd_mpi_vicap_get_scene](#kd_mpi_vicap_get_scene) - Get the current scene name

#### Stream Control

- [kd_mpi_vicap_start_stream](#kd_mpi_vicap_start_stream) - Start the data stream
- [kd_mpi_vicap_stop_stream](#kd_mpi_vicap_stop_stream) - Stop the data stream
- [kd_mpi_vicap_set_vi_drop_frame](#kd_mpi_vicap_set_vi_drop_frame) - Set frame dropping

#### Image Capture and Dump

- [kd_mpi_vicap_dump_frame](#kd_mpi_vicap_dump_frame) - Dump image frames
- [kd_mpi_vicap_dump_release](#kd_mpi_vicap_dump_release) - Release dump frames
- [kd_mpi_vicap_set_dump_reserved](#kd_mpi_vicap_set_dump_reserved) - Set dump reserved
- [kd_mpi_vicap_load_image](#kd_mpi_vicap_load_image) - Load image data (offline mode)
- [kd_mpi_vicap_dump_register](#kd_mpi_vicap_dump_register) - Dump register configuration

#### Sensor Control

- [kd_mpi_vicap_get_sensor_fd](#kd_mpi_vicap_get_sensor_fd) - Get the sensor file descriptor
- [kd_mpi_vicap_again_set](#kd_mpi_vicap_again_set) - Set analog gain
- [kd_mpi_vicap_again_get](#kd_mpi_vicap_again_get) - Get analog gain
- [kd_mpi_vicap_intg_time_set](#kd_mpi_vicap_intg_time_set) - Set integration time (exposure)
- [kd_mpi_vicap_set_af_enable](#kd_mpi_vicap_set_af_enable) - Set auto-focus enable
- [kd_mpi_vicap_tpg_enable](#kd_mpi_vicap_tpg_enable) - Enable test pattern generator

#### Clock and Synchronization

- [kd_mpi_vicap_set_mclk](#kd_mpi_vicap_set_mclk) - Set master clock
- [kd_mpi_vicap_set_slave_enable](#kd_mpi_vicap_set_slave_enable) - Set slave mode enable
- [kd_mpi_vicap_set_slave_attr](#kd_mpi_vicap_set_slave_attr) - Set slave mode attributes
- [kd_mpi_vicap_3d_mode_crtl](#kd_mpi_vicap_3d_mode_crtl) - 3D mode control

#### kd_mpi_vicap_get_sensor_info

【Description】

Get sensor configuration information based on the specified sensor configuration type.

【Syntax】

```c
k_s32 kd_mpi_vicap_get_sensor_info(k_vicap_sensor_type sensor_type, k_vicap_sensor_info *sensor_info)
```

【Parameters】

| **Parameter Name** | **Description**       | **Input/Output** |
|--------------|----------------|---------------|
| sensor_type  | Sensor configuration type | Input          |
| sensor_info  | Sensor configuration information | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

The application developer needs to first call this API to get sensor configuration information according to the sensor configuration type to be used, and then call subsequent interfaces to initialize other VICAP modules based on the configuration information.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_set_dev_attr

【Description】

Set VICAP device attributes.

【Syntax】

```c
k_s32 kd_mpi_vicap_set_dev_attr(k_vicap_dev dev_num, k_vicap_dev_attr dev_attr)
```

【Parameters】

| **Parameter Name** | **Description**      | **Input/Output** |
|--------------|---------------|---------------|
| dev_num      | VICAP device number   | Input          |
| dev_attr     | VICAP device attributes | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_get_dev_attr

【Description】

Get VICAP device attributes.

【Syntax】

```c
k_s32 kd_mpi_vicap_get_dev_attr(k_vicap_dev dev_num, k_vicap_dev_attr *dev_attr)
```

【Parameters】

| **Parameter Name** | **Description**      | **Input/Output** |
|--------------|---------------|---------------|
| dev_num      | VICAP device number   | Input          |
| dev_attr     | VICAP device attributes | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_set_chn_attr

【Description】

Set VICAP device attributes.

【Syntax】

```c
k_s32 kd_mpi_vicap_set_chn_attr(k_vicap_dev dev_num, k_vicap_chn chn_num, k_vicap_chn_attr chn_attr)
```

【Parameters】

| **Parameter Name** | **Description**          | **Input/Output** |
|--------------|-------------------|---------------|
| dev_num      | VICAP device number       | Input          |
| chn_num      | VICAP output channel number   | Input          |
| chn_attr     | VICAP output channel attributes | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_get_chn_attr

【Description】

Get VICAP device attributes.

【Syntax】

```c
k_s32 kd_mpi_vicap_get_chn_attr(k_vicap_dev dev_num, k_vicap_chn chn_num, k_vicap_chn_attr *chn_attr)
```

【Parameters】

| **Parameter Name** | **Description**          | **Input/Output** |
|--------------|-------------------|---------------|
| dev_num      | VICAP device number       | Input          |
| chn_num      | VICAP output channel number   | Input          |
| chn_attr     | VICAP output channel attributes | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_init

【Description】

VICAP device initialization.

【Syntax】

```c
k_s32 kd_mpi_vicap_init(k_vicap_dev dev_num)
```

【Parameters】

| **Parameter Name** | **Description**    | **Input/Output** |
|--------------|-------------|---------------|
| dev_num      | VICAP device number | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

Before using this interface, you need to first call kd_mpi_vicap_set_dev_attr to set the device attributes, and then call kd_mpi_vicap_set_chn_attr to set the output channel attributes.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_deinit

【Description】

VICAP device deinitialization.

【Syntax】

```c
k_s32 kd_mpi_vicap_deinit(k_vicap_dev dev_num)
```

【Parameters】

| **Parameter Name** | **Description**    | **Input/Output** |
|--------------|-------------|---------------|
| dev_num      | VICAP device number | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_start_stream

【Description】

Start the VICAP device output data stream.

【Syntax】

```c
k_s32 kd_mpi_vicap_start_stream(k_vicap_dev dev_num)
```

【Parameters】

| **Parameter Name** | **Description**    | **Input/Output** |
|--------------|-------------|---------------|
| dev_num      | VICAP device number | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_stop_stream

【Description】

Stop the VICAP device data stream output.

【Syntax】

```c
k_s32 kd_mpi_vicap_stop_stream(k_vicap_dev dev_num)
```

【Parameters】

| **Parameter Name** | **Description**    | **Input/Output** |
|--------------|-------------|---------------|
| dev_num      | VICAP device number | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_dump_frame

【Description】

Dump VICAP data based on the specified device and output channel.

【Syntax】

```c
k_s32 kd_mpi_vicap_dump_frame(k_vicap_dev dev_num, k_vicap_chn chn_num, k_vicap_dump_format foramt,
    k_video_frame_info *vf_info, k_u32 milli_sec)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| dev_num      | VICAP device number     | Input          |
| chn_num      | VICAP output channel number | Input          |
| foramt       | Dump data type    | Input          |
| vf_info      | Dump frame information      | Output          |
| milli_sec    | Timeout duration        | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_dump_release

【Description】

Release dump data frames.

【Syntax】

```c
k_s32 kd_mpi_vicap_dump_release(k_vicap_dev dev_num, k_vicap_chn chn_num, const k_video_frame_info *vf_info)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| dev_num      | VICAP device number     | Input          |
| chn_num      | VICAP output channel number | Input          |
| vf_info      | Dump frame information      | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_vicap_set_vi_drop_frame

【Description】

Set hardware frame dropping.

【Syntax】

```c
k_s32 kd_mpi_vicap_set_vi_drop_frame(k_vicap_csi_num csi, k_vicap_drop_frame *frame, k_bool enable)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| csi         | VICAP device number     | Input          |
| frame        | Structure, see below |               |
| m | Drop n frames every m frames| Input |
| n | Drop n frames every m frames| Input |
| mode | HDR mode | Input |
| enable       | Whether to enable | Input |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

#### kd_mpi_vicap_set_mclk

【Description】

Set the MCLK frequency.

【Syntax】

```c
k_s32 kd_mpi_vicap_set_mclk(k_vicap_mclk_id id, k_vicap_mclk_sel sel, k_u8 mclk_div, k_u8 mclk_en)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| id         | MCLK ID     | Input          |
| sel | Clock source | Input |
| mclk_div | Frequency division coefficient | Input |
| mclk_en | Whether to enable | Input |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

#### kd_mpi_vicap_set_dump_reserved

【Description】

Set whether to enable fast dump mode.

【Syntax】

void kd_mpi_vicap_set_dump_reserved(k_vicap_dev dev_num, k_vicap_chn chn_num, k_bool reserved)

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| dev_num      | VICAP device number     | Input          |
| chn_num      | VICAP output channel number | Input          |
| reserved | Whether to enable fast dump mode | Input |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

#### kd_mpi_vicap_set_slave_enable

【Description】

Enable slave mode.

【Syntax】

```c
k_s32 kd_mpi_vicap_set_slave_enable(k_vicap_slave_id id, k_vicap_slave_enable *enable)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| id      | ID of the slave mode     | Input          |
| enable      | Whether to enable slave mode | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

#### kd_mpi_vicap_set_slave_attr

【Description】

Set slave mode parameters.

【Syntax】

```c
k_s32 kd_mpi_vicap_set_slave_attr(k_vicap_slave_id id, k_vicap_slave_info *info)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| id      | ID of the slave mode     | Input          |
| info      | Parameters of the slave mode | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

#### kd_mpi_vicap_3d_mode_crtl

【Description】

Set 3D mode enable.

【Syntax】

```c
k_s32 kd_mpi_vicap_3d_mode_crtl(k_bool enable)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| enable      | 3D mode enable     | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-0        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

### Sensor

This function module provides the following APIs:

- [kd_mpi_sensor_open](#kd_mpi_sensor_open)
- [kd_mpi_sensor_close](#kd_mpi_sensor_close)
- [kd_mpi_sensor_power_set](#kd_mpi_sensor_power_set)
- [kd_mpi_sensor_id_get](#kd_mpi_sensor_id_get)
- [kd_mpi_sensor_init](#kd_mpi_sensor_init)
- [kd_mpi_sensor_reg_read](#kd_mpi_sensor_reg_read)
- [kd_mpi_sensor_reg_write](#kd_mpi_sensor_reg_write)
- [kd_mpi_sensor_mode_get](#kd_mpi_sensor_mode_get)
- [kd_mpi_sensor_mode_set](#kd_mpi_sensor_mode_set)
- [kd_mpi_sensor_stream_enable](#kd_mpi_sensor_stream_enable)
- [kd_mpi_sensor_again_set](#kd_mpi_sensor_again_set)
- [kd_mpi_sensor_again_get](#kd_mpi_sensor_again_get)
- [kd_mpi_sensor_dgain_set](#kd_mpi_sensor_dgain_set)
- [kd_mpi_sensor_dgain_get](#kd_mpi_sensor_dgain_get)
- [kd_mpi_sensor_intg_time_set](#kd_mpi_sensor_intg_time_set)
- [kd_mpi_sensor_intg_time_get](#kd_mpi_sensor_intg_time_get)
- [kd_mpi_sensor_otpdata_get](#kd_mpi_sensor_otpdata_get)
- [kd_mpi_sensor_otpdata_set](#kd_mpi_sensor_otpdata_set)
- [kd_mpi_sensor_get_exposure_time_range](#kd_mpi_sensor_get_exposure_time_range)
- [kd_mpi_sensor_get_gain_range](#kd_mpi_sensor_get_gain_range)
- [kd_mpi_sensor_get_focus_caps](#kd_mpi_sensor_get_focus_caps)

#### kd_mpi_sensor_open

【Description】

Open the sensor device according to the sensor device name.

【Syntax】

```c
k_s32 kd_mpi_sensor_open(const char *sensor_name)
```

【Parameters】

| **Parameter Name** | **Description**       | **Input/Output** |
|--------------|----------------|---------------|
| sensor_name  | Sensor device name | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| Positive value | Success. Returns the device descriptor.   |
| Negative value | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_close

【Description】

Close the sensor device.

【Syntax】

```c
k_s32 kd_mpi_sensor_close (k_s32 fd)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_power_set

【Description】

Set the sensor power state.

【Syntax】

```c
k_s32 kd_mpi_sensor_power_set(k_s32 fd, k_bool on)
```

【Parameters】

| **Parameter Name** | **Description**                                      | **Input/Output** |
|--------------|-----------------------------------------------|---------------|
| fd           | Sensor device file descriptor                          | Input          |
| on           | Set the sensor power state, K_TRUE: power on, K_FALSE: power off | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_id_get

【Description】

Get the sensor id.

【Syntax】

```c
k_s32 kd_mpi_sensor_id_get(k_s32 fd, k_u32 *sensor_id)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| sensor_id    | The obtained sensor id      | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_init

【Description】

Sensor initialization.

【Syntax】

```c
k_s32 kd_mpi_sensor_init(k_s32 fd, k_sensor_mode mode)
```

【Parameters】

| **Parameter Name** | **Description**                                    | **Input/Output** |
|--------------|---------------------------------------------|---------------|
| fd           | Sensor device file descriptor                        | Input          |
| mode         | Initialize sensor configuration registers according to the specified sensor mode | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_reg_read

【Description】

Read the sensor register content.

【Syntax】

```c
k_s32 kd_mpi_sensor_reg_read(k_s32 fd, k_u32 reg_addr, k_u32 *reg_val)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| reg_addr     | Sensor register address     | Input          |
| reg_val      | Read register content       | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_reg_write

【Description】

Write the sensor register content.

【Syntax】

```c
k_s32 kd_mpi_sensor_reg_write(k_s32 fd, k_u32 reg_addr, k_u32 reg_val)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| reg_addr     | Sensor register address     | Input          |
| reg_val      | Content written to the sensor register | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_mode_get

【Description】

Get the sensor mode configuration.

【Syntax】

```c
k_s32 kd_mpi_sensor_mode_get(k_s32 fd, k_sensor_mode *mode)
```

【Parameters】

| **Parameter Name** | **Description**                      | **Input/Output** |
|--------------|-------------------------------|---------------|
| fd           | Sensor device file descriptor          | Input          |
| mode         | Returns the obtained sensor mode configuration parameters | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_mode_set

【Description】

Set the sensor mode configuration.

【Syntax】

```c
k_s32 kd_mpi_sensor_mode_get(k_s32 fd, k_sensor_mode mode)
```

【Parameters】

| **Parameter Name** | **Description**                | **Input/Output** |
|--------------|-------------------------|---------------|
| fd           | Sensor device file descriptor    | Input          |
| mode         | Set sensor mode configuration parameters | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_stream_enable

【Description】

Set the sensor mode configuration.

【Syntax】

```c
k_s32 kd_mpi_sensor_stream_enable(k_s32 fd, k_s32 enable)
```

【Parameters】

| **Parameter Name** | **Description**                                         | **Input/Output** |
|--------------|--------------------------------------------------|---------------|
| fd           | Sensor device file descriptor                             | Input          |
| enable       | Set the sensor stream output state, 0: disable output, non-zero: enable output | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_again_set

【Description】

Set the sensor analog gain.

【Syntax】

```c
k_s32 kd_mpi_sensor_again_set(k_s32 fd, k_sensor_gain gain)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| gain         | Gain configuration parameter         | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_again_get

【Description】

Get the sensor analog gain.

【Syntax】

```c
k_s32 kd_mpi_sensor_again_set(k_s32 fd, k_sensor_gain *gain)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| gain         | Gain configuration parameter         | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_dgain_set

【Description】

Set the sensor digital gain.

【Syntax】

```c
k_s32 kd_mpi_sensor_dgain_set(k_s32 fd, k_sensor_gain gain)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| gain         | Gain configuration parameter         | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_dgain_get

【Description】

Get the sensor digital gain.

【Syntax】

```c
k_s32 kd_mpi_sensor_dgain_get(k_s32 fd, k_sensor_gain *gain)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| gain         | Gain configuration parameter         | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_intg_time_set

【Description】

Set the sensor integration time.

【Syntax】

```c
k_s32 kd_mpi_sensor_intg_time_set(k_s32 fd, k_sensor_intg_time time)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| time         | Integration time configuration parameter     | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_intg_time_get

【Description】

Get the sensor integration time.

【Syntax】

```c
k_s32 kd_mpi_sensor_intg_time_get(k_s32 fd, k_sensor_intg_time *time)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| time         | Integration time configuration parameter     | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_otpdata_get

【Description】

Get sensor otp data.

【Syntax】

```c
k_s32 kd_mpi_sensor_otpdata_get(k_s32 fd, void *ota_data)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| ota_data         | otp data    | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_otpdata_set

【Description】

Set sensor otp data.

【Syntax】

```c
k_s32 kd_mpi_sensor_otpdata_set(k_s32 fd, void *ota_data)
```

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| ota_data         | otp data    | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

None.

【Example】

None.

【Related Topics】

#### kd_mpi_sensor_get_exposure_time_range

【Description】

Get the sensor exposure time range.

【Syntax】

k_s32 kd_mpi_sensor_get_exposure_time_range(k_s32 fd, k_sensor_exposure_time_range *range)

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| range        | Exposure range configuration parameter     | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

The returned exposure time unit is microseconds (us).

【Example】

```c
k_sensor_exposure_time_range range;
k_s32 ret = kd_mpi_sensor_get_exposure_time_range(fd, &range);
if (ret == 0) {
    printf("Exposure range: %.0f - %.0f us\n", 
           range.min_intg_time_us, range.max_intg_time_us);
}
```

【Related Topics】

#### kd_mpi_sensor_get_gain_range

【Description】

Get the sensor gain range (including minimum value, maximum value, and step).

【Syntax】

k_s32 kd_mpi_sensor_get_gain_range(k_s32 fd, k_sensor_gain_range *range)

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| range        | Gain range configuration parameter     | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

The returned gain range includes min_gain, max_gain, and step_gain.

【Example】

```c
k_sensor_gain_range range;
k_s32 ret = kd_mpi_sensor_get_gain_range(fd, &range);
if (ret == 0) {
    printf("Gain range: %.2f - %.2f, step: %.6f\n", 
           range.min_gain, range.max_gain, range.step_gain);
}
```

【Related Topics】

#### kd_mpi_sensor_get_focus_caps

【Description】

Get the sensor focus capability information (only supported by sensor modules with auto-focus function).

【Syntax】

k_s32 kd_mpi_sensor_get_focus_caps(k_s32 fd, k_sensor_autofocus_caps *caps)

【Parameters】

| **Parameter Name** | **Description**             | **Input/Output** |
|--------------|----------------------|---------------|
| fd           | Sensor device file descriptor | Input          |
| caps         | Focus capability configuration parameter     | Output          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero        | Failure, refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_sensor_api.h
- Library file: libsensor.a

【Note】

Only supported by sensor modules with auto-focus function.

【Example】

```c
k_sensor_autofocus_caps caps;
k_s32 ret = kd_mpi_sensor_get_focus_caps(fd, &caps);
if (ret == 0) {
    printf("Focus caps available\n");
}
```

【Related Topics】

#### kd_mpi_vicap_get_sensor_fd

【Description】

Get the sensor file descriptor associated with the VICAP device.

【Syntax】

```c
k_s32 kd_mpi_vicap_get_sensor_fd(k_vicap_sensor_attr *sensor_attr)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| sensor_attr  | Sensor attribute structure pointer, containing the device number and the returned sensor_fd | Input/Output |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| K_SUCCESS (0) | Success |
| K_FAILED (non-zero) | Failure, invalid device number or sensor not opened |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- Must initialize the VICAP device and open the sensor before getting the fd.
- sensor_attr->dev_num must be within the valid range (VICAP_DEV_ID_0 to VICAP_DEV_ID_MAX-1).
- The returned sensor_fd can be used for subsequent sensor-related operations.

【Example】

```c
k_vicap_sensor_attr sensor_attr;
sensor_attr.dev_num = VICAP_DEV_ID_0;

k_s32 ret = kd_mpi_vicap_get_sensor_fd(&sensor_attr);
if (ret == K_SUCCESS) {
    printf("Sensor fd: %d\n", sensor_attr.sensor_fd);
    // You can use sensor_attr.sensor_fd for sensor operations
}
```

【Related Topics】

- [kd_mpi_sensor_open](#kd_mpi_sensor_open)

---

#### kd_mpi_vicap_tpg_enable

【Description】

Enable or disable the Test Pattern Generator (TPG).

【Syntax】

```c
k_s32 kd_mpi_vicap_tpg_enable(k_bool enable)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| enable       | K_TRUE: enable TPG, K_FALSE: disable TPG | Input |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| Non-zero | Failure, refer to the error code definition |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- TPG is used for debugging and does not depend on real sensor input.
- After enabling, VICAP will output test patterns instead of real image data.

【Example】

```c
// Enable test pattern
kd_mpi_vicap_tpg_enable(K_TRUE);

// Disable test pattern, use real sensor data
kd_mpi_vicap_tpg_enable(K_FALSE);
```

【Related Topics】

---

#### kd_mpi_vicap_register_scene

【Description】

Register scene configuration, associate the scene name with the configuration file path.

【Syntax】

```c
k_s32 kd_mpi_vicap_register_scene(const char *scene_name, const char *path)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| scene_name | Scene name (e.g., "day", "night", "indoor", etc.) | Input |
| path | Configuration file directory path (must end with /, e.g., "/etc/vicap/") | Input |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| -1 | Failure (invalid parameters, duplicate scene name, exceeding the maximum number of scenes, etc.) |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- Call after system initialization and before using the scene.
- Scene names must be unique (including not duplicating with "default_scene").
- The path will automatically be ensured to end with `/`.
- Up to 8 scenes are supported (including the default scene).
- On the first call, the default scene "default_scene" (path: /bin/) will be automatically registered.

【Example】

```c
// Register the daytime scene
kd_mpi_vicap_register_scene("day", "/etc/vicap/day/");

// Register the nighttime scene
kd_mpi_vicap_register_scene("night", "/etc/vicap/night/");

// Register the indoor scene
kd_mpi_vicap_register_scene("indoor", "/etc/vicap/indoor/");
```

【Related Topics】

- [kd_mpi_vicap_load_scene](#kd_mpi_vicap_load_scene)
- [kd_mpi_vicap_get_scene](#kd_mpi_vicap_get_scene)

---

#### kd_mpi_vicap_load_scene

【Description】

Load the configuration file of the specified scene.

【Syntax】

```c
k_s32 kd_mpi_vicap_load_scene(const char *scene_name)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| scene_name | Scene name (must be registered through register_scene first) | Input |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| -1 | Failure (scene_name is NULL, scene does not exist, configuration file loading failed) |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- **Must be called after closing the camera and before starting the camera.**
- The scene must be registered through `kd_mpi_vicap_register_scene` first (including `default_scene`).
- It will call the underlying `kd_mpi_isp_set_config_path` to set the path.
- The loaded configuration files include: `_manual.json`, `_auto.json`, `.xml`.

【Example】

```c
// Switch to the daytime scene
kd_mpi_vicap_deinit(dev);
kd_mpi_vicap_load_scene("day");
kd_mpi_vicap_set_dev_attr(dev, day_attr);
kd_mpi_vicap_init(dev);

// Switch to the nighttime scene
kd_mpi_vicap_deinit(dev);
kd_mpi_vicap_load_scene("night");
kd_mpi_vicap_set_dev_attr(dev, night_attr);
kd_mpi_vicap_init(dev);

// Switch to the default scene (use the configuration file under /bin/)
kd_mpi_vicap_deinit(dev);
kd_mpi_vicap_load_scene("default_scene");
kd_mpi_vicap_init(dev);
```

【Related Topics】

- [kd_mpi_vicap_register_scene](#kd_mpi_vicap_register_scene)
- [kd_mpi_vicap_get_scene](#kd_mpi_vicap_get_scene)
- [kd_mpi_vicap_init](#kd_mpi_vicap_init)
- [kd_mpi_vicap_deinit](#kd_mpi_vicap_deinit)

---

#### kd_mpi_vicap_get_scene

【Description】

Get the name of the currently loaded scene.

【Syntax】

```c
const char* kd_mpi_vicap_get_scene(void)
```

【Parameters】

None.

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| const char* | Current scene name string |
| NULL | No scene is set |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- The returned string is maintained internally and does not need to be released.
- The first call returns NULL until `load_scene` is called successfully.
- After loading the default scene, it returns `"default_scene"`.

【Example】

```c
const char* current = kd_mpi_vicap_get_scene();
if (current) {
    printf("Current scene: %s\n", current);
} else {
    printf("No scene loaded\n");
}

// After loading the default scene
kd_mpi_vicap_load_scene("default_scene");
printf("Current scene: %s\n", kd_mpi_vicap_get_scene());  // Output: default_scene
```

【Related Topics】

- [kd_mpi_vicap_register_scene](#kd_mpi_vicap_register_scene)
- [kd_mpi_vicap_load_scene](#kd_mpi_vicap_load_scene)

#### kd_mpi_vicap_load_image

【Description】

Load user image data into VICAP (for offline mode).

【Syntax】

```c
k_s32 kd_mpi_vicap_load_image(k_vicap_dev dev_num, const void *image_data, k_u32 data_len)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| dev_num      | VICAP device number | Input |
| image_data   | Image data pointer | Input |
| data_len     | Image data length (bytes) | Input |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| Non-zero | Failure, invalid device number or parameter error |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- Only used in offline mode (VICAP_WORK_OFFLINE_MODE).
- image_data cannot be NULL.
- The data format needs to match the VICAP configuration.

【Example】

```c
// Load image data into VICAP device 0
const void *image_data = ...; // Image data
k_u32 data_len = 1920 * 1080 * 3; // Size of 1080P RGB data

k_s32 ret = kd_mpi_vicap_load_image(VICAP_DEV_ID_0, image_data, data_len);
if (ret == 0) {
    printf("Image loaded successfully\n");
}
```

【Related Topics】

- [kd_mpi_vicap_init](#kd_mpi_vicap_init)

---

#### kd_mpi_vicap_dump_register

【Description】

Dump VICAP register configuration to a file (for debugging).

【Syntax】

```c
k_s32 kd_mpi_vicap_dump_register(k_vicap_dev dev_num, const char *file_name)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| dev_num      | VICAP device number | Input |
| file_name    | Output file path | Input |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| Non-zero | Failure, file open failed or dump failed |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- The output file contains the register configuration of ISP and Dewarp (if enabled).
- Used for debugging and problem analysis.
- The file will be overwritten if it already exists.

【Example】

```c
// Dump the register configuration of VICAP device 0 to a file
k_s32 ret = kd_mpi_vicap_dump_register(VICAP_DEV_ID_0, "/sdcard/vicap_reg_dump.txt");
if (ret == 0) {
    printf("Register dump saved to /sdcard/vicap_reg_dump.txt\n");
}
```

【Related Topics】

---

#### kd_mpi_vicap_again_set

【Description】

Set the sensor analog gain (Again).

【Syntax】

```c
k_s32 kd_mpi_vicap_again_set(k_vicap_dev dev_num, k_sensor_gain gain)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| dev_num      | VICAP device number | Input |
| gain         | Gain configuration structure | Input |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| Non-zero | Failure, refer to the error code definition |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- The gain value must be within the supported range of the sensor.
- It is recommended to call `kd_mpi_sensor_get_gain_range()` to get the range first.
- For the definition of the gain structure, refer to [k_sensor_gain](#k_sensor_gain).

【Example】

```c
k_sensor_gain gain;
gain.gain[0] = 4.0f;  // Set channel 0 gain to 4.0

k_s32 ret = kd_mpi_vicap_again_set(VICAP_DEV_ID_0, gain);
if (ret == 0) {
    printf("Gain set successfully\n");
}
```

【Related Topics】

- [kd_mpi_vicap_again_get](#kd_mpi_vicap_again_get)
- [kd_mpi_sensor_get_gain_range](#kd_mpi_sensor_get_gain_range)

---

#### kd_mpi_vicap_again_get

【Description】

Get the current sensor analog gain value.

【Syntax】

```c
k_s32 kd_mpi_vicap_again_get(k_vicap_dev dev_num, k_sensor_gain *gain)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| dev_num      | VICAP device number | Input |
| gain         | Output gain configuration structure pointer | Output |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| Non-zero | Failure, refer to the error code definition |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- The gain pointer cannot be NULL.
- The returned gain value is in units of multiples (e.g., 4.0 means 4x gain).

【Example】

```c
k_sensor_gain gain;

k_s32 ret = kd_mpi_vicap_again_get(VICAP_DEV_ID_0, &gain);
if (ret == 0) {
    printf("Current gain: %.2f\n", gain.gain[0]);
}
```

【Related Topics】

- [kd_mpi_vicap_again_set](#kd_mpi_vicap_again_set)

---

#### kd_mpi_vicap_intg_time_set

【Description】

Set the sensor integration time (exposure time).

【Syntax】

```c
k_s32 kd_mpi_vicap_intg_time_set(k_vicap_dev dev_num, k_sensor_intg_time time)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| dev_num      | VICAP device number | Input |
| time         | Integration time configuration structure (unit: second) | Input |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| Non-zero | Failure, refer to the error code definition |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- The integration time must be within the supported range of the sensor.
- It is recommended to call `kd_mpi_sensor_get_exposure_time_range()` to get the range first.
- For the definition of the time structure, refer to [k_sensor_intg_time](#k_sensor_intg_time).

【Example】

```c
k_sensor_intg_time time;
time.intg_time[0] = 0.01f;  // 10ms exposure time

k_s32 ret = kd_mpi_vicap_intg_time_set(VICAP_DEV_ID_0, time);
if (ret == 0) {
    printf("Exposure time set to 10ms\n");
}
```

【Related Topics】

- [kd_mpi_sensor_get_exposure_time_range](#kd_mpi_sensor_get_exposure_time_range)

---

#### kd_mpi_vicap_set_af_enable

【Description】

Set the auto-focus function enable state.

【Syntax】

```c
k_s32 kd_mpi_vicap_set_af_enable(k_vicap_dev dev_num, k_bool enable)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| dev_num      | VICAP device number | Input |
| enable       | K_TRUE: enable auto-focus, K_FALSE: disable auto-focus | Input |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| Non-zero | Failure, refer to the error code definition |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- Only supported by sensor modules with auto-focus function.
- After disabling, the focus interface needs to be called manually.

【Example】

```c
// Enable auto-focus
kd_mpi_vicap_set_af_enable(VICAP_DEV_ID_0, K_TRUE);

// Disable auto-focus, use manual focus
kd_mpi_vicap_set_af_enable(VICAP_DEV_ID_0, K_FALSE);
```

【Related Topics】

- [kd_mpi_vicap_get_af_enable](#kd_mpi_vicap_get_af_enable)

---

#### kd_mpi_vicap_get_af_enable

【Description】

Get the current enable state of the auto-focus function.

【Syntax】

```c
k_s32 kd_mpi_vicap_get_af_enable(k_vicap_dev dev_num, k_bool *enable)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------|---------------|
| dev_num      | VICAP device number | Input |
| enable       | Output enable state pointer (K_TRUE: enabled, K_FALSE: disabled) | Output |

【Return Value】

| **Return Value** | **Description** |
|------------|----------|
| 0 | Success |
| Non-zero | Failure, refer to the error code definition |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_vicap_api.h
- Library file: libvicap.a

【Note】

- The enable pointer cannot be NULL.
- The returned enable state reflects the current working state of the auto-focus function.

【Example】

```c
k_bool enable;

k_s32 ret = kd_mpi_vicap_get_af_enable(VICAP_DEV_ID_0, &enable);
if (ret == 0) {
    if (enable) {
        printf("Auto-focus is enabled\n");
    } else {
        printf("Auto-focus is disabled\n");
    }
}
```

【Related Topics】

- [kd_mpi_vicap_set_af_enable](#kd_mpi_vicap_set_af_enable)

---

## Data Types

### VICAP

The related data type definitions of this function module are as follows:

- [k_vicap_sensor_type](#k_vicap_sensor_type)
- [k_vicap_dev](#k_vicap_dev)
- [k_vicap_chn](#k_vicap_chn)
- [k_vicap_csi_num](#k_vicap_csi_num)
- [k_vicap_mipi_lanes](#k_vicap_mipi_lanes)
- [k_vicap_csi_data_type](#k_vicap_csi_data_type)
- [k_vicap_data_source](#k_vicap_data_source)
- [k_vicap_vi_dvp_port](#k_vicap_vi_dvp_port)
- [k_vicap_vi_flash_mode](#k_vicap_vi_flash_mode)
- [k_vicap_img_window](#k_vicap_img_window)
- [k_vicap_work_mode](#k_vicap_work_mode)
- [k_vicap_sensor_info](#k_vicap_sensor_info)
- [k_vicap_dump_format](#k_vicap_dump_format)
- [k_vicap_dev_attr](#k_vicap_dev_attr)
- [k_vicap_chn_attr](#k_vicap_chn_attr)

#### k_vicap_sensor_type

**Note:** Definition of sensor types supported by the current system. The actually available members are determined by the corresponding
`CONFIG_MPP_ENABLE_SENSOR_*` compilation options, so use the member names rather than relying on the enum values.

**Definition**

```c
typedef enum {
    IMX335_MIPI_CSI0_2LANE_1920X1080_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI0_2LANE_2592X1944_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI0_4LANE_2592X1944_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI1_2LANE_1920X1080_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI1_2LANE_2592X1944_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI2_2LANE_1920X1080_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI2_2LANE_2592X1944_30FPS_12BIT_LINEAR,

    OV5647_MIPI_CSI0_2592x1944_15FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI0_1920X1080_30FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI0_1280X960_45FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI0_1280X720_60FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI0_640x480_90FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_2592x1944_15FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_1920X1080_30FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_1280X960_45FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_1280X720_60FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_640x480_90FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_2592x1944_15FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_1920X1080_30FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_1280X960_45FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_1280X720_60FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_640x480_90FPS_10BIT_LINEAR,

    GC2093_MIPI_CSI0_1920X1080_30FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI0_1920X1080_60FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI0_1280X960_90FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI0_1280X720_90FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI1_1920X1080_30FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI1_1920X1080_60FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI1_1280X960_90FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI1_1280X720_90FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI2_1920X1080_30FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI2_1920X1080_60FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI2_1280X960_90FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI2_1280X720_90FPS_10BIT_LINEAR,

    SC132GS_MIPI_CSI0_1080X1280_120FPS_10BIT_LINEAR,
    SC132GS_MIPI_CSI0_640X480_240FPS_10BIT_LINEAR,
    SC132GS_MIPI_CSI1_1080X1280_120FPS_10BIT_LINEAR,
    SC132GS_MIPI_CSI1_640X480_240FPS_10BIT_LINEAR,
    SC132GS_MIPI_CSI2_1080X1280_120FPS_10BIT_LINEAR,
    SC132GS_MIPI_CSI2_640X480_240FPS_10BIT_LINEAR,

    XS9950_MIPI_CSI0_1280X720_25FPS_YUV422,
    XS9950_MIPI_CSI1_1280X720_25FPS_YUV422,
    XS9950_MIPI_CSI2_1280X720_25FPS_YUV422,

    IMX675_MIPI_CSI0_2LANE_RAW10_2592X1944_30FPS_LINEAR,
    IMX675_MIPI_CSI1_2LANE_RAW10_2592X1944_30FPS_LINEAR,
    IMX675_MIPI_CSI2_2LANE_RAW10_2592X1944_30FPS_LINEAR,

    BF3238_MIPI_CSI0_1920X1080_30FPS_10BIT_LINEAR,
    BF3238_MIPI_CSI0_1280X960_30FPS_10BIT_LINEAR,
    BF3238_MIPI_CSI1_1920X1080_30FPS_10BIT_LINEAR,
    BF3238_MIPI_CSI1_1280X960_30FPS_10BIT_LINEAR,
    BF3238_MIPI_CSI2_1920X1080_30FPS_10BIT_LINEAR,
    BF3238_MIPI_CSI2_1280X960_30FPS_10BIT_LINEAR,

    OV13850_MIPI_CSI0_3840x2160_7FPS_10BIT_LINEAR,
    OV13850_MIPI_CSI1_3840x2160_7FPS_10BIT_LINEAR,
    OV13850_MIPI_CSI2_3840x2160_7FPS_10BIT_LINEAR,

    SENSOR_TYPE_MAX,
} k_vicap_sensor_type;

/* Compatibility names retained for legacy applications. */
#define OV5647_MIPI_CSI0_2592x1944_10FPS_10BIT_LINEAR OV5647_MIPI_CSI0_2592x1944_15FPS_10BIT_LINEAR
#define OV5647_MIPI_CSI1_2592x1944_10FPS_10BIT_LINEAR OV5647_MIPI_CSI1_2592x1944_15FPS_10BIT_LINEAR
#define OV5647_MIPI_CSI2_2592x1944_10FPS_10BIT_LINEAR OV5647_MIPI_CSI2_2592x1944_15FPS_10BIT_LINEAR
#define SC132GS_MIPI_CSI0_1080X1200_30FPS_10BIT_LINEAR SC132GS_MIPI_CSI0_1080X1280_120FPS_10BIT_LINEAR
#define SC132GS_MIPI_CSI0_640X480_30FPS_10BIT_LINEAR SC132GS_MIPI_CSI0_640X480_240FPS_10BIT_LINEAR
#define SC132GS_MIPI_CSI1_1080X1200_30FPS_10BIT_LINEAR SC132GS_MIPI_CSI1_1080X1280_120FPS_10BIT_LINEAR
#define SC132GS_MIPI_CSI1_640X480_30FPS_10BIT_LINEAR SC132GS_MIPI_CSI1_640X480_240FPS_10BIT_LINEAR
#define SC132GS_MIPI_CSI2_1080X1200_30FPS_10BIT_LINEAR SC132GS_MIPI_CSI2_1080X1280_120FPS_10BIT_LINEAR
#define SC132GS_MIPI_CSI2_640X480_30FPS_10BIT_LINEAR SC132GS_MIPI_CSI2_640X480_240FPS_10BIT_LINEAR
#define XS9950_MIPI_CSI0_1280X720_30FPS_YUV422 XS9950_MIPI_CSI0_1280X720_25FPS_YUV422
#define XS9950_MIPI_CSI1_1280X720_30FPS_YUV422 XS9950_MIPI_CSI1_1280X720_25FPS_YUV422
#define XS9950_MIPI_CSI2_1280X720_30FPS_YUV422 XS9950_MIPI_CSI2_1280X720_25FPS_YUV422
```

**Members:**

In `CSI<n>`, `<n>` indicates 0, 1, or 2. Each enabled CSI interface has corresponding members.

| Model | Canonical Sensor Type Modes |
|------|------------------------------|
| IMX335 | `IMX335_MIPI_CSI<n>_2LANE_1920X1080_30FPS_12BIT_LINEAR`, `IMX335_MIPI_CSI<n>_2LANE_2592X1944_30FPS_12BIT_LINEAR`; optional 4-lane full-size mode |
| OV5647 | `OV5647_MIPI_CSI<n>_2592x1944_15FPS_10BIT_LINEAR`, 1920x1080@30, 1280x960@45, 1280x720@60, 640x480@90 |
| GC2093 | `GC2093_MIPI_CSI<n>_1920X1080_30FPS_10BIT_LINEAR`, 1920x1080@60, 1280x960@90, 1280x720@90 |
| SC132GS | `SC132GS_MIPI_CSI<n>_1080X1280_120FPS_10BIT_LINEAR`, `SC132GS_MIPI_CSI<n>_640X480_240FPS_10BIT_LINEAR` |
| XS9950 | `XS9950_MIPI_CSI<n>_1280X720_25FPS_YUV422` |
| IMX675 | `IMX675_MIPI_CSI<n>_2LANE_RAW10_2592X1944_30FPS_LINEAR` |
| BF3238 | `BF3238_MIPI_CSI<n>_1920X1080_30FPS_10BIT_LINEAR`, `BF3238_MIPI_CSI<n>_1280X960_30FPS_10BIT_LINEAR` |
| OV13850 | `OV13850_MIPI_CSI<n>_3840x2160_7FPS_10BIT_LINEAR` |

**Notes:**

1. Compatibility names are used only to compile legacy applications. New code should use the canonical Sensor Types listed above.
2. This list is maintained by Sensor driver developers. Application developers open the specified type of Sensor device through the Sensor Type defined here.

#### k_vicap_dev

**Note:** Definition of vicap device number

**Definition**

```c
typedef enum {
VICAP_DEV_ID_0 = 0,
VICAP_DEV_ID_1 = 1,
VICAP_DEV_ID_2 = 2,
VICAP_DEV_ID_MAX,
} k_vicap_dev;
```

**Members:**

| **Member Name**   | **Description**   |
|----------------|------------|
| VICAP_DEV_ID_0 | VICAP device 0 |
| VICAP_DEV_ID_1 | VICAP device 1 |
| VICAP_DEV_ID_2 | VICAP device 2 |

#### k_vicap_chn

**Note:** Definition of vicap output channel number

**Definition**

```c
typedef enum {
VICAP_CHN_ID_0 = 0,
VICAP_CHN_ID_1 = 1,
VICAP_CHN_ID_2 = 2,
VICAP_CHN_ID_MAX,
} k_vicap_chn;
```

**Members:**

| **Member Name**   | **Description**       |
|----------------|----------------|
| VICAP_CHN_ID_0 | VICAP output channel 0 |
| VICAP_CHN_ID_1 | VICAP output channel 1 |
| VICAP_CHN_ID_2 | VICAP output channel 2 |

#### k_vicap_csi_num

**Note:** Definition of vicap csi label

**Definition**

```c
typedef enum {
VICAP_CSI0 = 1,
VICAP_CSI1 = 2,
VICAP_CSI2 = 3,
} k_vicap_csi_num;
```

**Members:**

| **Member Name** | **Description** |
|--------------|----------|
| VICAP_CSI0   | CSI0     |
| VICAP_CSI1   | CSI1     |
| VICAP_CSI2   | CSI2     |

**Notes:**

The CSI number to which the sensor is connected is determined by the hardware physical connection.

#### k_vicap_mipi_lanes

**Note:** Definition of vicap mipi channel number

**Definition**

```c
typedef enum {
VICAP_MIPI_1LANE = 0,
VICAP_MIPI_2LANE = 1,
VICAP_MIPI_4LANE = 3,
} k_vicap_mipi_lanes;
```

**Members:**

| **Member Name**     | **Description** |
|------------------|----------|
| VICAP_MIPI_1LANE | 1 lane   |
| VICAP_MIPI_2LANE | 2 lane   |
| VICAP_MIPI_4LANE | 4 lane   |

**Notes:**

The number of mipi channels used for sensor connection is determined by the hardware physical connection. When 4 lanes are used, at most two sensors can be connected.

#### k_vicap_csi_data_type

**Note:** Definition of vicap mipi channel number

**Definition**

```c
typedef enum {
VICAP_CSI_DATA_TYPE_RAW8 = 0x2A,
VICAP_CSI_DATA_TYPE_RAW10 = 0x2B,
VICAP_CSI_DATA_TYPE_RAW12 = 0x2C,
VICAP_CSI_DATA_TYPE_RAW14 = 0x2D,
} k_vicap_csi_data_type;
```

**Members:**

| **Member Name**              | **Description** |
|---------------------------|----------|
| VICAP_CSI_DATA_TYPE_RAW8  | RAW8     |
| VICAP_CSI_DATA_TYPE_RAW10 | RAW10    |
| VICAP_CSI_DATA_TYPE_RAW12 | RAW12    |
| VICAP_CSI_DATA_TYPE_RAW14 | RAW14    |

**Notes:**

None

#### k_vicap_data_source

**Note:** vicap data source

**Definition**

```c
typedef enum {
VICAP_SOURCE_CSI0 = 0, /**< vicap acquire data from the csi0*/
VICAP_SOURCE_CSI1 = 1, /**< vicap acquire data from the csi0*/
VICAP_SOURCE_CSI1_FS_TR0 = 2, /**<vicap acquire data from the csi1 for flash trigger 0*/
VICAP_SOURCE_CSI1_FS_TR1 = 3, /**<vicap acquire data from the csi0 for flash trigger 1*/
VICAP_SOURCE_CSI2 = 4, /**< vicap acquire data from the csi2*/
} k_vicap_data_source;
```

**Members:**

| **Member Name**             | **Description**                            |
|--------------------------|-------------------------------------|
| VICAP_SOURCE_CSI0        | VICAP data source is CSI0                 |
| VICAP_SOURCE_CSI1        | VICAP data source is CSI1                 |
| VICAP_SOURCE_CSI1_FS_TR0 | VICAP data source is CSI1 Flash trigger 0 |
| VICAP_SOURCE_CSI1_FS_TR1 | VICAP data source is CSI1 Flash trigger 1 |
| VICAP_SOURCE_CSI2        | VICAP data source is CSI2                 |

**Notes:**

None

#### k_vicap_vi_dvp_port

**Note:** vicap vi dvp port number

**Definition**

```c
typedef enum {
VICAP_VI_DVP_PORT0 = 0,
VICAP_VI_DVP_PORT1 = 1,
VICAP_VI_DVP_PORT2 = 2,
VICAP_VI_DVP_PORT_MAX,
} k_vicap_vi_dvp_port;
```

**Members:**

| **Member Name**       | **Description**  |
|--------------------|-----------|
| VICAP_VI_DVP_PORT0 | DVP port 0 |
| VICAP_VI_DVP_PORT1 | DVP port 1  |
| VICAP_VI_DVP_PORT2 | DVP port 2  |

**Notes:**

1. The default port 0 corresponds to CSI0, port 1 corresponds to CSI1, and port 2 corresponds to CSI2.
1. Only port 0 supports HDR sensor. When the user needs to use HDR mode, it must be bound to DVP port 0.
1. When the user needs to change the port mapping relationship, a binding operation needs to be performed.

#### k_vicap_vi_flash_mode

**Note:** vicap flash light source control mode

**Definition**

```c
typedef enum {
VICAP_FLASH_FOLLOW_STROBE = 0,
VICAP_FLASH_FOLLOW_STROBE_BASE_PWM = 1,
VICAP_FLASH_NORMAL_PWM = 2,
VICAP_FLASH_DISABLE = 3, /**< disable flash light*/
} k_vicap_vi_flash_mode;
```

**Members:**

| **Member Name**                       | **Description**                    |
|------------------------------------|-----------------------------|
| VICAP_FLASH_FOLLOW_STROBE          | Controlled by strobe signal            |
| VICAP_FLASH_FOLLOW_STROBE_BASE_PWM | Based on PWM mode, controlled by strobe signal |
| VICAP_FLASH_NORMAL_PWM             | Controlled by PWM signal               |
| VICAP_FLASH_DISABLE                | Disable                        |

**Notes:**

None

#### k_vicap_img_window

**Note:** VICAP image window definition

**Definition**

```c
typedef struct {
k_u16 h_start;
k_u16 v_start;
k_u16 width;
k_u16 height;
} k_vicap_img_window;
```

**Members:**

| **Member Name** | **Description**     |
|--------------|--------------|
| h_start      | Horizontal start position |
| v_start      | Vertical start position |
| width        | Image width     |
| height       | Image height     |

#### k_vicap_work_mode

**Note:** vicap working mode

**Definition**

```c
typedef enum {
VICAP_WORK_ONLINE_MODE,
VICAP_WORK_OFFLINE_MODE,
VICAP_WORK_ONLY_MCM_MODE,
} k_vicap_work_mode;
```

**Members:**

| **Member Name**            | **Description** |
|-------------------------|----------|
| VICAP_WORK_ONLINE_MODE  | Online mode |
| VICAP_WORK_OFFLINE_MODE | Offline mode |
| VICAP_WORK_ONLY_MCM_MODE | Only works in mcm mode |

**Notes:**

When multiple camera inputs are supported, it must be specified as offline mode. When configuring VICAP_WORK_ONLY_MCM_MODE, dump images can only use the yuv444 format.

#### k_vicap_sensor_info

**Note:** VICAP sensor configuration information

**Definition**

```c
typedef struct {
const char *sensor_name;
k_vicap_csi_num csi_num; /**< CSI NUM that the sensor connects to*/
k_vicap_mipi_lanes mipi_lanes; /**< MIPI lanes that the sensor connects to*/
k_vicap_data_source source_id; /**<source id that the sensor used to*/
k_bool is_3d_sensor;
k_vicap_mipi_phy_freq phy_freq;
k_vicap_csi_data_type data_type;
k_vicap_hdr_mode hdr_mode;
k_vicap_vi_flash_mode flash_mode;
k_vicap_sensor_type sensor_type;
} k_vicap_sensor_info;
```

**Members:**

| **Member Name** | **Description**                              |
|--------------|---------------------------------------|
| sensor_name  | Sensor name                            |
| csi_num      | CSI number of the current sensor hardware connection             |
| mipi_lanes   | Number of MIPI channels used by the current sensor hardware connection |
| source_id    | VICAP data source label used by the current sensor       |
| is_3d_sensor | Whether it is a 3D sensor                        |
| phy_freq     | PHY frequency                               |
| data_type    | MIPI CSI data type                      |
| hdr_mode     | HDR mode                               |
| flash_mode   | Flash light configuration mode                        |
| sensor_type  | Sensor configuration type                        |

#### k_vicap_dump_format

**Note:** VICAP dump data frame format

**Definition**

```c
typedef enum {
VICAP_DUMP_YUV = 0,
VICAP_DUMP_RGB = 1,
VICAP_DUMP_RAW = 2,
VICAP_DUMP_YUV444 = 3,
} k_vicap_dump_format;
```

**Members:**

| **Member Name**   | **Description**     |
|----------------|--------------|
| VICAP_DUMP_YUV | Dump YUV data |
| VICAP_DUMP_RGB | Dump RGB data |
| VICAP_DUMP_RAW | Dump RAW data |
| VICAP_DUMP_YUV444 | Dump YUV444 data |

#### k_vicap_dev_attr

**Note:** VICAP device properties

**Definition**

```c
typedef struct {
    k_vicap_window acq_win;
    k_vicap_work_mode mode;
    k_vicap_isp_pipe_ctrl pipe_ctrl;
    k_u32 cpature_frame;
    k_vicap_sensor_info sensor_info;
    k_bool dw_enable;
    k_u32 buffer_num;
    k_u32 buffer_size;
    k_vicap_mirror mirror;
} k_vicap_dev_attr;
```

**Members:**

| **Member Name**  | **Description**                                                     |
| ------------- | ------------------------------------------------------------ |
| acq_win       | Image capture window                                                 |
| mode          | Vicap working mode. When multiple camera inputs are supported, it must be specified as offline mode.  |
| pipe_ctrl     | ISP pipeline control switch.                                      |
| cpature_frame | Specify the number of frames for data acquisition, input range \[0,1023\], 0: continuous acquisition          |
| sensor_info   | Sensor configuration information                                               |
| dw_enable     | Dewarp enable |
| buffer_num    | Number of buffers for sensor receiving data in offline mode                   |
| buffer_size   | Size of buffers for sensor receiving data in offline mode                   |
| mirror   | Mirror function of sensor                   |

**Notes:**

For small memory application scenarios, it is recommended to disable the 3DNR module to reduce memory usage. The way to disable it is to set pipe_ctrl.bits.dnr3_enable to 0 when the application sets device properties.

#### k_vicap_chn_attr

**Note:** VICAP device properties

**Definition**

```c
typedef struct {
    k_vicap_window out_win;
    k_vicap_window crop_win;
    k_vicap_window scale_win;
    k_bool crop_enable;
    k_bool scale_enable;
    k_bool chn_enable;
    k_pixel_format pix_format;
    k_u32 buffer_num;
    k_u32 buffer_size;
    k_u8 alignment;
} k_vicap_chn_attr;
```

**Members:**

| **Member Name** | **Description**                 |
| ------------ | ------------------------ |
| out_win      | Output window size             |
| crop_win     | Crop window size             |
| scale_win    | Scale window size             |
| crop_enable  | Crop enable                 |
| scale_enable | Scale enable                 |
| chn_enable   | Channel enable                 |
| pix_format   | Output pixel format             |
| buffer_num   | Number of buffers used by the current channel |
| buffer_size  | Buffer size               |
| alignment    | Buffer alignment method           |

#### k_vicap_mirror

**Note:** vicap sensor mirror function

**Definition**

```c
typedef enum {
VICAP_MIRROR_NONE = 0,
VICAP_MIRROR_HOR = 1,
VICAP_MIRROR_VER = 2,
VICAP_MIRROR_BOTH = 3,
} k_vicap_mirror;

```

**Members:**

| **Member Name**                       | **Description**                    |
|------------------------------------|-----------------------------|
| VICAP_MIRROR_NONE          | Sensor does not need mirror            |
| VICAP_MIRROR_HOR           | Sensor horizontal mirror |
| VICAP_MIRROR_VER           | Sensor vertical mirror              |
| VICAP_MIRROR_BOTH          | Sensor horizontal and vertical mirror                       |

**Notes:**

### Sensor

The relevant data type definitions for this function module are as follows:

- [k_sensor_bayer_pattern](#k_sensor_bayer_pattern)
- [k_sensor_exp_frame_type](#k_sensor_exp_frame_type)
- [k_sensor_exposure_param](#k_sensor_exposure_param)
- [k_sensor_intg_time](#k_sensor_intg_time)
- [k_sensor_gain](#k_sensor_gain)
- [k_sensor_size](#k_sensor_size)
- [k_sensor_ae_info](#k_sensor_ae_info)
- [k_sensor_mode](#k_sensor_mode)
- [k_sensor_otp_date](#k_sensor_otp_date)

#### k_sensor_bayer_pattern

【Definition】Definition of the Bayer pattern output by the sensor

```c
typedef enum {
BAYER_RGGB = 0,
BAYER_GRBG = 1,
BAYER_GBRG = 2,
BAYER_BGGR = 3,
BAYER_BUTT } k_sensor_bayer_pattern;
```

【Members】

| **Member Name** | **Description** |
|--------------|----------|
| BAYER_RGGB   | RGGB pattern |
| BAYER_GRBG   | GRBG pattern |
| BAYER_GBRG   | GBRG pattern |
| BAYER_BGGR   | BGGR pattern |

#### k_sensor_exp_frame_type

【Description】

【Definition】

```c
typedef enum {
SENSOR_EXPO_FRAME_TYPE_1FRAME = 0,
SENSOR_EXPO_FRAME_TYPE_2FRAMES = 1,
SENSOR_EXPO_FRAME_TYPE_3FRAMES = 2,
SENSOR_EXPO_FRAME_TYPE_4FRAMES = 3,
SENSOR_EXPO_FRAME_TYPE_MAX } k_sensor_exp_frame_type;
```

【Members】

| **Member Name**                   | **Description**           |
|--------------------------------|--------------------|
| SENSOR_EXPO_FRAME_TYPE_1FRAME  | Linear mode, single-frame exposure |
| SENSOR_EXPO_FRAME_TYPE_2FRAMES | 2-frame HDR exposure mode     |
| SENSOR_EXPO_FRAME_TYPE_3FRAMES | 2-frame HDR exposure mode     |
| SENSOR_EXPO_FRAME_TYPE_4FRAMES | 4-frame HDR exposure mode     |

#### k_sensor_exposure_param

【Description】Definition of sensor exposure parameters

【Definition】

```c
typedef struct {
k_u8 exp_frame_type;
float gain[SENSOR_EXPO_FRAME_TYPE_MAX];
float exp_time[SENSOR_EXPO_FRAME_TYPE_MAX];
} k_sensor_exposure_param;
```

【Members】

| **Member Name**   | **Description** |
|----------------|----------|
| exp_frame_type | Exposure type |
| gain           | Exposure gain |
| exp_time       | Exposure time |

#### k_sensor_intg_time

【Description】Definition of sensor exposure time

【Definition】

```c
typedef struct {
k_u8 exp_frame_type;
float intg_time[SENSOR_EXPO_FRAME_TYPE_MAX];
} k_sensor_intg_time;
```

【Members】

| **Member Name**   | **Description** |
|----------------|----------|
| exp_frame_type | Exposure type |
| intg_time      | Integration time |

#### k_sensor_gain

【Description】Definition of exposure gain

【Definition】

```c
typedef struct {
k_u8 exp_frame_type;
float gain[SENSOR_EXPO_FRAME_TYPE_MAX];
} k_sensor_gain;
```

【Members】

| **Member Name**   | **Description** |
|----------------|----------|
| exp_frame_type | Exposure type |
| gain           | Exposure gain |

#### k_sensor_size

【Description】Definition of image sizes supported by the sensor

【Definition】

```c
typedef struct {
k_u32 bounds_width;
k_u32 bounds_height;
k_u32 top;
k_u32 left;
k_u32 width;
k_u32 height;
} k_sensor_size;
```

【Members】

| **Member Name**  | **Description** |
|---------------|----------|
| bounds_width  | Width boundary |
| bounds_height | Height boundary |
| top           | Top boundary |
| left          | Left boundary   |
| width         | Width     |
| height        | Height     |

#### k_sensor_ae_info

【Description】AE parameter configuration

【Definition】

```c
typedef struct {
k_u16 frame_length;
k_u16 cur_frame_length;
float one_line_exp_time;
k_u32 gain_accuracy;
float min_gain;
float max_gain;
float integration_time_increment;
float gain_increment;
k_u16 max_long_integraion_line;
k_u16 min_long_integraion_line;
k_u16 max_integraion_line;
k_u16 min_integraion_line;
k_u16 max_vs_integraion_line;
k_u16 min_vs_integraion_line;
float max_long_integraion_time;
float min_long_integraion_time;
float max_integraion_time;
float min_integraion_time;
float max_vs_integraion_time;
float min_vs_integraion_time;
float cur_long_integration_time;
float cur_integration_time;
float cur_vs_integration_time;
float cur_long_gain;
float cur_long_again;
float cur_long_dgain;
float cur_gain;
float cur_again;
float cur_dgain;
float cur_vs_gain;
float cur_vs_again;
float cur_vs_dgain;
k_sensor_gain_info long_gain;
k_sensor_gain_info gain;
k_sensor_gain_info vs_gain;
k_sensor_gain_info a_long_gain;
k_sensor_gain_info a_gain;
k_sensor_gain_info a_vs_gain;
k_sensor_gain_info d_long_gain;
k_sensor_gain_info d_gain;
k_sensor_gain_info d_vs_gain;
k_u32 max_fps;
k_u32 min_fps;
k_u32 cur_fps;
k_sensor_auto_fps afps_info;
k_u32 hdr_ratio;
} k_sensor_ae_info;
```

【Members】

| **Member Name**               | **Description**              |
|----------------------------|-----------------------|
| frame_length               | Frame length                |
| cur_frame_length           | Current frame length            |
| one_line_exp_time          | Line exposure time (unit: s) |
| gain_accuracy              | Gain accuracy              |
| min_gain                   | Minimum gain              |
| max_gain                   | Maximum gain              |
| integration_time_increment | Integration time increment        |
| gain_increment             | Gain increment            |
| max_long_integraion_line   | Maximum long-frame integration lines        |
| min_long_integraion_line   | Minimum long-frame integration lines        |
| max_integraion_line        | Maximum middle-frame integration lines        |
| min_integraion_line        | Minimum middle-frame integration lines        |
| max_vs_integraion_line     | Maximum short-frame integration lines        |
| min_vs_integraion_line     | Minimum short-frame integration lines        |
| max_long_integraion_time   | Maximum long-frame integration time        |
| min_long_integraion_time   | Minimum long-frame integration time        |
| max_integraion_time        | Maximum middle-frame integration time        |
| min_integraion_time        | Minimum middle-frame integration time        |
| max_vs_integraion_time     | Maximum short-frame integration time        |
| min_vs_integraion_time     | Minimum short-frame integration time        |
| cur_long_integration_time  | Current long-frame integration time      |
| cur_integration_time       | Current frame integration time        |
| cur_vs_integration_time    | Current short-frame integration time      |
| cur_long_gain              | Current long-frame gain          |
| cur_long_again             | Current long-frame analog gain      |
| cur_long_dgain             | Current long-frame digital gain      |
| cur_gain                   | Current frame gain            |
| cur_again                  | Current frame analog gain        |
| cur_dgain                  | Current frame digital gain        |
| cur_vs_gain                | Current short-frame gain          |
| cur_vs_again               | Current short-frame analog gain      |
| cur_vs_dgain               | Current short-frame digital gain      |
| long_gain                  | Long-frame gain              |
| gain                       | Middle gain                |
| vs_gain                    | Short-frame gain              |
| a_long_gain                | Long-frame analog gain          |
| a_gain                     | Middle-frame analog gain          |
| a_vs_gain                  | Short-frame analog gain          |
| d_long_gain                | Long-frame digital gain          |
| d_gain                     | Middle-frame digital gain          |
| d_vs_gain                  | Short-frame digital gain          |
| max_fps                    | Maximum frame rate              |
| min_fps                    | Minimum frame rate              |
| cur_fps                    | Current frame rate              |
| hdr_ratio                  | HDR ratio              |

#### k_sensor_mode

【Description】Sensor mode parameters

【Definition】

```c
typedef struct {
k_u32 index;
k_vicap_sensor_type sensor_type;
k_sensor_size size;
k_u32 fps;
k_u32 hdr_mode;
k_u32 stitching_mode;
k_u32 bit_width;
k_u32 bayer_pattern;
k_sensor_mipi_info mipi_info;
k_sensor_ae_info ae_info;
k_sensor_reg_list *reg_list;
} k_sensor_mode;
```

【Members】

| **Member Name**   | **Description**                 |
|----------------|--------------------------|
| index          | Current mode index             |
| sensor_type    | Sensor configuration type           |
| size           | Sensor size in current mode       |
| fps            | Frame rate                     |
| hdr_mode       | HDR mode                  |
| stitching_mode | HDR stitching mode         |
| bit_width      | Output data width             |
| bayer_pattern  | Bayer pattern                 |
| mipi_info      | MIPI parameter information             |
| ae_info        | AE parameter information               |
| reg_list       | Register configuration list for the current mode |
| otp_type          | OTP type: sensor's own use and user             |
| otp_date    | OTP data           |

#### k_sensor_otp_date

【Description】Sensor OTP parameters

【Definition】

```c
typedef struct {
k_u8 otp_type;
k_u8 otp_date[20];
} k_sensor_otp_date;
```

【Members】

| **Member Name**   | **Description**                 |
|----------------|--------------------------|
| otp_type          | OTP type: sensor's own use and user             |
| otp_date    | OTP data           |

## MAPI

This functional module provides the following APIs:

- [kd_mapi_vicap_get_sensor_fd]
- [kd_mapi_vicap_get_sensor_info]
- [kd_mapi_vicap_set_dev_attr]
- [kd_mapi_vicap_set_chn_attr]
- [kd_mapi_vicap_start]
- [kd_mapi_vicap_stop]
- [kd_mapi_vicap_dump_frame]
- [kd_mapi_vicap_release_frame]
- [kd_mapi_vicap_set_vi_drop_frame]
- [kd_mapi_vicap_set_mclk]
- [kd_mapi_vicap_tuning]
- [kd_mapi_isp_ae_get_roi]
- [kd_mapi_isp_ae_set_roi]
- [kd_mapi_sensor_otpdata_get]

### API

#### kd_mapi_vicap_get_sensor_fd

【Description】

Get the file descriptor based on the specified sensor.

【Syntax】

```c
k_s32 kd_mapi_vicap_get_sensor_fd(k_vicap_sensor_attr *sensor_attr)
```

【Parameters】

| **Parameter Name** | **Description** | **Input/Output** |
|--------------|----------------|---------------|
| sensor_attr  | Sensor attribute | Input & Output     |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_get_sensor_info

【Description】

Get the sensor configuration information based on the specified sensor configuration type. See [kd_mpi_vicap_get_sensor_info](#kd_mpi_vicap_get_sensor_info). Put `sensor_type` into `sensor_info.sensor_type`, with the same usage.

【Syntax】

```c
k_s32 kd_mapi_vicap_get_sensor_info(k_vicap_sensor_info *sensor_info)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_set_dev_attr

【Description】

Set the VICAP device attributes. See [kd_mpi_vicap_set_dev_attr](#kd_mpi_vicap_set_dev_attr). Put `dev_num` into `dev_info.vicap_dev`, with the same usage.

【Syntax】

```c
k_s32 kd_mapi_vicap_set_dev_attr(k_vicap_dev_set_info dev_info)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_set_chn_attr

【Description】

Set the VICAP channel attributes. See [kd_mpi_vicap_set_chn_attr](#kd_mpi_vicap_set_chn_attr). Put `dev_num` into `chn_info.vicap_dev`, and put `chn_num` into `chn_info.vicap_chn`, with the same usage.

【Syntax】

```c
k_s32 kd_mapi_vicap_set_chn_attr(k_vicap_chn_set_info chn_info)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_start

【Description】

[kd_mpi_vicap_init](#kd_mpi_vicap_init) + [kd_mpi_vicap_start_stream](#kd_mpi_vicap_start_stream)

【Syntax】

```c
k_s32 kd_mapi_vicap_start(k_vicap_dev vicap_dev)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_stop

【Description】

[kd_mpi_vicap_stop_stream](#kd_mpi_vicap_stop_stream) + [kd_mpi_vicap_deinit](#kd_mpi_vicap_deinit)

【Syntax】

```c
k_s32 kd_mapi_vicap_stop(k_vicap_dev vicap_dev)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_dump_frame

【Description】

Dump VICAP data based on the specified device and output channel. See [kd_mpi_vicap_dump_frame](#kd_mpi_vicap_dump_frame).

【Syntax】

```c
k_s32 kd_mapi_vicap_dump_frame(k_vicap_dev dev_num, k_vicap_chn chn_num, k_vicap_dump_format foramt, k_video_frame_info *vf_info, k_u32 milli_sec)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| dev_num      | VICAP device number     | Input          |
| chn_num      | VICAP output channel number | Input          |
| foramt       | Dump data type    | Input          |
| vf_info      | Dump frame information      | Output          |
| milli_sec    | Timeout        | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_release_frame

【Description】

Release the dumped data frame. See [kd_mpi_vicap_dump_release](#kd_mpi_vicap_dump_release).

【Syntax】

```c
k_s32 kd_mapi_vicap_release_frame(k_vicap_dev dev_num, k_vicap_chn chn_num, const k_video_frame_info *vf_info)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| dev_num      | VICAP device number     | Input          |
| chn_num      | VICAP output channel number | Input          |
| vf_info      | Dump frame information      | Input          |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_set_vi_drop_frame

【Description】

Set hardware frame dropping. See [kd_mpi_vicap_set_vi_drop_frame](#kd_mpi_vicap_set_vi_drop_frame).

【Syntax】

```c
k_s32 kd_mapi_vicap_set_vi_drop_frame(k_vicap_csi_num csi, k_vicap_drop_frame *frame, k_bool enable)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| csi         | VICAP device number     | Input          |
| frame        | Structure, see below  | |
| m | Drop n frames every m frames| Input |
| n | Drop n frames every m frames| Input |
| mode | HDR mode | Input |
| enable       | Whether to enable | Input |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_set_mclk

【Description】

Set the MCLK frequency. See [kd_mpi_vicap_set_mclk](#kd_mpi_vicap_set_mclk).

【Syntax】

```c
k_s32 kd_mapi_vicap_set_mclk(k_vicap_mclk_id id, k_vicap_mclk_sel sel, k_u8 mclk_div, k_u8 mclk_en)
```

【Parameters】

| **Parameter Name** | **Description**        | **Input/Output** |
|--------------|-----------------|---------------|
| id         | MCLK ID     | Input          |
| sel | Clock source | Input |
| mclk_div | Divider coefficient | Input |
| mclk_en | Whether to enable | Input |

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_vicap_tuning

【Description】

Used to handle commands sent by the tuning client.

【Syntax】

```c
k_s32 kd_mapi_vicap_tuning(char* string, k_u32 size, char** response, k_u32* response_len)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_vicap_api.h
- Library file: libmapi.a

#### kd_mapi_isp_ae_get_roi

【Description】

Get the AE ROI configuration.

【Syntax】

```c
k_s32 kd_mapi_isp_ae_get_roi(k_vicap_dev dev_num, k_isp_ae_roi *ae_roi)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_isp_api.h
- Library file: libmapi.a

#### kd_mapi_isp_ae_set_roi

【Description】

Set the AE ROI.

【Syntax】

```c
k_s32 kd_mapi_isp_ae_set_roi(k_vicap_dev dev_num, k_isp_ae_roi ae_roi)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_isp_api.h
- Library file: libmapi.a

#### kd_mapi_sensor_otpdata_get

【Description】

Get the sensor OTP data.

【Syntax】

```c
k_s32 kd_mapi_sensor_otpdata_get(k_s32 sensor_type, k_sensor_otp_date *otp_data)
```

【Return Value】

| **Return Value** | **Description**               |
|------------|------------------------|
| 0          | Success.                 |
| Non-zero   | Failure. Refer to the error code definition. |

【Chip Differences】

None.

【Requirements】

- Header file: mapi_isp_api.h
- Library file: libmapi.a

## Error Codes

Table 41 VICAP API Error Codes

| Error Code  | Macro Definition           | Description                                                       |
|-------------|----------------------------|-------------------------------------------------------------------|
| 0xA0158001  | K_ERR_VICAP_INVALID_DEVID  | Device ID is out of valid range                                   |
| 0xA0158002  | K_ERR_VICAP_INVALID_CHNID  | Channel ID is out of valid range                                  |
| 0xA0158003  | K_ERR_VICAP_ILLEGAL_PARAM  | Parameter is out of valid range                                   |
| 0xA0158004  | K_ERR_VICAP_EXIST          | Attempting to request or create a device, channel, or resource that already exists |
| 0xA0158005  | K_ERR_VICAP_UNEXIST        | Attempting to use or destroy a device, channel, or resource that does not exist |
| 0xA0158006  | K_ERR_VICAP_NULL_PTR       | Null pointer in function parameters                               |
| 0xA0158007  | K_ERR_VICAP_NOT_CONFIG     | Not configured before use                                         |
| 0xA0158008  | K_ERR_VICAP_NOT_SUPPORT    | Unsupported parameter or feature                                 |
| 0xA0158009  | K_ERR_VICAP_NOT_PERM       | The operation is not permitted, such as attempting to modify static configuration parameters |
| 0xA015800C  | K_ERR_VICAP_NOMEM          | Memory allocation failed, such as insufficient system memory      |
| 0xA015800D  | K_ERR_VICAP_NOBUF          | Buffer allocation failed, such as the requested data buffer being too large |
| 0xA015800E  | K_ERR_VICAP_BUF_EMPTY      | No data in the buffer                                             |
| 0xA015800F  | K_ERR_VICAP_BUF_FULL       | Buffer is full                                                    |
| 0xA0158010  | K_ERR_VICAP_NOTREADY       | System is not initialized or the corresponding module is not loaded |
| 0xA0158011  | K_ERR_VICAP_BADADDR        | Address is out of valid range                                     |
| 0xA0158012  | K_ERR_VICAP_BUSY           | VICAP system is busy                                              |

## Debug Information

For VICAP memory management and system binding debug information, please refer to 《K230 System Control API Reference》.
