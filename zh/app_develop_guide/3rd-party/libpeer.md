# libpeer（WebRTC）说明

## 简介

libpeer 是 K230 RT-Smart SDK 集成的轻量级 C 语言 WebRTC 协议库。它负责 ICE、STUN/TURN、DTLS-SRTP、RTP/RTCP 和可选 SCTP DataChannel；应用负责摄像头、编码器、信令服务器以及媒体数据的采集和编码。

库源码位于 `src/rtsmart/libs/3rd-party/libpeer`，公开头文件为：

- `peer.h`：全局初始化和反初始化。
- `peer_connection.h`：PeerConnection、SDP、ICE、媒体和 DataChannel API。
- `peer_signaling.h`：可选的 HTTP/MQTT 信令客户端 API。

## 支持能力

| 项目 | 当前支持 | 说明 |
| :-- | :-- | :-- |
| 视频 RTP | H.264、H.265 | H.264 使用 FU-A；H.265 使用 RFC 7798 FU 分片。 |
| 音频 RTP | Opus、PCMA、PCMU | libpeer 打包已有的编码音频，不提供音频编码器。 |
| 安全传输 | DTLS-SRTP | 使用 ECDSA 证书和远端 SDP 指纹校验。 |
| 网络连通 | ICE、STUN、TURN | 局域网场景可以只使用主机候选；公网场景需要配置可用的 STUN/TURN 与信令服务。 |
| 数据通道 | SCTP DataChannel | 使用内嵌 usrsctp，可按 `PeerConfiguration.datachannel` 启用。 |
| 不支持 | VP8、MJPEG 视频 | `MediaCodec` 枚举保留了这些值，但没有 RTP 实现。 |

`sample_webrtc` 选择了视频优先的配置：H.265 或 H.264、无音频、无 DataChannel。

## 编译配置

在 SDK 根目录执行 `make menuconfig`：

```text
RT-Smart 3rd-party Configuration
  -> Enable Build libpeer (WebRTC) = Y
```

该选项会自动选择 cJSON 和 Mbed TLS。libpeer 还在自己的 `3rd-party/` 目录中构建 libsrtp、usrsctp、coreHTTP 和 coreMQTT。SDK 的 `lib3rdparty.mk` 会为启用 libpeer 的应用补充头文件路径和链接依赖。

## 基本生命周期

应用必须以如下顺序管理对象：

1. 调用 `peer_init()`。
2. 填充 `PeerConfiguration`，然后调用 `peer_connection_create()`。
3. 注册 ICE 状态和候选 SDP 回调。
4. 创建 Offer 或 Answer，并经应用自己的信令通道发送 SDP。
5. 设置远端 SDP；在一个受控的线程中持续调用 `peer_connection_loop()`。
6. 当状态为 `PEER_CONNECTION_COMPLETED` 后发送媒体或使用 DataChannel。
7. 调用 `peer_connection_close()`、`peer_connection_destroy()` 和 `peer_deinit()`。

`peer_connection_loop()` 驱动 ICE、DTLS 和接收处理，必须高频调用，且同一个 `PeerConnection` 不应被多个线程同时驱动。RT-Smart 示例使用独立线程以约 1 ms 的节拍调用它；媒体发送与销毁操作需要由应用做好串行化。

## 最小视频发送流程

以下代码展示应用管理 SDP 信令的核心步骤。`send_sdp_to_peer()` 和 `receive_remote_sdp()` 由应用通过 HTTP、MQTT 或其他信令方式实现。

