# RTOS UVC Host 使用说明

## 概述

RT-Smart UVC Host 用户态接口使用 `uvc_host_*` 命名，图像格式使用 `FOURCC` 描述。

当前支持的输入格式为：

- `USBH_VIDEO_FOURCC_YUY2`
- `USBH_VIDEO_FOURCC_UYVY`
- `USBH_VIDEO_FOURCC_NV12`
- `USBH_VIDEO_FOURCC_I420`
- `USBH_VIDEO_FOURCC_MJPEG`

其中：

- `MJPEG` 是压缩码流格式
- `YUY2`、`UYVY`、`NV12`、`I420` 是原始像素格式

## 数据结构

用户态头文件：`src/rtsmart/mpp/userapps/api/mpi_uvc_api.h`

### `struct uvc_format`

```c
struct uvc_format {
    unsigned int width;
    unsigned int height;
    unsigned int fourcc;
    unsigned int frameinterval;
};
```

字段说明：

| 字段 | 说明 |
|---|---|
| `width` | 期望或协商后的图像宽度 |
| `height` | 期望或协商后的图像高度 |
| `fourcc` | 图像格式，使用 `USBH_VIDEO_FOURCC_*` |
| `frameinterval` | 帧间隔，单位为 100ns；例如 30fps 可写为 `10000000 / 30` |

说明：

- `uvc_host_init()` 既使用它接收用户输入，也会把协商后的实际模式写回去
- 如果用户指定的分辨率/帧率无法完全匹配，底层会返回实际协商结果

### `struct uvc_frame`

```c
struct uvc_frame {
    unsigned int index;
    unsigned int bytesused;
    char *userptr;
    union {
        k_video_frame_info v_info;
        k_vdec_stream v_stream;
    };
};
```

字段说明：

| 字段 | 说明 |
|---|---|
| `index` | 当前帧对应的 UVC buffer 索引 |
| `bytesused` | 当前帧实际有效数据长度 |
| `userptr` | 当前帧的用户态虚拟地址 |
| `v_info` | 原始图像对应的视频帧信息 |
| `v_stream` | MJPEG 码流对应的 VDEC 输入信息 |

说明：

- 用户态结构中不包含内部使用的 buffer 映射字段，例如 `length`、`offset` 等
- `userptr` 仅在该帧持有期间有效，调用 `uvc_host_put_frame()` 后不能继续使用
- 对于 MJPEG，如果要直接写文件，通常使用 `bytesused`

## FOURCC 定义

```c
#define USBH_VIDEO_FOURCC(a, b, c, d) \
    ((uint32_t)(uint8_t)(a) | ((uint32_t)(uint8_t)(b) << 8) | \
     ((uint32_t)(uint8_t)(c) << 16) | ((uint32_t)(uint8_t)(d) << 24))

#define USBH_VIDEO_FOURCC_YUY2  USBH_VIDEO_FOURCC('Y', 'U', 'Y', '2')
#define USBH_VIDEO_FOURCC_UYVY  USBH_VIDEO_FOURCC('U', 'Y', 'V', 'Y')
#define USBH_VIDEO_FOURCC_NV12  USBH_VIDEO_FOURCC('N', 'V', '1', '2')
#define USBH_VIDEO_FOURCC_I420  USBH_VIDEO_FOURCC('I', '4', '2', '0')
#define USBH_VIDEO_FOURCC_MJPEG USBH_VIDEO_FOURCC('M', 'J', 'P', 'G')
```

## API 介绍

### `int uvc_host_init(struct uvc_format *fmt);`

初始化 UVC Host 设备。

```c
int uvc_host_init(struct uvc_format *fmt);
```

说明：

- `fmt` 输入用户期望的 `width` / `height` / `fourcc` / `frameinterval`
- 初始化成功后，`fmt` 会被更新为协商后的实际模式
- 当前 UVC buffer 由底层统一管理，使用前建议先完成 VB 初始化

返回值：

- 成功返回 `0`
- 失败返回负值

### `int uvc_host_start_stream(void);`

启动 UVC 视频流。

```c
int uvc_host_start_stream(void);
```

返回值：

- 成功返回 `0`
- 失败返回负值

### `int uvc_host_get_frame(struct uvc_frame *frame, unsigned int timeout_ms);`

