# Nonai_csc Demo

## 简介

nonai_csc Demo 是一个集成了 色彩空间转换（CSC） 与 OSD（On-Screen Display）叠加 功能的示例程序。该 Demo 展示了如何通过 nonai_2d 模块对视频帧进行格式转换，并在编码前动态叠加 OSD 图形与边框，适用于需要实时视频处理、图形叠加和编码输出的嵌入式视觉应用场景。

## 功能说明

- 色彩空间转换（CSC）：支持将输入图像（如 RGB888、YUV420 等）转换为不同像素格式（如 RGB565、NV12 等），便于后续处理或显示。
- OSD 叠加：通过 VENC 模块的 2D 加速功能，在 H.265 编码流中插入 ARGB8888 格式的 OSD 图层，并可配置透明度、位置、背景色等参数。
- 边框绘制：支持在指定区域绘制彩色边框，用于高亮或标记特定区域。
- 多通道并行处理：Demo 中创建了多个 nonai_2d 通道，分别用于绑定通路、RGB888 转换、RGB565 转换，实现灵活的数据流处理。
- 视频采集 + 编码 + 显示一体化：集成 VICAP 视频采集、NONAI_2D 处理、VENC 编码、VO 显示模块，形成完整媒体处理链路。

## 代码位置

Demo 源码路径：
/src/rtsmart/examples/mpp/sample_csc

假设您已正确编译该 Demo。

启动开发板后，进入 /sdcard/app/examples/mpp 目录，可执行文件为：
sample_csc.elf

## 使用说明

输入参数如下：

| 参数名 | 描述 | 默认值 |
|--------|------|--------|
| -o     | 编码后的265文件 | -      |
| -vo     | 显示设备类型   | -      |

## 示例

./sample_csc.elf -o /data/test.265 -vo 101

运行后：

- 实时采集摄像头画面会在hdmi 上显示；
- 在编码流第 90 帧起动态更新 OSD 和边框位置；
- 同时将处理后的 RGB888 和 RGB565 帧保存为 /data/out_2d_rgb888.rgb 和 /data/out_2d_rgb565.rgb；
- 视频输出到指定显示屏；
- 按键盘 q 键退出程序。

## 查看结果

- 编码流：将生成的 .h265 文件导出至 PC，使用 VLC 或 Elecard StreamEye 等播放器查看，可观察 OSD 图标与边框。
![265](https://www.kendryte.com/api/post/attachment?id=828)
- RGB 输出文件：使用 Raw RGB 查看工具（如 YUVPlayer 支持 RGB 模式）加载 out_2d_rgb888.rgb（1280×720, RGB888）或 out_2d_rgb565.rgb（1280×720, RGB565）验证色彩转换结果。
![RGB565](https://www.kendryte.com/api/post/attachment?id=826)
![RGB888](https://www.kendryte.com/api/post/attachment?id=827)

```{admonition} 提示
有关 nonai_2d 模块的具体接口，请参考[API文档](../../api_reference/mpp/nonai_2d.md)
```