```c
#include "peer.h"
#include "peer_connection.h"

static void on_ice_candidate(char *sdp, void *userdata)
{
    send_sdp_to_peer(sdp);  /* 应用实现 */
}

static void on_state(PeerConnectionState state, void *userdata)
{
    printf("WebRTC: %s\n", peer_connection_state_to_string(state));
}

int start_peer(void)
{
    PeerConfiguration config = {0};
    config.video_codec = CODEC_H265;
    config.audio_codec = CODEC_NONE;
    config.datachannel = DATA_CHANNEL_NONE;

    if (peer_init() != 0) {
        return -1;
    }

    PeerConnection *pc = peer_connection_create(&config);
    if (pc == NULL) {
        peer_deinit();
        return -1;
    }

    peer_connection_onicecandidate(pc, on_ice_candidate);
    peer_connection_oniceconnectionstatechange(pc, on_state);

    const char *offer = peer_connection_create_offer(pc);
    if (offer != NULL) {
        send_sdp_to_peer(offer);
    }

    /* 收到浏览器 Answer 后： */
    const char *answer = receive_remote_sdp();
    peer_connection_set_remote_description(pc, answer, SDP_TYPE_ANSWER);

    while (peer_connection_get_state(pc) != PEER_CONNECTION_FAILED) {
        peer_connection_loop(pc);
        usleep(1000);
    }

    peer_connection_close(pc);
    peer_connection_destroy(pc);
    peer_deinit();
    return 0;
}
```

创建 Offer 后，`onicecandidate` 接收的是包含本地候选信息的完整 SDP。对于非 trickle ICE 的局域网网页，可将浏览器 Answer（包含浏览器候选）整体传给 `peer_connection_set_remote_description()`。

## 媒体数据要求

`peer_connection_send_video()` 和 `peer_connection_send_audio()` 的时间戳单位均为微秒。

```c
peer_connection_send_video(pc, h265_annexb, h265_size, pts_us);
peer_connection_send_audio(pc, opus_packet, opus_size, pts_us);
```

- 视频输入应为 Annex-B 格式的 H.264 或 H.265 NAL 单元。VENC 产生的 `K_VENC_HEADER` 应缓存起来，并在每个 I 帧前发送。
- H.264 需要 SPS/PPS；H.265 需要 VPS/SPS/PPS。缺少这些参数集时，新加入的浏览器不能可靠解码首个关键帧。
- 音频输入必须已经按照 `audio_codec` 编码。设置 `CODEC_OPUS` 不会在 libpeer 内部把 PCM 编码为 Opus。
- 在 `PEER_CONNECTION_COMPLETED` 前不要发送媒体数据。

## ICE 和 DTLS 行为

RT-Smart 移植层使用非阻塞 UDP 接收，并使 DTLS 握手以增量方式推进，避免在一次 `peer_connection_loop()` 调用中长时间阻塞。ICE 连通性检查默认每 50 ms 重试，超时窗口约为五秒。

网络路径建立后仍须经过 DTLS-SRTP 握手。只有进入 `PEER_CONNECTION_COMPLETED`，SRTP 会话才已创建并可安全发送加密 RTP。

## K230 示例

SDK 提供可运行的局域网摄像头示例：

- 源码：`src/rtsmart/examples/mpp/sample_webrtc`
- 文档：[WebRTC Demo](../media/webrtc.md)

该示例通过内置 HTTP 服务交换 `GET /offer` 和 `POST /answer`，并展示 VENC 参数集缓存、H.264/H.265 切换、网页重连以及有序退出。它不是 libpeer 唯一的使用方式；生产环境通常应自行实现鉴权、HTTPS、信令和 TURN 配置。

## 注意事项

- 浏览器必须支持所选视频编码。H.264 的兼容性通常高于 H.265。
- Chrome/Edge 的 mDNS 候选隐私保护可能阻碍纯局域网的嵌入式对端；`sample_webrtc` 的网页会提示相应的浏览器设置。
- `PeerConnection` 中保存的 SDP 和回调参数不应在回调返回后长期借用；应用需要保存时请自行复制。
- 关闭时先停止媒体生产和 `peer_connection_loop()` 线程，再销毁 `PeerConnection`，避免工作线程访问已经释放的 DTLS/SRTP 状态。
