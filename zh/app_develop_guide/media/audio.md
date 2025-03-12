# Audio Demo

## 简介

本示例通过调用MPI API接口，完整实现了音频输入、输出、编解码以及Audio 3A处理功能。示例涵盖以下测试用例：

- **音频输入测试**：采集环境声音，并保存为WAV文件，以此验证音频输入功能的准确性和稳定性。
- **音频输出测试**：播放指定的WAV文件，通过耳机监听的方式，评估音频输出效果的质量。
- **音频输入输出同时测试**：实时进行音频采集和播放，达成声音的即采即播，检验系统的实时处理能力。
- **音频编解码测试**：利用内置的G711a/u 16bit音频编解码器，对音频数据执行编码和解码操作，测试编解码功能的可靠性。

## 功能说明

### 音频输入

音频输入功能通过采集环境中的声音信号，并将其保存为文件，以便后续对采集效果进行深度分析。在本示例中，系统会采集15秒的音频数据，并按照WAV格式标准进行保存。生成的WAV文件可使用VLC播放器直接播放，方便用户对采集的音频内容进行直观评估。

### 音频输出

音频输出功能通过播放WAV文件，并借助耳机监听来判断输出效果。在示例测试过程中，用户可上传不同格式的WAV文件进行测试，以此全面检验音频输出功能在不同文件格式下的兼容性和表现。

### 音频输入输出

音频输入和输出功能支持同时进行测试，该测试主要用于验证I2S模块功能。在测试时，I2S音频输入会实时采集环境中的声音信号，I2S音频输出则同步实时播放采集到的声音，用户插上耳机后，即可实时听到环境中的声音，以此评估I2S模块的实时处理性能。

### 音频编解码

本系统内置G711a/u 16bit音频编解码器，为用户提供了基础的编解码能力。同时，系统具备开放性，支持用户注册其他外置编解码器，以满足多样化的编解码需求。

### Audio 3A

Audio 3A（Automatic Acoustic Adjustment，自动声学调整）包含以下关键功能：

- **ANS（Automatic Noise Suppression）**：即自动噪声抑制功能，主要用于有效降低环境噪声对音频信号的干扰，提升音频的纯净度。
- **AGC（Automatic Gain Control）**：自动增益控制功能，其作用是自动调节音频信号的增益，确保音频信号的强度始终保持在合适的范围内，避免信号过强或过弱。
- **AEC（Acoustic Echo Cancellation）**：声学回声消除功能，可消除音频传输过程中产生的回声，保证音频通信的清晰度。

这些功能可通过设置不同的使能项来启用，具体的使用方法和参数设置，请参考API接口文档进行操作。

## 使用说明

### 代码位置

demo 源码位置：`canmv_k230/src/rtsmart/mpp/userapps/sample/sample_audio`。

假设您已经正确编译该 demo。启动开发板后，进入 `/sdcard/elf/userapps` 目录，`sample_audio.elf` 为测试 demo。

### 参数说明

启动开发板后，进入 `/sdcard/elf/userapps` 目录，输入 `./sample_audio.elf -help` 查看 demo 使用方法。

| 参数名       | 说明                                       | 默认值 |
|--------------|--------------------------------------------|--------|
| type         | 测试不同模块功能 [0,12]                    | -      |
| samplerate   | 配置音频输入和输出的采样率（8k-192k)       | 44100  |
| enablecodec  | 是否启用内置 codec [0,1]。1: 使用内置 codec | 0      |
| bitwidth     | 设置音频采样精度 [16,24,32]。              | 16     |
| filename     | 加载或存储 WAV/G711 文件名称。             | -      |
| channels     | 设置音频声道数，单声道或双声道 [1,2]。     | 2      |
| monochannel  | 设置为单声道时，选择单声道类型 [0,1]。0: 板载 mic，1: 耳机输入 | 0 |
| audio3a      | 是否启用 Audio 3A：enable_ans: 0x01, enable_agc: 0x02, enable_aec: 0x04，可叠加多个使能项 | 0 |

