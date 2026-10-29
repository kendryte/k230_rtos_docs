# MP4 Demo

## Introduction

This example describes how to manipulate MP4 files. Through this example, you will learn how to use the API interfaces to implement MP4 file muxing (muxer) and demuxing (demuxer). In addition, you will learn how to capture camera video and onboard audio on the K230 platform, record MP4 files, and parse MP4 files to display video through video output (VO) and play audio through audio output (AO).

## Usage Instructions

### Code Location

- Recording example: /src/rtsmart/examples/mpp/sample_muxer
- Demuxing example: /src/rtsmart/examples/mpp/sample_demuxer
- Player example: /src/rtsmart/examples/mpp/sample_player

Assuming the demo has been compiled correctly, after starting the development board, enter the `/sdcard/app/examples/mpp` directory and run the corresponding demo programs in sequence for testing.

- Recording example: Run `sample_muxer.elf`
- Demuxing example: Run `sample_demuxer.elf`
- Player example: Run `sample_player.elf`

## Examples

### Example 1: Record MP4 File

This example demonstrates how to capture video and audio from a camera and generate an MP4 file. The video encoding format is H264, and the audio encoding format is G711. Execute the following command to start recording:

```shell
./sample_muxer.elf -o /data/test.mp4
```

During recording, press `Ctrl+C` to stop recording, and the generated MP4 file will be saved in the current directory.

### Example 2: Parse MP4 File

This example demonstrates how to parse an MP4 file and extract the audio and video data from it. Execute the following command to start parsing:

```shell
./sample_demuxer.elf /data/test.mp4
```

During parsing, press `Ctrl+C` to stop parsing, and the extracted audio and video data will be saved to the current directory.

### Example 3: Play MP4 File

This example demonstrates how to play an MP4 file and select the output device (HDMI or LCD). Execute the following command to play the MP4 file:

```shell
./sample_player.elf /data/test.mp4 101 # HDMI output
./sample_player.elf /data/test.mp4 20  # LCD output
```

During playback, press `Ctrl+C` to stop playback, the video will be displayed on the specified output device, and the audio will be played through the system audio output device.

The second argument is the VO connector type; run `list_connector` on the board to see all connector types supported by the current firmware.

```{admonition} Note
For specific interfaces of the mp4 module, please refer to [API documentation](../../api_reference/middleware/multimedia_middleware.md)
```
