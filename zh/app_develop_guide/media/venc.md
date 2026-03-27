# venc demo

## Venc_demo简介

Venc demo主要是视频编码模块的例子，有4种不同的模式选择：

* 0：对摄像头输入的数据进行H265编码
* 1：对摄像头输入的数据进行JPEG编码
* 2：对摄像头输入的数据进行H264编码，并且叠加OSD
* 3：对摄像头输入的数据进行H265编码，并且叠加OSD，同时在OSD边缘画框

编码后的结果可以保存为文件，并导出到本地使用视频播放软件进行查看。

## 依赖资源

摄像头

## 使用说明

### mpp_demo执行

执行`./sample_venc.elf -h`后，输出demo的使用说明，如下：

```shell
Usage : ./sample_venc.elf [index] -o [filename]
index:
    0) H.265e.
    1) JPEG encode.
    2) OSD + H.264e.
    3) OSD + Border + H.265e.

sensor_index: see vicap doc
```

* index：0-3，选择模式
* filename：输出文件保存的名称

举例：

```shell
./sample_venc.elf 3 -o out.265
```

### 查看结果

输出文件可以导出到本地，用视频播放软件查看。

下图是运行上面例子中的命令，保存视频之后，从视频中截图的一帧图像，可以看到左上角叠加了一层OSD图标

![video_venc](https://www.kendryte.com/api/post/attachment?id=570)
