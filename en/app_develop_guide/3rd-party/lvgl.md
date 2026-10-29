# LVGL Examples and VG-Lite Acceleration

## Overview

K230 RT-Smart integrates LVGL 9.4 and provides adaptations for display, touch/HID, Sensor images, and K230 image
format conversion. After enabling the VG-Lite renderer, LVGL submits supported fill, border, shadow,
text, image, arc, line, layer, triangle, and mask tasks to the K230 GPU, while unsupported
tasks are still handled by the software renderer.

Source code locations:

```text
src/rtsmart/libs/3rd-party/lvgl/
src/rtsmart/examples/3rd-party/lvgl/
```

Current examples include:

| Example | Purpose |
| :-- | :-- |
| `lvgl_basic` | Displays common controls and verifies connector, OSD layer, rotation, and color format |
| `lvgl_hid` | Verifies USB HID input devices |
| `lvgl_sensor` | Displays Sensor images and overlays the LVGL UI |
| `lvgl_image_convert_test` | Verifies RVV pixel conversion and MPP CSC image conversion |

## Configuration

Enable the following in `make menuconfig`:

```text
RTSMART_3RD_PARTY_ENABLE_LVGL=y
RTSMART_ENABLE_3RD_PARTY_EXAMPLES=y
RTSMART_3RD_PARTY_ENABLE_LVGL_SAMPLES=y
```

The LVGL color depth is selected by the choice corresponding to `RTSMART_3RD_PARTY_LVGL_COLOR_DEPTH`，supporting
8、16、24 and 32 bit。The VG-Lite acceleration configuration is as follows：

```text
RTSMART_3RD_PARTY_LVGL_USE_VGLITE=y
RTSMART_HAL_ENABLE_VG_LITE=y
RT_USING_VG_LITE=y
```

Enabling `RTSMART_3RD_PARTY_LVGL_USE_VGLITE` automatically selects the user-space VG-Lite HAL；the kernel
still needs to include `RT_USING_VG_LITE`。The default tessellation size is 1920 x 1080，which can be adjusted through
`RTSMART_3RD_PARTY_LVGL_VGLITE_TESS_WIDTH` and
`RTSMART_3RD_PARTY_LVGL_VGLITE_TESS_HEIGHT`。

## Running lvgl_basic

First use `list_connector` to query the connector types supported by the current firmware, then run:

```shell
lvgl_basic.elf -c <connector_type>
```

Optional parameters:

```text
-c, --connector <type>  connector type
-l, --layer <id>        OSD layer, default 1
-f, --format <format>   l8, rgb565, rgb888, or argb8888
-r, --rotate <deg>      0, 90, 180, or 270
-H, --help              Display help
```

The example creates an LVGL display that matches the connector size and displays a label, button, bar, slider,
and switch. Pressing `Ctrl+C` to exit releases the LVGL, display, and VB resources.

For custom interfaces, continue using the standard LVGL API:

```c
lv_obj_t *label = lv_label_create(lv_screen_active());
lv_label_set_text(label, "Hello LVGL");
lv_obj_center(label);

while (running) {
    lv_timer_handler();
    usleep(5000);
}
```

## VG-Lite renderer

The K230 port creates a VG-Lite draw unit during LVGL initialization and retains the software draw unit
as a fallback. Applications do not need to rewrite every LVGL object to use the VG-Lite API, but the following should be noted:

- The draw buffer must be accessible by the GPU; the K230 port uses an appropriate
  allocator for LVGL's own buffers;
- Contiguous buffers from MPP/VB must first have their virtual address, physical address, size, cache attributes,
  and pixel format registered;
- When the CPU and GPU alternately access an external cacheable buffer, access must go through the port's synchronization path;
- Complex scenes should avoid frequently forcing `vg_lite_finish()`; instead, allow multiple draw tasks to form larger batches.

The low-level driver, native VG-Lite API, and Tiger performance examples are documented in
[VG-Lite GPU and examples](vglite.md).

## Image Conversion

The K230 port provides a layered conversion path for `lv_draw_buf_copy()`:

1. RVV is preferred between common packed LVGL formats;
1. When converting an MPP RGB/YUV buffer to an LVGL buffer, MPP CSC is used, combined with SDMA or
   memcpy as appropriate;
1. When the acceleration conditions are not met, it falls back to the scalar converter.

`lvgl_image_convert_test.elf` covers the following ranges:

- L8, A8, AL88, RGB565, RGB565 swapped, RGB888, XRGB8888;
- ARGB8888, premultiplied ARGB8888, ARGB1555, ARGB4444, ARGB2222, ARGB8565;
- MPP RGB/BGR packed formats, and NV12, NV21, I420.

Run the complete test:

```shell
lvgl_image_convert_test.elf
```

To run only one backend set or output each case:

```shell
lvgl_image_convert_test.elf --rvv-only
lvgl_image_convert_test.elf --csc-only --verbose
```

The program ultimately outputs `Total: passed/total`, where a return value of 0 indicates that all tests passed. CSC tests require successful MPP
VB initialization; if initialization fails, first check the VB configuration and memory rather than attributing all failures to LVGL.

## Sensor and Input Examples

`lvgl_sensor.elf` demonstrates the combined path of Sensor frame, LVGL draw buffer, GPU/CSC conversion, and display; `lvgl_hid.elf` demonstrates USB HID input. Before running, ensure that the target sensor, display, touch, or HID driver is included in the current board-level firmware.

## FAQ

1. connector initialization failure: use `list_connector` to verify the enumeration values and the board-level panel configuration.
1. The UI is displayed but GPU acceleration is not enabled: check the three VG-Lite configuration items and the startup log. The software
   fallback itself does not report an error.
1. Garbled external image: verify the physical address, stride, pixel format, cache attributes, and buffer
   lifecycle.
1. The conversion test only fails in the CSC case: first confirm that the MPP VB pool is available and that the YUV plane address
   and stride meet the format requirements.
