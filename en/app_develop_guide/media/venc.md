# venc demo

## Venc_demo Introduction

Venc demo is mainly an example of video encoding module, with 4 different mode options:

* 0: H265 encoding of camera input data
* 1: JPEG encoding of camera input data
* 2: H264 encoding of camera input data, with OSD overlay
* 3: H265 encoding of camera input data, with OSD overlay, and drawing a border around the OSD edge

The encoded result can be saved as a file and exported to local for viewing with video player software.

## Dependent Resources

Camera

## Usage Instructions

### mpp_demo Execution

After executing `./sample_venc.elf -h`, the usage instructions of the demo are output, as follows:

```shell
Usage : ./sample_venc.elf [index] -o [filename]
index:
    0) H.265e.
    1) JPEG encode.
    2) OSD + H.264e.
    3) OSD + Border + H.265e.

sensor_index: see vicap doc
```

* index: 0-3, select mode
* filename: the name of the output file to save

Example:

```shell
./sample_venc.elf 3 -o out.265
```

### View Results

The output file can be exported to local and viewed with video player software.

The following image is a frame captured from the video after running the command in the example above and saving the video, you can see an OSD icon overlaid in the upper left corner

![video_venc](https://www.kendryte.com/api/post/attachment?id=570)