```shell
msh /sharefs/app>./sample_audio.elf
Please input:
-type: test audio function[0-12]
  type 0:sample ai i2s module
  type 1:sample ai pdm module
  type 2:sample ao i2s module
  type 3:sample ai(i2s) to ao (api) module
  type 4:sample ai(i2s) to ao (sysbind) module
  type 5:sample ai(pdm) to ao (api) module
  type 6:sample ai(pdm) bind ao (sysbind) module
  type 7:sample aenc(ai->aenc->file) (sysbind) module
  type 8:sample adec(file->adec->ao) (sysbind) module
  type 9:sample aenc(ai->aenc->file) (api) module
  type 10:sample adec(file->adec->ao) (api) module
  type 11:sample overall test (ai->aenc->file file->adec->ao) module
  type 12:sample overall test (ai->aenc  adec->ao loopback ) module
-samplerate: set audio sample(8000 ~ 192000)
-enablecodec: enable audio codec(0,1)
-loglevel: show kernel log level[0,7]
-bitwidth: set audio bit width(16,24,32)
-channels: channel count
-monochannel:0:mic input 1:headphone input
-filename: load or save file name
-audio3a: enable audio3a:enable_ans:0x01,enable_agc:0x02,enable_aec:0x04
```

## 示例

### I2S音频输入测试

输入以下命令采集15秒的PCM音频数据，并保存为WAV格式文件：

```shell
./sample_audio.elf -type 0 -enablecodec 1 -bitwidth 16 -filename test.wav -audio3a 1
```

执行上述命令后，系统将开始采集音频数据，并显示如下输出：

```shell
./sample_audio.elf -type 0 -enablecodec 1 -bitwidth 16 -filename test.wav -audio3a 1
audio type:0,sample rate:44100,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:7.46 MB
vb_set_config ok
sample ai i2s module
audio i2s set clk freq is 2822400(2822400),ret:1
audio codec adc clk freq is 11289600(11289600)
ans_enable
========ans_enable:1,agc_enable:0,aec_enable:0
audio_save_init get vb block size:2646044
======kd_mpi_sys_mmap total size:2646044
[0s] timestamp 0 us,curpts:1505976917
[1s] timestamp 1000000 us,curpts:1506976917
[2s] timestamp 2000000 us,curpts:1507976917
[3s] timestamp 3000000 us,curpts:1508976917
[4s] timestamp 4000000 us,curpts:1509976917
[5s] timestamp 5000000 us,curpts:1510976917
[6s] timestamp 6000000 us,curpts:1511976917
[7s] timestamp 7000000 us,curpts:1512976917
[8s] timestamp 8000000 us,curpts:1513976917
[9s] timestamp 9000000 us,curpts:1514976917
[10s] timestamp 10000000 us,curpts:1515976917
[11s] timestamp 11000000 us,curpts:1516976917
[12s] timestamp 12000000 us,curpts:1517976917
[13s] timestamp 13000000 us,curpts:1518976917
dump binary memory test1.wav 0x10225000 0x104ab01c
[14s] timestamp 14000000 us,curpts:1519976917
destroy vb block
sample done
```

音频数据将被保存到指定的WAV文件中。

### I2S音频输出测试

该测试通过循环播放 WAV 文件来验证音频输出功能，用户可以按任意键退出测试。

输入以下命令播放 WAV 音频：

```shell
./sample_audio.elf -type 2 -filename test.wav -enablecodec 1
```

执行上述命令后，系统将开始播放指定的 WAV 文件，并显示如下输出：

```shell
./sample_audio.elf -type 2 -filename test.wav -enablecodec 1
audio type:2,sample rate:44100,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:7.46 MB
vb_set_config ok
enter q key to exit
sample ao i2s module
========read_wav_header:headerlen:44,channel:2,samplerate:44100,bitpersample:16
open file:test.wav ok,file size:2646044,data size:2646000,wav header size:44
=======_get_audio_frame virt_addr:0x1002aa000
audio i2s set clk freq is 2822400(2822400),ret:1
audio init codec dac clk freq is 11289600
audio set codec dac clk freq is 11289600(11289600)
q
diable ao audio
destroy vb block
sample done
```

