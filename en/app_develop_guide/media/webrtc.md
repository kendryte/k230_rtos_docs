# WebRTC Demo

## Introduction

`sample_webrtc` is a LAN WebRTC camera example. It captures camera frames on K230, encodes them using the hardware VENC, and then sends them to the browser through libpeer's ICE, DTLS-SRTP, and RTP links. The example includes an HTTP signaling service and web page, so no separate signaling server deployment is required.

The default configuration targets lower resource usage: `1280 x 720`, H.265, `512 Kbit/s`, with audio and DataChannel disabled. It can be switched to H.264 or adjusted to different resolutions and bitrates through command-line options.

```{important}
This is a LAN example and does not provide authentication, HTTPS, or public network penetration services. The device running the example and the browser must be on a mutually reachable network.
```

## Code Location and Build

- Example source code: `src/rtsmart/examples/mpp/sample_webrtc`
- libpeer source code: `src/rtsmart/libs/3rd-party/libpeer`

Enable the following options in `make menuconfig`:

```text
RT-Smart 3rd-party Configuration
  -> Enable Build libpeer (WebRTC) = Y

RT-Smart UserSpace Examples Configuration
  -> Enable MPP examples = Y
    -> Enable Build sample_webrtc = Y
```

After compiling and starting the development board, the executable is located at `/sdcard/app/examples/mpp/sample_webrtc.elf`.

## Data Flow

```text
VICAP CHN0 -> VO                 Local LCD/HDMI preview
VICAP CHN1 -> VENC (H.265/H.264) -> libpeer -> Browser
                                        ^
                              HTTP: GET /offer
                                    POST /answer
```

The example caches the parameter sets output by the VENC. Before each I-frame is sent, it first sends H.264's SPS/PPS or H.265's VPS/SPS/PPS, allowing the browser to start decoding from a keyframe after the connection is established.

## Command-Line Arguments

| Argument | Description | Default |
| :-- | :-- | :-- |
| `-p port` | HTTP signaling and web port | `8080` |
| `-s csi_num` | CSI device number, ranging from `0` to `2` | `2` |
| `-L lane` | MIPI lane preference: `2` or `4` | ANY |
| `-c connector` | Display connector, `605274512` for LCD, `757006876` for HDMI | LCD |
| `-t type` | Video encoding: `h265` or `h264` | `h265` |
| `-W width` | Encoding width, ranging from `64` to `3840` | `1280` |
| `-H height` | Encoding height, ranging from `64` to `2160` | `720` |
| `-b bitrate` | CBR target bitrate in Kbit/s, ranging from `100` to `20000` | `512` |

At the same bitrate, H.265 generally uses less bandwidth than H.264, but whether the browser can play H.265 depends on the platform and the installed system codecs. Use H.264 when compatibility is the priority.

## Example Usage

Using the default low-bitrate H.265:

```shell
cd /sdcard/app/examples/mpp
./sample_webrtc.elf
```

Using the more widely supported H.264:

```shell
./sample_webrtc.elf -t h264 -W 1280 -H 720 -b 512
```

When selecting 4LANE (supported only by CSI0), append `-s 0 -L 4`; for CSI1 / CSI2, omit `-L 4` or use `-L 2`.

After startup, the serial console outputs the access address, for example:

```text
libpeer LAN Camera Demo
Encode: 1280x720 @ 512kbps H265
Open in browser:
http://192.168.1.108:8080
```

Open this address in the browser and click **Connect**. The web page requests `/offer`, creates the browser Answer, and then returns it to the development board through `POST /answer`. After DTLS-SRTP establishment completes, the status transitions from `CHECKING` and `CONNECTED` to `COMPLETED`, after which video display begins.

Pressing `Ctrl+C` stops the HTTP, VENC, and PeerConnection worker threads in sequence and releases the media resources.

## Connection and Performance

On RT-Smart, libpeer uses non-blocking UDP reception and incremental DTLS handshakes to prevent ICE/DTLS waits from blocking the video transmission thread. LAN ICE connectivity checks are retried at 50 ms intervals, with a failure window of approximately five seconds.

Connection time still depends on the browser's candidate collection, Wi-Fi quality, and DTLS round-trip time. The video start time also depends on receiving the first keyframe with parameter sets. Low-bitrate configurations can reduce encoding and network load; when higher picture quality is needed, increase `-b` gradually instead of directly increasing both the resolution and bitrate.

## Browser Requirements and Troubleshooting

| Symptom | Resolution |
| :-- | :-- |
| Connected but no image displayed | First retry with `-t h264` to confirm that the browser and system support H.265. |
| The page indicates mDNS privacy protection | Chrome/Edge may hide browser candidate addresses as `.local`. Follow the instructions on the page to disable `WebRtcHideLocalIpsWithMdns` and then restart the browser, or use Firefox. |
| Remains in Connecting/Checking | Confirm that the browser and development board are on the same mutually reachable subnet, and that UDP traffic is not blocked by AP isolation or a firewall. |
| Video only, with no sound | This is the expected behavior of the example; the example uses `CODEC_NONE` by default and does not create an audio link. |
| Connection fails again | Use Disconnect on the page before connecting again; this example serves only one browser session at a time. |

For the libpeer API, supported encoding formats, and custom signaling methods, see [libpeer (WebRTC) Documentation](../3rd-party/libpeer.md).
