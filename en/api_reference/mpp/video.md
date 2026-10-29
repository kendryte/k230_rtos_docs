# K230 Video Codec API Reference

## Overview

### Overview

The video codec module has powerful functions and can support H.264, H.265, and JPEG codec. Among them, the VENC module is responsible for implementing 2D operations and encoding functions. These two functions can be enabled simultaneously or can be operated independently. The VDEC module focuses on implementing the decoding function.
It should be noted that VENC, VENC + 2D, and VDEC support system binding, but when 2D operations are performed independently, system binding is not supported.

### Functional Description

#### Video Encoding Module

![encode flow](https://download.kendryte.com/developer/pictures/9f7f41ea96a97ae9bf514535f6af1622.jpeg)

A typical video encoding process includes multiple key steps, such as receiving input images, image content masking and overlay processing, image encoding, and final bitstream output.

The encoding module is mainly composed of VENC receive channel, encoding channel, 2D receive channel, and 2D operation module. The specific encoding capabilities and 2D operation capabilities are detailed in the table below.

In the encoding data flow diagram, the path indicated by the green arrow is the process for performing 2D operations independently; the path indicated by the blue arrow is the process for performing encoding operations independently; the path indicated by the purple arrow is the process for performing 2D operations first, followed by encoding.

|              | H264                                                                                                            | HEVC                                                    | JPEG                                                   |
| ------------ | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------ |
| Input Format | YUV420 NV12 8bit, ARGB8888, BGRA8888                                                                            | YUV420 NV12 8bit, ARGB8888, BGRA8888                    | YUV420 NV12 8bit, YUV422 UYVY 8bit, ARGB8888, BGRA8888 |
| Output Format| YUV420 H.264 Baseline Profile(BP) ; H.264 Main Profile(MP) ; H.264 High Profile(HP);  H.264 High 10 Profile(HP) | YUV420 HEVC (H.265) Main ; HEVC (H.265) Main 10 Profile | YUV420 and YUV422 JPEG baseline sequential             |
| Max Resolution| 3840x2160                                                                                                       | 3840x2160                                               | 8192x8192                                              |
| Min Resolution| 128x64                                                                                                          | 128x64                                                  | 128x64                                                 |
| Bitrate Control Mode| CBR/VBR/FIXQP                                                                                              | CBR/VBR/FIXQP                                           | FIXQP                                                  |
| GOP          | I/P frames                                                                                                       | I/P frames                                              | -                                                      |
| Encoding Channels | 4 channels                                                                                                | 4 channels                                              | 4 channels                                             |

Note: H264/HEVC/JPEG share 4 channels.

| video input format           | video output format | overlay data format          | max resolution |
| --------------------------- | ------------------- | ---------------------------- | -------------- |
| I420/NV12/ARGB8888/BGRA8888 | Same as input format| ARGB8888/ARGB4444/ARGB1555   | 3840x2160      |

##### Encoding Channel

The encoding channel serves as a basic container for saving various user settings of the encoding channel and managing various internal resources of the encoding channel. It mainly completes the functions of image overlay and encoding. Among them, the 2D module is responsible for implementing image overlay operations, while the encoder module is responsible for implementing image encoding. These two modules can be used independently or in coordination.

![encode channel](https://download.kendryte.com/developer/pictures/d8ea12750bef3150afebf98c8a4563fd.jpeg)

##### Bitrate Control

The main function of the bitrate controller is to precisely control the encoding bitrate.

From the perspective of informatics, the compression ratio of an image is inversely proportional to the quality of the compressed image, that is, the lower the compression ratio, the higher the quality of the compressed image; conversely, the higher the compression ratio, the lower the quality of the compressed image. In the case of scene changes, if the stability of image quality is pursued, the encoding bitrate will fluctuate significantly; and if the stability of the encoding bitrate is pursued, the image quality will fluctuate significantly. H264/H265 encoding supports three bitrate control modes: CBR, VBR, and FIXQP, while MJPEG only supports the FIXQP mode.

- CBR: (Constant Bit Rate) Fixed bit rate. That is, the encoding bitrate is guaranteed to be stable within the bitrate statistics time.
- VBR: (Variable Bit Rate) Variable bit rate, that is, the encoding bitrate is allowed to fluctuate within the bitrate statistics time, thereby ensuring stable encoded image quality.
- FIXQP: Fixed QP value. Within the bitrate statistics time, all macroblock QP values of the encoded image are the same, using the image QP value set by the user.

##### GOP Structure

This module only supports I frames and P frames.

##### 2D Operations

The 2D operation module can implement OSD overlay on image data. The OSD mode can implement 8 region image overlays, and each region does not overlap. The supported OSD formats are: ARGB4444/ARGB1555/ARGB8888.

<a id="venc-2d-conversion-coefficients"></a>

###### Calculation of 2D Conversion Coefficients

During OSD overlay operations, if the input video format is YUV, the OSD layer needs to perform RGB to YUV conversion. There is a set of default conversion coefficients in the kernel state. If the user needs to customize a set of 12-bit conversion coefficients, they can be obtained through the RGB to YUV conversion formula.

The known RGB to YUV conversion formula is as follows:

![osd formula](https://download.kendryte.com/developer/pictures/osd_formula.png)

The specific calculation method is: multiply the coefficients in the 3\*3 matrix by 256 and round to the nearest integer to obtain the corresponding conversion coefficients, and the values in the 3\*1 matrix are the corresponding conversion coefficients.

Taking BT709 LIMITED as an example, the RGB-\>YUV conversion formula is:

Y = 0.1826\*R + 0.6142\*G + 0.0620\*B + 16

U = -0.1007\*R - 0.3385\*G + 0.4392\*B + 128

V = 0.4392\*R - 0.3990\*G - 0.0402\*B + 128

From this, the conversion coefficients are: { 47, 157, 16, 16, -26, -86, 112, 128, 112, -102, -10, 128 }

###### Configuration of 2D Conversion Coefficients

The 2D conversion coefficients can be configured through the user-defined coefficients interface [kd_mpi_venc_set_2d_custom_coef](#kd_mpi_venc_set_2d_custom_coef) and the color gamut configuration interface [kd_mpi_venc_set_2d_color_gamut](#kd_mpi_venc_set_2d_color_gamut). The user only needs to choose one of these interfaces for configuration. If neither interface is called before starting the operation, the default coefficients will be used for color gamut conversion. Selecting one of the two interfaces for configuration is sufficient. If neither interface is called before starting the operation, the default coefficients will be used for color gamut conversion.

##### Constraints

The encoding operation has the following constraints:

1. If the input data format is YUV420, the physical start address of the image data for each component Y, U, and V needs to be guaranteed to be 4K aligned.
1. If the input data format is NV12, the physical start address of the image data for Y and UV needs to be guaranteed to be 4K aligned.

The 2D operation has the following constraints:

1. The physical start address of the source image and destination image in DDR must be guaranteed to be 8-byte aligned.
1. The sizes of image, OSD, and frame are supported to be even numbers.
1. In overlay and frame-drawing operations, the src and dst addresses of the video data must be the same.

The decoding operation has the following constraint: the physical start address of the input data for each frame needs to be 4K aligned.

##### Typical Encoding Application Example

![venc sample flow](https://download.kendryte.com/developer/pictures/e57bfe4e5657980663f22e7cdef1f182.jpeg)

#### Video Decoding Module

|          | H264                                                                    | HEVC                     | JPEG                      |
| :------- | :---------------------------------------------------------------------- | :----------------------- | :------------------------ |
| Input Format | H.264 Baseline;H.264 Main;H.264 High;H.264 High10;supports interlaced stream | HEVC (H.265) Main/Main10 | JPEG, baseline sequential |
| Output Format | YUV420 NV12                                                             | YUV420 NV12              | YUV422 UYVY, YUV420 NV12  |
| Decoding Channels | 4 channels                                                                     | 4 channels                      | 4 channels                       |

Note: H264/HEVC/JPEG share 4 channels.

VDEC supports streaming transmission:

- Streaming transmission (K_VDEC_SEND_MODE_STREAM): Users can send any length of bitstream to the decoder each time, and the decoder internally completes the process of identifying one frame of bitstream. It should be noted that for H.264/H.265, the end of the current frame's bitstream can only be identified after receiving the next frame's bitstream. Therefore, in this transmission mode, inputting one frame of H.264/H.265 bitstream cannot be expected to start decoding the image immediately.

##### Typical Decoding Application Example

![vdec sample flow](https://download.kendryte.com/developer/pictures/e49f8a05613f3b2524e3dc075009146e.jpeg)

## API Reference

### Video Encoding

This function module provides the following APIs:

- [kd_mpi_venc_request_chn](#kd_mpi_venc_request_chn): Request an encoding channel.
- [kd_mpi_venc_release_chn](#kd_mpi_venc_release_chn): Release an encoding channel.
- [kd_mpi_venc_attach_vb_pool](#kd_mpi_venc_attach_vb_pool): Bind a VB pool to the encoding channel.
- [kd_mpi_venc_detach_vb_pool](#kd_mpi_venc_detach_vb_pool): Unbind the VB pool from the encoding channel.
- [kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn): Create an encoding channel.
- [kd_mpi_venc_destroy_chn](#kd_mpi_venc_destroy_chn): Destroy an encoding channel.
- [kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn): Start the encoding channel to receive input images.
- [kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn): Stop the encoding channel from receiving input images.
- [kd_mpi_venc_query_status](#kd_mpi_venc_query_status): Query the encoding channel status.
- [kd_mpi_venc_get_stream](#kd_mpi_venc_get_stream): Get the encoded stream.
- [kd_mpi_venc_release_stream](#kd_mpi_venc_release_stream): Release the stream buffer.
- [kd_mpi_venc_send_frame](#kd_mpi_venc_send_frame): Support user to send raw images for encoding.
- [kd_mpi_venc_set_rotation](#kd_mpi_venc_set_rotation): Set the rotation angle of the encoded image.
- [kd_mpi_venc_get_rotation](#kd_mpi_venc_get_rotation): Get the rotation angle of the encoded image.
- [kd_mpi_venc_set_mirror](#kd_mpi_venc_set_mirror): Set the rotation angle of the encoded image.
- [kd_mpi_venc_get_mirror](#kd_mpi_venc_get_mirror): Get the mirror mode of the encoded image.
- [kd_mpi_venc_enable_idr](#kd_mpi_venc_enable_idr): Enable IDR frame, generate IDR frames according to GOP interval.
- [kd_mpi_venc_set_2d_mode](#kd_mpi_venc_set_2d_mode): Set the 2D operation mode.
- [kd_mpi_venc_get_2d_mode](#kd_mpi_venc_get_2d_mode): Get the 2D operation mode.
- [kd_mpi_venc_set_2d_osd_param](#kd_mpi_venc_set_2d_osd_param): Set the OSD region attributes in 2D operation.
- [kd_mpi_venc_get_2d_osd_param](#kd_mpi_venc_get_2d_osd_param): Get the OSD region attributes of the specified index in 2D operation.
- [kd_mpi_venc_set_2d_border_param](#kd_mpi_venc_set_2d_border_param): Set the border attributes in 2D operation.
- [kd_mpi_venc_get_2d_border_param](#kd_mpi_venc_get_2d_border_param): Get the border attributes in 2D operation.
- [kd_mpi_venc_set_2d_custom_coef](#kd_mpi_venc_set_2d_custom_coef): Set the image format conversion coefficients in 2D operation.
- [kd_mpi_venc_get_2d_custom_coef](#kd_mpi_venc_get_2d_custom_coef): Get the image format conversion coefficients in 2D operation.
- [kd_mpi_venc_set_2d_color_gamut](#kd_mpi_venc_set_2d_color_gamut): Set the color gamut of 2D operation.
- [kd_mpi_venc_get_2d_color_gamut](#kd_mpi_venc_get_2d_color_gamut): Get the color gamut of 2D operation.
- [kd_mpi_venc_attach_2d](#kd_mpi_venc_attach_2d): Associate 2D operation with venc.
- [kd_mpi_venc_detach_2d](#kd_mpi_venc_detach_2d): Detach 2D operation from venc.
- [kd_mpi_venc_send_2d_frame](#kd_mpi_venc_send_2d_frame): Send a frame of data to the 2D module.
- [kd_mpi_venc_get_2d_frame](#kd_mpi_venc_get_2d_frame): Get the 2D operation result.
- [kd_mpi_venc_start_2d_chn](#kd_mpi_venc_start_2d_chn): Start the 2D channel to receive input images.
- [kd_mpi_venc_stop_2d_chn](#kd_mpi_venc_stop_2d_chn): Stop the 2D channel from receiving input images.
- [kd_mpi_venc_request_idr](#kd_mpi_venc_request_idr): Request an IDR frame, generate an IDR frame immediately after the call.
- [kd_mpi_venc_set_h265_sao](#kd_mpi_venc_set_h265_sao): Set the Sao attributes of the H.265 channel.
- [kd_mpi_venc_get_h265_sao](#kd_mpi_venc_get_h265_sao): Get the Sao attributes of the H.265 channel.
- [kd_mpi_venc_set_dblk](#kd_mpi_venc_set_dblk): Set the Deblocking enable of the protocol encoding channel.
- [kd_mpi_venc_get_dblk](#kd_mpi_venc_get_dblk): Get the Deblocking status of the protocol encoding channel.
- [kd_mpi_venc_set_intbuf_size](#kd_mpi_venc_set_intbuf_size): Set the VENC internal buffer size.
- [kd_mpi_venc_get_2d_csc_param](#kd_mpi_venc_get_2d_csc_param): Get 2D CSC parameters.
- [kd_mpi_venc_set_h264_entropy](#kd_mpi_venc_set_h264_entropy): Set the entropy coding mode of the H.264 protocol encoding channel.
- [kd_mpi_venc_get_h264_entropy](#kd_mpi_venc_get_h264_entropy): Get the entropy coding mode of the H.264 protocol encoding channel.
- [kd_mpi_venc_set_h265_entropy](#kd_mpi_venc_set_h265_entropy): Set the entropy coding mode of the H.265 protocol encoding channel.
- [kd_mpi_venc_get_h265_entropy](#kd_mpi_venc_get_h265_entropy): Get the entropy coding mode of the H.265 protocol encoding channel.

#### kd_mpi_venc_request_chn

【Description】

Request an encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_request_chn(k_u32* chn_num);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Output the requested encoding channel number, value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_release_chn

【Description】

Release an encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_release_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- Must stop receiving images and destroy channel-related resources before release, otherwise it returns failure.

【Example】

None.

【Related Topics】

[kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn)
[kd_mpi_venc_destroy_chn](#kd_mpi_venc_destroy_chn)

#### kd_mpi_venc_attach_vb_pool

【Description】

Bind a VB pool to the encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_attach_vb_pool(k_u32 chn_num, k_u32 pool_id)
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| pool_id  | VB pool ID.                                                                 | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Example】

None.

【Related Topics】

[kd_mpi_venc_detach_vb_pool](#kd_mpi_venc_detach_vb_pool)

#### kd_mpi_venc_detach_vb_pool

【Description】

Unbind the VB pool from the encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_detach_vb_pool(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Example】

None.

【Related Topics】

[kd_mpi_venc_attach_vb_pool](#kd_mpi_venc_attach_vb_pool)

#### kd_mpi_venc_create_chn

【Description】

Create an encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_create_chn(k_u32 chn_num, const [k_venc_chn_attr](#k_venc_chn_attr) *attr);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| attr     | Pointer to the encoding channel attributes.                                                         | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_destroy_chn

【Description】

Destroy an encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_destroy_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- Must stop receiving images before destruction, otherwise it returns failure.

【Example】

None.

【Related Topics】

[kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn)

#### kd_mpi_venc_start_chn

【Description】

Start the encoding channel to receive input images.

【Syntax】

```c
k_s32 kd_mpi_venc_start_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- If the channel is not created, it returns failure K_ERR_VENC_UNEXIST.
- If the channel has already started receiving images, calling this interface again to specify the number of received frames before stopping returns operation not allowed.
- The encoder only starts receiving and encoding images after receiving is enabled.

【Example】

None.

【Related Topics】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)
[kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn)

#### kd_mpi_venc_stop_chn

【Description】

Stop the encoding channel from receiving input images.

【Syntax】

```c
k_s32 kd_mpi_venc_stop_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- If the channel is not created, it returns failure.
- This interface does not check whether receiving is currently stopped, that is, repeated stop receiving is allowed without returning an error.
- This interface is used to stop the encoding channel from receiving images for encoding. The encoding channel must stop receiving images before being destroyed or reset.
- Calling this interface only stops receiving raw data for encoding, the stream buffer will not be cleared.

【Example】

None.

【Related Topics】

[kd_mpi_venc_destroy_chn](#kd_mpi_venc_destroy_chn)

#### kd_mpi_venc_query_status

【Description】

Query the encoding channel status.

【Syntax】

```c
k_s32 kd_mpi_venc_query_status(k_u32 chn_num, [k_venc_chn_status](#k_venc_chn_attr) *status);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| status   | Pointer to the encoding channel status.                                                     | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- If the channel is not created, it returns failure.

【Example】

None.

【Related Topics】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)

#### kd_mpi_venc_get_stream

【Description】

Get the encoded stream.

【Syntax】

```c
k_s32 kd_mpi_venc_get_stream(k_u32 chn_num, [k_venc_stream](#k_venc_stream) *stream, k_s32 milli_sec);
```

【Parameters】

| Parameter  | Description                                                                            | Input/Output |
| --------- | ------------------------------------------------------------------------------- | --------- |
| chn_num   | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).        | Input      |
| stream    | Pointer to the stream structure.                                                                 | Output      |
| milli_sec | Timeout for getting the stream. Value range: [-1, +∞ ) -1: Blocking. 0: Non-blocking. Greater than 0: Timeout. | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- If the channel is not created, it returns failure.
- If stream is NULL, it returns K_ERR_VENC_NULL_PTR.
- If milli_sec is less than -1, it returns K_ERR_VENC_ILLEGAL_PARAM.

【Example】

None.

【Related Topics】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)
[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

#### kd_mpi_venc_release_stream

【Description】

Release the stream buffer.

【Syntax】

```c
k_s32 kd_mpi_venc_release_stream(k_u32 chn_num, [k_venc_stream](#k_venc_stream) *stream);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| stream   | Pointer to the stream structure.                                                         | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- If the channel is not created, it returns error code K_ERR_VENC_UNEXIST.
- If stream is NULL, it returns error code K_ERR_VENC_NULL_PTR.

【Example】

None.

【Related Topics】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)
[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

#### kd_mpi_venc_send_frame

【Description】

Support user to send raw images for encoding.

【Syntax】

```c
k_s32 kd_mpi_venc_send_frame(k_u32 chn_num, k_video_frame_info *frame, k_s32 milli_sec);
```

【Parameters】

| Parameter  | Description                                                                           | Input/Output |
| --------- | ------------------------------------------------------------------------------ | --------- |
| chn_num   | Encoding channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).       | Input      |
| frame     | Pointer to the raw image information structure, refer to 《K230 System Control API Reference》。                          | Input      |
| milli_sec | Timeout for sending images. Value range: [-1,+∞ ) -1: Blocking. 0: Non-blocking.\> 0: Timeout. | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface supports user to send images to the encoding channel.
- If milli_sec is less than -1, it returns K_ERR_VENC_ILLEGAL_PARAM.
- When calling this interface to send images, the user needs to ensure that the encoding channel has been created and has started receiving input images.

【Example】

None.

【Related Topics】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)
[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

#### kd_mpi_venc_set_rotation

【Description】

Set the rotation angle of the encoded image.

【Syntax】

```c
k_s32 kd_mpi_venc_set_rotation(k_u32 chn_num, const [k_rotation](#k_rotation) rotation);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| rotation | Rotation angle enumeration.                                                       | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_rotation

【Description】

Get the rotation angle of the encoded image.

【Syntax】

```c
k_s32 kd_mpi_venc_get_rotation(k_u32 chn_num, [k_rotation](#k_rotation) *rotation);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| rotation | Pointer to the rotation angle enumeration.                                                   | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_mirror

【Description】

Set the mirror mode of the encoded image.

【Syntax】

```c
k_s32 kd_mpi_venc_set_mirror(k_u32 chn_num, const [k_venc_mirror](#k_venc_mirror) mirror);
```

【Parameters】

| Parameter | Description                                                                | Input/Output |
| -------- | ------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| mirror   | Mirror mode enumeration.                                                      | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.
【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.
【Example】

None.
【Related Topics】

None.

#### kd_mpi_venc_get_mirror

【Description】

Set the mirror mode of the encoded image.
【Syntax】

```c
k_s32 kd_mpi_venc_get_mirror(k_u32 chn_num, [k_venc_mirror](#k_venc_mirror) mirror);
```

【Parameters】

| Parameter | Description                                                                | Input/Output |
| -------- | ------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| mirror   | Mirror mode enumeration.                                                      | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.
【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.
【Example】

None.
【Related Topics】

None.

#### kd_mpi_venc_enable_idr

【Description】

Set the IDR frame enable.

【Syntax】

```c
k_s32 kd_mpi_venc_enable_idr(k_u32 chn_num, k_bool idr_enable);
```

【Parameters】

| Parameter   | Description                                                                 | Input/Output |
| ---------- | -------------------------------------------------------------------- | --------- |
| chn_num    | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| idr_enable | Whether to enable IDR frame. 0: Disable. 1: Enable.                                  | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface needs to be called after creating the encoding channel and before starting the encoding channel.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_2d_mode

【Description】

Set the 2D operation mode.

【Syntax】

```c
k_s32 kd_mpi_venc_set_2d_mode(k_u32 chn_num, [k_venc_2d_calc_mode](#k_venc_2d_calc_mode) mode);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| mode     | 2D operation mode enumeration.                                                     | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- The current operation mode does not support K_VENC_2D_CALC_MODE_CSC mode.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_2d_mode

【Description】

Get the 2D operation mode.

【Syntax】

```c
k_s32 kd_mpi_venc_get_2d_mode(k_u32 chn_num, [k_venc_2d_calc_mode](#k_venc_2d_calc_mode) *mode);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| mode     | Pointer to the 2D operation mode enumeration.                                                 | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- The current operation mode does not support K_VENC_2D_CALC_MODE_CSC mode.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_2d_osd_param

【Description】

Set the OSD region attributes in 2D operation.

【Syntax】

```c
k_s32 kd_mpi_venc_set_2d_osd_param(k_u32 chn_num, k_u8 index, const [k_venc_2d_osd_attr](#k_venc_2d_osd_attr) *attr);
```

【Parameters】

| Parameter | Description                                                                                            | Input/Output |
| -------- | ----------------------------------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).                            | Input      |
| index    | OSD region index. Value range: [0,[K_VENC_MAX_2D_OSD_REGION_NUM](#k_venc_max_2d_osd_region_num)). | Input      |
| attr     | Pointer to the OSD attributes.                                                                                   | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- If there are n overlay regions, the index values should be set to 0\~n-1.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_2d_osd_param

【Description】

Get the OSD region attributes of the specified index in 2D operation.

【Syntax】

```c
k_s32 kd_mpi_venc_get_2d_osd_param(k_u32 chn_num, k_u8 index, [k_venc_2d_osd_attr](#k_venc_2d_osd_attr) *attr);
```

【Parameters】

| Parameter | Description                                                                                            | Input/Output |
| -------- | ----------------------------------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).                            | Input      |
| index    | OSD region index. Value range: [0,[K_VENC_MAX_2D_OSD_REGION_NUM](#k_venc_max_2d_osd_region_num)). | Input      |
| attr     | Pointer to the OSD attributes.                                                                                   | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_2d_border_param

【Description】

Set the border attributes in 2D operation.

【Syntax】

```c
k_s32 kd_mpi_venc_set_2d_border_param(k_u32 chn_num, k_u8 index, const [k_venc_2d_border_attr](#k_venc_2d_border_attr) *attr);
```

【Parameters】

| Parameter | Description                                                                                 | Input/Output |
| -------- | ------------------------------------------------------------------------------------ | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).                 | Input      |
| index    | Border index. Value range: [0,[K_VENC_MAX_2D_BORDER_NUM](#k_venc_max_2d_border_num)). | Input      |
| attr     | Pointer to the border attributes.                                                                       | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- If there are n borders, the index values should be set to 0\~n-1.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_2d_border_param

【Description】

Get the border attributes in 2D operation.

【Syntax】

```c
k_s32 kd_mpi_venc_get_2d_border_param(k_u32 chn_num, k_u8 index, [k_venc_2d_border_attr](#k_venc_2d_border_attr) *attr);
```

【Parameters】

| Parameter | Description                                                                                 | Input/Output |
| -------- | ------------------------------------------------------------------------------------ | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).                 | Input      |
| index    | Border index. Value range: [0,[K_VENC_MAX_2D_BORDER_NUM](#k_venc_max_2d_border_num)). | Input      |
| attr     | Pointer to the border attributes.                                                                       | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_2d_custom_coef

【Description】

Set the image format conversion coefficients in 2D operation.

【Syntax】

```c
k_s32 kd_mpi_venc_set_2d_custom_coef(k_u32 chn_num, const k_s16 *coef);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| coef     | Pointer to the conversion coefficients. Refer to [Calculation of 2D Conversion Coefficients](#venc-2d-conversion-coefficients)        | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- The kernel has a set of default conversion coefficients. If you need to customize the conversion coefficients, you can configure them through this interface.
- This interface should be called after setting the operation mode.
- For the description of the conversion coefficients, see [Calculation of 2D Conversion Coefficients](#venc-2d-conversion-coefficients)
- When the operation mode is K_VENC_2D_CALC_MODE_BORDER, the conversion coefficients are not applicable, and calling this interface will report an error.

【Example】

None.

【Related Topics】

[kd_mpi_venc_set_2d_mode](#kd_mpi_venc_set_2d_mode)

#### kd_mpi_venc_get_2d_custom_coef

【Description】

Get the image format conversion coefficients in 2D operation.

【Syntax】

```c
k_s32 kd_mpi_venc_get_2d_custom_coef(k_u32 chn_num, k_s16 *coef);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| coef     | Pointer to the conversion coefficients. Refer to [Calculation of 2D Conversion Coefficients](#venc-2d-conversion-coefficients)        | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface should be called after setting the operation mode.
- When the operation mode is K_VENC_2D_CALC_MODE_BORDER, the conversion coefficients are not applicable, and calling this interface will report an error.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_2d_color_gamut

【Description】

Set the color gamut of 2D operation.

【Syntax】

```c
k_s32 kd_mpi_venc_set_2d_color_gamut(k_u32 chn_num, const [k_venc_2d_color_gamut](#k_venc_2d_color_gamut) color_gamut);
```

【Parameters】

| Parameter    | Description                                                                 | Input/Output |
| ----------- | -------------------------------------------------------------------- | --------- |
| chn_num     | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| color_gamut | Color gamut enumeration.                                                           | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- The kernel has a set of default conversion coefficients. If you need to customize the conversion coefficients, you can configure them through this interface.
- This interface should be called after setting the operation mode.
- When the operation mode is K_VENC_2D_CALC_MODE_BORDER, the color gamut is not applicable, and calling this interface will report an error.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_2d_color_gamut

【Description】

Get the color gamut of 2D operation.

【Syntax】

```c
k_s32 kd_mpi_venc_get_2d_color_gamut(k_u32 chn_num, [k_venc_2d_color_gamut](#k_venc_2d_color_gamut) *color_gamut);
```

【Parameters】

| Parameter    | Description                                                                 | Input/Output |
| ----------- | -------------------------------------------------------------------- | --------- |
| chn_num     | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| color_gamut | Pointer to the color gamut enumeration.                                                       | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- The kernel has a set of default conversion coefficients. If you need to customize the conversion coefficients, you can configure them through this interface.
- This interface should be called after setting the operation mode.
- When the operation mode is K_VENC_2D_CALC_MODE_BORDER, the color gamut is not applicable, and calling this interface will report an error.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_attach_2d

【Description】

Associate 2D operation with venc.

【Syntax】

```c
k_s32 kd_mpi_venc_attach_2d(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- Currently, the binding only supports the mode where the encoding channel number and the 2D operation channel number are the same. Only the first 3 encoding channels support the attach 2D operation.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_detach_2d

【Description】

Detach 2D operation from venc.

【Syntax】

```c
k_s32 kd_mpi_venc_detach_2d(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 2D operation channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- When calling this interface, the user needs to ensure that the encoding channel has been stopped.

【Example】

None.

【Related Topics】

[kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn)

#### kd_mpi_venc_send_2d_frame

【Description】

Send a frame of data to the 2D module.

【Syntax】

```c
k_s32 kd_mpi_venc_send_2d_frame(k_u32 chn_num, k_video_frame_info *frame);
```

【Parameters】

| Parameter | Description                                                                    | Input/Output |
| -------- | ----------------------------------------------------------------------- | --------- |
| chn_num  | 2D operation channel number, value range [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| frame    | Pointer to the raw image information structure, refer to 《K230 System Control API Reference》。                   | Input      |

【Return Value】

| Return Value | Description                          |
| ------ | ----------------------------- |
| 0      | Success.                        |
| Non-0    | Failure, returns [Error Code](#error-code) |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface is only used in the single 2D operation scenario. In the scenario of encoding after 2D operation, the interface for sending images to venc [kd_mpi_venc_send_frame](#kd_mpi_venc_send_frame) needs to be used.

【Example】

None.

【Related Topics】

[kd_mpi_venc_send_frame](#kd_mpi_venc_send_frame)

#### kd_mpi_venc_get_2d_frame

【Description】

Get the 2D operation result.

【Syntax】

```c
k_s32 kd_mpi_venc_get_2d_frame(k_u32 chn_num, k_video_frame_info *frame);
```

【Parameters】

| Parameter | Description                                                                    | Input/Output |
| -------- | ----------------------------------------------------------------------- | --------- |
| chn_num  | 2D operation channel number, value range [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| frame    | Pointer to the output image information structure, refer to 《K230 System Control API Reference》。                   | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface is only used in the single 2D operation scenario. In the scenario of encoding after 2D operation, to get the encoded stream, [kd_mpi_venc_get_stream](#kd_mpi_venc_get_stream) needs to be used.

【Example】

None.

【Related Topics】

[kd_mpi_venc_get_stream](#kd_mpi_venc_get_stream)

#### kd_mpi_venc_start_2d_chn

【Description】

Start the 2D channel to receive input images.

【Syntax】

```c
k_s32 kd_mpi_venc_start_2d_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                    | Input/Output |
| -------- | ----------------------------------------------------------------------- | --------- |
| chn_num  | 2D operation channel number, value range [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h

【Note】

- This interface is only used in the single 2D operation scenario. In the VENC+2D scenario, [kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn) needs to be called.

【Example】

None.

【Related Topics】

[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

#### kd_mpi_venc_stop_2d_chn

【Description】

Stop the 2D channel from receiving input images.

【Syntax】

```c
k_s32 kd_mpi_venc_stop_2d_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                    | Input/Output |
| -------- | ----------------------------------------------------------------------- | --------- |
| chn_num  | 2D operation channel number, value range [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_request_idr

【Description】

Request an IDR frame, generate an IDR frame immediately after the call.

【Syntax】

```c
k_s32 kd_mpi_venc_request_idr(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_h265_sao

【Description】

Set the Sao attributes of the H.265 channel.

【Syntax】

```c
k_s32 kd_mpi_venc_set_h265_sao(k_u32 chn_num, const [k_venc_h265_sao](#k_venc_h265_sao) *h265_sao);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| h265_sao | Sao configuration of the H.265 protocol encoding channel.                                         | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface needs to be called after creating the encoding channel and before starting the encoding channel.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_h265_sao

【Description】

Get the Sao attributes of the H.265 channel.

【Syntax】

```c
k_s32 kd_mpi_venc_get_h265_sao(k_u32 chn_num, [k_venc_h265_sao](#k_venc_h265_sao) *h265_sao);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| h265_sao | Sao configuration of the H.265 protocol encoding channel.                                         | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_dblk

【Description】

Set the Deblocking enable of the H.264/H.265 protocol encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_set_dblk(k_u32 chn_num, const k_bool dblk_en);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| dblk_en  | Whether to enable deblocking. K_TRUE: Enable. K_FALSE: Disable. Enabled by default.        | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface needs to be called after creating the encoding channel and before starting the encoding channel.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_dblk

【Description】

Get the Deblocking status of the H.264/H.265 protocol encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_get_dblk(k_u32 chn_num, k_bool *dblk_en);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| dblk_en  | Whether to enable deblocking. K_TRUE: Enable. K_FALSE: Disable. Enabled by default.        | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_intbuf_size

【Description】

Set the VENC buffer size.

【Syntax】

```c
k_s32 kd_mpi_venc_set_intbuf_size(k_u32 chn_num, k_u32 size)
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| size     | buffer size.                                                        | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface needs to be called before creating the encoding channel.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_2d_csc_param

【Description】

Get the 2D CSC attributes of the VENC channel.

【Syntax】

```c
k_s32 kd_mpi_venc_get_2d_csc_param(k_u32 chn_num, k_venc_2d_csc_attr *attr);
```

【Parameters】

| Parameter | Description                                                                 | Input/Output |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| attr     | 2D CSC parameters.                                                         | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_h264_entropy

【Description】

Set the entropy coding mode of the H.264 protocol encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_set_h264_entropy(k_u32 chn_num, const [k_venc_h264_entropy](#k_venc_h264_entropy) *h264_entropy);
```

【Parameters】

| Parameter     | Description                                                                 | Input/Output |
| ------------ | -------------------------------------------------------------------- | --------- |
| chn_num      | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| h264_entropy | Entropy coding mode of the H.264 protocol encoding channel.                                      | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface needs to be called after creating the encoding channel and before starting the encoding channel.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_h264_entropy

【Description】

Get the entropy coding mode of the H.264 protocol encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_get_h264_entropy(k_u32 chn_num, [k_venc_h264_entropy](#k_venc_h264_entropy) *h264_entropy);
```

【Parameters】

| Parameter     | Description                                                                 | Input/Output |
| ------------ | -------------------------------------------------------------------- | --------- |
| chn_num      | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| h264_entropy | Entropy coding mode of the H.264 protocol encoding channel.                                      | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_set_h265_entropy

【Description】

Set the entropy coding mode of the H.265 protocol encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_set_h265_entropy(k_u32 chn_num, const [k_venc_h265_entropy](#k_venc_h265_entropy) *h265_entropy);
```

【Parameters】

| Parameter     | Description                                                                 | Input/Output |
| ------------ | -------------------------------------------------------------------- | --------- |
| chn_num      | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| h265_entropy | Entropy coding mode of the H.265 protocol encoding channel.                                      | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

- This interface needs to be called after creating the encoding channel and before starting the encoding channel.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_venc_get_h265_entropy

【Description】

Get the entropy coding mode of the H.265 protocol encoding channel.

【Syntax】

```c
k_s32 kd_mpi_venc_get_h265_entropy(k_u32 chn_num, [k_venc_h265_entropy](#k_venc_h265_entropy) *h265_entropy);
```

【Parameters】

| Parameter     | Description                                                                 | Input/Output |
| ------------ | -------------------------------------------------------------------- | --------- |
| chn_num      | Channel number. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| h265_entropy | Entropy coding mode of the H.265 protocol encoding channel.                                      | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0    | Failure, returns [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_venc_api.h, k_type.h, k_module.h, k_sys_comm.h, k_venc_comm.h
- Library file: libvenc.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

### Video Decoding

This function module provides the following APIs:

- [kd_mpi_vdec_request_chn](#kd_mpi_vdec_request_chn)：Apply for a decoding channel.
- [kd_mpi_vdec_release_chn](#kd_mpi_vdec_release_chn)：Release a decoding channel.
- [kd_mpi_vdec_attach_vb_pool](#kd_mpi_vdec_attach_vb_pool)：Bind a VB pool to a decoding channel.
- [kd_mpi_vdec_detach_vb_pool](#kd_mpi_vdec_detach_vb_pool)：Unbind the VB pool of a decoding channel.
- [kd_mpi_vdec_create_chn](#kd_mpi_vdec_create_chn)：Create a video decoding channel.
- [kd_mpi_vdec_destroy_chn](#kd_mpi_vdec_destroy_chn)：Destroy a video decoding channel.
- [kd_mpi_vdec_start_chn](#kd_mpi_vdec_start_chn)：Start a video decoding channel.
- [kd_mpi_vdec_stop_chn](#kd_mpi_vdec_stop_chn)：Stop a video decoding channel.
- [kd_mpi_vdec_query_status](#kd_mpi_vdec_query_status)：The decoder stops receiving bitstreams sent by the user.
- [kd_mpi_vdec_send_stream](#kd_mpi_vdec_send_stream)：Send bitstream data to a video decoding channel.
- [kd_mpi_vdec_get_frame](#kd_mpi_vdec_get_frame)：Get the decoded image of a video decoding channel.
- [kd_mpi_vdec_release_frame](#kd_mpi_vdec_release_frame)：Get the decoded image of a video decoding channel.
- [kd_mpi_vdec_set_downscale](#kd_mpi_vdec_set_downscale)：Set the downscaled image output by decoding (specify length and width or by ratio).
- [kd_mpi_vdec_set_rotation](#kd_mpi_vdec_set_rotation)：Set the decoding rotation angle.
- [kd_mpi_vdec_close_fd](#kd_mpi_vdec_close_fd)：Close the VDEC device.

#### kd_mpi_vdec_request_chn

【Description】

Apply for a decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_request_chn(k_u32* chn_num);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Output the applied decoding channel number, value range: [0,VDEC_MAX_CHN_NUMS] | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_release_chn

【Description】

Release a decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_release_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Decoding channel number. Value range: [0,VDEC_MAX_CHN_NUMS] | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

- The decoding channel related operations must be stopped before release, otherwise it will return failure.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_attach_vb_pool

【Description】

Bind a VB pool to a decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_attach_vb_pool(k_u32 chn_num, k_u32 pool_id);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Decoding channel number. Value range: [0,VDEC_MAX_CHN_NUMS] | Input      |
| pool_id  | VB pool ID.                                                                 | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Example】

None.

【Related Topics】

[kd_mpi_vdec_detach_vb_pool](#kd_mpi_vdec_detach_vb_pool)

#### kd_mpi_vdec_detach_vb_pool

【Description】

Unbind the VB pool of a decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_detach_vb_pool(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                     | Input/Output |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | Decoding channel number. Value range: [0,VDEC_MAX_CHN_NUMS] | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Example】

None.

【Related Topics】

[kd_mpi_vdec_attach_vb_pool](#kd_mpi_vdec_attach_vb_pool)

#### kd_mpi_vdec_create_chn

【Description】

Create a video decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_create_chn(k_u32 chn_num, [k_vdec_chn_attr](#k_vdec_chn_attr) *attr);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| attr     | Decoding channel attribute pointer.                                                         | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_destroy_chn

【Description】

Destroy a video decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_destroy_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_start_chn

【Description】

Start a video decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_start_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_stop_chn

【Description】

Stop a video decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_stop_chn(k_u32 chn_num);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_query_status

【Description】

Query the decoding channel status.

【Syntax】

```c
k_s32 kd_mpi_vdec_query_status(k_u32 chn_num, [k_vdec_chn_status](#k_vdec_chn_status) *status);
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| status   | Video decoding channel status structure pointer.                                               | Output      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_send_stream

【Description】

Send bitstream data to a video decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_send_stream(k_u32 chn_num, [k_vdec_stream](#k_vdec_stream) *stream, k_s32 milli_sec);
```

【Parameters】

| Parameter  | Description                                                                                         | Input/Output |
| --------- | -------------------------------------------------------------------------------------------- | --------- |
| chn_num   | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).                   | Input      |
| stream    | Decoding bitstream data pointer.                                                                           | Input      |
| milli_sec | Bitstream sending method flag. Value range:  -1: blocking. 0: non-blocking. Positive value: timeout, no upper limit, in ms. | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_get_frame

【Description】

Get the decoded image of a video decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_get_frame(k_u32 chn_num, k_video_frame_info *frame_info, [k_vdec_supplement_info](#k_vdec_supplement_info) *supplement, k_s32 milli_sec);
```

【Parameters】

| Parameter   | Description                                                                                                  | Input/Output |
| ---------- | ----------------------------------------------------------------------------------------------------- | --------- |
| chn        | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).                            | Input      |
| frame_info | Obtained decoded image information, refer to 《K230 System Control API Reference》.                                                   | Output      |
| supplement | Obtained decoded image supplement information.                                                                              | Output      |
| milli_sec  | Bitstream sending method flag. Value range:  -1: blocking. 0: non-blocking. Positive value: timeout, no upper limit, in ms. Dynamic attribute. | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_release_frame

【Description】

Get the decoded image of a video decoding channel.

【Syntax】

```c
k_s32 kd_mpi_vdec_release_frame(k_u32 chn_num, k_video_frame_info *frame_info);
```

【Parameters】

| Parameter   | Description                                                                                                                 | Input/Output |
| ---------- | -------------------------------------------------------------------------------------------------------------------- | --------- |
| chn        | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)).                                           | Input      |
| frame_info | Decoded image information pointer, obtained by the [kd_mpi_vdec_get_frame](#kd_mpi_vdec_get_frame) interface, refer to 《K230 System Control API Reference》. | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

None.

【Example】

None.

【Related Topics】

[kd_mpi_vdec_get_frame](#kd_mpi_vdec_get_frame)

#### kd_mpi_vdec_set_downscale

【Description】

Set the downscaled image output by decoding (specify length and width or by ratio).

【Syntax】

```c
k_s32 kd_mpi_vdec_set_downscale(k_u32 chn_num, const  [k_vdec_downscale](#k_vdec_downscale)  *downscale)
```

【Parameters】

| Parameter  | Description                                                                       | Input/Output |
| --------- | -------------------------------------------------------------------------- | --------- |
| chn_num   | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| downscale | Downscale size parameter structure pointer.                                                   | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

Set it between kd_mpi_vdec_create_chn and kd_mpi_vdec_start_chn.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_set_rotation

【Description】

Set the decoding rotation angle.

【Syntax】

```c
k_s32 kd_mpi_vdec_set_rotation(k_u32 chn_num, [k_rotation](#k_rotation) rotation)
```

【Parameters】

| Parameter | Description                                                                       | Input/Output |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | Encoding channel information. Value range: [0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums)). | Input      |
| rotation | Rotation angle enumeration.                                                             | Input      |

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

Set it between kd_mpi_vdec_create_chn and kd_mpi_vdec_start_chn.

【Example】

None.

【Related Topics】

None.

#### kd_mpi_vdec_close_fd

【Description】

Close the VDEC device.

【Syntax】

```c
k_s32 kd_mpi_vdec_close_fd()
```

【Parameters】
None

【Return Value】

| Return Value | Description                            |
| ------ | ------------------------------- |
| 0      | Success.                          |
| Non-0  | Failure, see [Error Code](#error-code). |

【Chip Differences】

None.

【Requirements】

- Header files: mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- Library file: libvdec.a

【Note】

Call this function after kd_mpi_vdec_destroy_chn all chn.

【Example】

None.

【Related Topics】

None.

## Data Types

### Video Encoding Module

The related data type definitions for this functional module are as follows:

- [VENC_MAX_CHN_NUMS](#venc_max_chn_nums)：Defines the maximum number of channels.
- [K_VENC_MAX_2D_OSD_REGION_NUM](#k_venc_max_2d_osd_region_num)：Defines the maximum number of Regions for 2D operation OSD overlay.
- [K_VENC_MAX_2D_BORDER_NUM](#k_venc_max_2d_border_num)：Defines the maximum number of frames for 2D operation border drawing.
- [K_VENC_2D_COEF_NUM](#k_venc_2d_coef_num)：Defines the number of 2D operation CSC conversion coefficients.
- [K_VENC_2D_MAX_CHN_NUM](#k_venc_2d_max_chn_num)：Defines the number of 2D operation channels.
- [k_venc_rc_mode](#k_venc_rc_mode)：Defines the encoding channel bitrate controller mode.
- [k_venc_pack_type](#k_venc_pack_type)：Defines the JPEG stream PACK type enumeration.
- [k_venc_2d_calc_mode](#k_venc_2d_calc_mode)：Defines the calculation mode enumeration for 2D operations.
- [k_venc_2d_src_dst_fmt](#k_venc_2d_src_dst_fmt)：Defines the input/output data format enumeration for 2D operations.
- [k_venc_2d_osd_fmt](#k_venc_2d_osd_fmt)：Defines the OSD layer data format enumeration for 2D operations.
- [k_venc_2d_add_order](#k_venc_2d_add_order)：Defines the OSD overlay enumeration for 2D operations.
- [k_rotation](#k_rotation)：Defines the encoding rotation angle enumeration.
- [k_venc_mirror](#k_venc_mirror)：Defines the encoding flip mode enumeration.
- [k_venc_2d_color_gamut](#k_venc_2d_color_gamut)：Defines the color gamut enumeration for 2D operations.
- [k_venc_chn_attr](#k_venc_chn_attr)：Defines the encoding channel attribute structure.
- [k_venc_attr](#k_venc_attr)：Defines the encoder attribute structure.
- [k_venc_rc_attr](#k_venc_rc_attr)：Defines the encoding channel bitrate controller attribute structure.
- [k_venc_cbr](#k_venc_cbr)：Defines the H.264/H.265 encoding channel CBR attribute structure.
- [k_venc_vbr](#k_venc_vbr)：Defines the H.264/H.265 encoding channel VBR attribute structure.
- [k_venc_fixqp](#k_venc_fixqp)：Defines the H.264/H.265 encoding channel Fixqp attribute structure.
- [k_venc_mjpeg_fixqp](#k_venc_mjpeg_fixqp)：Defines the MJPEG encoding channel Fixqp attribute structure.
- [k_venc_chn_status](#k_venc_chn_status)：Defines the encoding channel status structure.
- [k_venc_stream](#k_venc_stream)：Defines the frame stream type structure.
- [k_venc_pack](#k_venc_pack)：Defines the frame stream packet structure.
- [k_venc_2d_osd_attr](#k_venc_2d_osd_attr)：2D overlay attribute structure.
- [k_venc_2d_border_attr](#k_venc_2d_border_attr)：2D border drawing structure.
- [k_venc_h265_sao](#k_venc_h265_sao)：Defines the Sao structure for H.265 protocol encoding channel.
- [k_venc_rect](#k_venc_rect)：Defines the rectangle region information structure.
- [k_venc_roi_attr](#k_venc_roi_attr)：Defines the encoding Region of Interest information.
- [k_venc_h264_entropy](#k_venc_h264_entropy)：Defines the entropy encoding structure for H.264 protocol encoding channel.
- [k_venc_h265_entropy](#k_venc_h265_entropy)：Defines the entropy encoding structure for H.265 protocol encoding channel.
- [k_venc_2d_csc_attr](#k_venc_2d_csc_attr)：Defines the 2D CSC parameter structure.

#### VENC_MAX_CHN_NUMS

【Description】

Defines the maximum number of channels.

【Definition】

```c
#define VENC_MAX_CHN_NUMS 4
```

【Notes】FV

None.

【Related Data Types and Interfaces】

None.

#### K_VENC_MAX_2D_OSD_REGION_NUM

【Description】

Defines the maximum number of Regions for 2D operation OSD overlay.

【Definition】

```c
#define K_VENC_MAX_2D_OSD_REGION_NUM 8
```

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### K_VENC_MAX_2D_BORDER_NUM

【Description】

Defines the maximum number of frames for 2D operation border drawing.

【Definition】

```c
#define K_VENC_MAX_2D_BORDER_NUM 32
```

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### K_VENC_2D_COEF_NUM

【Description】

Defines the number of 2D operation CSC conversion coefficients.

【Definition】

```c
#define K_VENC_2D_COEF_NUM 12
```

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### K_VENC_2D_MAX_CHN_NUM

【Description】

Defines the number of 2D operation channels.

【Definition】

\#define K_VENC_2D_MAX_CHN_NUM 3

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_rc_mode

【Description】

Defines the encoding channel bitrate controller mode.

【Definition】

typedef enum {
&emsp;K_VENC_RC_MODE_CBR = 1,
&emsp;K_VENC_RC_MODE_VBR,
&emsp;K_VENC_RC_MODE_FIXQP,
&emsp;K_VENC_RC_MODE_MJPEG_FIXQP,
&emsp;K_VENC_RC_MODE_BUTT,
} k_venc_rc_mode;

【Members】

| Member Name              | Description               |
| ------------------------ | ------------------------- |
| K_VENC_RC_MODE_CBR       | H.264/H.265 CBR mode.     |
| K_VENC_RC_MODE_VBR       | H.264/H.265 VBR mode.     |
| K_VENC_RC_MODE_FIXQP     | H.264/H.265 Fixqp mode.   |
| K_VENC_RC_MODE_MJPEG_FIXQP | MJPEG Fixqp mode.       |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_pack_type

【Description】

Defines the JPEG stream PACK type enumeration.

【Definition】

typedef enum {
&emsp;K_VENC_P_FRAME = 1,
&emsp;K_VENC_I_FRAME = 2,
&emsp;K_VENC_HEADER = 3,
&emsp;K_VENC_BUTT
} k_venc_pack_type;

【Members】

| Member Name   | Description  |
| ------------- | ------------ |
| K_VENC_P_FRAME | I frame.     |
| K_VENC_I_FRAME | P frame.     |
| K_VENC_HEADER  | Header.      |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_2d_calc_mode

【Description】

Defines the calculation mode enumeration for 2D operations.

【Definition】

typedef enum {
&emsp;K_VENC_2D_CALC_MODE_CSC = 0,
&emsp;K_VENC_2D_CALC_MODE_OSD,
&emsp;K_VENC_2D_CALC_MODE_BORDER,
&emsp;K_VENC_2D_CALC_MODE_OSD_BORDER,
&emsp;K_VENC_2D_CALC_MODE_BUTT
} k_venc_2d_calc_mode;

【Members】

| Member Name                  | Description                                 |
| ---------------------------- | ------------------------------------------- |
| K_VENC_2D_CALC_MODE_CSC      | Image format conversion.                    |
| K_VENC_2D_CALC_MODE_OSD      | Image overlay.                              |
| K_VENC_2D_CALC_MODE_BORDER   | Border drawing.                             |
| K_VENC_2D_CALC_MODE_OSD_BORDER | First perform image overlay, then draw borders. |

【Notes】

- Currently K_VENC_2D_CALC_MODE_CSC mode is not supported.

【Related Data Types and Interfaces】

None.

#### k_venc_2d_src_dst_fmt

【Description】

Defines the input/output data format enumeration for 2D operations.

【Definition】

typedef enum {
&emsp;K_VENC_2D_SRC_DST_FMT_YUV420_NV12= 0,
&emsp;K_VENC_2D_SRC_DST_FMT_YUV420_NV21,
&emsp;K_VENC_2D_SRC_DST_FMT_YUV420_I420,
&emsp;K_VENC_2D_SRC_DST_FMT_ARGB8888 = 4,
&emsp;K_VENC_2D_SRC_DST_FMT_ARGB4444,
&emsp;K_VENC_2D_SRC_DST_FMT_ARGB1555,
&emsp;K_VENC_2D_SRC_DST_FMT_XRGB8888,
&emsp;K_VENC_2D_SRC_DST_FMT_XRGB4444,
&emsp;K_VENC_2D_SRC_DST_FMT_XRGB1555,
&emsp;K_VENC_2D_SRC_DST_FMT_BGRA8888,
&emsp;K_VENC_2D_SRC_DST_FMT_BGRA4444,
&emsp;K_VENC_2D_SRC_DST_FMT_BGRA5551,
&emsp;K_VENC_2D_SRC_DST_FMT_BGRX8888,
&emsp;K_VENC_2D_SRC_DST_FMT_BGRX4444,
&emsp;K_VENC_2D_SRC_DST_FMT_BGRX5551,
&emsp;K_VENC_2D_SRC_DST_FMT_RGB888,
&emsp;K_VENC_2D_SRC_DST_FMT_BGR888,
&emsp;K_VENC_2D_SRC_DST_FMT_RGB565,
&emsp;K_VENC_2D_SRC_DST_FMT_BGR565,
&emsp;K_VENC_2D_SRC_DST_FMT_SEPERATE_RGB,
&emsp;K_VENC_2D_SRC_DST_FMT_BUTT
} k_venc_2d_src_dst_fmt;

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_2d_osd_fmt

【Description】

Defines the OSD layer data format enumeration for 2D operations.

【Definition】

typedef enum {
&emsp;K_VENC_2D_OSD_FMT_ARGB8888= 0,
&emsp;K_VENC_2D_OSD_FMT_ARGB4444,
&emsp;K_VENC_2D_OSD_FMT_ARGB1555,
&emsp;K_VENC_2D_OSD_FMT_XRGB8888,
&emsp;K_VENC_2D_OSD_FMT_XRGB4444,
&emsp;K_VENC_2D_OSD_FMT_XRGB1555,
&emsp;K_VENC_2D_OSD_FMT_BGRA8888,
&emsp;K_VENC_2D_OSD_FMT_BGRA4444,
&emsp;K_VENC_2D_OSD_FMT_BGRA5551,
&emsp;K_VENC_2D_OSD_FMT_BGRX8888,
&emsp;K_VENC_2D_OSD_FMT_BGRX4444,
&emsp;K_VENC_2D_OSD_FMT_BGRX5551,
&emsp;K_VENC_2D_OSD_FMT_RGB888,
&emsp;K_VENC_2D_OSD_FMT_BGR888,
&emsp;K_VENC_2D_OSD_FMT_RGB565,
&emsp;K_VENC_2D_OSD_FMT_BGR565,
&emsp;K_VENC_2D_OSD_FMT_SEPERATE_RGB,
&emsp;K_VENC_2D_OSD_FMT_BUTT
} k_venc_2d_osd_fmt;

【Notes】

- Currently the overlay image only supports ARGB8888, ARGB4444, and ARGB1555 formats.

【Related Data Types and Interfaces】

None.

#### k_venc_2d_add_order

【Description】

Defines the OSD overlay (video, OSD, and background layer) order enumeration for 2D operations.

【Definition】

```c
typedef enum {
/* bottom ------> top */
&emsp;K_VENC_2D_ADD_ORDER_VIDEO_OSD= 0,
&emsp;K_VENC_2D_ADD_ORDER_OSD_VIDEO,
&emsp;K_VENC_2D_ADD_ORDER_VIDEO_BG,
&emsp;K_VENC_2D_ADD_ORDER_BG_VIDEO,
&emsp;K_VENC_2D_ADD_ORDER_VIDEO_BG_OSD,
&emsp;K_VENC_2D_ADD_ORDER_VIDEO_OSD_BG,
&emsp;K_VENC_2D_ADD_ORDER_BG_VIDEO_OSD,
&emsp;K_VENC_2D_ADD_ORDER_BG_OSD_VIDEO,
&emsp;K_VENC_2D_ADD_ORDER_OSD_VIDEO_BG,
&emsp;K_VENC_2D_ADD_ORDER_OSD_BG_VIDEO,
&emsp;K_VENC_2D_ADD_ORDER_BUTT
} k_venc_2d_add_order;
```

【Members】

| Member Name                    | Description                                                       |
| ------------------------------ | ----------------------------------------------------------------- |
| K_VENC_2D_ADD_ORDER_VIDEO_OSD  | Video at the bottom, OSD at the top.                              |
| K_VENC_2D_ADD_ORDER_OSD_VIDEO  | OSD at the bottom, video at the top.                              |
| K_VENC_2D_ADD_ORDER_VIDEO_BG   | Video at the bottom, background color at the top.                 |
| K_VENC_2D_ADD_ORDER_BG_VIDEO   | Background color at the bottom, video at the top.                 |
| K_VENC_2D_ADD_ORDER_VIDEO_BG_OSD | Video at the bottom, background color in the middle, OSD at the top. |
| K_VENC_2D_ADD_ORDER_VIDEO_OSD_BG | Video at the bottom, OSD in the middle, background color at the top. |
| K_VENC_2D_ADD_ORDER_BG_VIDEO_OSD | Background color at the bottom, video in the middle, OSD at the top. |
| K_VENC_2D_ADD_ORDER_BG_OSD_VIDEO | Background color at the bottom, OSD in the middle, video at the top. |
| K_VENC_2D_ADD_ORDER_OSD_VIDEO_BG | OSD at the bottom, video in the middle, background color at the top. |
| K_VENC_2D_ADD_ORDER_OSD_BG_VIDEO | OSD at the bottom, background color in the middle, video at the top. |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_rotation

【Description】

Defines the encoding rotation angle enumeration.

【Definition】

typedef enum {
&emsp;K_VPU_ROTATION_0 = 0,
&emsp;K_VPU_ROTATION_90 = 1,
&emsp;K_VPU_ROTATION_180 = 2,
&emsp;K_VPU_ROTATION_270 = 3,
&emsp;K_VPU_ROTATION_BUTT
} k_rotation;

【Members】

| Member Name      | Description              |
| ---------------- | ------------------------ |
| K_VPU_ROTATION_0 | No rotation, 0 degrees.  |
| K_VPU_ROTATION_90 | Rotate 90 degrees.       |
| K_VPU_ROTATION_180 | Rotate 180 degrees.      |
| K_VPU_ROTATION_270 | Rotate 270 degrees.      |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_mirror

【Description】

Defines the encoding flip mode enumeration.

【Definition】

typedef enum {
&emsp;K_VENC_MIRROR_HORI = 0,
&emsp;K_VENC_MIRROR_VERT = 1,
&emsp;K_VENC_MIRROR_BUTT
} k_venc_mirror;

【Members】

| Member Name       | Description        |
| ----------------- | ------------------ |
| K_VENC_MIRROR_HORI | Horizontal flip.   |
| K_VENC_MIRROR_VERT | Vertical flip.     |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_2d_color_gamut

【Description】

Defines the color gamut enumeration for 2D operations.

【Definition】

typedef enum {
&emsp;VENC_2D_COLOR_GAMUT_BT601 = 0,
&emsp;VENC_2D_COLOR_GAMUT_BT709,
&emsp;VENC_2D_COLOR_GAMUT_BT2020,
&emsp;VENC_2D_COLOR_GAMUT_BUTT
} k_venc_2d_color_gamut;

【Members】

| Member Name               | Description       |
| ------------------------- | ----------------- |
| VENC_2D_COLOR_GAMUT_BT601  | BT.601 color gamut |
| VENC_2D_COLOR_GAMUT_BT709, | BT.709 color gamut |
| VENC_2D_COLOR_GAMUT_BT2020 | BT.2020 color gamut |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_chn_attr

【Description】

Defines the encoding channel attribute structure.

【Definition】

typedef struct {
&emsp;[k_venc_attr](#k_venc_attr) venc_attr;
&emsp;[k_venc_rc_attr](#k_venc_rc_attr) rc_attr;
} k_venc_chn_attr;

【Members】

| Member Name | Description             |
| ----------- | ----------------------- |
| venc_attr   | Encoder attribute.      |
| rc_attr     | Bitrate controller attribute. |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_attr

【Description】

Defines the encoder attribute structure.

【Definition】

typedef struct {
&emsp;k_payload_type type;
&emsp;k_u32 pic_width;
&emsp;k_u32 pic_height;
&emsp;k_venc_profile profile;
} k_venc_attr;

【Members】

| Member Name | Description                                                                                                                                          |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| type        | Encoding protocol type enumeration.                                                                                                                  |
| profile     | Encoding level enumeration.                                                                                                                         |
| pic_width   | Encoding image width. Value range: `[MIN_WIDTH, MAX_WIDTH]`, in pixels. Must be an integer multiple of MIN_ALIGN.                                     |
| pic_height  | Encoding image height. Value range: `[MIN_HEIGHT, MAX_HEIGHT]`, in pixels. Must be an integer multiple of MIN_ALIGN.                                  |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_rc_attr

【Description】

Defines the encoding channel bitrate controller attribute structure.

【Definition】

typedef struct {
&emsp;[k_venc_rc_mode](#k_venc_rc_mode) rc_mode;
&emsp;union { [k_venc_cbr](#k_venc_cbr) cbr;
&emsp;&emsp;[k_venc_vbr](#k_venc_vbr) vbr;
&emsp;&emsp;[k_venc_fixqp](#k_venc_fixqp) fixqp;
&emsp;&emsp;[k_venc_mjpeg_fixqp](#k_venc_mjpeg_fixqp) mjpeg_fixqp;
&emsp;};
} k_venc_rc_attr;

【Members】

| Member Name | Description                                                       |
| ----------- | ----------------------------------------------------------------- |
| rc_mode     | RC mode.                                                          |
| cbr         | H.264/H.265 protocol encoding channel CBR mode attribute.          |
| vbr         | H.264/H.265 protocol encoding channel VBR mode attribute.          |
| fixqp       | H.264/H.265 protocol encoding channel Fixqp mode attribute.        |
| mjpeg_fixqp | Mjpeg protocol encoding channel Fixqp mode attribute.              |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_cbr

【Description】

Defines the H.264/H.265 encoding channel CBR attribute structure.

【Definition】

typedef struct {
&emsp;k_u32 gop;
&emsp;k_u32 stats_time;
&emsp;k_u32 src_frame_rate;
&emsp;k_u32 dst_frame_rate;
&emsp;k_u32 bit_rate;
} k_venc_cbr;

【Members】

| Member Name    | Description                                                            |
| -------------- | ---------------------------------------------------------------------- |
| gop            | GOP value.                                                             |
| stats_time     | CBR bitrate statistics time, in seconds. Value range: `[1, 60]`.       |
| src_frame_rate | Input frame rate, in fps.                                              |
| dst_frame_rate | Encoder output frame rate, in fps.                                     |
| bit_rate       | Average bitrate, in kbps.                                              |

【Notes】

- If the set bitrate exceeds the maximum real-time bitrate specified in the chip manual, real-time encoding cannot be guaranteed.

【Related Data Types and Interfaces】

None.

#### k_venc_vbr

【Description】

Defines the H.264/H.265 encoding channel VBR attribute structure.

【Definition】

typedef struct {
&emsp;k_u32 gop;
&emsp;k_u32 stats_time;
&emsp;k_u32 src_frame_rate;
&emsp;k_u32 dst_frame_rate;
&emsp;k_u32 max_bit_rate;
&emsp;k_u32 bit_rate;
} k_venc_vbr;

【Members】

| Member Name    | Description                                                            |
| -------------- | ---------------------------------------------------------------------- |
| gop            | GOP value.                                                             |
| stats_time     | VBR bitrate statistics time, in seconds. Value range: `[1, 60]`.       |
| src_frame_rate | Input frame rate, in fps.                                              |
| dst_frame_rate | Encoder output frame rate, in fps.                                     |
| max_bit_rate   | Maximum bitrate, in kbps.                                              |
| bit_rate       | Average bitrate, in kbps.                                              |

【Notes】

Please refer to [k_venc_cbr](#k_venc_cbr) for the description of src_frame_rate and dst_frame_rate.

【Related Data Types and Interfaces】

None.

#### k_venc_fixqp

【Description】

Defines the H.264/H.265 encoding channel Fixqp attribute structure.

【Definition】

typedef struct {
&emsp;k_u32 gop;
&emsp;k_u32 src_frame_rate;
&emsp;k_u32 dst_frame_rate;
&emsp;k_u32 i_qp; k_u32 p_qp;
} k_venc_fixqp;

【Members】

| Member Name    | Description                                          |
| -------------- | ---------------------------------------------------- |
| gop            | GOP value.                                           |
| src_frame_rate | Input frame rate, in fps.                            |
| dst_frame_rate | Encoder output frame rate, in fps.                   |
| i_qp           | Qp value of all macroblocks in I frame. Value range: `[0, 51]`. |
| q_qp           | Qp value of all macroblocks in P frame. Value range: `[0, 51]`. |

【Notes】

Please refer to [k_venc_cbr](#k_venc_cbr) for the description of src_frame_rate and dst_frame_rate.

【Related Data Types and Interfaces】

None.

#### k_venc_mjpeg_fixqp

【Description】

Defines the MJPEG encoding channel Fixqp attribute structure.

【Definition】

typedef struct {
&emsp;k_u32 src_frame_rate;
&emsp;k_u32 dst_frame_rate;
&emsp;k_u32 q_factor;
} k_venc_mjpeg_fixqp;

【Members】

| Member Name    | Description                                              |
| -------------- | -------------------------------------------------------- |
| src_frame_rate | Input frame rate, in fps.                                |
| dst_frame_rate | Encoder output frame rate, in fps.                       |
| q_factor       | Qfactor for MJPEG encoding. Value range: `[1, 99]`.     |

【Notes】

Please refer to [k_venc_cbr](#k_venc_cbr) for the description of src_frame_rate and dst_frame_rate.

【Related Data Types and Interfaces】

None.

#### k_venc_chn_status

【Description】

Defines the encoding channel status structure.

【Definition】

typedef struct {
&emsp;k_u32 cur_packs;
&emsp;k_u64 release_pic_pts;
&emsp;k_bool end_of_stream;
} k_venc_chn_status;

【Members】

| Member Name     | Description                        |
| --------------- | ---------------------------------- |
| cur_packs       | Number of stream packets in the current frame. |
| release_pic_pts | PTS of the image corresponding to the released stream. |
| end_of_stream   | Stream end flag.                   |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_stream

【Description】

Defines the frame stream type structure.

【Definition】

typedef struct {
&emsp;[k_venc_pack](#k_venc_pack) \*pack;
&emsp;k_u32 pack_cnt;
} k_venc_stream;

【Members】

| Member Name | Description                              |
| ----------- | ---------------------------------------- |
| pack        | Frame stream packet structure.           |
| pack_cnt    | Number of all packets in a frame stream. |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_pack

【Description】

Defines the frame stream packet structure.

【Definition】

&emsp;typedef struct {
&emsp;k_u64 phys_addr;
&emsp;k_u32 len;
&emsp;k_u64 pts;
&emsp;[k_venc_pack_type](#k_venc_pack_type) type;
} k_venc_pack;

【Members】

| Member Name | Description              |
| ----------- | ------------------------ |
| phys_addr   | Physical address of the stream packet. |
| len         | Stream packet length.    |
| pts         | Timestamp. Unit: us.     |
| type        | Packet data type.        |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_2d_osd_attr

【Description】

2D overlay attribute structure.

【Definition】

typedef struct{
&emsp;k_u16 width;
&emsp;k_u16 height;
&emsp;k_u16 startx;
&emsp;k_u16 starty;
&emsp;k_u32 phys_addr`[3]`;
&emsp;k_u8 bg_alpha;
&emsp;k_u8 osd_alpha;
&emsp;k_u8 video_alpha;
&emsp;[k_venc_2d_add_order](#k_venc_2d_add_order) add_order;
&emsp;k_u32 bg_color;
&emsp;[k_venc_2d_osd_fmt](#k_venc_2d_osd_fmt) fmt;
} k_venc_2d_osd_attr;

【Members】

| Member Name | Description                                                                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| width       | Width of OSD overlay region.                                                                                                                          |
| height      | Height of OSD overlay region.                                                                                                                         |
| startx      | Pixel offset in the x direction from the top-left point of the OSD overlay region to the original image.                                              |
| starty      | Pixel offset in the y direction from the top-left point of the OSD overlay region to the original image.                                              |
| phys_addr   | Physical address of the OSD image.                                                                                                                    |
| bg_alpha    | Transparency of the background layer.                                                                                                                 |
| osd_alpha   | Transparency of the OSD image.                                                                                                                        |
| video_alpha | Transparency of the video input image.                                                                                                                |
| add_order   | OSD overlay order enumeration.                                                                                                                         |
| bg_color    | OSD background layer color, YUV444 format. Y: bit0\~bit7 U: bit8\~bit15 V: bit16\~bit 23                                                                |
| fmt         | OSD image format enumeration.                                                                                                                          |

【Notes】

- The start addresses of the source image and destination image in DDR must be guaranteed to be 8-byte aligned.
- The sizes of images and OSD must be even numbers.
- The src and dst addresses of OSD must be the same.

【Related Data Types and Interfaces】

None.

#### k_venc_2d_border_attr

【Description】

2D border drawing structure.

【Definition】

typedef struct {
&emsp;k_u16 width;
&emsp;k_u16 height;
&emsp;k_u16 line_width;
&emsp;k_u32 color;
&emsp;k_u16 startx;
&emsp;k_u16 starty;
} k_venc_2d_border_attr;

【Members】

| Member Name | Description                                                                                                              |
| ----------- | ------------------------------------------------------------------------------------------------------------------------ |
| width       | Width of the border drawing region, this is the outer frame width, including line width.                                |
| height      | Height of the border drawing region, this is the outer frame height, including line width.                              |
| line_width  | Line width of the border.                                                                                                |
| color       | Border color. Format is YUV444 Y: bit0\~bit7 U: bit8\~bit15 V: bit16\~bit 23                                              |
| startx      | Pixel offset in the x direction from the top-left point of the border drawing region to the original image.              |
| starty      | Pixel offset in the y direction from the top-left point of the border drawing region to the original image.              |

【Notes】

- The start addresses of the source image and destination image in DDR must be guaranteed to be 8-byte aligned.
- The sizes of images and borders must be even numbers.
- The src and dst addresses must be the same.

【Related Data Types and Interfaces】

None.

#### k_venc_h265_sao

【Description】

Defines the Sao structure for H.265 protocol encoding channel.

【Definition】

typedef struct {
&emsp;k_u32 slice_sao_luma_flag;
&emsp;k_u32 slice_sao_chroma_flag;
} k_venc_h265_sao;

【Members】

| Member Name           | Description                                              |
| :-------------------- | :-------------------------------------------------------- |
| slice_sao_luma_flag   | Default value is 1. Value range: 0 or 1.                 |
| slice_sao_chroma_flag | Default value is 1. Value range: 0 or 1.                 |

【Notes】

None.

#### k_venc_rect

【Description】

Defines the rectangle region information structure.

【Definition】

typedef struct {
&emsp;k_s32 left;
&emsp;k_s32 right;
&emsp;k_u32 top;
&emsp;k_u32 bottom;
} k_venc_rect;

【Members】

| Member Name | Description       |
| :---------- | :---------------- |
| left        | Left offset.      |
| right       | Right offset.     |
| top         | Top offset.       |
| bottom      | Bottom offset.    |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_roi_attr

【Description】

Defines the encoding Region of Interest information.

【Definition】

typedef struct {
&emsp;k_u32 idx;
&emsp;k_bool enable;
&emsp;k_bool is_abs_qp;
&emsp;k_s32 qp;
&emsp;[k_venc_rect](#k_venc_rect) rect;
} k_venc_roi_attr;

【Members】

| Member Name | Description                                                                                                          |
| :---------- | :-------------------------------------------------------------------------------------------------------------------- |
| idx         | Index of the ROI region. The system supported index range is `[0,15]`. Indices beyond this range are not supported.  |
| enable      | Whether to enable this ROI region.                                                                                   |
| is_abs_qp   | ROI region QP mode. K_FALSE: relative QP. K_TRUE: absolute QP.                                                        |
| qp          | QP value, range `[0,51]`.                                                                                            |
| rect        | ROI region. left, right, top, bottom must be 16-aligned.                                                             |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_h264_entropy

【Description】

Defines the entropy encoding structure for H.264 protocol encoding channel.

【Definition】

typedef struct {
&emsp;k_u32 entropy_coding_mode;
&emsp;k_u32 cabac_init_idc;
} k_venc_h264_entropy;

【Members】

| Member Name        | Description                                                                                                                                                |
| :----------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| entropy_coding_mode | Entropy coding mode. 0: cavlc. 1: cabac. >=2 has no meaning. Baseline does not support cabac. Default value is 1.                                          |
| cabac_init_idc     | Value range: `[0, 2]`, default value 0, please refer to H.264 protocol for specific meaning.                                                                |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_h265_entropy

【Description】

Defines the entropy encoding structure for H.265 protocol encoding channel.

【Definition】

typedef struct {
&emsp;k_u32 cabac_init_flag;
} k_venc_h265_entropy;

【Members】

| Member Name     | Description                                                  |
| :-------------- | :----------------------------------------------------------- |
| cabac_init_flag | Value range: `[0, 1]`, default value 1, please refer to H.265 protocol for specific meaning. |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_venc_2d_csc_attr

【Description】

Defines the VENC 2D CSC parameter structure.

【Definition】

typedef struct
{
&emsp;k_venc_2d_src_dst_fmt dst_fmt;
} k_venc_2d_csc_attr;

【Members】

| Member Name | Description                                                                |
| :---------- | :------------------------------------------------------------------------- |
| dst_fmt     | Value range: . Refer to [k_venc_2d_src_dst_fmt](#k_venc_2d_src_dst_fmt)   |

【Notes】

None.

【Related Data Types and Interfaces】

None.

### Video Decoding

The relevant data type definitions for this functional module are as follows:

- [k_vdec_send_mode](#k_vdec_send_mode): Defines the decoding channel attribute structure.
- [k_vdec_chn_attr](#k_vdec_chn_attr): Defines the decoding channel attribute structure.
- [k_vdec_chn_status](#k_vdec_chn_status): Defines the channel status structure.
- [k_vdec_dec_err](#k_vdec_dec_err): Defines the decoding error information structure.
- [k_vdec_stream](#k_vdec_stream): Defines the bitstream structure for video decoding.
- [k_vdec_supplement_info](#k_vdec_supplement_info): Defines the output frame supplement information.
- [k_vdec_dsl_mode](#k_vdec_dsl_mode): Defines the decoding downscale mode enumeration.
- [k_vdec_dsl_size](#k_vdec_dsl_size): Defines the decoding downscale-by-size parameter structure.
- [k_vdec_dsl_ratio](#k_vdec_dsl_ratio): Defines the decoding downscale-by-ratio parameter structure.
- [k_vdec_downscale](#k_vdec_downscale): Downscale structure.

#### k_vdec_send_mode

【Description】

Defines the decoding channel attribute structure.

【Definition】

typedef enum {
&emsp;K_VDEC_SEND_MODE_STREAM = 0,
&emsp;K_VDEC_SEND_MODE_FRAME,
&emsp;K_VDEC_SEND_MODE_BUTT
} k_vdec_send_mode;

【Members】

| Member Name              | Description                                                |
| ------------------------ | ---------------------------------------------------------- |
| K_VDEC_SEND_MODE_STREAM  | Send bitstream in stream mode.                             |
| OT_VDEC_SEND_MODE_FRAME  | Send bitstream in frame mode. In units of frames.          |

【Notes】

Currently only stream mode sending is supported.

【Related Data Types and Interfaces】

None.

#### k_vdec_chn_attr

【Description】

Defines the decoding channel attribute structure.

【Definition】

typedef struct {
&emsp;k_payload_type type;
&emsp;[k_vdec_send_mode](#k_vdec_send_mode) mode;
&emsp;k_u32 pic_width;
&emsp;k_u32 pic_height;
&emsp;k_u32 stream_buf_size;
} k_vdec_chn_attr;

【Members】

| Member Name     | Description                                                          |
| --------------- | -------------------------------------------------------------------- |
| type            | Decoding protocol type enumeration value.                            |
| mode            | Bitstream sending mode.                                              |
| pic_width       | Maximum width of the decoded image supported by the channel (in pixels). |
| pic_height      | Maximum height of the decoded image supported by the channel (in pixels). |
| stream_buf_size | Size of the bitstream buffer.                                        |

【Notes】

- Currently supported pic_format includes: PIXEL_FORMAT_YUV_SEMIPLANAR_420 and PIXEL_FORMAT_YVU_PLANAR_420.

【Related Data Types and Interfaces】

None.

#### k_vdec_chn_status

【Description】

Defines the channel status structure.

【Definition】

typedef struct {
&emsp;k_payload_type type;
&emsp;k_bool is_started;
&emsp;k_u32 recv_stream_frames;
&emsp;k_u32 dec_stream_frames;
&emsp;[k_vdec_dec_err](#k_vdec_dec_err) dec_err;
&emsp;k_u32 width;
&emsp;k_u32 height;
&emsp;k_u64 latest_frame_pts;
&emsp;k_bool end_of_stream;
} k_vdec_chn_status;

【Members】

| Member Name        | Description                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------------ |
| type               | Decoding protocol.                                                                               |
| is_started         | Whether the decoder has started receiving bitstreams.                                           |
| recv_stream_frames | "Number of bitstream frames received in the bitstream buffer. -1 indicates invalid. Invalid in stream sending mode." |
| dec_stream_frames  | Number of frames decoded in the bitstream buffer.                                                |
| dec_err            | Decoding error information.                                                                      |
| width              | Image width.                                                                                     |
| height             | Image height.                                                                                    |
| latest_frame_pts   | Timestamp of the latest decoded image.                                                           |
| end_of_stream      | Stream end flag.                                                                                 |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_vdec_dec_err

【Description】

Defines the decoding error information structure.

【Definition】

typedef struct {
&emsp;k_s32 set_pic_size_err;
&emsp;k_s32 format_err;
&emsp;k_s32 stream_unsupport;
} k_vdec_dec_err;

【Members】

| Member Name      | Description                                                                                       |
| ---------------- | ------------------------------------------------------------------------------------------------- |
| set_pic_size_err | The image width (or height) is larger than the channel width (or height).                        |
| format_err       | Unsupported format.                                                                               |
| stream_unsupport | Unsupported specification (the bitstream specification does not match the supported specifications of the solution). |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_vdec_stream

【Description】

Defines the bitstream structure for video decoding.

【Definition】

typedef struct {
&emsp;k_bool end_of_stream;
&emsp;k_u64 pts;
&emsp;k_u32 len;
&emsp;k_u8 \* addr;
} k_vdec_stream;

【Members】

| Member Name   | Description                                |
| ------------- | ------------------------------------------ |
| end_of_stream | Whether all bitstreams have been sent.     |
| pts           | Timestamp of the bitstream packet. In μs.  |
| len           | Length of the bitstream packet. In bytes.  |
| addr          | Address of the bitstream packet.           |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_vdec_supplement_info

【Description】

Defines the output frame supplement information.

【Definition】

typedef struct {
&emsp;k_payload_type type;
&emsp;k_bool is_valid_frame;
&emsp;k_bool end_of_stream;
} k_vdec_supplement_info;

【Members】

| Member Name    | Description                            |
| -------------- | -------------------------------------- |
| type           | Decoding protocol type enumeration value. |
| is_valid_frame | Whether it is a valid frame.           |
| end_of_stream  | Stream end flag.                       |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_vdec_dsl_mode

【Description】

Defines the decoding downscale mode enumeration.

【Definition】

typedef enum {
&emsp;K_VDEC_DSL_MODE_BY_SIZE,
&emsp;K_VDEC_DSL_MODE_BY_RATIO,
&emsp;K_VDEC_DSL_MODE_BUTT
} k_vdec_dsl_mode;

【Members】

| Member Name                | Description                |
| -------------------------- | -------------------------- |
| K_VDEC_DSL_MODE_BY_SIZE    | Downscale by size.         |
| K_VDEC_DSL_MODE_BY_RATIO   | Downscale by ratio.        |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_vdec_dsl_size

【Description】

Defines the decoding downscale-by-size parameter structure.

【Definition】

typedef struct {
&emsp;k_u32 dsl_frame_width;
&emsp;k_u32 dsl_frame_height;
} k_vdec_dsl_size;

【Members】

| Member Name      | Description                          |
| ---------------- | ------------------------------------ |
| dsl_frame_width  | Width after downscaling.             |
| dsl_frame_height | Height after downscaling.            |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_vdec_dsl_ratio

【Description】

Defines the decoding downscale-by-ratio parameter structure.

【Definition】

typedef struct {
&emsp;k_u8 dsl_ratio_hor;
&emsp;k_u8 dsl_ratio_ver;
} k_vdec_dsl_ratio;

【Members】

| Member Name      | Description                                    |
| ---------------- | ---------------------------------------------- |
| dsl_frame_width  | Downscale ratio in the horizontal direction.   |
| dsl_frame_height | Downscale ratio in the vertical direction.     |

【Notes】

None.

【Related Data Types and Interfaces】

None.

#### k_vdec_downscale

【Description】

Downscale structure.

【Definition】

typedef struct {
&emsp;[k_vdec_dsl_mode](#k_vdec_dsl_mode) dsl_mode;
&emsp;union
{
&emsp;&emsp;[k_vdec_dsl_size](#k_vdec_dsl_size) dsl_size;
&emsp;&emsp;[k_vdec_dsl_ratio](#k_vdec_dsl_ratio) dsl_ratio;
};
} k_vdec_downscale;

【Members】

| Member Name | Description                                |
| ----------- | ------------------------------------------ |
| dsl_mode    | Downscale mode enumeration.                |
| dsl_size    | Downscale-by-size parameter structure.     |
| dsl_ratio   | Downscale-by-ratio parameter structure.    |

【Notes】

None.

【Related Data Types and Interfaces】

None.

<a id="error-code"></a>

## Error Codes

Encoding API Error Codes

| Error Code   | Macro Definition              | Description                                                |
| ---------- | ------------------------ | -------------------------------------------- |
| 0xa0098001 | K_ERR_VENC_INVALID_DEVID | Device ID exceeds the valid range                           |
| 0xa0098002 | K_ERR_VENC_INVALID_CHNID | Channel ID exceeds the valid range                           |
| 0xa0098003 | K_ERR_VENC_ILLEGAL_PARAM | Parameter exceeds the valid range                             |
| 0xa0098004 | K_ERR_VENC_EXIST         | Attempted to apply for or create a device, channel, or resource that already exists |
| 0xa0098005 | K_ERR_VENC_UNEXIST       | Attempted to use or destroy a device, channel, or resource that does not exist   |
| 0xa0098006 | K_ERR_VENC_NULL_PTR      | A null pointer exists in the function parameters                           |
| 0xa0098007 | K_ERR_VENC_NOT_CONFIG    | Not configured before use                                 |
| 0xa0098008 | K_ERR_VENC_NOT_SUPPORT   | Unsupported parameter or function                         |
| 0xa0098009 | K_ERR_VENC_NOT_PERM      | This operation is not allowed, such as attempting to modify static configuration parameters         |
| 0xa009800c | K_ERR_VENC_NOMEM         | Memory allocation failed, such as insufficient system memory                 |
| 0xa009800d | K_ERR_VENC_NOBUF         | Buffer allocation failed, such as the requested data buffer being too large         |
| 0xa009800e | K_ERR_VENC_BUF_EMPTY     | No data in the buffer                               |
| 0xa009800f | K_ERR_VENC_BUF_FULL      | Data in the buffer is full                               |
| 0xa0098010 | K_ERR_VENC_NOTREADY      | The system is not initialized or the corresponding module is not loaded             |
| 0xa0098011 | K_ERR_VENC_BADADDR       | Address exceeds the valid range                             |
| 0xa0098012 | K_ERR_VENC_BUSY          | VENC system is busy                                   |

Decoding API Error Codes

| Error Code   | Macro Definition              | Description                                                |
| ---------- | ------------------------ | -------------------------------------------- |
| 0xa00a8001 | K_ERR_VDEC_INVALID_DEVID | Device ID exceeds the valid range                           |
| 0xa00a8002 | K_ERR_VDEC_INVALID_CHNID | Channel ID exceeds the valid range                           |
| 0xa00a8003 | K_ERR_VDEC_ILLEGAL_PARAM | Parameter exceeds the valid range                             |
| 0xa00a8004 | K_ERR_VDEC_EXIST         | Attempted to apply for or create a device, channel, or resource that already exists |
| 0xa00a8005 | K_ERR_VDEC_UNEXIST       | Attempted to use or destroy a device, channel, or resource that does not exist   |
| 0xa00a8006 | K_ERR_VDEC_NULL_PTR      | A null pointer exists in the function parameters                           |
| 0xa00a8007 | K_ERR_VDEC_NOT_CONFIG    | Not configured before use                                 |
| 0xa00a8008 | K_ERR_VDEC_NOT_SUPPORT   | Unsupported parameter or function                         |
| 0xa00a8009 | K_ERR_VDEC_NOT_PERM      | This operation is not allowed, such as attempting to modify static configuration parameters         |
| 0xa00a800c | K_ERR_VDEC_NOMEM         | Memory allocation failed, such as insufficient system memory                 |
| 0xa00a800d | K_ERR_VDEC_NOBUF         | Buffer allocation failed, such as the requested data buffer being too large         |
| 0xa00a800e | K_ERR_VDEC_BUF_EMPTY     | No data in the buffer                               |
| 0xa00a800f | K_ERR_VDEC_BUF_FULL      | Data in the buffer is full                               |
| 0xa00a8010 | K_ERR_VDEC_NOTREADY      | The system is not initialized or the corresponding module is not loaded             |
| 0xa00a8011 | K_ERR_VDEC_BADADDR       | Address exceeds the valid range                             |
| 0xa00a8012 | K_ERR_VDEC_BUSY          | VDEC system is busy                                   |

## Debugging Information

For multimedia memory management and system binding debugging information, please refer to the 《K230 System Control API Reference》.
