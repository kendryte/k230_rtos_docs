# libpeer（WebRTC）Description

## Introduction

libpeer is a lightweight C-language WebRTC protocol library integrated into the K230 RT-Smart SDK. It handles ICE, STUN/TURN, DTLS-SRTP, RTP/RTCP, and optional SCTP DataChannel; the application is responsible for capturing and encoding camera data, encoders, signaling servers, and media data.

The library source code is located in `src/rtsmart/libs/3rd-party/libpeer`, and the public headers are:

- `peer.h`: Global initialization and deinitialization.
- `peer_connection.h`: PeerConnection, SDP, ICE, media, and DataChannel APIs.
- `peer_signaling.h`: Optional HTTP/MQTT signaling client APIs.

## Supported Capabilities

| Item | Current Support | Description |
| :-- | :-- | :-- |
| Video RTP | H.264, H.265 | H.264 uses FU-A; H.265 uses RFC 7798 FU fragmentation. |
| Audio RTP | Opus, PCMA, PCMU | libpeer packages already encoded audio and does not provide an audio encoder. |
| Secure Transport | DTLS-SRTP | Uses ECDSA certificates and remote SDP fingerprint verification. |
| Network Connectivity | ICE, STUN, TURN | In LAN scenarios, only host candidates may be used; in public network scenarios, working STUN/TURN and signaling services must be configured. |
| Data Channel | SCTP DataChannel | Uses embedded usrsctp and can be enabled through `PeerConfiguration.datachannel`. |
| Unsupported | VP8, MJPEG video | The `MediaCodec` enumeration retains these values, but there is no RTP implementation for them. |

`sample_webrtc` uses a video-first configuration: H.265 or H.264, no audio, and no DataChannel.

## Build Configuration

Run `make menuconfig` in the SDK root directory:

```text
RT-Smart 3rd-party Configuration
  -> Enable Build libpeer (WebRTC) = Y
```

This option automatically selects cJSON and Mbed TLS. libpeer also builds libsrtp, usrsctp, coreHTTP, and coreMQTT in its own `3rd-party/` directory. The SDK's `lib3rdparty.mk` adds header paths and link dependencies for applications that enable libpeer.

## Basic Lifecycle

Applications must manage objects in the following order:

1. Call `peer_init()`.
2. Populate `PeerConfiguration`, and then call `peer_connection_create()`.
3. Register ICE state and candidate SDP callbacks.
4. Create an Offer or Answer, and send the SDP through the application's own signaling channel.
5. Set the remote SDP; continuously call `peer_connection_loop()` in a controlled thread.
6. Send media or use the DataChannel after the state becomes `PEER_CONNECTION_COMPLETED`.
7. Call `peer_connection_close()`, `peer_connection_destroy()`, and `peer_deinit()`.

`peer_connection_loop()` drives ICE, DTLS, and receive processing. It must be called frequently, and the same `PeerConnection` should not be driven by multiple threads concurrently. The RT-Smart example uses a dedicated thread to call it at approximately 1 ms intervals; media transmission and destruction operations must be serialized by the application.

## Minimal Video Sending Flow

The following code shows the core steps for application-managed SDP signaling. `send_sdp_to_peer()` and `receive_remote_sdp()` are implemented by the application using HTTP, MQTT, or another signaling method.

```c
#include "peer.h"
#include "peer_connection.h"

static void on_ice_candidate(char *sdp, void *userdata)
{
    send_sdp_to_peer(sdp);  /* Application implementation */
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

    /* After receiving the browser Answer: */
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

After the Offer is created, `onicecandidate` receives the complete SDP containing local candidate information. For a LAN web page that does not use trickle ICE, the browser Answer containing browser candidates can be passed in its entirety to `peer_connection_set_remote_description()`.

## Media Data Requirements

The timestamps for both `peer_connection_send_video()` and `peer_connection_send_audio()` are in microseconds.

```c
peer_connection_send_video(pc, h265_annexb, h265_size, pts_us);
peer_connection_send_audio(pc, opus_packet, opus_size, pts_us);
```

- Video input should consist of H.264 or H.265 NAL units in Annex-B format. The `K_VENC_HEADER` generated by VENC should be cached and sent before each I-frame.
- H.264 requires SPS/PPS; H.265 requires VPS/SPS/PPS. Without these parameter sets, newly joined browsers may not be able to reliably decode the first key frame.
- Audio input must already be encoded according to `audio_codec`. Setting `CODEC_OPUS` does not cause libpeer to encode PCM into Opus internally.
- Do not send media data before reaching `PEER_CONNECTION_COMPLETED`.

## ICE and DTLS Behavior

The RT-Smart port uses nonblocking UDP reception and advances the DTLS handshake incrementally, avoiding a long block during a single `peer_connection_loop()` call. ICE connectivity checks are retried every 50 ms by default, with a timeout window of approximately five seconds.

The DTLS-SRTP handshake must still be completed after the network path is established. The SRTP session is created and encrypted RTP can be sent safely only after entering `PEER_CONNECTION_COMPLETED`.

## K230 Example

The SDK provides a runnable LAN camera example:

- Source code: `src/rtsmart/examples/mpp/sample_webrtc`
- Documentation: [WebRTC Demo](../media/webrtc.md)

This example exchanges `GET /offer` and `POST /answer` through a built-in HTTP service, and demonstrates VENC parameter set caching, H.264/H.265 switching, web page reconnection, and orderly exit. It is not the only way to use libpeer; production environments typically require independent implementation of authentication, HTTPS, signaling, and TURN configuration.

## Precautions

- The browser must support the selected video codec. H.264 generally has better compatibility than H.265.
- mDNS candidate privacy protection in Chrome/Edge may prevent embedded peers from communicating over a pure LAN; the `sample_webrtc` web page provides instructions for the corresponding browser settings.
- The SDP and callback parameters stored in `PeerConnection` should not be retained long-term after the callback returns; the application must make its own copies if it needs to retain them.
- During shutdown, first stop media production and the `peer_connection_loop()` thread, and then destroy the `PeerConnection`, preventing the worker thread from accessing already released DTLS/SRTP state.
