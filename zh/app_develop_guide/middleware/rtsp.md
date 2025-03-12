# Rtsp Demo

## 简介

本示例介绍如何使用RTSP协议在K230板子上进行音视频数据的传输。通过以下示例，您将学习如何使用api接口设置RTSP服务器、客户端以及推流器，以实现实时音视频数据的传输和接收。

- **RTSP Server**: 介绍如何将板子上的sensor画面和音频通过RTSP协议输出，客户端可以通过拉取RTSP流获取音视频数据。
- **RTSP Client**: 介绍如何作为客户端从RTSP服务器获取音视频流，并将视频数据显示在HDMI输出显示器上。
- **RTSP Pusher**: 介绍如何将板子上的sensor画面推流到第三方流媒体服务器，客户端可以通过流媒体服务器拉取RTSP流获取音视频数据。

## 使用说明

### 代码位置

- **RTSP Server**：`canmv_k230/src/rtsmart/mpp/middleware/sample/sample_rtspserver`
- **RTSP Client**：`canmv_k230/src/rtsmart/mpp/middleware/sample/sample_rtspclient`
- **RTSP Pusher**：`canmv_k230/src/rtsmart/mpp/middleware/sample/sample_rtsppusher`

假设 demo 已正确编译，启动开发板后进入 `/sdcard/app/middleware` 目录，您将看到以下可执行文件：

- `sample_rtspserver.elf`：对应 RTSP Server demo
- `sample_rtspclient.elf`：对应 RTSP Client demo
- `sample_rtsppusher.elf`：对应 RTSP Pusher demo

确保这些文件存在并且已正确编译，以便在开发板上运行相应的示例程序。

## 示例

### 示例1: rtsp server

该示例介绍了如何使用RTSP协议实时将板子上的sensor画面和采集到的音频输出。通过拉取RTSP流，客户端可以获取到板子上的音视频数据。

#### 参数说明

| 参数名 | 描述 |参数范围 | 默认值 |
|:--|:--|:--|:--|
| H | 打印命令行参数信息 | - | - |
| t | 编码类型 | h264、h265 | h265 |
| w | 视频编码宽度 | `[128, 1920]` | 1280 |
| h | 视频编码高度 | `[64, 1080]` |720 |
| b | 视频编码码率 | - | 2000 |

#### 运行程序

启动RTSP服务器后，串口输出将显示一个类似 `rtsp://<server_ip>:8554/test` 的URL地址。客户端可以使用VLC播放器打开该URL地址，以获取板子上的实时音视频数据。

```shell
./sample_rtspserver.elf -t h264 -w 1280 -h 720
```

确保客户端设备与服务器在同一网络下，并将 `<server_ip>` 替换为实际的服务器IP地址。
按下 `ctrl+c` 退出程序。

