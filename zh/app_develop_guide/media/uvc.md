# RTOS UVC 介绍

我们在RTOS上对UVC设备进行了支持，现在默认仅支持MJPEG格式。

## API介绍

我们用struct uvc_frame来描述一帧UVC的图像，下面我们介绍该结构体。

```c
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

我们对UVC代码进行了简单封装后，提供了四个接口给用户调用，下面一一介绍：

```c
/**
 * uvc_init - 对枚举成功后的UVC设备进行初始化，开启摄像头。
 * @width：用于输入用户预期的宽，初始化完成后会返回实际的宽。
 * @height：用于输入用户预期的高，初始化完成后会返回实际的高。
 * @is_jpeg：用于选择是MJPEG格式还是YUYV格式，现在默认仅支持MJPEG格式。
 *
 * 用户输入的宽高代表着用户预期的分辨率，系统会将预期分辨率与该UVC设备支持的所有分辨率进行比较，
 * 最后找出的最接近的分辨率，然后通过width和height返回给用户，用户后续应当使用系统返回的分辨率。
 *
 * 此接口会分配一些内存以支持UVC图像的流转，默认内存是在VB里面分配的。
 *
 * @Return：成功返回0，失败返回负值。
 */
int uvc_init(int *width, int *height, unsigned char is_jpeg);

/**
 * uvc_get_frame - 获取一帧UVC图像，也就是拿到了一帧图像的Buffer。
 * @frame：用于返回一帧图像，帧结构体如上所述。
 *
 * 该接口会阻塞等待一帧图像返回，系统实现是无限期等待。
 *
 * @Return：成功返回0.失败返回负值。
 */
int uvc_get_frame(struct uvc_frame *frame);

/**
 * uvc_put_frame - 释放一帧图像Buffer给系统使用
 *
 * @Return：成功返回0.失败返回负值。
 */
int uvc_put_frame(struct uvc_frame *frame);

/**
 * uvc_exit - 关闭摄像头，释放uvc_init申请的内存。
 */
void uvc_exit();
```

## 示例介绍

### 对于UVC来说，它的主体使用框架应该如下：(假设UVC设备已经插入且枚举成功)

  1. 调用kd_mpi_vb_set_config(&config) 和 kd_mpi_vb_init() 进行VB的初始化，因为uvc_init分配的内存将来自VB。
  1. 调用uvc_init，进行uvc设备的初始化，打开UVC摄像头。
  1. 循环调用uvc_get_frame和uvc_put_frame，不断获取UVC图像。
  1. 程序结束，调用uvc_exit()，关闭UVC设备。

```c
/* 示意性代码如下 */

int i = 1;
struct uvc_frame frame;

kd_mpi_vb_set_config(&config);
kd_mpi_vb_init();

uvc_init(w, h , 1);

do {

    uvc_get_frame(&frame);

    /* Write Frame to SDCARD */
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

connector_type：表示接入的pannel类型
rotation：表示图像是否要翻转
is_jpeg：表示是用MJPEG还是YUYV格式，默认仅支持MJPEG格式
width：表示图像宽度
height：表示图像高度
total_frame：表示需要显示多少帧


例如该例程在01studio的板子上运行，接入了一个ST7701_V1_MIPI_2LAN_480X800_30FPS（枚举值为2）的屏幕，接入了一个支持640 * 480分辨率的UVC摄像头。
那么我们可以这样运行程序：sdcard/app/userapps/sample_uvc.elf 2 1 1 640 480 100000

如果程序运行正常，就会看到屏幕有图像显示。

```

## 配置选项

### make menuconfig

![make menuconfig](https://developer.canaan-creative.com/api/post/attachment?id=563)

### make rtsmart-menuconfig

![make rtsmart-menuconfig](https://developer.canaan-creative.com/api/post/attachment?id=564)

## 注意事项

不建议接入Hub后，接入UVC设备和其他使用Bulk传输的设备一起用，可能会有带宽不够的问题。如果一定要这么用，请先接入UVC设备使用起来后再接入其他设备，但不确保一定不会遇到带宽不足的问题。
