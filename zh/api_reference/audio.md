# K230音频API参考

## 概述

### 概述

音频模块是为满足 k230 平台多媒体业务需求而设计的高度集成化模块，由多个子模块协同构成，包括音频输入（AI）、音频输出（AO）、音频编码（AENC）、音频解码（ADEC），同时内置了一路音频编解码器。各子模块之间采用低耦合的架构设计，实现了高效且稳定的数据流传递。

#### 子模块功能详述

- **音频输入模块（AI）**：该模块具备灵活的接口兼容性，支持 I2S（Inter-IC Sound）和 PDM（Pulse Density Modulation）两种接口标准。在数据处理方面，借助 PDMA（Peripheral Direct Memory Access）技术实现快速的内存拷贝，确保音频数据的高效传输。它能够处理来自不同类型音频源的输入信号，包括采用 PDM 或 I2S 接口的数字麦克风，以及通过 I2S 接口连接的模拟麦。

- **内置音频编解码器**：模块内集成了一路音频编解码器，不仅能够完成基本的音频信号转换功能，还内置了通过软件实现的 audio3a 算法。该算法涵盖了回声消除（AEC）、降噪（ANR）和自动增益控制（AGC）等功能，可有效增强音频质量，为用户提供清晰、纯净的音频体验。

- **音频输出模块（AO）**：支持 I2S 接口，同样利用 PDMA 进行内存拷贝操作。此模块具有广泛的设备连接能力，可以连接外部数字扬声器，直接输出数字音频信号；也可以借助音频编解码器，将数字音频信号转换为模拟信号后输出，以适配不同类型的音频播放设备。

- **音频编码和解码模块（AENC 和 ADEC）**：目前，这两个模块主要支持 G711 格式的音频编解码。G711 是一种广泛应用的音频编码标准，具有较高的通用性和稳定性。此外，模块还提供了开放的扩展接口，允许用户注册外部编解码器，从而支持更多不同格式的音频编解码，以满足多样化的应用需求。

#### 场景应用

如在语音通话场景中，音频模块各子模块协同工作，形成一个完整的音频处理与传输链路。具体流程如下：

1. **音频输入模块（AI）**：该模块负责采集本地音频数据，无论是来自数字麦克风还是模拟音频编解码器的信号，都能被准确捕获。音频输入模块还支持3A处理（自动增益控制、回声消除和噪声抑制），以提升音频质量，确保输出的音频信号清晰、纯净。
1. **音频编码模块（AENC）**：将采集到的音频数据按照 G711 格式进行编码处理，以减小数据量，便于在网络中高效传输。
1. **网络传输**：编码后的音频数据通过网络发送到远端设备。
1. **音频解码模块（ADEC）**：远端设备接收到音频编码数据后，将其传输到音频解码模块，对编码数据进行解码操作，还原出原始的音频信号。
1. **音频输出模块（AO）**：解码后的音频信号通过音频输出模块进行播放，从而实现远端声音的清晰再现。

通过上述工作模式，音频模块在语音通话业务中实现了高效、稳定的音频数据处理和传输，为用户提供了优质的语音通信体验。

