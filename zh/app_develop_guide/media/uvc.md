# RTOS UVC 介绍

我们在RTOS上对UVC设备进行了支持，现在默认仅支持MJPEG格式。

## API介绍

我们使用struct uvc_format 来描述需要获取图像的格式，使用struct uvc_frame来描述获取到的一帧UVC的图像。

```c
  struct uvc_format {
      unsigned int width;               /* 图像的宽 */
      unsigned int height;              /* 图像的高 */
      unsigned char format_type;        /* 图像格式，1代表MJPEG格式，0代表YUYV格式，现在默认仅支持MJPEG格式 */
      unsigned int frameinterval;       /* 图像帧率，单位是100ns，例如输入333333就是30fps（1000000000/(333333 * 100)) */
  };

  struct uvc_frame {
      unsigned int index;               /* 系统默认会开4个Buffer来存UVC的图像，这代表其中的第几个Buffer */
      unsigned int reserve_1;           /* 系统保留字段 */
      unsigned int reserve_2;           /* 系统保留字段 */
      unsigned int len;                 /* 表示获取到的UVC图像的大小 */
      char *userptr;                    /* 表示获取到的UVC图像的用户态地址，例如可以将其内容写入到文件 */
      union {
          k_video_frame_info v_info;    /* 当支持YUYV的时候，返回的k_video_frame_info结构，可以传给kd_mpi_vo_chn_insert_frame显示 */
          k_vdec_stream v_stream;       /* 当支持MJPEG的时候，返回的k_vdec_stream结构，可以传给kd_mpi_vdec_send_stream解码 */
      };
  };
```

我们对UVC代码进行了简单封装后，主要提供了以下接口给用户调用，下面一一介绍：

```c
/**
 * uvc_init - 对枚举成功后的UVC设备进行初始化。
 * @fmt：用于输入用户的指定的格式参数，struct uvc_format结构体如上所述。
 *
 * 用户输入的宽高代表着用户预期的分辨率，系统会将预期分辨率与该UVC设备支持的所有分辨率进行比较，
 * 最后找出的最接近的分辨率，然后通过fmt->width和fmt->height返回给用户，用户后续应当使用系统返回的分辨率。
 * 用户如果输入了设备不支持的帧率，系统会通过fmt->frameinterval返回该分辨率下默认的帧率给到用户。
 *
 * 此接口会分配一些内存以支持UVC图像的流转，默认内存是在VB里面分配的。
 *
 * @Return：成功返回0，失败返回负值。
 */
int uvc_init(struct uvc_format *fmt);

/**
 * uvc_start_stream - 开启摄像头。
 *
 * @Return：成功返回0，失败返回负值。
 */
int uvc_start_stream(void);

/**
 * uvc_get_frame - 获取一帧UVC图像，也就是拿到了一帧图像的Buffer。
 * @frame：用于返回一帧图像，struct uvc_frame结构体如上所述。
 * @timeout_ms：超时等待时间
 *
 * 该接口会阻塞等待直到一帧图像返回或者超时时间到。
 *
 * @Return：成功返回0，失败返回负值。
 */
int uvc_get_frame(struct uvc_frame *frame, unsigned int timeout_ms);

/**
 * uvc_put_frame - 释放一帧图像Buffer给系统使用
 *
 * @Return：成功返回0，失败返回负值。
 */
int uvc_put_frame(struct uvc_frame *frame);

/**
 * uvc_exit - 关闭摄像头，释放uvc_init申请的内存。
 */
void uvc_exit();

/**
 * uvc_get_devinfo - 用于获取设备的厂商和产品信息
 * @info：用来存储字符串信息的buffer
 * @len：buffer的长度
 *
 * @Return：成功返回0，失败返回负值。
 */
int uvc_get_devinfo(char *info, int len);

/**
 * uvc_get_formats - 获取设备支持的所有格式。
 * @fmts：用以返回所有格式的指针。
 *
 * uvc_get_formats内部实现会申请内存以存储所有格式，调用者仅提供二级指针即可。
 *
 * @Return：成功返回支持的格式数量，所有格式存在fmts中，失败返回负值。
 */
int uvc_get_formats(struct uvc_format **fmts);

/**
 * uvc_free_formats - 释放uvc_get_formats申请的空间。
 * @fmts：同uvc_get_formats。
 */
void uvc_free_formats(struct uvc_format **fmts);
```

## 示例介绍

