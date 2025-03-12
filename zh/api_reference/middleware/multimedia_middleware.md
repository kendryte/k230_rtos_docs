# 多媒体中间件API手册

## 概述

### 概述

本文档旨在为开发者提供 K230 多媒体中间件的详细信息，包括各模块的 API 接口、头文件及使用说明。该中间件涵盖 RTSP 服务器、RTSP 客户端、RTSP 推流器、媒体播放器以及 MP4 格式封装与解封装等多个功能模块，有助于开发者深入了解其应用场景与工作原理。请注意，本指南可能会不定期更新，建议开发者始终参考最新版本的文档。

中间件代码位于系统路径`canmv_k230/src/rtsmart/mpp/middleware`，其中`canmv_k230/src/rtsmart/mpp/middleware/src`目录包含多媒体封装的API接口，`canmv_k230/src/rtsmart/mpp/middleware/sample`目录包含使用这些API接口的示例代码。

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

本文件包含了K230中间件的API参考，其中包括了live555和ffmpeg开源多媒体库。
用户可以根据自己的需求使用这些库提供的功能。

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
| data  | 音频码流数据地址 | 输入 |
| size  | 音频码流数据大小 | 输入 |
| key_frame  | 是否是关键帧 | 输入 |
| timestamp | 音频码流数据时间戳（微妙） | 输入 |

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
