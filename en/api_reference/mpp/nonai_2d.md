# K230 nonai 2D API Reference

## Overview

### Overview

The nonai 2D hardware can implement OSD, frame drawing, and CSC functions. This document only describes the CSC function. The OSD and frame drawing functions are not yet implemented in the APIs in this document and may be added in the future if needed.

The VENC module uses nonai 2D hardware to overlay OSD and draw frames on encoded images, limited to encoded images and cannot be used independently. See sections 1.2.1.4 and 2.1.14 to 2.1.29 of the "K230_Video Codec_API Reference".

### Function Description

Implements mutual conversion between RGB and YUV. As a module of mpp, it can participate in system binding functions, and can perform single-frame processing when not bound.

Supports mutual conversion of the following image formats:

PIXEL_FORMAT_YUV_SEMIPLANAR_420

PIXEL_FORMAT_YVU_PLANAR_420

PIXEL_FORMAT_YUV_PACKAGE_444

PIXEL_FORMAT_YVU_PLANAR_444

PIXEL_FORMAT_RGB_565

PIXEL_FORMAT_RGB_888

PIXEL_FORMAT_RGB_888_PLANAR

Code example:

```c
k_nonai_2d_chn_attr attr_2d;
k_video_frame_info input;
k_video_frame_info output;
int ch = 0;

attr_2d.mode = K_NONAI_2D_CALC_MODE_CSC;
attr_2d.dst_fmt = PIXEL_FORMAT_YUV_SEMIPLANAR_420;
kd_mpi_nonai_2d_create_chn(ch, &attr_2d);
kd_mpi_nonai_2d_start_chn(ch);

input.v_frame.pixel_format = PIXEL_FORMAT_RGB_888;
kd_mpi_nonai_2d_send_frame(ch, &input, 1000);
kd_mpi_nonai_2d_get_frame(ch, &output, 1000);

kd_mpi_nonai_2d_stop_chn(ch);
kd_mpi_nonai_2d_destroy_chn(ch);
```

## API Reference