### 对于UVC来说，它的主体使用框架应该如下：(假设UVC设备已经插入且枚举成功)

  1. 调用kd_mpi_vb_set_config(&config) 和 kd_mpi_vb_init() 进行VB的初始化，因为uvc_init分配的内存将来自VB。
  1. 调用uvc_init，进行uvc设备的初始化。
  1. 调用uvc_start_stream打开UVC摄像头。
  1. 循环调用uvc_get_frame和uvc_put_frame，不断获取UVC图像。
  1. 程序结束，调用uvc_exit()，关闭UVC设备。

```c
/* 示意性代码如下 */

int i = 1;
struct uvc_frame frame;

kd_mpi_vb_set_config(&config);
kd_mpi_vb_init();

uvc_init(w, h , 1);
uvc_start_stream();

do {

    uvc_get_frame(&frame, 3000);

    /* Write frame to SDcard */
    FILE *file = fopen("sdcard/app/userapps/test.jpg", "wb");
    size_t written = fwrite((char *)frame.userptr, sizeof(char), frame.len, file);
    fclose(file);

    uvc_put_frame(&frame);
} while (--i);

uvc_exit();

```

### 一个稍微复杂一些的的示例代码放在`src/rtsmart/mpp/userapps/sample/sample_uvc/uvc_test.c`

```c

不带任何参数，直接运行sample_uvc，默认会给出如下提示：
Usage: ./sample_uvc [connector_type] [rotation] [is_jpeg] [width] [height] [total_frame]

connector_type：表示接入的panel类型（下面会讲如何获取该值）
rotation：表示图像是否要翻转（HDMI不支持旋转）
is_jpeg：表示是用MJPEG还是YUYV格式，默认仅支持MJPEG格式，1代表MJPEG，0代表YUYV
width：表示图像宽度
height：表示图像高度
total_frame：表示需要显示多少帧


例如该例程在01studio的板子上运行:
1. 接入了一个ST7701_V1_MIPI_2LAN_480X800_30FPS（枚举值为20）的屏幕，再接入了一个支持640 * 480分辨率（MJPEG）的UVC摄像头，
   那么我们可以这样运行程序：sdcard/app/userapps/sample_uvc.elf 20 1 1 640 480 1000000

2. 接入了HDMI线并连接到一个可支持1080p的显示器（枚举值为101）上，再接入一个支持 1920 * 1280分辨率（MJPEG）的UVC摄像头，
   那么我们可以这样运行程序：sdcard/app/userapps/sample_uvc.elf 101 0 1 1920 1080 1000000

如果程序运行正常，就会看到屏幕/显示器有图像显示。

TIPS: 我们有两个方式可以获取到对应connector_type的枚举值:
a. 通过查找文档，阅读源码
b. 通过以下命令：

msh />list_connector
Connector Type List:
                0 -> HX8377_V2_MIPI_4LAN_1080X1920_30FPS
                1 -> ILI9806_MIPI_2LAN_480X800_30FPS
                2 -> ILI9881_MIPI_4LAN_800X1280_60FPS
               20 -> ST7701_V1_MIPI_2LAN_480X800_30FPS
               21 -> ST7701_V1_MIPI_2LAN_480X854_30FPS
               22 -> ST7701_V1_MIPI_2LAN_480X640_30FPS
               23 -> ST7701_V1_MIPI_2LAN_368X544_60FPS
              100 -> LT9611_MIPI_ADAPT_RESOLUTION
              101 -> LT9611_MIPI_4LAN_1920X1080_30FPS
              102 -> LT9611_MIPI_4LAN_1920X1080_60FPS
              103 -> LT9611_MIPI_4LAN_1920X1080_50FPS
              104 -> LT9611_MIPI_4LAN_1920X1080_25FPS
              105 -> LT9611_MIPI_4LAN_1920X1080_24FPS
              110 -> LT9611_MIPI_4LAN_1280X720_60FPS
              111 -> LT9611_MIPI_4LAN_1280X720_50FPS
              112 -> LT9611_MIPI_4LAN_1280X720_30FPS
              120 -> LT9611_MIPI_4LAN_640X480_60FPS
              200 -> VIRTUAL_DISPLAY_DEVICE
               -1 -> UNKNOWN
```

## 配置选项

### make menuconfig

![make menuconfig](https://developer.canaan-creative.com/api/post/attachment?id=563)

### make rtsmart-menuconfig

![make rtsmart-menuconfig](https://developer.canaan-creative.com/api/post/attachment?id=564)

## 注意事项

不建议接入Hub后，接入UVC设备和其他使用Bulk传输的设备一起用，可能会有带宽不够的问题。如果一定要这么用，请先接入UVC设备使用起来后再接入其他设备，但不确保一定不会遇到带宽不足的问题。
