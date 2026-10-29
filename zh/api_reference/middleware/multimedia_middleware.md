# 多媒体中间件API手册

## 概述

### 概述

本文档旨在为开发者提供 K230 多媒体中间件的详细信息，包括各模块的 API 接口、头文件及使用说明。该中间件涵盖 RTSP 服务器、RTSP 客户端、RTSP 推流器、媒体播放器、MP4 格式封装与解封装、Ogg 格式封装解封装以及 WebRTC 实时通信等多个功能模块，有助于开发者深入了解其应用场景与工作原理。请注意，本指南可能会不定期更新，建议开发者始终参考最新版本的文档。

中间件代码位于系统路径`src/rtsmart/mpp/middleware`，其中`src/rtsmart/mpp/middleware/src`目录包含多媒体封装的API接口，`src/rtsmart/examples/mpp`目录包含使用这些API接口的示例代码。

本文档提供了每个模块的API接口的详细描述和示例，帮助用户更好地理解和使用不同模块的API。

### 模块列表

| 模块 | 功能说明 |
|---|---|
| rtsp-server | RTSP服务端，将板端音视频数据以RTSP协议发送给客户端 |
| rtsp-client | RTSP客户端，从RTSP服务器获取音视频数据 |
| rtsp-pusher | RTSP推流器，将板端视频数据推送到第三方流媒体服务器 |
| 播放器 | MP4文件播放，视频支持H264/H265，音频支持G711a/u/OPUS |
| MP4封装解封装 | 音视频与MP4格式间的封装与解封装 |
| Ogg封装解封装 | 音频与Ogg格式间的封装与解封装 |
| WebRTC | 基于WebRTC协议的点对点实时音视频及数据通道通信 |

### 功能描述

#### rtsp server

rtsp-server支持将板子上的音频和视频数据以rtsp server协议发送给rtsp client客户端。

常用的使用场景有：

- 实时音视频传输：通过rtsp server将板子上的音频和视频数据实时传输给rtsp client客户端。
- 多媒体流媒体服务：搭建一个rtsp server，提供音视频流媒体服务，供客户端进行播放和访问。
- 远程监控：将板子上的音视频数据以rtsp server协议发送给远程客户端，实现远程监控功能。

#### rtsp client

rtsp-client支持板子使用rtsp客户端协议从rtsp服务器获取音频和视频数据。

常用的使用场景有：

- 实时监控系统：通过rtsp-client从rtsp服务器获取实时的音频和视频数据，用于监控和录制。
- 多媒体播放器：使用rtsp-client从rtsp服务器获取音频和视频数据，用于播放多媒体内容。
- 视频会议系统：通过rtsp-client从rtsp服务器获取音频和视频数据，用于实现视频会议功能。

#### rtsp pusher

实现将板子上的视频数据以RTSP协议推送到第三方流媒体服务器，客户端可以通过第三方流媒体服务器获取板子推送的视频数据。

常用的使用场景有：

- 视频监控系统：将板子上的视频数据推送到流媒体服务器，供监控客户端实时查看。
- 视频直播：将板子上的视频数据推送到流媒体服务器，供观众通过流媒体服务器观看直播。
- 视频录制：将板子上的视频数据推送到流媒体服务器，实现视频录制功能。
- 视频分发：将板子上的视频数据推送到流媒体服务器，供多个客户端同时获取视频数据。

#### 播放器

实现mp4文件播放。视频支持h264、h265，音频支持g711a/u/opus。

#### MP4格式封装解封装

实现音视频与mp4格式间的封装与解封装。

#### WebRTC

WebRTC（Web Real-Time Communication）模块基于 libpeer 提供点对点实时传输和可选 DataChannel。它负责 ICE、SDP、DTLS-SRTP、RTP/RTCP 和 SCTP；应用负责音视频采集、编码和信令。当前视频 RTP 支持 H.264、H.265，音频 RTP 支持 Opus、PCMA、PCMU。`sample_webrtc` 提供 H.265/H.264 的局域网视频示例，默认不启用音频和 DataChannel。

常用的使用场景有：

- 实时音视频通话：通过WebRTC协议实现板端与浏览器或其他WebRTC终端之间的点对点音视频通话。
- 远程监控：将板端摄像头采集的视频数据通过WebRTC实时传输给远程浏览器客户端查看。
- 数据通道通信：利用WebRTC DataChannel在板端与对端之间传输自定义数据（如传感器数据、控制指令等）。
- 低延迟流媒体：相比RTSP等协议，WebRTC提供更低的端到端延迟，适合对实时性要求较高的场景。

#### 其他

本文档包含了K230中间件的API参考，其中包括了live555和ffmpeg开源多媒体库的集成。用户可以根据自己的需求，利用这些库提供的强大功能来实现多媒体处理和传输。

## API参考

### rtsp-server

KdRtspServer提供以下API：

