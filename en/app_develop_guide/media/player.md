# Player Example

## Introduction

This example demonstrates how to use the K230's player module. The player module is a high-level wrapper that provides convenient audio and video playback functionality.

## Feature Description

### Player Features

This example demonstrates the usage of the player:

- **Video Playback**: Supports playing video files
- **Audio Playback**: Supports playing audio files
- **Audio-Video Synchronization**: Automatically synchronizes audio and video
- **Multiple Output Devices**: Supports output devices such as HDMI, LCD, etc.
- **Event Callbacks**: Supports playback event notifications

### Supported Formats

- **File Format**: MP4
- **Codecs**: H.264, H.265, G711, OPUS, etc.

### Main Interfaces

- `kd_player_init()` - Initialize the player
- `kd_player_deinit()` - Deinitialize the player
- `kd_player_start()` - Start playback
- `kd_player_stop()` - Stop playback
- `kd_player_pause()` - Pause playback
- `kd_player_resume()` - Resume playback
- `kd_player_register_event_cb()` - Register event callback

### Player Events

| Event | Description |
|------|------|
| K_PLAYER_EVENT_EOF | Playback ended |
| K_PLAYER_EVENT_ERROR | Playback error |

## Code Location

Demo source code location: `src/rtsmart/examples/mpp/sample_player`

## Usage Instructions

### Compilation Method

In the `K230 RTOS SDK` root directory, use `make menuconfig` to configure the compilation options, select to compile the player example into the firmware, and then compile the firmware.

### Running the Example

```shell
./sample_player.elf <file_path> <connect_type>
```

### Parameter Description

| Parameter Name | Description |
|--------|------|
| file_path | The path of the mp4 file to play |
| connect_type | VO connector type, run `list_connector` on the board to see the supported types |

### Viewing Results

After the program runs, it will:

1. Initialize the player
1. Open the media file
1. Parse audio and video streams
1. Start playing
1. Display playback progress information
1. Automatically exit after playback ends

Output example:

```text
./sample_player.elf ./test_800x480.mp4 20
file pathname:./test_800x480.mp4
connector type:20
video track info:type:96,track_id:1,width:800,height:480
input_pool_id 0
output_pool_id 1
VDEC: pool_id 1, frame_buf_pool_id 1
sample_vo_init>vo init width 800 height 480
sample_vo_init: layer_id 1, width 800, height 480, pixel_format 31, func 2,buf_nr:3
VDEC: first pts 5940, frame_interval 0
VDEC: first pts 5940, frame_interval 12060
kd_mp4_get_frame: demuxer has finished.
demuxer finished.
5941 pictures decoded. Average FrameRate = 99 Fps
vpu report fps 99
disp_play>ch 0, receive eos
vpu_exit>q_wm 16
```

```{admonition} Tip
The player module is based on K230's multimedia pipeline (MPP) and codec implementation, providing a simpler interface than directly using MPI. For the specific interfaces of the player module, please refer to the [Multimedia Middleware API Documentation](../../api_reference/middleware/multimedia_middleware.md).
```
