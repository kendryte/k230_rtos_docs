# VG-Lite GPU 与示例

## 概述

K230 的 VG-Lite 栈现由 RT-Smart 内核驱动和用户态 HAL 共同维护，不再依赖 MPP
中的旧 `libgpu.a` 和旧 `userapps/src/vg_lite` 副本。

```text
应用 / LVGL
    -> libvg_lite.a（用户态命令构建与 API）
    -> /dev 设备 ioctl
    -> RT-Smart VG-Lite kernel driver
    -> GCNanoUltraV GPU
```

源码位置：

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/interdrv/gpu/
src/rtsmart/libs/rtsmart_hal/components/vg_lite/
src/rtsmart/examples/peripheral/vglite_tiger/
```

## 配置

内核和用户态分别启用：

```text
RT_USING_VG_LITE=y
RTSMART_HAL_ENABLE_VG_LITE=y
```

`RT_USING_VG_LITE` 在启用 RT-Smart userspace 时默认为开启；Tiger 示例还会
选择用户态 HAL。构建示例需要：

```text
RTSMART_ENABLE_PERIPHERAL_EXAMPLES=y
RTSMART_PERIPHERAL_ENABLE_VGLITE_TIGER=y
```

用户态构建会安装 `vg_lite.h` 和 `libvg_lite.a`。示例 Makefile 通过
`librtsmart_hal.mk` 获取头文件和链接参数，自定义应用建议复用同一构建片段。

## API 使用流程

最小流程如下：

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

`vg_lite_allocate()` 创建的缓冲区使用 GPU 可访问的连续页和 uncached 映射。
显示、MPP 或其他模块分配的外部连续缓冲区应填写物理地址、stride、format 和
用户地址后调用 `vg_lite_map()`，退出前调用 `vg_lite_unmap()`。驱动会验证用户
虚拟地址和物理连续范围；不要传入普通的非连续 heap 缓冲区。

绘制 API 先把命令写入用户态 command buffer。`vg_lite_flush()` 提交当前 batch
并允许 CPU 构建下一批，`vg_lite_finish()` 会等待所有 GPU 工作完成。在 CPU
读取 GPU 结果或把缓冲区交给不共享同步语义的模块前，必须完成对应同步。

## Tiger 示例

无显示运行并查看渲染性能：

```shell
vglite_tiger.elf --no-display --frames=100 --profile
```

连接显示器后先用 `list_connector` 查询 connector 枚举值，再运行：

```shell
vglite_tiger.elf -c <connector_type> --animate --profile
```

常用参数：

| 参数 | 说明 |
| :-- | :-- |
| `--frames=N` | 渲染帧数；`--animate` 未指定时默认为静态帧 |
| `--animate` | 每帧更新 Tiger 变换 |
| `--fps=N` / `--no-sync` | 显示同步目标帧率，或关闭同步等待 |
| `--pipeline` | 动画显示时启用多显示缓冲 pipeline |
| `--buffers=1..8` | 显示缓冲数量 |
| `--quality=high\|upper\|medium\|low` | path tessellation 质量 |
| `--cmd-buf-kb=N` | command buffer 大小，初始化前生效 |
| `--tess-width=N`、`--tess-height=N` | tessellation 尺寸 |
| `--no-upload` | 每帧内联 path 数据，用于对比 uploaded path |
| `--profile` | 输出 clear、draw、submit、finish、display 各阶段耗时 |
| `--trace`、`--trace-paths` | 输出运行或 path 级跟踪信息 |

`--pipeline` 仅能与 `--animate` 和显示输出同时使用。按 `Ctrl+C` 可结束持续显示。

## 性能和内存注意事项

- 静态或重复 path 应先 upload 并跨帧复用，避免每次复制 path 数据。
- 保持 path 的变换后边界紧凑；过大的 tessellation 区域会增加 tile stall。
- 多个 draw 合并到同一 batch，并用 `flush()`/`finish()` 明确同步点。
- VG-Lite 自有 buffer 为 uncached；映射外部 cacheable buffer 时仍会发生必要的
  cache clean/invalidate。
- 当前用户态 HAL 使用全局 context，不应由多个线程同时构建命令。

LVGL 的 GPU renderer 和图像转换路径见 [LVGL 示例](lvgl.md)。