音频将通过耳机或扬声器播放，用户可以通过按任意键退出测试。

### I2S音频输入输出API接口测试

使用以下命令通过API接口实时测试音频输入输出功能：

```shell
./sample_audio.elf -type 3 -bitwidth 16 -enablecodec 1 -samplerate 8000 -audio3a 1
```

执行上述命令后，系统将开始实时采集和播放音频，并显示如下输出：

```shell
./sample_audio.elf -type 3 -bitwidth 16 -enablecodec 1 -samplerate 8000 -audio3a 1
audio type:3,sample rate:8000,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:1.35 MB
vb_set_config ok
enter q key to exit
sample ai(i2s) to ao module
audio i2s set clk freq is 512000(512000),ret:1
audio codec adc clk freq is 2048000(2048000)
ans_enable
========ans_enable:1,agc_enable:0,aec_enable:0
audio i2s set clk freq is 512000(512000),ret:1
audio init codec dac clk freq is 2048000
audio set codec dac clk freq is 2048000(2048000)
[0s] timestamp 0 us,curpts:2017301433
[1s] timestamp 1000000 us,curpts:2018301433
...
q
diable ao module
diable ai module
release vb block
destroy vb block
sample done
```

### I2S音频输入和输出模块的系统绑定测试

使用以下命令通过AI和AO模块绑定实时测试音频输入输出功能：

```shell
./sample_audio.elf -type 4 -bitwidth 16 -enablecodec 1 -samplerate 8000 -audio3a 1
```

执行上述命令后，系统将通过调用系统绑定API接口 `kd_mpi_sys_bind` 将AI和AO模块绑定，并显示如下输出：

```shell
./sample_audio.elf -type 4 -bitwidth 16 -enablecodec 1 -samplerate 8000 -audio3a 1
audio type:4,sample rate:8000,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:1.35 MB
vb_set_config ok
enter q key to exit
sample ai(i2s) bind ao module
audio i2s set clk freq is 512000(512000),ret:1
audio codec adc clk freq is 2048000(2048000)
ans_enable
========ans_enable:1,agc_enable:0,aec_enable:0
audio i2s set clk freq is 512000(512000),ret:1
audio init codec dac clk freq is 2048000
audio set codec dac clk freq is 2048000(2048000)
q
diable ao module
diable ai module
release vb block
destroy vb block
sample done
```

### 编码测试

使用以下命令获取AI数据并编码保存到文件。编解码只支持G711a/u/lpcm，16bit。

系统绑定方式：

```shell
./sample_audio.elf -type 7 -bitwidth 16 -enablecodec 1 -filename /sharefs/i2s_codec.g711a -audio3a 1
```

执行上述命令后，系统将开始编码音频数据，并显示如下输出：

```shell
./sample_audio.elf -type 7 -bitwidth 16 -enablecodec 1 -filename /sharefs/i2s_codec.g711a -audio3a 1
audio type:7,sample rate:44100,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:7.46 MB
vb_set_config ok
enter q key to exit
sample aenc module (sysbind)
audio i2s set clk freq is 2822400(2822400),ret:1
audio codec adc clk freq is 11289600(11289600)
ans_enable
========ans_enable:1,agc_enable:0,aec_enable:0
q
destroy vb block
sample done
```

API接口方式：

```shell
./sample_audio.elf -type 9 -bitwidth 16 -enablecodec 1 -filename /sharefs/i2s_codec.g711a -audio3a 1
```

执行上述命令后，系统将开始编码音频数据，并显示如下输出：

