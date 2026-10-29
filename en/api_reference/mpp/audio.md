# K230 Audio API Reference

## Overview

### Overview

The audio module is a highly integrated module designed to meet the multimedia business requirements of the k230 platform. It is composed of multiple sub-modules that work together, including Audio Input (AI), Audio Output (AO), Audio Encoding (AENC), and Audio Decoding (ADEC), and also has a built-in audio codec. The sub-modules adopt a low-coupling architecture design, achieving efficient and stable data flow transmission.

#### Sub-module Function Details

- **Audio Input Module (AI)**: This module features flexible interface compatibility and supports two interface standards: I2S (Inter-IC Sound) and PDM (Pulse Density Modulation). In terms of data processing, it uses PDMA (Peripheral Direct Memory Access) technology to achieve fast memory copies, ensuring efficient transmission of audio data. It can handle input signals from different types of audio sources, including digital microphones using PDM or I2S interfaces, as well as analog microphones connected through I2S interfaces.

- **Built-in Audio Codec**: The module integrates an audio codec, which not only performs basic audio signal conversion functions but also has a software-implemented audio3a algorithm built in. This algorithm covers functions such as Acoustic Echo Cancellation (AEC), Acoustic Noise Reduction (ANR), and Automatic Gain Control (AGC), which can effectively enhance audio quality and provide users with a clear and pure audio experience.

- **Audio Output Module (AO)**: It supports the I2S interface and also uses PDMA for memory copy operations. This module has extensive device connectivity capabilities. It can connect to external digital speakers and directly output digital audio signals; it can also use the audio codec to convert digital audio signals into analog signals for output, adapting to different types of audio playback devices.

- **Audio Encoding and Decoding Modules (AENC and ADEC)**: The audio codec module (AENC/ADEC) provides standardized encoding and decoding capabilities for audio data processing. It natively supports two mainstream audio formats, G711 and Opus, which can meet the audio encoding and decoding requirements in different scenarios. It also has flexible expansion capabilities to adapt to diverse business application scenarios.
G711 is a classic and universal audio encoding standard in the industry. It uses Pulse Code Modulation (PCM) compression. Its encoding and decoding algorithm is simple, with low processing latency, and has extremely strong compatibility. It is widely adapted to various basic audio communication, capture, and playback scenarios, with high operational stability, and can be quickly integrated without complex configuration;
Opus is a new generation of open-source and efficient audio encoding format that balances low latency and high compression ratio. It supports audio encoding from narrowband to full-band, and can maintain excellent audio quality even at low bit rates. At the same time, it is adapted to mid-to-high-end application scenarios such as real-time voice calls and audio stream transmission that have requirements for both latency and audio quality, with outstanding flexibility and practicality.
The module design follows an extensible architecture and provides standardized open extension interfaces. It supports users to register custom external codecs according to business requirements, quickly expanding the encoding and decoding capabilities of more audio formats, breaking the limitations of native formats, fully meeting various differentiated and customized audio processing requirements, and adapting to richer industry application scenarios.

#### Scenario Applications

For example, in a voice call scenario, the sub-modules of the audio module work together to form a complete audio processing and transmission link. The specific process is as follows:

1. **Audio Input Module (AI)**: This module is responsible for capturing local audio data, and signals from either digital microphones or analog audio codecs can be accurately captured. The audio input module also supports 3A processing (Automatic Gain Control, Acoustic Echo Cancellation, and Noise Suppression) to improve audio quality and ensure that the output audio signal is clear and pure.
1. **Audio Encoding Module (AENC)**: It encodes the captured audio data according to the G711 format to reduce the data volume and facilitate efficient transmission over the network.
1. **Network Transmission**: The encoded audio data is sent to the remote device over the network.
1. **Audio Decoding Module (ADEC)**: After the remote device receives the audio encoded data, it transmits it to the audio decoding module, which decodes the encoded data to restore the original audio signal.
1. **Audio Output Module (AO)**: The decoded audio signal is played through the audio output module, thereby achieving clear reproduction of the remote sound.

Through the above working mode, the audio module achieves efficient and stable audio data processing and transmission in voice call services, providing users with a high-quality voice communication experience.

