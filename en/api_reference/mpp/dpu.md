# K230 DPU API Reference

## Overview

### Overview

The DPU is primarily responsible for depth calculation of 3D structured light, providing depth information for 3D face recognition.

### Function Description

#### Binding Mode Call Flow

![Illustration, schematic diagram description automatically generated](https://download.kendryte.com/developer/pictures/b85b814d3911bf8b3802ba97751ff941.png)

#### Non-binding Mode Call Flow

![Illustration description automatically generated](https://download.kendryte.com/developer/pictures/dca3cfa887a526c493abced31b59afd2.png)

## API Reference

### DPU Usage

This function module provides the following APIs:

- [kd_mpi_dpu_init](#kd_mpi_dpu_init)
- [kd_mpi_dpu_delete](#kd_mpi_dpu_delete)
- [kd_mpi_dpu_parse_file](#kd_mpi_dpu_parse_file)
- [kd_mpi_dpu_set_dev_attr](#kd_mpi_dpu_set_dev_attr)
- [kd_mpi_dpu_get_dev_attr](#kd_mpi_dpu_get_dev_attr)
- [kd_mpi_dpu_set_ref_image](#kd_mpi_dpu_set_ref_image)
- [kd_mpi_dpu_set_processed_ref_image](#kd_mpi_dpu_set_processed_ref_image)
- [kd_mpi_dpu_set_template_image](#kd_mpi_dpu_set_template_image)
- [kd_mpi_dpu_start_dev](#kd_mpi_dpu_start_dev)
- [kd_mpi_dpu_set_chn_attr](#kd_mpi_dpu_set_chn_attr)
- [kd_mpi_dpu_get_chn_attr](#kd_mpi_dpu_get_chn_attr)
- [kd_mpi_dpu_start_chn](#kd_mpi_dpu_start_chn)
- [kd_mpi_dpu_stop_chn](#kd_mpi_dpu_stop_chn)
- [kd_mpi_dpu_send_frame](#kd_mpi_dpu_send_frame)
- [kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame)
- [kd_mpi_dpu_release_frame](#kd_mpi_dpu_release_frame)

#### kd_mpi_dpu_init

【Description】

Initialize the dpu device.

【Syntax】

```c
k_s32 kd_mpi_dpu_init(k_dpu_init_t *init);
```

【Parameters】

| Parameter Name | Description                                              | Input/Output |
|----------|------------------------------------------------------|-----------|
| init     | Pointer to the structure for initializing the dpu device. | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

None

【Example】

None

【Related Topics】

[k_dpu_init_t](#k_dpu_init_t)

#### kd_mpi_dpu_delete

【Description】

Delete an initialized dpu device.

【Syntax】

```c
k_s32 kd_mpi_dpu_delete();
```

【Parameters】

| Parameter Name | Description | Input/Output |
|----------|------|-----------|
| None       | None   | None        |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

This function can only be called to delete the dpu device after the dpu device has been initialized.

【Example】

None

【Related Topics】

None

#### kd_mpi_dpu_parse_file

【Description】

Parse dpu configuration parameters from the dpu configuration file.

【Syntax】

```c
k_s32 kd_mpi_dpu_parse_file(const k_char *param_path, k_dpu_dev_param_t *param, k_dpu_lcn_param_t *lcn_param, k_dpu_ir_param_t *ir_param, k_dpu_user_space_t *g_temp_space);
```

【Parameters】

| Parameter Name     | Description                                                                       | Input/Output |
|--------------|----------------------------------------------------------------------------|-----------|
| param_path   | Path to the configuration file                                                             | Input      |
| param        | Pointer to the dpu device parameter structure; the device parameters parsed from the configuration file are stored in this structure.   | Output      |
| lcn_param    | Pointer to the lcn channel parameter structure; the channel parameters parsed from the configuration file are stored in this structure. | Output      |
| ir_param     | Pointer to the ir channel parameter structure; the channel parameters parsed from the configuration file are stored in this structure.  | Output      |
| g_temp_space | Pointer to the template image structure; the starting address of the template image parsed from the configuration file is stored in this structure.     | Output      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- Dpu device parameters include long-period parameters and short-period parameters.
- lcn_param and ir_param are subsets of the dpu device parameters. If the dpu device parameters have already been configured, these two channel parameters can be ignored. If parameters in these two channel parameter structures need to be changed, you can modify the channel parameters and then call kd_mpi_dpu_set_chn_attr to make the changes take effect, or you can modify the device parameters and then call kd_mpi_dpu_set_dev_attr to make the changes take effect. If only the channel parameters are changed, calling kd_mpi_dpu_set_chn_attr is more efficient.
- The template image structure contains the virtual address and physical address of the template image parsed from the configuration file, as well as the size of the template image.

【Example】

None

【Related Topics】

[k_dpu_dev_param_t](#k_dpu_dev_param_t)

#### kd_mpi_dpu_set_dev_attr

【Description】

Configure dpu device attributes.

【Syntax】

```c
k_s32 kd_mpi_dpu_set_dev_attr(k_dpu_dev_attr_t *attr);
```

【Parameters】

| Parameter Name | Description         | Input/Output |
|----------|--------------|-----------|
| attr     | Dpu device attributes | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- This function can only be called to configure dpu device attributes after the dpu device has been initialized.
- When configuring dpu device attributes for the first time, tytz_temp_recfg and align_depth_recfg in attr should be set to K_TRUE so that the dpu loads the corresponding parameters. When modifying dpu device attributes subsequently, if the corresponding long-period parameters have not changed, setting these two members to K_FALSE can save the time for the dpu to reload the long-period parameters.

【Example】

None

【Related Topics】

[k_dpu_dev_attr_t](#k_dpu_dev_attr_t)

#### kd_mpi_dpu_get_dev_attr

【Description】

Get dpu device attributes.

【Syntax】

```c
k_s32 kd_mpi_dpu_get_dev_attr(k_dpu_dev_attr_t *attr);
```

【Parameters】

| Parameter Name | Description         | Input/Output |
|----------|--------------|-----------|
| attr     | Dpu device attributes | Output      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

None

【Example】

None

【Related Topics】

[k_dpu_dev_attr_t](#k_dpu_dev_attr_t)

#### kd_mpi_dpu_set_ref_image

【Description】

Configure the dpu reference image.

【Syntax】

```c
k_s32 kd_mpi_dpu_set_ref_image(const k_char *ref_path);
```

【Parameters】

| Parameter Name | Description       | Input/Output |
|----------|------------|-----------|
| ref_path | Reference image path | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- This function must be called after configuring the dpu device attributes to configure the reference image.

【Example】

None

【Related Topics】

None

#### kd_mpi_dpu_set_processed_ref_image

【Description】

Configure the offline-processed dpu reference image.

【Syntax】

```c
k_s32 kd_mpi_dpu_set_processed_ref_image(const k_char *ref_path);
```

【Parameters】

| Parameter Name | Description               | Input/Output |
|----------|--------------------|-----------|
| ref_path | Path to the processed reference image | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- This function must be called after configuring the dpu device attributes to configure the reference image. The configured reference image needs to be processed offline. Calling this function can save approximately 70ms compared to [kd_mpi_dpu_set_ref_image](#kd_mpi_dpu_set_ref_image).

【Example】

None

【Related Topics】

None

#### kd_mpi_dpu_set_template_image

【Description】

Configure the dpu template image.

【Syntax】

```c
k_s32 kd_mpi_dpu_set_template_image(k_dpu_user_space_t *temp_space);
```

【Parameters】

| Parameter Name   | Description           | Input/Output |
|------------|----------------|-----------|
| temp_space | Template image structure. | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- This function must be called after configuring the dpu device attributes to configure the reference image.
- temp_space needs to be passed as a parameter in [kd_mpi_dpu_parse_file](#kd_mpi_dpu_parse_file) to obtain the template image information from the configuration file.

【Example】

None

【Related Topics】

[k_dpu_user_space_t](#k_dpu_user_space_t)
[kd_mpi_dpu_parse_file](#kd_mpi_dpu_parse_file)

#### kd_mpi_dpu_start_dev

【Description】

Start the dpu device.

【Syntax】

```c
k_s32 kd_mpi_dpu_start_dev();
```

【Parameters】

| Parameter Name | Description | Input/Output |
|----------|------|-----------|
| None       | None   | None        |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

None

【Example】

None

【Related Topics】

None

#### kd_mpi_dpu_set_chn_attr

【Description】

Configure dpu channel attributes.

【Syntax】

```c
k_s32 kd_mpi_dpu_set_chn_attr(k_dpu_chn_lcn_attr_t *lcn_attr, k_dpu_chn_ir_attr_t *ir_attr);
```

【Parameters】

| Parameter Name | Description             | Input/Output |
|----------|------------------|-----------|
| lcn_attr | Speckle pattern channel attributes. | Input      |
| ir_attr  | Infrared image channel attributes. | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- The current dpu device has two channels in total: 0 and 1. The input/output channels for the speckle pattern and the infrared image are specified by configuring lcn_attr-\>chn_num and ir_attr-\>chn_num (if the infrared image channel is enabled).
- After starting the dpu device [kd_mpi_dpu_start_dev](#kd_mpi_dpu_start_dev) for the first time, this function should be called to configure channel attributes. The speckle pattern channel must be configured; the infrared image channel can be left unconfigured (configured as NULL) if it is not enabled.
- During operation, if only one channel's attributes need to be changed, only the structure parameter for that channel can be passed in, while the other channel's parameter can be NULL. Both channels' parameters can also be passed in at the same time. If both channels' parameters are NULL, the configuration will not take effect.

【Example】

None

【Related Topics】

[k_dpu_chn_lcn_attr_t](#k_dpu_chn_lcn_attr_t)
[k_dpu_chn_ir_attr_t](#k_dpu_chn_ir_attr_t)

#### kd_mpi_dpu_get_chn_attr

【Description】

Get dpu channel attributes.

【Syntax】

```c
k_s32 kd_mpi_dpu_get_chn_attr(k_dpu_chn_lcn_attr_t *lcn_attr, k_dpu_chn_ir_attr_t *ir_attr);
```

【Parameters】

| Parameter Name | Description             | Input/Output |
|----------|------------------|-----------|
| lcn_attr | Speckle pattern channel attributes. | Output      |
| ir_attr  | Infrared image channel attributes. | Output      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

None

【Example】

None

【Related Topics】

[k_dpu_chn_lcn_attr_t](#k_dpu_chn_lcn_attr_t)
[k_dpu_chn_ir_attr_t](#k_dpu_chn_ir_attr_t)

#### kd_mpi_dpu_start_chn

【Description】

Start a dpu channel.

【Syntax】

```c
k_s32 kd_mpi_dpu_start_chn(k_u32 chn_num);
```

【Parameters】

| Parameter Name | Description   | Input/Output |
|----------|--------|-----------|
| chn_num  | Channel number | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- The channel number should be 0 or 1.

【Example】

None

【Related Topics】

None

#### kd_mpi_dpu_stop_chn

【Description】

Stop a dpu channel.

【Syntax】

```c
k_s32 kd_mpi_dpu_stop_chn(k_u32 chn_num);
```

【Parameters】

| Parameter Name | Description   | Input/Output |
|----------|--------|-----------|
| chn_num  | Channel number | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- The channel number should be 0 or 1.

【Example】

None

【Related Topics】

None

#### kd_mpi_dpu_send_frame

【Description】

In non-binding mode, send one frame of data to the dpu.

【Syntax】

```c
k_s32 kd_mpi_dpu_send_frame(k_u32 chn_num, k_u64 addr, k_s32 s32_millisec);
```

【Parameters】

| Parameter Name     | Description                                                                                                                                                                                        | Input/Output |
|--------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| chn_num      | Channel number                                                                                                                                                                                      | Input      |
| addr         | Physical address of the data to be sent                                                                                                                                                                          | Input      |
| s32_millisec | Wait time. When this parameter is set to -1, it is blocking mode, and it returns only after the send is successful; when this parameter is set to 0, it is non-blocking mode, returning zero immediately on successful send or other values immediately on failed send. For specific failure information, refer to [dpu error code](#dpu-error-code); | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- If both the speckle pattern and infrared image paths are enabled at the same time, the infrared image and speckle pattern inputs must be strictly interleaved.

【Example】

None

【Related Topics】

None

#### kd_mpi_dpu_get_frame

【Description】

Get one frame of data from the dpu.

【Syntax】

```c
k_s32 kd_mpi_dpu_get_frame(k_u32 chn_num, k_dpu_chn_result_u *result, k_s32 s32_millisec);
```

【Parameters】

| Parameter Name     | Description                                                                                                                                                                                                     | Input/Output |
|--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| chn_num      | Channel number                                                                                                                                                                                                   | Input      |
| result       | Dpu output result union. Its member variables are k_dpu_chn_lcn_result_t and k_dpu_chn_ir_result_t. Which member is selected as the output result of this channel is determined by the user based on the configuration of [kd_mpi_dpu_set_chn_attr](#kd_mpi_dpu_set_chn_attr). | Output      |
| s32_millisec | Wait time. When this parameter is set to -1, it is blocking mode, and it returns only after the acquisition is successful; when this parameter is set to 0, it is non-blocking mode, returning zero immediately on successful acquisition or other values immediately on failed acquisition. For specific failure information, refer to [dpu error code](#dpu-error-code);              | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- If both the infrared image and speckle pattern are enabled at the same time, be sure to promptly retrieve the output results from both channels; otherwise, the results in the buffer may overflow, preventing further input.

【Example】

None

【Related Topics】

[k_dpu_chn_result_u](#k_dpu_chn_result_u)
[k_dpu_chn_lcn_result_t](#k_dpu_chn_lcn_result_t)
[k_dpu_chn_ir_result_t](#k_dpu_chn_ir_result_t)
[k_dpu_disp_out_t](#k_dpu_disp_out_t)
[k_dpu_depth_out_t](#k_dpu_depth_out_t)
[k_dpu_ir_out_t](#k_dpu_ir_out_t)
[k_dpu_qlt_out_t](#k_dpu_qlt_out_t)

#### kd_mpi_dpu_release_frame

【Description】

In non-binding mode, release the acquired result.

【Syntax】

```c
k_s32 kd_mpi_dpu_release_frame();
```

【Parameters】

None

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure; refer to the error code for the value. |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dpu_api.h
- Library file: libdpu.a

【Notes】

- This function releases the data in the buffer in order: the earliest generated result is released first. Currently, the dpu buffer size is 3. Please release the results obtained via [kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame) as soon as possible after use.

【Example】

None

【Related Topics】

None

## Data Types

### Public Data Types

This module has the following data types:

- [k_dpu_init_t](#k_dpu_init_t)
- [k_dpu_dev_param_t](#k_dpu_dev_param_t)
- [k_dpu_lcn_param_t](#k_dpu_lcn_param_t)
- [k_dpu_ir_param_t](#k_dpu_ir_param_t)
- [k_dpu_user_space_t](#k_dpu_user_space_t)
- [k_dpu_dev_attr_t](#k_dpu_dev_attr_t)
- [k_dpu_chn_lcn_attr_t](#k_dpu_chn_lcn_attr_t)
- [k_dpu_chn_ir_attr_t](#k_dpu_chn_ir_attr_t)
- [k_dpu_chn_result_u](#k_dpu_chn_result_u)
- [k_dpu_chn_lcn_result_t](#k_dpu_chn_lcn_result_t)
- [k_dpu_chn_ir_result_t](#k_dpu_chn_ir_result_t)
- [k_dpu_disp_out_t](#k_dpu_disp_out_t)
- [k_dpu_depth_out_t](#k_dpu_depth_out_t)
- [k_dpu_ir_out_t](#k_dpu_ir_out_t)
- [k_dpu_qlt_out_t](#k_dpu_qlt_out_t)

#### k_dpu_init_t

【Description】

dpu device initialization structure.

【Definition】

```c
typedef struct {
    k_u32 start_num;
    k_u32 buffer_num;
} k_dpu_init_t;
```

【Members】

| Member Name | Description                                                |
|-----------|-----------------------------------------------------|
| start_num | Starting frame number of the dpu device (i.e., the frame number of the first frame calculated by dpu).   |
| buffer_num| Number of dpu cached buffers, at least 1.                    |

【Notes】

None

【Related Data Types and Interfaces】

[kd_mpi_dpu_init](#kd_mpi_dpu_init)

#### k_dpu_dev_param_t

【Description】

dpu device parameter structure.

【Definition】

```c
typedef struct
{
    k_dpu_long_parameter_t lpp;
    k_dpu_short_parameter_t spp;
} k_dpu_dev_param_t;
```

【Members】

| Member Name | Description                 |
|----------|----------------------|
| lpp      | dpu long-period parameter structure |
| spp      | dpu short-period parameter structure |

【Notes】

- When the user needs to change the values in the long-period parameters, the virtual address member variable should be used.

【Related Data Types and Interfaces】

[k_dpu_long_parameter_t](#k_dpu_long_parameter_t)
[kd_mpi_dpu_parse_file](#kd_mpi_dpu_parse_file)

#### k_dpu_lcn_param_t

【Description】

Speckle image channel parameter structure.

【Definition】

```c
typedef struct {
    k_u8 matching_length_left_p0;
    k_u8 matching_length_right_p0;

    float image_check_match_threshold;
    float depth_p1;
    float depth_p2;
    float depth_precision;
} k_dpu_lcn_param_t;
```

【Members】
| Member Name                    | Description                                                                 |
|-----------------------------|---------------------------------------------------------------------|
| matching_length_left_p0     | Coarse search: leftward search range for disparity calculation, value: 0~256, integer                        |
| matching_length_right_p0    | Coarse search: rightward search range for disparity calculation, value: 0~256, integer                        |
| image_check_match_threshold | Speckle image quality assessment: template matching threshold, value range: 0.0~1.0, floating point: 0.01 precision       |
| depth_p1                    | Disparity to depth: depth value calculation coefficient p1, value range: 0.0~50000.0, floating point: 0.01 precision |
| depth_p2                    | Disparity to depth: depth value calculation coefficient p2, value range: -5.0~100.0, floating point: 0.01 precision  |
| depth_precision             | Disparity to depth: depth value precision (multiplier), value range: 0.0~100.0, floating point: 0.1 precision  |

【Notes】

- This channel structure parameter is a subset of the device structure parameters. If the device parameters have been configured and the channel parameters are the same as the device parameters, the channel parameters can be left unconfigured.

【Related Data Types and Interfaces】

[kd_mpi_dpu_parse_file](#kd_mpi_dpu_parse_file)

#### k_dpu_ir_param_t

【Description】

Infrared image channel parameter structure.

【Definition】

```c
typedef struct {
    float depth_k1;
    float depth_k2;
    float tz;
} k_dpu_ir_param_t;
```

【Members】
| Member Name | Description |
|---|---|
| depth_k1 | Directly corresponds to a register. Three-image alignment: depth value calculation coefficient k1, value range: 2e-4~1e-2, floating point: 1e-5 precision |
| depth_k2 | Directly corresponds to a register. Three-image alignment: depth value calculation coefficient k2, value range: 0.5~1.5, floating point: 0.001 precision |
| tz | Directly corresponds to a register. Three-image alignment: projector z-direction offset (mm), value range: -5.0~5.0, floating point: 0.001 precision |

【Notes】

- This channel structure parameter is a subset of the device structure parameters. If the device parameters have been configured and the channel parameters are the same as the device parameters, the channel parameters can be left unconfigured.

【Related Data Types and Interfaces】

[kd_mpi_dpu_parse_file](#kd_mpi_dpu_parse_file)

#### k_dpu_user_space_t

【Description】

User-acquired template image structure parameters.

【Definition】

```c
typedef struct {
    k_bool used;
    k_u32 size;
    k_u64 phys_addr;
    void *virt_addr;
} k_dpu_user_space_t;
```

【Members】

| Member Name  | Description                   |
|-----------|------------------------|
| used      | Users do not need to pay attention         |
| size      | The size of the template image obtained by the user |
| phys_addr | Physical address of the template image       |
| virt_addr | Virtual address of the template image       |

【Notes】

None

【Related Data Types and Interfaces】

[kd_mpi_dpu_parse_file](#kd_mpi_dpu_parse_file)

#### k_dpu_dev_attr_t

【Description】

Configure dpu device attribute structure.

【Definition】

```c
typedef struct {
    k_dpu_mode_e mode;
    k_bool tytz_temp_recfg;
    k_bool align_depth_recfg;
    k_bool ir_never_open;
    k_u32 param_valid;
    k_dpu_dev_param_t dev_param;
} k_dpu_dev_attr_t;
```

【Members】

| Member Name          | Description                                                                                                                     |
|-------------------|--------------------------------------------------------------------------------------------------------------------------|
| mode              | dpu operating mode, including bind mode and unbind mode.                                                                                 |
| tytz_temp_recfg   | Whether to update and load the SAD temperature compensation parameters and TyTz row compensation calculation algorithm. When this flag is K_FALSE, it indicates no update; when this flag is K_TRUE, it indicates update. |
| align_depth_recfg | Whether to update and load the three-image alignment/disparity-to-depth calculation parameters. When this flag is K_FALSE, it indicates no update; when this flag is K_TRUE, it indicates update.                 |
| ir_never_open     | The vb pool is configured when the dpu device is started and is released when the dpu device is paused. Its size is initialized when the device is started. Therefore, when the device is started, space is reserved for five parts: depth/disparity map, infrared output, quality detection, coarse and fine column disparity, and initial row-column determinant difference. Users can choose whether to enable three-image alignment through dev_param.spp.flag_align during the usage period.  If no infrared image output is needed throughout the entire usage period, there is no need to reserve space for the infrared image. Configuring K_TRUE indicates that no space needs to be reserved for infrared image output, and configuring K_FALSE indicates that space needs to be reserved for infrared image output. |
| param_valid       | When the user configures dpu device attributes, set this member to any non-zero value. When the device attribute takes effect, this arbitrary value will be returned in the output result of the corresponding effective frame.    |
| dev_param         | dpu device parameter structure.                                                                                                     |

【Notes】

- When configuring dpu device attributes for the first time, tytz_temp_recfg and align_depth_recfg should be configured as K_TRUE to make dpu load the corresponding parameters.

【Related Data Types and Interfaces】

[k_dpu_dev_param_t](#k_dpu_dev_param_t)
[kd_mpi_dpu_set_dev_attr](#kd_mpi_dpu_set_dev_attr)

#### k_dpu_chn_lcn_attr_t

【Description】

Configure speckle image channel attribute structure.

【Definition】

```c
typedef struct {
    k_u8 param_valid;
    k_s32 chn_num;
    k_dpu_lcn_param_t lcn_param;
} k_dpu_chn_lcn_attr_t;
```

【Members】

| Member Name    | Description                                                                                                                                                         |
|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| param_valid | When the user configures the speckle image channel attributes, set this member to any non-zero value. When the device attributes take effect, this arbitrary value will be returned in the output result of the corresponding effective frame.                                       |
| chn_num     | Channel number. Currently, the dpu device has two channels in total. The user can set this channel number to 0 or 1, and the speckle image channel will be input and output in the corresponding channel. If the infrared image channel is enabled, this channel number should be different from the infrared image channel number. |
| lcn_param   | Speckle image channel parameters.                                                                                                                                             |

【Notes】

None

【Related Data Types and Interfaces】

[kd_mpi_dpu_set_chn_attr](#kd_mpi_dpu_set_chn_attr)

#### k_dpu_chn_ir_attr_t

【Description】

Configure infrared image channel attribute structure.

【Definition】

```c
typedef struct {
    k_u8 param_valid;
    k_s32 chn_num;
    k_dpu_ir_param_t ir_param;
} k_dpu_chn_ir_attr_t;
```

【Members】

| Member Name    | Description                                                                                                                                   |
|-------------|----------------------------------------------------------------------------------------------------------------------------------------|
| param_valid | When the user configures the speckle image channel attributes, set this member to any non-zero value. When the device attributes take effect, this arbitrary value will be returned in the output result of the corresponding effective frame.                 |
| chn_num     | Channel number. Currently, the dpu device has two channels in total. The user can set this channel number to 0 or 1, and the infrared image channel will be input and output in the corresponding channel. This channel number should be different from the speckle image channel number. |
| ir_param    | Infrared image channel parameters.                                                                                                                       |

【Notes】

None

【Related Data Types and Interfaces】

[kd_mpi_dpu_set_chn_attr](#kd_mpi_dpu_set_chn_attr)

#### k_dpu_chn_result_u

【Description】

Union for obtaining dpu output results.

【Definition】

```c
typedef union {
    k_dpu_chn_lcn_result_t lcn_result;
    k_dpu_chn_ir_result_t ir_result;
} k_dpu_chn_result_u;
```

【Members】

| Member Name   | Description                                                                        |
|------------|-----------------------------------------------------------------------------|
| lcn_result | Speckle image channel output result structure. [k_dpu_chn_lcn_result_t](#k_dpu_chn_lcn_result_t) |
| ir_result  | Infrared image channel output result structure. [k_dpu_chn_ir_result_t](#k_dpu_chn_ir_result_t)   |

【Notes】

- The user needs to choose which member to use as the output result based on their own configuration. In [kd_mpi_dpu_set_chn_attr](#kd_mpi_dpu_set_chn_attr), the user configures the corresponding relationship between the channel number and the channel type.

【Related Data Types and Interfaces】

[k_dpu_chn_lcn_result_t](#k_dpu_chn_lcn_result_t)
[k_dpu_chn_ir_result_t](#k_dpu_chn_ir_result_t)
[kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame)

#### k_dpu_chn_lcn_result_t

【Description】

Structure of dpu speckle image channel output result.

【Definition】

```c
typedef struct {
    k_u32 time_ref;
    k_u64 pts;
    k_dpu_disp_out_t disp_out;
    k_dpu_depth_out_t depth_out;
    k_dpu_qlt_out_t qlt_out;
    k_dpu_param_flag_t flag;
} k_dpu_chn_lcn_result_t;
```

【Members】

| Member Name  | Description                                                                                                                                                                                                                   |
|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| pts       | Timestamp, valid in bind mode.                                                                                                                                                                                               |
| disp_out  | Disparity map output result structure.                                                                                                                                                                                                 |
| depth_out | Depth map output result structure.                                                                                                                                                                                                 |
| qlt_out   | Quality detection output result structure. Includes quality detection result, coarse and fine column disparity (initial resolution) result, and initial row-column determinant difference result.                                                                                                                            |
| flag      | This structure is used to mark in which frame the user-configured parameters take effect. The structure contains the param_valid variables from [k_dpu_dev_attr_t](#k_dpu_dev_attr_t), [k_dpu_chn_lcn_attr_t](#k_dpu_chn_lcn_attr_t), and [k_dpu_chn_ir_attr_t](#k_dpu_chn_ir_attr_t). |

【Notes】

None

【Related Data Types and Interfaces】

[k_dpu_disp_out_t](#k_dpu_disp_out_t)
[k_dpu_depth_out_t](#k_dpu_depth_out_t)
[k_dpu_qlt_out_t](#k_dpu_qlt_out_t)
[kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame)

#### k_dpu_chn_ir_result_t

【Description】

Structure of dpu infrared image channel output result.

【Definition】

```c
typedef struct {
    k_u32 time_ref;
    k_u64 pts;
    k_dpu_ir_out_t ir_out;
    k_dpu_param_flag_t flag;
} k_dpu_chn_ir_result_t;
```

【Members】

| Member Name | Description                                                                                                                                                                                                                   |
|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| pts      | Timestamp, valid in bind mode.                                                                                                                                                                                               |
| ir_out   | Infrared image output result structure.                                                                                                                                                                                                 |
| flag     | This structure is used to mark in which frame the user-configured parameters take effect. The structure contains the param_valid variables from [k_dpu_dev_attr_t](#k_dpu_dev_attr_t), [k_dpu_chn_lcn_attr_t](#k_dpu_chn_lcn_attr_t), and [k_dpu_chn_ir_attr_t](#k_dpu_chn_ir_attr_t). |

【Notes】

None

【Related Data Types and Interfaces】

[k_dpu_ir_out_t](#k_dpu_ir_out_t)
[kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame)

#### k_dpu_disp_out_t

【Description】

Structure of disparity map output result.

【Definition】

```c
typedef struct {
    k_bool valid;
    k_u32 length;
    k_u64 disp_phys_addr;
    k_u64 disp_virt_addr;
} k_dpu_disp_out_t;
```

【Members】

| Member Name       | Description                                                   |
|----------------|--------------------------------------------------------|
| valid          | K_TRUE: indicates the output result is valid; K_FALSE: indicates the output result is invalid. |
| length         | Length of the output result.                                         |
| disp_phys_addr | Physical address of the disparity map output result.                               |
| disp_virt_addr | Virtual address of the disparity map output result.                               |

【Notes】

None

【Related Data Types and Interfaces】

[k_dpu_chn_lcn_result_t](#k_dpu_chn_lcn_result_t)
[kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame)

#### k_dpu_depth_out_t

【Description】

Structure of depth map output result.

【Definition】

```c
typedef struct {
    k_bool valid;
    k_u32 length;
    k_u64 depth_phys_addr;
    k_u64 depth_virt_addr;
} k_dpu_depth_out_t;
```

【Members】

| Member Name        | Description                                                   |
|-----------------|--------------------------------------------------------|
| valid           | K_TRUE: indicates the output result is valid; K_FALSE: indicates the output result is invalid. |
| length          | Length of the output result.                                         |
| depth_phys_addr | Physical address of the depth map output result.                               |
| depth_virt_addr | Virtual address of the depth map output result.                               |

【Notes】

None

【Related Data Types and Interfaces】

[k_dpu_chn_lcn_result_t](#k_dpu_chn_lcn_result_t)
[kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame)

#### k_dpu_ir_out_t

【Description】

Structure of infrared image output result.

【Definition】

```c
typedef struct {
    k_bool valid;
    k_u32 length;
    k_u64 ir_phys_addr;
    k_u64 ir_virt_addr;
} k_dpu_ir_out_t;
```

【Members】

| Member Name     | Description                                                   |
|--------------|--------------------------------------------------------|
| valid        | K_TRUE: indicates the output result is valid; K_FALSE: indicates the output result is invalid. |
| length       | Length of the output result.                                         |
| ir_phys_addr | Physical address of the infrared image output result.                               |
| ir_virt_addr | Virtual address of the infrared image output result.                               |

【Notes】

None

【Related Data Types and Interfaces】

[k_dpu_chn_ir_result_t](#k_dpu_chn_ir_result_t)
[kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame)

#### k_dpu_qlt_out_t

【Description】

Structure of quality detection output result.

【Definition】

```c
typedef struct {
    k_bool valid;
    k_u32 qlt_length;
    k_u32 sad_disp_length;
    k_u32 init_sad_disp_length;
    k_u64 qlt_phys_addr;
    k_u64 qlt_virt_addr;
    k_u64 sad_disp_phys_addr;
    k_u64 sad_disp_virt_addr;
    k_u64 init_sad_disp_phys_addr;
    k_u64 init_sad_disp_virt_addr;
} k_dpu_qlt_out_t;
```

【Members】

| Member Name                | Description                                                   |
|-------------------------|--------------------------------------------------------|
| valid                   | K_TRUE: indicates the output result is valid; K_FALSE: indicates the output result is invalid. |
| qlt_length              | Length of the quality detection output result.                                 |
| sad_disp_length         | Length of the coarse and fine column disparity (initial resolution) output result.                 |
| init_sad_disp_length    | Length of the initial row-column determinant difference output result.                             |
| qlt_phys_addr           | Physical address of the quality detection output result.                             |
| qlt_virt_addr           | Virtual address of the quality detection output result.                             |
| sad_disp_phys_addr      | Physical address of the coarse and fine column disparity (initial resolution) output result.             |
| sad_disp_virt_addr      | Virtual address of the coarse and fine column disparity (initial resolution) output result.             |
| init_sad_disp_phys_addr | Physical address of the initial row-column determinant difference output result.                         |
| init_sad_disp_virt_addr | Virtual address of the initial row-column determinant difference output result.                         |

【Notes】

None

【Related Data Types and Interfaces】

[k_dpu_chn_lcn_result_t](#k_dpu_chn_lcn_result_t)
[kd_mpi_dpu_get_frame](#kd_mpi_dpu_get_frame)

### Long and Short Period Parameter Types

This module has the following data types:

- [k_dpu_long_parameter_t](#k_dpu_long_parameter_t)
- [k_dpu_short_parameter_t](#k_dpu_short_parameter_t)

#### k_dpu_long_parameter_t

【Description】

dpu long period parameter structure

【Definition】

The long period parameter has too many members to be shown here. Please refer to the structure k_dpu_long_parameter_t in k_dpu_comm.h in the K230_SDK.

【Notes】

- When the user needs to modify the values in the long period parameters, the virtual address member variable should be used.

【Related Data Types and Interfaces】

[k_dpu_dev_param_t](#k_dpu_dev_param_t)
[kd_mpi_dpu_parse_file](#kd_mpi_dpu_parse_file)
[kd_mpi_dpu_set_dev_attr](#kd_mpi_dpu_set_dev_attr)

#### k_dpu_short_parameter_t

【Description】

dpu short period parameter structure

【Definition】

The short period parameter has too many members to be shown here. Please refer to the structure k_dpu_short_parameter_t in k_dpu_comm.h in the K230_SDK.

【Notes】

None

【Related Data Types and Interfaces】

[k_dpu_dev_param_t](#k_dpu_dev_param_t)
[kd_mpi_dpu_set_dev_attr](#kd_mpi_dpu_set_dev_attr)
[kd_mpi_dpu_get_dev_attr](#kd_mpi_dpu_get_dev_attr)

## Error Codes

<a id="dpu-error-code"></a>

### dpu Error Codes

Table 41

| Error Code   | Macro Definition          | Description                          |
|--------------|---------------------------|--------------------------------------|
| 0xa0118001 | K_ERR_DPU_INVALID_DEVID   | Invalid device ID                    |
| 0xa0118002 | K_ERR_DPU_INVALID_CHNID   | Invalid channel ID                   |
| 0xa0118003 | K_ERR_DPU_ILLEGAL_PARAM   | Parameter error                      |
| 0xa0118004 | K_ERR_DPU_EXIST           | DPU device already exists            |
| 0xa0118005 | K_ERR_DPU_UNEXIST         | DPU device does not exist            |
| 0xa0118006 | K_ERR_DPU_NULL_PTR        | Null pointer error                   |
| 0xa0118007 | K_ERR_DPU_NOT_CONFIG      | DPU not yet configured               |
| 0xa0118008 | K_ERR_DPU_NOT_SUPPORT     | Unsupported feature                  |
| 0xa0118009 | K_ERR_DPU_NOT_PERM        | Operation not permitted              |
| 0xa011800c | K_ERR_DPU_NOMEM           | Memory allocation failed, e.g., insufficient system memory |
| 0xa011800d | K_ERR_DPU_NOBUF           | Insufficient BUFF                    |
| 0xa011800e | K_ERR_DPU_BUF_EMPTY       | BUFF is empty                        |
| 0xa011800f | K_ERR_DPU_BUF_FULL        | BUFF is full                         |
| 0xa0118010 | K_ERR_DPU_NOTREADY        | Device not ready                     |
| 0xa0118011 | K_ERR_DPU_BADADDR         | Incorrect address                    |
| 0xa0118012 | K_ERR_DPU_BUSY            | DPU is in a busy state               |

## Debug Information

### Overview

The debug information uses the proc file system, which can reflect the current system's running status in real time. The recorded information can be used for problem localization and analysis.

【File Directory】

/proc/

【File List】

| File Name | Description                                    |
|-----------|------------------------------------------------|
| umap/dpu  | Records some information about the dpu module |

### Debug Information

【Debug Information】

```shell
----------------------DPU Device Information----------------------
--------------------Pathway Switch Information--------------------
downScale: false align: false
align_ir: false align_rgbCoord: false
depthout: false denoise: false
median_p0: false median_denoise: false
median_post: false median_ir: false
check: false

----------------------Image Size Information----------------------
width_speckle: 0 height_speckle: 0
width_color: 0 height_color: 0
width_output: 0 height_output: 0

---------------------Result Length Information--------------------
sad_disp_x: 0 init_sad_disp_xy: 0
quanlity_check: 0 ir: 0
disp/depth: 0

----------------------------Frame Count---------------------------
from open to close, dpu has send 0 frames
```

【Pathway Selection Information】

| Parameter      | **Description**                                          |
|----------------|----------------------------------------------------------|
| downScale      | Whether to perform coarse search with reduced resolution |
| align          | Whether to perform three-image alignment                 |
| align_ir       | Whether to perform IR image alignment                    |
| align_rgbCoord | Whether to align disparity values to the color image coordinate system |
| depthout       | Whether to output the depth map                          |
| denoise        | Whether to denoise the disparity map                     |
| median_p0      | Whether to perform median filtering in coarse search     |
| median_denoise | Whether to perform internal median filtering in disparity denoising |
| median_post    | Whether to perform disparity post-processing / median filtering on the three-image alignment disparity map |
| median_ir      | Whether to perform median filtering on the three-image alignment IR map |
| check          | Whether to perform quality check and initial search on the object speckle map |

【Image Size Information】

| Parameter      | **Description**                                |
|----------------|------------------------------------------------|
| width_speckle  | Width in pixels of the original speckle/IR image |
| height_speckle | Height in pixels of the original speckle/IR image |
| width_color    | Width in pixels of the original color image    |
| height_color   | Height in pixels of the original color image   |
| width_output   | Width in pixels of the output disparity/depth/IR image |
| height_output  | Height in pixels of the output disparity/depth/IR image |

【Result Length Information】

| Parameter        | **Description**                                   |
|------------------|---------------------------------------------------|
| sad_disp_x       | Result length of coarse/fine column disparity (initial resolution) |
| init_sad_disp_xy | Result length of initial row-column disparity output |
| quanlity_check   | Result length of quality check                    |
| ir               | Result length of IR image                         |
| disp/depth       | Result length of disparity map / depth map        |

The debug information needs to be viewed during the dpu running process. After dpu finishes running, all current information will be reset to zero.

## demo Description

### dpu demo Introduction

The dpu demo implements both bound and unbound modes. Enter /bin/sample_dpu.elf in msh to execute the unbound mode, which ends after running ten frames; enter /bin/sample_dpu.elf BOUND in msh to execute the bound mode, where vvi acts as a simulated upper-level continuously feeding data to the dpu, and the dpu displays a message after completing the computation.

### Feature Description

The demo includes functions such as initializing and deleting the dpu, parsing parameters from the configuration file, configuring device properties, configuring channel properties, starting and pausing the device, starting and pausing channels, inputting and outputting data, and pipeline binding.

#### Unbound Mode

Complete the initialization of the dpu device by calling APIs, parse parameters from the configuration file, configure device properties based on the parsed parameters, call APIs to set the reference image and template image, start the dpu device, configure channel properties for the speckle image and infrared image, start the channels, loop input ten frames and compare results before stopping, stop the channels, stop the device, and delete the device.

#### Bound Mode

Complete the initialization of the dpu device by calling APIs, parse parameters from the configuration file, bind the vvi and dpu channels, configure device properties based on the parsed parameters, call APIs to set the reference image and template image, start the dpu device, configure channel properties for the speckle image and infrared image, start the dpu channel, start the vvi channel, and vvi acts as a simulated upper-level continuously feeding data to the dpu. After the user inputs e, the channels and device are stopped.

#### Compilation and Execution

For compilation and execution, please refer to the document "K230 SDK Demo User Guide".
