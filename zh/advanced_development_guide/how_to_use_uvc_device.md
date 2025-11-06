# K230 UVC Device 使用指南

## UVC Device 功能说明

K230 支持将开发板模拟成一个 UVC 设备，此时若将 K230 开发板接入电脑，电脑会识别到一个 UVC 摄像头。

## UVC Device 配置说明

使用 UVC Device 需要做如下配置

```bash
make rtsmart-menuconfig

# 1 找到对应的配置项
 > Components Configuration > Enable CherryUSB > Enable CherryUSB Device
        -> USB Device Function # 选择 UVC

# 2 当选择 UVC 功能之后，Enable UVC会被默认配置上，我们该配置项下，配置宽高和帧率
> Components Configuration > Enable CherryUSB > Enable CherryUSB Device > Enable CherryUSB Device Class Driver
        -> Enable UVC
```

![UVC FUNC](https://www.kendryte.com/api/post/attachment?id=777)

![UVC CONFIG](https://www.kendryte.com/api/post/attachment?id=776)

## UVC Device 示例

我们准备了两个示例程序。

```bash
src/rtsmart/mpp/userapps/sample/sample_uvc_dev_picture # 这个示例的数据源是一张静态的JPEG图片
src/rtsmart/mpp/userapps/sample/sample_uvc_dev_vicap   # 这个示例的数据源是板端的COMS摄像头，使用前请接入摄像头

如果需要使用上述两个示例程序，需要打开如下配置：

make menuconfig
 > MPP Configuration > Enable build MPP samples > Enable userapps samples
        -> UVC Device Sample # 选中该配置
```

![UVC SAMPLE](https://www.kendryte.com/api/post/attachment?id=778)

做完上述配置后，就可以在板端运行示例程序了

```bash
msh />/sdcard/app/userapps/sample_uvc_dev_picture.elf
或者
msh />/sdcard/app/userapps/sample_uvc_dev_vicap.elf
```

## 故障排除

1. 先查看是否有 /dev/video 这个文件，如果不存在，则是修改的配置并没有编译到固件里面去。
1. 若运行示例程序`sample_uvc_dev_vicap.elf`，需要确保板端接上了 COMS 摄像头。
