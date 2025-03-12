# 如何新增一个摄像头驱动

## 简介

本文档主要描述K230平台Camera Sensor框架以及如何新增支持一款新的Camera Sensor。

## 功能说明

本文档主要描述K230平台Camera Sensor基本框架以及如何新增支持一款新的Camera Sensor。

K230平台支持多种接口类型的sensor，我们以当前最常用的MIPI CSI接口Sensor为例进行说明。Sensor与主控平台的硬件连接示意图如下：

![camera sensor连接示意图](https://kendryte-download.canaan-creative.com/developer/pictures/e20100e34c268ad615e69966cb28e5a6.png)

主控通过I2C接口下发配置寄存器控制sensor的工作方式，sensor通过MIPI CSI接口将图像数据发送至主控SOC。

## 框架简介

Camera Sensor框架如图2-1所示，最底层是sensor驱动层

![camera sensor框架](https://kendryte-download.canaan-creative.com/developer/pictures/camera_sensor_arch.png)

图2-1 camera sensor框架

从上到下依次是：媒体接口层，驱动层以及硬件层

- 媒体接口层：该层对上提供kd_mpi_sensor_xxx接口给外部模块操作和访问sensor设备，对下通过ioctl操作具体的sensor设备
- 驱动层：该层包括sensor公共操作接口具体的sensor设备驱动。公共操作接口主要是ioctl操作命令和sensor i2c读写接口，sensor驱动主要提供设备节点以及操作接口的实现。这部分也是sensor适配的主要工作。
- 硬件层：对应各个具体的sensor硬件

## sesnor 适配准备工作

用户在适配新的sensor之前需要做以下一些准备工作：

1. 从正规渠道获取 Sensor datasheet、初始化序列。
1. 查看 Sensor datasheet 和相关应用手册，特别关注 Sensor 曝光、增益控制方法，不同模式下曝光和增益的限制，长曝光实现方法，黑电平值，bayer 数据输出顺序等。
1. 跟 Sensor 厂家索要所需模式初始化序列，了解各序列的数据数率，Sensor 输出总的宽高，精确的帧率是多少等。
1. 确认 Sensor 控制接口是 I2C、SPI 还是其他接口，Sensor 的设备地址可以通过硬件设置。对于多个摄像头的场景，sensor 尽量不要复用 I2C 总线。不同场景的Sensor IO 电平可能是 1.8V 或者 3.3V，设计时需要保证 sensor 的 IO 电平与SOC 对应的 GPIO 供电电压一致。如 sensor 电平是 1.8V，则用于 sensor 控制的GPIO，如 Reset，I2C，PRDN，需要使用 1.8V 供电。
1. 确认 Sensor 输出数据接口和协议类型。当前仅支持MIPI CSI接口。
1. 确认 wdr mode 是 VC、DT 或者 DOL 等。
1. 确认不同时序是否需要图像裁剪。

## Sensor适配示例

本节将按照如何增加支持一个新的camera sensor的步骤来进行详细描述。

这里以ov5647驱动作为示例进行说明，对应的驱动文件源码路径如下：

```shell
canmv_k230/src/rtsmart/mpp/kernel/sensor/src/ov5647/ov5647.c
```

### 定义支持的sensor类型

系统支持的Sensor类型是由如下枚举变量定义：

```c
typedef enum {

#if defined (CONFIG_MPP_ENABLE_SENSOR_IMX335)
    IMX335_MIPI_CSI0_2LANE_1920X1080_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI0_2LANE_2592X1944_30FPS_12BIT_LINEAR,
#if defined (CONFIG_MPP_SENSOR_IMX335_ENABLE_4LANE_CONFIGURE)
        IMX335_MIPI_CSI0_4LANE_2592X1944_30FPS_12BIT_LINEAR,
#endif // CONFIG_MPP_SENSOR_IMX335_ENABLE_4LANE_CONFIGURE

    IMX335_MIPI_CSI1_2LANE_1920X1080_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI1_2LANE_2592X1944_30FPS_12BIT_LINEAR,
#if defined (CONFIG_MPP_SENSOR_IMX335_ENABLE_4LANE_CONFIGURE)
        IMX335_MIPI_CSI1_4LANE_2592X1944_30FPS_12BIT_LINEAR,
#endif // CONFIG_MPP_SENSOR_IMX335_ENABLE_4LANE_CONFIGURE

    IMX335_MIPI_CSI2_2LANE_1920X1080_30FPS_12BIT_LINEAR,
    IMX335_MIPI_CSI2_2LANE_2592X1944_30FPS_12BIT_LINEAR,
#if defined (CONFIG_MPP_SENSOR_IMX335_ENABLE_4LANE_CONFIGURE)
        IMX335_MIPI_CSI2_4LANE_2592X1944_30FPS_12BIT_LINEAR,
#endif // CONFIG_MPP_SENSOR_IMX335_ENABLE_4LANE_CONFIGURE

#endif // CONFIG_MPP_ENABLE_SENSOR_IMX335

#if defined (CONFIG_MPP_ENABLE_SENSOR_OV5647)
    OV5647_MIPI_CSI0_2592x1944_10FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI0_1920X1080_30FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI0_1280X960_45FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI0_1280X720_60FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI0_640x480_90FPS_10BIT_LINEAR,

    OV5647_MIPI_CSI1_2592x1944_10FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_1920X1080_30FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_1280X960_45FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_1280X720_60FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI1_640x480_90FPS_10BIT_LINEAR,

    OV5647_MIPI_CSI2_2592x1944_10FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_1920X1080_30FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_1280X960_45FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_1280X720_60FPS_10BIT_LINEAR,
    OV5647_MIPI_CSI2_640x480_90FPS_10BIT_LINEAR,
#endif // CONFIG_MPP_ENABLE_SENSOR_OV5647

#if defined (CONFIG_MPP_ENABLE_SENSOR_GC2093)
    GC2093_MIPI_CSI0_1920X1080_30FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI0_1920X1080_60FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI0_1280X960_90FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI0_1280X720_90FPS_10BIT_LINEAR,

    GC2093_MIPI_CSI1_1920X1080_30FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI1_1920X1080_60FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI1_1280X960_90FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI1_1280X720_90FPS_10BIT_LINEAR,

    GC2093_MIPI_CSI2_1920X1080_30FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI2_1920X1080_60FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI2_1280X960_90FPS_10BIT_LINEAR,
    GC2093_MIPI_CSI2_1280X720_90FPS_10BIT_LINEAR,
#endif // CONFIG_MPP_ENABLE_SENSOR_GC2093

#if defined (CONFIG_MPP_ENABLE_SENSOR_SC132GS)
    SC132GS_MIPI_CSI0_1080X1200_30FPS_10BIT_LINEAR,
    SC132GS_MIPI_CSI0_640X480_30FPS_10BIT_LINEAR,

    SC132GS_MIPI_CSI1_1080X1200_30FPS_10BIT_LINEAR,
    SC132GS_MIPI_CSI1_640X480_30FPS_10BIT_LINEAR,

    SC132GS_MIPI_CSI2_1080X1200_30FPS_10BIT_LINEAR,
    SC132GS_MIPI_CSI2_640X480_30FPS_10BIT_LINEAR,
#endif // CONFIG_MPP_ENABLE_SENSOR_SC132GS

#if defined (CONFIG_MPP_ENABLE_SENSOR_XS9950)
    XS9950_MIPI_CSI0_1280X720_30FPS_YUV422,
    XS9950_MIPI_CSI1_1280X720_30FPS_YUV422,
    XS9950_MIPI_CSI2_1280X720_30FPS_YUV422,
#endif // CONFIG_MPP_ENABLE_SENSOR_XS9950

    SENSOR_TYPE_MAX,
} k_vicap_sensor_type;
```

用户需要增加新的sensor支持类型时，首先需要在这里增加对应类型的定义，**该类型是应用程序获取sensor配置的唯一标志**

### sensor驱动适配

sensor驱动适配在整个环节中最重要的环节，用户可以通过拷贝现有的sensor驱动文件来修改，其中关于sensor的AE相关寄存器配置和计算方式需要查看对应的手册或者寻求专业人事协助。

#### 定义sensor寄存器配置列表

sensor寄存器配置由数据类型 k_sensor_reg_list 定义：

```c
typedef struct {
    k_u32 addr;
    k_u32 val;
} k_sensor_reg;
```

以下是ov5647的寄存器配置列表，代码定义如下：

```shell
canmv_k230/src/rtsmart/mpp/kernel/sensor/src/ov5647/sensor_reg_table.c
```

```c
static const k_sensor_reg ov5647_mipi2lane_1080p_30fps_linear[] = {
    //pixel_rate = 81666700
    {0x0103, 0x01},
    {0x0100, 0x00},
    {0x3034, 0x1a},
    {0x3035, 0x21},
    ...
    {0x3501, 0x02},
    {0x3502, 0xa0},
    {0x3503, 0x07},
    {0x350b, 0x10},
    {REG_NULL, 0x00},
};
```

#### 定义sensor支持的模式

sensor的模式参数由数据类型k_sensor_mode 定义

```c
typedef struct {
    k_u32 index;
    k_vicap_sensor_type sensor_type;
    k_sensor_size size;
    k_u32 fps;
    k_u32 hdr_mode;
    k_u32 stitching_mode;
    k_u32 bit_width;
    k_sensor_data_compress compress;
    k_u32 bayer_pattern;
    k_sensor_mipi_info mipi_info;
    k_sensor_ae_info ae_info;
    k_sensor_reg_list *reg_list;
} k_sensor_mode;
```

以下是ov5647的支持的模式，代码定义如下：

```shell
canmv_k230/src/rtsmart/mpp/kernel/sensor/src/ov5647/sensor_csi0_mode_list.c
```

```c
static k_sensor_mode sensor_csi0_mode_list[] = {
    {
        .index = 0,
        .sensor_type = OV_OV5647_MIPI_1920X1080_30FPS_10BIT_LINEAR,
        .size = {
            .bounds_width = 1920,
            .bounds_height = 1080,
            .top = 0,
            .left = 0,
            .width = 1920,
            .height = 1080,
        },
    ......
}
```

#### 实现sensor操作接口

sensor的操作接口由数据类型k_sensor_function定义，用户根据实际情况实现相关的操作接口，不是所有接口都必须实现。

```c
typedef struct {
    k_s32 (*sensor_power) (void *ctx, k_s32 on);
    k_s32 (*sensor_init) (void *ctx, k_sensor_mode mode);
    k_s32 (*sensor_get_chip_id)(void *ctx, k_u32 *chip_id);
    k_s32 (*sensor_get_mode)(void *ctx, k_sensor_mode *mode);
    k_s32 (*sensor_set_mode)(void *ctx, k_sensor_mode mode);
    k_s32 (*sensor_enum_mode)(void *ctx, k_sensor_enum_mode *enum_mode);
    k_s32 (*sensor_get_caps)(void *ctx, k_sensor_caps *caps);
    k_s32 (*sensor_conn_check)(void *ctx, k_s32 *conn);
    k_s32 (*sensor_set_stream)(void *ctx, k_s32 enable);
    k_s32 (*sensor_get_again)(void *ctx, k_sensor_gain *gain);
    k_s32 (*sensor_set_again)(void *ctx, k_sensor_gain gain);
    k_s32 (*sensor_get_dgain)(void *ctx, k_sensor_gain *gain);
    k_s32 (*sensor_set_dgain)(void *ctx, k_sensor_gain gain);
    k_s32 (*sensor_get_intg_time)(void *ctx, k_sensor_intg_time *time);
    k_s32 (*sensor_set_intg_time)(void *ctx, k_sensor_intg_time time);
    k_s32 (*sensor_get_exp_parm)(void *ctx, k_sensor_exposure_param *exp_parm);
    k_s32 (*sensor_set_exp_parm)(void *ctx, k_sensor_exposure_param exp_parm);
    k_s32 (*sensor_get_fps)(void *ctx, k_u32 *fps);
    k_s32 (*sensor_set_fps)(void *ctx, k_u32 fps);
    k_s32 (*sensor_get_isp_status)(void *ctx, k_sensor_isp_status *staus);
    k_s32 (*sensor_set_blc)(void *ctx, k_sensor_blc blc);
    k_s32 (*sensor_set_wb)(void *ctx, k_sensor_white_balance wb);
    k_s32 (*sensor_get_tpg)(void *ctx, k_sensor_test_pattern *tpg);
    k_s32 (*sensor_set_tpg)(void *ctx, k_sensor_test_pattern tpg);
    k_s32 (*sensor_get_expand_curve)(void *ctx, k_sensor_compand_curve *curve);
    k_s32 (*sensor_get_otp_data)(void *ctx, void *data);
} k_sensor_function;
```

建议根据现有的sensor驱动的基础上拷贝修改，大多数接口不需要改动。

#### 更新sensor驱动列表

将上一节定义的sensor驱动结构体添加到sensor_common.c中的sensor_drv_list数组中。
当前系统支持的sensor列表如下：

```c
static sensor_probe_impl sensor_probes[] = {
#ifdef CONFIG_MPP_ENABLE_SENSOR_GC2093
    sensor_gc2093_probe,
#endif // CONFIG_MPP_ENABLE_SENSOR_GC2093
#ifdef CONFIG_MPP_ENABLE_SENSOR_OV5647
    sensor_ov5647_probe,
#endif // CONFIG_MPP_ENABLE_SENSOR_OV5647
#if defined (CONFIG_MPP_ENABLE_SENSOR_IMX335)
    sensor_imx335_probe,
#endif // CONFIG_MPP_ENABLE_SENSOR_IMX335
#if defined (CONFIG_MPP_ENABLE_SENSOR_SC132GS)
    sensor_sc132gs_probe,
#endif // CONFIG_MPP_ENABLE_SENSOR_SC132GS
#if defined (CONFIG_MPP_ENABLE_SENSOR_XS9950)
    sensor_xs9950_probe,
#endif // CONFIG_MPP_ENABLE_SENSOR_XS9950
#if defined (CONFIG_MPP_ENABLE_SENSOR_BF3238)
    sensor_bf3238_probe,
#endif // CONFIG_MPP_ENABLE_SENSOR_BF3238

    0, // end
};
```

### 更新sensor配置信息列表

sensor配置信息有结构体k_vicap_sensor_info定义：

```shell
typedef struct {
    const char *sensor_name; /*sensor名字*/
    const char *calib_file; /*sensor标定文件名*/
    k_u16 width; /*sensor输出图像宽度*/
    k_u16 height; /*sensor输出图像高度*/
    k_vicap_csi_num csi_num; /*sensor硬件连接使用的CSI总线标号*/
    k_vicap_mipi_lanes mipi_lanes; /*sensor硬件连接使用的MIPI LANE个数*/
    k_vicap_data_source source_id; /*数据源ID*/
    k_bool is_3d_sensor; /*是否为3D sensor*/

    k_vicap_mipi_phy_freq phy_freq; /*MIPI PHY速率*/
    k_vicap_csi_data_type data_type; /*CSI数据类型*/
    k_vicap_hdr_mode hdr_mode; /*HDR模式*/
    k_vicap_vi_flash_mode flash_mode; /*flash模式选择*/
    k_vicap_vi_first_frame_sel first_frame;
    k_u16 glitch_filter;
    k_vicap_sensor_type sensor_type; /*sensor类型*/
} k_vicap_sensor_info;
```

在canmv_k230/src/rtsmart/mpp/userapps/src/sensor/mpi_sensor.c 中ov5647对应的配置信息：

```shell
const k_vicap_sensor_info sensor_info_list[] = {
    {
        "ov5647",
        1920,
        1080,
        VICAP_CSI2,
        VICAP_MIPI_2LANE,
        VICAP_SOURCE_CSI2,
        K_TRUE,
        VICAP_MIPI_PHY_800M,
        VICAP_CSI_DATA_TYPE_RAW10,
        VICAP_LINERA_MODE,
        VICAP_FLASH_DISABLE,
        VICAP_VI_FIRST_FRAME_FS_TR0,
        0,
        OV_OV5647_MIPI_1920X1080_30FPS_10BIT_LINEAR,
    },
```

用户每增加一个sensor配置模式，就需要在sensor_info_list这个结构体中增加一项对应模式的配置。

### 增加sensor配置文件

当前SDK版本sensor配置文件包括xml文件和json文件，文件存放路径如下：

```shell
canmv_k230/src/rtsmart/mpp/userapps/src/sensor/config
```

以下是ov5647对应的配置文件：

```shell
ov5647.xml  ov5647_auto.json  ov5647_manual.json
```

对于新增加的sensor，可以通过拷贝修改现有文件实现支持，其中的calibration和tuning参数可以通过相关工具修改导出。

### 修改Makefile和Kconfig

用户新增了一个sensor驱动后，需要可以在menuconfig中进行使能和配置

参考src/rtsmart/mpp/Kconfig中其他sensor的定义，新增一个新的sensor配置选项
同时也要修改src/rtsmart/mpp/kernel/sensor/Makefile，将新的sensor驱动添加到编译系统中