![img](https://download.kendryte.com/developer/pictures/b96e2ea6fe9536e76af33afe46b2069e.png)

### Function Description

#### Audio Input Module (AI)

The core function of the Audio Input Module (AI) is to configure and enable audio input devices, and obtain audio frame data from them. This module supports both I2S and PDM protocol interfaces to meet different audio acquisition requirements.

##### I2S Audio Interface

- **Number of Channels**: Supports simultaneous acquisition of up to 2 channels of dual-channel audio, enabling high-quality stereo audio capture.
- **Sampling Parameters**:
  - **Sampling Rate**: Supports 8kHz, 12kHz, 16kHz, 24kHz, 32kHz, 44.1kHz, 48kHz, 96kHz, and 192kHz. Users can select an appropriate sampling rate based on actual application scenarios.
  - **Sampling Precision**: Provides three options: 16bit, 24bit, and 32bit, suitable for scenarios with different audio quality requirements.
- **IO Configuration and Working Mode**:
  - **IO Configuration**: Supports 2 groups of configurable input/output IO pins for transmitting I2S audio data.
  - **Working Mode**: Supports full-duplex mode, allowing simultaneous audio data input and output operations.

##### PDM Audio Interface

- **Number of Channels**: Supports simultaneous acquisition of up to 8 channels of mono audio, suitable for multi-audio source acquisition scenarios.
- **Sampling Parameters**:
  - **Bit Width and Sampling Clock Frequency**: Supports PDM audio input with 1bit bit width, sampling clock frequencies of 0.256MHz, 0.384MHz, 0.512MHz, 0.768MHz, 1.024MHz, 1.4112MHz, 1.536MHz, 2.048MHz, 2.8224MHz, 3.072MHz, 4.096MHz, 5.6448MHz, 6.144MHz, 12.288MHz, 24.576MHz, and the input PCM audio sampling rates are 8kHz, 12kHz, 16kHz, 24kHz, 32kHz, 44.1kHz, 48kHz, 96kHz, 192kHz.
  - **PCM Audio Sampling Rate**: Supports 8kHz, 12kHz, 16kHz, 24kHz, 32kHz, 44.1kHz, 48kHz, 96kHz, and 192kHz.
  - **Sampling Precision**: Supports three sampling precisions: 16bit, 24bit, and 32bit.
  - **Oversampling Rate**: Supports 128, 64, 32 times oversampling to improve audio resolution and signal-to-noise ratio.
- **IO Configuration and Channel Mode**:
  - **Number of IOs**: Supports 1 - 4 IO pins for inputting PDM audio data.
  - **Channel Mode**: Supports 1 - 8 PDM channels, supports PDM left/right mono mode and dual-channel mode.

#### Audio Output Module (AO)

The main function of the Audio Output Module (AO) is to enable audio output devices and send audio frame data to the corresponding output channels. This module only supports the I2S protocol interface.

##### I2S Audio Interface

- **Number of Channels**: Supports simultaneous output of up to 2 channels of dual-channel audio, achieving high-quality stereo audio output.
- **Sampling Parameters**:
  - **Sampling Rate**: Supports 8kHz, 12kHz, 16kHz, 24kHz, 32kHz, 44.1kHz, 48kHz, 96kHz, and 192kHz, ensuring compatibility of sampling rates between input and output audio data.
  - **Sampling Precision**: Supports 16bit, 24bit, and 32bit sampling precision, ensuring the integrity and consistency of audio data.
- **IO Configuration and Working Mode**:
  - **IO Configuration**: Supports 2 groups of configurable input/output IO pins for transmitting I2S audio data.
  - **Working Mode**: Supports full-duplex mode, allowing simultaneous input and output operations of audio data.

#### Audio Link

##### Basics of Audio Signal Conversion

The audio codec plays a key role in the audio link. The K230 has a built-in audio codec. When the analog microphone receives an audio signal, the audio codec converts these analog signals into Pulse Code Modulation (PCM) data in I2S format, which is then input to the I2S interface of the audio module. Conversely, when the I2S interface outputs PCM data, the audio codec converts it back into an analog signal and outputs it. In this mode, data transmission is fixed to use the sdi0 and sdo0 interfaces of I2S, without using the digital IO interface.

##### I2S Interface Connection Method

The I2S interface is highly flexible. It can directly connect to off-chip digital microphones for audio signal acquisition, or connect to a power amplifier (PA) to amplify the processed audio signal for output. The I2S interface has two groups available for selection, namely sdi0, sdo0 and sdi1, sdo1. Users can choose the appropriate interface group based on actual hardware connection requirements and system design schemes.

##### PDM Microphone Input Method

For off-chip Pulse Density Modulation (PDM) microphones, the audio module provides up to 4 input data interfaces, supporting simultaneous input of up to 8 channels of PDM data, meeting the needs of multi-channel audio acquisition.

##### Available Audio Link Schemes

To meet the needs of different users, the system provides multiple audio link schemes:

- **Scheme 1: 3 groups of PDM input + 1 group of I2S input + 2 groups of I2S output**
  - 3 groups of PDM input channels, which can connect multiple PDM microphones for audio acquisition.
  - 1 group of I2S input channel, which can use the built-in audio codec or connect to off-chip I2S devices.
  - 2 groups of I2S output channels, used to output processed audio signals.

- **Scheme 2: 4 groups of PDM input + 2 groups of I2S output**
  - 4 groups of PDM input channels, capable of connecting more PDM microphones for audio acquisition.
  - 2 groups of I2S output channels, used to output processed audio signals.

- **Scheme 3: 2 groups of I2S input + 2 groups of PDM input + 2 groups of I2S output**
  - 2 groups of I2S input channels and 2 groups of PDM input channels, which can simultaneously connect different types of audio input devices.
  - 2 groups of I2S output channels, used to output processed audio signals.

##### Hardware Usage Instructions

The K230 board is equipped with an onboard microphone and a 3.5mm headphone interface. Users can use the built-in audio codec to test the input and output functions of one group of I2S audio and the related functions of the audio codec. If more rich audio input and output functions are required, such as the input and output of 2 groups of I2S audio and the input function of 4 groups of PDM audio, users need to design and produce an audio daughter board by themselves to implement them.

## API Reference

### Audio Input

This function module provides the following APIs:

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

#### kd_mpi_ai_set_pub_attr

【Description】

Sets AI device attributes.

【Syntax】

```c
k_s32 kd_mpi_ai_set_pub_attr([k_audio_dev](#k_audio_dev) ai_dev, const [k_aio_dev_attr](#k_aio_dev_attr) *attr);
```

【Parameters】

| Parameter Name | Description              | Input/Output |
|----------|-------------------|-----------|
| ai_dev   | Audio device number.      | Input      |
| attr     | AI device attribute pointer.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

【Note】

None

【Example】

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

【Description】

Gets AI device attributes.

【Syntax】

```c
k_s32 kd_mpi_ai_get_pub_attr([k_audio_dev](#k_audio_dev) ai_dev, [k_aio_dev_attr](#k_aio_dev_attr) *attr)
```

【Parameters】

| Parameter Name | Description             | Input/Output |
|----------|------------------|-----------|
| ai_dev   | Audio device number.     | Input      |
| attr     | AI device attribute pointer. | Output      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

#### kd_mpi_ai_enable

【Description】

Enables the AI device.

【Syntax】

```c
k_s32 kd_mpi_ai_enable([k_audio_dev](#k_audio_dev) ai_dev);
```

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ai_dev   | Audio device number.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

#### kd_mpi_ai_disable

【Description】

Disables the AI device.

【Syntax】

```c
k_s32 kd_mpi_ai_disable([k_audio_dev](#k_audio_dev) ai_dev);
```

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ai_dev   | Audio device number.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

#### kd_mpi_ai_enable_chn

【Description】

Enables the AI channel.

【Syntax】

```c
k_s32 kd_mpi_ai_enable_chn([k_audio_dev](#k_audio_dev) ai_dev,[k_ai_chn](#k_ai_chn) ai_chn);
```

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ai_dev   | Audio device number.  | Input      |
| ai_chn   | Audio channel number.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

#### kd_mpi_ai_disable_chn

【Description】

Disables the AI channel.

【Syntax】

```c
k_s32 kd_mpi_ai_disable_chn([k_audio_dev](#k_audio_dev) ai_dev,[k_ai_chn](#k_ai_chn) ai_chn);
```

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ai_dev   | Audio device number.  | Input      |
| ai_chn   | Audio channel number.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

#### kd_mpi_ai_get_frame

【Description】

Gets the audio frame.

【Syntax】

```c
k_s32 kd_mpi_ai_get_frame([k_audio_dev](#k_audio_dev) ai_dev,[k_ai_chn](#k_ai_chn) ai_chn,[k_audio_frame](#k_audio_frame)*frame, k_u32 milli_sec);
```

【Parameters】

| Parameter Name  | Description                                                                                                                                        | Input/Output |
|-----------|-----------------------------------------------------------------------------|-----------|
| ai_dev    | Audio device number.                                                                                                                                | Input      |
| ai_chn    | Audio channel number.                                                                                                                                | Input      |
| frame     | Audio frame data.                                                                                                                                | Output      |
| milli_sec | Timeout for getting data. -1 indicates blocking mode, waiting indefinitely when there is no data;  0 indicates non-blocking mode, returning an error when there is no data;  >0 indicates blocking for milli_sec milliseconds, returning a timeout error when no data is available.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

【Note】

- The value of milli_sec must be greater than or equal to -1. When it is -1, the blocking mode is used to get data; when it is 0, the non-blocking mode is used to get data; when it is greater than 0, it blocks for milli_sec milliseconds, and returns a timeout error if no data is available.

- Before getting audio frame data, the corresponding AI channel must be enabled first.

【Example】

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

【Description】

Releases the audio frame.

【Syntax】

```c
k_s32 kd_mpi_ai_release_frame([k_audio_dev](#k_audio_dev) ai_dev,[k_ai_chn](#k_ai_chn) ai_chn,const [k_audio_frame](#k_audio_frame) *frame);
```

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ai_dev   | Audio device number.  | Input      |
| ai_chn   | Audio channel number.  | Input      |
| frame    | Audio frame data.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

#### kd_mpi_ai_set_vqe_attr

【Description】

Sets the voice quality enhancement related attributes of AI.

【Syntax】

```c
k_s32 kd_mpi_ai_set_vqe_attr([k_audio_dev](#k_audio_dev) ai_dev, [k_ai_chn](#k_ai_chn) ai_chn, const [k_ai_vqe_enable](#k_ai_vqe_enable) vqe_enable);
```

【Parameters】

| Parameter Name   | Description                                                      | Input/Output |
|------------|-----------------------------------------------------------|-----------|
| ai_dev     | Audio device number.                                              | Input      |
| ai_chn     | Audio channel number.                                              | Input      |
| vqe_enable | Voice quality enhancement enable flag.                                   | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h

Library file: libai.a

【Note】

The sampling precision supported by audio 3a is 16bit, and agc only supports 8k/16k/32k/48k.

#### kd_mpi_ai_get_vqe_attr

【Description】

Gets the voice quality enhancement related attributes of AI.

【Syntax】

k_s32 kd_mpi_ai_get_vqe_attr([k_audio_dev](#k_audio_dev) ai_dev, [k_ai_chn](#k_ai_chn) ai_chn, [k_ai_vqe_enable](#k_ai_vqe_enable) vqe_enable);

【Parameters】

| Parameter Name   | Description                                                          | Input/Output |
|------------|---------------------------------------------------------------|-----------|
| ai_dev     | Audio device number.                                                  | Input      |
| ai_chn     | Audio channel number.                                                  | Input      |
| vqe_enable | Voice quality enhancement enable flag pointer.                                    | Output      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure, refer to the error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

### Audio Output

This module provides the following APIs:

- [kd_mpi_ao_set_pub_attr](#kd_mpi_ao_set_pub_attr)
- [kd_mpi_ao_get_pub_attr](#kd_mpi_ai_get_pub_attr)
- [kd_mpi_ao_enable](#kd_mpi_ao_enable)
- [kd_mpi_ao_disable](#kd_mpi_ao_disable)
- [kd_mpi_ao_enable_chn](#kd_mpi_ao_enable_chn)
- [kd_mpi_ao_disable_chn](#kd_mpi_ao_disable_chn)
- [kd_mpi_ao_send_frame](#kd_mpi_ao_send_frame)

#### kd_mpi_ao_set_pub_attr

【Description】

Set AO device attributes.

【Syntax】

k_s32 kd_mpi_ao_set_pub_attr([k_audio_dev](#k_audio_dev) ao_dev, const [k_aio_dev_attr](#k_aio_dev_attr) *attr);

【Parameters】

| Parameter Name | Description              | Input/Output |
|----------|-------------------|-----------|
| ao_dev   | Audio device number.      | Input      |
| attr     | Pointer to AO device attributes.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure, refer to error code for its value |

【Requirements】

- Header file: mpi_ao_api.h
- Library file: libao.a

【Note】

None

【Example】

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

【Description】

Get AO device attributes.

【Syntax】

k_s32 kd_mpi_ao_get_pub_attr([k_audio_dev](#k_audio_dev) ao_dev, [k_aio_dev_attr](#k_aio_dev_attr) *attr);

【Parameters】

| Parameter Name | Description             | Input/Output |
|----------|------------------|-----------|
| ao_dev   | Audio device number.     | Input      |
| attr     | Pointer to AO device attributes. | Output      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure, refer to error code for its value |

【Requirements】

- Header file: mpi_ao_api.h
- Library file: libao.a

#### kd_mpi_ao_enable

【Description】

Enable ao device.

【Syntax】

k_s32 kd_mpi_ao_enable([k_audio_dev](#k_audio_dev) ao_dev);

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ao_dev   | Audio device number.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure, refer to error code for its value |

【Requirements】

- Header file: mpi_ao_api.h
- Library file: libao.a

#### kd_mpi_ao_disable

【Description】

Disable ao device.

【Syntax】

k_s32 kd_mpi_ao_disable([k_audio_dev](#k_audio_dev) ao_dev);

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ao_dev   | Audio device number.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure, refer to error code for its value |

【Requirements】

- Header file: mpi_ao_api.h
- Library file: libao.a

#### kd_mpi_ao_enable_chn

【Description】

Enable ao channel.

【Syntax】

k_s32 kd_mpi_ao_enable_chn([k_audio_dev](#k_audio_dev) ao_dev,[k_ao_chn](#k_ao_chn) ao_chn);

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ao_dev   | Audio device number.  | Input      |
| ao_chn   | Audio channel number.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure, refer to error code for its value |

【Requirements】

- Header file: mpi_ao_api.h
- Library file: libao.a

#### kd_mpi_ao_disable_chn

【Description】

Disable ao channel.

【Syntax】

k_s32 kd_mpi_ao_disable_chn([k_audio_dev](#k_audio_dev) ao_dev,[k_ao_chn](#k_ao_chn) ao_chn);

【Parameters】

| Parameter Name | Description          | Input/Output |
|----------|---------------|-----------|
| ao_dev   | Audio device number.  | Input      |
| ao_chn   | Audio channel number.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure, refer to error code for its value |

【Requirements】

- Header file: mpi_ao_api.h
- Library file: libao.a

#### kd_mpi_ao_send_frame

【Description】

Send ao frame data.

【Syntax】

k_s32 kd_mpi_ao_send_frame

([k_audio_dev](#k_audio_dev) ao_dev,[k_ao_chn](#k_ao_chn) ao_chn,const [k_audio_frame](#k_audio_frame)*frame,k_s32 milli_sec);

【Parameters】

| Parameter Name  | Description                                                                                                                                        | Input/Output |
|-----------|---------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| ao_dev    | Audio device number.                                                                                                                                | Input      |
| ao_chn    | Audio channel number.                                                                                                                                | Input      |
| frame     | Pointer to audio frame data.                                                                                                                            | Input      |
| milli_sec | Timeout for sending data. -1 indicates blocking mode, waits indefinitely when no data is available;  0 indicates non-blocking mode, returns an error when no data is available;  >0 indicates blocking for milli_sec milliseconds, returns a timeout error if no data is received.  | Input      |

【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0    | Failure, refer to error code for its value |

【Requirements】

- Header file: mpi_ai_api.h
- Library file: libai.a

【Note】

- The value of milli_sec must be greater than or equal to -1. When it is -1, blocking mode is used to get data; when it is 0, non-blocking mode is used to get data; when it is greater than 0, after blocking for milli_sec milliseconds, if there is no data, it returns a timeout error.

- Before sending audio frame data, the corresponding AO channel must be enabled first.

【Example】

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

### Audio Encoding

The audio encoding mainly implements functions such as creating encoding channels, sending audio frames for encoding, and obtaining encoded streams. The audio encoding part provides g711a/u and opus encoding, and currently only supports 16-bit sampling precision.

This function module provides the following APIs:

- [kd_mpi_aenc_register_encoder](#kd_mpi_aenc_register_encoder): Register an encoder.
- [kd_mpi_aenc_unregister_encoder](#kd_mpi_aenc_unregister_encoder): Unregister an encoder.
- [kd_mpi_aenc_create_chn](#kd_mpi_aenc_create_chn): Create an encoding channel.
- [kd_mpi_aenc_destroy_chn](#kd_mpi_aenc_destroy_chn): Destroy an encoding channel.
- [kd_mpi_aenc_send_frame](#kd_mpi_aenc_send_frame): Send an audio frame for encoding.
- [kd_mpi_aenc_get_stream](#kd_mpi_aenc_get_stream): Obtain the audio encoded stream.
- [kd_mpi_aenc_release_stream](#kd_mpi_aenc_release_stream): Release the audio encoded stream.

#### kd_mpi_aenc_register_encoder

- 【Description】

Register an encoder.

- 【Syntax】

k_s32 kd_mpi_aenc_register_encoder(k_s32 \*handle, const [k_aenc_encoder](#k_aenc_encoder) \*encoder);

- 【Parameters】

| **Parameter Name** | **Description**          | **Input/Output** |
|--------------------|--------------------------|------------------|
| handle             | Registration handle.     | Output           |
| encoder            | Encoder attribute structure. | Input        |

- 【Notes】

The user registers an encoder with the AENC module by passing in the encoder attribute structure, and the registration handle is returned. The user can finally use the registration handle to unregister the encoder.

The AENC module can register a maximum of 20 encoders, and G711.a, G711.u, and opus encoders have already been registered by default.

The same encoding protocol does not allow duplicate registration of encoders. For example, if a G711 encoder has already been registered, it is not allowed to register another G711 encoder.

- 【Return Value】

| Return Value | Description              |
|--------------|--------------------------|
| 0            | Success                  |
| Non-0        | Failure, see error code. |

【Requirements】

- Header file: mpi_aenc_api.h
- Library file: libaenc.a

#### kd_mpi_aenc_unregister_encoder

- 【Description】

Unregister an encoder.

- 【Syntax】

k_s32 kd_mpi_aenc_unregister_encoder(k_s32 handle);

- 【Parameters】

| **Parameter Name** | **Description**    | **Input/Output** |
|--------------------|--------------------|------------------|
| handle             | Unregistration handle. | Input       |

- 【Return Value】

| Return Value | Description              |
|--------------|--------------------------|
| 0            | Success                  |
| Non-0        | Failure, see error code. |

【Requirements】

- Header file: mpi_aenc_api.h
- Library file: libaenc.a

#### kd_mpi_aenc_create_chn

- 【Description】

Create an audio encoding channel.

- 【Syntax】

k_s32 kd_mpi_aenc_create_chn([k_aenc_chn](#k_aenc_chn) aenc_chn, const [k_aenc_chn_attr](#k_aenc_chn_attr) \*attr);

| **Parameter Name** | **Description**                                                          | **Input/Output** |
|--------------------|--------------------------------------------------------------------------|------------------|
| aenc_chn           | Channel number. Value range: [0, [AENC_MAX_CHN_NUM](#aenc_max_chn_nums)). | Input           |
| attr               | Pointer to the audio encoding channel attribute.                         | Input           |

- 【Notes】

The buffer size is in units of frames, with a value range of [2, [K_MAX_AUDIO_FRAME_NUM](#k_max_audio_frame_num)). It is recommended to configure it to 10 or more. A buffer configuration that is too small may cause frame loss or other exceptions. Each encoding channel will configure the queue size according to the buffer size to cache encoded frame data.

- 【Return Value】

| Return Value | Description              |
|--------------|--------------------------|
| 0            | Success                  |
| Non-0        | Failure, see error code. |

【Requirements】

- Header file: mpi_aenc_api.h
- Library file: libaenc.a

#### kd_mpi_aenc_destroy_chn

- 【Description】

Destroy an audio encoding channel.

- 【Syntax】

k_s32 kd_mpi_aenc_destroy_chn([k_aenc_chn](#k_aenc_chn) aenc_chn);

| **Parameter Name** | **Description**                                                          | **Input/Output** |
|--------------------|--------------------------------------------------------------------------|------------------|
| aenc_chn           | Channel number. Value range: [0, [AENC_MAX_CHN_NUM](#aenc_max_chn_nums)). | Input           |

- 【Notes】

None

- 【Return Value】

| Return Value | Description              |
|--------------|--------------------------|
| 0            | Success                  |
| Non-0        | Failure, see error code. |

【Requirements】

- Header file: mpi_aenc_api.h
- Library file: libaenc.a

#### kd_mpi_aenc_send_frame

- 【Description】

Send an audio encoding frame.

- 【Syntax】

k_s32 kd_mpi_aenc_send_frame([k_aenc_chn](#k_aenc_chn) aenc_chn,const [k_audio_frame](#k_audio_frame) \*frame);

- 【Parameters】

| **Parameter Name** | **Description**                                     | **Input/Output** |
|--------------------|-----------------------------------------------------|------------------|
| aenc_chn           | Channel number. Value range: [0, AENC_MAX_CHN_NUM). Input | Input       |
| frame              | Pointer to the audio frame structure.                | Input           |

- 【Notes】

The audio encoding stream sending is a non-blocking interface. If the audio stream buffer is full, it will directly return failure. This interface is used for the user to actively send audio frames for encoding. If the AENC channel has already been bound to the AI through the system binding interface, it is not necessary and not recommended to call this interface. When calling this interface to send an audio encoding audio frame, the corresponding encoding channel must be created first.

- 【Return Value】

| Return Value | Description              |
|--------------|--------------------------|
| 0            | Success                  |
| Non-0        | Failure, see error code. |

【Requirements】

- Header file: mpi_aenc_api.h
- Library file: libaenc.a

#### kd_mpi_aenc_get_stream

- 【Description】

Obtain the audio encoded stream.

- 【Syntax】

k_s32 kd_mpi_aenc_get_stream([k_aenc_chn](#k_aenc_chn) aenc_chn, [k_audio_stream](#k_audio_stream) \*stream, k_s32 milli_sec);

- 【Parameters】

| **Parameter Name** | **Description**                                                                                                                                          | **Input/Output** |
|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|------------------|
| aenc_chn           | Channel number. Value range: [0, AENC_MAX_CHN_NUM).                                                                                                       | Input           |
| stream             | Obtained audio stream.                                                                                                                                    | Output          |
| milli_sec          | Timeout for obtaining data. -1 indicates blocking mode, waiting indefinitely when there is no data; 0 indicates non-blocking mode, returning an error when there is no data; \>0 indicates blocking for s32MilliSec milliseconds, returning an error and timing out. | Input           |

- 【Notes】

The stream can only be obtained after the channel is created, otherwise it will directly return failure. If the channel is destroyed during the process of obtaining the stream, it will immediately return failure.

The value of s32MilliSec must be greater than or equal to -1. When it is -1, the blocking mode is used to obtain data; when it is 0, the non-blocking mode is used to obtain data; when it is greater than 0, if there is no data after blocking for s32MilliSec milliseconds, a timeout will be returned with an error.

- 【Return Value】

| Return Value | Description              |
|--------------|--------------------------|
| 0            | Success                  |
| Non-0        | Failure, see error code. |

【Requirements】

- Header file: mpi_aenc_api.h
- Library file: libaenc.a

#### kd_mpi_aenc_release_stream

- 【Description】

Release the audio encoded stream.

- 【Syntax】

k_s32 kd_mpi_aenc_release_stream([k_aenc_chn](#k_aenc_chn) aenc_chn, const [k_audio_stream](#k_audio_stream) \*stream);

- 【Parameters】

| **Parameter Name** | **Description**                                | **Input/Output** |
|--------------------|------------------------------------------------|------------------|
| aenc_chn           | Channel number. Value range: [0, AENC_MAX_CHN_NUM). | Input       |
| stream             | Obtained audio stream.                          | Output          |

- 【Notes】

None

- 【Return Value】

| Return Value | Description              |
|--------------|--------------------------|
| 0            | Success                  |
| Non-0        | Failure, see error code. |

【Requirements】

- Header file: mpi_aenc_api.h
- Library file: libaenc.a

### Audio Decoding

Audio decoding mainly implements functions such as decoding channels, sending audio streams for decoding, and obtaining decoded audio frames.

The audio codec section provides g711a/u and opus decoding, and currently supports 16-bit sampling precision.

This function module provides the following APIs:

- [kd_mpi_adec_register_decoder](#kd_mpi_adec_register_decoder): Register a decoder
- [kd_mpi_adec_unregister_decoder](#kd_mpi_adec_unregister_decoder): Unregister a decoder
- [kd_mpi_adec_create_chn](#kd_mpi_adec_create_chn): Create an audio decoding channel
- [kd_mpi_adec_destroy_chn](#kd_mpi_adec_destroy_chn): Destroy an audio decoding channel
- [kd_mpi_adec_send_stream](#kd_mpi_adec_send_stream): Send audio stream to audio decoding channel
- [kd_mpi_adec_clr_chn_buf](#kd_mpi_adec_clr_chn_buf): Clear the current audio data buffer in the ADEC channel.
- [kd_mpi_adec_get_frame](#kd_mpi_adec_get_frame): Obtain audio decoded frame data
- [kd_mpi_adec_release_frame](#kd_mpi_adec_release_frame): Release audio decoded frame data

#### kd_mpi_adec_register_decoder

- 【Description】

Register a decoder.

- 【Syntax】

k_s32 kd_mpi_adec_register_decoder(k_s32 \*handle, const [k_adec_decoder](#k_adec_decoder) \*decoder);

- 【Parameters】

| **Parameter Name** | **Description**           | **Input/Output** |
|--------------|--------------------|---------------|
| handle       | Registration handle.         | Output          |
| decoder      | Decoder attribute structure. | Input          |

- 【Note】

The user registers a decoder with the ADEC module by passing in the decoder attribute structure, and returns a registration handle. The user can finally use the registration handle to unregister the decoder. The ADEC module can register up to 20 decoders, and it has already registered G711a, G711u, and opus decoders. The same decoding protocol is not allowed to be registered repeatedly. For example, if a G711 decoder is already registered, it is not allowed to register another G711 decoder.

- 【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure. For the value, refer to the error code |

【Requirements】

Header file: mpi_adec_api.h

Library file: libadec.a

#### kd_mpi_adec_unregister_decoder

- 【Description】

Unregister a decoder.

- 【Syntax】

k_s32 kd_mpi_adec_unregister_decoder(k_s32 handle);

- 【Parameters】

| **Parameter Name** | **Description**    | **Input/Output** |
|--------------|-------------|---------------|
| handle       | Unregistration handle.  | Input          |

- 【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure. For the value, refer to the error code |

- 【Requirements】
- Header file: mpi_adec_api.h
- Library file: libadec.a

#### kd_mpi_adec_create_chn

- 【Description】

Create an audio decoding channel.

- 【Syntax】

k_s32 kd_mpi_adec_create_chn([k_adec_chn](#k_adec_chn) adec_chn, const [k_adec_chn_attr](#k_adec_chn_attr) \*attr);

- 【Parameters】

| **Parameter Name** | **Description**                                                            | **Input/Output** |
|--------------|---------------------------------------------------------------------|---------------|
| adec_chn     | Channel number. Value range: [0, [ADEC_MAX_CHN_NUM](#adec_max_chn_nums)).  | Input          |
| attr         | Channel attribute pointer.                                                      | Input          |

- 【Note】

The protocol type specifies the decoding protocol of the channel. Currently, G711 and opus are supported. Some attributes of audio decoding need to match the output device attributes, such as sampling rate, frame length (number of sampling points per frame), etc. The buffer size is in frames, and the value range is [2, [K_MAX_AUDIO_FRAME_NUM](#k_max_audio_frame_num)). It is recommended to configure it to more than 10. Too small buffer configuration may cause exceptions such as frame loss. This interface can only be used before the channel is created (or after it is destroyed). If the channel has been created, it returns that the channel has been created.

- 【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure. For the value, refer to the error code |

【Requirements】

Header file: mpi_adec_api.h

Library file: libadec.a

#### kd_mpi_adec_destroy_chn

- 【Description】

Destroy an audio decoding channel.

- 【Syntax】

k_s32 kd_mpi_adec_destroy_chn([k_adec_chn](#k_adec_chn) adec_chn);

- 【Parameters】

| **Parameter Name** | **Description**                                                           | **Input/Output** |
|--------------|--------------------------------------------------------------------|---------------|
| adec_chn     | Channel number. Value range: [0, [ADEC_MAX_CHN_NUM](#adec_max_chn_nums)).  | Input          |

- 【Note】

None

- 【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure. For the value, refer to the error code |

- 【Requirements】
- Header file: mpi_adec_api.h
- Library file: libadec.a

#### kd_mpi_adec_send_stream

- 【Description】

Send audio stream to audio decoding channel.

- 【Syntax】

k_s32 kd_mpi_adec_send_stream(k_adec_chn adec_chn,const k_audio_stream \*stream,k_bool block);

- 【Parameters】

| **Parameter Name** | **Description**                                         | **Input/Output** |
|--------------|--------------------------------------------------|---------------|
| adec_chn     | Channel number. Value range: [0, [ADEC_MAX_CHN_NUM](#adec_max_chn_nums)).      | Input          |
| stream       | Audio stream.                                       | Input          |
| block        | Block flag. HI_TRUE: blocking. HI_FALSE: non-blocking.  | Input          |

- 【Note】

When sending data, it must be ensured that the channel has been created, otherwise it will directly return failure. If the channel is destroyed during data sending, it will immediately return failure. Supports sending streams in blocking or non-blocking mode. When sending streams in blocking mode, if the buffer used to cache decoded audio frames is full, the call to this interface will be blocked until the decoded audio frame data is taken away, or the ADEC channel is destroyed.

- 【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure. For the value, refer to the error code |

- 【Requirements】

Header file: mpi_adec_api.h

Library file: libadec.a

#### kd_mpi_adec_clr_chn_buf

- 【Description】

Clear the current audio data buffer in the ADEC channel.

- 【Syntax】

k_s32 kd_mpi_adec_clr_chn_buf([k_adec_chn](#k_adec_chn) adec_chn);

- 【Parameters】

| **Parameter Name** | **Description**                                                           | **Input/Output** |
|--------------|--------------------------------------------------------------------|---------------|
| adec_chn     | Channel number. Value range: [0, [ADEC_MAX_CHN_NUM](#adec_max_chn_nums)).  | Input          |

- 【Note】

It is required that the decoding channel has been created. If the channel is not created, the channel does not exist error code is returned.

- 【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure. For the value, refer to the error code |

- 【Requirements】

Header file: mpi_adec_api.h

Library file: libadec.a

#### kd_mpi_adec_get_frame

- 【Description】

Obtain audio decoded frame data.

- 【Syntax】

k_s32 kd_mpi_adec_get_frame([k_adec_chn](#k_adec_chn) adec_chn, [k_audio_frame](#k_audio_frame) \*frame, k_s32 milli_sec);

- 【Parameters】

| **Parameter Name** | **Description**                 | **Input/Output** |
|--------------|--------------------------|---------------|
| adec_chn     | Audio decoding channel.           | Input          |
| frame_info   | Audio frame data structure  Output   | Output          |
| block        | Whether to obtain in blocking mode       | Input          |

- 【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure. For the value, refer to the error code |

- 【Requirements】

Header file: mpi_adec_api.h

Library file: libadec.a

#### kd_mpi_adec_release_frame

- 【Description】

Release the obtained audio decoded frame data.

- 【Syntax】

k_s32 kd_mpi_adec_release_frame([k_adec_chn](#k_aenc_chn) adec_chn, const [k_audio_frame](#k_audio_frame) \*frame);

- 【Parameters】

| **Parameter Name** | **Description**                 | **Input/Output** |
|--------------|--------------------------|---------------|
| adec_chn     | Audio decoding channel.           | Input          |
| frame_info   | Audio frame data structure  Output   | Input          |

- 【Return Value】

| Return Value | Description                 |
|--------|----------------------|
| 0      | Success                 |
| Non-0  | Failure. For the value, refer to the error code |

- 【Requirements】

Header file: mpi_adec_api.h

Library file: libadec.a

### Built-in Audio Codec

The built-in Audio Codec mainly provides operations on hardware devices through ioctl. Among the provided ioctl cmds, some cmds do not need to be called by the user; the default values at module loading can be used directly. The ioctl call implements read/write operations on the built-in Audio Codec registers.

The control operations on the audio codec in the current version mainly include: ADC digital and analog volume, DAC digital/analog volume, ADC/DAC mute control. The control operations such as sampling rate, sampling precision, and I2S alignment mode are automatically completed by the kernel through the user's call to the AI and AO API interfaces (the kernel code automatically implements operations on the codec hardware device), and no longer provide ioctl interfaces for control.

Built-in Audio Codec standard function cmds:

- [k_acodec_set_gain_micl](#k_acodec_set_gain_micl)：Left channel input analog gain control
- [k_acodec_set_gain_micr](#k_acodec_set_gain_micr)：Right channel input analog gain control
- [k_acodec_set_adcl_volume](#k_acodec_set_adcl_volume)：Left channel input digital volume control
- [k_acodec_set_adcr_volume](#k_acodec_set_adcr_volume)：Right channel input digital volume control
- [k_acodec_set_alc_gain_micl](#k_acodec_set_alc_gain_micl)：ALC left channel input analog gain control
- [k_acodec_set_alc_gain_micr](#k_acodec_set_alc_gain_micr)：ALC right channel input analog gain control
- [k_acodec_set_gain_hpoutl](#k_acodec_set_gain_hpoutl)：Left channel output analog volume control
- [k_acodec_set_gain_hpoutr](#k_acodec_set_gain_hpoutr)：Right channel output analog volume control
- [k_acodec_set_dacl_volume](#k_acodec_set_dacl_volume)：Left channel output digital volume control
- [k_acodec_set_dacr_volume](#k_acodec_set_dacr_volume)：Right channel output digital volume control
- [k_acodec_set_micl_mute](#k_acodec_set_micl_mute)：Left channel input mute control
- [k_acodec_set_micr_mute](#k_acodec_set_micr_mute)：Right channel input mute control
- [k_acodec_set_dacl_mute](#k_acodec_set_dacl_mute)：Left channel output mute control
- [k_acodec_set_dacr_mute](#k_acodec_set_dacr_mute)：Right channel output mute control
- [k_acodec_get_gain_micl](#k_acodec_get_gain_micl)：Get left channel input analog gain value
- [k_acodec_get_gain_micr](#k_acodec_get_gain_micr)：Get right channel input analog gain value
- [k_acodec_get_adcl_volume](#k_acodec_get_adcl_volume)：Get left channel input digital volume value
- [k_acodec_get_adcr_volume](#k_acodec_get_adcr_volume)：Get right channel input digital volume value
- [k_acodec_get_alc_gain_micl](#k_acodec_get_alc_gain_micl)：Get ALC left channel input analog gain value
- [k_acodec_get_alc_gain_micr](#k_acodec_get_alc_gain_micr)：Get ALC right channel input analog gain value
- [k_acodec_get_gain_hpoutl](#k_acodec_get_gain_hpoutl)：Get left channel output analog volume value
- [k_acodec_get_gain_hpoutr](#k_acodec_get_gain_hpoutr)：Get right channel output analog volume value
- [k_acodec_get_dacl_volume](#k_acodec_get_dacl_volume)：Get left channel output digital volume value
- [k_acodec_get_dacr_volume](#k_acodec_get_dacr_volume)：Get right channel output digital volume value
- [k_acodec_reset](#k_acodec_reset)：Volume reset

#### k_acodec_set_gain_micl

- 【Description】

Left channel input analog gain control

- 【Syntax】

int ioctl (int fd, k_acodec_set_gain_micl, k_u32 \*arg);

- 【Parameters】

| **Parameter Name**     | **Description**           | **Input/Output** |
| ---------------------- | ------------------------- | ---------------- |
| fd                     | Audio Codec device file descriptor | Input           |
| k_acodec_set_gain_micl | ioctl number              | Input            |
| arg                    | Unsigned integer pointer  | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is 0db, 6db, 20db, 30db.

#### k_acodec_set_gain_micr

- 【Description】

Right channel input analog gain control

- 【Syntax】

int ioctl (int fd, k_acodec_set_gain_micr, k_u32 \*arg);

- 【Parameters】

| **Parameter Name**     | **Description**           | **Input/Output** |
| ---------------------- | ------------------------- | ---------------- |
| fd                     | Audio Codec device file descriptor | Input           |
| k_acodec_set_gain_micr | ioctl number              | Input            |
| arg                    | Unsigned integer pointer  | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is 0db, 6db, 20db, 30db.

#### k_acodec_set_adcl_volume

- 【Description】

Left channel input digital gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_adcl_volume, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_set_adcl_volume | ioctl number              | Input            |
| arg                      | Signed float pointer      | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-97,30]`, the larger the value, the larger the volume, increasing by 0.5db.

#### k_acodec_set_adcr_volume

- 【Description】

Right channel input digital gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_adcr_volume, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_set_adcr_volume | ioctl number              | Input            |
| arg                      | Signed float pointer      | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-97,30]`, the larger the value, the larger the volume, increasing by 0.5db.

#### k_acodec_set_alc_gain_micl

- 【Description】

Left channel ALC input analog gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_alc_gain_micl, float \*arg);

- 【Parameters】

| **Parameter Name**         | **Description**           | **Input/Output** |
| -------------------------- | ------------------------- | ---------------- |
| fd                         | Audio Codec device file descriptor | Input           |
| k_acodec_set_alc_gain_micl | ioctl number              | Input            |
| arg                        | Signed float pointer      | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-18,28.5]`, the larger the value, the larger the volume, increasing by 1.5db.

#### k_acodec_set_alc_gain_micr

- 【Description】

Right channel ALC input analog gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_alc_gain_micr, float \*arg);

- 【Parameters】

| **Parameter Name**         | **Description**           | **Input/Output** |
| -------------------------- | ------------------------- | ---------------- |
| fd                         | Audio Codec device file descriptor | Input           |
| k_acodec_set_alc_gain_micr | ioctl number              | Input            |
| arg                        | Signed float pointer      | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-18,28.5]`, the larger the value, the larger the volume, increasing by 1.5db.

#### k_acodec_set_gain_hpoutl

- 【Description】

Left channel output analog gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_gain_hpoutl, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_set_gain_hpoutl | ioctl number              | Input            |
| arg                      | Signed float pointer      | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-39,6]`, the larger the value, the larger the volume, increasing by 1.5db.

#### k_acodec_set_gain_hpoutr

- 【Description】

Right channel output analog gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_gain_hpoutr, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_set_gain_hpoutr | ioctl number              | Input            |
| arg                      | Signed float pointer      | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-39,6]`, the larger the value, the larger the volume, increasing by 1.5db.

#### k_acodec_set_dacl_volume

- 【Description】

Left channel output digital gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_dacl_volume, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_set_dacl_volume | ioctl number              | Input            |
| arg                      | Signed float pointer      | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-120,7]`, the larger the value, the larger the volume, increasing by 0.5db.

#### k_acodec_set_dacr_volume

- 【Description】

Right channel output digital gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_dacr_volume, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_set_dacr_volume | ioctl number              | Input            |
| arg                      | Signed float pointer      | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-120,7]`, the larger the value, the larger the volume, increasing by 0.5db.

#### k_acodec_set_micl_mute

- 【Description】

Left channel input mute control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_micl_mute, k_bool \*arg);

- 【Parameters】

| **Parameter Name**     | **Description**           | **Input/Output** |
| ---------------------- | ------------------------- | ---------------- |
| fd                     | Audio Codec device file descriptor | Input           |
| k_acodec_set_micl_mute | ioctl number              | Input            |
| arg                    | Bool pointer              | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

Value range: K_TRUE for mute, K_FALSE for unmute.

#### k_acodec_set_micr_mute

- 【Description】

Right channel input mute control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_micr_mute, k_bool \*arg);

- 【Parameters】

| **Parameter Name**     | **Description**           | **Input/Output** |
| ---------------------- | ------------------------- | ---------------- |
| fd                     | Audio Codec device file descriptor | Input           |
| k_acodec_set_micr_mute | ioctl number              | Input            |
| arg                    | Bool pointer              | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

Value range: K_TRUE for mute, K_FALSE for unmute.

#### k_acodec_set_dacl_mute

- 【Description】

Left channel output mute control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_dacl_mute, k_bool \*arg);

- 【Parameters】

| **Parameter Name**     | **Description**           | **Input/Output** |
| ---------------------- | ------------------------- | ---------------- |
| fd                     | Audio Codec device file descriptor | Input           |
| k_acodec_set_dacl_mute | ioctl number              | Input            |
| arg                    | Bool pointer              | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

Value range: K_TRUE for mute, K_FALSE for unmute.

#### k_acodec_set_dacr_mute

- 【Description】

Right channel output mute control.

- 【Syntax】

int ioctl (int fd, k_acodec_set_dacr_mute, k_bool \*arg);

- 【Parameters】

| **Parameter Name**     | **Description**           | **Input/Output** |
| ---------------------- | ------------------------- | ---------------- |
| fd                     | Audio Codec device file descriptor | Input           |
| k_acodec_set_dacr_mute | ioctl number              | Input            |
| arg                    | Bool pointer              | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

Value range: K_TRUE for mute, K_FALSE for unmute.

#### k_acodec_get_gain_micl

- 【Description】

Get left channel input analog gain value.

- 【Syntax】

int ioctl (int fd, k_acodec_get_gain_micl, k_u32 \*arg);

- 【Parameters】

| **Parameter Name**     | **Description**           | **Input/Output** |
| ---------------------- | ------------------------- | ---------------- |
| fd                     | Audio Codec device file descriptor | Input           |
| k_acodec_get_gain_micl | ioctl number              | Input            |
| arg                    | Unsigned integer pointer  | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The obtained analog gain range is 0db, 6db, 20db, 30db.

#### k_acodec_get_gain_micr

- 【Description】

Get right channel input analog gain value.

- 【Syntax】

int ioctl (int fd, k_acodec_get_gain_micr, k_u32 \*arg);

- 【Parameters】

| **Parameter Name**     | **Description**           | **Input/Output** |
| ---------------------- | ------------------------- | ---------------- |
| fd                     | Audio Codec device file descriptor | Input           |
| k_acodec_get_gain_micr | ioctl number              | Input            |
| arg                    | Unsigned integer pointer  | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The obtained analog gain range is 0db, 6db, 20db, 30db.

#### k_acodec_get_adcl_volume

- 【Description】

Get left channel input digital volume value

- 【Syntax】

int ioctl (int fd, k_acodec_get_adcl_volume, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_get_adcl_volume | ioctl number              | Input            |
| arg                      | Signed float pointer      | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-97,30]`, the larger the value, the larger the volume, increasing by 0.5db.

#### k_acodec_get_adcr_volume

- 【Description】

Get right channel input digital gain control value.

- 【Syntax】

int ioctl (int fd, k_acodec_get_adcr_volume, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_get_adcr_volume | ioctl number              | Input            |
| arg                      | Signed float pointer      | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-97,30]`, the larger the value, the larger the volume, increasing by 0.5db.

#### k_acodec_get_alc_gain_micl

- 【Description】

Get left channel ALC input analog gain value.

- 【Syntax】

int ioctl (int fd, k_acodec_set_alc_gain_micl, float \*arg);

- 【Parameters】

| **Parameter Name**         | **Description**           | **Input/Output** |
| -------------------------- | ------------------------- | ---------------- |
| fd                         | Audio Codec device file descriptor | Input           |
| k_acodec_get_alc_gain_micl | ioctl number              | Input            |
| arg                        | Signed float pointer      | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-18,28.5]`, the larger the value, the larger the volume, increasing by 1.5db.

#### k_acodec_get_alc_gain_micr

- 【Description】

Get right channel ALC input analog gain value.

- 【Syntax】

int ioctl (int fd, k_acodec_get_alc_gain_micr, float \*arg);

- 【Parameters】

| **Parameter Name**         | **Description**           | **Input/Output** |
| -------------------------- | ------------------------- | ---------------- |
| fd                         | Audio Codec device file descriptor | Input           |
| k_acodec_get_alc_gain_micr | ioctl number              | Input            |
| arg                        | Signed float pointer      | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-18,28.5]`, the larger the value, the larger the volume, increasing by 1.5db.

#### k_acodec_get_gain_hpoutl

- 【Description】

Get left channel output analog gain value.

- 【Syntax】

int ioctl (int fd, k_acodec_get_gain_hpoutl, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_get_gain_hpoutl | ioctl number              | Input            |
| arg                      | Signed float pointer      | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-39,6]`, the larger the value, the larger the volume, increasing by 1.5db.

#### k_acodec_get_gain_hpoutr

- 【Description】

Get right channel output analog gain control.

- 【Syntax】

int ioctl (int fd, k_acodec_get_gain_hpoutr, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_get_gain_hpoutr | ioctl number              | Input            |
| arg                      | Signed float pointer      | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-39,6]`, the larger the value, the larger the volume, increasing by 1.5db.

#### k_acodec_get_dacl_volume

- 【Description】

Get left channel output digital gain value.

- 【Syntax】

int ioctl (int fd, k_acodec_get_dacl_volume, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_get_dacl_volume | ioctl number              | Input            |
| arg                      | Signed float pointer      | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-120,7]`, the larger the value, the larger the volume, increasing by 0.5db.

#### k_acodec_get_dacr_volume

- 【Description】

Get right channel output digital gain value.

- 【Syntax】

int ioctl (int fd, k_acodec_get_dacr_volume, float \*arg);

- 【Parameters】

| **Parameter Name**       | **Description**           | **Input/Output** |
| ------------------------ | ------------------------- | ---------------- |
| fd                       | Audio Codec device file descriptor | Input           |
| k_acodec_get_dacr_volume | ioctl number              | Input            |
| arg                      | Signed float pointer      | Output           |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

The analog gain range is `[-120,7]`, the larger the value, the larger the volume, increasing by 0.5db.

#### k_acodec_reset

- 【Description】

Volume reset: including ADC, DAC, ALC digital and analog gain.

- 【Syntax】

int ioctl (int fd, k_acodec_reset, ...);

- 【Parameters】

| **Parameter Name** | **Description**           | **Input/Output** |
| ------------------ | ------------------------- | ---------------- |
| fd                 | Audio Codec device file descriptor | Input           |
| k_acodec_reset     | ioctl number              | Input            |

- 【Return Value】

| Return Value | Description            |
|--------------|------------------------|
| 0            | Success                |
| Non-0        | Failure, see error code for its value |

- 【Requirements】

Header file: k_acodec_comm.h

Library file: libacodec.a

- 【Note】

None

## Data Types

### Audio Input and Output

Data types and data structure definitions related to audio input and output are as follows:

- [k_audio_type](#k_audio_type): Defines the audio input and output type.
- [k_audio_dev](#k_audio_dev): Defines the audio device.
- [k_ai_chn](#k_ai_chn): Defines the ai channel.
- [k_ao_chn](#k_ao_chn): Defines the ao channel.
- [K_MAX_AUDIO_FRAME_NUM](#k_max_audio_frame_num): Defines the maximum number of audio decoding buffer frames.
- [k_audio_bit_width](#k_audio_bit_width): Defines the audio sampling precision.
- [k_audio_snd_mode](#k_audio_snd_mode): Defines the audio channel mode.
- [k_audio_pdm_oversample](#k_audio_pdm_oversample): Defines pdm oversampling.
- [k_aio_dev_attr](#k_aio_dev_attr): Defines the audio input and output device attribute structure.
- [k_audio_pdm_attr](#k_audio_pdm_attr): Defines pdm audio input attributes.
- [k_i2s_work_mode](#k_i2s_work_mode): Defines i2s work mode.
- [k_audio_i2s_attr](#k_audio_i2s_attr): Defines i2s audio input attributes.
- [k_aio_i2s_type](#k_aio_i2s_type): Defines i2s connected device type.
- [k_audio_frame](#k_audio_frame): Defines the audio frame structure.
- [k_ai_vqe_enable](#k_ai_vqe_enable): Defines the audio input voice quality enhancement configuration information structure.

#### k_audio_type

【Description】

Defines the audio input and output type.

【Definition】

```c
typedef enum {
KD_AUDIO_INPUT_TYPE_I2S = 0,//i2s in
KD_AUDIO_INPUT_TYPE_PDM = 1,//pdm in
KD_AUDIO_OUTPUT_TYPE_I2S = 2,//i2s out
} k_audio_type;
```

【Notes】

Audio input includes i2s and pdm, while audio output only supports i2s.

【Related Data Types and Interfaces】

None

#### k_audio_dev

【Description】

Defines the audio device.

【Definition】

**typedef k_u32 k_audio_dev;**

【Notes】

For the ai module, the k_audio_dev value is 0 and 1, where 0 is for i2s audio input, and 1 is for pdm audio input.

For the ao module, the k_audio_dev value is fixed at 0, which is i2s audio output.

#### k_ai_chn

【Description】

Defines the ai audio channel.

【Definition】

**typedef k_u32 k_ai_chn;**

【Notes】

For I2s audio input, there are 2 groups in total, with the value range of `[0,1]`.

For pdm audio input, there are 4 groups in total, with the value range of `[0,3]`.

#### k_ao_chn

【Description】

Defines the ao audio channel.

【Definition】

**typedef k_u32 k_ao_chn;**

【Notes】

For I2s audio output, there are 2 groups in total, with the value range of `[0,1]`.

#### K_MAX_AUDIO_FRAME_NUM

【Description】

Defines the maximum number of audio decoding buffer frames.

【Definition】

\#define K_MAX_AUDIO_FRAME_NUM 50

#### k_audio_bit_width

【Description】

- Defines the audio sampling precision.

【Definition】

```c
typedef enum {
KD_AUDIO_BIT_WIDTH_16 = 0, /* 16bit width */
KD_AUDIO_BIT_WIDTH_24 = 1, /* 24bit width */
KD_AUDIO_BIT_WIDTH_32 = 2, /* 32bit width */
} k_audio_bit_width;
```

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_audio_snd_mode

【Description】

- Defines the channel mode.

【Definition】

```c
typedef enum {
KD_AUDIO_SOUND_MODE_MONO = 0, /* mono */
KD_AUDIO_SOUND_MODE_STEREO = 1, /* stereo */
} k_audio_snd_mode;
```

#### k_audio_pdm_oversample

【Description】

Defines pdm oversampling.

【Definition】

```c
typedef enum
{
KD_AUDIO_PDM_INPUT_OVERSAMPLE_32 = 0,
KD_AUDIO_PDM_INPUT_OVERSAMPLE_64 ,
KD_AUDIO_PDM_INPUT_OVERSAMPLE_128 ,
} k_audio_pdm_oversample;
```

#### k_audio_pdm_attr

【Description】

Defines pdm audio input attributes.

【Definition】

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

【Members】

| Member Name         | Description                                                |
|---------------------|------------------------------------------------------------|
| chn_cnt             | Number of supported channels. Supports 1-4 channels, and channel enabling needs to be continuous. |
| sample_rate         | Sampling rate: supports 8k\~192k                           |
| bit_width           | Sampling precision: supports 16/24/32                     |
| snd_mode            | Audio channel mode. Supports mono and stereo.             |
| pdm_oversample      | Oversampling: supports 32, 64, 128 times oversampling.   |
| frame_num           | Number of buffer frames `[2,K_MAX_AUDIO_FRAME_NUM]`.      |
| point_num_per_frame | Number of sampling points per frame.                      |

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_audio_i2s_attr

【Description】

Defines i2s audio input attributes.

【Definition】

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

【Members】

| Member Name         | Description                                                 |
| ------------------- | ----------------------------------------------------------- |
| chn_cnt             | Number of supported channels. Supports 1-2 channels.        |
| sample_rate         | Sampling rate: supports 8k~192k                             |
| bit_width           | Sampling precision: supports 16/24/32                       |
| snd_mode            | Audio channel mode. Supports mono and stereo.              |
| mono_channel        | Mono source selection. 0: mic input, 1: headphone input    |
| I2s_mode            | I2s work mode: supports Philips mode, left-justified mode, right-justified mode. |
| frame_num           | Number of buffer frames `[2,K_MAX_AUDIO_FRAME_NUM]`.        |
| point_num_per_frame | Number of sampling points per frame `[sample_rate/100,sample_rate]`. |
| i2s_type            | I2s connected device type: internal codec or external device. |

【Notes】

The values of point_num_per_frame (number of sampling points per frame) and sample_rate determine the frequency of hardware interrupts. Too high a frequency will affect system performance and interfere with other services. It is recommended that the values of these two parameters satisfy the formula: (point_num_per_frame *1000)/ sample_rate >=10 (100 interrupts). For example, when the sampling rate is 16000Hz, it is recommended to set the number of sampling points to be greater than or equal to 160.

【Related Data Types and Interfaces】

None

#### k_i2s_work_mode

【Description】

Defines i2s work mode.

【Definition】

```c
typedef enum
{
K_STANDARD_MODE = 1,
K_RIGHT_JUSTIFYING_MODE = 2,
K_LEFT_JUSTIFYING_MODE = 4
} k_i2s_work_mode;
```

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_aio_dev_attr

【Description】

Defines the audio input and output device attribute structure.

【Definition】

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

【Members】

| Member Name   | Description                |
|---------------|----------------------------|
| audio_type    | Audio type.                |
| kd_audio_attr | Audio attribute settings.  |

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_aio_i2s_type

【Description】

Defines i2s connected device type.

【Definition】

```c
typedef enum
{
K_AIO_I2STYPE_INNERCODEC = 0, /* AIO I2S connect inner audio CODEC */
K_AIO_I2STYPE_EXTERN,/* AIO I2S connect extern hardware */
} k_aio_i2s_type;
```

【Notes】

The internal audio codec uses the 0th group i2s channel by default, and the 1st group i2s channel still uses the external codec.

【Related Data Types and Interfaces】

None

#### k_audio_frame

【Description】

Defines the audio frame structure.

【Definition】

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

【Members】

| Member Name | Description                       |
|------------|------------------------------------|
| bit_width  | Sampling precision.                |
| snd_mode   | Audio channel mode.                |
| virt_addr  | Virtual address of audio frame data. |
| phys_addr  | Physical address of audio frame data. |
| time_stamp | Audio frame timestamp, in μs.      |
| seq        | Audio frame sequence number.       |
| len        | Audio frame length, in bytes.      |
| pool_id    | Audio frame buffer pool ID.        |

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_ai_vqe_enable

【Description】

Defines the audio input voice quality enhancement configuration information structure.

【Definition】

typedef struct
{
    k_bool aec_enable;
    k_u32  aec_echo_delay_ms;//speaker playback time to mic recording time difference (100-500ms)
    k_bool agc_enable;
    k_bool ans_enable;
}k_ai_vqe_enable;

【Members】

| Member Name        | Description                       |
|--------------------|------------------------------------|
| aec_enable         | Echo cancellation enable.          |
| aec_echo_delay_ms  | The length of the echo cancellation filter, recommended to be 100-500ms. That is, the time difference between the speaker playback time and the mic recording time. The specific value of this parameter needs to be fine-tuned. Improper adjustment will directly affect the echo cancellation effect. |
| agc_enable         | Automatic gain control enable.     |
| ans_enable         | Audio noise suppression enable.    |

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_i2s_in_mono_channel

【Description】

- Mono source.

【Definition】

```c
typedef enum
{
    KD_I2S_IN_MONO_RIGHT_CHANNEL = 0,  //mic input
    KD_I2S_IN_MONO_LEFT_CHANNEL = 1,   //hp input
} k_i2s_in_mono_channel;
```

### Audio Codec

Audio codec-related data types and data structure definitions are as follows:

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

【Description】

Defines the audio/video payload type enumeration.

【Definition】

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

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_aenc_encoder

【Description】

Defines the encoder attribute structure.

【Definition】

```c
typedef struct {
k_payload_type k_u32 max_frame_len;
k_char name[K_MAX_ENCODER_NAME_LEN];
k_s32 (func_open_encoder)(void encoder_attr,void *encoder);
k_s32 (func_enc_frame)(void *encoder,const k_audio_frame *data,k_u8 *outbuf, k_u32 *out_len);
k_s32 (*func_close_encoder)(void *encoder);
} k_aenc_encoder;

```

【Members】

| Member Name        | Description                                       |
|--------------------|---------------------------------------------------|
| type               | Encoder protocol type.                            |
| max_frame_len      | Maximum stream length.                            |
| name               | Encoder name.                                     |
| func_open_encoder  | Function pointer for opening the encoder.         |
| func_enc_frame     | Function pointer for performing encoding.         |
| func_close_encoder | Function pointer for closing the encoder.         |

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_aenc_chn_attr

【Description】

Defines the encoder channel attribute structure.

【Definition】

```c
typedef struct {
k_payload_type type;
k_u32 point_num_per_frame;
k_u32 buf_size; // buf size[2,K_MAX_AUDIO_FRAME_NUM]
} k_aenc_chn_attr;
```

【Members】

| Member Name         | Description                                                                                                                                                  |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| type                | Audio encoding protocol type.                                                                                                                                |
| point_num_per_frame | The frame length corresponding to the audio encoding protocol (encoding can be performed when the received audio frame length is less than or equal to this frame length). |
| buf_size            | Audio encoding buffer size. Value range: `[2, K_MAX_AUDIO_FRAME_NUM]`, in units of frames.                                                                    |

【Notes】

None

【Related Data Types and Interfaces】

None

#### AENC_MAX_CHN_NUMS

【Description】

Defines the maximum number of encoding channels.

【Definition】

\#define AENC_MAX_CHN_NUMS 4

【Notes】

None

【Related Data Types and Interfaces】

None

#### K_MAX_ENCODER_NAME_LEN

【Description】

Defines the maximum length of the audio encoder name.

【Definition】

\#define K_MAX_ENCODER_NAME_LEN 25

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_aenc_chn

【Description】

Defines the encoding channel type.

【Definition】

typedef k_u32 k_aenc_chn;

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_audio_stream

【Description】

Defines the stream structure.

【Definition】

```c
typedef struct {
void *stream; /* the virtual address of stream */
k_u64 phys_addr; /* the physics address of stream */
k_u32 len; /* stream lenth, by bytes */
k_u64 time_stamp; /* frame time stamp */
k_u32 seq; /* frame seq, if stream is not a valid frame,seq is 0 */
} k_audio_stream;
```

【Members】

| Member Name | Description                              |
|-------------|------------------------------------------|
| stream      | Audio stream data pointer                |
| phys_addr   | Physical address of the audio stream.    |
| len         | Audio stream length. In units of bytes.  |
| time_stamp  | Audio stream time stamp.                 |
| seq         | Audio stream sequence number.            |

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_adec_chn_attr

【Description】

Defines the decoder channel attribute structure.

【Definition】

```c
typedef struct {
k_payload_type payload_type;
k_u32 point_num_per_frame;
k_u32 buf_size; /* buf size[2~K_MAX_AUDIO_FRAME_NUM] */
} k_adec_chn_attr;
```

【Members】

| Member Name         | Description                                                                                                                                                  |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| type                | Audio decoding protocol type.                                                                                                                                |
| point_num_per_frame | The frame length corresponding to the audio decoding protocol                                                                                                |
| buf_size            | Audio encoding buffer size. Value range: `[2, K_MAX_AUDIO_FRAME_NUM]`, in units of frames.                                                                    |

【Notes】

Some attributes of audio decoding need to match the output device attributes, such as sampling rate, frame length (number of samples per frame), etc.

【Related Data Types and Interfaces】

None

#### k_adec_decoder

【Description】

Defines the decoder attribute structure.

【Definition】

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

【Members】

| Member Name         | Description                                                  |
|---------------------|--------------------------------------------------------------|
| type                | Decoder protocol type.                                       |
| name                | Decoder name.                                                |
| func_open_decoder   | Function pointer for opening the decoder.                    |
| func_get_frame_info | Function pointer for getting audio frame information.        |
| func_close_decoder  | Function pointer for closing the decoder.                    |
| func_reset_decoder  | Function pointer for clearing buffer and resetting decoder.  |

【Notes】

None

【Related Data Types and Interfaces】

None

#### K_MAX_DECODER_NAME_LEN

【Description】

Defines the maximum length of the audio decoder name.

【Definition】

\#define K_MAX_DECODER_NAME_LEN 25

【Notes】

None

【Related Data Types and Interfaces】

None

#### ADEC_MAX_CHN_NUMS

【Description】

Defines the maximum number of decoding channels.

【Definition】

\#define ADEC_MAX_CHN_NUMS 4

【Notes】

None

【Related Data Types and Interfaces】

None

#### k_adec_chn

【Description】

Defines the decoding channel type.

【Definition】

typedef k_u32 k_adec_chn;

【Notes】

None

【Related Data Types and Interfaces】

None

## Error Codes

### Audio Input API Error Codes

| Error Code | Macro Definition         | Description                      |
|----------|------------------------|-----------------------------|
|0xA0158001| K_ERR_AI_INVALID_DEVID | Invalid audio input device ID          |
|0xA0158002| K_ERR_AI_INVALID_CHNID | Invalid audio input channel ID          |
|0xA0158003| K_ERR_AI_ILLEGAL_PARAM | Invalid audio input parameter setting        |
|0xA0158004| K_ERR_AI_NOT_ENABLED   | Audio input device or channel not enabled |
|0xA0158005| K_ERR_AI_NULL_PTR      | Null pointer error in input parameters          |
|0xA0158006| K_ERR_AI_NOT_CFG       | Audio input device attributes not set      |
|0xA0158007| K_ERR_AI_NOT_SUPPORT   | Operation not supported                  |
|0xA0158008| K_ERR_AI_NOT_PERM      | Operation not permitted                  |
|0xA0158009| K_ERR_AI_NO_MEM        | Memory allocation failed                |
|0xA015800A| K_ERR_AI_NO_BUF        | Insufficient audio input buffer            |
|0xA015800B| K_ERR_AI_BUF_EMPTY     | Audio input buffer is empty            |
|0xA015800C| K_ERR_AI_BUF_FULL      | Audio input buffer is full            |
|0xA015800D| K_ERR_AI_NOT_READY     | Audio input system not initialized        |
|0xA015800E| K_ERR_AI_BUSY          | Audio input system busy              |
