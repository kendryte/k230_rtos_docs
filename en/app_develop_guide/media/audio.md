# Audio Demo

## Introduction

This example fully implements audio input, output, encoding/decoding, and Audio 3A processing functions by calling the MPI API interface. The example covers the following test cases:

- **Audio Input Test**: Captures ambient sounds and saves them as WAV files, thereby verifying the accuracy and stability of the audio input function.
- **Audio Output Test**: Plays a specified WAV file and evaluates the quality of the audio output effect by listening through headphones.
- **Audio Input and Output Simultaneous Test**: Performs audio capture and playback in real time, achieving instant capture and playback of sound, and verifies the real-time processing capability of the system.
- **Audio Encoding and Decoding Test**: Uses the built-in G711a/u, opus 16bit audio codecs to perform encoding and decoding operations on audio data, testing the reliability of the encoding and decoding functions.

## Function Description

### Audio Input

The audio input function captures sound signals from the environment and saves them as files for in-depth analysis of the capture effect later. In this example, the system captures 15 seconds of audio data and saves it according to the WAV format standard. The generated WAV file can be played directly using the VLC player, making it convenient for users to intuitively evaluate the captured audio content.

### Audio Output

The audio output function plays WAV files and judges the output effect by listening through headphones. During the example test, users can upload WAV files in different formats for testing, so as to comprehensively verify the compatibility and performance of the audio output function under different file formats.

### Audio Input and Output

The audio input and output functions support simultaneous testing, which is mainly used to verify the I2S module function. During the test, the I2S audio input will capture sound signals from the environment in real time, and the I2S audio output will simultaneously play the captured sound in real time. After plugging in headphones, the user can hear the sound in the environment in real time, thereby evaluating the real-time processing performance of the I2S module.

### Audio Encoding and Decoding

This system has a built-in G711a/u 16bit audio codec, providing users with basic encoding and decoding capabilities. At the same time, the system is open and supports users to register other external codecs to meet diversified encoding and decoding needs.

### Audio 3A

Audio 3A (Automatic Acoustic Adjustment, automatic acoustic adjustment) includes the following key functions:

- **ANS (Automatic Noise Suppression)**: That is, the automatic noise suppression function, mainly used to effectively reduce the interference of environmental noise on audio signals and improve the purity of audio.
- **AGC (Automatic Gain Control)**: The automatic gain control function, whose role is to automatically adjust the gain of the audio signal, ensuring that the strength of the audio signal is always kept within an appropriate range, avoiding the signal being too strong or too weak.
- **AEC (Acoustic Echo Cancellation)**: The acoustic echo cancellation function can eliminate the echo generated during audio transmission and ensure the clarity of audio communication.

These functions can be enabled by setting different enable items. For specific usage methods and parameter settings, please refer to the API interface documentation for operation.

## Usage Instructions

### Code Location

Demo source code location: `/src/rtsmart/examples/mpp/sample_audio`.

Assume you have already correctly compiled the demo. After starting the development board, enter the `/sdcard/app/examples/mpp` directory, where `sample_audio.elf` is the test demo.

### Parameter Description

After starting the development board, enter the `/sdcard/app/examples/mpp` directory, and input `./sample_audio.elf -help` to view the demo usage.

| Parameter    | Description                                                                                                          | Default |
|--------------|----------------------------------------------------------------------------------------------------------------------|---------|
| type         | Test different module functions [0,12]                                                                               | -       |
| samplerate   | Configure the sampling rate of audio input and output (8k-192k)                                                      | 44100   |
| enablecodec  | Whether to enable the built-in codec [0,1]. 1: Use the built-in codec                                                | 0       |
| bitwidth     | Set the audio sampling precision [16,24,32].                                                                         | 16      |
| filename     | The name of the WAV/G711 file to load or save.                                                                       | -       |
| channels     | Set the number of audio channels, mono or stereo [1,2].                                                              | 2       |
| monochannel  | When set to mono, select the mono type [0,1]. 0: on-board mic, 1: headphone input                                    | 0       |
| audio3a      | Whether to enable Audio 3A: enable_ans: 0x01, enable_agc: 0x02, enable_aec: 0x04, multiple enable items can be stacked | 0       |

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
  type 13:sample overall test (opus ai->aenc  adec->ao loopback ) module
