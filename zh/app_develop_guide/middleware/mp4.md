# MP4 Demo

## 简介

本示例介绍如何操作 MP4 文件。通过本示例，您将学习如何使用 API 接口实现 MP4 文件的复用（muxer）和解复用（demuxer）。此外，您还将了解如何在 K230 平台上采集摄像头视频和板载音频，录制 MP4 文件，以及解析 MP4 文件并通过视频输出（VO）显示画面和音频输出（AO）播放声音。

## 使用说明

### 代码位置

- 录制示例：canmv_k230/src/rtsmart/mpp/middleware/sample/sample_muxer
- 解复用示例：canmv_k230/src/rtsmart/mpp/middleware/sample/sample_demuxer
- 播放器示例：canmv_k230/src/rtsmart/mpp/middleware/sample/sample_player

假设 demo 已正确编译，启动开发板后进入 `/sdcard/app/middleware` 目录，依次运行相应的 demo 程序进行测试。

- 录制示例：运行 `sample_muxer.elf`
- 解复用示例：运行 `sample_demuxer.elf`
- 播放器示例：运行 `sample_player.elf`

## 示例

### 示例1: 录制 MP4 文件

该示例展示如何从摄像头捕获视频和音频，并生成 MP4 文件。视频编码格式为 H264，音频编码格式为 G711。执行以下命令开始录制：

```shell
./sample_muxer.elf -o test.mp4
```

录制过程中，按下 `Ctrl+C` 可以停止录制，生成的 MP4 文件将保存在当前目录下。

### 示例2: 解析 MP4 文件

该示例展示如何解析 MP4 文件，提取其中的音视频数据。执行以下命令开始解析：

```shell
./sample_demuxer.elf test.mp4
```

解析过程中，按下 `Ctrl+C` 可以停止解析，提取的音视频数据将保存到当前目录。

### 示例3: 播放 MP4 文件

该示例展示如何播放 MP4 文件，并选择输出设备（HDMI 或 LCD）。执行以下命令播放 MP4 文件：

```shell
./sample_player.elf test.mp4 1  # HDMI 输出
./sample_player.elf test.mp4 2  # LCD 输出
```

播放过程中，按下 `Ctrl+C` 可以停止播放，视频将显示在指定的输出设备上，音频将通过系统音频输出设备播放。

```{admonition} 提示
有关 mp4 模块的具体接口，请参考[API文档](../../api_reference/middleware/multimedia_middleware.md)
```