- [kd_mpi_nonai_2d_request_chn](#kd_mpi_nonai_2d_request_chn)
- [kd_mpi_nonai_2d_release_chn](#kd_mpi_nonai_2d_release_chn)
- [kd_mpi_nonai_2d_attach_vb_pool](#kd_mpi_nonai_2d_attach_vb_pool)
- [kd_mpi_nonai_2d_detach_vb_pool](#kd_mpi_nonai_2d_detach_vb_pool)
- [kd_mpi_nonai_2d_create_chn](#kd_mpi_nonai_2d_create_chn)
- [kd_mpi_nonai_2d_destroy_chn](#kd_mpi_nonai_2d_destroy_chn)
- [kd_mpi_nonai_2d_start_chn](#kd_mpi_nonai_2d_start_chn)
- [kd_mpi_nonai_2d_stop_chn](#kd_mpi_nonai_2d_stop_chn)
- [kd_mpi_nonai_2d_get_frame](#kd_mpi_nonai_2d_get_frame)
- [kd_mpi_nonai_2d_release_frame](#kd_mpi_nonai_2d_release_frame)
- [kd_mpi_nonai_2d_send_frame](#kd_mpi_nonai_2d_send_frame)

### kd_mpi_nonai_2d_request_chn

【Description】

Requests an idle 2D channel.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_request_chn(k_u32* chn_num);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num  | Output the requested idle channel number, range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Output      |

【Return Value】

| Return Value | Description                          |
|---|---|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- If chn_num is a NULL pointer, returns K_ERR_NONAI_2D_NULL_PTR.
- If there is no idle channel, returns K_ERR_NONAI_2D_NOBUF or the corresponding no-resource error code.
- The requested channel must be initialized via kd_mpi_nonai_2d_create_chn before use.

【Example】

None.

【Related Topics】

kd_mpi_nonai_2d_release_chn, kd_mpi_nonai_2d_create_chn

### kd_mpi_nonai_2d_release_chn

【Description】

Releases a requested 2D channel.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_release_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num  | The channel number to release, range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input      |

【Return Value】

| Return Value | Description                          |
|---|---|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- If the channel number is out of the valid range, returns K_ERR_NONAI_2D_INVALID_CHNID.
- If the channel has not been requested or has already been released, returns K_ERR_NONAI_2D_UNEXIST.
- Before releasing the channel, ensure that the channel has been stopped (kd_mpi_nonai_2d_stop_chn) and destroyed (kd_mpi_nonai_2d_destroy_chn), otherwise an operation-not-permitted error is returned.

【Example】

None.

【Related Topics】

kd_mpi_nonai_2d_request_chn, kd_mpi_nonai_2d_destroy_chn

### kd_mpi_nonai_2d_attach_vb_pool

【Description】

Attaches a VB (Video Buffer) pool to a specified 2D channel.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_attach_vb_pool(k_u32 chn_num, k_u32 pool_id);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num  | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input      |
| pool_id  | VB pool ID. | Input      |

【Return Value】

| Return Value | Description                          |
|---|---|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- It can be set on the fly
- If the channel number is invalid, returns K_ERR_NONAI_2D_INVALID_CHNID.
- If the channel has not been created, returns K_ERR_NONAI_2D_UNEXIST.
- If the VB pool ID is invalid, returns K_ERR_NONAI_2D_ILLEGAL_PARAM.
- A channel can only be bound to one VB pool at a time; rebinding will overwrite the original binding.

【Example】

None.

【Related Topics】

kd_mpi_nonai_2d_detach_vb_pool

### kd_mpi_nonai_2d_detach_vb_pool

【Description】

Detaches the VB pool from the specified 2D channel.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_detach_vb_pool(k_u32 chn_num);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num  | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input      |

【Return Value】

| Return Value | Description                          |
|---|---|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- It can be set on the fly
- If the channel number is invalid, returns K_ERR_NONAI_2D_INVALID_CHNID.
- If the channel has not been created, returns K_ERR_NONAI_2D_UNEXIST.
- If the channel is not bound to any VB pool, success is still returned (no error).

【Example】

None.

【Related Topics】

kd_mpi_nonai_2d_attach_vb_pool

### kd_mpi_nonai_2d_create_chn

【Description】

Creates a channel.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_create_chn(k_u32 chn_num, const k_nonai_2d_chn_attr *attr);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num  | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input      |
| attr     | Pointer to channel attributes.                                                   | Input      |

【Return Value】

| Return Value | Description |
|---|---|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

None.

【Example】

None.

【Related Topics】

None.

### kd_mpi_nonai_2d_destroy_chn

【Description】

Destroys a channel.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_destroy_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num  | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input      |

【Return Value】

| Return Value | Description                          |
|---|---|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- Before destroying, kd_mpi_nonai_2d_stop_chn must be called to stop receiving images, otherwise the operation fails.

【Example】

None.

【Related Topics】

None.

### kd_mpi_nonai_2d_start_chn

【Description】

Starts receiving input images.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_start_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input |

【Return Value】

| Return Value | Description                          |
|--------|-------------------------------|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- If the channel has not been created, returns failure K_ERR_NONAI_2D_UNEXIST.
- If the channel has already started receiving images, calling this interface again before stopping to specify the number of received frames returns operation-not-permitted.
- Frames are processed only after receiving is started.

【Example】

None.

【Related Topics】

None.

### kd_mpi_nonai_2d_stop_chn

【Description】

Stops receiving input images.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_stop_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input |

【Return Value】

| Return Value | Description                          |
|--------|-------------------------------|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- If the channel has not been created, returns failure.
- This interface does not check whether reception has already been stopped, i.e., repeated stops are allowed without returning an error.
- This interface is used to stop receiving images; reception must be stopped before destroying or resetting the channel.
- Calling this interface only stops receiving raw data; the frame buffer is not cleared.

【Example】

None.

【Related Topics】

None.

### kd_mpi_nonai_2d_get_frame

【Description】

Gets the processed image.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_get_frame(k_u32 chn_num, k_video_frame_info *frame, k_s32 milli_sec);
```

【Parameters】

| Parameter  | Description | Input/Output |
|---|---|---|
| chn_num | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input |
| frame    | Pointer to the image structure. | Output |
| milli_sec | Timeout for getting an image. Range: [-1, +∞] -1: blocking. 0: non-blocking. >0: timeout duration. | Input |

【Return Value】

| Return Value | Description                          |
|--------|-------------------------------|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- If the channel has not been created, returns failure.
- If frame is NULL, returns K_ERR_NONAI_2D_NULL_PTR.
- If milli_sec is less than -1, returns K_ERR_NONAI_2D_ILLEGAL_PARAM.

【Example】

None.

【Related Topics】

None.

### kd_mpi_nonai_2d_release_frame

【Description】

Releases the image cache.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_release_frame(k_u32 chn_num, k_video_frame_info *frame);
```

【Parameters】

| Parameter | Description | Input/Output |
|---|---|---|
| chn_num  | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input |
| frame   | Pointer to the image structure. | Output |

【Return Value】

| Return Value | Description |
|---|---|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- If the channel has not been created, returns error code K_ERR_NONAI_2D_UNEXIST.
- If frame is NULL, returns error code K_ERR_NONAI_2D_NULL_PTR.

【Example】

None.

【Related Topics】

None.

### kd_mpi_nonai_2d_send_frame

【Description】

Supports the user in sending original images for 2D operations.

【Syntax】

```c
k_s32 kd_mpi_nonai_2d_send_frame(k_u32 chn_num, k_video_frame_info *frame, k_s32 milli_sec);
```

【Parameters】

| Parameter  | Description | Input/Output |
|---|---|---|
| chn_num | Channel number. Range: [0, K_NONAI_2D_MAX_CHN_NUMS]. | Input |
| frame | Pointer to the original image information structure, refer to "K230 System Control API Reference". | Input |
| milli_sec | Timeout for sending an image. Range: [-1, +∞] -1: blocking. 0: non-blocking. > 0: timeout duration. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0      | Success.                        |
| Non-zero | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_nonai_2d_api.h, k_type.h, k_module.h, k_sys_comm.h, k_nonai_2d_comm.h
- Library file: libvenc.a

【Notes】

- This interface supports the user in sending images to a channel.
- If milli_sec is less than -1, returns K_ERR_NONAI_2D_ILLEGAL_PARAM.
- To call this interface to send images, the user must ensure that the channel has been created and that input image reception has been started.

【Example】

None.

【Related Topics】

None.

## Data Types

The related data type definitions for this functional module are as follows:

### K_NONAI_2D_MAX_CHN_NUMS

【Description】

Defines the maximum number of channels.

【Definition】

```c
#define K_NONAI_2D_MAX_CHN_NUMS  24
```

【Notes】

None.

【Related Data Types and Interfaces】

None.

### k_nonai_2d_calc_mode

【Description】

Defines the 2D operation mode.

【Definition】

```text
typedef enum
{
​     K_NONAI_2D_CALC_MODE_CSC = 0,    /* Color space conversion */
​     K_NONAI_2D_CALC_MODE_OSD,      /* On Screen Display */
​     K_NONAI_2D_CALC_MODE_BORDER,     /* Draw border */
​     K_NONAI_2D_CALC_MODE_OSD_BORDER,   /* OSD first, then draw border */
​     K_NONAI_2D_CALC_MODE_BUTT
} k_nonai_2d_calc_mode;
```

【Members】

| Member Name | Description           |
| -------- | --------------------- |
| mode     | 2D calculation mode |

【Notes】

Currently only the CSC mode is supported; other modes are not yet implemented.

【Related Data Types and Interfaces】

None.

### k_nonai_2d_chn_attr

【Description】

Defines the channel attributes.

【Definition】

```text
typedef struct
{
​      k_pixel_format dst_fmt;     /* Format of output image */
​      k_nonai_2d_calc_mode mode;
} k_nonai_2d_chn_attr;
```

【Members】

| Member Name | Description                  |
| -------- | --------------------- |
| dst_fmt  | Format of the output image, see Section 1.2 |
| mode     | 2D calculation mode, see Section 3.2 |

【Notes】

【Related Data Types and Interfaces】

None.

### k_nonai_2d_color_gamut

【Description】

Defines the color type of CSC, with BT601 as the default.

【Definition】

```text
typedef enum
{
​     NONAI_2D_COLOR_GAMUT_BT601 = 0,
​     NONAI_2D_COLOR_GAMUT_BT709,
​     NONAI_2D_COLOR_GAMUT_BT2020,
​     NONAI_2D_COLOR_GAMUT_BUTT
} k_nonai_2d_color_gamut;
```

【Notes】

None.

【Related Data Types and Interfaces】

None.

<a id="error-code"></a>

## Error Codes

Table 41  API Error Codes
| Error Code | Macro Definition              | Description                                                       |
| ---------- | ----------------------------- | ----------------------------------------------------------------- |
| 0xa0188001 | K_ERR_NONAI_2D_INVALID_DEVID  | Device ID out of legal range                                      |
| 0xa0188002 | K_ERR_NONAI_2D_INVALID_CHNID  | Channel ID out of legal range                                     |
| 0xa0188003 | K_ERR_NONAI_2D_ILLEGAL_PARAM  | Parameter out of legal range                                      |
| 0xa0188004 | K_ERR_NONAI_2D_EXIST          | Trying to apply for or create an already existing device, channel, or resource |
| 0xa0188005 | K_ERR_NONAI_2D_UNEXIST        | Trying to use or destroy a non-existent device, channel, or resource |
| 0xa0188006 | K_ERR_NONAI_2D_NULL_PTR       | Null pointer in function parameters                               |
| 0xa0188007 | K_ERR_NONAI_2D_NOT_CONFIG     | Not configured before use                                         |
| 0xa0188008 | K_ERR_NONAI_2D_NOT_SUPPORT    | Unsupported parameter or function                                 |
| 0xa0188009 | K_ERR_NONAI_2D_NOT_PERM       | Operation not permitted, such as attempting to modify static configuration parameters |
| 0xa018800c | K_ERR_NONAI_2D_NOMEM          | Memory allocation failed, such as insufficient system memory      |
| 0xa018800d | K_ERR_NONAI_2D_NOBUF          | Buffer allocation failed, such as the requested data buffer is too large |
| 0xa018800e | K_ERR_NONAI_2D_BUF_EMPTY      | No data in the buffer                                            |
| 0xa018800f | K_ERR_NONAI_2D_BUF_FULL       | Buffer is full                                                    |
| 0xa0188010 | K_ERR_NONAI_2D_NOTREADY       | System not initialized or corresponding module not loaded         |
| 0xa0188011 | K_ERR_NONAI_2D_BADADDR        | Address out of legal range                                        |
| 0xa0188012 | K_ERR_NONAI_2D_BUSY           | NONAI_2D system busy                                              |
