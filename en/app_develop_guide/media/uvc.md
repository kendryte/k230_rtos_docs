# RTOS UVC Host Usage Instructions

## Overview

RT-Smart UVC Host user-space interface uses the `uvc_host_*` naming convention, and image formats are described using `FOURCC`.

Related example directories:

- `src/rtsmart/examples/mpp/sample_uvc_host`
- `src/rtsmart/examples/mpp/sample_uvc_dev_picture`
- `src/rtsmart/examples/mpp/sample_uvc_dev_vicap`

Currently supported input formats are:

- `USBH_VIDEO_FOURCC_YUY2`
- `USBH_VIDEO_FOURCC_UYVY`
- `USBH_VIDEO_FOURCC_NV12`
- `USBH_VIDEO_FOURCC_I420`
- `USBH_VIDEO_FOURCC_MJPEG`

Where:

- `MJPEG` is a compressed stream format
- `YUY2`, `UYVY`, `NV12`, `I420` are raw pixel formats

## Data Structures

User-space header file: `src/rtsmart/mpp/userapps/api/mpi_uvc_api.h`

### `struct uvc_format`

```c
struct uvc_format {
    unsigned int width;
    unsigned int height;
    unsigned int fourcc;
    unsigned int frameinterval;
};
```

Field description:

| Field | Description |
|---|---|
| `width` | Expected or negotiated image width |
| `height` | Expected or negotiated image height |
| `fourcc` | Image format, using `USBH_VIDEO_FOURCC_*` |
| `frameinterval` | Frame interval, in units of 100ns; for example, 30fps can be written as `10000000 / 30` |

Description:

- `uvc_host_init()` uses it to receive user input, and also writes back the actual negotiated mode
- If the user-specified resolution/frame rate cannot be fully matched, the underlying layer will return the actual negotiated result

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

Field description:

| Field | Description |
|---|---|
| `index` | The UVC buffer index corresponding to the current frame |
| `bytesused` | The actual valid data length of the current frame |
| `userptr` | The user-space virtual address of the current frame |
| `v_info` | Video frame information corresponding to the raw image |
| `v_stream` | VDEC input information corresponding to the MJPEG stream |

Description:

- The user-space structure does not include internally used buffer mapping fields, such as `length`, `offset`, etc.
- `userptr` is only valid while the frame is held, and cannot be used after calling `uvc_host_put_frame()`
- For MJPEG, if you want to write directly to a file, `bytesused` is typically used

## FOURCC Definitions

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

## API Introduction

### `int uvc_host_init(struct uvc_format *fmt);`

Initialize the UVC Host device.

```c
int uvc_host_init(struct uvc_format *fmt);
```

Description:

- `fmt` inputs the user's expected `width` / `height` / `fourcc` / `frameinterval`
- After successful initialization, `fmt` will be updated to the actual negotiated mode
- The current UVC buffer is managed uniformly by the underlying layer; it is recommended to complete VB initialization before use

Return value:

- Returns `0` on success
- Returns a negative value on failure

### `int uvc_host_start_stream(void);`

Start the UVC video stream.

```c
int uvc_host_start_stream(void);
```

Return value:

- Returns `0` on success
- Returns a negative value on failure

### `int uvc_host_get_frame(struct uvc_frame *frame, unsigned int timeout_ms);`

Get one frame of UVC data.

```c
int uvc_host_get_frame(struct uvc_frame *frame, unsigned int timeout_ms);
```

Description:

- This interface will block until a frame of data is obtained or a timeout occurs
- After success, the `frame` will return buffer information and `userptr`
- After each successful acquisition, a paired call to `uvc_host_put_frame()` must be made

Return value:

- Returns `0` on success
- Returns a negative value on failure

### `int uvc_host_put_frame(struct uvc_frame *frame);`

Return a frame buffer.

```c
int uvc_host_put_frame(struct uvc_frame *frame);
```

Description:

- After returning, the buffer can be reused by the driver
- After the call, the `userptr` of the frame can no longer be used

### `void uvc_host_exit(void);`

Close the UVC device and release resources.

```c
void uvc_host_exit(void);
```

Description:

- If the stream has been started, `uvc_host_exit()` will be responsible for performing stream-stop cleanup
- There is currently no separate `uvc_host_stop_stream()` provided

### `int uvc_host_get_devinfo(char *info, int len);`

Get device vendor/product information.

```c
int uvc_host_get_devinfo(char *info, int len);
```

Description:

- On success, it returns a string in the format `vendor#product`
- Even if `uvc_host_init()` has not been called yet, the interface will temporarily open the device for querying

### `int uvc_host_get_formats(struct uvc_format **fmts);`

Enumerate all modes supported by the device.

```c
int uvc_host_get_formats(struct uvc_format **fmts);
```

Description:

- The return value is the number of modes
- `*fmts` is allocated internally by the interface; `uvc_host_free_formats()` must be called after use is complete
- Each `uvc_format` corresponds to a specific `width + height + fourcc + frameinterval`

### `void uvc_host_free_formats(struct uvc_format **fmts);`

Free the mode array returned by `uvc_host_get_formats()`.