-samplerate: set audio sample(8000 ~ 192000)
-enablecodec: enable audio codec(0,1)
-loglevel: show kernel log level[0,7]
-bitwidth: set audio bit width(16,24,32)
-channels: channel count
-monochannel:0:mic input 1:headphone input
-filename: load or save file name
-audio3a: enable audio3a:enable_ans:0x01,enable_agc:0x02,enable_aec:0x04
```

## Example

### I2S Audio Input Test

Enter the following command to capture 15 seconds of PCM audio data and save it as a WAV file:

```shell
./sample_audio.elf -type 0 -enablecodec 1 -bitwidth 16 -filename test.wav -audio3a 1
```

After executing the above command, the system will start capturing audio data and display the following output:

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

The audio data will be saved to the specified WAV file.

### I2S Audio Output Test

This test verifies the audio output function by playing the WAV file in a loop. Users can press any key to exit the test.

Enter the following command to play the WAV audio:

```shell
./sample_audio.elf -type 2 -filename test.wav -enablecodec 1
```

After executing the above command, the system will start playing the specified WAV file and display the following output:

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

The audio will be played through the headphone or speaker, and users can exit the test by pressing any key.

### I2S Audio Input/Output API Interface Test

Use the following command to test the audio input/output functions in real time through the API interface:

```shell
./sample_audio.elf -type 3 -bitwidth 16 -enablecodec 1 -samplerate 8000 -audio3a 1
```

After executing the above command, the system will start capturing and playing audio in real time, and display the following output:

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

### I2S Audio Input and Output Module System Binding Test

Use the following command to test the audio input/output functions in real time by binding the AI and AO modules:

```shell
./sample_audio.elf -type 4 -bitwidth 16 -enablecodec 1 -samplerate 8000 -audio3a 1
```

After executing the above command, the system will bind the AI and AO modules by calling the system binding API interface `kd_mpi_sys_bind`, and display the following output:

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

### Encoding Test

Use the following command to obtain AI data and encode it to save to a file. Encoding/decoding only supports G711a/u/lpcm, 16bit.

System binding method:

```shell
./sample_audio.elf -type 7 -bitwidth 16 -enablecodec 1 -filename /sharefs/i2s_codec.g711a -audio3a 1
```

After executing the above command, the system will start encoding the audio data and display the following output:

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

API interface method:

```shell
./sample_audio.elf -type 9 -bitwidth 16 -enablecodec 1 -filename /sharefs/i2s_codec.g711a -audio3a 1
```

After executing the above command, the system will start encoding the audio data and display the following output:

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

### Decoding Test

Use the following command to read file data and decode it for playback. Encoding/decoding only supports G711a/u/lpcm, 16bit.

System binding method:

```shell
./sample_audio.elf -type 8 -filename /sharefs/i2s_codec.g711a -enablecodec 1 -bitwidth 16
```

After executing the above command, the system will start decoding the audio data and display the following output:

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

API interface method:

```shell
./sample_audio.elf -type 10 -filename /sharefs/i2s_codec.g711a -enablecodec 1 -bitwidth 16
```

After executing the above command, the system will start decoding the audio data and display the following output:

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

### Audio Full Process Test 1

The audio full process test includes two links: AI->AENC and ADEC->AO binding loopback test. This test uses the built-in codec with 16bit precision for simulation and enables the AEC software noise reduction function. At the same time, the timestamp of the stream after G711 encoding is tested.

Use the following command to perform the test:

```shell
./sample_audio.elf -type 12 -samplerate 48000 -enablecodec 1 -audio3a 1 &
```

After executing the above command, the system will start the audio full process test and display the following output:

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

Enter `cat /proc/umap/sysbind` to view the system bindings between modules:

```shell
-----BIND RELATION TABLE--------------------------------------------------------
  FirMod  FirDev  FirChn  SecMod  SecDev  SecChn  TirMod  TirDev  TirChn    SendCnt     rstCnt
      ai       0       0    aenc       0       0    null       0       0        310          0
    adec       0       0      ao       0       0    null       0       0        310          0
```

### Audio Full Process Test 2

The audio full process test includes two links: AI->AENC and ADEC->AO binding loopback test. This test uses the built-in codec with 16bit precision for simulation and enables the AEC software noise reduction function. At the same time, the timestamp of the stream after opus encoding is tested.

Use the following command to perform the test:

```shell
./sample_audio.elf -type 13 -samplerate 48000 -enablecodec 1 -audio3a 1 &
```

After executing the above command, the system will start the audio full process test and display the following output:

```shell
./sample_audio.elf -type 13 -samplerate 48000 -enablecodec 1 -audio3a 1 &
audio type:13,sample rate:48000,bit width:16,channels:2,enablecodec:1,monochannel:0
vb_set_config ok
audio_data_vb_create_pool poolid 0
enter q key to exit
sample ai->aenc  adec->ao module (opus,loopback)
Force the sampling accuracy to be set to 16,use inner cocdec
_opus_open_encoder enc_inst:0x79da80, samplerate:8000,channels:1
_opus_open_encoder ok
_opus_open_decoder dec_inst:0x0, samplerate:8000, channels:1 before
_opus_open_decoder ok
audio i2s set clk freq is 512000(512000),ret:1
audio codec adc clk freq is 2048000(2048000)
audio i2s set clk freq is 512000(512000),ret:1
audio init codec dac clk freq is 11289600
audio set codec dac clk freq is 2048000(2048000)
adec_bind_call_back dev_id:0 chn_id:0
...
q
adec_bind_call_back dev_id:0 chn_id:0
destroy vb block
sample done
```

Enter `cat /proc/umap/sysbind` to view the system bindings between modules:

```shell
-----BIND RELATION TABLE--------------------------------------------------------
  FirMod  FirDev  FirChn  SecMod  SecDev  SecChn  TirMod  TirDev  TirChn    SendCnt     rstCnt
      ai       0       0    aenc       0       0    null       0       0        310          0
    adec       0       0      ao       0       0    null       0       0        310          0
```

```{admonition} Tip
For the specific interfaces of the audio module, please refer to the [API Documentation](../../api_reference/mpp/audio.md)
```