```text
msh /sdcard/app/middleware>./sample_rtspserver.elf -t h264 -w 1280 -h 720
./rtsp_server -H to show usage
Validate the input config, not implemented yet, TODO.
probe sensor type 7, mirror 0
detect sensor type: 7
with_video
with_audio
g711liveSubSession

"test" stream
Play this stream using the URL "rtsp://10.100.228.46:8554/test"
vb_set_config ok
debug: _ai_i2s_set_pitch_shift : semitones = 0
kd_mpi_venc_init start 0
venc[0] 1280*720 size:462848 cnt:30 srcfps:30 dstfps:30 rate:4000 rc_mode:1 type:96 profile:3
kd_mpi_venc_init end
audio i2s set clk freq is 512000(512000),ret:1
audio init codec dac clk freq is 11289600
audio set codec dac clk freq is 2048000(2048000)
adec_bind_call_back dev_id:0 chn_id:0
audio i2s set clk freq is 512000(512000),ret:1
audio codec adc clk freq is 2048000(2048000)
set output err, set default format ISP_PIX_FMT_YUV420SP
[tuning] dev: 0
acq_win.width: 1920
acq_win.height: 1080
pipe_ctrl: 4294967289
sensor_fd: 12
sensor_type: 7
sensor_name: ov5647_csi0
database_name: ov5647-1920x1080
buffer_num: 0
buffer_size: 0
[tuning] chn: 0
out_win.width: 1280
out_win.height: 720
bit_width: 0
pix_format: 5
buffer_num: 6
buffer_size: 1382400
yraw_size: 0
uv_size: 0
v_size: 0
block_type: 1
wait_time: 500
chn_enable: 1
isp_3dnr_en is 0 g_isp_dev_ctx[dev_num].dev_attr.pipe_ctrl.bits.dnr3_enable is 1
VsiCamDeviceCreate hw:0-vt:0 created!
kd_mpi_isp_set_output_chn_format, width(1920), height(1080), pix_format(5)
[dw] init, version Feb 17 2025 00:06:56
[dw] open dewarp config file error
[dw] load config /bin/ov5647-1920x1080.bin failed, bypass
[dw] enter kd_mpi_sys_mmz_alloc((k_u64*)&settings->lut_phy_addr, &settings->lut_user_virt_addr, "dewarp/lut", "anonymous", settings->lut_size)
[dw] enter dev_fds[dev_num] < 0
[dw] enter ioctl(dev_fds[dev_num], K_DWVIOC_SETUP, settings)
[dw] split: 0 8191 8191 8191
[dw] LUT: 121x69=33396 phy(130ac000)
[dw] input:     1920x1080@YUV420SP align 0 bit 8
[dw] output[0]: 1280x720@YUV420SP align 12 bit 8 crop(0,0,0,0)
^Cexit_flag true
kd_mpi_isp_stop_stream chn enable is 1
kd_mpi_isp_stop_stream chn enable is 0
kd_mpi_isp_stop_stream chn enable is 0
release reserved vb 268832768
ch 0: 253 pictures encoded. Average FrameRate = 30 Fps
adec_bind_call_back dev_id:0 chn_id:0
ch 0: total used pages 921
vpu_exit>q_wm 118
```

### 示例2: rtsp client

该示例介绍了如何使用RTSP协议作为客户端从RTSP服务器获取音频和视频流，并将视频数据显示在HDMI输出显示器上。

#### 参数说明

| 参数名 | 描述 | 参数范围 | 默认值 |
|:--|:--|:--|:--|
| H | 打印命令行参数信息 | - | - |
| rtsp_url | RTSP流地址 | - | - |
| out_type | 输出类型 | 1: HDMI, 2: LCD | 1 |

#### 运行程序

拉取服务器端的rtsp流数据，并将视频输出到HDMI显示器。

```shell
./sample_rtspclient.elf rtsp_url 1 # hdmi 显示
#./sample_rtspclient.elf rtsp_url 2 # LCD  显示
```

确保客户端设备与服务器在同一网络下，并将 `<rtsp_url>` 替换为实际的RTSP流地址。
按下 `ctrl+c` 退出程序。