获取一帧 UVC 数据。

```c
int uvc_host_get_frame(struct uvc_frame *frame, unsigned int timeout_ms);
```

说明：

- 该接口会阻塞，直到获取到一帧数据或超时
- 成功后 `frame` 中会返回 buffer 信息和 `userptr`
- 每次成功获取后，都必须配对调用一次 `uvc_host_put_frame()`

返回值：

- 成功返回 `0`
- 失败返回负值

### `int uvc_host_put_frame(struct uvc_frame *frame);`

归还一帧 buffer。

```c
int uvc_host_put_frame(struct uvc_frame *frame);
```

说明：

- 归还后该 buffer 可以重新被驱动复用
- 调用后不能再继续使用该帧的 `userptr`

### `void uvc_host_exit(void);`

关闭 UVC 设备并释放资源。

```c
void uvc_host_exit(void);
```

说明：

- 如果流已经启动，`uvc_host_exit()` 会负责执行停流清理
- 当前没有额外提供独立的 `uvc_host_stop_stream()`

### `int uvc_host_get_devinfo(char *info, int len);`

获取设备厂商/产品信息。

```c
int uvc_host_get_devinfo(char *info, int len);
```

说明：

- 成功时会返回形如 `厂商#产品` 的字符串
- 即使尚未 `uvc_host_init()`，接口也会临时打开设备进行查询

### `int uvc_host_get_formats(struct uvc_format **fmts);`

枚举设备支持的全部模式。

```c
int uvc_host_get_formats(struct uvc_format **fmts);
```

说明：

- 返回值为模式数量
- `*fmts` 由接口内部申请，使用完成后必须调用 `uvc_host_free_formats()`
- 每一项 `uvc_format` 都对应一个具体的 `width + height + fourcc + frameinterval`

### `void uvc_host_free_formats(struct uvc_format **fmts);`

释放 `uvc_host_get_formats()` 返回的模式数组。

```c
void uvc_host_free_formats(struct uvc_format **fmts);
```

## 原始格式转换辅助接口

除了直接取流，当前还提供了 3 个常用原始格式转换接口：

```c
int uvc_host_raw_to_nv12(const struct uvc_frame *frame, void *dst, size_t dst_len);
int uvc_host_raw_to_rgb565(const struct uvc_frame *frame, void *dst, size_t dst_len);
int uvc_host_raw_to_yuyv(const struct uvc_frame *frame, void *dst, size_t dst_len);
```

这些接口的特点：

- 不再需要额外传入 `struct uvc_format`
- 它们直接使用最近一次 `uvc_host_init()` 协商得到的格式
- 只适用于原始像素格式，不适用于 `MJPEG`

### `uvc_host_raw_to_nv12`

支持输入格式：

- `YUY2`
- `UYVY`
- `NV12`
- `I420`

目标缓冲区大小要求：

```c
dst_len >= width * height * 3 / 2
```

说明：

- `NV12 -> NV12` 时属于直通复制
- 当 `dst == frame->userptr` 且当前格式已经是 `NV12` 时，不会重复拷贝

### `uvc_host_raw_to_rgb565`

支持输入格式：

- `YUY2`
- `UYVY`

目标缓冲区大小要求：

```c
dst_len >= width * height * 2
```

### `uvc_host_raw_to_yuyv`

支持输入格式：

- `YUY2`
- `UYVY`

目标缓冲区大小要求：

```c
dst_len >= width * height * 2
```

说明：

- `YUY2` 本身就是 YUYV 字节序
- 当当前格式为 `YUY2` 且 `dst == frame->userptr` 时，不会重复拷贝
- 当当前格式为 `UYVY` 时，会转换成 YUYV 排列

## 基本使用流程

典型调用顺序如下：

1. 初始化 VB
1. 可选：调用 `uvc_host_get_devinfo()` / `uvc_host_get_formats()`
1. 调用 `uvc_host_init()`
1. 调用 `uvc_host_start_stream()`
1. 循环调用 `uvc_host_get_frame()` / `uvc_host_put_frame()`
1. 程序结束时调用 `uvc_host_exit()`

### 示例 1：MJPEG 数据写文件

