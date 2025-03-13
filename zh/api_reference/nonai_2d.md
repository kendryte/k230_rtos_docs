# K230 nonai 2D API参考

## 概述

### 概述

nonai 2D硬件能实现OSD，画框和CSC功能，本文仅仅描述CSC功能，OSD和画框功能暂未在本文API中实现，后续如有需求可以增加。

VENC模块借助nonai 2D硬件实现了在编码图像上叠加OSD和画框，仅限于编码图像不能单独使用，见《K230_视频编解码_API参考》的1.2.1.4和2.1.14 ~ 2.1.29等章节。

### 功能描述

实现RGB和YUV的相互转换，作为mpp的一个模块，可参与系统绑定功能，在不绑定的情况下可以做单帧处理。

支持如下图像格式的互转：

PIXEL_FORMAT_YUV_SEMIPLANAR_420

PIXEL_FORMAT_YVU_PLANAR_420

PIXEL_FORMAT_YUV_PACKAGE_444

PIXEL_FORMAT_YVU_PLANAR_444

PIXEL_FORMAT_RGB_565

PIXEL_FORMAT_RGB_888

PIXEL_FORMAT_RGB_888_PLANAR

代码示例：

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

## API参考

- [kd_mpi_nonai_2d_create_chn](#kd_mpi_nonai_2d_create_chn)
- [kd_mpi_nonai_2d_destroy_chn](#kd_mpi_nonai_2d_destory_chn)
- [kd_mpi_nonai_2d_start_chn](#kd_mpi_nonai_2d_start_chn)
- [kd_mpi_nonai_2d_stop_chn](#kd_mpi_nonai_2d_stop_chn)
- [kd_mpi_nonai_2d_get_frame](#kd_mpi_nonai_2d_get_frame)
- [kd_mpi_nonai_2d_release_frame](#kd_mpi_nonai_2d_release_frame)
- [kd_mpi_nonai_2d_send_frame](#kd_mpi_nonai_2d_send_frame)

### kd_mpi_nonai_2d_create_chn

【描述】

创建通道。

【语法】

```c
k_s32 kd_mpi_nonai_2d_create_chn(k_u32 chn_num, const k_nonai_2d_chn_attr *attr);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| chn_num  | 通道号。 取值范围：[0, K_NONAI_2D_MAX_CHN_NUMS]。 | 输入      |
| attr     | 通道属性指针。                                                   | 输入      |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0      | 成功。                        |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_nonai_2d_api.h，k_type.h，k_module.h，k_sys_comm.h，k_nonai_2d_comm.h
- 库文件：libvenc.a

【注意】

无。

【举例】

无。

【相关主题】

无。

### kd_mpi_nonai_2d_destory_chn

【描述】

销毁通道。

【语法】

```c
k_s32 kd_mpi_nonai_2d_destory_chn(k_u32 chn_num);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| chn_num  | 通道号。 取值范围：[0, K_NONAI_2D_MAX_CHN_NUMS]。 | 输入      |

【返回值】

| 返回值 | 描述                          |
|---|---|
| 0      | 成功。                        |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_nonai_2d_api.h，k_type.h，k_module.h，k_sys_comm.h，k_nonai_2d_comm.h
- 库文件：libvenc.a

【注意】

- 销毁前必须调用kd_mpi_nonai_2d_stop_chn停止接收图像，否则返回失败。

【举例】

无。

【相关主题】

无。

### kd_mpi_nonai_2d_start_chn

【描述】

开启接收输入图像。

【语法】

```c
k_s32 kd_mpi_nonai_2d_start_chn(k_u32 chn_num);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| chn_num | 通道号。 取值范围：[0, K_NONAI_2D_MAX_CHN_NUMS]。 | 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_nonai_2d_api.h，k_type.h，k_module.h，k_sys_comm.h，k_nonai_2d_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，则返回失败K_ERR_NONAI_2D_UNEXIST。
- 如果通道已经开始接收图像，没有停止接收图像前再一次调用此接口指定接收帧数，返回操作不允许。
- 只有开启接收之后才开始处理帧。

【举例】

无。

【相关主题】

无。

### kd_mpi_nonai_2d_stop_chn

【描述】

停止接收输入图像。

【语法】

```c
k_s32 kd_mpi_nonai_2d_stop_chn(k_u32 chn_num);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| chn_num | 通道号。 取值范围：[0, K_NONAI_2D_MAX_CHN_NUMS]。 | 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_nonai_2d_api.h，k_type.h，k_module.h，k_sys_comm.h，k_nonai_2d_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，则返回失败。
- 此接口并不判断当前是否停止接收，即允许重复停止接收不返回错误。
- 此接口用于停止接收图像，在通道销毁或复位前必须停止接收图像。
- 调用此接口仅停止接收原始数据，frame buffer并不会被清除。

【举例】

无。

【相关主题】

无。

### kd_mpi_nonai_2d_get_frame

【描述】

获取处理后的图像。

【语法】

```c
k_s32 kd_mpi_nonai_2d_get_frame(k_u32 chn_num, k_video_frame_info *frame, k_s32 milli_sec);
```

【参数】

| 参数名称  | 描述 | 输入/输出 |
|---|---|---|
| chn_num | 通道号。 取值范围：[0, K_NONAI_2D_MAX_CHN_NUMS]。 | 输入 |
| frame    | 图像结构体指针. | 输出 |
| milli_sec | 获取图像超时时间。 取值范围： [-1, +∞] -1：阻塞。 0：非阻塞。 大于0：超时时间 | 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_nonai_2d_api.h，k_type.h，k_module.h，k_sys_comm.h，k_nonai_2d_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，返回失败。
- 如果frame为空，返回K_ERR_NONAI_2D_NULL_PTR。
- 如果milli_sec小于-1，返回K_ERR_NONAI_2D_ILLEGAL_PARAM。

【举例】

无。

【相关主题】

无。

### kd_mpi_nonai_2d_release_frame

【描述】

释放图像缓存。

【语法】

```c
k_s32 kd_mpi_nonai_2d_release_frame(k_u32 chn_num, k_video_frame_info *frame);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| chn_num  | 通道号。 取值范围：[0, K_NONAI_2D_MAX_CHN_NUMS]。 | 输入 |
| frame   | 图像结构体指针。 | 输出 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0      | 成功。                        |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_nonai_2d_api.h，k_type.h，k_module.h，k_sys_comm.h，k_nonai_2d_comm.h
- 库文件：libvenc.a

【注意】

- 如果通道未创建，则返回错误码K_ERR_NONAI_2D_UNEXIST。
- 如果frame为空，则返回错误码K_ERR_NONAI_2D_NULL_PTR。

【举例】

无。

【相关主题】

无。

### kd_mpi_nonai_2d_send_frame

【描述】

支持用户发送原始图像进行2D运算。

【语法】

```c
k_s32 kd_mpi_nonai_2d_send_frame(k_u32 chn_num, k_video_frame_info *frame, k_s32 milli_sec);
```

【参数】

| 参数名称  | 描述 | 输入/输出 |
|---|---|---|
| chn_num | 通道号。 取值范围：[0, K_NONAI_2D_MAX_CHN_NUMS]。 | 输入 |
| frame | 原始图像信息结构指针，参考《K230 系统控制 API参考》。 | 输入 |
| milli_sec | 发送图像超时时间。 取值范围： [-1,+∞] -1：阻塞。 0：非阻塞。 \> 0：超时时间。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0      | 成功。                        |
| 非0    | 失败，参见[错误码](#错误码)。 |

【芯片差异】

无。

【需求】

- 头文件：mpi_nonai_2d_api.h，k_type.h，k_module.h，k_sys_comm.h，k_nonai_2d_comm.h
- 库文件：libvenc.a

【注意】

- 此接口支持用户发送图像至通道。
- 如果milli_sec小于-1，返回K_ERR_NONAI_2D_ILLEGAL_PARAM。
- 调用该接口发送图像，用户需要保证通道已创建且开启接收输入图像。

【举例】

无。

【相关主题】

无。

## 数据类型

该功能模块的相关数据类型定义如下：

### K_NONAI_2D_MAX_CHN_NUMS

【说明】

定义最大通道个数。

【定义】

```c
#define K_NONAI_2D_MAX_CHN_NUMS  24
```

【注意事项】

无。

【相关数据类型及接口】

无。

### k_nonai_2d_calc_mode

【说明】

定义2D运算模式。

【定义】

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

【成员】

| 成员名称 | 描述                  |
| -------- | --------------------- |
| mode     | 2D计算模式 |

【注意事项】

目前仅仅支持CSC模式，其他模式暂未实现。

【相关数据类型及接口】

无。

### k_nonai_2d_chn_attr

【说明】

定义通道属性。

【定义】

```text
typedef struct
{
​      k_pixel_format dst_fmt;     /* Format of output image */
​      k_nonai_2d_calc_mode mode;
} k_nonai_2d_chn_attr;
```

【成员】

| 成员名称 | 描述                  |
| -------- | --------------------- |
| dst_fmt  | 输出图像的格式，见1.2章节 |
| mode     | 2D计算模式，见3.2章节 |

【注意事项】

【相关数据类型及接口】

无。

### k_nonai_2d_color_gamut

【说明】

定义CSC的颜色类型，默认是BT601。

【定义】

```text
typedef enum
{
​     NONAI_2D_COLOR_GAMUT_BT601 = 0,
​     NONAI_2D_COLOR_GAMUT_BT709,
​     NONAI_2D_COLOR_GAMUT_BT2020,
​     NONAI_2D_COLOR_GAMUT_BUTT
} k_nonai_2d_color_gamut;
```

【注意事项】

无。

【相关数据类型及接口】

无。

## 错误码

表 41  API 错误码
| 错误代码   | 宏定义                       | 描述                                         |
| ---------- | ---------------------------- | -------------------------------------------- |
| 0xa0188001 | K_ERR_NONAI_2D_INVALID_DEVID | 设备ID超出合法范围                           |
| 0xa0188002 | K_ERR_NONAI_2D_INVALID_CHNID | 通道ID超出合法范围                           |
| 0xa0188003 | K_ERR_NONAI_2D_ILLEGAL_PARAM | 参数超出合法范围                             |
| 0xa0188004 | K_ERR_NONAI_2D_EXIST         | 试图申请或者创建已经存在的设备、通道或者资源 |
| 0xa0188005 | K_ERR_NONAI_2D_UNEXIST       | 试图使用或者销毁不存在的设备、通道或者资源   |
| 0xa0188006 | K_ERR_NONAI_2D_NULL_PTR      | 函数参数中有空指针                           |
| 0xa0188007 | K_ERR_NONAI_2D_NOT_CONFIG    | 使用前未配置                                 |
| 0xa0188008 | K_ERR_NONAI_2D_NOT_SUPPORT   | 不支持的参数或者功能                         |
| 0xa0188009 | K_ERR_NONAI_2D_NOT_PERM      | 该操作不允许，如试图修改静态配置参数         |
| 0xa018800c | K_ERR_NONAI_2D_NOMEM         | 分配内存失败，如系统内存不足                 |
| 0xa018800d | K_ERR_NONAI_2D_NOBUF         | 分配缓存失败，如申请的数据缓冲区太大         |
| 0xa018800e | K_ERR_NONAI_2D_BUF_EMPTY     | 缓冲区中无数据                               |
| 0xa018800f | K_ERR_NONAI_2D_BUF_FULL      | 缓冲区中数据满                               |
| 0xa0188010 | K_ERR_NONAI_2D_NOTREADY      | 系统没有初始化或没有加载相应模块             |
| 0xa0188011 | K_ERR_NONAI_2D_BADADDR       | 地址超出合法范围                             |
| 0xa0188012 | K_ERR_NONAI_2D_BUSY          | NONAI_2D系统忙                               |
