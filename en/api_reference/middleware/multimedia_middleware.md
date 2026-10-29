# Multimedia Middleware API Manual

## Overview

### Overview

This document aims to provide developers with detailed information about the K230 multimedia middleware, including the API interfaces, header files, and usage instructions of each module. The middleware covers multiple functional modules, including an RTSP server, RTSP client, RTSP pusher, media player, MP4 encapsulation and decapsulation, Ogg encapsulation and decapsulation, and WebRTC real-time communication, helping developers gain a deeper understanding of its application scenarios and operating principles. Please note that this guide may be updated from time to time; developers are advised to always refer to the latest version of the documentation.

The middleware code is located at the system path `src/rtsmart/mpp/middleware`. The `src/rtsmart/mpp/middleware/src` directory contains the multimedia encapsulation API interfaces, while the `src/rtsmart/examples/mpp` directory contains sample code that uses these API interfaces.

This document provides detailed descriptions and examples of the API interfaces for each module to help users better understand and use the APIs of different modules.

### Module List

| Module | Description |
|---|---|
| rtsp-server | RTSP server that sends audio and video data from the board to clients over the RTSP protocol |
| rtsp-client | RTSP client that obtains audio and video data from an RTSP server |
| rtsp-pusher | RTSP pusher that pushes video data from the board to a third-party streaming server |
| Player | MP4 file playback; supports H264/H265 video and G711a/u/OPUS audio |
| MP4 encapsulation and decapsulation | Encapsulation and decapsulation between audio/video and the MP4 format |
| Ogg encapsulation and decapsulation | Encapsulation and decapsulation between audio and the Ogg format |
| WebRTC | Peer-to-peer real-time audio/video and data channel communication based on the WebRTC protocol |

### Feature Descriptions

#### rtsp server

rtsp-server supports sending audio and video data from the board to rtsp client clients using the rtsp server protocol.

Common use cases include:

- Real-time audio/video transmission: Transmitting audio and video data from the board to rtsp client clients in real time through the rtsp server.
- Multimedia streaming service: Setting up an rtsp server to provide audio/video streaming services for clients to play and access.
- Remote monitoring: Sending audio and video data from the board to remote clients using the rtsp server protocol to enable remote monitoring.

#### rtsp client

rtsp-client supports using the rtsp client protocol on the board to obtain audio and video data from an rtsp server.

Common use cases include:

- Real-time monitoring system: Obtaining real-time audio and video data from an rtsp server through rtsp-client for monitoring and recording.
- Multimedia player: Using rtsp-client to obtain audio and video data from an rtsp server for multimedia content playback.
- Video conferencing system: Using rtsp-client to obtain audio and video data from an rtsp server to implement video conferencing.

#### rtsp pusher

Pushes video data from the board to a third-party streaming server over the RTSP protocol. Clients can obtain the video data pushed by the board through the third-party streaming server.

Common use cases include:

- Video surveillance system: Pushing video data from the board to a streaming server for monitoring clients to view in real time.
- Live streaming: Pushing video data from the board to a streaming server for viewers to watch live broadcasts through the streaming server.
- Video recording: Pushing video data from the board to a streaming server to implement video recording.
- Video distribution: Pushing video data from the board to a streaming server so that multiple clients can obtain the video data simultaneously.

#### Player

Implements MP4 file playback. Supports h264 and h265 video, and g711a/u/opus audio.

#### MP4 Format Encapsulation and Decapsulation

Implements encapsulation and decapsulation between audio/video and the MP4 format.

#### WebRTC

The WebRTC (Web Real-Time Communication) module is based on libpeer and provides peer-to-peer real-time transmission and an optional DataChannel. It handles ICE, SDP, DTLS-SRTP, RTP/RTCP, and SCTP; applications are responsible for audio/video capture, encoding, and signaling. Currently, video RTP supports H.264 and H.265, while audio RTP supports Opus, PCMA, and PCMU. `sample_webrtc` provides a local area network video example for H.265/H.264, with audio and DataChannel disabled by default.

Common use cases include:

- Real-time audio/video calls: Implementing peer-to-peer audio/video calls between the board and a browser or other WebRTC terminal through the WebRTC protocol.
- Remote monitoring: Transmitting video data captured by the board's camera to a remote browser client in real time through WebRTC for viewing.
- Data channel communication: Using the WebRTC DataChannel to transmit custom data, such as sensor data and control commands, between the board and the peer.
- Low-latency streaming: Compared with protocols such as RTSP, WebRTC provides lower end-to-end latency and is suitable for scenarios with high real-time requirements.

#### Others

This document contains the API reference for the K230 middleware, including integration with the live555 and ffmpeg open-source multimedia libraries. Users can leverage the powerful features provided by these libraries to implement multimedia processing and transmission according to their own requirements.

## API Reference

### rtsp-server

KdRtspServer provides the following APIs:

- [Init](#kdrtspserverinit): Initializes.
- [DeInit](#kdrtspserverdeinit): Deinitializes.
- [CreateSession](#kdrtspservercreatesession): Creates an rtsp session.
- [DestroySession](#kdrtspserverdestroysession): Destroys an rtsp session.
- [Start](#kdrtspserverstart): Starts the rtsp-server service.
- [Stop](#kdrtspserverstop): Stops the rtsp-server service.
- [SendVideoData](#kdrtspserversendvideodata): Writes video bitstream data.
- [SendAudioData](#kdrtspserversendaudiodata): Writes audio bitstream data.

#### KdRtspServer::Init

【Description】

Initializes rtsp-server.

【Syntax】

```c
int Init(Port port = 8554, IOnBackChannel *back_channel = nullptr);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| port  | rtsp service port. | Input      |
| back_channel     | Callback pointer for incoming audio data from the peer.   | Input      |

【Return Value】

| Return Value | Description |
|---|---|
| 0      | Success.                        |
| Non-zero    | Failure.                        |

【Requirements】

- Header file: rtsp_server.h
- Library file: librtsp_server.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### KdRtspServer::DeInit

【Description】

Deinitializes.

【Syntax】

```c
void DeInit();
```

【Parameters】

None.

【Return Value】

None.

【Requirements】

- Header file: rtsp_server.h
- Library file: librtsp_server.a

【Example】

None.

#### KdRtspServer::CreateSession

【Description】

Creates an RtspSession.

【Syntax】

```c
int CreateSession(const std::string &session_name, const SessionAttr &session_attr);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| session_name | stream url. | Input |
| session_attr | session configuration parameters. | Input |

【Return Value】

| Return Value | Description                          |
|--------|-------------------------------|
| 0      | Success.                        |
| Non-zero    | Failure. |

【Requirements】

- Header file: rtsp_server.h
- Library file: librtsp_server.a

【Note】

【Example】

None.

#### KdRtspServer::DestroySession

【Description】

Destroys an rtsp session.

【Syntax】

```c
int DestroySession(const std::string &session_name);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| session_name | stream url.| Input |

【Return Value】

| Return Value | Description                          |
|--------|-------------------------------|
| 0      | Success.                        |
| Non-zero    | Failure. |

【Requirements】

- Header file: rtsp_server.h
- Library file: librtsp_server.a

【Note】

【Example】

None.

【Related Topics】

#### KdRtspServer::Start

【Description】

Starts the rtsp server service.

【Syntax】

```c
void Start();
```

【Parameters】

None.

【Return Value】

None.

【Requirements】

- Header file: rtsp-server.h
- Library file: librtsp_server.a

【Note】
None

【Example】

None.

【Related Topics】

#### KdRtspServer::Stop

【Description】

Stops the rtsp-server service.

【Syntax】

```c
void Stop();
```

【Parameters】

None

【Return Value】

None

【Requirements】

- Header file: rtsp_server.h
- Library file: librtsp_server.a

【Note】

【Example】

None.

#### KdRtspServer::SendVideoData

【Description】

Writes video bitstream data.

【Syntax】

```c
int SendVideoData(const std::string &session_name, const uint8_t *data, size_t size, uint64_t timestamp);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| session_name  | stream url | Input |
| data   | Video bitstream address. | Input |
| size   | Video bitstream size. | Input |
| timestamp   | Bitstream timestamp (milliseconds) | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0      | Success.                        |
| Non-zero    | Failure. |

【Requirements】

- Header file: rtsp_server.h
- Library file: librtsp_server.a

【Example】

None.

#### KdRtspServer::SendAudioData

【Description】

Writes audio bitstream data.

【Syntax】

```c
int SendAudioData(const std::string &session_name, const uint8_t *data, size_t size, uint64_t timestamp);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| session_name  | stream url | Input |
| data   | Audio bitstream address. | Input |
| size   | Audio bitstream size. | Input |
| timestamp   | Bitstream timestamp (milliseconds) | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0      | Success.                        |
| Non-zero    | Failure.  |

【Requirements】

- Header file: rtsp_server.h
- Library file: librtsp_server.a

【Example】

None.

### rtsp-client

The KdRtspClient module provides the following APIs:

- [Init](#kdrtspclientinit): Initialization.
- [DeInit](#kdrtspclientdeinit): Deinitialization.
- [Open](#kdrtspclientopen): Opens and runs the rtspclient connection.
- [Close](#kdrtspclientclose): Closes the rtspclient connection.
- [SendAudioData](#kdrtspclientsendaudiodata): Writes backchannel audio bitstream data.

#### KdRtspClient::Init

【Description】

Initialization。

【Syntax】

```c
int Init(const RtspClientInitParam &param);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| param  | rtspclient initialization parameters | Input |

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
        IOnVideoData *on_video_data{nullptr}; // Video bitstream frame callback received from the server side
        IOnAudioData *on_audio_data{nullptr}; // Audio bitstream frame callback received from the server side
        IRtspClientEvent *on_event{nullptr};  // rtspclient event callback
        bool enableBackchanel{false};         // Whether to enable audio backchannel
    };
```

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success。                        |
| Non-zero    | Failure。 |

【Requirements】

- Header file: rtsp_client.h
- Library file: librtsp_client.a

【Note】

None。

【Example】

None。

【Related Topics】

None。

#### KdRtspClient::Deinit

【Description】

Deinitialization。

【Syntax】

void DeInit();

【Parameters】

None。

【Return Value】

None。

【Requirements】

- Header file: rtsp_client.h
- Library file: librtsp_client.a

【Note】

None。

【Example】

None。

【Related Topics】

None。

#### KdRtspClient::Open

【Description】

Opens and runs the rtspclient connection。

【Syntax】

```c
int Open(const char *url);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| url  | rtsp url。 | Input |

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success。                        |
| Non-zero    | Failure。 |

【Requirements】

- Header file: rtsp_client.h
- Library file: librtsp_client.a

【Note】

None。

【Example】

None。

【Related Topics】

None。

#### KdRtspClient::Close

【Description】

Closes the rtsp client。

【Syntax】

```c
void Close();
```

【Parameters】

【Return Value】

【Requirements】

- Header file: rtsp_client.h
- Library file: librtsp_client.a

【Note】

None。

【Example】

None。

【Related Topics】

None。

#### KdRtspClient::SendAudioData

【Description】

Writes audio back channnel bitstream data。

【Syntax】

```c
int SendAudioData(const uint8_t *data, size_t size, uint64_t timestamp);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| data  | Audio bitstream data address | Input |
| size  | Audio bitstream data size | Output |
| timestamp | Audio bitstream data timestamp（milliseconds） | Output |

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success。                        |
| Non-zero    | Failure。 |

【Requirements】

- Header file: rtsp_client.h
- Library file: librtsp_client.a

【Note】

None。

【Example】

None。

【Related Topics】

None。

### Player Encapsulation

The KdPlayer module provides the following APIs:

- [kd_player_init](#kd_player_init): Initialization.
- [kd_player_deinit](#kd_player_deinit): Deinitialization.
- [kd_player_setdatasource](#kd_player_setdatasource): Sets the media playback file.
- [kd_player_regcallback](#kd_player_regcallback): Registers an event callback.
- [kd_player_start](#kd_player_start): Starts playback.
- [kd_player_stop](#kd_player_stop): Stops playback.

#### kd_player_init

【Description】

Player initialization.

【Syntax】

```c
k_s32 kd_player_init();
```

【Parameters】

None

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success.                        |
| Nonzero | Failure.                        |

【Requirements】

- Header file: kplayer.h
- Source location: src/rtsmart/examples/mpp/sample_player (compiled directly into the sample_player example and no longer packaged as a standalone library)

【Notes】

None.

【Example】

None.

【Related Topics】

None.

#### kd_player_deinit

【Description】

Deinitialization.

【Syntax】

```c
k_s32 kd_player_deinit();
```

【Parameters】

None

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success.                        |
| Nonzero | Failure.                        |

【Requirements】

- Header file: kplayer.h
- Source location: src/rtsmart/examples/mpp/sample_player (compiled directly into the sample_player example and no longer packaged as a standalone library)

【Notes】

None.

【Example】

None.

【Related Topics】

None.

#### kd_player_setdatasource

【Description】

Deinitialization.

【Syntax】

```c
k_s32 kd_player_setdatasource(const k_char* filePath);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| filePath  | Media file path | Input |

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success.                        |
| Nonzero | Failure.                        |

【Requirements】

- Header file: kplayer.h
- Source location: src/rtsmart/examples/mpp/sample_player (compiled directly into the sample_player example and no longer packaged as a standalone library)

【Notes】

None.

【Example】

None.

【Related Topics】

None.

#### kd_player_regcallback

【Description】

Registers a player event callback.

【Syntax】

```c
k_s32 kd_player_regcallback( K_PLAYER_EVENT_FN pfnCallback,void* pData);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pfnCallback  | Callback function pointer | Input |
| pData  | Callback data pointer | Input |

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success.                        |
| Nonzero | Failure.                        |

【Requirements】

- Header file: kplayer.h
- Source location: src/rtsmart/examples/mpp/sample_player (compiled directly into the sample_player example and no longer packaged as a standalone library)

【Notes】

None.

【Example】

None.

【Related Topics】

None.

#### kd_player_start

【Description】

Starts playback.

【Syntax】

```c
k_s32 kd_player_start();
```

【Parameters】

None

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success.                        |
| Nonzero | Failure.                        |

【Requirements】

- Header file: kplayer.h
- Source location: src/rtsmart/examples/mpp/sample_player (compiled directly into the sample_player example and no longer packaged as a standalone library)

【Notes】

None.

【Example】

None.

【Related Topics】

None.

#### kd_player_stop

【Description】

Stops playback.

【Syntax】

```c
k_s32 kd_player_stop();
```

【Parameters】

None

【Return Value】

| Return Value | Description                      |
|--------|-------------------------------|
| 0      | Success.                        |
| Nonzero | Failure.                        |

【Requirements】

- Header file: kplayer.h
- Source location: src/rtsmart/examples/mpp/sample_player (compiled directly into the sample_player example and no longer packaged as a standalone library)

【Notes】

None.

【Example】

None.

【Related Topics】

None.

### MP4 Format Muxing and Demuxing

The MP4 format muxing and demuxing APIs are as follows:

- [kd_mp4_create](#kd_mp4_create)：Create an MP4 instance
- [kd_mp4_destroy](#kd_mp4_destroy)：Destroy an MP4 instance
- [kd_mp4_create_track](#kd_mp4_create_track)：Create a track for MP4
- [kd_mp4_destroy_tracks](#kd_mp4_destroy_tracks)：Destroy all tracks in MP4
- [kd_mp4_write_frame](#kd_mp4_write_frame)：Write frame data to MP4.
- [kd_mp4_get_file_info](#kd_mp4_get_file_info)：Get MP4 file information.
- [kd_mp4_get_track_by_index](#kd_mp4_get_track_by_index)：Get track information by index.
- [kd_mp4_get_frame](#kd_mp4_get_frame)：Get track bitstream information.

#### kd_mp4_create

【Description】

Create an MP4 instance

【Syntax】

```c
int kd_mp4_create(KD_HANDLE *mp4_handle, k_mp4_config_s *mp4_cfg);
```

【Parameters】

|     Parameter   |     Description    |   Input/Output   |
|------------|------------|--------------|
| mp4_handle | MP4 instance handle |     Output     |
| mp4_cfg    | Parameter configuration information |     Input     |

【Return Value】

|  Return Value  |   Description  |
|----------|--------|
|    0     |  Success  |
|   Non-0    |  Failure  |

【Requirements】

- Header file: mp4_format.h
- Library file: libmp4_format.a

【Notes】

The muxer instance or demuxer instance of the MP4 instance being created can be specified through the mp4_cfg configuration information

【Example】

Refer to mp4_muxer and mp4_demuxer under samples

【Related Topics】

None

#### kd_mp4_destroy

【Description】

Destroy an MP4 instance

【Syntax】

```c
int kd_mp4_destroy(KD_HANDLE mp4_handle);
```

【Parameters】

|    Parameter    |    Description    |    Input/Output    |
|------------|------------|----------------|
| mp4_handle | MP4 instance handle |     Input       |

【Return Value】

|    Return Value    |    Description    |
|--------------|-----------|
|      0       |    Success    |
|     Non-0      |    Failure     |

【Requirements】

- Header file: mp4_format.h
- Library file: libmp4_format.a

【Notes】

None

【Example】

Refer to mp4_muxer and mp4_demuxer under samples

【Related Topics】

None

#### kd_mp4_create_track

【Description】

Create a track for MP4

【Syntax】

```c
int kd_mp4_create_track(KD_HANDLE mp4_handle, KD_HANDLE *track_handle, k_mp4_track_info_s *mp4_track_info);
```

【Parameters】

|    Parameter    |    Description    |    Input/Output    |
|------------|------------|----------------|
| mp4_handle | MP4 instance handle |    Input        |
|track_handle| Track handle   |    Output        |
|mp4_track_info| Track configuration |    Input        |

【Return Value】

|    Return Value   |    Description    |
|-------------|------------|
|     0       |    Success     |
|    Non-0      |    Failure     |

【Requirements】

- Header file: mp4_format.h
- Library file: libmp4_format.a

【Notes】

- This is a muxer API and is used when the created MP4 instance is a muxer instance
- Currently, each MP4 instance supports the creation of up to 3 tracks

【Example】

Refer to mp4_muxer under samples

【Related Topics】

None

#### kd_mp4_destroy_tracks

【Description】

Destroy all tracks in MP4

【Syntax】

```c
int kd_mp4_destroy_tracks(KD_HANDLE mp4_handle);
```

【Parameters】

|    Parameter    |    Description    |    Input/Output    |
|------------|------------|----------------|
| mp4_handle |  MP4 instance   |   Input          |

【Return Value】

|    Return Value    |    Description    |
|--------------|-----------|
|     0        |   Success     |
|    Non-0       |   Failure     |

【Requirements】

- Header file: mp4_format.h
- Library file: libmp4_format.a

【Notes】

- This is a muxer API and is used when the created MP4 instance is a muxer instance
- Call this interface after creating the MP4 instance and track

【Example】

Refer to mp4_muxer under samples

【Related Topics】

None

#### kd_mp4_write_frame

【Description】

Write frame data to MP4

【Syntax】

```c
int kd_mp4_write_frame(KD_HANDLE mp4_handle, KD_HANDLE track_handle, k_mp4_frame_data_s *frame_data);
```

【Parameters】

|    Parameter    |    Description    |    Input/Output    |
|------------|------------|----------------|
|  mp4_handle| MP4 instance handle |  Input          |
| track_handle| Track handle  |  Input          |
| frame_data  |  Frame data information |  Input         |

【Return Value】

|    Return Value    |    Description    |
|--------------|-----------|
|      0       |    Success    |
|     Non-0      |    Failure    |

【Requirements】

- Header file: mp4_format.h
- Library file: libmp4_format.a

【Notes】

- This is a muxer API and is used when the created MP4 instance is a muxer instance
- Call this interface after creating the MP4 instance and track
- The unit of frame_data->time_stamp is microseconds

【Example】

Refer to mp4_muxer under samples

【Related Topics】

None

#### kd_mp4_get_file_info

【Description】

Get MP4 file information

【Syntax】

```c
int kd_mp4_get_file_info(KD_HANDLE mp4_handle, k_mp4_file_info_s *file_info);
```

【Parameters】

|    Parameter    |    Description    |    Input/Output    |
|------------|------------|----------------|
| mp4_handle | MP4 instance handle |   Input         |
| file_info  | MP4 file information |   Output         |

【Return Value】

|    Return Value    |    Description    |
|--------------|-----------|
|      0       |    Success    |
|     Non-0      |    Failure    |

【Requirements】

- Header file: mp4_format.h
- Library file: libmp4_format.a

【Notes】

- This is a demuxer API and is used when the created MP4 instance is a demuxer instance

【Example】

Refer to mp4_demuxer under samples

【Related Topics】

None

#### kd_mp4_get_track_by_index

【Description】

Get track information by index

【Syntax】

```c
int kd_mp4_get_track_by_index(KD_HANDLE mp4_handle, uint32_t index, k_mp4_track_info_s *mp4_track_info);
```

【Parameters】

|    Parameter    |    Description    |    Input/Output    |
|------------|------------|----------------|
| mp4_handle | MP4 instance handle|   Input          |
|   index    |   Index     |   Input          |
| mp4_track_info | Track information | Output         |

【Return Value】

|    Return Value    |    Description    |
|--------------|------------|
|      0       |    Success     |
|     Non-0      |    Failure     |

【Requirements】

- Header file: mp4_format.h
- Library file: libmp4_format.a

【Notes】

- This is a demuxer API and is used when the created MP4 instance is a demuxer instance

【Example】

Refer to mp4_demuxer under samples

【Related Topics】

None

#### kd_mp4_get_frame

【Description】

Get track bitstream information

【Syntax】

```c
int kd_mp4_get_frame(KD_HANDLE mp4_handle, k_mp4_frame_data_s *frame_data);
```

【Parameters】

|    Parameter    |    Description    |    Input/Output    |
|------------|------------|----------------|
| mp4_handle |  MP4 instance handle|    Input        |
| frame_data |  Bitstream information   |    Output        |

【Return Value】

|    Return Value    |    Description    |
|--------------|-----------|
|      0       |   Success     |
|     Non-0      |   Failure     |

【Requirements】

- Header file: mp4_format.h
- Library file: libmp4_format.a

【Notes】

- This is a demuxer API and is used when the created MP4 instance is a demuxer instance
- The unit of frame_data->time_stamp is microseconds

【Example】

Refer to mp4_demuxer under samples

【Related Topics】

None

### rtsp pusher

The RTSP pusher provides the following APIs:

- [Init](#kdrtsppusherinit): Initializes the instance.
- [DeInit](#kdrtsppusherdeinit): Deinitializes the instance.
- [Open](#kdrtsppusheropen): Establishes an RTSP streaming connection with the streaming media server.
- [Close](#kdrtsppusherclose): Closes the connection to the streaming media server.
- [PushVideoData](#kdrtsppusherpushvideodata): Pushes video data to the streaming media.

#### KdRtspPusher::Init

【Description】

Initializes the instance.

【Syntax】

```c
int Init(const RtspPusherInitParam &param);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| param  | RTSP pusher initialization parameters | Input |

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

【Return Value】

| Return Value | Description                          |
|--------|-------------------------------|
| 0      | Success.                        |
| Non-zero    | Failure. |

【Requirements】

- Header file: rtsp_pusher.h
- Library file: librtsp_pusher.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### KdRtspPusher::Deinit

【Description】

Deinitializes the instance.

【Syntax】

void DeInit();

【Parameters】

None.

【Return Value】

None.

【Requirements】

- Header file: rtsp_pusher.h
- Library file: librtsp_pusher.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### KdRtspPusher::Open

【Description】

Establishes an RTSP streaming connection with the streaming media server.

【Syntax】

int Open();

【Parameters】

None.

【Return Value】

| Return Value | Description                          |
|--------|-------------------------------|
| 0      | Success.                        |
| Non-zero    | Failure. |

【Requirements】

- Header file: rtsp_pusher.h
- Library file: librtsp_pusher.a

【Note】

None.

【Example】

None.

【Related Topics】

None.

#### KdRtspPusher::Close

【Description】

Closes the connection to the streaming media server.

【Syntax】

void Close();

【Parameters】

【Return Value】

【Requirements】

- Header file: rtsp_pusher.h
- Library file: librtsp_pusher.a

【Note】

None.

【Example】

None.
【Related Topics】

None.

#### KdRtspPusher::PushVideoData

【Description】

Pushes video data to the streaming media.

【Syntax】

int  PushVideoData(const uint8_t *data, size_t size, bool key_frame,uint64_t timestamp);

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| data  | Video bitstream data address | Input |
| size  | Video bitstream data size | Input |
| key_frame  | Whether it is a key frame | Input |
| timestamp | Video bitstream data timestamp (microseconds) | Input |

【Return Value】

| Return Value | Description                          |
|--------|-------------------------------|
| 0      | Success.                        |
| Non-zero    | Failure. |

【Requirements】

- Header file: rtsp_pusher.h
- Library file: librtsp_pusher.a

【Note】

The current version only supports H.264 encoded streaming.

【Example】

None.

【Related Topics】

None.

### ogg

This module provides support for the Ogg container format and can be used for muxing and demuxing audio data. It is suitable for scenarios requiring raw audio frames to be packed into Ogg files/streams or audio frames to be extracted from Ogg data.
Ogg Muxer (Muxer)
[kd_ogg_muxer_init](#kd_ogg_muxer_init): Initializes an Ogg muxer instance.
[kd_ogg_write_frame](#kd_ogg_write_frame): Writes one frame of audio data to the Ogg muxer.
[kd_ogg_write_frame_ex](#kd_ogg_write_frame_ex): Extended version that supports retrieving the generated Ogg page data.
[kd_ogg_muxer_destroy](#kd_ogg_muxer_destroy): Destroys the Ogg muxer instance and releases resources.
Ogg Demuxer (Demuxer)
[kd_ogg_demuxer_init](#kd_ogg_demuxer_init): Initializes an Ogg demuxer instance.
[kd_ogg_demuxer_feed_page](#kd_ogg_demuxer_feed_page): Feeds one complete Ogg page of data to the demuxer (for streaming mode).
[kd_ogg_demuxer_feed_page_ex](#kd_ogg_demuxer_feed_page_ex): Extended version that supports extracting raw frame data from a page into a specified buffer.
[kd_ogg_demuxer_destroy](#kd_ogg_demuxer_destroy): Destroys the Ogg demuxer instance.

#### Functional Description

- **Ogg Muxer (Muxer)**: Muxes raw audio frames (such as the Opus encoding format) into Ogg pages according to the Ogg container specification, supporting output to files or callback-based output to memory/network streams.
- **Ogg Demuxer (Demuxer)**: Parses audio frame data from Ogg files or streams and notifies the upper-layer application through callbacks.

The current implementation is not bound to a specific audio encoding (such as Opus) and only handles the Ogg container layer. Audio encoding/decoding must be handled by the upper layer.

#### Use Cases

- Recording audio and saving it as an Ogg-format file;
- Transmitting an Ogg-muxed audio stream over RTSP or a custom protocol;
- Extracting raw audio frames from an Ogg file for playback or analysis;
- Integrating with systems such as WebRTC and VoIP to process Ogg-muxed audio data.
- Using Ogg with Opus encoding to store and stream ASR input data and mux and distribute TTS output data, adapting to real-time voice interaction scenarios.

#### API Reference

##### Type Definitions

```c
typedef void kd_ogg_muxer;
typedef void kd_ogg_demuxer;
```

##### Callback Function Types

- **kd_ogg_write_callback**: Used for streaming writes of Ogg pages.

```c
typedef int (*kd_ogg_write_callback)(const void *ptr, size_t size, void *user_data);
```

- **kd_ogg_frame_callback**: Used to receive demuxed audio frames.

```c
typedef void (*kd_ogg_frame_callback)(const uint8_t *data, size_t len, void *user_data);
```

##### Ogg Muxer API

###### kd_ogg_muxer_init

【Description】

Initializes an Ogg muxer instance.

【Syntax】

```c
int kd_ogg_muxer_init(kd_ogg_muxer **ogg_muxer, kd_ogg_muxer_params *params);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| ogg_muxer | Output muxer handle | Output |
| params | Initialization parameters (see the table below) | Input |

`kd_ogg_muxer_params` structure members:

| Member | Description |
|---|---|
| filename[128] | If non-empty, writes to a file; if empty, uses write_cb for streaming output |
| sample_rate | Audio sample rate (such as 48000) |
| channels | Number of channels (such as 1 or 2) |
| serial_no | Ogg stream serial number (set to 0 for automatic generation) |
| write_cb | Write callback for stream mode (must be provided when filename is empty) |
| user_data | User data pointer passed to the callback |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success |
| Non-zero | Failure |

【Requirements】

- Header file: libogg.h
- Library file: libogg.a

【Note】

None.

【Related Topics】

None.

###### kd_ogg_write_frame

【Description】

Writes one frame of audio data to the Ogg muxer.

【Syntax】

```c
int kd_ogg_write_frame(kd_ogg_muxer *ogg_muxer, kd_ogg_frame_params *frame);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| ogg_muxer | Initialized muxer handle | Input |
| frame | Frame information containing data, len, and frame_samples | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success |
| Non-zero | Failure |

【Requirements】

- Header file: libogg.h
- Library file: libogg.a

【Note】

None.

【Related Topics】

None.

###### kd_ogg_write_frame_ex

【Description】

Extended version that supports retrieving the generated Ogg page data (suitable for scenarios requiring manual page handling).

【Syntax】

```c
int kd_ogg_write_frame_ex(kd_ogg_muxer *ogg_muxer, kd_ogg_frame_params_ex *frame);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| ogg_muxer | Initialized muxer handle | Input |
| frame | Extended frame information containing input frame data and the output page buffer | Input/Output |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success |
| Non-zero | Failure |

【Requirements】

- Header file: libogg.h
- Library file: libogg.a

【Note】

The caller must ensure that the out_page buffer is sufficiently large.

【Related Topics】

None.

###### kd_ogg_muxer_destroy

【Description】

Destroys the Ogg muxer instance and releases resources.

【Syntax】

```c
int kd_ogg_muxer_destroy(kd_ogg_muxer *ogg_muxer);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| ogg_muxer | Initialized muxer handle | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success |
| Non-zero | Failure |

【Requirements】

- Header file: libogg.h
- Library file: libogg.a

【Note】

None.

【Related Topics】

None.

##### Ogg Demuxer API

###### kd_ogg_demuxer_init

【Description】

Initializes an Ogg demuxer instance.

【Syntax】

```c
int kd_ogg_demuxer_init(kd_ogg_demuxer **ogg_demuxer, kd_ogg_demuxer_params *params);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| ogg_demuxer | Output demuxer handle | Output |
| params | Initialization parameters (see the table below) | Input |

`kd_ogg_demuxer_params` structure members:

| Member | Description |
|---|---|
| filename[128] | If not empty, reads from the file; if empty, data must be supplied through feed_page |
| frame_cb | Callback that receives demuxed audio frames (must be provided) |
| user_data | User data passed to the callback |
| sample_rate | Populated with the actual value by the demuxer after initialization |
| channels | Populated with the actual value by the demuxer after initialization |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success |
| Nonzero | Failure |

【Requirements】

- Header file: libogg.h
- Library file: libogg.a

【Notes】

None.

【Related Topics】

None.

###### kd_ogg_demuxer_feed_page

【Description】

Inputs one complete Ogg page of data into the demuxer (for streaming mode).

【Syntax】

```c
int kd_ogg_demuxer_feed_page(kd_ogg_demuxer *ogg_demuxer, const uint8_t *page_data, size_t page_size);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| ogg_demuxer | Initialized demuxer handle | Input |
| page_data | Ogg page data address | Input |
| page_size | Ogg page data size | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success |
| Nonzero | Failure |

【Requirements】

- Header file: libogg.h
- Library file: libogg.a

【Notes】

None.

【Related Topics】

None.

###### kd_ogg_demuxer_feed_page_ex

【Description】

Extended version that supports extracting raw frame data from a page into a specified buffer.

【Syntax】

```c
int kd_ogg_demuxer_feed_page_ex(kd_ogg_demuxer *ogg_demuxer, kd_ogg_page_params_ex *page);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| ogg_demuxer | Initialized demuxer handle | Input |
| page | Extended page information containing the input page data and output frame buffer | Input/Output |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success |
| Nonzero | Failure |

【Requirements】

- Header file: libogg.h
- Library file: libogg.a

【Notes】

None.

【Related Topics】

None.

###### kd_ogg_demuxer_destroy

【Description】

Destroys an Ogg demuxer instance.

【Syntax】

```c
int kd_ogg_demuxer_destroy(kd_ogg_demuxer *ogg_demuxer);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| ogg_demuxer | Initialized demuxer handle | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success |
| Nonzero | Failure |

【Requirements】

- Header file: libogg.h
- Library file: libogg.a

【Notes】

None.

【Related Topics】

None.

##### Notes

1. The Ogg muxer automatically handles Ogg protocol details such as page segmentation, sequence numbers, and checksums.
1. Timestamps are managed by the upper layer. The Ogg container itself does not store absolute timestamps and only records sample offsets.
1. Currently, only a single audio track is supported.
1. When using stream mode, ensure that write_cb or feed_page is called correctly to maintain data stream continuity.

### WebRTC

The WebRTC module is based on the libpeer library and provides the following three groups of APIs:

- **Peer**: Global initialization and deinitialization.
- **PeerConnection**: WebRTC connection management, including SDP negotiation, ICE candidates, audio and video transmission, DataChannel, etc.
- **PeerSignaling**: Signaling service connection and communication.

```{admonition} Usage notes
`peer_connection_loop()` must be called continuously by the application to drive ICE, DTLS, and reception processing. Media should be sent after `PEER_CONNECTION_COMPLETED`; H.264/H.265 video requires the corresponding parameter sets to be provided before keyframes. For complete K230 usage instructions and runnable examples, see the [libpeer documentation](../../app_develop_guide/3rd-party/libpeer.md) and [WebRTC Demo](../../app_develop_guide/media/webrtc.md).
```

#### Peer

The Peer module provides the following APIs:

- [peer_init](#peer_init): Global WebRTC initialization.
- [peer_deinit](#peer_deinit): Global WebRTC deinitialization.

##### peer_init

【Description】

Performs global WebRTC initialization and must be called before using any other WebRTC API.

【Syntax】

```c
int peer_init();
```

【Parameters】

None.

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Non-0 | Failure. |

【Requirements】

- Header file: peer.h
- Library file: libpeer.a

【Notes】

This function must be called before creating a PeerConnection or connecting to the signaling service.

【Example】

None.

【Related Topics】

None.

##### peer_deinit

【Description】

Performs global WebRTC deinitialization and releases global resources. Call it when the WebRTC functionality is no longer needed.

【Syntax】

```c
void peer_deinit();
```

【Parameters】

None.

【Return Value】

None.

【Requirements】

- Header file: peer.h
- Library file: libpeer.a

【Notes】

This function should be called after all PeerConnection instances have been destroyed and signaling connections have been disconnected.

【Example】

None.

【Related Topics】

None.

#### PeerConnection

The PeerConnection module provides the following APIs:

- [peer_connection_create](#peer_connection_create): Creates a PeerConnection instance.
- [peer_connection_destroy](#peer_connection_destroy): Destroys a PeerConnection instance.
- [peer_connection_close](#peer_connection_close): Closes the PeerConnection connection.
- [peer_connection_loop](#peer_connection_loop): Drives the PeerConnection event loop.
- [peer_connection_get_state](#peer_connection_get_state): Gets the connection state.
- [peer_connection_state_to_string](#peer_connection_state_to_string): Converts a connection state enumeration value to a string.
- [peer_connection_create_offer](#peer_connection_create_offer): Creates an SDP Offer.
- [peer_connection_create_answer](#peer_connection_create_answer): Creates an SDP Answer.
- [peer_connection_set_local_description](#peer_connection_set_local_description): Sets the local SDP description.
- [peer_connection_set_remote_description](#peer_connection_set_remote_description): Sets the remote SDP description.
- [peer_connection_add_ice_candidate](#peer_connection_add_ice_candidate): Adds a remote ICE candidate.
- [peer_connection_onicecandidate](#peer_connection_onicecandidate): Registers an ICE candidate callback.
- [peer_connection_oniceconnectionstatechange](#peer_connection_oniceconnectionstatechange): Registers an ICE connection state change callback.
- [peer_connection_ondatachannel](#peer_connection_ondatachannel): Registers a DataChannel event callback.
- [peer_connection_create_datachannel](#peer_connection_create_datachannel): Creates a DataChannel.
- [peer_connection_create_datachannel_sid](#peer_connection_create_datachannel_sid): Creates a DataChannel with the specified Stream ID.
- [peer_connection_datachannel_send](#peer_connection_datachannel_send): Sends a text message through a DataChannel.
- [peer_connection_datachannel_send_sid](#peer_connection_datachannel_send_sid): Sends a text message through the DataChannel with the specified Stream ID.
- [peer_connection_datachannel_send_binary](#peer_connection_datachannel_send_binary): Sends binary data through a DataChannel.
- [peer_connection_datachannel_send_binary_sid](#peer_connection_datachannel_send_binary_sid): Sends binary data through the DataChannel with the specified Stream ID.
- [peer_connection_lookup_sid](#peer_connection_lookup_sid): Looks up the Stream ID of a DataChannel by label.
- [peer_connection_lookup_sid_label](#peer_connection_lookup_sid_label): Looks up the label of a DataChannel by Stream ID.
- [peer_connection_send_audio](#peer_connection_send_audio): Sends audio data.
- [peer_connection_send_video](#peer_connection_send_video): Sends video data.
- [peer_connection_on_receiver_packet_loss](#peer_connection_on_receiver_packet_loss): Registers a receiver packet loss callback.
- [peer_connection_get_sctp](#peer_connection_get_sctp): Gets the Sctp instance pointer.

##### Data Types

The PeerConnection module uses the following data types and enumerations:

**SdpType**

SDP type enumeration used to distinguish Offers and Answers.

| Enumeration Value | Description |
|---|---|
| SDP_TYPE_OFFER | SDP Offer. |
| SDP_TYPE_ANSWER | SDP Answer. |

**PeerConnectionState**

PeerConnection connection state enumeration.

| Enumeration Value | Description |
|---|---|
| PEER_CONNECTION_CLOSED | The connection has been closed. |
| PEER_CONNECTION_NEW | A new connection that has not yet begun ICE negotiation. |
| PEER_CONNECTION_CHECKING | ICE connection checks are in progress. |
| PEER_CONNECTION_CONNECTED | At least one ICE candidate pair has connected successfully. |
| PEER_CONNECTION_COMPLETED | All ICE candidate pair checks have completed and the connection has been established. |
| PEER_CONNECTION_FAILED | The ICE connection check failed. |
| PEER_CONNECTION_DISCONNECTED | The connection has been disconnected. |

**DataChannelType**

DataChannel data type enumeration.

| Enumeration Value | Description |
|---|---|
| DATA_CHANNEL_NONE | No DataChannel. |
| DATA_CHANNEL_STRING | String-type DataChannel. |
| DATA_CHANNEL_BINARY | Binary-type DataChannel. |

**DecpChannelType**

DataChannel transport reliability type enumeration used to specify transport characteristics when creating a DataChannel.

| Enumeration Value | Description |
|---|---|
| DATA_CHANNEL_RELIABLE | Reliable, ordered transmission. |
| DATA_CHANNEL_RELIABLE_UNORDERED | Reliable, unordered transmission. |
| DATA_CHANNEL_PARTIAL_RELIABLE_REXMIT | Partially reliable with retransmission guarantees. |
| DATA_CHANNEL_PARTIAL_RELIABLE_REXMIT_UNORDERED | Partially reliable, unordered, with retransmission guarantees. |
| DATA_CHANNEL_PARTIAL_RELIABLE_TIMED | Partially reliable with timeout guarantees. |
| DATA_CHANNEL_PARTIAL_RELIABLE_TIMED_UNORDERED | Partially reliable, unordered, with timeout guarantees. |

**MediaCodec**

Media codec type enumeration.

| Enumeration Value | Description |
|---|---|
| CODEC_NONE | No codec. |
| CODEC_H264 | H.264 video codec. |
| CODEC_H265 | H.265 video codec. |
| CODEC_VP8 | VP8 video codec (not yet implemented). |
| CODEC_MJPEG | MJPEG video codec (not yet implemented). |
| CODEC_OPUS | Opus audio codec. |
| CODEC_PCMA | G.711A audio codec. |
| CODEC_PCMU | G.711U audio codec. |

**IceServer**

ICE server configuration structure.

```c
typedef struct IceServer {
  const char* urls;       // ICE server URL (e.g. "stun:stun.l.google.com:19302")
  const char* username;   // Username (required for TURN servers)
  const char* credential; // Credential (required for TURN servers)
} IceServer;
```

**PeerConfiguration**

PeerConnection configuration structure passed when creating a PeerConnection.

```c
typedef struct PeerConfiguration {
  IceServer ice_servers[5];           // ICE server list, up to 5 entries
  MediaCodec audio_codec;             // Audio codec type
  uint32_t audio_sample_rate;         // Audio sample rate (Hz, e.g. 8000), used for Opus fmtp constraints on browser encoders
  MediaCodec video_codec;             // Video codec type
  DataChannelType datachannel;        // DataChannel data type
  void (*onaudiotrack)(uint8_t* data, size_t size, void* userdata);   // Audio frame reception callback
  void (*onvideotrack)(uint8_t* data, size_t size, void* userdata);   // Video frame reception callback
  void (*on_request_keyframe)(void* userdata);                        // Keyframe request callback
  void* user_data;                    // User data pointer passed to each callback function
} PeerConfiguration;
```

##### peer_connection_create

【Description】

Creates a PeerConnection instance.

【Syntax】

```c
PeerConnection* peer_connection_create(PeerConfiguration* config);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| config | PeerConnection configuration parameters. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| Non-NULL | Success. Returns a PeerConnection instance pointer. |
| NULL | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

peer_init() must be called before invocation to complete global initialization.

【Example】

None.

【Related Topics】

None.

##### peer_connection_destroy

【Description】

Destroys a PeerConnection instance and releases its resources.

【Syntax】

```c
void peer_connection_destroy(PeerConnection* pc);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |

【Return Value】

None.

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

peer_connection_close() should be called before destruction to close the connection.

【Example】

None.

【Related Topics】

None.

##### peer_connection_close

【Description】

Closes the PeerConnection connection.

【Syntax】

```c
void peer_connection_close(PeerConnection* pc);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |

【Return Value】

None.

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_loop

【Description】

Drives the PeerConnection event loop to handle network transmission and reception and state updates. It must be called periodically in the main loop.

【Syntax】

```c
int peer_connection_loop(PeerConnection* pc);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

This function should continue to be called after the connection has been established to maintain normal connection operation.

【Example】

None.

【Related Topics】

None.

##### peer_connection_get_state

【Description】

Gets the current PeerConnection connection state.

【Syntax】

```c
PeerConnectionState peer_connection_get_state(PeerConnection* pc);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| PeerConnectionState enumeration value | Current connection state. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_state_to_string

【Description】

Converts a PeerConnectionState enumeration value to a readable string.

【Syntax】

```c
const char* peer_connection_state_to_string(PeerConnectionState state);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| state | PeerConnection connection state enumeration value. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| Non-NULL | Success. Returns the string corresponding to the state. |
| NULL | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_create_offer

【Description】

Creates an SDP Offer to initiate WebRTC connection negotiation. After the call, use the peer_connection_onicecandidate callback to obtain ICE candidate information.

【Syntax】

```c
const char* peer_connection_create_offer(PeerConnection* pc);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| Non-NULL | Success. Returns the SDP Offer string. |
| NULL | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

The returned SDP string remains valid until the next call to this function. Make a copy yourself if it must be retained long-term.

【Related Topics】

None.

##### peer_connection_create_answer

【Description】

Creates an SDP Answer to respond to a remote SDP Offer. It must be called after calling peer_connection_set_remote_description to set the remote Offer.

【Syntax】

```c
const char* peer_connection_create_answer(PeerConnection* pc);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| Non-NULL | Success. Returns the SDP Answer string. |
| NULL | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

The returned SDP string remains valid until the next call to this function. Make a copy yourself if it must be retained long-term.

【Related Topics】

None.

##### peer_connection_set_local_description

【Description】

Sets the local SDP description.

【Syntax】

```c
void peer_connection_set_local_description(PeerConnection* pc, const char* sdp, SdpType sdp_type);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| sdp | SDP description string. | Input |
| sdp_type | SDP type (Offer or Answer). | Input |

【Return Value】

None.

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_set_remote_description

【Description】

Sets the remote SDP description.

【Syntax】

```c
void peer_connection_set_remote_description(PeerConnection* pc, const char* sdp, SdpType sdp_type);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| sdp | Remote SDP description string. | Input |
| sdp_type | SDP type (Offer or Answer). | Input |

【Return Value】

None.

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_add_ice_candidate

【Description】

Adds remote ICE candidate information.

【Syntax】

```c
int peer_connection_add_ice_candidate(PeerConnection* pc, char* ice_candidate);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| ice_candidate | ICE candidate string. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| -1 | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_onicecandidate

【Description】

Registers an ICE candidate callback function, which is triggered when a new ICE candidate is discovered.

【Syntax】

```c
void peer_connection_onicecandidate(PeerConnection* pc, void (*onicecandidate)(char* sdp_text, void* userdata));
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| onicecandidate | ICE candidate callback function. Callback parameters: sdp_text is the ICE candidate SDP text, and userdata is user data. | Input |

【Return Value】

None.

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

The ICE candidate obtained in the callback must be sent to the peer through the signaling channel.

【Related Topics】

None.

##### peer_connection_oniceconnectionstatechange

【Description】

Registers an ICE connection state change callback function, which is triggered when the ICE connection state changes.

【Syntax】

```c
void peer_connection_oniceconnectionstatechange(PeerConnection* pc,
    void (*oniceconnectionstatechange)(PeerConnectionState state, void* userdata));
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| oniceconnectionstatechange | ICE connection state change callback function. Callback parameters: state is the current connection state, and userdata is user data. | Input |

【Return Value】

None.

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_ondatachannel

【Description】

Registers DataChannel event callback functions, including message reception, channel open, and channel close events.

【Syntax】

```c
void peer_connection_ondatachannel(PeerConnection* pc,
    void (*onmessage)(char* msg, size_t len, void* userdata, uint16_t sid),
    void (*onopen)(void* userdata),
    void (*onclose)(void* userdata));
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| onmessage | Message reception callback function. Callback parameters: msg is the message content, len is the message length, userdata is user data, and sid is the Stream ID. | Input |
| onopen | DataChannel open callback function. Callback parameter: userdata is user data. | Input |
| onclose | DataChannel close callback function. Callback parameter: userdata is user data. | Input |

【Return Value】

None.

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_create_datachannel

【Description】

Creates a DataChannel.

【Syntax】

```c
int peer_connection_create_datachannel(PeerConnection* pc, DecpChannelType channel_type,
    uint16_t priority, uint32_t reliability_parameter, char* label, char* protocol);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| channel_type | DataChannel transport reliability type. | Input |
| priority | DataChannel priority. | Input |
| reliability_parameter | Reliability parameter (retransmission count or timeout, depending on channel_type). | Input |
| label | DataChannel label name. | Input |
| protocol | DataChannel protocol name. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_create_datachannel_sid

【Description】

Creates a DataChannel with the specified Stream ID.

【Syntax】

```c
int peer_connection_create_datachannel_sid(PeerConnection* pc, DecpChannelType channel_type,
    uint16_t priority, uint32_t reliability_parameter, char* label, char* protocol, uint16_t sid);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| channel_type | DataChannel transport reliability type. | Input |
| priority | DataChannel priority. | Input |
| reliability_parameter | Reliability parameter. | Input |
| label | DataChannel label name. | Input |
| protocol | DataChannel protocol name. | Input |
| sid | Specified Stream ID. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_datachannel_send

【Description】

Sends a text message through a DataChannel.

【Syntax】

```c
int peer_connection_datachannel_send(PeerConnection* pc, char* message, size_t len);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| message | Message buffer. | Input |
| len | Message length. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_datachannel_send_sid

【Description】

Sends a text message through the DataChannel with the specified Stream ID.

【Syntax】

```c
int peer_connection_datachannel_send_sid(PeerConnection* pc, char* message, size_t len, uint16_t sid);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| message | Message buffer. | Input |
| len | Message length. | Input |
| sid | Stream ID. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_datachannel_send_binary

【Description】

Sends binary data through a DataChannel (PPID=53).

【Syntax】

```c
int peer_connection_datachannel_send_binary(PeerConnection* pc, const char* data, size_t len);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| data | Data buffer. | Input |
| len | Data length. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| -1 | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_datachannel_send_binary_sid

【Description】

Sends binary data through the DataChannel with the specified Stream ID (PPID=53).

【Syntax】

```c
int peer_connection_datachannel_send_binary_sid(PeerConnection* pc, const char* data, size_t len, uint16_t sid);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| data | Data buffer. | Input |
| len | Data length. | Input |
| sid | Stream ID. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| -1 | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_lookup_sid

【Description】

Looks up the corresponding Stream ID by the DataChannel label.

【Syntax】

```c
int peer_connection_lookup_sid(PeerConnection* pc, const char* label, uint16_t* sid);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| label | DataChannel label name. | Input |
| sid | Output Stream ID. | Output |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure (the corresponding DataChannel was not found). |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_lookup_sid_label

【Description】

Looks up the DataChannel label by Stream ID.

【Syntax】

```c
char* peer_connection_lookup_sid_label(PeerConnection* pc, uint16_t sid);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| sid | Stream ID. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| Non-NULL | Success. Returns the label string. |
| NULL | Failure (the corresponding DataChannel was not found). |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_connection_send_audio

【Description】

Sends audio data.

【Syntax】

```c
int peer_connection_send_audio(PeerConnection* pc, const uint8_t* packet, size_t bytes, uint64_t timestamp_us);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| packet | Audio data buffer. | Input |
| bytes | Audio data size (in bytes). | Input |
| timestamp_us | Timestamp (microseconds). | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

The audio data format must match the audio_codec configured in PeerConfiguration.

【Related Topics】

None.

##### peer_connection_send_video

【Description】

Sends video data.

【Syntax】

```c
int peer_connection_send_video(PeerConnection* pc, const uint8_t* packet, size_t bytes, uint64_t timestamp_us);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| packet | Video data buffer. | Input |
| bytes | Video data size (in bytes). | Input |
| timestamp_us | Timestamp (microseconds). | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

The video data format must match the video_codec configured in PeerConfiguration.

【Related Topics】

None.

##### peer_connection_on_receiver_packet_loss

【Description】

Registers a receiver packet loss callback function, which is triggered when an RTCP receiver report is received.

【Syntax】

```c
void peer_connection_on_receiver_packet_loss(PeerConnection* pc,
    void (*on_receiver_packet_loss)(float fraction_loss, uint32_t total_loss, void* userdata));
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |
| on_receiver_packet_loss | Packet loss callback function. Callback parameters: fraction_loss is the packet loss rate (0.0~1.0), total_loss is the total number of lost packets, and userdata is user data. | Input |

【Return Value】

None.

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

Encoding parameters may be dynamically adjusted or a keyframe may be requested based on the packet loss rate.

【Related Topics】

None.

##### peer_connection_get_sctp

【Description】

Gets the SCTP instance pointer for low-level SCTP protocol operations.

【Syntax】

```c
void* peer_connection_get_sctp(PeerConnection* pc);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| pc | PeerConnection instance pointer. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| Non-NULL | Success. Returns the SCTP instance pointer. |
| NULL | Failure. |

【Requirements】

- Header file: peer_connection.h
- Library file: libpeer.a

【Note】

This is a low-level interface and is generally not required by applications.

【Related Topics】

None.

#### PeerSignaling

The PeerSignaling module provides signaling service connection and communication functions, supporting interaction with the signaling server via HTTP or MQTT to complete SDP exchange and ICE candidate delivery for WebRTC connections. This module can be disabled at compile time by defining the `DISABLE_PEER_SIGNALING` macro.

The PeerSignaling module provides the following APIs:

- [peer_signaling_connect](#peer_signaling_connect): Connects to the signaling server.
- [peer_signaling_disconnect](#peer_signaling_disconnect): Disconnects from the signaling server.
- [peer_signaling_loop](#peer_signaling_loop): Drives the signaling event loop.
- [peer_signaling_set_custom_rpc_handler](#peer_signaling_set_custom_rpc_handler): Registers a callback for handling custom RPC methods.
- [peer_signaling_publish](#peer_signaling_publish): Publishes a message through the MQTT connection at the signaling layer.

##### peer_signaling_connect

【Description】

Connects to the signaling server and establishes a communication channel with the signaling service.

【Syntax】

```c
int peer_signaling_connect(const char* url, const char* token, PeerConnection* pc);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| url | Signaling server URL. | Input |
| token | Authentication token. | Input |
| pc | Pointer to a PeerConnection instance. | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_signaling.h
- Library file: libpeer.a

【Note】

A PeerConnection instance must be created before calling this function.

【Example】

None.

【Related Topics】

None.

##### peer_signaling_disconnect

【Description】

Disconnects from the signaling server.

【Syntax】

```c
void peer_signaling_disconnect();
```

【Parameters】

None.

【Return Value】

None.

【Requirements】

- Header file: peer_signaling.h
- Library file: libpeer.a

【Note】

None.

【Related Topics】

None.

##### peer_signaling_loop

【Description】

Drives the signaling event loop and processes the sending and receiving of signaling messages. It must be called periodically in the main loop.

【Syntax】

```c
int peer_signaling_loop();
```

【Parameters】

None.

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| Nonzero | Failure. |

【Requirements】

- Header file: peer_signaling.h
- Library file: libpeer.a

【Note】

This function should be called continuously after the signaling connection has been established to maintain normal signaling communication.

【Related Topics】

None.

##### peer_signaling_set_custom_rpc_handler

【Description】

Registers a callback for handling custom RPC methods, which is used to process application-layer custom RPC methods not recognized by the signaling layer. It must be called after peer_signaling_connect(). Only one handler callback can be registered at a time, and subsequent calls replace the previous callback. Passing NULL cancels the registration.

【Syntax】

```c
void peer_signaling_set_custom_rpc_handler(peer_signaling_custom_rpc_cb cb, void* userdata);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| cb | Custom RPC method handler callback function. | Input |
| userdata | Pointer to user data passed to the callback function. | Input |

Callback function type definition:

```c
typedef int (*peer_signaling_custom_rpc_cb)(const char* method, cJSON* params, int id,
    cJSON** result, cJSON** error, void* userdata);
```

Callback parameter descriptions:

| Parameter Name | Description | Input/Output |
|---|---|---|
| method | RPC method name (such as "list_recordings"). | Input |
| params | cJSON object for the "params" field (may be NULL). | Input |
| id | JSON-RPC request ID. | Input |
| result | Output: Set to the cJSON result object (the caller takes ownership). | Output |
| error | Output: Set to the cJSON error object (the caller takes ownership). | Output |
| userdata | User data pointer. | Input |

Callback return value:

| Return Value | Description |
|---|---|
| 0 | The method was handled (result or error must be set). |
| -1 | The method was not handled (the signaling layer will return METHOD_NOT_FOUND). |

【Return Value】

None.

【Requirements】

- Header file: peer_signaling.h
- Library file: libpeer.a

【Note】

The callback function is invoked in the signaling thread (peer_signaling_loop), and thread safety must be ensured during implementation.

【Related Topics】

None.

##### peer_signaling_publish

【Description】

Publishes a message to a specified MQTT topic through the existing MQTT connection at the signaling layer, reusing the MQTT connection established by peer_signaling_connect() without creating an additional MQTT client. It is available only in MQTT mode (proto == 0).

【Syntax】

```c
int peer_signaling_publish(const char* topic, const char* message);
```

【Parameters】

| Parameter Name | Description | Input/Output |
|---|---|---|
| topic | MQTT topic (such as "/devices/heartbeat"). | Input |
| message | Message content (JSON string). | Input |

【Return Value】

| Return Value | Description |
|---|---|
| 0 | Success. |
| -1 | Failure (HTTP mode or the MQTT connection has not been established). |

【Requirements】

- Header file: peer_signaling.h
- Library file: libpeer.a

【Note】

- Available only in MQTT signaling mode; calling it in HTTP mode returns -1.
- Must be called after peer_signaling_connect() has successfully established the MQTT connection.

【Related Topics】

None.

#### Typical WebRTC Usage Flow

1. Call `peer_init()` for global initialization.
2. Configure the `PeerConfiguration` structure, including ICE servers, audio and video codec types, callback functions, etc.
3. Call `peer_connection_create()` to create a PeerConnection instance.
4. Register callback functions: `peer_connection_onicecandidate()`, `peer_connection_oniceconnectionstatechange()`, `peer_connection_ondatachannel()`, etc.
5. Exchange SDP and ICE candidates through the application's own HTTP/MQTT/WebSocket signaling, or the optional `peer_signaling_connect()`.
6. Continuously call `peer_connection_loop()` in a controlled thread; when using `peer_signaling`, also call `peer_signaling_loop()`.
7. After the connection enters `PEER_CONNECTION_COMPLETED`, send encoded media data through `peer_connection_send_audio()`/`peer_connection_send_video()`, or send and receive data through a DataChannel.
8. After communication ends, call `peer_signaling_disconnect()` to disconnect the signaling connection, call `peer_connection_close()` to close the PeerConnection, and call `peer_connection_destroy()` to destroy the instance.
9. Call `peer_deinit()` for global de-initialization.
