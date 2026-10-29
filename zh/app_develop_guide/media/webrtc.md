# WebRTC Demo

## 简介

`sample_webrtc` 是一个局域网 WebRTC 摄像头示例。它在 K230 上采集摄像头画面，经硬件 VENC 编码后通过 libpeer 的 ICE、DTLS-SRTP 和 RTP 链路发送到浏览器。示例自带 HTTP 信令服务和网页，无需单独部署信令服务器。

默认配置面向较低的资源占用：`1280 x 720`、H.265、`512 Kbit/s`、不启用音频和 DataChannel。可通过命令行切换为 H.264 或调整分辨率、码率。

```{important}
这是局域网示例，不提供鉴权、HTTPS 或公网穿透服务。运行设备与浏览器需要处于可互通的网络中。
```

## 代码位置和编译

- 示例源码：`src/rtsmart/examples/mpp/sample_webrtc`
- libpeer 源码：`src/rtsmart/libs/3rd-party/libpeer`

在 `make menuconfig` 中启用以下选项：

```text
RT-Smart 3rd-party Configuration
  -> Enable Build libpeer (WebRTC) = Y

RT-Smart UserSpace Examples Configuration
  -> Enable MPP examples = Y
    -> Enable Build sample_webrtc = Y
```

编译并启动开发板后，可执行文件位于 `/sdcard/app/examples/mpp/sample_webrtc.elf`。

## 数据流程

```text
VICAP CHN0 -> VO                 本地 LCD/HDMI 预览
VICAP CHN1 -> VENC (H.265/H.264) -> libpeer -> 浏览器
                                        ^
                              HTTP: GET /offer
                                    POST /answer
```

示例会缓存 VENC 输出的参数集。每个 I 帧发送前都会先发送 H.264 的 SPS/PPS 或 H.265 的 VPS/SPS/PPS，使浏览器在连接建立后能够从关键帧开始解码。

## 命令行参数

| 参数 | 含义 | 默认值 |
| :-- | :-- | :-- |
| `-p port` | HTTP 信令和网页端口 | `8080` |
| `-s csi_num` | CSI 设备号，范围 `0` 到 `2` | `2` |
| `-L lane` | MIPI lane 偏好：`2` 或 `4` | ANY |
| `-c connector` | 显示连接器，`605274512` 为 LCD，`757006876` 为 HDMI | LCD |
| `-t type` | 视频编码：`h265` 或 `h264` | `h265` |
| `-W width` | 编码宽度，范围 `64` 到 `3840` | `1280` |
| `-H height` | 编码高度，范围 `64` 到 `2160` | `720` |
| `-b bitrate` | CBR 目标码率，单位 Kbit/s，范围 `100` 到 `20000` | `512` |

H.265 在相同码率下通常比 H.264 更节省带宽，但浏览器是否能播放 H.265 取决于平台和安装的系统编解码器。兼容性优先时使用 H.264。

## 运行示例

使用默认的低码率 H.265：

```shell
cd /sdcard/app/examples/mpp
./sample_webrtc.elf
```

使用更通用的 H.264：

```shell
./sample_webrtc.elf -t h264 -W 1280 -H 720 -b 512
```

需要选择 4LANE 时（仅 CSI0 支持）追加 `-s 0 -L 4`；CSI1 / CSI2 请省略 `-L 4` 或使用 `-L 2`。

启动后串口会输出访问地址，例如：

```text
libpeer LAN Camera Demo
Encode: 1280x720 @ 512kbps H265
Open in browser:
http://192.168.1.108:8080
```

在浏览器打开该地址并点击 **Connect**。网页请求 `/offer`，创建浏览器 Answer 后通过 `POST /answer` 返回开发板。DTLS-SRTP 建立完成后，状态会从 `CHECKING`、`CONNECTED` 进入 `COMPLETED`，随后开始显示视频。

按 `Ctrl+C` 会按顺序停止 HTTP、VENC 和 PeerConnection 工作线程并释放媒体资源。

## 连接和性能

libpeer 在 RT-Smart 上使用非阻塞 UDP 接收和增量 DTLS 握手，避免 ICE/DTLS 等待阻塞视频发送线程。局域网 ICE 连通性检查以 50 ms 的间隔重试，并保持约五秒的失败窗口。

连接时间仍取决于浏览器收集候选地址、Wi-Fi 质量和 DTLS 往返时间。视频开始时间还取决于接收到首个带参数集的关键帧。低码率配置可降低编码与网络负载；需要更高画质时逐步提高 `-b`，不要直接提高分辨率和码率两项。

## 浏览器要求和排障

| 现象 | 处理方法 |
| :-- | :-- |
| 已连接但没有画面 | 先以 `-t h264` 重试，确认浏览器和系统支持 H.265。 |
| 页面提示 mDNS 隐私保护 | Chrome/Edge 可能把浏览器候选地址隐藏为 `.local`。按页面提示关闭 `WebRtcHideLocalIpsWithMdns` 后重启浏览器，或使用 Firefox。 |
| 一直处于 Connecting/Checking | 确认浏览器和开发板在同一可互通网段，且 UDP 未被 AP 隔离或防火墙拦截。 |
| 只有视频，没有声音 | 这是示例的预期行为；示例默认 `CODEC_NONE`，且不创建音频链路。 |
| 再次连接失败 | 使用页面的 Disconnect 后再 Connect；该示例一次只服务一个浏览器会话。 |

有关 libpeer 的 API、支持的编码格式和自定义信令方式，请参阅 [libpeer（WebRTC）说明](../3rd-party/libpeer.md)。