- [Init](#kdrtspserverinit)：初始化。
- [DeInit](#kdrtspserverdeinit)：反初始化。
- [CreateSession](#kdrtspservercreatesession)：创建rtsp session。
- [DestroySession](#kdrtspserverdestroysession)：销毁rtsp session。
- [Start](#kdrtspserverstart)：开启rtsp-server服务。
- [Stop](#kdrtspserverstop)：停止rtsp-server服务。
- [SendVideoData](#kdrtspserversendvideodata)：写入视频码流数据。
- [SendAudioData](#kdrtspserversendaudiodata)：写入音频码流数据。

#### KdRtspServer::Init

【描述】

rtsp-server初始化。

【语法】

```c
int Init(Port port = 8554, IOnBackChannel *back_channel = nullptr);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| port  | rtsp服务端口。 | 输入      |
| back_channel     | 对端来的音频数据回调指针。   | 输入      |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0      | 成功。                        |
| 非0    | 失败。                        |

【需求】

- 头文件：rtsp_server.h
- 库文件：librtsp_server.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### KdRtspServer::DeInit

【描述】

反初始化。

【语法】

```c
void DeInit();
```

【参数】

无。

【返回值】

无。

【需求】

- 头文件：rtsp_server.h
- 库文件：librtsp_server.a

【举例】

无。

#### KdRtspServer::CreateSession

【描述】

创建RtspSession。

【语法】

```c
int CreateSession(const std::string &session_name, const SessionAttr &session_attr);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| session_name | stream url。 | 输入 |
| session_attr | session 配置参数。 | 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_server.h
- 库文件：librtsp_server.a

【注意】

【举例】

无。

#### KdRtspServer::DestroySession

【描述】

销毁rtsp session。

【语法】

```c
int DestroySession(const std::string &session_name);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| session_name | stream url。| 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_server.h
- 库文件：librtsp_server.a

【注意】

【举例】

无。

【相关主题】

#### KdRtspServer::Start

【描述】

开启rtsp server服务。

【语法】

```c
void Start();
```

【参数】

无。

【返回值】

无。

【需求】

- 头文件：rtsp-server.h
- 库文件：librtsp_server.a

【注意】
无

【举例】

无。

【相关主题】

#### KdRtspServer::Stop

【描述】

停止rtsp-server服务。

【语法】

```c
void Stop();
```

【参数】

无

【返回值】

无

【需求】

- 头文件：rtsp_server.h
- 库文件：librtsp_server.a

【注意】

【举例】

无。

#### KdRtspServer::SendVideoData

【描述】

写入视频码流数据。

【语法】

```c
int SendVideoData(const std::string &session_name, const uint8_t *data, size_t size, uint64_t timestamp);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| session_name  | stream url | 输入 |
| data   | 视频码流地址。 | 输入 |
| size   | 视频码流大小。 | 输入 |
| timestamp   | 码流时间戳（毫秒） | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_server.h
- 库文件：librtsp_server.a

【举例】

无。

#### KdRtspServer::SendAudioData

【描述】

写入音频码流数据。

【语法】

```c
int SendAudioData(const std::string &session_name, const uint8_t *data, size_t size, uint64_t timestamp);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| session_name  | stream url | 输入 |
| data   | 音频码流地址。 | 输入 |
| size   | 音频码流大小。 | 输入 |
| timestamp   | 码流时间戳（毫秒） | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0      | 成功。                        |
| 非0    | 失败。  |

【需求】

- 头文件：rtsp_server.h
- 库文件：librtsp_server.a

【举例】

无。

### rtsp-client

KdRtspClient模块提供以下API：

- [Init](#kdrtspclientinit)：初始化。
- [DeInit](#kdrtspclientdeinit)：反初始化。
- [Open](#kdrtspclientopen)：打开并运行rtspclient连接。
- [Close](#kdrtspclientclose)：关闭rtspclient连接。
- [SendAudioData](#kdrtspclientsendaudiodata)：写入backchannel音频码流数据。

#### KdRtspClient::Init

【描述】

初始化

【语法】

```c
int Init(const RtspClientInitParam &param);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| param  | rtspclient初始化参数 | 输入 |

```c
    class IOnAudioData {
    public:
        virtual ~IOnAudioData() {}
        virtual void OnAudioData(const uint8_t *data, size_t size, uint64_t timestamp) = 0;
    };

    class IOnVideoData {
    public:
        enum VideoType {VideoTypeInvalid, VideoTypeH264, VideoTypeH265};
        virtual ~IOnVideoData() {}
        virtual void OnVideoType(VideoType type, uint8_t *extra_data, size_t extra_data_size) = 0;
        virtual void OnVideoData(const uint8_t *data, size_t size, uint64_t timestamp, bool keyframe) = 0;
    };

    class IRtspClientEvent {
    public:
        virtual ~IRtspClientEvent() {}
        virtual void OnRtspClientEvent(int event) = 0; // event 0: shutdown
    };

    struct RtspClientInitParam {
        IOnVideoData *on_video_data{nullptr}; // 从server侧收到的视频码流帧回调
        IOnAudioData *on_audio_data{nullptr}; // 从server侧收到的音频码流帧回调
        IRtspClientEvent *on_event{nullptr};  // rtspclient event回调
        bool enableBackchanel{false};         // 是否enable audio backchannel
    };
```

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_client.h
- 库文件：librtsp_client.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### KdRtspClient::Deinit

【描述】

反初始化。

【语法】

void DeInit();

【参数】

无。

【返回值】

无。

【需求】

- 头文件：rtsp_client.h
- 库文件：librtsp_client.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### KdRtspClient::Open

【描述】

打开并运行rtspclient连接

【语法】

```c
int Open(const char *url);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| url  | rtsp url。 | 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_client.h
- 库文件: librtsp_client.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### KdRtspClient::Close

【描述】

关闭rtsp client。

【语法】

```c
void Close();
```

【参数】

【返回值】

【需求】

- 头文件：rtsp_client.h
- 库文件: librtsp_client.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### KdRtspClient::SendAudioData

【描述】

写入音频back channnel码流数据。

【语法】

```c
int SendAudioData(const uint8_t *data, size_t size, uint64_t timestamp);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| data  | 音频码流数据地址 | 输入 |
| size  | 音频码流数据大小 | 输出 |
| timestamp | 音频码流数据时间戳（毫秒） | 输出 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_client.h
- 库文件：librtsp_client.a

【注意】

无。

【举例】

无。

【相关主题】

无。

### 播放器封装

KdPlayer模块提供以下API：

- [kd_player_init](#kd_player_init)：初始化。
- [kd_player_deinit](#kd_player_deinit)：反初始化。
- [kd_player_setdatasource](#kd_player_setdatasource)：设置媒体播放文件。
- [kd_player_regcallback](#kd_player_regcallback)：注册事件回调。
- [kd_player_start](#kd_player_start)：开始播放。
- [kd_player_stop](#kd_player_stop)：停止播放。

#### kd_player_init

【描述】

播放器初始化。

【语法】

```c
k_s32 kd_player_init();
```

【参数】

无

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 源码位置：src/rtsmart/examples/mpp/sample_player（直接编译进 sample_player 示例，不再作为独立库打包）

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_player_deinit

【描述】

反初始化。

【语法】

```c
k_s32 kd_player_deinit();
```

【参数】

无

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 源码位置：src/rtsmart/examples/mpp/sample_player（直接编译进 sample_player 示例，不再作为独立库打包）

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_player_setdatasource

【描述】

反初始化。

【语法】

```c
k_s32 kd_player_setdatasource(const k_char* filePath);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| filePath  | 媒体文件路径 | 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 源码位置：src/rtsmart/examples/mpp/sample_player（直接编译进 sample_player 示例，不再作为独立库打包）

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_player_regcallback

【描述】

注册播放器事件回调。

【语法】

```c
k_s32 kd_player_regcallback( K_PLAYER_EVENT_FN pfnCallback,void* pData);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pfnCallback  | 回调函数指针 | 输入 |
| pData  | 回调数据指针 | 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 源码位置：src/rtsmart/examples/mpp/sample_player（直接编译进 sample_player 示例，不再作为独立库打包）

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_player_start

【描述】

开始播放。

【语法】

```c
k_s32 kd_player_start();
```

【参数】

无

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 源码位置：src/rtsmart/examples/mpp/sample_player（直接编译进 sample_player 示例，不再作为独立库打包）

【注意】

无。

【举例】

无。

【相关主题】

无。

#### kd_player_stop

【描述】

停止播放。

【语法】

```c
k_s32 kd_player_stop();
```

【参数】

无

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 源码位置：src/rtsmart/examples/mpp/sample_player（直接编译进 sample_player 示例，不再作为独立库打包）

【注意】

无。

【举例】

无。

【相关主题】

无。

### MP4格式封装解封装

MP4格式封装解封装提供如下API：

- [kd_mp4_create](#kd_mp4_create)：MP4实例创建
- [kd_mp4_destroy](#kd_mp4_destroy)：MP4实例销毁
- [kd_mp4_create_track](#kd_mp4_create_track)：为MP4创建track
- [kd_mp4_destroy_tracks](#kd_mp4_destroy_tracks)：为MP4销毁所有track
- [kd_mp4_write_frame](#kd_mp4_write_frame)：MP4中写入帧数据。
- [kd_mp4_get_file_info](#kd_mp4_get_file_info)：获取MP4文件信息。
- [kd_mp4_get_track_by_index](#kd_mp4_get_track_by_index)：根据下标获取track信息。
- [kd_mp4_get_frame](#kd_mp4_get_frame)：获取track码流信息。

#### kd_mp4_create

【描述】

MP4实例创建

【语法】

```c
int kd_mp4_create(KD_HANDLE *mp4_handle, k_mp4_config_s *mp4_cfg);
```

【参数】

|     参数   |     描述    |   输入/输出   |
|------------|------------|--------------|
| mp4_handle | MP4实例句柄 |     输出     |
| mp4_cfg    | 参数配置信息 |     输入     |

【返回值】

|  返回值  |   描述  |
|----------|--------|
|    0     |  成功  |
|   非0    |  失败  |

【需求】

- 头文件：mp4_format.h
- 库文件：libmp4_format.a

【注意】

通过mp4_cfg配置信息可以指定当前创建的MP4实例时muxer实例或者demuxer实例

【举例】

参考 samples下 mp4_muxer和mp4_demuxer

【相关主题】

无

#### kd_mp4_destroy

【描述】

MP4实例销毁

【语法】

```c
int kd_mp4_destroy(KD_HANDLE mp4_handle);
```

【参数】

|    参数    |    描述    |    输入/输出    |
|------------|------------|----------------|
| mp4_handle | MP4实例句柄 |     输入       |

【返回值】

|    返回值    |    描述    |
|--------------|-----------|
|      0       |    成功    |
|     非0      |    失败     |

【需求】

- 头文件：mp4_format.h
- 库文件：libmp4_format.a

【注意】

无

【举例】

参考 samples下 mp4_muxer和mp4_demuxer

【相关主题】

无

#### kd_mp4_create_track

【描述】

为MP4创建track

【语法】

```c
int kd_mp4_create_track(KD_HANDLE mp4_handle, KD_HANDLE *track_handle, k_mp4_track_info_s *mp4_track_info);
```

【参数】

|    参数    |    描述    |    输入/输出    |
|------------|------------|----------------|
| mp4_handle | MP4实例句柄 |    输入        |
|track_handle| track句柄   |    输出        |
|mp4_track_info| track配置 |    输入        |

【返回值】

|    返回值   |    描述    |
|-------------|------------|
|     0       |    成功     |
|    非0      |    失败     |

【需求】

- 头文件：mp4_format.h
- 库文件：libmp4_format.a

【注意】

- 该API为muxer API，当创建的MP4实例为muxer实例时使用
- 目前每个MP4支持创建最多3个track

【举例】

参考 samples下 mp4_muxer

【相关主题】

无

#### kd_mp4_destroy_tracks

【描述】

为MP4销毁所有track

【语法】

```c
int kd_mp4_destroy_tracks(KD_HANDLE mp4_handle);
```

【参数】

|    参数    |    描述    |    输入/输出    |
|------------|------------|----------------|
| mp4_handle |  MP4实例   |   输入          |

【返回值】

|    返回值    |    描述    |
|--------------|-----------|
|     0        |   成功     |
|    非0       |   失败     |

【需求】

- 头文件：mp4_format.h
- 库文件：libmp4_format.a

【注意】

- 该API为muxer API，当创建的MP4实例为muxer实例时使用
- 请在创建MP4实例和track之后调用该接口

【举例】

参考 samples下 mp4_muxer

【相关主题】

无

#### kd_mp4_write_frame

【描述】

MP4中写入帧数据

【语法】

```c
int kd_mp4_write_frame(KD_HANDLE mp4_handle, KD_HANDLE track_handle, k_mp4_frame_data_s *frame_data);
```

【参数】

|    参数    |    描述    |    输入/输出    |
|------------|------------|----------------|
|  mp4_handle| MP4实例句柄 |  输入          |
| track_handle| track句柄  |  输入          |
| frame_data  |  帧数据信息 |  输入         |

【返回值】

|    返回值    |    描述    |
|--------------|-----------|
|      0       |    成功    |
|     非0      |    失败    |

【需求】

- 头文件：mp4_format.h
- 库文件：libmp4_format.a

【注意】

- 该API为muxer API，当创建的MP4实例为muxer实例时使用
- 请在创建MP4实例和track之后调用该接口
- frame_data->time_stamp 单位为微秒

【举例】

参考 samples下 mp4_muxer

【相关主题】

无

#### kd_mp4_get_file_info

【描述】

获取MP4文件信息

【语法】

```c
int kd_mp4_get_file_info(KD_HANDLE mp4_handle, k_mp4_file_info_s *file_info);
```

【参数】

|    参数    |    描述    |    输入/输出    |
|------------|------------|----------------|
| mp4_handle | MP4实例句柄 |   输入         |
| file_info  | MP4文件信息 |   输出         |

【返回值】

|    返回值    |    描述    |
|--------------|-----------|
|      0       |    成功    |
|     非0      |    失败    |

【需求】

- 头文件：mp4_format.h
- 库文件：libmp4_format.a

【注意】

- 该API为demuxer API，当创建的MP4实例为demuxer实例时使用

【举例】

参考 samples下 mp4_demuxer

【相关主题】

无

#### kd_mp4_get_track_by_index

【描述】

根据下标获取track信息

【语法】

```c
int kd_mp4_get_track_by_index(KD_HANDLE mp4_handle, uint32_t index, k_mp4_track_info_s *mp4_track_info);
```

【参数】

|    参数    |    描述    |    输入/输出    |
|------------|------------|----------------|
| mp4_handle | MP4实例句柄|   输入          |
|   index    |   下标     |   输入          |
| mp4_track_info | track信息 | 输出         |

【返回值】

|    返回值    |    描述    |
|--------------|------------|
|      0       |    成功     |
|     非0      |    失败     |

【需求】

- 头文件：mp4_format.h
- 库文件：libmp4_format.a

【注意】

- 该API为demuxer API，当创建的MP4实例为demuxer实例时使用

【举例】

参考 samples下 mp4_demuxer

【相关主题】

无

#### kd_mp4_get_frame

【描述】

获取track码流信息

【语法】

```c
int kd_mp4_get_frame(KD_HANDLE mp4_handle, k_mp4_frame_data_s *frame_data);
```

【参数】

|    参数    |    描述    |    输入/输出    |
|------------|------------|----------------|
| mp4_handle |  MP4实例句柄|    输入        |
| frame_data |  码流信息   |    输出        |

【返回值】

|    返回值    |    描述    |
|--------------|-----------|
|      0       |   成功     |
|     非0      |   失败     |

【需求】

- 头文件：mp4_format.h
- 库文件：libmp4_format.a

【注意】

- 该API为demuxer API，当创建的MP4实例为demuxer实例时使用
- frame_data->time_stamp 单位为微秒

【举例】

参考 samples下 mp4_demuxer

【相关主题】

无

### rtsp pusher

rtsp推流提供如下API：

- [Init](#kdrtsppusherinit)：初始化。
- [DeInit](#kdrtsppusherdeinit)：反初始化。
- [Open](#kdrtsppusheropen)：与流媒体服务器建立rtsp推流连接。
- [Close](#kdrtsppusherclose)：关闭流媒体服务器连接。
- [PushVideoData](#kdrtsppusherpushvideodata)：推送视频数据到流媒体。

#### KdRtspPusher::Init

【描述】

初始化

【语法】

```c
int Init(const RtspPusherInitParam &param);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| param  | rtsppusher初始化参数 | 输入 |

```c
class IRtspPusherEvent {
  public:
    virtual ~IRtspPusherEvent() {}
    virtual void OnRtspPushEvent(int event) = 0; // event 0: connect  ok; event 1:disconnet ;   event 2:reconnect ok
};

struct RtspPusherInitParam {
    int video_width;
    int video_height;
    char sRtspUrl[256];
    IRtspPusherEvent *on_event{nullptr};
};
```

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_pusher.h
- 库文件：librtsp_pusher.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### KdRtspPusher::Deinit

【描述】

反初始化。

【语法】

void DeInit();

【参数】

无。

【返回值】

无。

【需求】

- 头文件：rtsp_pusher.h
- 库文件：librtsp_pusher.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### KdRtspPusher::Open

【描述】

与流媒体服务器建立rtsp推流连接。

【语法】

int Open();

【参数】

无。

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_pusher.h
- 库文件：librtsp_pusher.a

【注意】

无。

【举例】

无。

【相关主题】

无。

#### KdRtspPusher::Close

【描述】

关闭流媒体服务器连接。

【语法】

void Close();

【参数】

【返回值】

【需求】

- 头文件：rtsp_pusher.h
- 库文件：librtsp_pusher.a

【注意】

无。

【举例】

无。
【相关主题】

无。

#### KdRtspPusher::PushVideoData

【描述】

推送视频数据到流媒体。

【语法】

int  PushVideoData(const uint8_t *data, size_t size, bool key_frame,uint64_t timestamp);

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| data  | 视频码流数据地址 | 输入 |
| size  | 视频码流数据大小 | 输入 |
| key_frame  | 是否是关键帧 | 输入 |
| timestamp | 视频码流数据时间戳（微秒） | 输入 |

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：rtsp_pusher.h
- 库文件：librtsp_pusher.a

【注意】

当前版本只支持264编码推流。

【举例】

无。

【相关主题】

无。

### ogg

本模块提供对 Ogg 容器格式的支持，可用于音频数据的封装（muxing）与解封装（demuxing）。适用于需要将原始音频帧打包为 Ogg 文件/流，或从 Ogg 数据中提取音频帧的场景。
Ogg Muxer（封装器）
[kd_ogg_muxer_init](#kd_ogg_muxer_init)：初始化 Ogg 封装器实例。
[kd_ogg_write_frame](#kd_ogg_write_frame)：向 Ogg 封装器写入一帧音频数据。
[kd_ogg_write_frame_ex](#kd_ogg_write_frame_ex)：扩展版本，支持获取生成的 Ogg 页面数据。
[kd_ogg_muxer_destroy](#kd_ogg_muxer_destroy)：销毁 Ogg 封装器实例并释放资源。
Ogg Demuxer（解封装器）
[kd_ogg_demuxer_init](#kd_ogg_demuxer_init)：初始化 Ogg 解封装器实例。
[kd_ogg_demuxer_feed_page](#kd_ogg_demuxer_feed_page)：向解封装器输入一个完整的 Ogg 页面数据（用于流模式）。
[kd_ogg_demuxer_feed_page_ex](#kd_ogg_demuxer_feed_page_ex)：扩展版本，支持从页面中提取原始帧数据到指定缓冲区。
[kd_ogg_demuxer_destroy](#kd_ogg_demuxer_destroy)：销毁 Ogg 解封装器实例。

#### 功能描述

- **Ogg Muxer（封装器）**：将原始音频帧（如 Opus 编码格式）按 Ogg 容器规范封装为 Ogg 页面（page），支持写入文件或通过回调输出到内存/网络流。
- **Ogg Demuxer（解封装器）**：从 Ogg 文件或流中解析出音频帧数据，并通过回调通知上层应用。

当前实现不绑定具体音频编码（如 Opus），仅处理 Ogg 容器层。音频编码/解码需由上层负责。

#### 使用场景

- 音频录制并保存为 Ogg 格式文件；
- 通过 RTSP 或自定义协议传输 Ogg 封装的音频流；
- 从 Ogg 文件中提取原始音频帧用于播放或分析；
- 与 WebRTC、VoIP 等系统集成，处理 Ogg 封装的音频数据。
- 采用 Ogg 搭配 Opus 编码的格式，承载语音 ASR 输入数据的存储与流传输、TTS 输出数据的封装与分发，适配实时语音交互场景。

#### API 参考

##### 类型定义

```c
typedef void kd_ogg_muxer;
typedef void kd_ogg_demuxer;
```

##### 回调函数类型

- **kd_ogg_write_callback**：用于流式写入 Ogg 页面。

```c
typedef int (*kd_ogg_write_callback)(const void *ptr, size_t size, void *user_data);
```

- **kd_ogg_frame_callback**：用于接收解封装后的音频帧。

```c
typedef void (*kd_ogg_frame_callback)(const uint8_t *data, size_t len, void *user_data);
```

##### Ogg Muxer API

###### kd_ogg_muxer_init

【描述】

初始化 Ogg 封装器实例。

【语法】

```c
int kd_ogg_muxer_init(kd_ogg_muxer **ogg_muxer, kd_ogg_muxer_params *params);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| ogg_muxer | 输出的封装器句柄 | 输出 |
| params | 初始化参数（见下表） | 输入 |

`kd_ogg_muxer_params` 结构体成员：

| 成员 | 描述 |
|---|---|
| filename[128] | 若非空，则写入文件；若为空，则使用 write_cb 流式输出 |
| sample_rate | 音频采样率（如 48000） |
| channels | 声道数（如 1 或 2） |
| serial_no | Ogg 流序列号（设为 0 表示自动生成） |
| write_cb | 流模式下的写回调（当 filename 为空时必须提供） |
| user_data | 传递给回调的用户数据指针 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功 |
| 非0 | 失败 |

【需求】

- 头文件：libogg.h
- 库文件：libogg.a

【注意】

无。

【相关主题】

无。

###### kd_ogg_write_frame

【描述】

向 Ogg 封装器写入一帧音频数据。

【语法】

```c
int kd_ogg_write_frame(kd_ogg_muxer *ogg_muxer, kd_ogg_frame_params *frame);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| ogg_muxer | 已初始化的封装器句柄 | 输入 |
| frame | 包含 data, len, frame_samples 的帧信息 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功 |
| 非0 | 失败 |

【需求】

- 头文件：libogg.h
- 库文件：libogg.a

【注意】

无。

【相关主题】

无。

###### kd_ogg_write_frame_ex

【描述】

扩展版本，支持获取生成的 Ogg 页面数据（适用于需要手动处理页面的场景）。

【语法】

```c
int kd_ogg_write_frame_ex(kd_ogg_muxer *ogg_muxer, kd_ogg_frame_params_ex *frame);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| ogg_muxer | 已初始化的封装器句柄 | 输入 |
| frame | 包含输入帧数据及输出页面缓冲区的扩展帧信息 | 输入/输出 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功 |
| 非0 | 失败 |

【需求】

- 头文件：libogg.h
- 库文件：libogg.a

【注意】

调用者需确保 out_page 缓冲区足够大.

【相关主题】

无。

###### kd_ogg_muxer_destroy

【描述】

销毁 Ogg 封装器实例并释放资源。

【语法】

```c
int kd_ogg_muxer_destroy(kd_ogg_muxer *ogg_muxer);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| ogg_muxer | 已初始化的封装器句柄 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功 |
| 非0 | 失败 |

【需求】

- 头文件：libogg.h
- 库文件：libogg.a

【注意】

无。

【相关主题】

无。

##### Ogg Demuxer API

###### kd_ogg_demuxer_init

【描述】

初始化 Ogg 解封装器实例。

【语法】

```c
int kd_ogg_demuxer_init(kd_ogg_demuxer **ogg_demuxer, kd_ogg_demuxer_params *params);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| ogg_demuxer | 输出的解封装器句柄 | 输出 |
| params | 初始化参数（见下表） | 输入 |

`kd_ogg_demuxer_params` 结构体成员：

| 成员 | 描述 |
|---|---|
| filename[128] | 若非空，从文件读取；若为空，需通过 feed_page 输入数据 |
| frame_cb | 接收解封装后音频帧的回调（必须提供） |
| user_data | 传递给回调的用户数据 |
| sample_rate | 初始化后由 demuxer 填充实际值 |
| channels | 初始化后由 demuxer 填充实际值 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功 |
| 非0 | 失败 |

【需求】

- 头文件：libogg.h
- 库文件：libogg.a

【注意】

无。

【相关主题】

无。

###### kd_ogg_demuxer_feed_page

【描述】

向解封装器输入一个完整的 Ogg 页面数据（用于流模式）。

【语法】

```c
int kd_ogg_demuxer_feed_page(kd_ogg_demuxer *ogg_demuxer, const uint8_t *page_data, size_t page_size);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| ogg_demuxer | 已初始化的解封装器句柄 | 输入 |
| page_data | Ogg 页面数据地址 | 输入 |
| page_size | Ogg 页面数据大小 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功 |
| 非0 | 失败 |

【需求】

- 头文件：libogg.h
- 库文件：libogg.a

【注意】

无。

【相关主题】

无。

###### kd_ogg_demuxer_feed_page_ex

【描述】

扩展版本，支持从页面中提取原始帧数据到指定缓冲区。

【语法】

```c
int kd_ogg_demuxer_feed_page_ex(kd_ogg_demuxer *ogg_demuxer, kd_ogg_page_params_ex *page);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| ogg_demuxer | 已初始化的解封装器句柄 | 输入 |
| page | 包含输入页面数据及输出帧缓冲区的扩展页面信息 | 输入/输出 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功 |
| 非0 | 失败 |

【需求】

- 头文件：libogg.h
- 库文件：libogg.a

【注意】

无。

【相关主题】

无。

###### kd_ogg_demuxer_destroy

【描述】

销毁 Ogg 解封装器实例。

【语法】

```c
int kd_ogg_demuxer_destroy(kd_ogg_demuxer *ogg_demuxer);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| ogg_demuxer | 已初始化的解封装器句柄 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功 |
| 非0 | 失败 |

【需求】

- 头文件：libogg.h
- 库文件：libogg.a

【注意】

无。

【相关主题】

无。

##### 注意事项

1. Ogg 封装器内部自动处理页分割、序列号、校验和等 Ogg 协议细节。
1. 时间戳由上层管理，Ogg 容器本身不存储绝对时间戳，仅记录样本偏移。
1. 当前仅支持单音频轨道。
1. 若使用流模式（stream mode），需确保 write_cb 或 feed_page 被正确调用以维持数据流连续性。

### WebRTC

WebRTC模块基于libpeer库，提供以下三组API：

- **Peer**：全局初始化与反初始化。
- **PeerConnection**：WebRTC连接管理，包括SDP协商、ICE候选、音视频传输、DataChannel等。
- **PeerSignaling**：信令服务连接与通信。

```{admonition} 使用提示
`peer_connection_loop()` 必须由应用持续调用以驱动 ICE、DTLS 和接收处理。媒体应在 `PEER_CONNECTION_COMPLETED` 后发送；H.264/H.265 视频需要在关键帧前提供对应参数集。完整的 K230 使用说明和可运行样例请参阅[libpeer 文档](../../app_develop_guide/3rd-party/libpeer.md)与[WebRTC Demo](../../app_develop_guide/media/webrtc.md)。
```

#### Peer

Peer模块提供以下API：

- [peer_init](#peer_init)：WebRTC全局初始化。
- [peer_deinit](#peer_deinit)：WebRTC全局反初始化。

##### peer_init

【描述】

WebRTC全局初始化，在使用任何其他WebRTC API之前必须调用。

【语法】

```c
int peer_init();
```

【参数】

无。

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer.h
- 库文件：libpeer.a

【注意】

必须在创建PeerConnection或连接信令服务之前调用此函数。

【举例】

无。

【相关主题】

无。

##### peer_deinit

【描述】

WebRTC全局反初始化，释放全局资源。在不再使用WebRTC功能时调用。

【语法】

```c
void peer_deinit();
```

【参数】

无。

【返回值】

无。

【需求】

- 头文件：peer.h
- 库文件：libpeer.a

【注意】

应在销毁所有PeerConnection实例并断开信令连接之后调用此函数。

【举例】

无。

【相关主题】

无。

#### PeerConnection

PeerConnection模块提供以下API：

- [peer_connection_create](#peer_connection_create)：创建PeerConnection实例。
- [peer_connection_destroy](#peer_connection_destroy)：销毁PeerConnection实例。
- [peer_connection_close](#peer_connection_close)：关闭PeerConnection连接。
- [peer_connection_loop](#peer_connection_loop)：驱动PeerConnection事件循环。
- [peer_connection_get_state](#peer_connection_get_state)：获取连接状态。
- [peer_connection_state_to_string](#peer_connection_state_to_string)：将连接状态枚举转换为字符串。
- [peer_connection_create_offer](#peer_connection_create_offer)：创建SDP Offer。
- [peer_connection_create_answer](#peer_connection_create_answer)：创建SDP Answer。
- [peer_connection_set_local_description](#peer_connection_set_local_description)：设置本地SDP描述。
- [peer_connection_set_remote_description](#peer_connection_set_remote_description)：设置远端SDP描述。
- [peer_connection_add_ice_candidate](#peer_connection_add_ice_candidate)：添加远端ICE候选。
- [peer_connection_onicecandidate](#peer_connection_onicecandidate)：注册ICE候选回调。
- [peer_connection_oniceconnectionstatechange](#peer_connection_oniceconnectionstatechange)：注册ICE连接状态变更回调。
- [peer_connection_ondatachannel](#peer_connection_ondatachannel)：注册DataChannel事件回调。
- [peer_connection_create_datachannel](#peer_connection_create_datachannel)：创建DataChannel。
- [peer_connection_create_datachannel_sid](#peer_connection_create_datachannel_sid)：创建指定Stream ID的DataChannel。
- [peer_connection_datachannel_send](#peer_connection_datachannel_send)：通过DataChannel发送文本消息。
- [peer_connection_datachannel_send_sid](#peer_connection_datachannel_send_sid)：通过指定Stream ID的DataChannel发送文本消息。
- [peer_connection_datachannel_send_binary](#peer_connection_datachannel_send_binary)：通过DataChannel发送二进制数据。
- [peer_connection_datachannel_send_binary_sid](#peer_connection_datachannel_send_binary_sid)：通过指定Stream ID的DataChannel发送二进制数据。
- [peer_connection_lookup_sid](#peer_connection_lookup_sid)：根据label查找DataChannel的Stream ID。
- [peer_connection_lookup_sid_label](#peer_connection_lookup_sid_label)：根据Stream ID查找DataChannel的label。
- [peer_connection_send_audio](#peer_connection_send_audio)：发送音频数据。
- [peer_connection_send_video](#peer_connection_send_video)：发送视频数据。
- [peer_connection_on_receiver_packet_loss](#peer_connection_on_receiver_packet_loss)：注册接收端丢包率回调。
- [peer_connection_get_sctp](#peer_connection_get_sctp)：获取Sctp实例指针。

##### 数据类型

PeerConnection模块使用以下数据类型和枚举：

**SdpType**

SDP类型枚举，用于区分Offer和Answer。

| 枚举值 | 描述 |
|---|---|
| SDP_TYPE_OFFER | SDP Offer。 |
| SDP_TYPE_ANSWER | SDP Answer。 |

**PeerConnectionState**

PeerConnection连接状态枚举。

| 枚举值 | 描述 |
|---|---|
| PEER_CONNECTION_CLOSED | 连接已关闭。 |
| PEER_CONNECTION_NEW | 新建连接，尚未开始ICE协商。 |
| PEER_CONNECTION_CHECKING | 正在进行ICE连接检查。 |
| PEER_CONNECTION_CONNECTED | 至少一个ICE候选对连接成功。 |
| PEER_CONNECTION_COMPLETED | 所有ICE候选对检查完成，连接建立。 |
| PEER_CONNECTION_FAILED | ICE连接检查失败。 |
| PEER_CONNECTION_DISCONNECTED | 连接已断开。 |

**DataChannelType**

DataChannel数据类型枚举。

| 枚举值 | 描述 |
|---|---|
| DATA_CHANNEL_NONE | 无DataChannel。 |
| DATA_CHANNEL_STRING | 字符串类型DataChannel。 |
| DATA_CHANNEL_BINARY | 二进制类型DataChannel。 |

**DecpChannelType**

DataChannel传输可靠性类型枚举，用于创建DataChannel时指定传输特性。

| 枚举值 | 描述 |
|---|---|
| DATA_CHANNEL_RELIABLE | 可靠有序传输。 |
| DATA_CHANNEL_RELIABLE_UNORDERED | 可靠无序传输。 |
| DATA_CHANNEL_PARTIAL_RELIABLE_REXMIT | 部分可靠，重传保证。 |
| DATA_CHANNEL_PARTIAL_RELIABLE_REXMIT_UNORDERED | 部分可靠无序，重传保证。 |
| DATA_CHANNEL_PARTIAL_RELIABLE_TIMED | 部分可靠，超时保证。 |
| DATA_CHANNEL_PARTIAL_RELIABLE_TIMED_UNORDERED | 部分可靠无序，超时保证。 |

**MediaCodec**

媒体编解码类型枚举。

| 枚举值 | 描述 |
|---|---|
| CODEC_NONE | 无编解码。 |
| CODEC_H264 | H.264视频编解码。 |
| CODEC_H265 | H.265视频编解码。 |
| CODEC_VP8 | VP8视频编解码（暂未实现）。 |
| CODEC_MJPEG | MJPEG视频编解码（暂未实现）。 |
| CODEC_OPUS | Opus音频编解码。 |
| CODEC_PCMA | G.711A音频编解码。 |
| CODEC_PCMU | G.711U音频编解码。 |

**IceServer**

ICE服务器配置结构体。

```c
typedef struct IceServer {
  const char* urls;       // ICE服务器URL（如 "stun:stun.l.google.com:19302"）
  const char* username;   // 用户名（TURN服务器需要）
  const char* credential; // 凭据（TURN服务器需要）
} IceServer;
```

**PeerConfiguration**

PeerConnection配置结构体，在创建PeerConnection时传入。

```c
typedef struct PeerConfiguration {
  IceServer ice_servers[5];           // ICE服务器列表，最多5个
  MediaCodec audio_codec;             // 音频编解码类型
  uint32_t audio_sample_rate;         // 音频采样率（Hz，如8000），用于Opus fmtp约束浏览器编码器
  MediaCodec video_codec;             // 视频编解码类型
  DataChannelType datachannel;        // DataChannel数据类型
  void (*onaudiotrack)(uint8_t* data, size_t size, void* userdata);   // 接收音频帧回调
  void (*onvideotrack)(uint8_t* data, size_t size, void* userdata);   // 接收视频帧回调
  void (*on_request_keyframe)(void* userdata);                        // 请求关键帧回调
  void* user_data;                    // 用户数据指针，传递给各回调函数
} PeerConfiguration;
```

##### peer_connection_create

【描述】

创建PeerConnection实例。

【语法】

```c
PeerConnection* peer_connection_create(PeerConfiguration* config);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| config | PeerConnection配置参数。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 非NULL | 成功，返回PeerConnection实例指针。 |
| NULL | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

调用前需先调用peer_init()完成全局初始化。

【举例】

无。

【相关主题】

无。

##### peer_connection_destroy

【描述】

销毁PeerConnection实例并释放资源。

【语法】

```c
void peer_connection_destroy(PeerConnection* pc);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |

【返回值】

无。

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

销毁前应先调用peer_connection_close()关闭连接。

【举例】

无。

【相关主题】

无。

##### peer_connection_close

【描述】

关闭PeerConnection连接。

【语法】

```c
void peer_connection_close(PeerConnection* pc);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |

【返回值】

无。

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_loop

【描述】

驱动PeerConnection事件循环，处理网络收发和状态更新。需在主循环中周期性调用。

【语法】

```c
int peer_connection_loop(PeerConnection* pc);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

此函数应在连接建立后持续调用以维持连接正常工作。

【举例】

无。

【相关主题】

无。

##### peer_connection_get_state

【描述】

获取PeerConnection当前连接状态。

【语法】

```c
PeerConnectionState peer_connection_get_state(PeerConnection* pc);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| PeerConnectionState枚举值 | 当前连接状态。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_state_to_string

【描述】

将PeerConnectionState枚举值转换为可读字符串。

【语法】

```c
const char* peer_connection_state_to_string(PeerConnectionState state);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| state | PeerConnection连接状态枚举值。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 非NULL | 成功，返回状态对应的字符串。 |
| NULL | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_create_offer

【描述】

创建SDP Offer，用于发起WebRTC连接协商。调用后需通过peer_connection_onicecandidate回调获取ICE候选信息。

【语法】

```c
const char* peer_connection_create_offer(PeerConnection* pc);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 非NULL | 成功，返回SDP Offer字符串。 |
| NULL | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

返回的SDP字符串在下次调用此函数前有效，如需长期保存请自行复制。

【相关主题】

无。

##### peer_connection_create_answer

【描述】

创建SDP Answer，用于响应远端SDP Offer。需在调用peer_connection_set_remote_description设置远端Offer后调用。

【语法】

```c
const char* peer_connection_create_answer(PeerConnection* pc);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 非NULL | 成功，返回SDP Answer字符串。 |
| NULL | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

返回的SDP字符串在下次调用此函数前有效，如需长期保存请自行复制。

【相关主题】

无。

##### peer_connection_set_local_description

【描述】

设置本地SDP描述。

【语法】

```c
void peer_connection_set_local_description(PeerConnection* pc, const char* sdp, SdpType sdp_type);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| sdp | SDP描述字符串。 | 输入 |
| sdp_type | SDP类型（Offer或Answer）。 | 输入 |

【返回值】

无。

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_set_remote_description

【描述】

设置远端SDP描述。

【语法】

```c
void peer_connection_set_remote_description(PeerConnection* pc, const char* sdp, SdpType sdp_type);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| sdp | 远端SDP描述字符串。 | 输入 |
| sdp_type | SDP类型（Offer或Answer）。 | 输入 |

【返回值】

无。

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_add_ice_candidate

【描述】

添加远端ICE候选信息。

【语法】

```c
int peer_connection_add_ice_candidate(PeerConnection* pc, char* ice_candidate);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| ice_candidate | ICE候选字符串。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| -1 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_onicecandidate

【描述】

注册ICE候选回调函数，当发现新的ICE候选时触发。

【语法】

```c
void peer_connection_onicecandidate(PeerConnection* pc, void (*onicecandidate)(char* sdp_text, void* userdata));
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| onicecandidate | ICE候选回调函数。回调参数：sdp_text为ICE候选SDP文本，userdata为用户数据。 | 输入 |

【返回值】

无。

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

回调中获取的ICE候选需通过信令通道发送给对端。

【相关主题】

无。

##### peer_connection_oniceconnectionstatechange

【描述】

注册ICE连接状态变更回调函数，当ICE连接状态发生变化时触发。

【语法】

```c
void peer_connection_oniceconnectionstatechange(PeerConnection* pc,
    void (*oniceconnectionstatechange)(PeerConnectionState state, void* userdata));
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| oniceconnectionstatechange | ICE连接状态变更回调函数。回调参数：state为当前连接状态，userdata为用户数据。 | 输入 |

【返回值】

无。

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_ondatachannel

【描述】

注册DataChannel事件回调函数，包括消息接收、通道打开和通道关闭事件。

【语法】

```c
void peer_connection_ondatachannel(PeerConnection* pc,
    void (*onmessage)(char* msg, size_t len, void* userdata, uint16_t sid),
    void (*onopen)(void* userdata),
    void (*onclose)(void* userdata));
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| onmessage | 消息接收回调函数。回调参数：msg为消息内容，len为消息长度，userdata为用户数据，sid为Stream ID。 | 输入 |
| onopen | DataChannel打开回调函数。回调参数：userdata为用户数据。 | 输入 |
| onclose | DataChannel关闭回调函数。回调参数：userdata为用户数据。 | 输入 |

【返回值】

无。

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_create_datachannel

【描述】

创建DataChannel。

【语法】

```c
int peer_connection_create_datachannel(PeerConnection* pc, DecpChannelType channel_type,
    uint16_t priority, uint32_t reliability_parameter, char* label, char* protocol);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| channel_type | DataChannel传输可靠性类型。 | 输入 |
| priority | DataChannel优先级。 | 输入 |
| reliability_parameter | 可靠性参数（重传次数或超时时间，取决于channel_type）。 | 输入 |
| label | DataChannel标签名称。 | 输入 |
| protocol | DataChannel协议名称。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_create_datachannel_sid

【描述】

创建指定Stream ID的DataChannel。

【语法】

```c
int peer_connection_create_datachannel_sid(PeerConnection* pc, DecpChannelType channel_type,
    uint16_t priority, uint32_t reliability_parameter, char* label, char* protocol, uint16_t sid);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| channel_type | DataChannel传输可靠性类型。 | 输入 |
| priority | DataChannel优先级。 | 输入 |
| reliability_parameter | 可靠性参数。 | 输入 |
| label | DataChannel标签名称。 | 输入 |
| protocol | DataChannel协议名称。 | 输入 |
| sid | 指定的Stream ID。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_datachannel_send

【描述】

通过DataChannel发送文本消息。

【语法】

```c
int peer_connection_datachannel_send(PeerConnection* pc, char* message, size_t len);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| message | 消息缓冲区。 | 输入 |
| len | 消息长度。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_datachannel_send_sid

【描述】

通过指定Stream ID的DataChannel发送文本消息。

【语法】

```c
int peer_connection_datachannel_send_sid(PeerConnection* pc, char* message, size_t len, uint16_t sid);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| message | 消息缓冲区。 | 输入 |
| len | 消息长度。 | 输入 |
| sid | Stream ID。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_datachannel_send_binary

【描述】

通过DataChannel发送二进制数据（PPID=53）。

【语法】

```c
int peer_connection_datachannel_send_binary(PeerConnection* pc, const char* data, size_t len);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| data | 数据缓冲区。 | 输入 |
| len | 数据长度。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| -1 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_datachannel_send_binary_sid

【描述】

通过指定Stream ID的DataChannel发送二进制数据（PPID=53）。

【语法】

```c
int peer_connection_datachannel_send_binary_sid(PeerConnection* pc, const char* data, size_t len, uint16_t sid);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| data | 数据缓冲区。 | 输入 |
| len | 数据长度。 | 输入 |
| sid | Stream ID。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| -1 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_lookup_sid

【描述】

根据DataChannel的label查找对应的Stream ID。

【语法】

```c
int peer_connection_lookup_sid(PeerConnection* pc, const char* label, uint16_t* sid);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| label | DataChannel标签名称。 | 输入 |
| sid | 输出的Stream ID。 | 输出 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败（未找到对应DataChannel）。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_lookup_sid_label

【描述】

根据Stream ID查找DataChannel的label。

【语法】

```c
char* peer_connection_lookup_sid_label(PeerConnection* pc, uint16_t sid);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| sid | Stream ID。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 非NULL | 成功，返回label字符串。 |
| NULL | 失败（未找到对应DataChannel）。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_connection_send_audio

【描述】

发送音频数据。

【语法】

```c
int peer_connection_send_audio(PeerConnection* pc, const uint8_t* packet, size_t bytes, uint64_t timestamp_us);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| packet | 音频数据缓冲区。 | 输入 |
| bytes | 音频数据大小（字节）。 | 输入 |
| timestamp_us | 时间戳（微秒）。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

音频数据格式需与PeerConfiguration中配置的audio_codec一致。

【相关主题】

无。

##### peer_connection_send_video

【描述】

发送视频数据。

【语法】

```c
int peer_connection_send_video(PeerConnection* pc, const uint8_t* packet, size_t bytes, uint64_t timestamp_us);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| packet | 视频数据缓冲区。 | 输入 |
| bytes | 视频数据大小（字节）。 | 输入 |
| timestamp_us | 时间戳（微秒）。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

视频数据格式需与PeerConfiguration中配置的video_codec一致。

【相关主题】

无。

##### peer_connection_on_receiver_packet_loss

【描述】

注册接收端丢包率回调函数，当收到RTCP接收端报告时触发。

【语法】

```c
void peer_connection_on_receiver_packet_loss(PeerConnection* pc,
    void (*on_receiver_packet_loss)(float fraction_loss, uint32_t total_loss, void* userdata));
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |
| on_receiver_packet_loss | 丢包率回调函数。回调参数：fraction_loss为丢包率（0.0~1.0），total_loss为总丢包数，userdata为用户数据。 | 输入 |

【返回值】

无。

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

可根据丢包率动态调整编码参数或请求关键帧。

【相关主题】

无。

##### peer_connection_get_sctp

【描述】

获取SCTP实例指针，用于底层SCTP协议操作。

【语法】

```c
void* peer_connection_get_sctp(PeerConnection* pc);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| pc | PeerConnection实例指针。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 非NULL | 成功，返回SCTP实例指针。 |
| NULL | 失败。 |

【需求】

- 头文件：peer_connection.h
- 库文件：libpeer.a

【注意】

此接口为底层接口，一般应用无需使用。

【相关主题】

无。

#### PeerSignaling

PeerSignaling模块提供信令服务连接与通信功能，支持通过HTTP或MQTT协议与信令服务器交互，完成WebRTC连接的SDP交换和ICE候选传递。该模块在编译时可通过定义`DISABLE_PEER_SIGNALING`宏来禁用。

PeerSignaling模块提供以下API：

- [peer_signaling_connect](#peer_signaling_connect)：连接信令服务器。
- [peer_signaling_disconnect](#peer_signaling_disconnect)：断开信令服务器连接。
- [peer_signaling_loop](#peer_signaling_loop)：驱动信令事件循环。
- [peer_signaling_set_custom_rpc_handler](#peer_signaling_set_custom_rpc_handler)：注册自定义RPC方法处理回调。
- [peer_signaling_publish](#peer_signaling_publish)：通过信令层的MQTT连接发布消息。

##### peer_signaling_connect

【描述】

连接信令服务器，建立与信令服务的通信通道。

【语法】

```c
int peer_signaling_connect(const char* url, const char* token, PeerConnection* pc);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| url | 信令服务器URL。 | 输入 |
| token | 认证令牌。 | 输入 |
| pc | PeerConnection实例指针。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_signaling.h
- 库文件：libpeer.a

【注意】

调用前需先创建PeerConnection实例。

【举例】

无。

【相关主题】

无。

##### peer_signaling_disconnect

【描述】

断开信令服务器连接。

【语法】

```c
void peer_signaling_disconnect();
```

【参数】

无。

【返回值】

无。

【需求】

- 头文件：peer_signaling.h
- 库文件：libpeer.a

【注意】

无。

【相关主题】

无。

##### peer_signaling_loop

【描述】

驱动信令事件循环，处理信令消息的收发。需在主循环中周期性调用。

【语法】

```c
int peer_signaling_loop();
```

【参数】

无。

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| 非0 | 失败。 |

【需求】

- 头文件：peer_signaling.h
- 库文件：libpeer.a

【注意】

此函数应在信令连接建立后持续调用以维持信令通信正常工作。

【相关主题】

无。

##### peer_signaling_set_custom_rpc_handler

【描述】

注册自定义RPC方法处理回调，用于处理信令层未识别的应用层自定义RPC方法。需在peer_signaling_connect()之后调用。同一时间只能注册一个处理回调，后续调用会替换之前的回调。传入NULL可取消注册。

【语法】

```c
void peer_signaling_set_custom_rpc_handler(peer_signaling_custom_rpc_cb cb, void* userdata);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| cb | 自定义RPC方法处理回调函数。 | 输入 |
| userdata | 传递给回调函数的用户数据指针。 | 输入 |

回调函数类型定义：

```c
typedef int (*peer_signaling_custom_rpc_cb)(const char* method, cJSON* params, int id,
    cJSON** result, cJSON** error, void* userdata);
```

回调参数说明：

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| method | RPC方法名称（如 "list_recordings"）。 | 输入 |
| params | "params"字段的cJSON对象（可能为NULL）。 | 输入 |
| id | JSON-RPC请求ID。 | 输入 |
| result | 输出：设置为cJSON结果对象（调用者获取所有权）。 | 输出 |
| error | 输出：设置为cJSON错误对象（调用者获取所有权）。 | 输出 |
| userdata | 用户数据指针。 | 输入 |

回调返回值：

| 返回值 | 描述 |
|---|---|
| 0 | 方法已处理（必须设置result或error）。 |
| -1 | 方法未处理（信令层将返回METHOD_NOT_FOUND）。 |

【返回值】

无。

【需求】

- 头文件：peer_signaling.h
- 库文件：libpeer.a

【注意】

回调函数在信令线程（peer_signaling_loop）中被调用，实现时需保证线程安全。

【相关主题】

无。

##### peer_signaling_publish

【描述】

通过信令层已有的MQTT连接向指定MQTT主题发布消息，复用peer_signaling_connect()建立的MQTT连接，无需额外创建MQTT客户端。仅在MQTT模式（proto == 0）下可用。

【语法】

```c
int peer_signaling_publish(const char* topic, const char* message);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
|---|---|---|
| topic | MQTT主题（如 "/devices/heartbeat"）。 | 输入 |
| message | 消息内容（JSON字符串）。 | 输入 |

【返回值】

| 返回值 | 描述 |
|---|---|
| 0 | 成功。 |
| -1 | 失败（HTTP模式或MQTT连接未建立）。 |

【需求】

- 头文件：peer_signaling.h
- 库文件：libpeer.a

【注意】

- 仅在MQTT信令模式下可用，HTTP模式调用将返回-1。
- 需在peer_signaling_connect()成功建立MQTT连接后调用。

【相关主题】

无。

#### WebRTC典型使用流程

1. 调用`peer_init()`进行全局初始化。
2. 配置`PeerConfiguration`结构体，设置ICE服务器、音视频编解码类型、回调函数等。
3. 调用`peer_connection_create()`创建PeerConnection实例。
4. 注册回调函数：`peer_connection_onicecandidate()`、`peer_connection_oniceconnectionstatechange()`、`peer_connection_ondatachannel()`等。
5. 通过应用自己的 HTTP/MQTT/WebSocket 信令，或可选的`peer_signaling_connect()`，交换 SDP 和 ICE 候选。
6. 在受控线程中持续调用`peer_connection_loop()`；使用 `peer_signaling` 时同时调用`peer_signaling_loop()`。
7. 连接进入`PEER_CONNECTION_COMPLETED`后，通过`peer_connection_send_audio()`/`peer_connection_send_video()`发送已编码的媒体数据，或通过DataChannel收发数据。
8. 通信结束后，调用`peer_signaling_disconnect()`断开信令连接，调用`peer_connection_close()`关闭PeerConnection，调用`peer_connection_destroy()`销毁实例。
9. 调用`peer_deinit()`进行全局反初始化。