![img](https://kendryte-download.canaan-creative.com/developer/pictures/b96e2ea6fe9536e76af33afe46b2069e.png)

### 功能描述

#### 音频输入模块（AI）

音频输入模块（AI）的核心功能是对音频输入设备进行配置与启用操作，并从中获取音频帧数据。该模块支持 I2S 和 PDM 两种协议接口，以满足不同的音频采集需求。

##### I2S 音频接口

- **声道数量**：支持同时采集最多 2 路双声道音频，实现高质量的立体声音频采集。
- **采样参数**：
  - **采样率**：支持 8kHz、12kHz、16kHz、24kHz、32kHz、44.1kHz、48kHz、96kHz 和 192kHz。用户可根据实际应用场景选择合适的采样率。
  - **采样精度**：提供 16bit、24bit 和 32bit 三种选项，适用于不同音质要求的场景。
- **IO 配置与工作模式**：
  - **IO 配置**：支持 2 组可配置的输入/输出 IO 引脚，用于传输 I2S 音频数据。
  - **工作模式**：支持全双工模式，可同时进行音频数据的输入和输出操作。

##### PDM 音频接口

- **声道数量**：支持同时采集最多 8 路单声道音频，适用于多音频源采集场景。
- **采样参数**：
  - **位宽与采样时钟频率**：支持PDM音频输入，1bit位宽，采样时钟频率为0.256MHz、0.384MHz、0.512MHz、0.768MHz、1.024MHz、1.4112MHz、1.536MHz、2.048MHz、2.8224MHz、3.072MHz、4.096MHz、5.6448MHz、6.144MHz、12.288MHz、24.576MHz，输入的PCM音频采样率为8kHz、12kHz、16kHz、24kHz、32kHz、44.1kHz、48kHz、96kHz、192kHz。
  - **PCM 音频采样率**：支持 8kHz、12kHz、16kHz、24kHz、32kHz、44.1kHz、48kHz、96kHz 和 192kHz。
  - **采样精度**：支持 16bit、24bit 和 32bit 三种采样精度。
  - **过采样率**：支持 128、64、32 倍过采样，提高音频分辨率和信噪比。
- **IO 配置与声道模式**：
  - **IO 数量**：支持 1 - 4 个 IO 引脚用于输入 PDM 音频数据。
  - **声道模式**：支持 1 - 8 个 PDM 声道，支持 PDM 左右单声道模式和双声道模式。

#### 音频输出模块（AO）

音频输出模块（AO）的主要功能是启用音频输出设备，并将音频帧数据发送到相应的输出通道。该模块仅支持 I2S 协议接口。

##### I2S 音频接口

- **声道数量**：支持同时输出最多 2 路双声道音频，实现高质量的立体声音频输出。
- **采样参数**：
  - **采样率**：支持 8kHz、12kHz、16kHz、24kHz、32kHz、44.1kHz、48kHz、96kHz 和 192kHz，确保输入和输出音频数据的采样率兼容性。
  - **采样精度**：支持 16bit、24bit 和 32bit 三种采样精度，保证音频数据的完整性和一致性。
- **IO 配置与工作模式**：
  - **IO 配置**：支持 2 组可配置的输入/输出 IO 引脚，用于传输 I2S 音频数据。
  - **工作模式**：支持全双工模式，允许同时进行音频数据的输入和输出操作。

#### 音频链路

##### 音频信号转换基础

音频编解码器（Codec）在音频链路中起着关键作用，k230内置一路音频编解码器（Codec）。当模拟麦克风接收到声音信号后，音频 Codec 会将这些模拟信号转换为符合 I2S 格式的脉冲编码调制（PCM）数据，然后输入到音频模块的 I2S 接口。相反，当 I2S 接口输出 PCM 数据时，音频 Codec 会将其转换回模拟信号并输出。在这种模式下，数据传输固定采用 I2S 的 sdi0 和 sdo0 接口，而不使用数字 IO 接口。

##### I2S 接口连接方式

I2S 接口具有较强的灵活性，既可以直接连接片外的数字麦克风用于采集音频信号，也可以连接功率放大器（PA）将处理后的音频信号放大输出。I2S 接口有两组可供选择，分别是 sdi0、sdo0 和 sdi1、sdo1。用户可以根据实际硬件连接需求和系统设计方案选择合适的接口组。

##### PDM 麦克风输入方式

对于片外的脉冲密度调制（PDM）麦克风，音频模块提供了最多 4 个输入数据接口，最多可以同时输入 8 路 PDM 数据，满足多通道音频采集需求。

##### 可供选择的音频链路方案

为了满足不同用户的需求，系统提供了多种音频链路方案：

- **方案一：3 组 PDM 输入 + 1 组 I2S 输入 + 2 组 I2S 输出**
  - 3 组 PDM 输入通道，可连接多个 PDM 麦克风进行音频采集。
  - 1 组 I2S 输入通道，可使用内置音频 Codec 或连接片外 I2S 设备。
  - 2 组 I2S 输出通道，用于输出处理后的音频信号。

- **方案二：4 组 PDM 输入 + 2 组 I2S 输出**
  - 4 组 PDM 输入通道，能够连接更多 PDM 麦克风进行音频采集。
  - 2 组 I2S 输出通道，用于输出处理后的音频信号。

- **方案三：2 组 I2S 输入 + 2 组 PDM 输入 + 2 组 I2S 输出**
  - 2 组 I2S 输入通道和 2 组 PDM 输入通道，可同时连接不同类型的音频输入设备。
  - 2 组 I2S 输出通道，用于输出处理后的音频信号。

##### 硬件使用说明

K230 板子配备了一个板载麦克风和一个 3.5mm 耳机接口。用户可以使用内置音频 Codec 测试一组 I2S 音频的输入输出功能及音频编解码器的相关功能。如果需要使用更丰富的音频输入输出功能，如 2 组 I2S 音频的输入输出和 4 组 PDM 音频的输入功能，则需要自行设计并制作音频子板来实现。

## API 参考

### 音频输入

该功能模块提供以下API：

- [kd_mpi_ai_set_pub_attr](#kd_mpi_ai_set_pub_attr)
- [kd_mpi_ai_get_pub_attr](#kd_mpi_ai_get_pub_attr)
- [kd_mpi_ai_enable](#kd_mpi_ai_enable)
- [kd_mpi_ai_disable](#kd_mpi_ai_disable)
- [kd_mpi_ai_enable_chn](#kd_mpi_ai_enable_chn)
- [kd_mpi_ai_disable_chn](#kd_mpi_ai_enable_chn)
- [kd_mpi_ai_get_frame](#kd_mpi_ai_get_frame)
- [kd_mpi_ai_release_frame](#kd_mpi_ai_release_frame)
- [kd_mpi_ai_set_vqe_attr](#kd_mpi_ai_set_vqe_attr)
- [kd_mpi_ai_get_vqe_attr](#kd_mpi_ai_get_vqe_attr)
- [kd_mpi_ai_send_far_echo_frame](#kd_mpi_ai_send_far_echo_frame)

#### kd_mpi_ai_set_pub_attr

【描述】

设置AI设备属性。

【语法】

k_s32 kd_mpi_ai_set_pub_attr([k_audio_dev](#k_audio_dev) ai_dev, const [k_aio_dev_attr](#k_aio_dev_attr) \*attr);

【参数】

| 参数名称 | 描述              | 输入/输出 |
|----------|-------------------|-----------|
| ai_dev   | 音频设备号。      | 输入      |
| attr     | AI设备属性指针。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

【注意】

无

【举例】

```c
k_aio_dev_attr aio_dev_attr;
memset(&aio_dev_attr,0,sizeof(aio_dev_attr));
aio_dev_attr.audio_type = KD_AUDIO_INPUT_TYPE_I2S;
aio_dev_attr.kd_audio_attr.i2s_attr.sample_rate = 44100;
aio_dev_attr.kd_audio_attr.i2s_attr.bit_width = KD_AUDIO_BIT_WIDTH_16
aio_dev_attr.kd_audio_attr.i2s_attr.chn_cnt = 2;
aio_dev_attr.kd_audio_attr.i2s_attr.i2s_mode = K_STANDARD_MODE;
aio_dev_attr.kd_audio_attr.i2s_attr.frame_num = 25;
aio_dev_attr.kd_audio_attr.i2s_attr.point_num_per_frame = 44100/25;
aio_dev_attr.kd_audio_attr.i2s_attr.i2s_type = K_AIO_I2STYPE_INNERCODEC;
if (K_SUCCESS != kd_mpi_ai_set_pub_attr(0, &aio_dev_attr))
{
printf("kd_mpi_ai_set_pub_attr failed\n");
return K_FAILED;
}
if (K_SUCCESS != kd_mpi_ai_enable(0))
{
printf("kd_mpi_ai_set_pub_attr failed\n");
return K_FAILED;
}
if (K_SUCCESS != kd_mpi_ai_enable_chn(0, 0))
{
printf("kd_mpi_ai_set_pub_attr failed\n");
return K_FAILED;
}
```

#### kd_mpi_ai_get_pub_attr

【描述】

获取AI设备属性。

【语法】

k_s32 kd_mpi_ai_get_pub_attr([k_audio_dev](#k_audio_dev) ai_dev, [k_aio_dev_attr](#k_aio_dev_attr) \*attr);

【参数】

| 参数名称 | 描述             | 输入/输出 |
|----------|------------------|-----------|
| ai_dev   | 音频设备号。     | 输入      |
| attr     | AI设备属性指针。 | 输出      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

#### kd_mpi_ai_enable

【描述】

使能ai设备。

【语法】

k_s32 kd_mpi_ai_enable([k_audio_dev](#k_audio_dev) ai_dev);

【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ai_dev   | 音频设备号。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

#### kd_mpi_ai_disable

【描述】

禁用ai设备。

【语法】

k_s32 kd_mpi_ai_disable([k_audio_dev](#k_audio_dev) ai_dev);

【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ai_dev   | 音频设备号。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

#### kd_mpi_ai_enable_chn

【描述】

使能ai通道。

【语法】

k_s32 kd_mpi_ai_enable_chn([k_audio_dev](#k_audio_dev) ai_dev,[k_ai_chn](#k_ai_chn) ai_chn);

【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ai_dev   | 音频设备号。  | 输入      |
| ai_chn   | 音频通道号。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

#### kd_mpi_ai_disable_chn

【描述】

禁用ai通道。

【语法】

k_s32 kd_mpi_ai_disable_chn([k_audio_dev](#k_audio_dev) ai_dev,[k_ai_chn](#k_ai_chn) ai_chn);

【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ai_dev   | 音频设备号。  | 输入      |
| ai_chn   | 音频通道号。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

#### kd_mpi_ai_get_frame

【描述】

获取音频帧。

【语法】

k_s32 kd_mpi_ai_get_frame([k_audio_dev](#k_audio_dev) ai_dev,[k_ai_chn](#k_ai_chn) ai_chn,[k_audio_frame](#k_audio_frame)\*frame, k_u32 milli_sec);

【参数】

| 参数名称  | 描述                                                                                                                                        | 输入/输出 |
|-----------|---------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| ai_dev    | 音频设备号。                                                                                                                                | 输入      |
| ai_chn    | 音频通道号。                                                                                                                                | 输入      |
| frame     | 音频帧数据。                                                                                                                                | 输出      |
| milli_sec | 获取数据的超时时间。 -1表示阻塞模式，无数据时一直等待；  0表示非阻塞模式，无数据时则报错返回；  >0表示阻塞milli_sec毫秒，超时则报错返回。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

【注意】

- milli_sec的值必须大于等于-1，等于-1时采用阻塞模式获取数据，等于0时采用非

阻塞模式获取数据，大于0时，阻塞milli_sec毫秒后，没有数据则返回超时并报错。

- 获取音频帧数据前，必须先使能对应的AI通道。

【举例】

```c
k_audio_frame audio_frame;
while(true)
{
//get frame
if (K_SUCCESS != kd_mpi_ai_get_frame(dev_num, channel, &audio_frame, 1000))
{
printf("=========kd_mpi_ai_get_frame timeout\n");
continue ;
}
//process frame
process_frame(&audio_frame);
//release frame
kd_mpi_ai_release_frame(dev_num, channel, &audio_frame);
}
```

#### kd_mpi_ai_release_frame

【描述】

释放音频帧。

【语法】

k_s32 kd_mpi_ai_release_frame([k_audio_dev](#k_audio_dev) ai_dev,[k_ai_chn](#k_ai_chn) ai_chn,const [k_audio_frame](#k_audio_frame) *frame);【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ai_dev   | 音频设备号。  | 输入      |
| ai_chn   | 音频通道号。  | 输入      |
| frame    | 音频帧数据。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

#### kd_mpi_ai_set_vqe_attr

【描述】

设置AI的声音质量增强功能相关属性。

【语法】

k_s32 kd_mpi_ai_set_vqe_attr([k_audio_dev](#k_audio_dev) ai_dev, [k_ai_chn](#k_ai_chn) ai_chn, const [k_ai_vqe_enable](#k_ai_vqe_enable) vqe_enable);

【参数】

| 参数名称   | 描述                                                      | 输入/输出 |
|------------|-----------------------------------------------------------|-----------|
| ai_dev     | 音频设备号。                                              | 输入      |
| ai_chn     | 音频通道号。                                              | 输入      |
| vqe_enable | 声音质量增强使能标志位。                                   | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h

库文件：libai.a

【注意】

audio 3a支持的采样精度为16bit，且agc只支持8k/16k/32k/48k。

#### kd_mpi_ai_get_vqe_attr

【描述】

获取AI的声音质量增强功能相关属性。

【语法】

k_s32 kd_mpi_ai_get_vqe_attr([k_audio_dev](#k_audio_dev) ai_dev, [k_ai_chn](#k_ai_chn) ai_chn, [k_ai_vqe_enable](#k_ai_vqe_enable) vqe_enable);

【参数】

| 参数名称   | 描述                                                          | 输入/输出 |
|------------|---------------------------------------------------------------|-----------|
| ai_dev     | 音频设备号。                                                  | 输入      |
| ai_chn     | 音频通道号。                                                  | 输入      |
| vqe_enable | 声音质量增强使能标志位指针。                                    | 输出      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

#### kd_mpi_ai_send_far_echo_frame

【描述】

发送远端语音信号。该信号为被远端麦克风采集的信号（说话人语音），也等于近端扬声器播放的语音，也称为参考语音。

【语法】

k_s32 kd_mpi_ai_send_far_echo_frame([k_audio_dev](#k_audio_dev) ai_dev, [k_ai_chn](#k_ai_chn) ai_chn, const [k_audio_frame](#k_audio_frame) *frame, k_s32 milli_sec);

【参数】

| 参数名称   | 描述                                                          | 输入/输出 |
|------------|---------------------------------------------------------------|-----------|
| ai_dev     | 音频设备号。                                                  | 输入      |
| ai_chn     | 音频通道号。                                                  | 输入      |
| frame | 参考语音数据。                                    | 输入     |
| milli_sec | 发送数据的超时时间。 -1表示阻塞模式，无数据时一直等待；  0表示非阻塞模式，无数据时则报错返回；  >0表示阻塞milli_sec毫秒，超时则报错返回。                                     | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

### 音频输出

该功能模块提供以下API：

- [kd_mpi_ao_set_pub_attr](#kd_mpi_ao_set_pub_attr)
- [kd_mpi_ao_get_pub_attr](#kd_mpi_ai_get_pub_attr)
- [kd_mpi_ao_enable](#kd_mpi_ao_enable)
- [kd_mpi_ao_disable](#kd_mpi_ao_disable)
- [kd_mpi_ao_enable_chn](#kd_mpi_ao_enable_chn)
- [kd_mpi_ao_disable_chn](#kd_mpi_ao_disable_chn)
- [kd_mpi_ao_send_frame](#kd_mpi_ao_send_frame)

#### kd_mpi_ao_set_pub_attr

【描述】

设置AO设备属性。

【语法】

k_s32 kd_mpi_ao_set_pub_attr([k_audio_dev](#k_audio_dev) ao_dev, const [k_aio_dev_attr](#k_aio_dev_attr) *attr);

【参数】

| 参数名称 | 描述              | 输入/输出 |
|----------|-------------------|-----------|
| ao_dev   | 音频设备号。      | 输入      |
| attr     | AO设备属性指针。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ao_api.h
- 库文件：libao.a

【注意】

无

【举例】

```c
k_aio_dev_attr ao_dev_attr;
memset(&ao_dev_attr,0,sizeof(ao_dev_attr));
ao_dev_attr.audio_type = KD_AUDIO_OUTPUT_TYPE_I2S;
ao_dev_attr.kd_audio_attr.i2s_attr.sample_rate = 48000;
ao_dev_attr.kd_audio_attr.i2s_attr.bit_width = KD_AUDIO_BIT_WIDTH_24;
ao_dev_attr.kd_audio_attr.i2s_attr.chn_cnt = 2;
ao_dev_attr.kd_audio_attr.i2s_attr.i2s_mode = K_RIGHT_JUSTIFYING_MODE;
ao_dev_attr.kd_audio_attr.i2s_attr.frame_num = 15;
ao_dev_attr.kd_audio_attr.i2s_attr.point_num_per_frame = 48000/25;
ao_dev_attr.kd_audio_attr.i2s_attr.i2s_type = K_AIO_I2STYPE_EXTERN;
if (K_SUCCESS != kd_mpi_ao_set_pub_attr(0, &ao_dev_attr))
{
printf("kd_mpi_ao_set_pub_attr failed\n");
return K_FAILED;
}

if (K_SUCCESS != kd_mpi_ai_enable(0))
{
printf("kd_mpi_ai_enable failed\n");
return K_FAILED;
}

if (K_SUCCESS != kd_mpi_ai_enable_chn(0,1))
{
printf("kd_mpi_ai_enable_chn failed\n");
return K_FAILED;
}
```

#### kd_mpi_ao_get_pub_attr

【描述】

获取AO设备属性。

【语法】

k_s32 kd_mpi_ao_get_pub_attr([k_audio_dev](#k_audio_dev) ao_dev, [k_aio_dev_attr](#k_aio_dev_attr) *attr);

【参数】

| 参数名称 | 描述             | 输入/输出 |
|----------|------------------|-----------|
| ao_dev   | 音频设备号。     | 输入      |
| attr     | AO设备属性指针。 | 输出      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ao_api.h
- 库文件：libao.a

#### kd_mpi_ao_enable

【描述】

使能ao设备。

【语法】

k_s32 kd_mpi_ao_enable([k_audio_dev](#k_audio_dev) ao_dev);

【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ao_dev   | 音频设备号。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ao_api.h
- 库文件：libao.a

#### kd_mpi_ao_disable

【描述】

禁用ao设备。

【语法】

k_s32 kd_mpi_ao_disable([k_audio_dev](#k_audio_dev) ao_dev);

【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ao_dev   | 音频设备号。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ao_api.h
- 库文件：libao.a

#### kd_mpi_ao_enable_chn

【描述】

使能ao通道。

【语法】

k_s32 kd_mpi_ao_enable_chn([k_audio_dev](#k_audio_dev) ao_dev,[k_ao_chn](#k_ao_chn) ao_chn);

【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ao_dev   | 音频设备号。  | 输入      |
| ao_chn   | 音频通道号。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ao_api.h
- 库文件：libao.a

#### kd_mpi_ao_disable_chn

【描述】

禁用ao通道。

【语法】

k_s32 kd_mpi_ao_disable_chn([k_audio_dev](#k_audio_dev) ao_dev,[k_ao_chn](#k_ao_chn) ao_chn);

【参数】

| 参数名称 | 描述          | 输入/输出 |
|----------|---------------|-----------|
| ao_dev   | 音频设备号。  | 输入      |
| ao_chn   | 音频通道号。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ao_api.h
- 库文件：libao.a

#### kd_mpi_ao_send_frame

【描述】

发送ao帧数据。

【语法】

k_s32 kd_mpi_ao_send_frame

([k_audio_dev](#k_audio_dev) ao_dev,[k_ao_chn](#k_ao_chn) ao_chn,const [k_audio_frame](#k_audio_frame)*frame,k_s32 milli_sec);

【参数】

| 参数名称  | 描述                                                                                                                                        | 输入/输出 |
|-----------|---------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| ao_dev    | 音频设备号。                                                                                                                                | 输入      |
| ao_chn    | 音频通道号。                                                                                                                                | 输入      |
| frame     | 音频帧数据指针。                                                                                                                            | 输入      |
| milli_sec | 发送数据的超时时间。 -1表示阻塞模式，无数据时一直等待；  0表示非阻塞模式，无数据时则报错返回；  >0表示阻塞milli_sec毫秒，超时则报错返回。  | 输入      |

【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_ai_api.h
- 库文件：libai.a

【注意】

- milli_sec的值必须大于等于-1，等于-1时采用阻塞模式获取数据，等于0时采用非

阻塞模式获取数据，大于0时，阻塞milli_sec毫秒后，没有数据则返回超时并报错。

- 发送音频帧数据前，必须先使能对应的AO通道。

【举例】

```c
k_audio_frame audio_frame;
k_s32 ret = 0;
while (true)
{
//get ai frame
ret = kd_mpi_ai_get_frame(0, 0, &audio_frame, 1000);
if (K_SUCCESS != ret)
{
printf("=========kd_mpi_ai_get_frame timeout\n");
continue ;
}
//send ai frame to ao
ret = kd_mpi_ao_send_frame(0, 1, &audio_frame, 0);
if (K_SUCCESS != ret)
{
printf("=======kd_mpi_ao_send_frame failed\n");
}
//release ai frame
kd_mpi_ai_release_frame(0, 0, &audio_frame);
}
```

### 音频编码

音频编码主要实现创建编码通道、发送音频帧编码及获取编码码流等功能。音频编码部分，提供g711a/u编码，暂只支持16bit采样精度。

该功能模块提供以下API：

- [kd_mpi_aenc_register_encoder](#kd_mpi_aenc_register_encoder)：注册编码器。
- [kd_mpi_aenc_unregister_encoder](#kd_mpi_aenc_unregister_encoder)：注销编码器。
- [kd_mpi_aenc_create_chn](#kd_mpi_aenc_create_chn):创建编码通道
- [kd_mpi_aenc_destroy_chn](#kd_mpi_aenc_destroy_chn):销毁编码通道
- [kd_mpi_aenc_send_frame](#kd_mpi_aenc_send_frame)：发送音频编码音频帧
- [kd_mpi_aenc_get_stream](#kd_mpi_aenc_get_stream)：获取音频编码码流
- [kd_mpi_aenc_release_stream](#kd_mpi_aenc_release_stream)：释放音频编码码流

#### kd_mpi_aenc_register_encoder

- 【描述】

注册编码器。

- 【语法】

k_s32 kd_mpi_aenc_register_encoder(k_s32 \*handle, const [k_aenc_encoder](#k_aenc_encoder) \*encoder);

- 【参数】

| **参数名称** | **描述**           | **输入/输出** |
|--------------|--------------------|---------------|
| handle       | 注册句柄。         | 输出          |
| encoder      | 编码器属性结构体。 | 输入          |

- 【说明】

用户通过传入编码器属性结构体，向 AENC 模块注册一个编码器，并返回注册句

柄，用户可以最后通过注册句柄来注销该编码器。

AENC 模块最大可注册 20 个编码器，且自身已注册 G711.a、G711.u

两个编码器。

同一种编码协议不允许重复注册编码器，例如假如已注册 G711 编码器，不允许另

外再注册一个 G711 编码器

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_aenc_api.h
- 库文件：libaenc.a

#### kd_mpi_aenc_unregister_encoder

- 【描述】

注销编码器。

- 【语法】

k_s32 kd_mpi_aenc_unregister_encoder(k_s32 handle);

- 【参数】

| **参数名称** | **描述**    | **输入/输出** |
|--------------|-------------|---------------|
| handle       | 注销句柄。  | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_aenc_api.h
- 库文件：libaenc.a

#### kd_mpi_aenc_create_chn

- 【描述】

创建音频编码通道。

- 【语法】

k_s32 kd_mpi_aenc_create_chn([k_aenc_chn](#k_aenc_chn) aenc_chn, const [k_aenc_chn_attr](#k_aenc_chn_attr) \*attr);

| **参数名称** | **描述**                                                           | **输入/输出** |
|--------------|--------------------------------------------------------------------|---------------|
| aenc_chn     | 通道号。 取值范围: [0, [AENC_MAX_CHN_NUM](#aenc_max_chn_nums))。  | 输入          |
| attr         | 音频编码通道属性指针。                                             | 输入          |

- 【说明】

buffer 大小以帧为单位，取值范围是[2, [K_MAX_AUDIO_FRAME_NUM](#k_max_audio_frame_num)，建议配置 为 10 以上，过小的 buffer 配置可能导致丢帧等异常。每个编码通道都会根据buffer大小来配置队列大小，用以缓存编码帧数据。

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_aenc_api.h
- 库文件：libaenc.a

#### kd_mpi_aenc_destroy_chn

- 【描述】

销毁音频编码通道。

- 【语法】

k_s32 kd_mpi_aenc_destroy_chn([k_aenc_chn](#k_aenc_chn) aenc_chn);

| **参数名称** | **描述**                                                           | **输入/输出** |
|--------------|--------------------------------------------------------------------|---------------|
| aenc_chn     | 通道号。 取值范围: [0, [AENC_MAX_CHN_NUM](#aenc_max_chn_nums))。  | 输入          |

- 【说明】

无

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_aenc_api.h
- 库文件：libaenc.a

#### kd_mpi_aenc_send_frame

- 【描述】

发送音频编码帧。

- 【语法】

k_s32 kd_mpi_aenc_send_frame([k_aenc_chn](#k_aenc_chn) aenc_chn,const [k_audio_frame](#k_audio_frame) \*frame);

- 【参数】

| **参数名称** | **描述**                                          | **输入/输出** |
|--------------|---------------------------------------------------|---------------|
| aenc_chn     | 通道号。  取值范围：[0, AENC_MAX_CHN_NUM)。  输入 | 输入          |
| frame        | 音频帧结构体指针。                                | 输入          |

- 【说明】

音频编码发送码流是非阻塞接口，如果音频码流缓存满，则直接返回失败。该接口用于用户主动发送音频帧进行编码，如果 AENC 通道已经通过系统绑定接口与 AI 绑定，不需要也不建议调此接口。调用该接口发送音频编码音频帧时，必须先创建对应的编码通道。

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_aenc_api.h
- 库文件：libaenc.a

#### kd_mpi_aenc_get_stream

- 【描述】

获取音频编码码流。

- 【语法】

k_s32 kd_mpi_aenc_get_stream([k_aenc_chn](#k_aenc_chn) aenc_chn, [k_audio_stream](#k_audio_stream) \*stream, k_s32 milli_sec);

- 【参数】

| **参数名称** | **描述**                                                                                                                                          | **输入/输出** |
|--------------|---------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| aenc_chn     | 通道号。  取值范围：[0, AENC_MAX_CHN_NUM)。                                                                                                       | 输入          |
| stream       | 获取的音频码流。                                                                                                                                  | 输出          |
| milli_sec    | 获取数据的超时时间  -1 表示阻塞模式，无数据时一直等待；  0 表示非阻塞模式，无数据时则报错返回；  \>0 表示阻塞 s32MilliSec 毫秒，超时则报错返回。  | 输入          |

- 【说明】

必须创建通道后才可能获取码流，否则直接返回失败，如果在获取码流过程中销

毁通道则会立刻返回失败。

s32MilliSec 的值必须大于等于-1，等于-1 时采用阻塞模式获取数据，等于 0 时采

用非阻塞模式获取数据，大于 0 时，阻塞 s32MilliSec 毫秒后，没有数据则返回超

时并报错。

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_aenc_api.h
- 库文件：libaenc.a

#### kd_mpi_aenc_release_stream

- 【描述】

释放音频编码码流。

- 【语法】

k_s32 kd_mpi_aenc_release_stream([k_aenc_chn](#k_aenc_chn) aenc_chn, const [k_audio_stream](#k_audio_stream) \*stream);

- 【参数】

| **参数名称** | **描述**                                     | **输入/输出** |
|--------------|----------------------------------------------|---------------|
| aenc_chn     | 通道号。  取值范围：[0, AENC_MAX_CHN_NUM)。  | 输入          |
| stream       | 获取的音频码流。                             | 输出          |

- 【说明】

无

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

- 头文件：mpi_aenc_api.h
- 库文件：libaenc.a

### 音频解码

音频解码主要实现解码通道、发送音频码流解码及获取解码后音频帧等功能。

音频编解码部分，提供g711a/u解码，暂支持16bit采样精度。

该功能模块提供以下API：

- [kd_mpi_adec_register_decoder](#kd_mpi_adec_register_decoder)：注册解码器
- [kd_mpi_adec_unregister_decoder](#kd_mpi_adec_unregister_decoder)：注销解码器
- [kd_mpi_adec_create_chn](#kd_mpi_adec_create_chn)：创建音频解码通道
- [kd_mpi_adec_destroy_chn](#kd_mpi_adec_destroy_chn)：销毁音频解码通道
- [kd_mpi_adec_send_stream](#kd_mpi_adec_send_stream)：发送音频码流到音频解码通道
- [kd_mpi_adec_clr_chn_buf](#kd_mpi_adec_clr_chn_buf)：清除 ADEC 通道中当前的音频数据缓存。
- [kd_mpi_adec_get_frame](#kd_mpi_adec_get_frame)：获取音频解码帧数据
- [kd_mpi_adec_release_frame](#kd_mpi_adec_release_frame)：释放音频解码帧数据

#### kd_mpi_adec_register_decoder

- 【描述】

注册解码器。

- 【语法】

k_s32 kd_mpi_adec_register_decoder(k_s32 \*handle, const [k_adec_decoder](#k_adec_decoder) \*decoder);

- 【参数】

| **参数名称** | **描述**           | **输入/输出** |
|--------------|--------------------|---------------|
| handle       | 注册句柄。         | 输出          |
| decoder      | 解码器属性结构体。 | 输入          |

- 【说明】

用户通过传入解码器属性结构体，向 ADEC 模块注册一个解码器，并返回注册句柄，用户可以最后通过注册句柄来注销该解码器。 ADEC 模块最大可注册 20 个解码器，且自身已注册 G711a、G711u两个解码器。 同一种解码协议不允许重复注册解码器，例如假如已注册 G711 解码器，不允许另外再注册一个 G711 解码器。

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

头文件：mpi_adec_api.h

库文件：libadec.a

#### kd_mpi_adec_unregister_decoder

- 【描述】

注销解码器。

- 【语法】

k_s32 kd_mpi_adec_unregister_decoder(k_s32 handle);

- 【参数】

| **参数名称** | **描述**    | **输入/输出** |
|--------------|-------------|---------------|
| handle       | 注销句柄。  | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】
- 头文件：mpi_adec_api.h
- 库文件：libadec.a

#### kd_mpi_adec_create_chn

- 【描述】

创建音频解码通道。

- 【语法】

k_s32 kd_mpi_adec_create_chn([k_adec_chn](#k_adec_chn) adec_chn, const [k_adec_chn_attr](#k_adec_chn_attr) \*attr);

- 【参数】

| **参数名称** | **描述**                                                            | **输入/输出** |
|--------------|---------------------------------------------------------------------|---------------|
| adec_chn     | 通道号。  取值范围：[0, [ADEC_MAX_CHN_NUM](#adec_max_chn_nums))。  | 输入          |
| attr         | 通道属性指针。                                                      | 输入          |

- 【说明】

协议类型指定了该通道的解码协议，目前支持 G711。音频解码的部分属性需要与输出设备属性相匹配，例如采样率、帧长（每帧采样点数目）等。 buffer 大小以帧为单位，取值范围是[2, [K_MAX_AUDIO_FRAME_NUM](#k_max_audio_frame_num)，建议配置为 10 以上，过小的 buffer 配置可能导致丢帧等异常。 在通道未创建前（或销毁后）才能使用此接口，如果通道已经被创建，则返回通道已经创建。

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

【需求】

头文件：mpi_adec_api.h

库文件：libadec.a

#### kd_mpi_adec_destroy_chn

- 【描述】

销毁音频解码通道。

- 【语法】

k_s32 kd_mpi_adec_destroy_chn([k_adec_chn](#k_adec_chn) adec_chn);

- 【参数】

| **参数名称** | **描述**                                                           | **输入/输出** |
|--------------|--------------------------------------------------------------------|---------------|
| adec_chn     | 通道号。 取值范围: [0, [ADEC_MAX_CHN_NUM](#adec_max_chn_nums))。  | 输入          |

- 【说明】

无

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】
- 头文件：mpi_adec_api.h
- 库文件：libadec.a

#### kd_mpi_adec_send_stream

- 【描述】

发送音频码流到音频解码通道。

- 【语法】

k_s32 kd_mpi_adec_send_stream(k_adec_chn adec_chn,const k_audio_stream \*stream,k_bool block);

- 【参数】

| **参数名称** | **描述**                                         | **输入/输出** |
|--------------|--------------------------------------------------|---------------|
| adec_chn     | 通道号。  取值范围：[0, [ADEC_MAX_CHN_NUM](#adec_max_chn_nums))。      | 输入          |
| stream       | 音频码流。                                       | 输入          |
| block        | 阻塞标识。  HI_TRUE：阻塞。  HI_FALSE：非阻塞。  | 输入          |

- 【说明】

发送数据时必须保证通道已经被创建，否则直接返回失败，如果在送数据过程中 销毁通道则会立刻返回失败。 支持阻塞或非阻塞方式发送码流。 当阻塞方式发送码流时，如果用于缓存解码后的音频帧的 Buffer 满，则此接口调用会被阻塞，直至解码后的音频帧数据被取走，或 ADEC 通道被销毁。

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：mpi_adec_api.h

库文件：libadec.a

#### kd_mpi_adec_clr_chn_buf

- 【描述】

清除ADEC通道中当前的音频数据缓存。

- 【语法】

k_s32 kd_mpi_adec_clr_chn_buf([k_adec_chn](#k_adec_chn) adec_chn);

- 【参数】

| **参数名称** | **描述**                                                           | **输入/输出** |
|--------------|--------------------------------------------------------------------|---------------|
| adec_chn     | 通道号。 取值范围: [0, [ADEC_MAX_CHN_NUM](#adec_max_chn_nums))。  | 输入          |

- 【说明】

要求解码通道已经被创建，如果通道未被创建则返回通道不存在错误码。

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：mpi_adec_api.h

库文件：libadec.a

#### kd_mpi_adec_get_frame

- 【描述】

获取音频解码帧数据。

- 【语法】

k_s32 kd_mpi_adec_get_frame([k_adec_chn](#k_adec_chn) adec_chn, [k_audio_frame](#k_audio_frame) \*frame, k_s32 milli_sec);

- 【参数】

| **参数名称** | **描述**                 | **输入/输出** |
|--------------|--------------------------|---------------|
| adec_chn     | 音频解码通道。           | 输入          |
| frame_info   | 音频帧数据结构体  输出   | 输出          |
| block        | 是否以阻塞方式获取       | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：mpi_adec_api.h

库文件：libadec.a

#### kd_mpi_adec_release_frame

- 【描述】

释放获取到的音频解码帧数据。

- 【语法】

k_s32 kd_mpi_adec_release_frame([k_adec_chn](#k_aenc_chn) adec_chn, const [k_audio_frame](#k_audio_frame) \*frame);

- 【参数】

| **参数名称** | **描述**                 | **输入/输出** |
|--------------|--------------------------|---------------|
| adec_chn     | 音频解码通道。           | 输入          |
| frame_info   | 音频帧数据结构体  输出   | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：mpi_adec_api.h

库文件：libadec.a

### 内置Audio Codec

内置Audio Codec主要通过ioctl提供对硬件设备的操作。在提供的ioctl的cmd中，有些

cmd用户可以不需要调用，直接使用模块加载时的默认值即可。ioctl调用实现的是对内置Audio Codec寄存器的读写。

当前版本对audio codec的控制操作主要包含:adc数字和模拟音量，dac数字/模拟音量，adc/dac静音控制。其中采样率，采样精度，i2s对齐模式这些控制操作由用户通过调用ai和ao的api接口内核自动完成(内核代码自动实现对codec硬件设备操作)，不再提供ioctl接口来控制。

内置 Audio Codec 标准功能 cmd:

- [k_acodec_set_gain_micl](#k_acodec_set_gain_micl)：左声道输入模拟增益控制
- [k_acodec_set_gain_micr](#k_acodec_set_gain_micr)：右声道输入模拟增益控制
- [k_acodec_set_adcl_volume](#k_acodec_set_adcl_volume)：左声道输入数字音量控制
- [k_acodec_set_adcr_volume](#k_acodec_set_adcr_volume)：右声道输入数字音量控制
- [k_acodec_set_alc_gain_micl](#k_acodec_set_alc_gain_micl)：alc左声道输入的模拟增益控制
- [k_acodec_set_alc_gain_micr](#k_acodec_set_alc_gain_micr)：alc右声道输入的模拟增益控制
- [k_acodec_set_gain_hpoutl](#k_acodec_set_gain_hpoutl)：左声道输出模拟音量控制
- [k_acodec_set_gain_hpoutr](#k_acodec_set_gain_hpoutr)：右声道输出模拟音量控制
- [k_acodec_set_dacl_volume](#k_acodec_set_dacl_volume)：左声道输出数字音量控制
- [k_acodec_set_dacr_volume](#k_acodec_set_dacr_volume)：右声道输出数字音量控制
- [k_acodec_set_micl_mute](#k_acodec_set_micl_mute)：左声道输入静音控制
- [k_acodec_set_micr_mute](#k_acodec_set_micr_mute)：右声道输入静音控制
- [k_acodec_set_dacl_mute](#k_acodec_set_dacl_mute)：左声道输出静音控制
- [k_acodec_set_dacr_mute](#k_acodec_set_dacr_mute)：右声道输出静音控制
- [k_acodec_get_gain_micl](#k_acodec_get_gain_micl)：获取左声道输入模拟增益值
- [k_acodec_get_gain_micr](#k_acodec_get_gain_micr)：获取右声道输入模拟增益值
- [k_acodec_get_adcl_volume](#k_acodec_get_adcl_volume)：获取左声道输入数字音量值
- [k_acodec_get_adcr_volume](#k_acodec_get_adcr_volume)：获取右声道输入数字音量值
- [k_acodec_get_alc_gain_micl](#k_acodec_get_alc_gain_micl)：获取alc左声道输入的模拟增益值
- [k_acodec_get_alc_gain_micr](#k_acodec_get_alc_gain_micr)：获取alc右声道输入的模拟增益值
- [k_acodec_get_gain_hpoutl](#k_acodec_get_gain_hpoutl)：获取左声道输出模拟音量值
- [k_acodec_get_gain_hpoutr](#k_acodec_get_gain_hpoutr)：获取右声道输出模拟音量值
- [k_acodec_get_dacl_volume](#k_acodec_get_dacl_volume)：获取左声道输出数字音量值
- [k_acodec_get_dacr_volume](#k_acodec_get_dacr_volume)：获取右声道输出数字音量值
- [k_acodec_reset](#k_acodec_reset)：音量重置

#### k_acodec_set_gain_micl

- 【描述】

左声道输入模拟增益控制

- 【语法】

int ioctl (int fd, k_acodec_set_gain_micl, k_u32 \*arg);

- 【参数】

| **参数名称**           | **描述**                  | **输入/输出** |
| ---------------------- | ------------------------- | ------------- |
| fd                     | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_gain_micl | ioctl号                   | 输入          |
| arg                    | 无符号整型指针            | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围为0db,6db,20db,30db。

#### k_acodec_set_gain_micr

- 【描述】

右声道输入模拟增益控制

- 【语法】

int ioctl (int fd, k_acodec_set_gain_micr, k_u32 \*arg);

- 【参数】

| **参数名称**           | **描述**                  | **输入/输出** |
| ---------------------- | ------------------------- | ------------- |
| fd                     | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_gain_micr | ioctl号                   | 输入          |
| arg                    | 无符号整型指针            | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围为0db,6db,20db,30db。

#### k_acodec_set_adcl_volume

- 【描述】

左声道输入数字增益控制。

- 【语法】

int ioctl (int fd, k_acodec_set_adcl_volume, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_adcl_volume | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-97,30]`,赋值越大，音量越大，按0.5db递增。

#### k_acodec_set_adcr_volume

- 【描述】

右声道输入数字增益控制。

- 【语法】

int ioctl (int fd, k_acodec_set_adcr_volume, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_adcr_volume | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-97,30]`,赋值越大，音量越大，按0.5db递增。

#### k_acodec_set_alc_gain_micl

- 【描述】

左声道alc输入模拟增益控制。

- 【语法】

int ioctl (int fd, k_acodec_set_alc_gain_micl, float \*arg);

- 【参数】

| **参数名称**               | **描述**                  | **输入/输出** |
| -------------------------- | ------------------------- | ------------- |
| fd                         | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_alc_gain_micl | ioctl号                   | 输入          |
| arg                        | 有符号浮点型指针          | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-18,28.5]`,赋值越大，音量越大，按1.5db递增。

#### k_acodec_set_alc_gain_micr

- 【描述】

右声道alc输入模拟增益控制。

- 【语法】

int ioctl (int fd, k_acodec_set_alc_gain_micr, float \*arg);

- 【参数】

| **参数名称**               | **描述**                  | **输入/输出** |
| -------------------------- | ------------------------- | ------------- |
| fd                         | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_alc_gain_micr | ioctl号                   | 输入          |
| arg                        | 有符号浮点型指针          | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-18,28.5]`,赋值越大，音量越大，按1.5db递增。

#### k_acodec_set_gain_hpoutl

- 【描述】

左声道输出模拟增益控制。

- 【语法】

int ioctl (int fd, k_acodec_set_gain_hpoutl, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_gain_hpoutl | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-39,6]`,赋值越大，音量越大，按1.5db递增。

#### k_acodec_set_gain_hpoutr

- 【描述】

右声道输出模拟增益控制。

- 【语法】

int ioctl (int fd, k_acodec_set_gain_hpoutr, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_gain_hpoutr | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-39,6]`,赋值越大，音量越大，按1.5db递增。

#### k_acodec_set_dacl_volume

- 【描述】

左声道输出数字增益控制。

- 【语法】

int ioctl (int fd, k_acodec_set_dacl_volume, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_dacl_volume | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-120,7]`,赋值越大，音量越大，按0.5db递增。

#### k_acodec_set_dacr_volume

- 【描述】

右声道输出数字增益控制。

- 【语法】

int ioctl (int fd, k_acodec_set_dacr_volume, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_dacr_volume | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-120,7]`,赋值越大，音量越大，按0.5db递增。

#### k_acodec_set_micl_mute

- 【描述】

左声道输入静音控制。

- 【语法】

int ioctl (int fd, k_acodec_set_micl_mute, k_bool \*arg);

- 【参数】

| **参数名称**           | **描述**                  | **输入/输出** |
| ---------------------- | ------------------------- | ------------- |
| fd                     | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_micl_mute | ioctl号                   | 输入          |
| arg                    | bool型指针                | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

取值范围:K_TRUE静音，K_FALSE取消静音。

#### k_acodec_set_micr_mute

- 【描述】

右声道输入静音控制。

- 【语法】

int ioctl (int fd, k_acodec_set_micr_mute, k_bool \*arg);

- 【参数】

| **参数名称**           | **描述**                  | **输入/输出** |
| ---------------------- | ------------------------- | ------------- |
| fd                     | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_micr_mute | ioctl号                   | 输入          |
| arg                    | bool型指针                | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

取值范围:K_TRUE静音，K_FALSE取消静音。

#### k_acodec_set_dacl_mute

- 【描述】

左声道输出静音控制。

- 【语法】

int ioctl (int fd, k_acodec_set_dacl_mute, k_bool \*arg);

- 【参数】

| **参数名称**           | **描述**                  | **输入/输出** |
| ---------------------- | ------------------------- | ------------- |
| fd                     | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_dacl_mute | ioctl号                   | 输入          |
| arg                    | bool型指针                | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

取值范围:K_TRUE静音，K_FALSE取消静音。

#### k_acodec_set_dacr_mute

- 【描述】

右声道输出静音控制。

- 【语法】

int ioctl (int fd, k_acodec_set_dacr_mute, k_bool \*arg);

- 【参数】

| **参数名称**           | **描述**                  | **输入/输出** |
| ---------------------- | ------------------------- | ------------- |
| fd                     | Audio Codec设备文件描述符 | 输入          |
| k_acodec_set_dacr_mute | ioctl号                   | 输入          |
| arg                    | bool型指针                | 输入          |

- 【返回值】

| 返回值 | 描述                 |
|--------|----------------------|
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

取值范围:K_TRUE静音，K_FALSE取消静音。

#### k_acodec_get_gain_micl

- 【描述】

获取左声道输入模拟增益值。

- 【语法】

int ioctl (int fd, k_acodec_get_gain_micl, k_u32 \*arg);

- 【参数】

| **参数名称**           | **描述**                  | **输入/输出** |
| ---------------------- | ------------------------- | ------------- |
| fd                     | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_gain_micl | ioctl号                   | 输入          |
| arg                    | 无符号整型指针            | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

获取到得模拟增益范围为0db,6db,20db,30db。

#### k_acodec_get_gain_micr

- 【描述】

获取右声道输入模拟增益值。

- 【语法】

int ioctl (int fd, k_acodec_get_gain_micr, k_u32 \*arg);

- 【参数】

| **参数名称**           | **描述**                  | **输入/输出** |
| ---------------------- | ------------------------- | ------------- |
| fd                     | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_gain_micr | ioctl号                   | 输入          |
| arg                    | 无符号整型指针            | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

获取到得模拟增益范围为0db,6db,20db,30db。

#### k_acodec_get_adcl_volume

- 【描述】

获取左声道输入数字音量值

- 【语法】

int ioctl (int fd, k_acodec_get_adcl_volume, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_adcl_volume | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-97,30]`,赋值越大，音量越大，按0.5db递增。

#### k_acodec_get_adcr_volume

- 【描述】

获取右声道输入数字增益控制值。

- 【语法】

int ioctl (int fd, k_acodec_get_adcr_volume, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_adcr_volume | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-97,30]`,赋值越大，音量越大，按0.5db递增。

#### k_acodec_get_alc_gain_micl

- 【描述】

获取左声道alc输入模拟增益值。

- 【语法】

int ioctl (int fd, k_acodec_set_alc_gain_micl, float \*arg);

- 【参数】

| **参数名称**               | **描述**                  | **输入/输出** |
| -------------------------- | ------------------------- | ------------- |
| fd                         | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_alc_gain_micl | ioctl号                   | 输入          |
| arg                        | 有符号浮点型指针          | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-18,28.5]`,赋值越大，音量越大，按1.5db递增。

#### k_acodec_get_alc_gain_micr

- 【描述】

获取右声道alc输入模拟增益值。

- 【语法】

int ioctl (int fd, k_acodec_get_alc_gain_micr, float \*arg);

- 【参数】

| **参数名称**               | **描述**                  | **输入/输出** |
| -------------------------- | ------------------------- | ------------- |
| fd                         | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_alc_gain_micr | ioctl号                   | 输入          |
| arg                        | 有符号浮点型指针          | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-18,28.5]`,赋值越大，音量越大，按1.5db递增。

#### k_acodec_get_gain_hpoutl

- 【描述】

获取左声道输出模拟增益值。

- 【语法】

int ioctl (int fd, k_acodec_get_gain_hpoutl, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_gain_hpoutl | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-39,6]`,赋值越大，音量越大，按1.5db递增。

#### k_acodec_get_gain_hpoutr

- 【描述】

获取右声道输出模拟增益控制。

- 【语法】

int ioctl (int fd, k_acodec_get_gain_hpoutr, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_gain_hpoutr | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-39,6]`,赋值越大，音量越大，按1.5db递增。

#### k_acodec_get_dacl_volume

- 【描述】

获取左声道输出数字增益值。

- 【语法】

int ioctl (int fd, k_acodec_get_dacl_volume, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_dacl_volume | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-120,7]`,赋值越大，音量越大，按0.5db递增。

#### k_acodec_get_dacr_volume

- 【描述】

获取右声道输出数字增益值。

- 【语法】

int ioctl (int fd, k_acodec_get_dacr_volume, float \*arg);

- 【参数】

| **参数名称**             | **描述**                  | **输入/输出** |
| ------------------------ | ------------------------- | ------------- |
| fd                       | Audio Codec设备文件描述符 | 输入          |
| k_acodec_get_dacr_volume | ioctl号                   | 输入          |
| arg                      | 有符号浮点型指针          | 输出          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

模拟增益范围`[-120,7]`,赋值越大，音量越大，按0.5db递增。

#### k_acodec_reset

- 【描述】

音量重置:包括adc、dac、alc数字模拟增益。

- 【语法】

int ioctl (int fd, k_acodec_reset, ...);

- 【参数】

| **参数名称**   | **描述**                  | **输入/输出** |
| -------------- | ------------------------- | ------------- |
| fd             | Audio Codec设备文件描述符 | 输入          |
| k_acodec_reset | ioctl号                   | 输入          |

- 【返回值】

| 返回值 | 描述                 |
| ------ | -------------------- |
| 0      | 成功                 |
| 非0    | 失败，其值参见错误码 |

- 【需求】

头文件：k_acodec_comm.h

库文件：libacodec.a

- 【注意】

无

## 数据类型

### 音频输入输出

音频输入输出相关数据类型、数据结构定义如下：

- [k_audio_type](#k_audio_type):定义音频输入输出类型。
- [k_audio_dev](#k_audio_dev)：定义音频设备。
- [k_ai_chn](#k_ai_chn)：定义ai通道。
- [k_ao_chn](#k_ao_chn)：定义ao通道。
- [K_MAX_AUDIO_FRAME_NUM](#k_max_audio_frame_num)：定义最大音频解码缓存帧数。
- [k_audio_bit_width](#k_audio_bit_width)：定义音频采样精度。
- [k_audio_snd_mode](#k_audio_snd_mode)：定义音频声道模式。
- [k_audio_pdm_oversample](#k_audio_pdm_oversample):定义pdm过采样。
- [k_aio_dev_attr](#k_aio_dev_attr):定义音频输入输出设备属性结构体。
- [k_audio_pdm_attr](#k_audio_pdm_attr):定义pdm音频输入属性。
- [k_i2s_work_mode](#k_i2s_work_mode):定义i2s工作模式。
- [k_audio_i2s_attr](#k_audio_i2s_attr):定义i2s音频输入属性。
- [k_aio_i2s_type](#k_aio_i2s_type):定义i2s对接设备类型。
- [k_audio_frame](#k_audio_frame):定义音频帧结构体。
- [k_ai_vqe_enable](#k_ai_vqe_enable)：定义音频输入声音质量增强配置信息结构体。

#### k_audio_type

【说明】

定义音频输入输出类型。

【定义】

```c
typedef enum {
KD_AUDIO_INPUT_TYPE_I2S = 0,//i2s in
KD_AUDIO_INPUT_TYPE_PDM = 1,//pdm in
KD_AUDIO_OUTPUT_TYPE_I2S = 2,//i2s out
} k_audio_type;
```

【注意事项】

音频输入包括i2s和pdm两种，音频输出只有i2s。

【相关数据类型及接口】

无

#### k_audio_dev

【说明】

定义音频设备。

【定义】

**typedef k_u32 k_audio_dev;**

【注意事项】

ai模块，k_audio_dev取值为0和1，其中0为i2s音频输入，1为pdm音频输入。

ao模块，k_audio_dev取值固定为0，即i2s音频输出。

#### k_ai_chn

【说明】

定义ai音频通道。

【定义】

**typedef k_u32 k_ai_chn;**

【注意事项】

I2s音频输入，共有2组，取值范围为`[0,1]`。

pdm音频输入，共有4组，取值范围为`[0,3]`。

#### k_ao_chn

【说明】

定义ao音频通道。

【定义】

**typedef k_u32 k_ao_chn;**

【注意事项】

I2s音频输出，共有2组，取值范围为`[0,1]`。

#### K_MAX_AUDIO_FRAME_NUM

【说明】

定义最大音频解码缓存帧数。

【定义】

\#define K_MAX_AUDIO_FRAME_NUM 50

#### k_audio_bit_width

【说明】

- 定义音频采样精度。

【定义】

```c
typedef enum {
KD_AUDIO_BIT_WIDTH_16 = 0, /* 16bit width */
KD_AUDIO_BIT_WIDTH_24 = 1, /* 24bit width */
KD_AUDIO_BIT_WIDTH_32 = 2, /* 32bit width */
} k_audio_bit_width;
```

【注意事项】

无

【相关数据类型及接口】

无

#### k_audio_snd_mode

【说明】

- 定义声道模式。

【定义】

```c
typedef enum {
KD_AUDIO_SOUND_MODE_MONO = 0, /* mono */
KD_AUDIO_SOUND_MODE_STEREO = 1, /* stereo */
} k_audio_snd_mode;
```

#### k_audio_pdm_oversample

【说明】

定义pdm过采样。

【定义】

```c
typedef enum
{
KD_AUDIO_PDM_INPUT_OVERSAMPLE_32 = 0,
KD_AUDIO_PDM_INPUT_OVERSAMPLE_64 ,
KD_AUDIO_PDM_INPUT_OVERSAMPLE_128 ,
} k_audio_pdm_oversample;
```

#### k_audio_pdm_attr

【说明】

定义pdm音频输入属性。

【定义】

```c
typedef struct {
k_u32 chn_cnt; /* channle number on FS,i2s valid value:1/2,pdm valid value:1/2/3/4*/
k_audio_sample_rate rate;
k_audio_bit_width width;
k_audio_snd_mode mode;
k_audio_pdm_oversample oversample;
k_u32 frame_num; /* frame num in buf[2,K_MAX_AUDIO_FRAME_NUM] */
k_u32 point_num_per_frame;
} k_audio_pdm_attr;
```

【成员】

| 成员名称            | 描述                                                |
|---------------------|-----------------------------------------------------|
| chn_cnt             | 支持的通道数目。  支持1-4个通道，通道使能需要连续。 |
| sample_rate         | 采样率:支持8k\~192k                                 |
| bit_width           | 采样精度：支持16/24/32                              |
| snd_mode            | 音频声道模式。支持单声道和双声道。                  |
| pdm_oversample      | 过采样：支持32、64、128倍过采样。                   |
| frame_num           | 缓存帧数目`[2,K_MAX_AUDIO_FRAME_NUM]`。               |
| point_num_per_frame | 每帧的采样点个数。                                  |

【注意事项】

无

【相关数据类型及接口】

无

#### k_audio_i2s_attr

【说明】

定义i2s音频输入属性。

【定义】

```c
typedef struct
{
k_u32 chn_cnt; /* channle number on FS,i2s valid value:1/2,pdm valid value:1/2/3/4 */
k_u32 sample_rate; /* sample rate 8k ~192k */
k_audio_bit_width bit_width;
k_audio_snd_mode snd_mode; /* momo or stereo */
k_i2s_in_mono_channel  mono_channel;/* use mic input or headphone input */
k_i2s_work_mode   i2s_mode;  /*i2s work mode*/
k_u32 frame_num; /* frame num in buf[2,K_MAX_AUDIO_FRAME_NUM] */
k_u32 point_num_per_frame;
k_aio_i2s_type type;
} k_audio_i2s_attr;
```

【成员】

| 成员名称            | 描述                                                 |
| ------------------- | ---------------------------------------------------- |
| chn_cnt             | 支持的通道数目。  支持1-2个通道。                    |
| sample_rate         | 采样率:支持8k~192k                                   |
| bit_width           | 采样精度：支持16/24/32                               |
| snd_mode            | 音频声道模式。支持单声道和双声道。                   |
| mono_channel        | 单声道源选择。0:mic input,  1:headphone input     |
| I2s_mode            | I2s工作模式:支持飞利浦模式，左对齐模式，右对齐模式。 |
| frame_num           | 缓存帧数目`[2,K_MAX_AUDIO_FRAME_NUM]`。              |
| point_num_per_frame | 每帧的采样点个数`[sample_rate/100,sample_rate]`。    |
| i2s_type            | i2s对接设备类型:内置codec或外接设备。                |

【注意事项】

每帧的采样点个数point_num_per_frame和采样率sample_rate的取值决定了硬件产生

中断的频率，频率过高会影响系统的性能，跟其他业务也会相互影响，建议这两个参

数的取值满足算式：(point_num_per_frame *1000)/ sample_rate >=10(中断100次)，比如在采样

率为16000Hz时，建议设置采样点个数大于或者等于160。

【相关数据类型及接口】

无

#### k_i2s_work_mode

【说明】

定义i2s工作模式。

【定义】

```c
typedef enum
{
K_STANDARD_MODE = 1,
K_RIGHT_JUSTIFYING_MODE = 2,
K_LEFT_JUSTIFYING_MODE = 4
} k_i2s_work_mode;
```

【注意事项】

无

【相关数据类型及接口】

无

#### k_aio_dev_attr

【说明】

定义音频输入输出设备属性结构体。

【定义】

```c
typedef struct {
k_audio_type type;
union
{
k_audio_pdm_attr pdm_attr;
k_audio_i2s_attr i2s_attr;
} kd_audio_attr;
} k_aio_dev_attr;
```

【成员】

| 成员名称      | 描述         |
|---------------|--------------|
| audio_type    | 音频类型。   |
| kd_audio_attr | 音频属性设置 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_aio_i2s_type

【说明】

定义i2s对接设备类型。

【定义】

```c
typedef enum
{
K_AIO_I2STYPE_INNERCODEC = 0, /* AIO I2S connect inner audio CODEC */
K_AIO_I2STYPE_EXTERN,/* AIO I2S connect extern hardware */
} k_aio_i2s_type;
```

【注意事项】

内置audio codec固定使用第0组i2s 通路，第1组i2s通路仍使用外部codec。

【相关数据类型及接口】

无

#### k_audio_frame

【说明】

定义音频帧结构体。

【定义】

```c
typedef struct {
k_audio_bit_width bit_width;
k_audio_snd_mode snd_mode;
void* virt_addr;
k_u64 phys_addr;
k_u64 time_stamp; /* audio frame time stamp */
k_u32 seq; /* audio frame seq */
k_u32 len; /* data lenth per channel in frame */
k_u32 pool_id;
} k_audio_frame;
```

【成员】

| 成员名称   | 描述                       |
|------------|----------------------------|
| bit_width  | 采样精度。                 |
| snd_mode   | 音频声道模式。             |
| virt_addr  | 音频帧数据虚拟地址。       |
| phys_addr  | 音频帧数据物理地址。       |
| time_stamp | 音频帧时间戳，以μs为单位。 |
| seq        | 音频帧序号。               |
| len        | 音频帧长度，以byte为单位。 |
| pool_id    | 音频帧缓存池ID。           |

【注意事项】

无

【相关数据类型及接口】

无

#### k_ai_vqe_enable

【说明】

定义音频输入声音质量增强配置信息结构体。

【定义】

typedef struct
{
    k_bool aec_enable;
    k_u32  aec_echo_delay_ms;//speaker播出时间到mic录到的时间差(100-500ms)
    k_bool agc_enable;
    k_bool ans_enable;
}k_ai_vqe_enable;

【成员】

| 成员名称 | 描述                       |
|----------|----------------------------|
| aec_enable  | 回声抑制使能。 |
| aec_echo_delay_ms  | 回声消除滤波器的长度，推荐为100-500ms。也就是speaker播出时间到mic录到的时间差，本参数具体大小需细调，调整不好直接影响回音消除效果。|
| agc_enable  | 自动增益使能。 |
| ans_enable  | 音频降噪使能。 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_i2s_in_mono_channel

【说明】

- 单声道源。

【定义】

```c
typedef enum
{
    KD_I2S_IN_MONO_RIGHT_CHANNEL = 0,  //mic input
    KD_I2S_IN_MONO_LEFT_CHANNEL = 1,   //hp input
} k_i2s_in_mono_channel;
```

### 音频编解码

音频编解码相关数据类型、数据结构定义如下：

[k_payload_type](#k_payload_type)

[k_aenc_encoder](#k_aenc_encoder)

[k_aenc_chn_attr](#k_aenc_chn_attr)

[AENC_MAX_CHN_NUMS](#aenc_max_chn_nums)

[K_MAX_ENCODER_NAME_LEN](#k_max_encoder_name_len)

[k_aenc_chn](#k_aenc_chn)

[k_audio_stream](#k_audio_stream)

[k_adec_chn_attr](#k_adec_chn_attr)

[k_adec_decoder](#k_adec_decoder)

[K_MAX_DECODER_NAME_LEN](#k_max_decoder_name_len)

[ADEC_MAX_CHN_NUMS](#adec_max_chn_nums)

#### k_payload_type

【说明】

定义音视频净荷类型枚举。

【定义】

```c
typedef enum {
K_PT_PCMU = 0,
K_PT_1016 = 1,
K_PT_G721 = 2,
K_PT_GSM = 3,
K_PT_G723 = 4,
K_PT_DVI4_8K = 5,
K_PT_DVI4_16K = 6,
K_PT_LPC = 7,
K_PT_PCMA = 8,
K_PT_G722 = 9,
K_PT_S16BE_STEREO = 10,
K_PT_S16BE_MONO = 11,
K_PT_QCELP = 12,
K_PT_CN = 13,
K_PT_MPEGAUDIO = 14,
K_PT_G728 = 15,
K_PT_DVI4_3 = 16,
K_PT_DVI4_4 = 17,
K_PT_G729 = 18,
K_PT_G711A = 19,
K_PT_G711U = 20,
K_PT_G726 = 21,
K_PT_G729A = 22,
K_PT_LPCM = 23,
K_PT_CelB = 25,
K_PT_JPEG = 26,
K_PT_CUSM = 27,
K_PT_NV = 28,
K_PT_PICW = 29,
K_PT_CPV = 30,
K_PT_H261 = 31,
K_PT_MPEGVIDEO = 32,
K_PT_MPEG2TS = 33,
K_PT_H263 = 34,
K_PT_SPEG = 35,
K_PT_MPEG2VIDEO = 36,
K_PT_AAC = 37,
K_PT_WMA9STD = 38,
K_PT_HEAAC = 39,
K_PT_PCM_VOICE = 40,
K_PT_PCM_AUDIO = 41,
K_PT_MP3 = 43,
K_PT_ADPCMA = 49,
K_PT_AEC = 50,
K_PT_X_LD = 95,
K_PT_H264 = 96,
K_PT_D_GSM_HR = 200,
K_PT_D_GSM_EFR = 201,
K_PT_D_L8 = 202,
K_PT_D_RED = 203,
K_PT_D_VDVI = 204,
K_PT_D_BT656 = 220,
K_PT_D_H263_1998 = 221,
K_PT_D_MP1S = 222,
K_PT_D_MP2P = 223,
K_PT_D_BMPEG = 224,
K_PT_MP4VIDEO = 230,
K_PT_MP4AUDIO = 237,
K_PT_VC1 = 238,
K_PT_JVC_ASF = 255,
K_PT_D_AVI = 256,
K_PT_DIVX3 = 257,
K_PT_AVS = 258,
K_PT_REAL8 = 259,
K_PT_REAL9 = 260,
K_PT_VP6 = 261,
K_PT_VP6F = 262,
K_PT_VP6A = 263,
K_PT_SORENSON = 264,
K_PT_H265 = 265,
K_PT_VP8 = 266,
K_PT_MVC = 267,
K_PT_PNG = 268,
K_PT_AMR = 1001,
K_PT_MJPEG = 1002,
K_PT_AMRWB = 1003,
K_PT_PRORES = 1006,
K_PT_OPUS = 1007,
K_PT_BUTT
} k_payload_type;
```

【注意事项】

无

【相关数据类型及接口】

无

#### k_aenc_encoder

【说明】

定义编码器属性结构体。

【定义】

```c
typedef struct {
k_payload_type k_u32 max_frame_len;
k_char name[K_MAX_ENCODER_NAME_LEN];
k_s32 (func_open_encoder)(void encoder_attr,void *encoder);
k_s32 (func_enc_frame)(void *encoder,const k_audio_frame *data,k_u8 *outbuf, k_u32 *out_len);
k_s32 (*func_close_encoder)(void *encoder);
} k_aenc_encoder;

```

【成员】

| 成员名称           | 描述                    |
|--------------------|-------------------------|
| type               | 编码协议类型。          |
| max_frame_len      | 最大码流长度。          |
| name               | 编码器名称。            |
| func_open_encoder  | 打开编码器的函数指针。  |
| func_enc_frame     | 进行编码的函数指针。    |
| func_close_encoder | 关闭编码器的函数指针。  |

【注意事项】

无

【相关数据类型及接口】

无

#### k_aenc_chn_attr

【说明】

定义编码器通道属性结构体。

【定义】

```c
typedef struct {
k_payload_type type;
k_u32 point_num_per_frame;
k_u32 buf_size; // buf size[2,K_MAX_AUDIO_FRAME_NUM]
} k_aenc_chn_attr;
```

【成员】

| 成员名称            | 描述                                                                                                    |
|---------------------|---------------------------------------------------------------------------------------------------------|
| type                | 音频编码协议类型。                                                                                      |
| point_num_per_frame | 音频编码协议对应的帧长（编码时收到的音频帧长小于等  于该帧长都可以进行编码）。                          |
| buf_size            | 音频编码缓存大小。  取值范围：`[2, K_MAX_AUDIO_FRAME_NUM]`，以帧为  单位。 |

【注意事项】

无

【相关数据类型及接口】

无

#### AENC_MAX_CHN_NUMS

【说明】

定义最大编码通道数。

【定义】

\#define AENC_MAX_CHN_NUMS 4

【注意事项】

无

【相关数据类型及接口】

无

#### K_MAX_ENCODER_NAME_LEN

【说明】

定义音频编码器名称最大长度。

【定义】

\#define K_MAX_ENCODER_NAME_LEN 25

【注意事项】

无

【相关数据类型及接口】

无

#### k_aenc_chn

【说明】

定义编码通道类型。

【定义】

typedef k_u32 k_aenc_chn;

【注意事项】

无

【相关数据类型及接口】

无

#### k_audio_stream

【说明】

定义码流结构体。

【定义】

```c
typedef struct {
void *stream; /* the virtual address of stream */
k_u64 phys_addr; /* the physics address of stream */
k_u32 len; /* stream lenth, by bytes */
k_u64 time_stamp; /* frame time stamp */
k_u32 seq; /* frame seq, if stream is not a valid frame,seq is 0 */
} k_audio_stream;
```

【成员】

| 成员名称   | 描述                         |
|------------|------------------------------|
| stream     | 音频码流数据指针             |
| phys_addr  | 音频码流的物理地址。         |
| len        | 音频码流长度。以byte为单位。 |
| time_stamp | 音频码流时间戳。             |
| seq        | 音频码流序号。               |

【注意事项】

无

【相关数据类型及接口】

无

#### k_adec_chn_attr

【说明】

定义解码器通道属性结构体。

【定义】

```c
typedef struct {
k_payload_type payload_type;
k_u32 point_num_per_frame;
k_u32 buf_size; /* buf size[2~K_MAX_AUDIO_FRAME_NUM] */
} k_adec_chn_attr;
```

【成员】

| 成员名称            | 描述                                                                                                    |
|---------------------|---------------------------------------------------------------------------------------------------------|
| type                | 音频解码协议类型。                                                                                      |
| point_num_per_frame | 音频解码协议对应的帧长                                                                                  |
| buf_size            | 音频编码缓存大小。  取值范围：`[2, K_MAX_AUDIO_FRAME_NUM]`，以帧为  单位。 |

【注意事项】

音频解码的部分属性需要与输出设备属性相匹配，例如采样率、帧长（每帧采样

点数目）等。

【相关数据类型及接口】

无

#### k_adec_decoder

【说明】

定义解码器属性结构体。

【定义】

```c
typedef struct {
k_payload_type payload_type;
k_char name[K_MAX_DECODER_NAME_LEN];
k_s32 (func_open_decoder)(void *decoder_attr, void **decoder);
k_s32 (*func_dec_frame)(void *decoder, k_u8 **inbuf, k_s32 *left_byte, k_u16*outbuf, k_u32 *out_len, k_u32 *chns);
k_s32 (*func_get_frame_info)(void *decoder, void *info);
k_s32 (*func_close_decoder)(void *decoder);
k_s32 (*func_reset_decoder)(void *decoder);
} k_adec_decoder;
```

【成员】

| 成员名称            | 描述                                    |
|---------------------|-----------------------------------------|
| type                | 解码协议类型。                          |
| name                | 解码器名称。                            |
| func_open_decoder   | 打开解码器的函数指针。                  |
| func_get_frame_info | 获取音频帧信息的函数指针。              |
| func_close_decoder  | 关闭解码器的函数指针。                  |
| func_reset_decoder  | 清空缓存buffer，复位解码器的函数指针。  |

【注意事项】

无

【相关数据类型及接口】

无

#### K_MAX_DECODER_NAME_LEN

【说明】

定义音频解码器名称最大长度。

【定义】

\#define K_MAX_DECODER_NAME_LEN 25

【注意事项】

无

【相关数据类型及接口】

无

#### ADEC_MAX_CHN_NUMS

【说明】

定义最大解码通道数。

【定义】

\#define ADEC_MAX_CHN_NUMS 4

【注意事项】

无

【相关数据类型及接口】

无

#### k_adec_chn

【说明】

定义解码通道类型。

【定义】

typedef k_u32 k_adec_chn;

【注意事项】

无

【相关数据类型及接口】

无

## 错误码

### 音频输入API 错误码

| 错误代码 | 宏定义                 | 描述                        |
|----------|------------------------|-----------------------------|
|0xA0158001| K_ERR_AI_INVALID_DEVID | 音频输入设备号无效          |
|0xA0158002| K_ERR_AI_INVALID_CHNID | 音频输入通道号无效          |
|0xA0158003| K_ERR_AI_ILLEGAL_PARAM | 音频输入参数设置无效        |
|0xA0158004| K_ERR_AI_NOT_ENABLED   | 音频输入设备或通道没有使 能 |
|0xA0158005| K_ERR_AI_NULL_PTR      | 输入参数空指针错误          |
|0xA0158006| K_ERR_AI_NOT_CFG       | 音频输入设备属性未设置      |
|0xA0158007| K_ERR_AI_NOT_SUPPORT   | 操作不支持                  |
|0xA0158008| K_ERR_AI_NOT_PERM      | 操作不允许                  |
|0xA0158009| K_ERR_AI_NO_MEM        | 分配内存失败                |
|0xA015800A| K_ERR_AI_NO_BUF        | 音频输入缓存不足            |
|0xA015800B| K_ERR_AI_BUF_EMPTY     | 音频输入缓存为空            |
|0xA015800C| K_ERR_AI_BUF_FULL      | 音频输入缓存为满            |
|0xA015800D| K_ERR_AI_NOT_READY     | 音频输入系统未初始化        |
|0xA015800E| K_ERR_AI_BUSY          | 音频输入系统忙              |
