# FFmpeg

## Introduction

FFmpeg is an open-source cross-platform multimedia framework that provides a complete solution for recording, converting, and streaming audio and video. The K230 RTOS SDK integrates the FFmpeg library to support multimedia processing on the K230 platform.

## Features

### FFmpeg Features

FFmpeg contains the following main components:

- **libavcodec**: Audio and video codec library
- **libavformat**: Audio and video format muxing/demuxing library
- **libavutil**: Utility function library
- **libswscale**: Image scaling and color space conversion library
- **libswresample**: Audio resampling library
- **libavfilter**: Audio and video filter library

### Supported Codecs

FFmpeg supports a large number of codecs, including:

- **Video codecs**: H.264, H.265, MPEG-2, MPEG-4, VP8, VP9, etc.
- **Audio codecs**: AAC, MP3, Opus, Vorbis, FLAC, etc.
- **Image codecs**: JPEG, PNG, GIF, BMP, etc.

### Supported Formats

FFmpeg supports a variety of container formats:

- **Video formats**: MP4, MKV, AVI, MOV, FLV, etc.
- **Audio formats**: MP3, AAC, FLAC, OGG, etc.
- **Streaming protocols**: RTSP, RTMP, HTTP, HLS, DASH, etc.

## Application Scenarios

Although FFmpeg is powerful, most of its functionality relies on the CPU; in the K230 platform, the project uses the MPP API as the core to complete multimedia core functions such as audio/video encoding and decoding, format conversion, etc., and only uses FFmpeg to assist in implementing capabilities not supported by MPP, such as MP4 muxing/demuxing, RTSP pushing and pulling operations.

On the K230 platform, the RTSP push stream interface implemented based on FFmpeg encapsulation is located at `/src/rtsmart/mpp/middleware/src/rtsmart/middleware/src/rtsp_pusher`, and its accompanying demo corresponds to the path `/src/rtsmart/examples/mpp/sample_rtsppusher`.

## Build Instructions

### FFmpeg Library Integration

The K230 RTOS SDK has pre-compiled FFmpeg libraries located in the SDK's library directory. Users can directly link and use these libraries.

### Linking FFmpeg Library

Add FFmpeg library linking in the Makefile or CMake:

```makefile
# Makefile example
LDFLAGS += -lavcodec -lavformat -lavutil -lswscale -lm
```

```cmake
# CMake example
target_link_libraries(your_target
    avcodec
    avformat
    avutil
    swscale
    m
)
```

## Usage Instructions

### Basic Usage Flow

#### 1. Register all codecs and formats

```c
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>

av_register_all();
```

#### 2. Open input file

```c
AVFormatContext *pFormatCtx = avformat_alloc_context();
avformat_open_input(&pFormatCtx, filename, NULL, NULL);
avformat_find_stream_info(pFormatCtx, NULL);
```

#### 3. Find video stream

```c
int video_index = -1;
for (int i = 0; i < pFormatCtx->nb_streams; i++) {
    if (pFormatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
        video_index = i;
        break;
    }
}
```

#### 4. Create decoder context

```c
AVCodecParameters *codecPar = pFormatCtx->streams[video_index]->codecpar;
AVCodec *pCodec = avcodec_find_decoder(codecPar->codec_id);
AVCodecContext *pCodecCtx = avcodec_alloc_context3(pCodec);
avcodec_parameters_to_context(pCodecCtx, codecPar);
avcodec_open2(pCodecCtx, pCodec, NULL);
```

#### 5. Read and decode video frames

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

#### 6. Release resources

```c
av_frame_free(&frame);
av_packet_free(&packet);
avcodec_free_context(&pCodecCtx);
avformat_close_input(&pFormatCtx);
```

```{admonition} Tip
FFmpeg is a powerful multimedia framework with a relatively complex API. It is recommended to first read the FFmpeg official documentation and example code. For detailed FFmpeg API, please refer to [FFmpeg Official Documentation](https://ffmpeg.org/documentation.html).
```

```{admonition} Tip
When using FFmpeg for video decoding on the K230 platform, consider using it together with the K230 hardware codecs (VDEC/VENC) to improve performance.
```