```shell
./sample_audio.elf -type 9 -bitwidth 16 -enablecodec 1 -filename /sharefs/i2s_codec.g711a -audio3a 1
audio type:9,sample rate:44100,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:7.46 MB
vb_set_config ok
enter q key to exit
sample aenc module (api)
audio i2s set clk freq is 2822400(2822400),ret:1
audio codec adc clk freq is 11289600(11289600)
ans_enable
========ans_enable:1,agc_enable:0,aec_enable:0
q
destroy vb block
sample done
```

### 解码测试

使用以下命令读取文件数据并解码播放。编解码只支持G711a/u/lpcm，16bit。

系统绑定方式：

```shell
./sample_audio.elf -type 8 -filename /sharefs/i2s_codec.g711a -enablecodec 1 -bitwidth 16
```

执行上述命令后，系统将开始解码音频数据，并显示如下输出：

```shell
./sample_audio.elf -type 8 -filename /sharefs/i2s_codec.g711a -enablecodec 1 -bitwidth 16
audio type:8,sample rate:44100,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:7.46 MB
vb_set_config ok
enter q key to exit
sample adec module (sysbind)
audio i2s set clk freq is 2822400(2822400),ret:1
audio init codec dac clk freq is 11289600
audio set codec dac clk freq is 11289600(11289600)
adec_bind_call_back dev_id:0 chn_id:0
read file again
q
adec_bind_call_back dev_id:0 chn_id:0
destroy vb block
sample done
```

API接口方式：

```shell
./sample_audio.elf -type 10 -filename /sharefs/i2s_codec.g711a -enablecodec 1 -bitwidth 16
```

执行上述命令后，系统将开始解码音频数据，并显示如下输出：

```shell
./sample_audio.elf -type 10 -filename /sharefs/i2s_codec.g711a -enablecodec 1 -bitwidth 16
audio type:10,sample rate:44100,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:7.46 MB
vb_set_config ok
enter q key to exit
sample adec module (api)
audio i2s set clk freq is 2822400(2822400),ret:1
audio init codec dac clk freq is 11289600
audio set codec dac clk freq is 11289600(11289600)
read file again
q
destroy vb block
sample done
```

### 音频全流程测试

音频全流程测试包括两条链路：AI->AENC 和 ADEC->AO 的绑定回环测试。该测试使用内置 codec，16bit 精度进行模拟，并启用 AEC 软件降噪功能。同时，测试 G711 编码后的流时间戳。

使用以下命令进行测试：

```shell
./sample_audio.elf -type 12 -samplerate 48000 -enablecodec 1 -audio3a 1 &
```

执行上述命令后，系统将开始音频全流程测试，并显示如下输出：

```shell
./sample_audio.elf -type 12 -samplerate 48000 -enablecodec 1 -audio3a 1 &
audio type:12,sample rate:48000,bit width:16,channels:2,enablecodec:1,monochannel:0
mmz blk total size:8.12 MB
vb_set_config ok
enter q key to exit
sample ai->aenc  adec->ao module (loopback)
Force the sampling accuracy to be set to 16,use inner cocdec
audio i2s set clk freq is 3072000(3072000),ret:1
audio codec adc clk freq is 12288000(12288000)
audio i2s set clk freq is 3072000(3072000),ret:1
audio init codec dac clk freq is 11289600
audio set codec dac clk freq is 12288000(12288000)
adec_bind_call_back dev_id:0 chn_id:0
[0s] g711 stream timestamp 0 us,curpts:341326051
[1s] g711 stream timestamp 1000000 us,curpts:342326051
...
q
adec_bind_call_back dev_id:0 chn_id:0
destroy vb block
sample done
```

输入 `cat /proc/umap/sysbind` 可查看模块间系统绑定：

```shell
-----BIND RELATION TABLE--------------------------------------------------------
  FirMod  FirDev  FirChn  SecMod  SecDev  SecChn  TirMod  TirDev  TirChn    SendCnt     rstCnt
      ai       0       0    aenc       0       0    null       0       0        310          0
    adec       0       0      ao       0       0    null       0       0        310          0
```

```{admonition} 提示
有关 audio 模块的具体接口，请参考[API文档](../../api_reference/audio.md)
```
