# video demo

## Venc_demo

### Venc_demo简介

Venc demo主要是视频编码模块的例子，有4种不同的模式选择：

* 0：对摄像头输入的数据进行H265编码
* 1：对摄像头输入的数据进行JPEG编码
* 2：对摄像头输入的数据进行H264编码，并且叠加OSD
* 3：对摄像头输入的数据进行H265编码，并且叠加OSD，同时在OSD边缘画框

编码后的结果可以保存为文件，并导出到本地使用视频播放软件进行查看。

### Feature说明

只支持1280x720分辨率。

### 依赖资源

摄像头

### 使用说明

#### mpp_demo执行

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

#### 查看结果

输出文件可以导出到本地，用视频播放软件查看。

下图是运行上面例子中的命令，保存视频之后，从视频中截图的一帧图像，可以看到左上角叠加了一层OSD图标

![video_venc](https://developer.canaan-creative.com/api/post/attachment?id=570)

## Vdec_demo

### Vdec_demo简介

Vdec demo实现视频解码的功能。解码功能支持H.264/H.265/JPEG解码。支持的输入数据格式为.264/.265/.jpeg。

### Feature说明

Vdec demo通过读取流文件进行解码。解码输出结果通过屏幕显示。

### 依赖资源

无。

### 使用说明

#### 执行

执行`./sample_vdec.elf -help`，可以看到可配置参数及说明，其默认值如下表所示：

| 参数名 | 说明                                                                                | 默认值 |
| ------ | ----------------------------------------------------------------------------------- | ------ |
| i      | 输入文件名，需要后缀名分别为.264/.265/.jpg                                          | -      |
| type   | vo connector type, 参看k_connector_type的定义（01Studio开发板配套800x400的屏选择2） | 0      |

举例：

`./sample_vdec.elf -type2 -i out.h265`

#### 查看结果

解码结果可以在屏幕上查看。