```c
void uvc_host_free_formats(struct uvc_format **fmts);
```

## Raw Format Conversion Helper Interfaces

In addition to direct streaming, three commonly used raw format conversion interfaces are also provided:

```c
int uvc_host_raw_to_nv12(const struct uvc_frame *frame, void *dst, size_t dst_len);
int uvc_host_raw_to_rgb565(const struct uvc_frame *frame, void *dst, size_t dst_len);
int uvc_host_raw_to_yuyv(const struct uvc_frame *frame, void *dst, size_t dst_len);
```

Features of these interfaces:

- No longer require passing in `struct uvc_format` additionally
- They directly use the format negotiated by the most recent `uvc_host_init()`
- Only applicable to raw pixel formats, not applicable to `MJPEG`

### `uvc_host_raw_to_nv12`

Supported input formats:

- `YUY2`
- `UYVY`
- `NV12`
- `I420`

Destination buffer size requirement:

```c
dst_len >= width * height * 3 / 2
```

Notes:

- `NV12 -> NV12` is a direct copy
- When `dst == frame->userptr` and the current format is already `NV12`, no duplicate copy will occur

### `uvc_host_raw_to_rgb565`

Supported input formats:

- `YUY2`
- `UYVY`

Destination buffer size requirement:

```c
dst_len >= width * height * 2
```

### `uvc_host_raw_to_yuyv`

Supported input formats:

- `YUY2`
- `UYVY`

Destination buffer size requirement:

```c
dst_len >= width * height * 2
```

Notes:

- `YUY2` itself is YUYV byte order
- When the current format is `YUY2` and `dst == frame->userptr`, no duplicate copy will occur
- When the current format is `UYVY`, it will be converted to YUYV arrangement

## Basic Usage Flow

The typical call sequence is as follows:

1. Initialize VB
1. Optional: call `uvc_host_get_devinfo()` / `uvc_host_get_formats()`
1. Call `uvc_host_init()`
1. Call `uvc_host_start_stream()`
1. Loop calling `uvc_host_get_frame()` / `uvc_host_put_frame()`
1. Call `uvc_host_exit()` when the program ends

### Example 1: Writing MJPEG Data to a File

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

### Example 2: Converting Raw Format to NV12 and Sending to VO for Display

```c
struct uvc_format fmt = {
    .width = 640,
    .height = 480,
    .fourcc = USBH_VIDEO_FOURCC_YUY2,
    .frameinterval = 10000000 / 30,
};
struct uvc_frame frame;

/* vo_vaddr / vo_size / vf_info are prepared in advance by the VO side */

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

## Example Program

The current Host example is located at:

- `src/rtsmart/examples/mpp/sample_uvc_host/uvc_test.c`

Command line arguments:

```text
Usage: ./sample_uvc_host [connector_type] [rotation] [fourcc] [width] [height] [total_frame]
```

Parameter description:

| Parameter | Description |
|---|---|
| `connector_type` | Screen type enum value |
| `rotation` | Whether to rotate, `0` or `1` |
| `fourcc` | Supports `YUY2` / `UYVY` / `NV12` / `I420` / `MJPEG`, also supports passing numeric values directly |
| `width` | Target width |
| `height` | Target height |
| `total_frame` | Number of frames to process |

Running example:

```sh
/sdcard/app/examples/mpp/sample_uvc_host.elf 20 1 MJPEG 640 480 1000000
/sdcard/app/examples/mpp/sample_uvc_host.elf 20 1 YUY2 640 480 1000000
```

Notes:

- The program will print the input `fourcc` and the actual negotiated `fourcc`
- The `MJPEG` path internally goes through VDEC decoding before display
- Non-`MJPEG` paths will first call `uvc_host_raw_to_nv12()` and then send to VO for display
- The program will periodically print FPS

### Getting `connector_type`

You can view it with the following command:

```sh
msh />list_connector
```

## Configuration Options

### `make menuconfig`

```bash
    > RT-Smart UserSpace Examples Configuration > Enable MPP examples
        -> Enable Build sample_uvc_host # Select this configuration
```

### `make rtsmart-menuconfig`

```bash
    > Components Configuration > Enable CherryUSB > Enable CherryUSB Host
        -> CherryUSB Host Controller Driver (Using DesignWare Driver)  # Select (Using DesignWare Driver)

    > Components Configuration > Enable CherryUSB > Enable CherryUSB Host > Enable CherryUSB Host Class Driver
        ->  Enable UVC
```

## Notes

1. After `uvc_host_get_frame()` succeeds, you must pair it with a call to `uvc_host_put_frame()`.
1. `userptr` must not be saved or used across `uvc_host_put_frame()`.
1. If you only need to enumerate formats or read device information, you can simply call `uvc_host_get_formats()` / `uvc_host_get_devinfo()` without calling `uvc_host_init()` first.
1. For the `VO` display path, it is currently more common to first convert the original format to `NV12`.
1. It is not recommended to keep a UVC camera and high-bandwidth Bulk devices connected to the same Hub for extended periods, as you may encounter USB bandwidth shortage issues.
