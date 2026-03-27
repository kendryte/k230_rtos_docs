# FFmpeg

## 简介

FFmpeg是一个开源的跨平台多媒体框架，提供了录制、转换和流式音视频的完整解决方案。K230 RTOS SDK集成了FFmpeg库，支持在K230平台上进行多媒体处理。

## 功能说明

### FFmpeg特性

FFmpeg包含以下主要组件：

- **libavcodec**：音视频编解码器库
- **libavformat**：音视频格式封装/解封装库
- **libavutil**：工具函数库
- **libswscale**：图像缩放和颜色空间转换库
- **libswresample**：音频重采样库
- **libavfilter**：音视频滤镜库

### 支持的编解码器

FFmpeg支持大量的编解码器，包括：

- **视频编解码器**：H.264、H.265、MPEG-2、MPEG-4、VP8、VP9等
- **音频编解码器**：AAC、MP3、Opus、Vorbis、FLAC等
- **图像编解码器**：JPEG、PNG、GIF、BMP等

### 支持的格式

FFmpeg支持多种容器格式：

- **视频格式**：MP4、MKV、AVI、MOV、FLV等
- **音频格式**：MP3、AAC、FLAC、OGG等
- **流媒体协议**：RTSP、RTMP、HTTP、HLS、DASH等

## 应用场景

FFmpeg 功能虽强，但多数功能依托 CPU 实现；在 K230 平台中，项目以 MPP API 为核心完成音视频编解码,格式转换等多媒体核心功能，仅通过 FFmpeg 辅助实现 MPP 不支持的能力，如 MP4 封解封装、RTSP 推拉流等操作。

K230 平台下，基于 FFmpeg 封装实现的 RTSP 推流接口位于 `/src/rtsmart/mpp/middleware/src/rtsp_pusher`，其配套演示 Demo 对应路径为 `/src/rtsmart/examples/mpp/sample_rtsppusher`。

## 编译说明

### FFmpeg库集成

K230 RTOS SDK已经预编译了FFmpeg库，位于SDK的库目录下。用户可以直接链接使用这些库。

### 链接FFmpeg库

在Makefile或CMake中添加FFmpeg库链接：

```makefile
# Makefile示例
LDFLAGS += -lavcodec -lavformat -lavutil -lswscale -lm
```

```cmake
# CMake示例
target_link_libraries(your_target
    avcodec
    avformat
    avutil
    swscale
    m
)
```

## 使用说明

### 基本使用流程

#### 1. 注册所有编解码器和格式

```c
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>

av_register_all();
```

#### 2. 打开输入文件

```c
AVFormatContext *pFormatCtx = avformat_alloc_context();
avformat_open_input(&pFormatCtx, filename, NULL, NULL);
avformat_find_stream_info(pFormatCtx, NULL);
```

#### 3. 查找视频流

```c
int video_index = -1;
for (int i = 0; i < pFormatCtx->nb_streams; i++) {
    if (pFormatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
        video_index = i;
        break;
    }
}
```

#### 4. 创建解码器上下文

```c
AVCodecParameters *codecPar = pFormatCtx->streams[video_index]->codecpar;
AVCodec *pCodec = avcodec_find_decoder(codecPar->codec_id);
AVCodecContext *pCodecCtx = avcodec_alloc_context3(pCodec);
avcodec_parameters_to_context(pCodecCtx, codecPar);
avcodec_open2(pCodecCtx, pCodec, NULL);
```

#### 5. 读取并解码视频帧

```c
AVPacket *packet = av_packet_alloc();
AVFrame *frame = av_frame_alloc();

while (av_read_frame(pFormatCtx, packet) >= 0) {
    if (packet->stream_index == video_index) {
        avcodec_send_packet(pCodecCtx, packet);
        while (avcodec_receive_frame(pCodecCtx, frame) == 0) {
            // 处理解码后的帧
        }
    }
    av_packet_unref(packet);
}
```

#### 6. 释放资源

```c
av_frame_free(&frame);
av_packet_free(&packet);
avcodec_free_context(&pCodecCtx);
avformat_close_input(&pFormatCtx);
```

```{admonition} 提示
FFmpeg是一个功能强大的多媒体框架，API相对复杂。建议先阅读FFmpeg官方文档和示例代码。有关 FFmpeg 的详细API，请参考 [FFmpeg官方文档](https://ffmpeg.org/documentation.html)。
```

```{admonition} 提示
在K230平台上使用FFmpeg进行视频解码时，可以考虑与K230的硬件编解码器（VDEC/VENC）配合使用，以提高性能。
```