```text
msh /sdcard/app/middleware>./sample_rtspclient.elf rtsp://10.10.1.94:8554/canaan.264 1
vb_set_config ok
debug: _ai_i2s_set_pitch_shift : semitones = 0
Created new TCP socket 9 for connection
Connecting to 10.10.1.94, port 8554 on socket 9...
...remote connection opened
Sending request: DESCRIBE rtsp://10.10.1.94:8554/canaan.264 RTSP/1.0
CSeq: 2
User-Agent: BackChannel RTSP Client (LIVE555 Streaming Media v2023.01.19)
Accept: application/sdp


Received 691 new bytes of response data.
Received a complete DESCRIBE response:
RTSP/1.0 200 OK
CSeq: 2
Date: Tue, Mar 04 2025 08:14:16 GMT
Content-Base: rtsp://10.10.1.94:8554/canaan.264/
Content-Type: application/sdp
Content-Length: 524

v=0
o=- 1741076056720017 1 IN IP4 10.10.1.94
s=H.264 Video, streamed by the LIVE555 Media Server
i=canaan.264
t=0 0
a=tool:LIVE555 Streaming Media v2023.03.30
a=type:broadcast
a=control:*
a=range:npt=now-
a=x-qt-text-nam:H.264 Video, streamed by the LIVE555 Media Server
a=x-qt-text-inf:canaan.264
m=video 0 RTP/AVP 96
c=IN IP4 0.0.0.0
b=AS:500
a=rtpmap:96 H264/90000
a=fmtp:96 packetization-mode=1;profile-level-id=640028;sprop-parameter-sets=Z2QAKKzZQHgCJ+XARAAAAwAEAAADAPA8YMZY,aOvjyyLA
a=control:track1

[URL:"rtsp://10.10.1.94:8554/canaan.264/"]: Got a SDP description:
v=0
o=- 1741076056720017 1 IN IP4 10.10.1.94
s=H.264 Video, streamed by the LIVE555 Media Server
i=canaan.264
t=0 0
a=tool:LIVE555 Streaming Media v2023.03.30
a=type:broadcast
a=control:*
a=range:npt=now-
a=x-qt-text-nam:H.264 Video, streamed by the LIVE555 Media Server
a=x-qt-text-inf:canaan.264
m=video 0 RTP/AVP 96
c=IN IP4 0.0.0.0
b=AS:500
a=rtpmap:96 H264/90000
a=fmtp:96 packetization-mode=1;profile-level-id=640028;sprop-parameter-sets=Z2QAKKzZQHgCJ+XARAAAAwAEAAADAPA8YMZY,aOvjyyLA
a=control:track1

MediaSubsession::initiate()  FLAG_RECVONLY
[URL:"rtsp://10.10.1.94:8554/canaan.264/"]: Initiated the "video/H264" subsession (client ports 49154-49155)
Sending request: SETUP rtsp://10.10.1.94:8554/canaan.264/track1 RTSP/1.0
CSeq: 3
User-Agent: BackChannel RTSP Client (LIVE555 Streaming Media v2023.01.19)
Transport: RTP/AVP;unicast;client_port=49154-49155


Received 213 new bytes of response data.
Received a complete SETUP response:
RTSP/1.0 200 OK
CSeq: 3
Date: Tue, Mar 04 2025 08:14:16 GMT
Transport: RTP/AVP;unicast;destination=10.100.228.46;source=10.10.1.94;client_port=49154-49155;server_port=6970-6971
Session: 5F0B692D;timeout=65


[URL:"rtsp://10.10.1.94:8554/canaan.264/"]: Set up the "video/H264" subsession (client ports 49154-49155)
[URL:"rtsp://10.10.1.94:8554/canaan.264/"]: Created a data sink for the "video/H264" subsession
OnVideoType() called, type H264
input_pool_id = 2
output_pool_id = 3
VDEC: pool_id 3, frame_buf_pool_id 3
connector_fd  is 13 ret is 0
[D/lt9611] vtotal 1125 vactive 1080 htotal_sys 400

Sending request: PLAY rtsp://10.10.1.94:8554/canaan.264/ RTSP/1.0
CSeq: 4
User-Agent: BackChannel RTSP Client (LIVE555 Streaming Media v2023.01.19)
Session: 5F0B692D
Range: npt=0.000-


Received 187 new bytes of response data.
Received a complete PLAY response:
RTSP/1.0 200 OK
CSeq: 4
Date: Tue, Mar 04 2025 08:14:17 GMT
Range: npt=0.000-
Session: 5F0B692D
RTP-Info: url=rtsp://10.10.1.94:8554/canaan.264/track1;seq=14854;rtptime=980441214


[URL:"rtsp://10.10.1.94:8554/canaan.264/"]: continueAfterPLAY
[URL:"rtsp://10.10.1.94:8554/canaan.264/"]: Started playing session...
[URL:"rtsp://10.10.1.94:8554/canaan.264/"]: continueAfterPLAY done
VDEC: first pts 156696845161140, frame_interval 0
VDEC: first pts 156696845161140, frame_interval 3000
^CKdRtspClient thread exit
235 pictures decoded. Average FrameRate = 29 Fps
vpu report fps 30
KdMedia::StopVDecVo() : EOS done
vpu_exit>q_wm 16

```

