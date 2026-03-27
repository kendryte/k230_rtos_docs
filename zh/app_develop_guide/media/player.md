# 播放器示例

## 简介

本示例演示了如何使用K230的播放器模块。播放器模块是一个高级封装，提供了便捷的音视频播放功能。

## 功能说明

### 播放器功能

本示例展示了播放器的使用方法：

- **视频播放**：支持播放视频文件
- **音频播放**：支持播放音频文件
- **音视频同步**：自动同步音视频
- **多种输出设备**：支持HDMI、LCD等输出设备
- **事件回调**：支持播放事件通知

### 支持的格式

- **文件格式**：MP4
- **编解码器**：H.264、H.265、G711、OPUS等

### 主要接口

- `kd_player_init()` - 初始化播放器
- `kd_player_deinit()` - 反初始化播放器
- `kd_player_start()` - 开始播放
- `kd_player_stop()` - 停止播放
- `kd_player_pause()` - 暂停播放
- `kd_player_resume()` - 恢复播放
- `kd_player_register_event_cb()` - 注册事件回调

### 播放器事件

| 事件 | 说明 |
|------|------|
| K_PLAYER_EVENT_EOF | 播放结束 |
| K_PLAYER_EVENT_ERROR | 播放错误 |

## 代码位置

Demo 源码位置：`src/rtsmart/examples/mpp/sample_player`

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将播放器示例编译进固件，然后编译固件。

### 运行示例

```shell
./sample_player.elf <file_path> <connect_type>
```

### 参数说明

| 参数名 | 说明 |
|--------|------|
| file_path | 要播放的mp4文件路径 |
| connect_type | 连接类型，如LCD(20), HDMI(101) |

### 查看结果

程序运行后会：

1. 初始化播放器
1. 打开媒体文件
1. 解析音视频流
1. 开始播放
1. 显示播放进度信息
1. 播放结束后自动退出

输出示例：

```text
./sample_player.elf ./test_800x480.mp4 20
file pathname:./test_800x480.mp4
connector type:20
video track info:type:96,track_id:1,width:800,height:480
input_pool_id 0
output_pool_id 1
VDEC: pool_id 1, frame_buf_pool_id 1
sample_vo_init>vo init width 800 height 480
sample_vo_init: layer_id 1, width 800, height 480, pixel_format 31, func 2,buf_nr:3
VDEC: first pts 5940, frame_interval 0
VDEC: first pts 5940, frame_interval 12060
kd_mp4_get_frame: demuxer has finished.
demuxer finished.
5941 pictures decoded. Average FrameRate = 99 Fps
vpu report fps 99
disp_play>ch 0, receive eos
vpu_exit>q_wm 16
```

```{admonition} 提示
播放器模块基于K230的多媒体管道（MPP）和编解码器实现，提供了比直接使用MPI更简单的接口。有关播放器模块的具体接口，请参考 [多媒体中间件 API 文档](../../api_reference/middleware/multimedia_middleware.md)。
```