```c
struct uvc_format fmt = {
    .width = 640,
    .height = 480,
    .fourcc = USBH_VIDEO_FOURCC_MJPEG,
    .frameinterval = 10000000 / 30,
};
struct uvc_frame frame;

kd_mpi_vb_set_config(&config);
kd_mpi_vb_init();

if (uvc_host_init(&fmt) != 0) {
    return -1;
}

if (uvc_host_start_stream() != 0) {
    uvc_host_exit();
    return -1;
}

if (uvc_host_get_frame(&frame, 3000) == 0) {
    FILE *file = fopen("/sdcard/test.jpg", "wb");
    if (file) {
        fwrite(frame.userptr, 1, frame.bytesused, file);
        fclose(file);
    }
    uvc_host_put_frame(&frame);
}

uvc_host_exit();
```

### 示例 2：原始格式转 NV12 后送 VO 显示

```c
struct uvc_format fmt = {
    .width = 640,
    .height = 480,
    .fourcc = USBH_VIDEO_FOURCC_YUY2,
    .frameinterval = 10000000 / 30,
};
struct uvc_frame frame;

/* vo_vaddr / vo_size / vf_info 由 VO 侧提前准备好 */

if (uvc_host_init(&fmt) != 0) {
    return -1;
}

if (uvc_host_start_stream() != 0) {
    uvc_host_exit();
    return -1;
}

while (uvc_host_get_frame(&frame, 5000) == 0) {
    if (uvc_host_raw_to_nv12(&frame, vo_vaddr, vo_size) == 0) {
        kd_mpi_vo_insert_frame(K_VO_LAYER_VIDEO1, &vf_info);
    }
    uvc_host_put_frame(&frame);
}

uvc_host_exit();
```

## 示例程序

当前 Host 示例位于：

- `src/rtsmart/examples/mpp/sample_uvc_host/uvc_test.c`

命令行参数：

```text
Usage: ./sample_uvc_host [connector_type] [rotation] [fourcc] [width] [height] [total_frame]
```

参数说明：

| 参数 | 说明 |
|---|---|
| `connector_type` | 屏幕类型枚举值 |
| `rotation` | 是否旋转，`0` 或 `1` |
| `fourcc` | 支持 `YUY2` / `UYVY` / `NV12` / `I420` / `MJPEG`，也支持直接传数值 |
| `width` | 目标宽度 |
| `height` | 目标高度 |
| `total_frame` | 处理帧数 |

运行示例：

```sh
/sdcard/app/examples/mpp/sample_uvc_host.elf 20 1 MJPEG 640 480 1000000
/sdcard/app/examples/mpp/sample_uvc_host.elf 20 1 YUY2 640 480 1000000
```

说明：

- 程序会打印输入 `fourcc` 和实际协商后的 `fourcc`
- `MJPEG` 路径内部走 VDEC 解码后显示
- 非 `MJPEG` 路径会先调用 `uvc_host_raw_to_nv12()` 再送 VO 显示
- 程序会周期性打印 FPS

### 获取 `connector_type`

可以通过以下命令查看：

```sh
msh />list_connector
```

## 配置选项

### `make menuconfig`

```bash
    > RT-Smart UserSpace Examples Configuration > Enable MPP examples
        -> Enable Build sample_uvc_host # 选中该配置
```

### `make rtsmart-menuconfig`

```bash
    > Components Configuration > Enable CherryUSB > Enable CherryUSB Host
        -> CherryUSB Host Controller Driver (Using DesignWare Driver)  #选择 (Using DesignWare Driver

    > Components Configuration > Enable CherryUSB > Enable CherryUSB Host > Enable CherryUSB Host Class Driver
        ->  Enable UVC
```

## 注意事项

1. `uvc_host_get_frame()` 成功后，必须配对调用 `uvc_host_put_frame()`。
1. `userptr` 不能跨 `uvc_host_put_frame()` 保存和使用。
1. 如果只是做格式枚举或读取设备信息，可以只调用 `uvc_host_get_formats()` / `uvc_host_get_devinfo()`，不必先 `uvc_host_init()`。
1. 对于 `VO` 显示路径，当前更常见的做法是把原始格式先转换为 `NV12`。
1. 不建议把 UVC 摄像头和高带宽 Bulk 设备长期挂在同一个 Hub 后使用，可能会遇到 USB 带宽不足问题。