注：服务器rtsp server搭建方式有多种，如：使用live555 中的Meidaserver输出rtsp地址， 使用上例中的rtsp server输出rtsp地址。

### 示例3: rtsp pusher

该示例介绍了如何使用RTSP协议实时将板子上的sensor画面推流到三方流媒体服务器。通过从流媒体服务器拉取RTSP流，客户端可以获取到板子上的视频数据。
请使用 `make menuconfig` 启用 `MPP_ENABLE_MIDDLEWARE_LIB_RTSP_PUSHER` 选项。这将自动启用 `ffmpeg` 和 `x264` 库，以支持RTSP推流功能。

#### 参数说明

| 参数名 | 描述 |参数范围 | 默认值 |
|:--|:--|:--|:--|
| H | 打印命令行参数信息 | - | - |
| w | 视频编码宽度 | `[128, 1920]` | 1280 |
| h | 视频编码高度 | `[64, 1080]` |720 |
| b | 视频编码码率 | - | 2000 |
| o | rtsp 推流地址 | - | - |

#### 运行程序

采集sensor画面并将其推送到第三方流媒体服务器上。

```shell
./sample_rtsppusher.elf -w 1280 -h 720 -o <rtsp_url>
```

确保客户端设备与服务器在同一网络下，并将 `<rtsp_url>` 替换为实际的RTSP流地址。按下 `ctrl+c` 退出程序。

