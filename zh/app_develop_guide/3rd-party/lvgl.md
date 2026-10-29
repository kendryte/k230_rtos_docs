# LVGL 示例与 VG-Lite 加速

## 概述

K230 RT-Smart 集成 LVGL 9.4，并提供显示、触摸/HID、Sensor 图像和 K230 图像
格式转换适配。启用 VG-Lite renderer 后，LVGL 会把支持的 fill、border、shadow、
text、image、arc、line、layer、triangle 和 mask 任务提交给 K230 GPU，不支持的
任务仍由 software renderer 处理。

源码位置：

```text
src/rtsmart/libs/3rd-party/lvgl/
src/rtsmart/examples/3rd-party/lvgl/
```

当前示例包括：

| 示例 | 作用 |
| :-- | :-- |
| `lvgl_basic` | 显示常用控件，验证 connector、OSD layer、旋转和颜色格式 |
| `lvgl_hid` | 验证 USB HID 输入设备 |
| `lvgl_sensor` | 显示 Sensor 图像并叠加 LVGL UI |
| `lvgl_image_convert_test` | 验证 RVV 像素转换和 MPP CSC 图像转换 |

## 配置

在 `make menuconfig` 中启用：

```text
RTSMART_3RD_PARTY_ENABLE_LVGL=y
RTSMART_ENABLE_3RD_PARTY_EXAMPLES=y
RTSMART_3RD_PARTY_ENABLE_LVGL_SAMPLES=y
```

LVGL 颜色深度由 `RTSMART_3RD_PARTY_LVGL_COLOR_DEPTH` 对应的 choice 选择，支持
8、16、24 和 32 bit。VG-Lite 加速配置如下：

```text
RTSMART_3RD_PARTY_LVGL_USE_VGLITE=y
RTSMART_HAL_ENABLE_VG_LITE=y
RT_USING_VG_LITE=y
```

启用 `RTSMART_3RD_PARTY_LVGL_USE_VGLITE` 会自动选择用户态 VG-Lite HAL；内核
仍需包含 `RT_USING_VG_LITE`。默认 tessellation 尺寸为 1920 x 1080，可通过
`RTSMART_3RD_PARTY_LVGL_VGLITE_TESS_WIDTH` 和
`RTSMART_3RD_PARTY_LVGL_VGLITE_TESS_HEIGHT` 调整。

## 运行 lvgl_basic

先使用 `list_connector` 查询当前固件支持的 connector 类型，再运行：

```shell
lvgl_basic.elf -c <connector_type>
```

可选参数：

```text
-c, --connector <type>  connector 类型
-l, --layer <id>        OSD layer，默认 1
-f, --format <format>   l8、rgb565、rgb888 或 argb8888
-r, --rotate <deg>      0、90、180 或 270
-H, --help              显示帮助
```

示例会创建适配 connector 尺寸的 LVGL display，并显示 label、button、bar、slider
和 switch。按 `Ctrl+C` 退出时会释放 LVGL、显示和 VB 资源。

自定义界面继续使用标准 LVGL API：

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

K230 port 在 LVGL 初始化时创建 VG-Lite draw unit，并保留 software draw unit
作为 fallback。应用不需要把每个 LVGL 对象改写成 VG-Lite API，但应注意：

- draw buffer 必须能被 GPU 访问；K230 port 会为 LVGL 自有 buffer 使用合适的
  分配器；
- 来自 MPP/VB 的连续 buffer 需要先注册其虚拟地址、物理地址、大小、cache 属性
  和 pixel format；
- CPU 与 GPU 交替访问外部 cacheable buffer 时必须经过 port 的同步路径；
- 复杂 scene 应避免频繁强制 `vg_lite_finish()`，让多个 draw task 组成较大 batch。

底层驱动、原生 VG-Lite API 和 Tiger 性能示例见
[VG-Lite GPU 与示例](vglite.md)。

## 图像转换

K230 port 为 `lv_draw_buf_copy()` 提供分层转换路径：

1. 常见 packed LVGL format 之间优先使用 RVV；
1. MPP RGB/YUV buffer 转 LVGL buffer 时使用 MPP CSC，并根据条件组合 SDMA 或
   memcpy；
1. 不满足加速条件时回退到 scalar converter。

`lvgl_image_convert_test.elf` 覆盖以下范围：

- L8、A8、AL88、RGB565、RGB565 swapped、RGB888、XRGB8888；
- ARGB8888、premultiplied ARGB8888、ARGB1555、ARGB4444、ARGB2222、ARGB8565；
- MPP RGB/BGR packed format 和 NV12、NV21、I420。

运行完整测试：

```shell
lvgl_image_convert_test.elf
```

只运行一个 backend 集合或输出每个 case：

```shell
lvgl_image_convert_test.elf --rvv-only
lvgl_image_convert_test.elf --csc-only --verbose
```

程序最终输出 `Total: passed/total`，返回值为 0 表示全部通过。CSC 测试需要 MPP
VB 初始化成功；失败时应先检查 VB 配置和内存，而不是把所有失败归因于 LVGL。

## Sensor 和输入示例

`lvgl_sensor.elf` 演示 Sensor frame、LVGL draw buffer、GPU/CSC 转换和显示的
组合路径；`lvgl_hid.elf` 演示 USB HID 输入。运行前需确保目标 sensor、display、
touch 或 HID 驱动已包含在当前板级固件中。

## 常见问题

1. connector 初始化失败：使用 `list_connector` 核对枚举值和板级 panel 配置。
1. 界面显示但没有 GPU 加速：检查三个 VG-Lite 配置项和启动日志，software
   fallback 本身不会报错。
1. 外部图像花屏：核对物理地址、stride、pixel format、cache 属性和 buffer
   生命周期。
1. 转换测试只在 CSC case 失败：先确认 MPP VB pool 可用，以及 YUV plane 地址
   和 stride 符合格式要求。
