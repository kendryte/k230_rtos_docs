# 多媒体中间件API手册

## 概述

### 概述

本文档旨在为开发者提供 K230 多媒体中间件的详细信息，包括各模块的 API 接口、头文件及使用说明。该中间件涵盖 RTSP 服务器、RTSP 客户端、RTSP 推流器、媒体播放器以及 MP4 格式封装与解封装、ogg 格式封装接封装等多个功能模块，有助于开发者深入了解其应用场景与工作原理。请注意，本指南可能会不定期更新，建议开发者始终参考最新版本的文档。

中间件代码位于系统路径`src/rtsmart/mpp/middleware`，其中`src/rtsmart/mpp/middleware/src`目录包含多媒体封装的API接口，`src/rtsmart/examples/mpp`目录包含使用这些API接口的示例代码。

本文档提供了每个模块的API接口的详细描述和示例，帮助用户更好地理解和使用不同模块的API。

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

实现mp4文件播放。视频支持h264、h265，音频支持g711a/u。

#### MP4格式封装解封装

实现音视频与mp4格式间的封装与解封装。

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

int Init(Port port = 8554, IOnBackChannel *back_channel = nullptr);

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

void DeInit();

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

int CreateSession(const std::string &session_name, const SessionAttr &session_attr);

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

int DestroySession(const std::string &session_name);

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

void Start();

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

void Stop();

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

int SendVideoData(const std::string &session_name, const uint8_t *data, size_t size, uint64_t timestamp);

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

int SendAudioData(const std::string &session_name, const uint8_t *data, size_t size, uint64_t timestamp);

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

int Init(const RtspClientInitParam &param);

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

int Open(const char *url);

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

void Close();

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

int SendAudioData(const uint8_t *data, size_t size, uint64_t timestamp);

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

k_s32 kd_player_init();

【参数】

无

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 库文件：libkplayer.a

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

k_s32 kd_player_deinit();

【参数】

无

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 库文件：libkplayer.a

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

k_s32 kd_player_setdatasource(const k_char* filePath);

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
- 库文件：libkplayer.a

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

k_s32 kd_player_regcallback( K_PLAYER_EVENT_FN pfnCallback,void* pData);

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
- 库文件：libkplayer.a

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

k_s32 kd_player_start();

【参数】

无

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 库文件：libkplayer.a

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

k_s32 kd_player_stop();

【参数】

无

【返回值】

| 返回值 | 描述                          |
|--------|-------------------------------|
| 0      | 成功。                        |
| 非0    | 失败。 |

【需求】

- 头文件：kplayer.h
- 库文件：libkplayer.a

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

int kd_mp4_create(KD_HANDLE *mp4_handle, k_mp4_config_s \*mp4_cfg);

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
- 库文件：libmp4.a

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

int kd_mp4_destroy(KD_HANDLE mp4_handle);

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
- 库文件：libmp4.a

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

int kd_mp4_create_track(KD_HANDLE mp4_handle, KD_HANDLE \*track_handle, k_mp4_track_info_s \*mp4_track_info);

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
- 库文件：libmp4.a

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

int kd_mp4_destroy_tracks(KD_HANDLE mp4_handle);

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
- 库文件：libmp4.a

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

int kd_mp4_write_frame(KD_HANDLE mp4_handle, KD_HANDLE track_handle, k_mp4_frame_data_s *frame_data);

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
- 库文件：libmp4.a

【注意】

- 该API为muxer API，当创建的MP4实例为muxer实例时使用
- 请在创建MP4实例和track之后调用该接口

【举例】

参考 samples下 mp4_muxer

【相关主题】

无

#### kd_mp4_get_file_info

【描述】

获取MP4文件信息

【语法】

int kd_mp4_get_file_info(KD_HANDLE mp4_handle, k_mp4_file_info_s *file_info);

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
- 库文件：libmp4.a

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

int kd_mp4_get_track_by_index(KD_HANDLE mp4_handle, uint32_t index, k_mp4_track_info_s *mp4_track_info);

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
- 库文件：libmp4.a

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

int kd_mp4_get_frame(KD_HANDLE mp4_handle, k_mp4_frame_data_s *frame_data);

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
- 库文件：libmp4.a

【注意】

- 该API为demuxer API，当创建的MP4实例为demuxer实例时使用

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

int Init(const RtspPusherInitParam &param);

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
