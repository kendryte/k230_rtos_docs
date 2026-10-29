# Ogg Demo

## Introduction

This example demonstrates the real-time audio loopback processing flow based on Opus on K230, with Ogg encapsulation and decapsulation steps inserted in the middle. The program collects audio from AI, hands it to AENC for Opus encoding, then completes Ogg mux/demux in memory, and finally sends it to ADEC for decoding and plays it through AO.

- Ogg encapsulation: Pack Opus frames output by AENC into Ogg pages
- Ogg decapsulation: Extract Opus frames from Ogg pages
- Real-time loopback: AI -> AENC -> Ogg mux -> Ogg demux -> ADEC -> AO
- Exit method: The program runs continuously; press Ctrl+C to trigger signal handling and clean up resources

## Usage Instructions

### Code Location

Example directory: `/src/rtsmart/examples/mpp/sample_ogg`

The current example entry file is `main.cpp`, which generates the executable `sample_ogg.elf` after building.

### Key Parameters

| Parameter Name | Description | Value |
| :-- | :-- | :-- |
| `SAMPLE_RATE` | Audio sampling rate | 16000 Hz |
| `AUDIO_PERSEC_DIV_NUM` | Number of audio frames per second | 25 |
| `MAX_AUDIO_STREAM_SIZE` | Ogg/Opus intermediate buffer size | 1000 bytes |
| Encoding format | Payload type used by AENC/ADEC | Opus |
| Encoding channel count | Codec channel count | 1 |
| Sampling precision | I2S bit width | 16 bit |
| AI/AO device number | Used by the program by default | 0 |
| AI/AO/AENC/ADEC channel number | Used by the program by default | 0 |

### Running the Program

After startup, the program initializes VB, AI, AO, AENC, ADEC, Ogg muxer, and demuxer, then enters the loop to process real-time audio. Press Ctrl+C to exit.

```shell
./sample_ogg.elf
```

The example prints messages similar to the following at startup:

```text
Starting Ogg audio sample program. Press Ctrl+C to exit.
vb_set_config succeeded
Ogg stream muxer initialized successfully.
```

### Code Flow Description

1. Initialize VB resources
   - `audio_sample_vb_init()` calls `kd_mpi_vb_set_config()` and `kd_mpi_vb_init()` to initialize the VB system.
   - `audio_data_vb_create_pool()` creates a private VB pool for saving the intermediate audio stream used as ADEC input.
   - Use `kd_mpi_vb_get_block()`, `kd_mpi_vb_handle_to_phyaddr()`, and `kd_mpi_sys_mmap()` to establish mapping from physical address to user space.

1. Initialize Ogg components
   - `init_ogg_muxer()` configures `kd_ogg_muxer_params`, setting sampling rate to 16 kHz, mono channel, and streaming output.
   - `init_ogg_demuxer()` creates the Ogg demuxer, used to restore pages back to Opus frames.

1. Configure audio input, output, and codecs
   - In `audio_sample_ogg()`, both AI and AO are configured to I2S mode of the built-in codec.
   - Both AI/AO are set to 16 bit, 16 kHz, `AUDIO_PERSEC_DIV_NUM=25`.
   - Create AENC/ADEC channels with payload type `K_PT_OPUS`.

1. Establish MPP binding relationships
   - `kd_mpi_sys_bind()` binds the AI channel to AENC.
   - `kd_mpi_sys_bind()` binds the ADEC channel to AO.

1. Perform Ogg encapsulation and decapsulation in memory
   - The main loop obtains the Opus encoded stream through `kd_mpi_aenc_get_stream()`.
   - `do_opus_stream()` first calls `kd_ogg_write_frame_ex()` to encapsulate Opus frames into Ogg pages.
   - Then it calls `kd_ogg_demuxer_feed_page_ex()` to extract Opus frames from the pages.
   - The extracted Opus data is copied to the pre-allocated `g_audio_stream` buffer, and then sent to the decoder through `kd_mpi_adec_send_stream()`.
   - After processing, `kd_mpi_aenc_release_stream()` is called to release the encoded stream.

1. Signal exit and resource cleanup
   - `main()` registers `SIGINT` and `SIGTERM`; upon receiving a signal, it sets `g_running` to `false`.
   - After the loop exits, the program unbinds AI/AENC and ADEC/AO, and closes AI, AO, AENC, ADEC.
   - `cleanup_resources()` destroys the Ogg muxer and demuxer, releases VB blocks, destroys the VB pool, and calls `kd_mpi_vb_exit()`.

### Notes

- This example does not read or write `.ogg` files; Ogg encapsulation and decapsulation are all completed in memory.
- The example fixedly uses device number 0 and channel number 0; adjustments to the code are required when porting to other audio chains.
- If audio device initialization fails, the program will directly print the error and execute the cleanup flow.

```{admonition} Tip
For interfaces related to Ogg processing and audio codecs, please read together with `sample_ogg/main.cpp` and the corresponding audio API documentation.
```