```text
msh /sdcard/app/middleware>./sample_rtsppusher.elf -w 1280 -h 720 -o rtsp://10.10.1.94:10554/live/test
./rtsp_server -H to show usage
Validate the input config, not implemented yet, TODO.
probe sensor type 7, mirror 0
detect sensor type: 7
vb_set_config ok
debug: _ai_i2s_set_pitch_shift : semitones = 0
kd_mpi_venc_init start 0
venc[0] 1280*720 size:462848 cnt:30 srcfps:30 dstfps:30 rate:4000 rc_mode:1 type:96 profile:3
kd_mpi_venc_init end
rtsp_pusher url:rtsp://10.10.1.94:10554/live/test
zlmedia url: rtsp://10.10.1.94:10554/live/test, w: 1280, h: 720
audio i2s set clk freq is 512000(512000),ret:1
audio init codec dac clk freq is 11289600
audio set codec dac clk freq is 2048000(2048000)
adec_bind_call_back dev_id:0 chn_id:0
[libx264 @ 0x300015340] using cpu capabilities: none!
[libx264 @ 0x300015340] profile Constrained High, level 3.2, 4:2:0, 8-bit
[libx264 @ 0x300015340] 264 - core 157 - H.264/MPEG-4 AVC codec - Copyleft 2003-2019 - http://www.videolan.org/x264.html - options: cabac=1 ref=3 deblock=1:0:0 analyse=0x3:0x113 me=hex subme=7 psy=1 psy_rd=1.00:0.00 mixed_ref=1 me_range=16 chroma_me=1 trellis=1 8x8dct=1 cqm=0 deadzone=21,11 fast_pskip=1 chroma_qp_offset=-2 threads=1 lookahead_threads=1 sliced_threads=0 nr=0 decimate=1 interlaced=0 bluray_compat=0 constrained_intra=0 bframes=0 weightp=2 keyint=25 keyint_min=2 scenecut=40 intra_refresh=0 rc_lookahead=0 rc=cbr mbtree=0 bitrate=20000 ratetol=1.0 qcomp=0.60 qpmin=0 qpmax=69 qpstep=4 vbv_maxrate=20000 vbv_bufsize=20000 nal_hrd=none filler=0 ip_ratio=1.40 aq=1:1.00
url: rtsp://10.10.1.94:10554/live/test pusher extradata: 0x300170640, size: 36
extradata: 0x300171a20, size: 36
-----rtsp://10.10.1.94:10554/live/test: 00 00 00 01 67 64 0c 20 ac b2 00 a0 0b 74 20 00 00 03 00 20 00 00 06 51 e3 06 49 00 00 00 01 68 eb cc b2 2c
rtsp pusher init success, url: rtsp://10.10.1.94:10554/live/test
audio i2s set clk freq is 512000(512000),ret:1
audio codec adc clk freq is 2048000(2048000)
set output err, set default format ISP_PIX_FMT_YUV420SP
[tuning] dev: 0
acq_win.width: 1920
acq_win.height: 1080
pipe_ctrl: 4294967289
sensor_fd: 12
sensor_type: 7
sensor_name: ov5647_csi0
database_name: ov5647-1920x1080
buffer_num: 0
buffer_size: 0
[tuning] chn: 0
out_win.width: 1280
out_win.height: 720
bit_width: 0
pix_format: 5
buffer_num: 6
buffer_size: 1382400
yraw_size: 0
uv_size: 0
v_size: 0
block_type: 1
wait_time: 500
chn_enable: 1
isp_3dnr_en is 0 g_isp_dev_ctx[dev_num].dev_attr.pipe_ctrl.bits.dnr3_enable is 1
VsiCamDeviceCreate hw:0-vt:0 created!
kd_mpi_isp_set_output_chn_format, width(1920), height(1080), pix_format(5)
[dw] init, version Feb 17 2025 00:06:56
[dw] open dewarp config file error
[dw] load config /bin/ov5647-1920x1080.bin failed, bypass
[dw] enter kd_mpi_sys_mmz_alloc((k_u64*)&settings->lut_phy_addr, &settings->lut_user_virt_addr, "dewarp/lut", "anonymous", settings->lut_size)
[dw] enter dev_fds[dev_num] < 0
[dw] enter ioctl(dev_fds[dev_num], K_DWVIOC_SETUP, settings)
[dw] split: 0 8191 8191 8191
[dw] LUT: 121x69=33396 phy(130ac000)
[dw] input:     1920x1080@YUV420SP align 0 bit 8
[dw] output[0]: 1280x720@YUV420SP align 12 bit 8 crop(0,0,0,0)
[100]rtsp://10.10.1.94:10554/live/test fLiveFrameQueue_ size:1,free framequeue size:24
[200]rtsp://10.10.1.94:10554/live/test fLiveFrameQueue_ size:1,free framequeue size:24
[300]rtsp://10.10.1.94:10554/live/test fLiveFrameQueue_ size:1,free framequeue size:24
[400]rtsp://10.10.1.94:10554/live/test fLiveFrameQueue_ size:1,free framequeue size:24
[500]rtsp://10.10.1.94:10554/live/test fLiveFrameQueue_ size:1,free framequeue size:24
^Cexit_flag true
kd_mpi_isp_stop_stream chn enable is 1
kd_mpi_isp_stop_stream chn enable is 0
kd_mpi_isp_stop_stream chn enable is 0
release reserved vb 276205568
ch 0: 557 pictures encoded. Average FrameRate = 30 Fps
adec_bind_call_back dev_id:0 chn_id:0
ch 0: total used pages 921
vpu_exit>q_wm 120
```

注：流媒体服务器的搭建可以使用easydarwin 或 ZLMediaKit等。

```{admonition} 提示
有关 rtsp 模块的具体接口，请参考[API文档](../../api_reference/middleware/multimedia_middleware.md)
```
