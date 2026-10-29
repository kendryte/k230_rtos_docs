# K230 DMA API Reference

## Overview

### Overview

GSDMA: DMA stands for Direct Memory Access, which copies data from one address space to another, providing high-speed data transfer between memories. GDMA stands for Graphic Direct Memory Access, responsible for copying images in memory to another block of memory, and can simultaneously complete functions such as image rotation and mirroring. SDMA stands for System Direct Memory Access, responsible for copying data in memory to another block of memory, which is the traditional meaning of DMA.

The software code provides each function of the GSDMA hardware to users in the form of APIs, helping users quickly implement image transfer, rotation, mirroring, 2D functions, and data transfer functions. At the same time, functions such as module status information statistics are implemented.

### Function Description

Abstract the dma hardware as a device with eight channels, among which channels 0\~3 are gdma channels, and channels 4\~7 are sdma channels.

#### gdma

Users use gdma to implement image rotation and mirroring. The main calling process is as follows:

1. Configure the dma device properties;
1. Start the dma device. After calling this function, the driver will automatically apply for VB space as the data buffer for the destination address;
1. Configure the gdma channel properties;
1. Start the gdma channel;
1. The user applies for VB space in user mode as the source data buffer, and calls kd_mpi_dma_send_frame to send the source address of the data to gdma;
1. The driver will transfer the data from the source address to the destination address data buffer applied for in step 2;
1. The user calls kd_mpi_dma_get_frame to obtain the data address in the destination address.

#### sdma

Users use sdma to implement data movement. The main calling process is as follows:

1. Configure the dma device properties;
1. Start the dma device. After calling this function, the driver will automatically apply for VB space as the data buffer for the destination address;
1. Configure the sdma channel properties;
1. Start the sdma channel;
1. The user applies for VB space in user mode as the source data buffer, and calls kd_mpi_dma_send_frame to send the source address of the data to sdma;
1. The driver will transfer the data from the source address to the destination address data buffer applied for in step 2;
1. The user calls kd_mpi_dma_get_frame to obtain the data address in the destination address.

## API Reference

### DMA Usage

This function module provides the following APIs:

- [kd_mpi_dma_set_dev_attr](#kd_mpi_dma_set_dev_attr)
- [kd_mpi_dma_get_dev_attr](#kd_mpi_dma_get_dev_attr)
- [kd_mpi_dma_start_dev](#kd_mpi_dma_start_dev)
- [kd_mpi_dma_stop_dev](#kd_mpi_dma_stop_dev)
- [kd_mpi_dma_set_chn_attr](#kd_mpi_dma_set_chn_attr)
- [kd_mpi_dma_get_chn_attr](#kd_mpi_dma_get_chn_attr)
- [kd_mpi_dma_start_chn](#kd_mpi_dma_start_chn)
- [kd_mpi_dma_stop_chn](#kd_mpi_dma_stop_chn)
- [kd_mpi_dma_send_frame](#kd_mpi_dma_send_frame)
- [kd_mpi_dma_get_frame](#kd_mpi_dma_get_frame)
- [kd_mpi_dma_release_frame](#kd_mpi_dma_release_frame)

#### kd_mpi_dma_set_dev_attr

【Description】

Configure dma device attributes.

【Syntax】

```c
k_s32 kd_mpi_dma_set_dev_attr(k_dma_dev_attr_t *attr);
```

【Parameters】

| Parameter Name | Description                          | Input/Output |
|----------|---------------------------|-----------|
| attr     | Pointer to the dma device attribute structure.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None.

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

None

【Example】

None

【Related Topics】

[k_dma_dev_attr_t](#k_dma_dev_attr_t)

#### kd_mpi_dma_get_dev_attr

【Description】

Get the configured dma device attributes.

【Syntax】

```c
k_s32 kd_mpi_dma_get_dev_attr(k_dma_dev_attr_t *attr);
```

【Parameters】

| Parameter Name | Description                   | Input/Output |
|----------|------------------------|-----------|
| attr     | Pointer to the dma device attribute structure | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

The dma device attributes can only be obtained after the dma device attributes have been configured.

【Example】

None

【Related Topics】

[k_dma_dev_attr_t](#k_dma_dev_attr_t)

#### kd_mpi_dma_start_dev

【Description】

Start the dma device.

【Syntax】

```c
k_s32 kd_mpi_dma_start_dev();
```

【Parameters】

| Parameter Name | Description | Input/Output |
|----------|------|-----------|
| None       | None   | None        |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

- This function can be called to start the dma only after the dma device attributes have been configured.

【Example】

None

【Related Topics】

None

#### kd_mpi_dma_stop_dev

【Description】

Stop the dma device.

【Syntax】

```c
kd_mpi_dma_stop_dev();
```

【Parameters】

| Parameter Name | Description | Input/Output |
|----------|------|-----------|
| None       | None   | None        |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

- This function can be called to stop the dma device only after the dma device has been started.

【Example】

None

【Related Topics】

None

#### kd_mpi_dma_set_chn_attr

【Description】

Configure dma channel attributes.

【Syntax】

```c
k_s32 kd_mpi_dma_set_chn_attr(k_u8 chn_num, k_dma_chn_attr_u *attr);
```

【Parameters】

| Parameter Name | Description                                                                                                                             | Input/Output |
|----------|----------------------------------------------------------------------------------------------------------------------------------|-----------|
| chn_num  | Channel number                                                                                                                           | Input      |
| attr     | Dma channel attributes. This parameter is a union, which can be used to configure gdma channel attributes or sdma channel attributes. Channels 0\~3 are gdma, and channels 4\~7 are sdma | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

None

【Example】

None

【Related Topics】

[k_dma_chn_attr_u](#k_dma_chn_attr_u)

#### kd_mpi_dma_get_chn_attr

【Description】

Get the configured dma channel attributes.

【Syntax】

```c
k_s32 kd_mpi_dma_get_chn_attr(k_u8 chn_num, k_dma_chn_attr_u *attr);
```

【Parameters】

| Parameter Name | Description                                                                                                                             | Input/Output |
|----------|----------------------------------------------------------------------------------------------------------------------------------|-----------|
| chn_num  | Channel number                                                                                                                           | Input      |
| attr     | Dma channel attributes. This parameter is a union, which can be used to obtain gdma channel attributes or sdma channel attributes. Channels 0\~3 are gdma, and channels 4\~7 are sdma | Output      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

- The dma channel attributes can only be obtained after the dma channel attributes have been configured.

【Example】

None

【Related Topics】

[k_dma_chn_attr_u](#k_dma_chn_attr_u)

#### kd_mpi_dma_start_chn

【Description】

Start the dma channel.

【Syntax】

```c
k_s32 kd_mpi_dma_start_chn(k_u8 chn_num);
```

【Parameters】

| Parameter Name | Description     | Input/Output |
|----------|----------|-----------|
| chn_num  | Channel number. | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

- The dma channel can be started only after the dma device has been configured and started, and the dma channel attributes have been configured.

【Example】

None

【Related Topics】

None

#### kd_mpi_dma_stop_chn

【Description】

Pause the dma channel.

【Syntax】

```c
k_s32 kd_mpi_dma_stop_chn(k_u8 chn_num);
```

【Parameters】

| Parameter Name | Description     | Input/Output |
|----------|----------|-----------|
| chn_num  | Channel number. | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

- This function can be called to stop the dma channel only after the dma channel has been started.

【Example】

None

【Related Topics】

None

#### kd_mpi_dma_send_frame

【Description】

Send data from user space to the destination address.

【Syntax】

```c
k_s32 kd_mpi_dma_send_frame(k_u8 chn_num, k_video_frame_info *df_info, k_s32 millisec);
```

【Parameters】

| Parameter Name | Description                                                                                                                                                                  | Input/Output |
|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| chn_num  | Channel number.                                                                                                                                                              | Input      |
| df_info  | Address information of the data to be sent.                                                                                                                                                  | Input      |
| millisec | Waiting time. When this parameter is set to -1, it blocks; when this parameter is set to 0, it is non-blocking; when this parameter is set to a value greater than 0, it will wait for the corresponding time until the data is successfully sent. If the data is still not successfully sent after the timeout, it returns failure. | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

None

【Example】

None

【Related Topics】

[k_video_frame_info](#k_video_frame_info)

#### kd_mpi_dma_get_frame

【Description】

Get the data transferred by dma.

【Syntax】

```c
k_s32 kd_mpi_dma_get_frame(k_u8 chn_num, k_video_frame_info *df_info, k_s32 millisec);
```

【Parameters】

| Parameter Name | Description                                                                                                                                                                  | Input/Output |
|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| chn_num  | Channel number.                                                                                                                                                              | Input      |
| df_info  | Address information of the obtained data.                                                                                                                                                  | Output      |
| millisec | Waiting time. When this parameter is set to -1, it blocks; when this parameter is set to 0, it is non-blocking; when this parameter is set to a value greater than 0, it will wait for the corresponding time until the data is successfully obtained. If the data is still not successfully obtained after the timeout, it returns failure. | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

None

【Example】

None

【Related Topics】

[k_video_frame_info](#k_video_frame_info)

#### kd_mpi_dma_release_frame

【Description】

Release the obtained dma data.

【Syntax】

```c
k_s32 kd_mpi_dma_release_frame(k_u8 chn_num, k_video_frame_info *df_info);
```

【Parameters】

| Parameter Name | Description           | Input/Output |
|----------|----------------|-----------|
| chn_num  | Channel number.       | Input      |
| df_info  | Data to be released. | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, see the error code for its value |

【Chip Differences】

None

【Requirements】

- Header file: mpi_dma_api.h
- Library file: libdma.a

【Note】

- In the current design, the dma output buffer is 3. If 3 frames of data are obtained without calling this function for release, data input cannot continue. Therefore, the user should release the data in time after obtaining and using it.

【Example】

None

【Related Topics】

[k_video_frame_info](#k_video_frame_info)

## Data Types

### Public Data Types

#### DMA_MAX_DEV_NUMS

【Description】

Maximum number of DMA devices

【Definition】

```c
#define DMA_MAX_DEV_NUMS (1)
```

【Notes】

None

【Related Data Types and Interfaces】

None

#### DMA_MAX_CHN_NUMS

【Description】

Maximum number of DMA channels

【Definition】

\#define DMA_MAX_CHN_NUMS (8)

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_dma_mode_e

【Description】

Defines the DMA working mode.

【Definition】

```c
typedef enum
{
    DMA_BIND,
    DMA_UNBIND,
} k_dma_mode_e;
```

【Members】

| Member Name | Description         |
|-------------|---------------------|
| BIND        | Bind mode.          |
| UNBIND      | Unbind mode         |

【Notes】

None

【Related Data Types and Interfaces】

[k_gdma_chn_attr_t](#k_gdma_chn_attr_t)
[k_sdma_chn_attr_t](#k_sdma_chn_attr_t)

#### k_dma_dev_attr_t

【Description】

Defines the DMA device attributes.

【Definition】

```c
typedef struct
{
    k_u8 burst_len;
    k_u8 outstanding;
    k_bool ckg_bypass;
} k_dma_dev_attr_t;
```

【Members】

| Member Name | Description                          |
|-------------|--------------------------------------|
| burst_len   | Configures the burst length of DMA   |
| outstanding | Configures DMA outstanding           |
| ckg_bypass  | Configures clock gate bypass         |

【Notes】

None

【Related Data Types and Interfaces】

[kd_mpi_dma_set_dev_attr](#kd_mpi_dma_set_dev_attr)
[kd_mpi_dma_get_dev_attr](#kd_mpi_dma_get_dev_attr)

#### k_dma_chn_attr_u

【Description】

Defines the DMA channel attributes.

【Definition】

```c
typedef union
{
    k_gdma_chn_attr_t gdma_attr;
    k_sdma_chn_attr_t sdma_attr;
} k_dma_chn_attr_u;
```

【Members】

| Member Name | Description              |
|-------------|--------------------------|
| gdma_attr   | GDMA channel attribute   |
| sdma_attr   | SDMA channel attribute   |
| ckg_bypass  | Configures clock gate bypass |

【Notes】

None

【Related Data Types and Interfaces】

[k_gdma_chn_attr_t](#k_gdma_chn_attr_t)
[k_sdma_chn_attr_t](#k_sdma_chn_attr_t)
[kd_mpi_dma_set_chn_attr](#kd_mpi_dma_set_chn_attr)
[kd_mpi_dma_get_chn_attr](#kd_mpi_dma_get_chn_attr)

#### k_video_frame_info

【Description】

Defines the DMA data address.

【Definition】

```c
typedef struct
{
    k_video_frame v_frame;  /**< Video picture frame */
    k_u32 pool_id;          /**< VB pool ID */
    k_mod_id mod_id;        /**< Logical unit for generating video frames */
} k_video_frame_info;
```

【Members】

| Member Name | Description                                |
|-------------|--------------------------------------------|
| v_frame     | Timestamp, valid in bind mode.             |
| pool_id     | Pool ID of the data VB pool.               |
| mod_id      | Module ID                                  |

【Notes】

None

【Related Data Types and Interfaces】

[kd_mpi_dma_send_frame](#kd_mpi_dma_send_frame)
[kd_mpi_dma_get_frame](#kd_mpi_dma_get_frame)
[kd_mpi_dma_release_frame](#kd_mpi_dma_release_frame)

#### k_video_frame

【Description】

Defines the DMA data address. Uses the public data structure k_video_frame, and only part of its members are used.

【Definition】

```c
typedef struct
{
    k_u64 phys_addr[3];
    k_u64 virt_addr[3];
    k_u32 time_ref;
    k_u64 pts;
} k_video_frame;
```

【Members】

| Member Name | Description                                                                                                                                                                                            |
|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| phys_addr   | Physical address of the image. For a single-channel image, only the first physical address needs to be configured; for a dual-channel image, only the first two physical addresses need to be configured; for a three-channel image, three physical addresses need to be configured. |
| virt_addr   | Virtual address of the image. For a single-channel image, only the first virtual address needs to be configured; for a dual-channel image, only the first two virtual addresses need to be configured; for a three-channel image, three virtual addresses need to be configured.   |
| time_ref    | Pass-through frame number, input by the previous stage in bind mode                                                                                                                                    |
| pts         | Pass-through timestamp, input by the previous stage in bind mode                                                                                                                                       |

【Notes】

None

【Related Data Types and Interfaces】

[kd_mpi_dma_send_frame](#kd_mpi_dma_send_frame)
[kd_mpi_dma_get_frame](#kd_mpi_dma_get_frame)

### gdma Channel Data Types

This module has the following data types

- [GDMA_MAX_CHN_NUMS](#gdma_max_chn_nums)
- [k_gdma_rotation_e](#k_gdma_rotation_e)
- [k_pixel_format_dma_e](#k_pixel_format_dma_e)
- [k_gdma_chn_attr_t](#k_gdma_chn_attr_t)

#### GDMA_MAX_CHN_NUMS

【Description】

Maximum number of GDMA channels

【Definition】

```c
define GDMA_MAX_CHN_NUMS (4)
```

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_gdma_rotation_e

【Description】

Defines the rotation angle of the gdma channel.

【Definition】

```c
typedef enum
{
    DEGREE_0,       /**< Rotate 0 degrees */
    DEGREE_90,      /**< Rotate 90 degrees */
    DEGREE_180,     /**< Rotate 180 degrees */
    DEGREE_270,     /**< Rotate 270 degrees */
} k_gdma_rotation_e;
```

【Notes】

None

【Related Data Types and Interfaces】

[k_gdma_chn_attr_t](#k_gdma_chn_attr_t)

#### k_pixel_format_dma_e

【Description】

Defines the gdma image format.

【Definition】

```c
typedef enum
{
    DMA_PIXEL_FORMAT_RGB_444 = 0,
    DMA_PIXEL_FORMAT_RGB_555,
    DMA_PIXEL_FORMAT_RGB_565,
    DMA_PIXEL_FORMAT_RGB_888,

    DMA_PIXEL_FORMAT_BGR_444,
    DMA_PIXEL_FORMAT_BGR_555,
    DMA_PIXEL_FORMAT_BGR_565,
    DMA_PIXEL_FORMAT_BGR_888,

    DMA_PIXEL_FORMAT_ARGB_1555,
    DMA_PIXEL_FORMAT_ARGB_4444,
    DMA_PIXEL_FORMAT_ARGB_8565,
    DMA_PIXEL_FORMAT_ARGB_8888,

    DMA_PIXEL_FORMAT_ABGR_1555,
    DMA_PIXEL_FORMAT_ABGR_4444,
    DMA_PIXEL_FORMAT_ABGR_8565,
    DMA_PIXEL_FORMAT_ABGR_8888,

    DMA_PIXEL_FORMAT_YVU_PLANAR_420_8BIT,
    DMA_PIXEL_FORMAT_YVU_PLANAR_420_10BIT,
    DMA_PIXEL_FORMAT_YVU_PLANAR_420_16BIT,
    DMA_PIXEL_FORMAT_YVU_PLANAR_444_8BIT,
    DMA_PIXEL_FORMAT_YVU_PLANAR_444_10BIT,

    DMA_PIXEL_FORMAT_YUV_PLANAR_420_8BIT,
    DMA_PIXEL_FORMAT_YUV_PLANAR_420_10BIT,
    DMA_PIXEL_FORMAT_YUV_PLANAR_420_16BIT,

    DMA_PIXEL_FORMAT_YVU_SEMIPLANAR_420_8BIT,
    DMA_PIXEL_FORMAT_YVU_SEMIPLANAR_420_10BIT,
    DMA_PIXEL_FORMAT_YVU_SEMIPLANAR_420_16BIT,

    DMA_PIXEL_FORMAT_YUV_SEMIPLANAR_420_8BIT,
    DMA_PIXEL_FORMAT_YUV_SEMIPLANAR_420_10BIT,
    DMA_PIXEL_FORMAT_YUV_SEMIPLANAR_420_16BIT,

    DMA_PIXEL_FORMAT_YUV_400_8BIT,
    DMA_PIXEL_FORMAT_YUV_400_10BIT,
    DMA_PIXEL_FORMAT_YUV_400_12BIT,
    DMA_PIXEL_FORMAT_YUV_400_16BIT,

    DMA_PIXEL_FORMAT_YUV_PACKED_444_8BIT,
    DMA_PIXEL_FORMAT_YUV_PACKED_444_10BIT,

    /* SVP data format */
    DMA_PIXEL_FORMAT_BGR_888_PLANAR,
} k_pixel_format_dma_e;
```

#### k_gdma_chn_attr_t

【Description】

Defines the gdma channel attributes.

【Definition】

```c
typedef struct
{
    k_u8 buffer_num;
    k_gdma_rotation_e rotation;
    k_bool x_mirror;
    k_bool y_mirror;
    k_u16 width;
    k_u16 height;
    k_u16 src_stride[3];
    k_u16 dst_stride[3];
    k_dma_mode_e work_mode;
    k_pixel_format_dma_e pixel_format;
} k_gdma_chn_attr_t;
```

【Members】

| Member Name  | Description                                                                                                                                                                                                                |
|--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| buffer_num   | Number of buffers for the gdma channel, at least 1. |
| rotation     | Rotation angle of the gdma channel.                                                                                                                                                                                        |
| x_mirror     | Whether the gdma channel performs horizontal mirroring                                                                                                                                                                    |
| y_mirror     | Whether the gdma channel performs vertical mirroring                                                                                                                                                                      |
| width        | Width of the gdma channel, in pixels.                                                                                                                                                                                      |
| height       | Height of the gdma channel, in pixels.                                                                                                                                                                                     |
| src_stride   | Source data stride of gdma. If the image format is single-channel mode, only `src_stride[0]` needs to be configured; if the image format is dual-channel mode, `src_stride[0]` and `src_stride[1]` need to be configured; if the image format is tri-channel mode, `src_stride[0]`, `src_stride[1]`, and `src_stride[2]` need to be configured.    |
| dst_stride   | Destination data stride of gdma. If the image format is single-channel mode, only `dst_stride[0]` needs to be configured; if the image format is dual-channel mode, `dst_stride[0]` and `dst_stride[1]` need to be configured; if the image format is tri-channel mode, `dst_stride[0]`, `dst_stride[1]`, and `dst_stride[2]` need to be configured. |
| work_mode    | Work mode, which can be either bound mode or unbound mode.                                                                                                                                                                 |
| pixel_format | Image format.                                                                                                                                                                                                              |

【Notes】

- None.

【Related Data Types and Interfaces】

- [kd_mpi_dma_set_chn_attr](#kd_mpi_dma_set_chn_attr)
- [kd_mpi_dma_get_chn_attr](#kd_mpi_dma_get_chn_attr)

### sdma Channel Data Types

This module has the following data types

- [SDMA_MAX_CHN_NUMS](#sdma_max_chn_nums)
- [k_sdma_data_mode_e](#k_sdma_data_mode_e)
- [k_sdma_chn_attr_t](#k_sdma_chn_attr_t)

#### SDMA_MAX_CHN_NUMS

【Description】

Maximum number of SDMA channels

【Definition】

```c
#define SDMA_MAX_CHN_NUMS (4)
```

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_sdma_data_mode_e

【Description】

Defines the data transfer mode of sdma channels

【Definition】

```c
typedef enum
{
    DIMENSION1,
    DIMENSION2,
} k_sdma_data_mode_e;
```

【Members】

| Member Name | Description         |
|-------------|---------------------|
| DIMENSION1  | 1D DMA transfer mode |
| DIMENSION1  | 2D DMA transfer mode |

【Notes】

None

【Related Data Types and Interfaces】

[k_sdma_chn_attr_t](#k_sdma_chn_attr_t)

#### k_sdma_chn_attr_t

【Description】

Defines sdma channel attributes.

【Definition】

```c
typedef struct
{
    k_u8 buffer_num;
    k_u32 line_size;
    k_u16 line_num;
    k_u16 line_space;
    k_sdma_data_mode_e data_mode;
    k_dma_mode_e work_mode;
} k_sdma_chn_attr_t;
```

【Members】

| Member Name | Description                                                                                                                                       |
|-------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| buffer_num  | Number of sdma channel buffers, at least 1.                                                                                                       |
| line_size   | For 1D mode, this is the total length of transferred data; for 2D mode, this is the length of a single line of data.                              |
| line_num    | For 1D mode, this member is invalid; for 2D mode, this is the number of lines transferred.                                                        |
| line_space  | For 1D mode, this member is invalid; for 2D mode, this is the interval between lines.                                                            |
| data_mode   | SDMA data transfer mode, including 1D mode and 2D mode.                                                                                           |
| work_mode   | Work mode, can be bound mode or unbound mode.                                                                                                     |

【Notes】

None

【Related Data Types and Interfaces】

[k_dma_chn_attr_u](#k_dma_chn_attr_u)

## Error Code

### DMA Error Code

Table 41

| Error Code    | Macro Definition           | Description                                  |
|---------------|----------------------------|----------------------------------------------|
| 0xa0148001    | K_ERR_DMA_INVALID_DEVID    | Invalid device ID                           |
| 0xa0148002    | K_ERR_DMA_INVALID_CHNID   | Invalid channel ID                          |
| 0xa0148003    | K_ERR_DMA_ILLEGAL_PARAM    | Parameter error                             |
| 0xa0148004    | K_ERR_DMA_EXIST            | DMA device already exists                   |
| 0xa0148005    | K_ERR_DMA_UNEXIST          | DMA device does not exist                   |
| 0xa0148006    | K_ERR_DMA_NULL_PTR         | Null pointer error                          |
| 0xa0148007    | K_ERR_DMA_NOT_CONFIG       | DMA not configured yet                      |
| 0xa0148008    | K_ERR_DMA_NOT_SUPPORT      | Unsupported feature                         |
| 0xa0148009    | K_ERR_DMA_NOT_PERM         | Operation not permitted                     |
| 0xa014800c    | K_ERR_DMA_NOMEM            | Memory allocation failed, e.g., insufficient system memory |
| 0xa014800d    | K_ERR_DMA_NOBUF            | Insufficient BUFF                           |
| 0xa014800e    | K_ERR_DMA_BUF_EMPTY        | BUFF is empty                               |
| 0xa014800f    | K_ERR_DMA_BUF_FULL         | BUFF is full                                |
| 0xa0148010    | K_ERR_DMA_NOTREADY         | Device not ready                            |
| 0xa0148011    | K_ERR_DMA_BADADDR          | Incorrect address                           |
| 0xa0148012    | K_ERR_DMA_BUSY             | DMA is in busy state                        |

## Debugging Information

### Overview

The debugging information uses the proc file system, which can reflect the current system's running status in real time. The recorded information can be used for problem locating and analysis.

【File Directory】

/proc/

【File List】

| File Name  | Description                            |
|------------|----------------------------------------|
| umap/dma   | Records the usage of the current DMA module |

### System Binding

#### System Binding Debugging Information

【Debugging Information】

```shell
msh /\>cat /proc/umap/dma
-------------------------------dma dev attr info---------------------------------
DevId burst_len outstanding ckg_bypass
0 0 0 0

-------------------------------dma chn 0\~3 attr info-------------------------------
ChnId rotation x_mirror y_mirror width height work_mode
0 0 false false 0 0 BIND
1 0 false false 0 0 BIND
2 0 false false 0 0 BIND
3 0 false false 0 0 BIND

-------------------------------dma chn 4\~7 attr info-------------------------------
ChnId line_size line_num line_space data_mode work_mode
4 0 0 0 1 DIMENSION BIND
5 0 0 0 1 DIMENSION BIND
6 0 0 0 1 DIMENSION BIND
7 0 0 0 1 DIMENSION BIND
```

【Debugging Information Analysis】

Records the usage of the current DMA module

【Device Parameter Description】

| Parameter    | **Description**       |
|--------------|-----------------------|
| DevId        | Device ID             |
| burst_len    | dma burst length      |
| outstanding  | dma outstanding       |

【GDMA Channel Parameter Description】

| Parameter  | **Description**                |
|------------|--------------------------------|
| ChnId      | Channel ID                     |
| rotation   | Rotation degrees               |
| x_mirror   | Whether horizontal mirroring is performed |
| y_mirror   | Whether vertical mirroring is performed   |
| width      | Image width, in pixels         |
| height     | Image height, in pixels        |
| work_mode  | Working mode                   |

【SDMA Channel Parameter Description】

| Parameter    | **Description**                                                                                                                                          |
|--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| ChnId        | Channel ID                                                                                                                                               |
| line_size    | For 1D mode, it is the total length of the transmitted data; for 2D mode, it is the length of a single row of data.                                      |
| ine_num      | For 1D mode, this member is invalid; for 2D mode, it is the number of rows to be transmitted.                                                            |
| line_space   | For 1D mode, this member is invalid; for 2D mode, it is the interval between rows.                                                                       |
| data_mode    | SDMA data transfer mode, including 1D mode and 2D mode                                                                                                  |
| work_mode    | Working mode, which can be selected as binding mode or non-binding mode.                                                                                 |

## demo description

### Non-binding mode demo

The non-binding mode demo is located at /bin/sample_dma.elf. After executing /bin/sample_dma.elf, it starts running in a loop. Press e + Enter to end the running.

The demo mainly implements the following functions:

- Use channel 0 to transfer an image with a resolution of 1920\*1080, 8bit, YUV400 single-channel, and output after gdma rotates 90 degrees;
- Use channel 1 to transfer an image with a resolution of 1280\*720, 8bit, YUV420 dual-channel, and output after gdma rotates 180 degrees;
- Use channel 2 to transfer an image with a resolution of 1280\*720, 10bit, YUV420 three-channel, and output after gdma performs horizontal and vertical mirroring;
- Use channel 4 to transfer data, sdma uses 1d mode for transfer;
- Use channel 5 to transfer data, sdma uses 2d mode for transfer.

### Binding mode demo

The binding mode demo is located at /bin/sample_dma_bind.elf. After executing /bin/sample_dma_bind.elf, it starts running in a loop. Press e + Enter to end the running.

The demo mainly implements the following functions:

- Use the vvi module as the simulated input for the gsdma front-end binding to implement the binding function test;
- The two channels respectively input images with a resolution of 640\*320, 8bit, YUV400 single-channel, and output after gdma rotates 90 degrees and 180 degrees respectively.
