# K230视频编解码API参考

## 概述

### 概述

视频编解码模块具备强大的功能，能够支持 H.264、H.265 以及 JPEG 编解码。其中，VENC 模块负责实现 2D 运算和编码功能，这两个功能既可以同时启用，也能够单独进行运算。而 VDEC 模块则专注于实现解码功能。
需要注意的是，VENC、VENC + 2D 和 VDEC 支持系统绑定，但当 2D 单独进行运算时，不支持系统绑定。

### 功能描述

#### 视频编码模块

![encode flow](https://kendryte-download.canaan-creative.com/developer/pictures/9f7f41ea96a97ae9bf514535f6af1622.jpeg)

典型的视频编码流程包含多个关键步骤，如输入图像的接收、图像内容的遮挡与覆盖处理、图像的编码以及最终码流的输出等。

编码模块主要由 VENC 接收通道、编码通道、2D 接收通道以及 2D 运算模块构成。具体的编码能力和 2D 运算能力详见下表。

在编码数据流程图中，绿色箭头所指示的路径为单独进行 2D 运算的流程；蓝色箭头所指示的路径为单独进行编码运算的流程；紫色箭头所指示的路径为先进行 2D 运算，再进行编码的流程。

|              | H264                                                                                                            | HEVC                                                    | JPEG                                                   |
| ------------ | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------ |
| 输入格式     | YUV420 NV12 8bit, ARGB8888, BGRA8888                                                                            | YUV420 NV12 8bit, ARGB8888, BGRA8888                    | YUV420 NV12 8bit, YUV422 UYVY 8bit, ARGB8888, BGRA8888 |
| 输出格式     | YUV420 H.264 Baseline Profile(BP) ; H.264 Main Profile(MP) ; H.264 High Profile(HP);  H.264 High 10 Profile(HP) | YUV420 HEVC (H.265) Main ; HEVC (H.265) Main 10 Profile | YUV420 and YUV422 JPEG baseline sequential             |
| 最大分辨率   | 3840x2160                                                                                                       | 3840x2160                                               | 8192x8192                                              |
| 最小分辨率   | 128x64                                                                                                          | 128x64                                                  | 128x64                                                 |
| 码率控制模式 | CBR/VBR/FIXQP                                                                                                   | CBR/VBR/FIXQP                                           | FIXQP                                                  |
| GOP          | I/P帧                                                                                                           | I/P帧                                                   | -                                                      |
| 编码通道     | 4路                                                                                                             | 4路                                                     | 4路                                                    |

注意：H264/HEVC/JPEG共用4路。

| video输入格式               | video输出格式 | 叠加数据格式               | 最大分辨率 |
| --------------------------- | ------------- | -------------------------- | ---------- |
| I420/NV12/ARGB8888/BGRA8888 | 同输入格式    | ARGB8888/ARGB4444/ARGB1555 | 3840x2160  |

##### 编码通道

编码通道作为一个基本容器，用于保存编码通道的多种用户设置，并管理编码通道的多种内部资源。它主要完成图像叠加和编码的功能。其中，2D 模块负责实现图像叠加运算，编码器模块则负责实现图像编码。这两个模块既可以单独使用，也可以协同工作。

![encode channel](https://kendryte-download.canaan-creative.com/developer/pictures/d8ea12750bef3150afebf98c8a4563fd.jpeg)

##### 码率控制

码率控制器的主要作用是对编码码率进行精准控制。

从信息学的角度分析，图像的压缩比与压缩图像的质量呈反比关系，即图像的压缩比越低，压缩图像的质量越高；反之，图像压缩比例越高，压缩图像的质量越低。在场景发生变化的情况下，如果追求图像质量的稳定，那么编码码率会有较大的波动；而如果追求编码码率的稳定，则图像质量会出现较大的波动。H264/H265 编码支持 CBR、VBR 和 FIXQP 三种码率控制模式，而 MJPEG 仅支持 FIXQP 模式。

- CBR：（Constant Bit Rate）固定比特率。即在码率统计时间内保证编码码率平稳。
- VBR：（ Variable Bit Rate）可变比特率，即允许在码率统计时间内编码码率波动，从而保证编码图像质量平稳。
- FIXQP：固定QP值。在码率统计时间内，编码图像所有宏块QP值相同，采用用户设定的图像QP值。

##### GOP结构

本模块只支持I帧和P帧

##### 2D运算

2D运算模块可以实现对图像数据的OSD叠加，OSD模式可以实现8个region图像叠加，各region不重叠。支持的OSD格式有：ARGB4444/ARGB1555/ARGB8888。

###### 2D转换系数的计算

在OSD叠加运算时，如果输入video的格式为YUV，则OSD层需要做RGB to YUV的转换。在内核态有一组默认的转换系数，用户若需要自定义一组 12bit 的转换系数，可通过 RGB to YUV 的转换公式来获取。

已知 RGB to YUV 的转换公式如下：

![osd formula](https://kendryte-download.canaan-creative.com/developer/pictures/osd_formula.png)

具体计算方法为：3\*3矩阵中的系数乘以256后四舍五入取整，即可得到对应的转换系数，3\*1矩阵中的值即为对应的转换系数。

以BT709 LIMITED为例，RGB-\>YUV的转换公式为：

Y = 0.1826\*R + 0.6142\*G + 0.0620\*B + 16

U = -0.1007\*R - 0.3385\*G + 0.4392\*B + 128

V = 0.4392\*R - 0.3990\*G - 0.0402\*B + 128

由此可得，转换系数为：{ 47, 157, 16, 16, -26, -86, 112, 128, 112, -102, -10, 128 }

###### 2D转换系数的配置

2D转换系数可以通过用户自定义系数接口[kd_mpi_venc_set_2d_custom_coef](#kd_mpi_venc_set_2d_custom_coef)和色域配置接口[kd_mpi_venc_set_2d_color_gamut](#kd_mpi_venc_set_2d_color_gamut)进行配置，用户只需选择其中一个接口进行配置即可。如果在开始运算前这两个接口都未被调用，那么将使用默认系数进行色域转换。两者中选择一个接口进行配置即可。如果两个接口在开始运算前都没有调用，会使用默认系数进行色域转换。

##### 限制条件

编码运算存在以下限制：

1. 如果输入数据格式为YUV420，Y、U、V各分量的图像数据的物理起始地址需要保证4k对齐。
1. 如果输入数据格式为NV12，Y和UV数据的图像数据的物理起始地址需要保证4k对齐。

2D运算存在以下限制：

1. 源图像以及目的图像在ddr的物理起始地址要保证8byte align。
1. 支持图像、osd、框的尺寸为偶数。
1. 叠加和画框运算中的video数据的src和dst地址必须相同。

解码运算存在限制：每帧输入数据的物理起始地址需要4k对齐。

##### 编码典型应用举例

![venc sample flow](https://kendryte-download.canaan-creative.com/developer/pictures/e57bfe4e5657980663f22e7cdef1f182.jpeg)

#### 视频解码模块

|          | H264                                                                    | HEVC                     | JPEG                      |
| :------- | :---------------------------------------------------------------------- | :----------------------- | :------------------------ |
| 输入格式 | H.264 Baseline;H.264 Main;H.264 High;H.264 High10;支持interlaced stream | HEVC (H.265) Main/Main10 | JPEG, baseline sequential |
| 输出格式 | YUV420 NV12                                                             | YUV420 NV12              | YUV422 UYVY, YUV420 NV12  |
| 解码通道 | 4路                                                                     | 4路                      | 4路                       |

注意：H264/HEVC/JPEG共用4路。

VDEC支持流式发送：

- 流式发送（ K_VDEC_SEND_MODE_STREAM）：用户每次可发送任意长度码流到解码器，由解码器内部完成一帧码流的识别过程。须要注意的是，对H.264/H.265而言，在收到下一帧码流才能识别当前帧码流的结束，所以在该发送模式下，输入一帧H.264/H.265码流，不能希望马上开始解码图像。

##### 解码典型应用举例

![vdec sample flow](https://kendryte-download.canaan-creative.com/developer/pictures/e49f8a05613f3b2524e3dc075009146e.jpeg)

## API参考

### 视频编码

该功能模块提供以下API：

- [kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)：创建编码通道。
- [kd_mpi_venc_destory_chn](#kd_mpi_venc_destory_chn)：销毁编码通道。
- [kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)：开启编码通道接收输入图像。
- [kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn)：停止编码通道接收输入图像。
- [kd_mpi_venc_query_status](#kd_mpi_venc_query_status)：查询编码通道状态。
- [kd_mpi_venc_get_stream](#kd_mpi_venc_get_stream)：获取编码后的码流。
- [kd_mpi_venc_release_stream](#kd_mpi_venc_release_stream)：释放码流缓存。
- [kd_mpi_venc_send_frame](#kd_mpi_venc_send_frame)：支持用户发送原始图像进行编码。
- [kd_mpi_venc_set_rotaion](#kd_mpi_venc_set_rotaion)：设置编码图像旋转角度。
- [kd_mpi_venc_get_rotaion](#kd_mpi_venc_get_rotaion)：获取编码图像旋转角度。
- [kd_mpi_venc_set_mirror](#kd_mpi_venc_set_mirror)：设置编码图像旋转角度。
- [kd_mpi_venc_get_mirror](#kd_mpi_venc_get_mirror)：获取编码图像翻转方式。
- [kd_mpi_venc_enable_idr](#kd_mpi_venc_enable_idr)：使能IDR帧，根据GOP间隔产生IDR帧。
- [kd_mpi_venc_set_2d_mode](#kd_mpi_venc_set_2d_mode)：设置2D运算模式。
- [kd_mpi_venc_get_2d_mode](#kd_mpi_venc_get_2d_mode)：获取2D运算模式。
- [kd_mpi_venc_set_2d_osd_param](#kd_mpi_venc_set_2d_osd_param)：设置2D运算中OSD的区域属性。
- [kd_mpi_venc_get_2d_osd_param](#kd_mpi_venc_get_2d_osd_param)：获取2D运算中指定索引的OSD的区域属性。
- [kd_mpi_venc_set_2d_border_param](#kd_mpi_venc_set_2d_border_param)：设置2D运算中的画框属性。
- [kd_mpi_venc_get_2d_border_param](#kd_mpi_venc_get_2d_border_param)：获取2D运算中的画框属性。
- [kd_mpi_venc_set_2d_custom_coef](#kd_mpi_venc_set_2d_custom_coef)：设置2D运算中的图像格式转换系数。
- [kd_mpi_venc_get_2d_custom_coef](#kd_mpi_venc_get_2d_custom_coef)：获取2D运算中的图像格式转换系数。
- [kd_mpi_venc_set_2d_color_gamut](#kd_mpi_venc_set_2d_color_gamut)：设置2D运算的色域。
- [kd_mpi_venc_get_2d_color_gamut](#kd_mpi_venc_get_2d_color_gamut)：获取2D运算的色域
- [kd_mpi_venc_attach_2d](#kd_mpi_venc_attach_2d)：将2D运算与venc关联。
- [kd_mpi_venc_detach_2d](#kd_mpi_venc_detach_2d)：将2D运算与venc分离。
- [kd_mpi_venc_send_2d_frame](#kd_mpi_venc_send_2d_frame)：向2D模块发送一帧数据。
- [kd_mpi_venc_get_2d_frame](#kd_mpi_venc_get_2d_frame)：获取2D运算结果。
- [kd_mpi_venc_start_2d_chn](#kd_mpi_venc_start_2d_chn)：开始2D通道接收输入图像。
- [kd_mpi_venc_stop_2d_chn](#kd_mpi_venc_stop_2d_chn)：停止2D通道接收输入图像。
- [kd_mpi_venc_request_idr](#kd_mpi_venc_request_idr)：请求IDR帧，在调用之后立即产生一个IDR帧。
- [kd_mpi_venc_set_h265_sao](#kd_mpi_venc_set_h265_sao)：设置H.265通道的Sao属性。
- [kd_mpi_venc_get_h265_sao](#kd_mpi_venc_get_h265_sao)：获取H.265通道的Sao属性。
- [kd_mpi_venc_set_dblk](#kd_mpi_venc_set_dblk)：设置协议编码通道的Deblocking使能。
- [kd_mpi_venc_get_dblk](#kd_mpi_venc_get_dblk)：获取协议编码通道的Deblocking状态。
- [kd_mpi_venc_set_intbuf_size](#kd_mpi_venc_set_intbuf_size)：设置VENC内部缓冲大小。
- [kd_mpi_venc_get_2d_csc_param](#kd_mpi_venc_get_2d_csc_param)：获取2D CSC参数。
- [kd_mpi_venc_set_h264_entropy](#kd_mpi_venc_set_h264_entropy)：设置H.264协议编码通道的熵编码模式。
- [kd_mpi_venc_get_h264_entropy](#kd_mpi_venc_get_h264_entropy)：获取H.264协议编码通道的熵编码模式。
- [kd_mpi_venc_set_h265_entropy](#kd_mpi_venc_set_h265_entropy)：设置H.265协议编码通道的熵编码模式。
- [kd_mpi_venc_get_h265_entropy](#kd_mpi_venc_get_h265_entropy)：获取H.265协议编码通道的熵编码模式。

#### kd_mpi_venc_create_chn

【描述】

创建编码通道。

【语法】

k_s32 kd_mpi_venc_create_chn(k_u32 chn_num, const [k_venc_chn_attr](#k_venc_chn_attr) \*attr);

【参数】

| 参数名称 | 描述                                                                       | 输入/输出 |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| attr     | 编码通道属性指针。                                                         | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_destory_chn

【描述】

销毁编码通道。

【语法】

k_s32 kd_mpi_venc_destory_chn(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                     | 输入/输出 |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | 编码通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 销毁前必须停止接收图像，否则返回失败。

【举例】

无。

【相关主题】

[kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn)

#### kd_mpi_venc_start_chn

【描述】

开启编码通道接收输入图像。

【语法】

k_s32 kd_mpi_venc_start_chn(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                     | 输入/输出 |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | 编码通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，则返回失败K_ERR_VENC_UNEXIST。
- 如果通道已经开始接收图像，没有停止接收图像前再一次调用此接口指定接收帧数，返回操作不允许。
- 只有开启接收之后编码器才开始接收图像编码。

【举例】

无。

【相关主题】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)
[kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn)

#### kd_mpi_venc_stop_chn

【描述】

停止编码通道接收输入图像。

【语法】

k_s32 kd_mpi_venc_stop_chn(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                     | 输入/输出 |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | 编码通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，则返回失败。
- 此接口并不判断当前是否停止接收，即允许重复停止接收不返回错误。
- 此接口用于编码通道停止接收图像来编码，在编码通道销毁或复位前必须停止接收图像。
- 调用此接口仅停止接收原始数据编码，码流buffer并不会被清除。

【举例】

无。

【相关主题】

[kd_mpi_venc_destory_chn](#kd_mpi_venc_destory_chn)

#### kd_mpi_venc_query_status

【描述】

查询编码通道状态。

【语法】

k_s32 kd_mpi_venc_query_status(k_u32 chn_num, [k_venc_chn_status](#k_venc_chn_attr) \*status);

【参数】

| 参数名称 | 描述                                                                     | 输入/输出 |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | 编码通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| status   | 编码通道的状态指针。                                                     | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，则返回失败。

【举例】

无。

【相关主题】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)

#### kd_mpi_venc_get_stream

【描述】

获取编码后的码流。

【语法】

k_s32 kd_mpi_venc_get_stream(k_u32 chn_num, [k_venc_stream](#k_venc_stream) \*stream, k_s32 milli_sec);

【参数】

| 参数名称  | 描述                                                                            | 输入/输出 |
| --------- | ------------------------------------------------------------------------------- | --------- |
| chn_num   | 编码通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。        | 输入      |
| stream    | 码流结构体指针.                                                                 | 输出      |
| milli_sec | 获取码流超时时间。 取值范围： [-1, +∞ ) -1：阻塞。 0：非阻塞。 大于0：超时时间 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，返回失败。
- 如果stream为空，返回K_ERR_VENC_NULL_PTR。
- 如果milli_sec小于-1，返回K_ERR_VENC_ILLEGAL_PARAM。

【举例】

无。

【相关主题】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)
[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

#### kd_mpi_venc_release_stream

【描述】

释放码流缓存。

【语法】

k_s32 kd_mpi_venc_release_stream(k_u32 chn_num, [k_venc_stream](#k_venc_stream) \*stream);

【参数】

| 参数名称 | 描述                                                                     | 输入/输出 |
| -------- | ------------------------------------------------------------------------ | --------- |
| chn_num  | 编码通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| stream   | 码流结构体指针。                                                         | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，则返回错误码K_ERR_VENC_UNEXIST。
- 如果stream为空，则返回错误码K_ERR_VENC_NULL_PTR。

【举例】

无。

【相关主题】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)
[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

#### kd_mpi_venc_send_frame

【描述】

支持用户发送原始图像进行编码。

【语法】

k_s32 kd_mpi_venc_send_frame(k_u32 chn_num, k_video_frame_info \*frame, k_s32 milli_sec);

【参数】

| 参数名称  | 描述                                                                           | 输入/输出 |
| --------- | ------------------------------------------------------------------------------ | --------- |
| chn_num   | 编码通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。       | 输入      |
| frame     | 原始图像信息结构指针，参考《K230 系统控制 API参考》。                          | 输入      |
| milli_sec | 发送图像超时时间。 取值范围： [-1,+∞ ) -1：阻塞。 0：非阻塞。\> 0：超时时间。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 此接口支持用户发送图像至编码通道。
- 如果milli_sec小于-1，返回K_ERR_VENC_ILLEGAL_PARAM。
- 调用该接口发送图像，用户需要保证编码通道已创建且开启接收输入图像。

【举例】

无。

【相关主题】

[kd_mpi_venc_create_chn](#kd_mpi_venc_create_chn)
[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

#### kd_mpi_venc_set_rotaion

【描述】

设置编码图像旋转角度。

【语法】

k_s32 kd_mpi_venc_set_rotaion(k_u32 chn_num, const [k_rotation](#k_rotation) rotation);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| rotation | 旋转角度枚举。                                                       | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_rotaion

【描述】

获取编码图像旋转角度。

【语法】

k_s32 kd_mpi_venc_get_rotaion(k_u32 chn_num, [k_rotation](#k_rotation) \*rotation);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| rotation | 旋转角度枚举指针。                                                   | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_mirror

【描述】

设置编码图像镜像方式。

【语法】

k_s32 kd_mpi_venc_set_mirror(k_u32 chn_num, const [k_venc_mirror](#k_venc_mirror) mirror);

【参数】

| 参数名称 | 描述                                                                | 输入/输出 |
| -------- | ------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| mirror   | 翻转方式枚举。                                                      | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。
【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。
【举例】

无。
【相关主题】

无。

#### kd_mpi_venc_get_mirror

【描述】

设置编码图像镜像方式。
【语法】

| k_s32 kd_mpi_venc_get_mirror(k_u32 chn_num, [k_venc_mirror](#k_venc_mirror) mirror);|

【参数】

| 参数名称 | 描述                                                                | 输入/输出 |
| -------- | ------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| mirror   | 翻转方式枚举。                                                      | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。
【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。
【举例】

无。
【相关主题】

无。

#### kd_mpi_venc_enable_idr

【描述】

设置IDR帧使能。

【语法】

k_s32 kd_mpi_venc_enable_idr(k_u32 chn_num, k_bool idr_enable);

【参数】

| 参数名称   | 描述                                                                 | 输入/输出 |
| ---------- | -------------------------------------------------------------------- | --------- |
| chn_num    | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| idr_enable | 是否使能IDR帧。0：不使能。1：使能。                                  | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口需要在创建编码通道之后，开始编码通道之前调用。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_2d_mode

【描述】

设置2D运算模式。

【语法】

k_s32 kd_mpi_venc_set_2d_mode(k_u32 chn_num, [k_venc_2d_calc_mode](#k_venc_2d_calc_mode) mode);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| mode     | 2D运算模式枚举。                                                     | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 目前运算模式不支持K_VENC_2D_CALC_MODE_CSC模式。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_2d_mode

【描述】

获取2D运算模式。

【语法】

k_s32 kd_mpi_venc_get_2d_mode(k_u32 chn_num, [k_venc_2d_calc_mode](#k_venc_2d_calc_mode) \*mode);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| mode     | 2D运算模式枚举指针。                                                 | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 目前运算模式不支持K_VENC_2D_CALC_MODE_CSC模式。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_2d_osd_param

【描述】

设置2D运算中OSD的区域属性。

【语法】

k_s32 kd_mpi_venc_set_2d_osd_param(k_u32 chn_num, k_u8 index, const [k_venc_2d_osd_attr](#k_venc_2d_osd_attr) \*attr);

【参数】

| 参数名称 | 描述                                                                                            | 输入/输出 |
| -------- | ----------------------------------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。                            | 输入      |
| index    | OSD区域索引。 取值范围：[0,[K_VENC_MAX_2D_OSD_REGION_NUM](#k_venc_max_2d_osd_region_num))。 | 输入      |
| attr     | OSD属性指针。                                                                                   | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 如果有n个叠加区域，索引值应分别设置为0\~n-1。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_2d_osd_param

【描述】

获取2D运算中指定索引的OSD的区域属性。

【语法】

k_s32 kd_mpi_venc_get_2d_osd_param(k_u32 chn_num, k_u8 index, [k_venc_2d_osd_attr](#k_venc_2d_osd_attr) \*attr);

【参数】

| 参数名称 | 描述                                                                                            | 输入/输出 |
| -------- | ----------------------------------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。                            | 输入      |
| index    | OSD区域索引。 取值范围：[0,[K_VENC_MAX_2D_OSD_REGION_NUM](#k_venc_max_2d_osd_region_num))。 | 输入      |
| attr     | OSD属性指针。                                                                                   | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_2d_border_param

【描述】

设置2D运算中的画框属性。

【语法】

k_s32 kd_mpi_venc_set_2d_border_param(k_u32 chn_num, k_u8 index, const [k_venc_2d_border_attr](#k_venc_2d_border_attr) \*attr);

【参数】

| 参数名称 | 描述                                                                                 | 输入/输出 |
| -------- | ------------------------------------------------------------------------------------ | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。                 | 输入      |
| index    | 画框索引。 取值范围：[0,[K_VENC_MAX_2D_BORDER_NUM](#k_venc_max_2d_border_num))。 | 输入      |
| attr     | 画框属性指针。                                                                       | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 如果有n个框，索引值应分别设置为0\~n-1。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_2d_border_param

【描述】

获取2D运算中的画框属性。

【语法】

k_s32 kd_mpi_venc_get_2d_border_param(k_u32 chn_num, k_u8 index, [k_venc_2d_border_attr](#k_venc_2d_border_attr) \*attr);

【参数】

| 参数名称 | 描述                                                                                 | 输入/输出 |
| -------- | ------------------------------------------------------------------------------------ | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。                 | 输入      |
| index    | 画框索引。 取值范围：[0,[K_VENC_MAX_2D_BORDER_NUM](#k_venc_max_2d_border_num))。 | 输入      |
| attr     | 画框属性指针。                                                                       | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_2d_custom_coef

【描述】

设置2D运算中的图像格式转换系数。

【语法】

k_s32 kd_mpi_venc_set_2d_custom_coef(k_u32 chn_num, const k_s16 \*coef);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| coef     | 转换系数指针。参考[2D转换系数的计算](#2d转换系数的计算)        | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 内核态有一组默认的转换系数，如需自定义转换系数，可通过本接口配置。
- 本接口调用应该在设置运算模式之后。
- 转换系数的说明，详见[2D转换系数的计算](#2d转换系数的计算)
- 在运算模式为K_VENC_2D_CALC_MODE_BORDER时，不适用转换系数，调用本接口会报错。

【举例】

无。

【相关主题】

[kd_mpi_venc_set_2d_mode](#kd_mpi_venc_set_2d_mode)

#### kd_mpi_venc_get_2d_custom_coef

【描述】

获取2D运算中的图像格式转换系数。

【语法】

k_s32 kd_mpi_venc_get_2d_custom_coef(k_u32 chn_num, k_s16 \*coef);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| coef     | 转换系数指针。参考[2D转换系数的计算](#2d转换系数的计算)        | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口调用应该在设置运算模式之后。
- 在运算模式为K_VENC_2D_CALC_MODE_BORDER时，不适用转换系数，调用本接口会报错。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_2d_color_gamut

【描述】

设置2D运算的色域。

【语法】

k_s32 kd_mpi_venc_set_2d_color_gamut(k_u32 chn_num, const [k_venc_2d_color_gamut](#k_venc_2d_color_gamut) color_gamut);

【参数】

| 参数名称    | 描述                                                                 | 输入/输出 |
| ----------- | -------------------------------------------------------------------- | --------- |
| chn_num     | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| color_gamut | 色域枚举。                                                           | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 内核态有一组默认的转换系数，如需自定义转换系数，可通过本接口配置。
- 本接口调用应该在设置运算模式之后。
- 在运算模式为K_VENC_2D_CALC_MODE_BORDER时，不适用色域，调用本接口会报错。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_2d_color_gamut

【描述】

获取2D运算的色域。

【语法】

k_s32 kd_mpi_venc_get_2d_color_gamut(k_u32 chn_num, [k_venc_2d_color_gamut](#k_venc_2d_color_gamut) \*color_gamut);

【参数】

| 参数名称    | 描述                                                                 | 输入/输出 |
| ----------- | -------------------------------------------------------------------- | --------- |
| chn_num     | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| color_gamut | 色域枚举指针。                                                       | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 内核态有一组默认的转换系数，如需自定义转换系数，可通过本接口配置。
- 本接口调用应该在设置运算模式之后。
- 在运算模式为K_VENC_2D_CALC_MODE_BORDER时，不适用色域，调用本接口会报错。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_attach_2d

【描述】

将2D运算与venc关联。

【语法】

k_s32 kd_mpi_venc_attach_2d(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 目前绑定只支持编码通道号和2D运算通道号相同的模式。只有前3路编码支持attach 2D操作。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_detach_2d

【描述】

将2D运算与venc分离。

【语法】

k_s32 kd_mpi_venc_detach_2d(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                       | 输入/输出 |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 2D运算通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 调用该接口，用户需要保证编码通道已停止。

【举例】

无。

【相关主题】

[kd_mpi_venc_stop_chn](#kd_mpi_venc_stop_chn)

#### kd_mpi_venc_send_2d_frame

【描述】

向2D模块发送一帧数据。

【语法】

| k_s32 kd_mpi_venc_send_2d_frame(k_u32 chn_num, k_video_frame_info \*frame);

【参数】

| 参数名称 | 描述                                                                    | 输入/输出 |
| -------- | ----------------------------------------------------------------------- | --------- |
| chn_num  | 2D运算通道号，取值范围[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| frame    | 原始图像信息结构指针，参考《K230 系统控制 API参考》。                   | 输入      |

【返回值】

| 返回值 | 描述                          |
| ------ | ----------------------------- |
| 0      | 成功。                        |
| 非0    | 失败，返回[错误码](#错误码) |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口只在单2D运算的场景使用，在2D运算后再进行编码的场景，需要使用venc发送图形的接口[kd_mpi_venc_send_frame](#kd_mpi_venc_send_frame)。

【举例】

无。

【相关主题】

[kd_mpi_venc_send_frame](#kd_mpi_venc_send_frame)

#### kd_mpi_venc_get_2d_frame

【描述】

获取2D运算结果。

【语法】

k_s32 kd_mpi_venc_get_2d_frame(k_u32 chn_num, k_video_frame_info \*frame);

【参数】

| 参数名称 | 描述                                                                    | 输入/输出 |
| -------- | ----------------------------------------------------------------------- | --------- |
| chn_num  | 2D运算通道号，取值范围[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| frame    | 输出图像信息结构指针，参考《K230 系统控制 API参考》。                   | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口只在单2D运算的场景使用，在2D运算后再进行编码的场景，获取编码后的码流需要使用[kd_mpi_venc_get_stream](#kd_mpi_venc_get_stream)

【举例】

无。

【相关主题】

[kd_mpi_venc_get_stream](#kd_mpi_venc_get_stream)

#### kd_mpi_venc_start_2d_chn

【描述】

开始2D通道接收输入图像。

【语法】

k_s32 kd_mpi_venc_start_2d_chn(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                    | 输入/输出 |
| -------- | ----------------------------------------------------------------------- | --------- |
| chn_num  | 2D运算通道号，取值范围[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h

【注意】

- 本接口只在单2D运算的场景使用，在VENC+2D的场景，需要调用[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

【举例】

无。

【相关主题】

[kd_mpi_venc_start_chn](#kd_mpi_venc_start_chn)

#### kd_mpi_venc_stop_2d_chn

【描述】

停止2D通道接收输入图像。

【语法】

k_s32 kd_mpi_venc_stop_2d_chn(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                    | 输入/输出 |
| -------- | ----------------------------------------------------------------------- | --------- |
| chn_num  | 2D运算通道号，取值范围[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_request_idr

【描述】

请求IDR帧，在调用之后立即产生一个IDR帧。

【语法】

k_s32 kd_mpi_venc_request_idr(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_h265_sao

【描述】

设置H.265通道的Sao属性。

【语法】

k_s32 kd_mpi_venc_set_h265_sao(k_u32 chn_num, const [k_venc_h265_sao](#k_venc_h265_sao) *h265_sao);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| h265_sao | H.265协议编码通道的Sao配置。                                         | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口需要在创建编码通道之后，开始编码通道之前调用。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_h265_sao

【描述】

获取H.265通道的Sao属性。

【语法】

k_s32 kd_mpi_venc_get_h265_sao(k_u32 chn_num, [k_venc_h265_sao](#k_venc_h265_sao) *h265_sao);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| h265_sao | H.265协议编码通道的Sao配置。                                         | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_dblk

【描述】

设置H.264/H.265协议编码通道的Deblocking使能。

【语法】

k_s32 kd_mpi_venc_set_dblk(k_u32 chn_num, const k_bool dblk_en);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| dblk_en  | 是否使能deblocking。K_TRUE：使能。K_FALSE：不使能。默认使能。        | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口需要在创建编码通道之后，开始编码通道之前调用。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_dblk

【描述】

获取H.264/H.265协议编码通道的Deblocking状态。

【语法】

k_s32 kd_mpi_venc_get_dblk(k_u32 chn_num, k_bool *dblk_en);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| dblk_en  | 是否使能deblocking。K_TRUE：使能。K_FALSE：不使能。默认使能。        | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_intbuf_size

【描述】

设置VENC缓冲区大小。

【语法】

k_s32 kd_mpi_venc_set_intbuf_size(k_u32 chn_num, k_u32 size)

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| size     | buffer size。                                                        | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口需要在创建编码通道之前调用。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_2d_csc_param

【描述】

获取VENC通道的2D CSC属性。

【语法】

k_s32 kd_mpi_venc_get_2d_csc_param(k_u32 chn_num, k_venc_2d_csc_attr *attr);

【参数】

| 参数名称 | 描述                                                                 | 输入/输出 |
| -------- | -------------------------------------------------------------------- | --------- |
| chn_num  | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| attr     | 2D CSC参数。                                                         | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_h264_entropy

【描述】

设置H.264协议编码通道的熵编码模式。

【语法】

k_s32 kd_mpi_venc_set_h264_entropy(k_u32 chn_num, const [k_venc_h264_entropy](#k_venc_h264_entropy) *h264_entropy);

【参数】

| 参数名称     | 描述                                                                 | 输入/输出 |
| ------------ | -------------------------------------------------------------------- | --------- |
| chn_num      | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| h264_entropy | H.264协议编码通道的熵编码模式。                                      | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口需要在创建编码通道之后，开始编码通道之前调用。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_h264_entropy

【描述】

获取H.264协议编码通道的熵编码模式。

【语法】

k_s32 kd_mpi_venc_get_h264_entropy(k_u32 chn_num, [k_venc_h264_entropy](#k_venc_h264_entropy) *h264_entropy);

【参数】

| 参数名称     | 描述                                                                 | 输入/输出 |
| ------------ | -------------------------------------------------------------------- | --------- |
| chn_num      | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| h264_entropy | H.264协议编码通道的熵编码模式。                                      | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_set_h265_entropy

【描述】

设置H.265协议编码通道的熵编码模式。

【语法】

k_s32 kd_mpi_venc_set_h265_entropy(k_u32 chn_num, const [k_venc_h265_entropy](#k_venc_h265_entropy) *h265_entropy);

【参数】

| 参数名称     | 描述                                                                 | 输入/输出 |
| ------------ | -------------------------------------------------------------------- | --------- |
| chn_num      | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| h265_entropy | H.265协议编码通道的熵编码模式。                                      | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

- 本接口需要在创建编码通道之后，开始编码通道之前调用。

【举例】

无。

【相关主题】

无。

#### kd_mpi_venc_get_h265_entropy

【描述】

获取H.265协议编码通道的熵编码模式。

【语法】

k_s32 kd_mpi_venc_get_h265_entropy(k_u32 chn_num, [k_venc_h265_entropy](#k_venc_h265_entropy) *h265_entropy);

【参数】

| 参数名称     | 描述                                                                 | 输入/输出 |
| ------------ | -------------------------------------------------------------------- | --------- |
| chn_num      | 通道号。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| h265_entropy | H.265协议编码通道的熵编码模式。                                      | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，返回[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_venc_api.h，k_type.h，k_module.h，k_sys_comm.h，k_venc_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

### 视频解码

该功能模块提供以下API：

- [kd_mpi_vdec_create_chn](#kd_mpi_vdec_create_chn)：创建视频解码通道。
- [kd_mpi_vdec_destroy_chn](#kd_mpi_vdec_destroy_chn)：销毁视频解码通道。
- [kd_mpi_vdec_start_chn](#kd_mpi_vdec_start_chn)：开启视频解码通道。
- [kd_mpi_vdec_stop_chn](#kd_mpi_vdec_stop_chn)：停止视频解码通道。
- [kd_mpi_vdec_query_status](#kd_mpi_vdec_query_status)：解码器停止接收用户发送的码流。
- [kd_mpi_vdec_send_stream](#kd_mpi_vdec_send_stream)：向视频解码通道发送码流数据。
- [kd_mpi_vdec_get_frame](#kd_mpi_vdec_get_frame)：获取视频解码通道的解码图像。
- [kd_mpi_vdec_release_frame](#kd_mpi_vdec_release_frame)：获取视频解码通道的解码图像。
- [kd_mpi_vdec_set_downscale](#kd_mpi_vdec_set_downscale)：设置解码输出缩小的图像(指定长宽或按比例)。
- [kd_mpi_vdec_set_rotation](#kd_mpi_vdec_set_rotation)：设置解码旋转角度。
- [kd_mpi_vdec_close_fd](#kd_mpi_vdec_close_fd)：关闭VDEC设备

#### kd_mpi_vdec_create_chn

【描述】

创建视频解码通道。

【语法】

k_s32 kd_mpi_vdec_create_chn(k_u32 chn_num, [k_vdec_chn_attr](#k_vdec_chn_attr) \*attr);

【参数】

| 参数名称 | 描述                                                                       | 输入/输出 |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| attr     | 解码通道属性指针。                                                         | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_destroy_chn

【描述】

销毁视频解码通道。

【语法】

k_s32 kd_mpi_vdec_destroy_chn(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                       | 输入/输出 |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_start_chn

【描述】

开启视频解码通道。

【语法】

k_s32 kd_mpi_vdec_start_chn(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                       | 输入/输出 |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_stop_chn

【描述】

停止视频解码通道。

【语法】

k_s32 kd_mpi_vdec_stop_chn(k_u32 chn_num);

【参数】

| 参数名称 | 描述                                                                       | 输入/输出 |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_query_status

【描述】

查询解码通道状态。

【语法】

k_s32 kd_mpi_vdec_query_status(k_u32 chn_num, [k_vdec_chn_status](#k_vdec_chn_status) \*status);

【参数】

| 参数名称 | 描述                                                                       | 输入/输出 |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| status   | 视频解码通道状态结构体指针。                                               | 输出      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_send_stream

【描述】

向视频解码通道发送码流数据。

【语法】

k_s32 kd_mpi_vdec_send_stream(k_u32 chn_num, [k_vdec_stream](#k_vdec_stream) \*stream, k_s32 milli_sec);

【参数】

| 参数名称  | 描述                                                                                         | 输入/输出 |
| --------- | -------------------------------------------------------------------------------------------- | --------- |
| chn_num   | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。                   | 输入      |
| stream    | 解码码流数据指针。                                                                           | 输入      |
| milli_sec | 送码流方式标志。 取值范围：  -1：阻塞。 0：非阻塞。 正值：超时时间，没有上限值，以ms为单位。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_get_frame

【描述】

获取视频解码通道的解码图像。

【语法】

k_s32 kd_mpi_vdec_get_frame(k_u32 chn_num, k_video_frame_info \*frame_info, [k_vdec_supplement_info](#k_vdec_supplement_info) \*supplement, k_s32 milli_sec);

【参数】

| 参数名称   | 描述                                                                                                  | 输入/输出 |
| ---------- | ----------------------------------------------------------------------------------------------------- | --------- |
| chn        | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。                            | 输入      |
| frame_info | 获取的解码图像信息，参考《K230 系统控制 API参考》。                                                   | 输出      |
| supplement | 获取的解码图像补充信息。                                                                              | 输出      |
| milli_sec  | 送码流方式标志。 取值范围：  -1：阻塞。 0：非阻塞。 正值：超时时间，没有上限值，以ms为单位 动态属性。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_release_frame

【描述】

获取视频解码通道的解码图像。

【语法】

k_s32 kd_mpi_vdec_release_frame(k_u32 chn_num, k_video_frame_info \*frame_info);

【参数】

| 参数名称   | 描述                                                                                                                 | 输入/输出 |
| ---------- | -------------------------------------------------------------------------------------------------------------------- | --------- |
| chn        | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。                                           | 输入      |
| frame_info | 解码后的图像信息指针，由[kd_mpi_vdec_get_frame](#kd_mpi_vdec_get_frame)接口获取，参考《K230 系统控制 API参考》。 | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

无。

【举例】

无。

【相关主题】

[kd_mpi_vdec_get_frame](#kd_mpi_vdec_get_frame)

#### kd_mpi_vdec_set_downscale

【描述】

设置解码输出缩小的图像(指定长宽或按比例)。

【语法】

k_s32 kd_mpi_vdec_set_downscale(k_u32 chn_num, const  [k_vdec_downscale](#k_vdec_downscale)  *downscale)

【参数】

| 参数名称  | 描述                                                                       | 输入/输出 |
| --------- | -------------------------------------------------------------------------- | --------- |
| chn_num   | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| downscale | 缩小尺寸参数结构体指针。                                                   | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

在kd_mpi_vdec_create_chn和kd_mpi_vdec_start_chn之间设置。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_set_rotation

【描述】

设置解码旋转角度。

【语法】

k_s32 kd_mpi_vdec_set_rotation(k_u32 chn_num, [k_rotation](#k_rotation) rotation)

【参数】

| 参数名称 | 描述                                                                       | 输入/输出 |
| -------- | -------------------------------------------------------------------------- | --------- |
| chn_num  | 编码通道信息。 取值范围：[0,[VENC_MAX_CHN_NUMS](#venc_max_chn_nums))。 | 输入      |
| rotation | 旋转角度枚举。                                                             | 输入      |

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

在kd_mpi_vdec_create_chn和kd_mpi_vdec_start_chn之间设置。

【举例】

无。

【相关主题】

无。

#### kd_mpi_vdec_close_fd

【描述】

关闭VDEC设备。

【语法】

k_s32 kd_mpi_vdec_close_fd()

【参数】
无

【返回值】

| 返回值 | 描述                            |
| ------ | ------------------------------- |
| 0      | 成功。                          |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_vdec_api.h，k_type.h，k_module.h，k_sys_comm.h，k_vdec_comm.h
- 库文件：libvdec.a

【注意】

在kd_mpi_vdec_destroy_chn所有的chn之后调用该函数。

【举例】

无。

【相关主题】

无。

## 数据类型

### 视频编码模块

该功能模块的相关数据类型定义如下：

- [VENC_MAX_CHN_NUMS](#venc_max_chn_nums)：定义最大通道个数。
- [K_VENC_MAX_2D_OSD_REGION_NUM](#k_venc_max_2d_osd_region_num)：定义2D运算叠加OSD的最大Region个数。
- [K_VENC_MAX_2D_BORDER_NUM](#k_venc_max_2d_border_num)：定义2D运算画框的最大个数。
- [K_VENC_2D_COEF_NUM](#k_venc_2d_coef_num)：定义2D运算CSC转换系数的个数。
- [K_VENC_2D_MAX_CHN_NUM](#k_venc_2d_max_chn_num)：定义2D运算channel个数。
- [k_venc_rc_mode](#k_venc_rc_mode)：定义编码通道码率控制器模式。
- [k_venc_pack_type](#k_venc_pack_type)：定义JPEG码流PACK类型枚举。
- [k_venc_2d_calc_mode](#k_venc_2d_calc_mode)：定义2d运算的计算模式枚举。
- [k_venc_2d_src_dst_fmt](#k_venc_2d_src_dst_fmt)：定义2D运算的输入输出数据格式枚举。
- [k_venc_2d_osd_fmt](#k_venc_2d_osd_fmt)：定义2D运算的OSD层数据格式枚举。
- [k_venc_2d_add_order](#k_venc_2d_add_order)：定义2D运算的OSD叠加枚举。
- [k_rotation](#k_rotation)：定义编码旋转角度枚举。
- [k_venc_mirror](#k_venc_mirror)：定义编码翻转方式枚举。
- [k_venc_2d_color_gamut](#k_venc_2d_color_gamut)：定义2D运算的色域枚举。
- [k_venc_chn_attr](#k_venc_chn_attr)：定义编码通道属性结构体。
- [k_venc_attr](#k_venc_attr)：定义编码器属性结构体。
- [k_venc_rc_attr](#k_venc_rc_attr)：定义编码通道码率控制器属性结构体。
- [k_venc_cbr](#k_venc_cbr)：定义H.264/H.265编码通道CBR属性结构体。
- [k_venc_vbr](#k_venc_vbr)：定义H.264/H.265编码通道VBR属性结构体。
- [k_venc_fixqp](#k_venc_fixqp)：定义H.264/H.265编码通道Fixqp属性结构体。
- [k_venc_mjpeg_fixqp](#k_venc_mjpeg_fixqp)：定义MJPEG编码通道Fixqp属性结构体。
- [k_venc_chn_status](#k_venc_chn_status)：定义编码通道的状态结构体。
- [k_venc_stream](#k_venc_stream)：定义帧码流类型结构体。
- [k_venc_pack](#k_venc_pack)：定义帧码流包结构体。
- [k_venc_2d_osd_attr](#k_venc_2d_osd_attr)：2D叠加属性结构体。
- [k_venc_2d_border_attr](#k_venc_2d_border_attr)：2D画框结构体。
- [k_venc_h265_sao](#k_venc_h265_sao)：定义H.265协议编码通道Sao的结构体。
- [k_venc_rect](#k_venc_rect)：定义矩形区域信息结构体。
- [k_venc_roi_attr](#k_venc_roi_attr)：定义编码感兴趣区域信息。
- [k_venc_h264_entropy](#k_venc_h264_entropy)：定义H.264协议编码通道熵编码结构体。
- [k_venc_h265_entropy](#k_venc_h265_entropy)：定义H.265协议编码通道熵编码结构体。
- [k_venc_2d_csc_attr](#k_venc_2d_csc_attr)：定义2D CSC参数结构体。

#### VENC_MAX_CHN_NUMS

【说明】

定义最大通道个数。

【定义】

\#define VENC_MAX_CHN_NUMS 4

【注意事项】

无。

【相关数据类型及接口】

无。

#### K_VENC_MAX_2D_OSD_REGION_NUM

【说明】

定义2D运算叠加OSD的最大Region个数。

【定义】

\#define K_VENC_MAX_2D_OSD_REGION_NUM 8

【注意事项】

无。

【相关数据类型及接口】

无。

#### K_VENC_MAX_2D_BORDER_NUM

【说明】

定义2D运算画框的最大个数。

【定义】

\#define K_VENC_MAX_2D_BORDER_NUM 32

【注意事项】

无。

【相关数据类型及接口】

无。

#### K_VENC_2D_COEF_NUM

【说明】

定义2D运算CSC转换系数的个数。

【定义】

\#define K_VENC_2D_COEF_NUM 12

【注意事项】

无。

【相关数据类型及接口】

无。

#### K_VENC_2D_MAX_CHN_NUM

【说明】

定义2D运算channel个数。

【定义】

\#define K_VENC_2D_MAX_CHN_NUM 3

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_rc_mode

【说明】

定义编码通道码率控制器模式。

【定义】

typedef enum {
&emsp;K_VENC_RC_MODE_CBR = 1,
&emsp;K_VENC_RC_MODE_VBR,
&emsp;K_VENC_RC_MODE_FIXQP,
&emsp;K_VENC_RC_MODE_MJPEG_FIXQP,
&emsp;K_VENC_RC_MODE_BUTT,
} k_venc_rc_mode;

【成员】

| 成员名称                   | 描述                    |
| -------------------------- | ----------------------- |
| K_VENC_RC_MODE_CBR         | H.264/H.265 CBR模式。   |
| K_VENC_RC_MODE_VBR         | H.264/H.265 VBR模式。   |
| K_VENC_RC_MODE_FIXQP       | H.264/H.265 Fixqp模式。 |
| K_VENC_RC_MODE_MJPEG_FIXQP | MJPEG Fixqp模式。       |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_pack_type

【说明】

定义JPEG码流PACK类型枚举。

【定义】

typedef enum {
&emsp;K_VENC_P_FRAME = 1,
&emsp;K_VENC_I_FRAME = 2,
&emsp;K_VENC_HEADER = 3,
&emsp;K_VENC_BUTT
} k_venc_pack_type;

【成员】

| 成员名称       | 描述     |
| -------------- | -------- |
| K_VENC_P_FRAME | I帧。    |
| K_VENC_I_FRAME | P帧。    |
| K_VENC_HEADER  | Header。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_2d_calc_mode

【说明】

定义2d运算的计算模式枚举。

【定义】

typedef enum {
&emsp;K_VENC_2D_CALC_MODE_CSC = 0,
&emsp;K_VENC_2D_CALC_MODE_OSD,
&emsp;K_VENC_2D_CALC_MODE_BORDER,
&emsp;K_VENC_2D_CALC_MODE_OSD_BORDER,
&emsp;K_VENC_2D_CALC_MODE_BUTT
} k_venc_2d_calc_mode;

【成员】

| 成员名称                       | 描述                     |
| ------------------------------ | ------------------------ |
| K_VENC_2D_CALC_MODE_CSC        | 图片格式转换。           |
| K_VENC_2D_CALC_MODE_OSD        | 图片叠加。               |
| K_VENC_2D_CALC_MODE_BORDER     | 画框。                   |
| K_VENC_2D_CALC_MODE_OSD_BORDER | 先进行图片叠加，再画框。 |

【注意事项】

- 目前不支持K_VENC_2D_CALC_MODE_CSC模式。

【相关数据类型及接口】

无。

#### k_venc_2d_src_dst_fmt

【说明】

定义2D运算的输入输出数据格式枚举。

【定义】

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

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_2d_osd_fmt

【说明】

定义2D运算的OSD层数据格式枚举。

【定义】

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

【注意事项】

- 目前叠加图像只支持ARGB8888、ARGB4444和ARGB1555的格式。

【相关数据类型及接口】

无。

#### k_venc_2d_add_order

【说明】

定义2D运算的OSD叠加（video、osd和背景层）顺序枚举。

【定义】

typedef enum {
/\* bottom ------\> top \*/
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

【成员】

| 成员名称                         | 描述                                     |
| -------------------------------- | ---------------------------------------- |
| K_VENC_2D_ADD_ORDER_VIDEO_OSD    | Video在底层，OSD在顶层。                 |
| K_VENC_2D_ADD_ORDER_OSD_VIDEO    | OSD在底层，video在顶层。                 |
| K_VENC_2D_ADD_ORDER_VIDEO_BG     | Video在底层，背景色顶层。                |
| K_VENC_2D_ADD_ORDER_BG_VIDEO     | 背景色在底层，video顶层。                |
| K_VENC_2D_ADD_ORDER_VIDEO_BG_OSD | Video在底层，背景色在中间层，OSD在顶层。 |
| K_VENC_2D_ADD_ORDER_VIDEO_OSD_BG | Video在底层，OSD在中间层，背景色在顶层。 |
| K_VENC_2D_ADD_ORDER_BG_VIDEO_OSD | 背景色在底层，video在中间层，OSD在顶层。 |
| K_VENC_2D_ADD_ORDER_BG_OSD_VIDEO | 背景色在底层，OSD在中间层，video在顶层。 |
| K_VENC_2D_ADD_ORDER_OSD_VIDEO_BG | OSD在底层，video在中间层，背景色在顶层。 |
| K_VENC_2D_ADD_ORDER_OSD_BG_VIDEO | OSD在底层，背景色在中间层，video在顶层。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_rotation

【说明】

定义编码旋转角度枚举。

【定义】

typedef enum {
&emsp;K_VPU_ROTATION_0 = 0,
&emsp;K_VPU_ROTATION_90 = 1,
&emsp;K_VPU_ROTATION_180 = 2,
&emsp;K_VPU_ROTATION_270 = 3,
&emsp;K_VPU_ROTATION_BUTT
} k_rotation;

【成员】

| 成员名称           | 描述              |
| ------------------ | ----------------- |
| K_VPU_ROTATION_0   | 不旋转，旋转0度。 |
| K_VPU_ROTATION_90  | 旋转90度。        |
| K_VPU_ROTATION_180 | 旋转180度。       |
| K_VPU_ROTATION_270 | 旋转270度。       |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_mirror

【说明】

定义编码翻转方式枚举。

【定义】

typedef enum {
&emsp;K_VENC_MIRROR_HORI = 0,
&emsp;K_VENC_MIRROR_VERT = 1,
&emsp;K_VENC_MIRROR_BUTT
} k_venc_mirror;

【成员】

| 成员名称           | 描述       |
| ------------------ | ---------- |
| K_VENC_MIRROR_HORI | 水平翻转。 |
| K_VENC_MIRROR_VERT | 垂直翻转。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_2d_color_gamut

【说明】

定义2D运算的色域枚举。

【定义】

typedef enum {
&emsp;VENC_2D_COLOR_GAMUT_BT601 = 0,
&emsp;VENC_2D_COLOR_GAMUT_BT709,
&emsp;VENC_2D_COLOR_GAMUT_BT2020,
&emsp;VENC_2D_COLOR_GAMUT_BUTT
} k_venc_2d_color_gamut;

【成员】

| 成员名称                   | 描述        |
| -------------------------- | ----------- |
| VENC_2D_COLOR_GAMUT_BT601  | BT.601色域  |
| VENC_2D_COLOR_GAMUT_BT709, | BT.709色域  |
| VENC_2D_COLOR_GAMUT_BT2020 | BT.2020色域 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_chn_attr

【说明】

定义编码通道属性结构体。

【定义】

typedef struct {
&emsp;[k_venc_attr](#k_venc_attr) venc_attr;
&emsp;[k_venc_rc_attr](#k_venc_rc_attr) rc_attr;
} k_venc_chn_attr;

【成员】

| 成员名称  | 描述             |
| --------- | ---------------- |
| venc_attr | 编码器属性。     |
| rc_attr   | 码率控制器属性。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_attr

【说明】

定义编码器属性结构体。

【定义】

typedef struct {
&emsp;k_payload_type type;
&emsp;k_u32 stream_buf_size;
&emsp;k_u32 stream_buf_cnt;
&emsp;k_u32 pic_width;
&emsp;k_u32 pic_height;
&emsp;k_venc_profile profile;
} k_venc_attr;

【成员】

| 成员名称        | 描述                                                                                          |
| --------------- | --------------------------------------------------------------------------------------------- |
| type            | 编码协议类型枚。                                                                              |
| stream_buf_size | 码流buffer大小。                                                                              |
| stream_buf_size | 码流buffer大小。                                                                              |
| stream_buf_cnt  | 码流buffer个数。                                                                              |
| profile         | 编码的等级枚举。                                                                              |
| pic_width       | 编码图像宽度。 取值范围：`[MIN_WIDTH, MAX_WIDTH]`，以像素为单位。 必须是MIN_ALIGN的整数倍。   |
| pic_height      | 编码图像高度。 取值范围：`[MIN_HEIGHT, MAX_HEIGHT]`，以像素为单位。 必须是MIN_ALIGN的整数倍。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_rc_attr

【说明】

定义编码通道码率控制器属性结构体。

【定义】

typedef struct {
&emsp;[k_venc_rc_mode](#k_venc_rc_mode) rc_mode;
&emsp;union { [k_venc_cbr](#k_venc_cbr) cbr;
&emsp;&emsp;[k_venc_vbr](#k_venc_vbr) vbr;
&emsp;&emsp;[k_venc_fixqp](#k_venc_fixqp) fixqp;
&emsp;&emsp;[k_venc_mjpeg_fixqp](#k_venc_mjpeg_fixqp) mjpeg_fixqp;
&emsp;};
} k_venc_rc_attr;

【成员】

| 成员名称    | 描述                                        |
| ----------- | ------------------------------------------- |
| rc_mode     | RC模式。                                    |
| cbr         | H.264/H.265协议编码通道固定比特率模式属性。 |
| vbr         | H.264/H.265协议编码通道可变比特率模式属性。 |
| fixqp       | H.264/H.265协议编码通道固定qp模式属性。     |
| mjpeg_fixqp | Mjpeg协议编码通道Fixqp模式属性。            |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_cbr

【说明】

定义H.264/H.265编码通道CBR属性结构体。

【定义】

typedef struct {
&emsp;k_u32 gop;
&emsp;k_u32 stats_time;
&emsp;k_u32 src_frame_rate;
&emsp;k_u32 dst_frame_rate;
&emsp;k_u32 bit_rate;
} k_venc_cbr;

【成员】

| 成员名称       | 描述                                                |
| -------------- | --------------------------------------------------- |
| gop            | gop值。                                             |
| stats_time     | CBR码率统计时间，以秒为单位。 取值范围：`[1, 60]`。 |
| src_frame_rate | 输入帧率，以fps为单位。                             |
| dst_frame_rate | 编码器输出帧率，以fps为单位。                       |
| bit_rate       | 平均bitrate，以kbps为单位。                         |

【注意事项】

- 如果设置的码率超过芯片手册中规定的最大实时码率，则不能保证实时编码。

【相关数据类型及接口】

无。

#### k_venc_vbr

【说明】

定义H.264/H.265编码通道VBR属性结构体。

【定义】

typedef struct {
&emsp;k_u32 gop;
&emsp;k_u32 stats_time;
&emsp;k_u32 src_frame_rate;
&emsp;k_u32 dst_frame_rate;
&emsp;k_u32 max_bit_rate;
&emsp;k_u32 bit_rate;
} k_venc_vbr;

【成员】

| 成员名称       | 描述                                                |
| -------------- | --------------------------------------------------- |
| gop            | gop值。                                             |
| stats_time     | VBR码率统计时间，以秒为单位。 取值范围：`[1, 60]`。 |
| src_frame_rate | 输入帧率，以fps为单位。                             |
| dst_frame_rate | 编码器输出帧率，以fps为单位。                       |
| max_bit_rate   | 最大bitrate，以kbps为单位。                         |
| bit_rate       | 平均bitrate，以kbps为单位。                         |

【注意事项】

请参见[k_venc_cbr](#k_venc_cbr)关于src_frame_rate和dst_frame_rate的说明。

【相关数据类型及接口】

无。

#### k_venc_fixqp

【说明】

定义H.264/H.265编码通道Fixqp属性结构体。

【定义】

typedef struct {
&emsp;k_u32 gop;
&emsp;k_u32 src_frame_rate;
&emsp;k_u32 dst_frame_rate;
&emsp;k_u32 i_qp; k_u32 p_qp;
} k_venc_fixqp;

【成员】

| 成员名称       | 描述                                    |
| -------------- | --------------------------------------- |
| gop            | gop值。                                 |
| src_frame_rate | 输入帧率，以fps为单位。                 |
| dst_frame_rate | 编码器输出帧率，以fps为单位。           |
| i_qp           | I帧所有宏块Qp值。 取值范围：`[0, 51]`。 |
| q_qp           | P帧所有宏块Qp值。 取值范围：`[0, 51]`。 |

【注意事项】

请参见[k_venc_cbr](#k_venc_cbr)关于src_frame_rate和dst_frame_rate的说明。

【相关数据类型及接口】

无。

#### k_venc_mjpeg_fixqp

【说明】

定义MJPEG编码通道Fixqp属性结构体。

【定义】

typedef struct {
&emsp;k_u32 src_frame_rate;
&emsp;k_u32 dst_frame_rate;
&emsp;k_u32 q_factor;
} k_venc_mjpeg_fixqp;

【成员】

| 成员名称       | 描述                                       |
| -------------- | ------------------------------------------ |
| src_frame_rate | 输入帧率，以fps为单位。                    |
| dst_frame_rate | 编码器输出帧率，以fps为单位。              |
| q_factor       | MJPEG编码的Qfactor。 取值范围：`[1, 99]`。 |

【注意事项】

请参见[k_venc_cbr](#k_venc_cbr)关于src_frame_rate和dst_frame_rate的说明。

【相关数据类型及接口】

无。

#### k_venc_chn_status

【说明】

定义编码通道的状态结构体。

【定义】

typedef struct {
&emsp;k_u32 cur_packs;
&emsp;k_u64 release_pic_pts;
&emsp;k_bool end_of_stream;
} k_venc_chn_status;

【成员】

| 成员名称        | 描述                    |
| --------------- | ----------------------- |
| cur_packs       | 当前帧的码流包个数。    |
| release_pic_pts | 释放码流对应图像的PTS。 |
| end_of_stream   | Stream结束标志位。      |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_stream

【说明】

定义帧码流类型结构体。

【定义】

typedef struct {
&emsp;[k_venc_pack](#k_venc_pack) \*pack;
&emsp;k_u32 pack_cnt;
} k_venc_stream;

【成员】

| 成员名称 | 描述                     |
| -------- | ------------------------ |
| pack     | 帧码流包结构。           |
| pack_cnt | 一帧码流的所有包的个数。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_pack

【说明】

定义帧码流包结构体。

【定义】

&emsp;typedef struct {
&emsp;k_u64 phys_addr;
&emsp;k_u32 len;
&emsp;k_u64 pts;
&emsp;[k_venc_pack_type](#k_venc_pack_type) type;
} k_venc_pack;

【成员】

| 成员名称  | 描述                |
| --------- | ------------------- |
| phys_addr | 码流包物理地址。    |
| len       | 码流包长度。        |
| pts       | 时间戳。单位： us。 |
| type      | 包数据类型。        |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_2d_osd_attr

【说明】

2D叠加属性结构体。

【定义】

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

【成员】

| 成员名称    | 描述                                                                      |
| ----------- | ------------------------------------------------------------------------- |
| width       | OSD叠加区域的宽度。                                                       |
| height      | OSD叠加区域的高度。                                                       |
| startx      | OSD叠加区域左上点在原图中x方向上的像素偏移                                |
| starty      | OSD叠加区域左上点在原图中y方向上的像素偏移                                |
| phys_addr   | OSD图像的物理地址。                                                       |
| bg_alpha    | 背景层的透明度。                                                          |
| osd_alpha   | OSD图像的透明度。                                                         |
| video_alpha | video输入图像的透明度。                                                   |
| add_order   | OSD叠加顺序枚举。                                                         |
| bg_color    | OSD背景层颜色，YUV444格式。 Y: bit0\~bit7 U: bit8\~bit15 V: bit16\~bit 23 |
| fmt         | OSD图像格式枚举。                                                         |

【注意事项】

- 源图像以及目的图像在ddr的起始地址要保证8byte align。
- 支持图像、osd的尺寸为偶数。
- OSD的src和dst地址必须相同。

【相关数据类型及接口】

无。

#### k_venc_2d_border_attr

【说明】

2D画框结构体。

【定义】

typedef struct {
&emsp;k_u16 width;
&emsp;k_u16 height;
&emsp;k_u16 line_width;
&emsp;k_u32 color;
&emsp;k_u16 startx;
&emsp;k_u16 starty;
} k_venc_2d_border_attr;

【成员】

| 成员名称   | 描述                                                                 |
| ---------- | -------------------------------------------------------------------- |
| width      | 画框区域的宽度，此为外框宽度，包含线宽。                             |
| height     | 画框区域的高度，此为外框高度，包含线宽。                             |
| line_width | 画框的线宽。                                                         |
| color      | 框的颜色。格式为YUV444 Y: bit0\~bit7 U: bit8\~bit15 V: bit16\~bit 23 |
| startx     | 画框区域左上点在原图中x方向上的像素偏移                              |
| starty     | 画框区域左上点在原图中y方向上的像素偏移                              |

【注意事项】

- 源图像以及目的图像在ddr的起始地址要保证8byte align。
- 支持图像、框的尺寸为偶数。
- src和dst地址必须相同。

【相关数据类型及接口】

无。

#### k_venc_h265_sao

【说明】

定义H.265协议编码通道Sao的结构体。

【定义】

typedef struct {
&emsp;k_u32 slice_sao_luma_flag;
&emsp;k_u32 slice_sao_chroma_flag;
} k_venc_h265_sao;

【成员】

| 成员名称              | 描述                      |
| :-------------------- | :------------------------ |
| slice_sao_luma_flag   | 默认为1。取值范围：0或1。 |
| slice_sao_chroma_flag | 默认为1。取值范围：0或1。 |

【注意事项】

无。

#### k_venc_rect

【说明】

定义矩形区域信息结构体。

【定义】

typedef struct {
&emsp;k_s32 left;
&emsp;k_s32 right;
&emsp;k_u32 top;
&emsp;k_u32 bottom;
} k_venc_rect;

【成员】

| 成员名称 | 描述            |
| :------- | :-------------- |
| left     | Left offset。   |
| right    | Right offset。  |
| top      | Top offset。    |
| bottom   | Bottom offset。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_roi_attr

【说明】

定义编码感兴趣区域信息。

【定义】

typedef struct {
&emsp;k_u32 idx;
&emsp;k_bool enable;
&emsp;k_bool is_abs_qp;
&emsp;k_s32 qp;
&emsp;[k_venc_rect](#k_venc_rect) rect;
} k_venc_roi_attr;

【成员】

| 成员名称  | 描述                                                                    |
| :-------- | :---------------------------------------------------------------------- |
| idx       | ROI区域的索引，系统支持的索引范围为`[0,15]`，不支持超出这个范围的索引。 |
| enable    | 是否使能这个ROI区域。                                                   |
| is_abs_qp | ROI区域QP模式。K_FALSE：相对QP。K_TRUE：绝对QP。                        |
| qp        | QP值，范围`[0,51]`。                                                    |
| rect      | ROI区域。left、 right、 top、bottom必须是16对齐。                       |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_h264_entropy

【说明】

定义H.264协议编码通道熵编码结构体。

【定义】

typedef struct {
&emsp;k_u32 entropy_coding_mode;
&emsp;k_u32 cabac_init_idc;
} k_venc_h264_entropy;

【成员】

| 成员名称            | 描述                                                                             |
| :------------------ | :------------------------------------------------------------------------------- |
| entropy_coding_mode | 熵编码模式。0： cavlc。1： cabac。>=2没有意义。Baseline不支持cabac。 默认值为1。 |
| cabac_init_idc      | 取值范围：`[0, 2]`, 默认值0，具体含义请参见H.264协议。                           |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_h265_entropy

【说明】

定义H.265协议编码通道熵编码结构体。

【定义】

typedef struct {
&emsp;k_u32 cabac_init_flag;
} k_venc_h265_entropy;

【成员】

| 成员名称        | 描述                                                   |
| :-------------- | :----------------------------------------------------- |
| cabac_init_flag | 取值范围：`[0, 1]`, 默认值1，具体含义请参见H.265协议。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_venc_2d_csc_attr

【说明】

定义VENC 2D CSC 参数结构体。

【定义】

typedef struct
{
&emsp;k_venc_2d_src_dst_fmt dst_fmt;
} k_venc_2d_csc_attr;

【成员】

| 成员名称 | 描述                                                                 |
| :------- | :------------------------------------------------------------------- |
| dst_fmt  | 取值范围：。 参考[k_venc_2d_src_dst_fmt](#k_venc_2d_src_dst_fmt) |

【注意事项】

无。

【相关数据类型及接口】

无。

### 视频解码

该功能模块的相关数据类型定义如下：

- [k_vdec_send_mode](#k_vdec_send_mode)：定义解码通道属性结构体。
- [k_vdec_chn_attr](#k_vdec_chn_attr)：定义解码通道属性结构体。
- [k_vdec_chn_status](#k_vdec_chn_status)：定义通道状态结构体。
- [k_vdec_dec_err](#k_vdec_dec_err)：定义解码错误信息结构体。
- [k_vdec_stream](#k_vdec_stream)：定义视频解码的码流结构体。
- [k_vdec_supplement_info](#k_vdec_supplement_info)：定义输出帧补充信息。
- [k_vdec_dsl_mode](#k_vdec_dsl_mode)：定义解码减小尺寸模式枚举。
- [k_vdec_dsl_size](#k_vdec_dsl_size)：定义解码按照大小减小尺寸参数结构体。
- [k_vdec_dsl_ratio](#k_vdec_dsl_ratio)：定义解码按照比例减小尺寸参数结构体。
- [k_vdec_downscale](#k_vdec_downscale)：缩小尺寸结构体。

#### k_vdec_send_mode

【说明】

定义解码通道属性结构体。

【定义】

typedef enum {
&emsp;K_VDEC_SEND_MODE_STREAM = 0,
&emsp;K_VDEC_SEND_MODE_FRAME,
&emsp;K_VDEC_SEND_MODE_BUTT
} k_vdec_send_mode;

【成员】

| 成员名称                | 描述                           |
| ----------------------- | ------------------------------ |
| K_VDEC_SEND_MODE_STREAM | 按流方式发送码流。             |
| OT_VDEC_SEND_MODE_FRAME | 按帧方式发送码流。以帧为单位。 |

【注意事项】

目前只支持流式发送。

【相关数据类型及接口】

无。

#### k_vdec_chn_attr

【说明】

定义解码通道属性结构体。

【定义】

typedef struct {
&emsp;k_payload_type type;
&emsp;[k_vdec_send_mode](#k_vdec_send_mode) mode;
&emsp;k_u32 pic_width;
&emsp;k_u32 pic_height;
&emsp;k_u32 stream_buf_size;
&emsp;k_u32 frame_buf_size;
&emsp;k_u32 frame_buf_cnt;
&emsp;k_pixel_format pic_format;
} k_vdec_chn_attr;

【成员】

| 成员名称        | 描述                                              |
| --------------- | ------------------------------------------------- |
| type            | 解码协议类型枚举值。                              |
| mode            | 码流发送方式。                                    |
| pic_width       | 通道支持的解码图像最大宽（以像素为单位）          |
| pic_height      | 通道支持的解码图像最大高（以像素为单位）          |
| stream_buf_size | 码流缓存的大小。                                  |
| frame_buf_size  | 解码图像帧存buffer大小。                          |
| pic_format      | 输入数据格式枚举，参考《K230 系统控制 API参考》。 |

【注意事项】

- 目前支持的pic_format为：PIXEL_FORMAT_YUV_SEMIPLANAR_420和PIXEL_FORMAT_YVU_PLANAR_420。

【相关数据类型及接口】

无。

#### k_vdec_chn_status

【说明】

定义通道状态结构体。

【定义】

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

【成员】

| 成员名称           | 描述                                                           |
| ------------------ | -------------------------------------------------------------- |
| type               | 解码协议。                                                     |
| is_started         | 解码器是否已经启动接收码流。                                   |
| recv_stream_frames | "码流buffer中已接收码流帧数。 -1表示无效。 流模式发送时无效。" |
| dec_stream_frames  | 码流buffer中已解码帧数。                                       |
| dec_err            | 解码错误信息。                                                 |
| width              | 图像宽度。                                                     |
| height             | 图像高度。                                                     |
| latest_frame_pts   | 最新解码图像的时间戳。                                         |
| end_of_stream      | Stream结束标志位。                                             |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_vdec_dec_err

【说明】

定义解码错误信息结构体。

【定义】

typedef struct {
&emsp;k_s32 set_pic_size_err;
&emsp;k_s32 format_err;
&emsp;k_s32 stream_unsupport;
} k_vdec_dec_err;

【成员】

| 成员名称         | 描述                                                     |
| ---------------- | -------------------------------------------------------- |
| set_pic_size_err | 图像的宽（或高）比通道的宽（或高）大。                   |
| format_err       | 不支持的格式。                                           |
| stream_unsupport | 不支持的规格（码流规格与解决方案宣称支持的规格不一致）。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_vdec_stream

【说明】

定义视频解码的码流结构体。

【定义】

typedef struct {
&emsp;k_bool end_of_stream;
&emsp;k_u64 pts;
&emsp;k_u32 len;
&emsp;k_u8 \* addr;
} k_vdec_stream;

【成员】

| 成员名称      | 描述                          |
| ------------- | ----------------------------- |
| end_of_stream | 是否发完所有码流。            |
| pts           | 码流包的时间戳。以μs为单位。 |
| len           | 码流包的长度。以byte为单位。  |
| addr          | 码流包的地址。                |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_vdec_supplement_info

【说明】

定义输出帧补充信息。

【定义】

typedef struct {
&emsp;k_payload_type type;
&emsp;k_bool is_valid_frame;
&emsp;k_bool end_of_stream;
} k_vdec_supplement_info;

【成员】

| 成员名称       | 描述                 |
| -------------- | -------------------- |
| type           | 解码协议类型枚举值。 |
| is_valid_frame | 是否为有效帧。       |
| end_of_stream  | Stream结束标志位。   |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_vdec_dsl_mode

【说明】

定义解码减小尺寸模式枚举。

【定义】

typedef enum {
&emsp;K_VDEC_DSL_MODE_BY_SIZE,
&emsp;K_VDEC_DSL_MODE_BY_RATIO,
&emsp;K_VDEC_DSL_MODE_BUTT
} k_vdec_dsl_mode;

【成员】

| 成员名称                 | 描述           |
| ------------------------ | -------------- |
| K_VDEC_DSL_MODE_BY_SIZE  | 根据尺寸减小。 |
| K_VDEC_DSL_MODE_BY_RATIO | 根据比例减小。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_vdec_dsl_size

【说明】

定义解码按照大小减小尺寸参数结构体。

【定义】

typedef struct {
&emsp;k_u32 dsl_frame_width;
&emsp;k_u32 dsl_frame_height;
} k_vdec_dsl_size;

【成员】

| 成员名称         | 描述               |
| ---------------- | ------------------ |
| dsl_frame_width  | 减小尺寸后的宽度。 |
| dsl_frame_height | 减小尺寸后的高度。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_vdec_dsl_ratio

【说明】

定义解码按照比例减小尺寸参数结构体。

【定义】

typedef struct {
&emsp;k_u8 dsl_ratio_hor;
&emsp;k_u8 dsl_ratio_ver;
} k_vdec_dsl_ratio;

【成员】

| 成员名称         | 描述                     |
| ---------------- | ------------------------ |
| dsl_frame_width  | 减小尺寸水平方向的比例。 |
| dsl_frame_height | 减小尺寸垂直方向的比例。 |

【注意事项】

无。

【相关数据类型及接口】

无。

#### k_vdec_downscale

【说明】

缩小尺寸结构体。

【定义】

typedef struct {
&emsp;[k_vdec_dsl_mode](#k_vdec_dsl_mode) dsl_mode;
&emsp;union
{
&emsp;&emsp;[k_vdec_dsl_size](#k_vdec_dsl_size) dsl_size;
&emsp;&emsp;[k_vdec_dsl_ratio](#k_vdec_dsl_ratio) dsl_ratio;
};
} k_vdec_downscale;

【成员】

| 成员名称  | 描述                         |
| --------- | ---------------------------- |
| dsl_mode  | 减小尺寸模式枚举。           |
| dsl_size  | 按照大小减小尺寸参数结构体。 |
| dsl_ratio | 按照比例减小尺寸参数结构体。 |

【注意事项】

无。

【相关数据类型及接口】

无。

## 错误码

编码 API 错误码

| 错误代码   | 宏定义                   | 描述                                         |
| ---------- | ------------------------ | -------------------------------------------- |
| 0xa0098001 | K_ERR_VENC_INVALID_DEVID | 设备ID超出合法范围                           |
| 0xa0098002 | K_ERR_VENC_INVALID_CHNID | 通道ID超出合法范围                           |
| 0xa0098003 | K_ERR_VENC_ILLEGAL_PARAM | 参数超出合法范围                             |
| 0xa0098004 | K_ERR_VENC_EXIST         | 试图申请或者创建已经存在的设备、通道或者资源 |
| 0xa0098005 | K_ERR_VENC_UNEXIST       | 试图使用或者销毁不存在的设备、通道或者资源   |
| 0xa0098006 | K_ERR_VENC_NULL_PTR      | 函数参数中有空指针                           |
| 0xa0098007 | K_ERR_VENC_NOT_CONFIG    | 使用前未配置                                 |
| 0xa0098008 | K_ERR_VENC_NOT_SUPPORT   | 不支持的参数或者功能                         |
| 0xa0098009 | K_ERR_VENC_NOT_PERM      | 该操作不允许，如试图修改静态配置参数         |
| 0xa009800c | K_ERR_VENC_NOMEM         | 分配内存失败，如系统内存不足                 |
| 0xa009800d | K_ERR_VENC_NOBUF         | 分配缓存失败，如申请的数据缓冲区太大         |
| 0xa009800e | K_ERR_VENC_BUF_EMPTY     | 缓冲区中无数据                               |
| 0xa009800f | K_ERR_VENC_BUF_FULL      | 缓冲区中数据满                               |
| 0xa0098010 | K_ERR_VENC_NOTREADY      | 系统没有初始化或没有加载相应模块             |
| 0xa0098011 | K_ERR_VENC_BADADDR       | 地址超出合法范围                             |
| 0xa0098012 | K_ERR_VENC_BUSY          | VENC系统忙                                   |

解码 API 错误码

| 错误代码   | 宏定义                   | 描述                                         |
| ---------- | ------------------------ | -------------------------------------------- |
| 0xa00a8001 | K_ERR_VDEC_INVALID_DEVID | 设备ID超出合法范围                           |
| 0xa00a8002 | K_ERR_VDEC_INVALID_CHNID | 通道ID超出合法范围                           |
| 0xa00a8003 | K_ERR_VDEC_ILLEGAL_PARAM | 参数超出合法范围                             |
| 0xa00a8004 | K_ERR_VDEC_EXIST         | 试图申请或者创建已经存在的设备、通道或者资源 |
| 0xa00a8005 | K_ERR_VDEC_UNEXIST       | 试图使用或者销毁不存在的设备、通道或者资源   |
| 0xa00a8006 | K_ERR_VDEC_NULL_PTR      | 函数参数中有空指针                           |
| 0xa00a8007 | K_ERR_VDEC_NOT_CONFIG    | 使用前未配置                                 |
| 0xa00a8008 | K_ERR_VDEC_NOT_SUPPORT   | 不支持的参数或者功能                         |
| 0xa00a8009 | K_ERR_VDEC_NOT_PERM      | 该操作不允许，如试图修改静态配置参数         |
| 0xa00a800c | K_ERR_VDEC_NOMEM         | 分配内存失败，如系统内存不足                 |
| 0xa00a800d | K_ERR_VDEC_NOBUF         | 分配缓存失败，如申请的数据缓冲区太大         |
| 0xa00a800e | K_ERR_VDEC_BUF_EMPTY     | 缓冲区中无数据                               |
| 0xa00a800f | K_ERR_VDEC_BUF_FULL      | 缓冲区中数据满                               |
| 0xa00a8010 | K_ERR_VDEC_NOTREADY      | 系统没有初始化或没有加载相应模块             |
| 0xa00a8011 | K_ERR_VDEC_BADADDR       | 地址超出合法范围                             |
| 0xa00a8012 | K_ERR_VDEC_BUSY          | VDEC系统忙                                   |

## 调试信息

多媒体内存管理和和系统绑定调试信息，请参考《K230 系统控制 API参考》。
