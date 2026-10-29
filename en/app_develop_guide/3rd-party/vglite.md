# VG-Lite GPU and Examples

## Overview

K230's VG-Lite stack is now maintained jointly by the RT-Smart kernel driver and the user-space HAL, and no longer depends on the legacy `libgpu.a` and the legacy `userapps/src/vg_lite` copy in MPP.

```text
Application / LVGL
    -> libvg_lite.a (user-space command building and API)
    -> /dev device ioctl
    -> RT-Smart VG-Lite kernel driver
    -> GCNanoUltraV GPU
```

Source locations:

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/interdrv/gpu/
src/rtsmart/libs/rtsmart_hal/components/vg_lite/
src/rtsmart/examples/peripheral/vglite_tiger/
```

## Configuration

Enable the kernel and user-space separately:

```text
RT_USING_VG_LITE=y
RTSMART_HAL_ENABLE_VG_LITE=y
```

`RT_USING_VG_LITE` is enabled by default when RT-Smart userspace is enabled; the Tiger example also
selects the user-space HAL. Building the example requires:

```text
RTSMART_ENABLE_PERIPHERAL_EXAMPLES=y
RTSMART_PERIPHERAL_ENABLE_VGLITE_TIGER=y
```

The user-space build installs `vg_lite.h` and `libvg_lite.a`. The example Makefile obtains the header files and linker parameters through
`librtsmart_hal.mk`; custom applications should reuse the same build fragment.

## API Usage Flow

The minimum flow is as follows:

```c
#include <vg_lite.h>

vg_lite_buffer_t target = {0};
vg_lite_error_t error;

error = vg_lite_init(640, 480);
if (error != VG_LITE_SUCCESS)
    return error;

target.width = 640;
target.height = 480;
target.format = VG_LITE_RGBA8888;

error = vg_lite_allocate(&target);
if (error == VG_LITE_SUCCESS) {
    vg_lite_clear(&target, NULL, 0xff202020);
    vg_lite_finish();
    vg_lite_free(&target);
}

vg_lite_close();
```

Buffers created by `vg_lite_allocate()` use GPU-accessible contiguous pages and uncached mappings.
Externally allocated contiguous buffers for display, MPP, or other modules should have their physical address, stride, format, and
user address filled in before calling `vg_lite_map()`, and `vg_lite_unmap()` should be called before exiting. The driver validates the user
virtual address and physically contiguous range; do not pass ordinary non-contiguous heap buffers.

The drawing API first writes commands to the user-space command buffer. `vg_lite_flush()` submits the current batch
and allows the CPU to build the next batch, while `vg_lite_finish()` waits for all GPU work to complete. Before the CPU reads GPU results or passes a buffer to a module that does not share the synchronization semantics,
the corresponding synchronization must be completed.

## Tiger Example

Run without a display and view rendering performance:

```shell
vglite_tiger.elf --no-display --frames=100 --profile
```

After connecting a display, first use `list_connector` to query the connector enumeration value, and then run:

```shell
vglite_tiger.elf -c <connector_type> --animate --profile
```

Common parameters:

| Parameter | Description |
| :-- | :-- |
| `--frames=N` | Number of frames to render; defaults to a static frame when `--animate` is not specified |
| `--animate` | Updates the Tiger transformation each frame |
| `--fps=N` / `--no-sync` | Target frame rate for display synchronization, or disables synchronization waits |
| `--pipeline` | Enables a multi-display-buffer pipeline during animated display |
| `--buffers=1..8` | Number of display buffers |
| `--quality=high\|upper\|medium\|low` | Path tessellation quality |
| `--cmd-buf-kb=N` | Command buffer size; takes effect before initialization |
| `--tess-width=N`、`--tess-height=N` | Tessellation dimensions |
| `--no-upload` | Inlines path data each frame, for comparison with uploaded paths |
| `--profile` | Outputs timing for the clear, draw, submit, finish, and display stages |
| `--trace`、`--trace-paths` | Outputs runtime or path-level tracing information |

`--pipeline` can only be used together with `--animate` and display output. Press `Ctrl+C` to end continuous display.

## Performance and Memory Considerations

- Static or repeated paths should be uploaded first and reused across frames to avoid copying path data each time.
- Keep the transformed bounds of paths compact; excessively large tessellation regions increase tile stalls.
- Combine multiple draws into the same batch and use `flush()`/`finish()` to define explicit synchronization points.
- VG-Lite's own buffers are uncached; when mapping external cacheable buffers, necessary
  cache clean/invalidate operations still occur.
- The current user-space HAL uses a global context, and multiple threads should not build commands concurrently.

For the LVGL GPU renderer and image conversion paths, see [LVGL Example](lvgl.md).
