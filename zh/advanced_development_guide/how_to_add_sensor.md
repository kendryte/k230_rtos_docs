# 如何适配Sensor

## 概述

K230 Sensor 框架分为驱动层和应用层，底层为硬件层（如 ov9732、ov9286 等 Sensor），中间为驱动层（对应 /dev/sensor_xxx 设备节点），上层通过媒体接口层（kd_mpi_sensor_xxx）和 sensor_ops 实现对 Sensor 的操作。本文将以 IMX219 为例，详细介绍在 RTOS 操作系统中新增 Sensor 适配的完整流程，包括配置、驱动开发、应用层适配、编译运行及问题调试。

![1740391632750](https://www.kendryte.com/api/post/attachment?id=806)

## 开发步骤

### 整体配置

#### 增加 Sensor 开关配置

在`~/src/rtsmart/mpp/Kconfig`中添加 IMX219 的配置项，支持通过`make menuconfig`控制该摄像头驱动的启用 / 禁用，并针对不同 CSI 接口（CSI0/CSI1/CSI2）配置 MCLK 使用选项。

```cpp
menuconfig MPP_ENABLE_SENSOR_IMX219

   bool "Enable IMX219"

   if MPP_ENABLE_SENSOR_IMX219

       config MPP_SENSOR_IMX219_ON_CSI0_USE_CHIP_CLK

           bool "IMX219 On CSI0 Use CHIP MCLK"

           default n

           depends on MPP_ENABLE_CSI_DEV_0

       config MPP_SENSOR_IMX219_ON_CSI1_USE_CHIP_CLK

           bool "IMX219 On CSI1 Use CHIP MCLK"

           default n

           depends on MPP_ENABLE_CSI_DEV_1

       config MPP_SENSOR_IMX219_ON_CSI2_USE_CHIP_CLK

           bool "IMX219 On CSI2 Use CHIP MCLK"

           default n

           depends on MPP_ENABLE_CSI_DEV_2

   endif
```

### 驱动层开发

#### Makefile 编译配置

在`~/src/rtsmart/mpp/kernel/sensor/Makefile`中添加 IMX219 的编译规则，确保启用配置后自动编译对应驱动文件。

```shell
src-$(CONFIG_MPP_ENABLE_SENSOR_IMX219) += src/imx219/imx219.c
```

#### Sensor 模式定义

在`~/src/rtsmart/mpp/include/comm/k_sensor_comm.h`中，新增 IMX219 支持的分辨率、帧率、CSI 接口组合模式，共 3 种分辨率 ×3 个 CSI 接口 = 9 个宏定义。

```cpp
typedef enum {

...

#if defined (CONFIG_MPP_ENABLE_SENSOR_IMX219)

   IMX219_MIPI_CSI0_2LANE_3280x2464_21FPS_12BIT_LINEAR,

   IMX219_MIPI_CSI0_2LANE_1920x1080_30FPS_12BIT_LINEAR,

   IMX219_MIPI_CSI0_2LANE_1080x1920_30FPS_12BIT_LINEAR,

   IMX219_MIPI_CSI1_2LANE_3280x2464_21FPS_12BIT_LINEAR,

   IMX219_MIPI_CSI1_2LANE_1920x1080_30FPS_12BIT_LINEAR,

   IMX219_MIPI_CSI1_2LANE_1080x1920_30FPS_12BIT_LINEAR,

   IMX219_MIPI_CSI2_2LANE_3280x2464_21FPS_12BIT_LINEAR,

   IMX219_MIPI_CSI2_2LANE_1920x1080_30FPS_12BIT_LINEAR,

   IMX219_MIPI_CSI2_2LANE_1080x1920_30FPS_12BIT_LINEAR,

#endif

   SENSOR_TYPE_MAX,

} k_vicap_sensor_type;
```

#### 开机扫描检测配置

在驱动初始化扫描逻辑中添加 IMX219 的检测支持，包括探针函数注册和类型名称映射。

##### 探针函数注册

修改`~/src/rtsmart/mpp/kernel/sensor/src/sensor_dev.c`，在`sensor_probes`数组中添加 IMX219 的探针函数，在`sth_table`中添加模式名称映射。

```cpp
static sensor_probe_impl sensor_probes[] = {

...

#if defined (CONFIG_MPP_ENABLE_SENSOR_IMX219)

   sensor_imx219_probe,

#endif // CONFIG_MPP_ENABLE_SENSOR_BF3238

   0, // end

};

static const struct sensor_type_name sth_table[] = {

...

#if defined (CONFIG_MPP_ENABLE_SENSOR_IMX219)

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI0_2LANE_3280x2464_21FPS_12BIT_LINEAR),

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI0_2LANE_1920x1080_30FPS_12BIT_LINEAR),

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI0_2LANE_1080x1920_30FPS_12BIT_LINEAR),

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI1_2LANE_3280x2464_21FPS_12BIT_LINEAR),

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI1_2LANE_1920x1080_30FPS_12BIT_LINEAR),

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI1_2LANE_1080x1920_30FPS_12BIT_LINEAR),

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI2_2LANE_3280x2464_21FPS_12BIT_LINEAR),

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI2_2LANE_1920x1080_30FPS_12BIT_LINEAR),

   SENSOR_TYPE_NAME(IMX219_MIPI_CSI2_2LANE_1080x1920_30FPS_12BIT_LINEAR),

#endif

   /* last type set to U32 MAX */

   {__UINT32_MAX__, "UNKNOWN"},

};
```

##### 探针函数声明

在`~/src/rtsmart/mpp/kernel/sensor/src/sensor_dev.h`中声明 IMX219 的探针函数。

```cpp
extern k_s32 sensor_imx219_probe(struct k_sensor_probe_cfg *cfg, struct sensor_driver_dev *dev);
```

#### 驱动文件目录创建

拷贝现有类似 Sensor（如 gc2093）的驱动目录，修改为 IMX219 专属目录及文件名称。

```cpp
cp -rf gc2093 imx219

cd imx219

mv gc2093.c imx219.c

# 新增目录结构如下

aaa@DESKTOP-OSN5BJK:~/canmv_k230_mmp/src/rtsmart/mpp/kernel/sensor/src/imx219$ ls

imx219.c  sensor_csi0_mode_list.c  sensor_csi1_mode_list.c  sensor_csi2_mode_list.c  sensor_reg_table.c
```

#### 寄存器配置

针对 3 种分辨率模式，添加对应的寄存器初始化序列（需从摄像头模组厂获取），序列以`{REG_NULL, 0x00}`结束。

```cpp
/* MCLK:24MHz  3280x2464  21.2fps   MIPI LANE2 */

static const k_sensor_reg imx219_mipi2lane_3280_2464_21fps[] = {

   {0x30EB, 0x05},     /* Access Code for address over 0x3000 */

   {0x30EB, 0x0C},     /* Access Code for address over 0x3000 */

   {0x300A, 0xFF},     /* Access Code for address over 0x3000 */

   {0x300B, 0xFF},     /* Access Code for address over 0x3000 */

   {0x30EB, 0x05},     /* Access Code for address over 0x3000 */

   {0x30EB, 0x09},     /* Access Code for address over 0x3000 */

   {0x0114, 0x01},     /* CSI_LANE_MODE[1:0} */

   {0x0128, 0x00},     /* DPHY_CNTRL */

   {0x012A, 0x18},     /* EXCK_FREQ[15:8] */

   {0x012B, 0x00},     /* EXCK_FREQ[7:0] */

   {0x015A, 0x01},     /* INTEG TIME[15:8] */

   {0x015B, 0xF4},     /* INTEG TIME[7:0] */

   {0x0160, 0x09},     /* FRM_LENGTH_A[15:8] */

   {0x0161, 0xC4},     /* FRM_LENGTH_A[7:0] */

   {0x0162, 0x0D},     /* LINE_LENGTH_A[15:8] */

   {0x0163, 0x78},     /* LINE_LENGTH_A[7:0] */

   {0x0260, 0x09},     /* FRM_LENGTH_B[15:8] */

   {0x0261, 0xC4},     /* FRM_LENGTH_B[7:0] */

   {0x0262, 0x0D},     /* LINE_LENGTH_B[15:8] */

   {0x0263, 0x78},     /* LINE_LENGTH_B[7:0] */

   {0x0170, 0x01},     /* X_ODD_INC_A[2:0] */

   {0x0171, 0x01},     /* Y_ODD_INC_A[2:0] */

   {0x0270, 0x01},     /* X_ODD_INC_B[2:0] */

   {0x0271, 0x01},     /* Y_ODD_INC_B[2:0] */

   {0x0174, 0x00},     /* BINNING_MODE_H_A */

   {0x0175, 0x00},     /* BINNING_MODE_V_A */

   {0x0274, 0x00},     /* BINNING_MODE_H_B */

   {0x0275, 0x00},     /* BINNING_MODE_V_B */

   {0x018C, 0x0A},     /* CSI_DATA_FORMAT_A[15:8] */

   {0x018D, 0x0A},     /* CSI_DATA_FORMAT_A[7:0] */

   {0x028C, 0x0A},     /* CSI_DATA_FORMAT_B[15:8] */

   {0x028D, 0x0A},     /* CSI_DATA_FORMAT_B[7:0] */

   {0x0301, 0x05},     /* VTPXCK_DIV */

   {0x0303, 0x01},     /* VTSYCK_DIV */

   {0x0304, 0x03},     /* PREPLLCK_VT_DIV[3:0] */

   {0x0305, 0x03},     /* PREPLLCK_OP_DIV[3:0] */

   {0x0306, 0x00},     /* PLL_VT_MPY[10:8] */

   {0x0307, 0x39},     /* PLL_VT_MPY[7:0] */

   {0x0309, 0x0A},     /* OPPXCK_DIV[4:0] */

   {0x030B, 0x01},     /* OPSYCK_DIV */

   {0x030C, 0x00},     /* PLL_OP_MPY[10:8] */

   {0x030D, 0x72},     /* PLL_OP_MPY[7:0] */

   {0x455E, 0x00},     /* CIS Tuning */

   {0x471E, 0x4B},     /* CIS Tuning */

   {0x4767, 0x0F},     /* CIS Tuning */

   {0x4750, 0x14},     /* CIS Tuning */

   {0x47B4, 0x14},     /* CIS Tuning */

   {REG_NULL, 0x00},

};

/* MCLK:24MHz  1920x1080  30fps   MIPI LANE2 */

static const k_sensor_reg imx219_mipi2lane_1920_1080_30fps[] = {

   {0x30eb, 0x05},

   {0x30eb, 0x0c},

   {0x300a, 0xff},

   {0x300b, 0xff},

   {0x30eb, 0x05},

   {0x30eb, 0x09},

   {0x0114, 0x01}, //REG_CSI_LANE 01 -2lanes 03-4lanes

   {0x0128, 0x00}, //REG_DPHY_CTRL

   {0x012a, 0x18}, //REG_EXCK_FREQ_MSB

   {0x012b, 0x00}, //REG_EXCK_FREQ_LSB

   {0x0160, 0x04},//FRM_LENGTH_A[15:8] 1166

   {0x0161, 0x8e},//FRM_LENGTH_A[7:0] 1166    

   {0x0162, 0x0d},//0x0d},//LINE_LENGTH_A[15:8] 3448

   {0x0163, 0x94},//0x78},//LINE_LENGTH_A[7:0]

   {0x0164, 0x02}, //X_ADD_STA_A[11:8]

   {0x0165, 0xa8},//X_ADD_STA_A[7:0]

   {0x0166, 0x0a}, //X_ADD_END_A[11:8]

   {0x0167, 0x27}, //X_ADD_END_A[7:0]

   {0x0168, 0x02},//Y_ADD_STA_A[11:8]

   {0x0169, 0xb4},//Y_ADD_STA_A[7:0]

   {0x016a, 0x06},//Y_ADD_END_A[11:8]

   {0x016b, 0xeb},//Y_ADD_END_A[7:0]

   {0x016c, 0x07},//x_output_size[11:8]

   {0x016d, 0x80},//x_output_size[7:0]

   {0x016e, 0x04},//y_output_size[11:8]

   {0x016f, 0x38},// y_output_size[7:0]

   {0x0170, 0x01},//X_ODD_INC_A

   {0x0171, 0x01},//Y_ODD_INC_A

   {0x0174, 0x00},//BINNING_MODE_H_A

   {0x0175, 0x00},//BINNING_MODE_V_A

   {0x0301, 0x05},//VTPXCK_DIV

   {0x0303, 0x01},//VTSYCK_DIV

   {0x0304, 0x03},//PREPLLCK_VT_DIV

   {0x0305, 0x03},//PREPLLCK_OP_DIV

   {0x0306, 0x00},//PLL_VT_MPY[10:8]

   {0x0307, 0x26},//0x25},//PLL_VT_MPY[7:0] 0x39

   {0x030b, 0x01},//OPSYCK_DIV

   {0x030c, 0x00},//PLL_OP_MPY[10:8]

   {0x030d, 0x30},//PLL_OP_MPY[7:0] 0x72

   {0x0624, 0x07},

   {0x0625, 0x80},

   {0x0626, 0x04},

   {0x0627, 0x38},

   {0x455e, 0x00},

   {0x471e, 0x4b},

   {0x4767, 0x0f},

   {0x4750, 0x14},

   {0x4540, 0x00},

   {0x47b4, 0x14},

   {0x4713, 0x30},

   {0x478b, 0x10},

   {0x478f, 0x10},

   {0x4793, 0x10},

   {0x4797, 0x0e},

   {0x479b, 0x0e},

   {0x0157, 0x40},

   {REG_NULL, 0x00},

};

/* MCLK:24MHz  1080x1920  30fps   MIPI LANE2 */

static const k_sensor_reg imx219_mipi2lane_1080_1920_30fps[] = {

   //Access command sequence

   {0x30eb, 0x05},

   {0x30eb, 0x0c},

   {0x300a, 0xff},

   {0x300b, 0xff},

   {0x30eb, 0x05},

   {0x30eb, 0x09},

   {0x0114, 0x01}, //REG_CSI_LANE 01 -2lanes 03-4lanes

   {0x0128, 0x00}, //REG_DPHY_CTRL

   {0x012a, 0x18}, //REG_EXCK_FREQ_MSB

   {0x012b, 0x00}, //REG_EXCK_FREQ_LSB

   {0x0160, 0x08},//FRM_LENGTH_A[15:8] 1166

   {0x0161, 0x98},//FRM_LENGTH_A[7:0] 1166    

   {0x0162, 0x0d},//0x0d},//LINE_LENGTH_A[15:8] 3476

   {0x0163, 0x94},//0x78},//LINE_LENGTH_A[7:0]

   {0x0164, 0x02}, //X_ADD_STA_A[11:8]    680 + 1080 - 1                      3476 * 2200

   {0x0165, 0xb4},//X_ADD_STA_A[7:0]

   {0x0166, 0x06}, //X_ADD_END_A[11:8]  1771

   {0x0167, 0xeb}, //X_ADD_END_A[7:0]

   {0x0168, 0x01},//Y_ADD_STA_A[11:8]

   {0x0169, 0x00},//Y_ADD_STA_A[7:0]

   {0x016a, 0x08},//Y_ADD_END_A[11:8]          2175   

   {0x016b, 0x7f},//Y_ADD_END_A[7:0]

   {0x016c, 0x04},//x_output_size[11:8]

   {0x016d, 0x38},//x_output_size[7:0]

   {0x016e, 0x07},//y_output_size[11:8]

   {0x016f, 0x80},// y_output_size[7:0]

   {0x0170, 0x01},//X_ODD_INC_A

   {0x0171, 0x01},//Y_ODD_INC_A

   {0x0172, 0x00},//IMG_ORIENTATION_A

   {0x0174, 0x00},//BINNING_MODE_H_A

   {0x0175, 0x00},//BINNING_MODE_V_A

   {0x0301, 0x05},//VTPXCK_DIV

   {0x0303, 0x01},//VTSYCK_DIV

   {0x0304, 0x03},//PREPLLCK_VT_DIV

   {0x0305, 0x03},//PREPLLCK_OP_DIV

   {0x0306, 0x00},//PLL_VT_MPY[10:8]

   {0x0307, 0x48},//0x25},//PLL_VT_MPY[7:0] 0x39

   {0x030b, 0x01},//OPSYCK_DIV

   {0x030c, 0x00},//PLL_OP_MPY[10:8]

   {0x030d, 0x40},//PLL_OP_MPY[7:0] 0x72  0x56  0x51  0x40

   {0x0624, 0x07},

   {0x0625, 0x80},

   {0x0626, 0x04},

   {0x0627, 0x38},

   {0x455e, 0x00},

   {0x471e, 0x4b},

   {0x4767, 0x0f},

   {0x4750, 0x14},

   {0x4540, 0x00},

   {0x47b4, 0x14},

   {0x4713, 0x30},

   {0x478b, 0x10},

   {0x478f, 0x10},

   {0x4793, 0x10},

   {0x4797, 0x0e},

   {0x479b, 0x0e},

   {0x0157, 0x40},

   { REG_NULL, 0x00 }

};
```

#### CSI 模式配置（sensor_csi*_mode_list.c）

修改`sensor_csi0_mode_list.c`、`sensor_csi1_mode_list.c`、`sensor_csi2_mode_list.c`，添加对应 CSI 接口的模式配置，包括分辨率、帧率、MIPI 通道数、数据格式等参数（注：目前仅 CSI0 支持 MCLK）。

```cpp
static const k_sensor_mode sensor_csi0_mode_list[] = {

   {

       .index = 0,

       .sensor_type = IMX219_MIPI_CSI0_2LANE_1920x1080_30FPS_12BIT_LINEAR,

       .size = {

           .bounds_width = 1920,

           .bounds_height = 1080,

           .top = 0,

           .left = 0,

           .width = 1920,

           .height = 1080,

       },

       .fps = 30000,

       .hdr_mode = SENSOR_MODE_LINEAR,

       .bit_width = 10,

       .bayer_pattern = BAYER_PAT_RGGB, //BAYER_PAT_RGGB,

       .mipi_info = {

           .csi_id = 0,

           .mipi_lanes = 2,

           .data_type = 0x2B,

       },

#if defined (CONFIG_MPP_SENSOR_GC2093_ON_CSI0_USE_CHIP_CLK)

       .mclk_setting = {

           {

               .mclk_setting_en = K_TRUE,

               .setting.id = CONFIG_MPP_CSI_DEV0_MCLK_NUM,

               .setting.mclk_sel = SENSOR_PLL1_CLK_DIV4,

               .setting.mclk_div = 25, // 594/25 = 23.76MHz

           },

           {K_FALSE},

           {K_FALSE},

       },

       .reg_list = gc2093_mipi2lane_1080p_30fps_linear,

       .sensor_ae_info = &sensor_csi0_ae_info[0],

#else

       .mclk_setting = {

           {K_FALSE},

           {K_FALSE},

           {K_FALSE},

       },

       .reg_list = gc2093_mipi2lane_1080p_30fps_mclk_24m_linear,

       .sensor_ae_info = &sensor_csi0_ae_info[4],

#endif

   },

};
```

#### AE 参数配置

在`sensor_csi*_mode_list.c`中添加自动曝光（AE）参数配置，包括帧长、曝光时间增量、增益范围等。

```cpp
static k_sensor_ae_info sensor_csi2_ae_info[] = {

    // list  for external  clk 23.76M

   // 1920x1080

   {

       .frame_length = 1206,

       .cur_frame_length = 1206,

       .one_line_exp_time = 0.000027652,

       .gain_accuracy = 1024,

       .min_gain = 1,

       .max_gain = 18,

       .int_time_delay_frame = 2,

       .gain_delay_frame = 2,

       .color_type = SENSOR_COLOR,

       .integration_time_increment = 0.000027652, // 计算方式：1000/(FPS×frame_length) = 1000/(30×1166)≈0.02858

       .gain_increment = IMX219_MIN_GAIN_STEP,

       .max_integraion_line = 1206 - 1,

       .min_integraion_line = 1,

       .max_integraion_time = 0.000027652 * (1206 - 1),

       .min_integraion_time = 0.000027652 * 1,

       .cur_integration_time = 0.0,

       .cur_again = 1.0,

       .cur_dgain = 1.0,

       .a_gain = {

           .min = 1.0,

           .max = 63.984375,

           .step = (1.0f/64.0f),

       },

       .d_gain = {

           .min = 1.0,

           .max = 63.984375,

           .step = (1.0f/1024.0f),

       },

       .cur_fps = 30,

   },

};
```

#### 核心驱动实现（imx219.c）

##### 寄存器定义

根据 IMX219 芯片手册，定义芯片 ID、曝光、增益等关键寄存器地址。

```cpp
/* Chip ID */

#define IMX219_CHIP_ID                  (219)

#define IMX219_REG_ID                   (0x10)  

/* Exposure control */

#define IMX219_REG_EXP_SHORT_TIME_H     (0x018a)

#define IMX219_REG_EXP_SHORT_TIME_L     (0x018b)

#define IMX219_REG_EXP_TIME_H           (0x015a)

#define IMX219_REG_EXP_TIME_L           (0x015b)

/* Analog gain control */

#define IMX219_REG_DGAIN_H              (0x0158)

#define IMX219_REG_DGAIN_L              (0x0159)

#define IMX219_MIN_GAIN_STEP            (1.0f/64.0f)
```

##### 探针函数实现

开机时通过 I2C 读取芯片 ID，确认 IMX219 是否接入，并初始化对应 CSI 接口的模式列表。

```cpp
k_s32 sensor_imx219_probe(struct k_sensor_probe_cfg *cfg, struct sensor_driver_dev *dev)

{

   k_s32 ret = 0;

   k_u32 chip_id = 0;

   const k_sensor_mode *sensor_mode = NULL;

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_0)

   if(0x00 == cfg->csi_num) {

       dev->mode_count = sizeof(sensor_csi0_mode_list) / sizeof(sensor_csi0_mode_list[0]);

       dev->sensor_mode_list = &sensor_csi0_mode_list[0];

       sensor_mode = &dev->sensor_mode_list[0];

   } else

#endif // CONFIG_MPP_ENABLE_CSI_DEV_0

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_1)

   if(0x01 == cfg->csi_num) {

       dev->mode_count = sizeof(sensor_csi1_mode_list) / sizeof(sensor_csi1_mode_list[0]);

       dev->sensor_mode_list = &sensor_csi1_mode_list[0];

       sensor_mode = &dev->sensor_mode_list[0];

   } else

#endif // CONFIG_MPP_ENABLE_CSI_DEV_1

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_2)

   if(0x02 == cfg->csi_num) {

       dev->mode_count = sizeof(sensor_csi2_mode_list) / sizeof(sensor_csi2_mode_list[0]);

       dev->sensor_mode_list = &sensor_csi2_mode_list[0];

       sensor_mode = &dev->sensor_mode_list[0];

   }

#endif // CONFIG_MPP_ENABLE_CSI_DEV_2

   if(0x00 == dev->mode_count) {

       goto _on_failed;

   }

   if(NULL == sensor_mode) {

       rt_kprintf("FATAL error, %sn", __func__);

       goto _on_failed;

   }

   /* update dev */

   dev->pwd_gpio = cfg->pwd_gpio;

   dev->reset_gpio = cfg->reset_gpio;

   if(NULL == (dev->i2c_info.i2c_bus = rt_i2c_bus_device_find(cfg->i2c_name))) {

       rt_kprintf("Can't find %sn", cfg->i2c_name);

       goto _on_failed;

   }

   strncpy(&dev->i2c_info.i2c_name[0], cfg->i2c_name, sizeof(dev->i2c_info.i2c_name));

   memcpy(&dev->sensor_func, &sensor_functions, sizeof(k_sensor_function));

   //设置时钟

   sensor_set_mclk(&sensor_mode->mclk_setting[0]);

   /** NEW SENSOR MODIFY START */

   snprintf(dev->sensor_name, sizeof(dev->sensor_name), "imx219_csi%d", cfg->csi_num);

   //设置power上电

   _sensor_power_state_set(dev, 1, 1);

   /* probe different slave address */

   dev->i2c_info.reg_addr_size = SENSOR_REG_VALUE_16BIT;

   dev->i2c_info.reg_val_size = SENSOR_REG_VALUE_8BIT;

   dev->i2c_info.slave_addr = 0x10;

   //读取chip ID

   if((0x00 != _sensor_read_chip_id_r(dev, &chip_id))) {

       _sensor_power_state_set(dev, 1, 1);

       goto _on_failed;

   }

   /** NEW SENSOR MODIFY END */

   return 0;

_on_failed:

   memset(dev, 0, sizeof(*dev));

   return -1;

}
```

##### 传感器功能函数映射

实现 Sensor 的电源控制、初始化、参数配置（增益、曝光、帧率等）函数映射，下面标注的必须实现的函数需要根据摄像头datasheet文档完成参数配置。

```cpp
static const k_sensor_function sensor_functions = {
//sensor 上电初始化（必须实现）
   .sensor_power = sensor_power_impl,
//初始化配置函数，用来对sensor reset，gpio控制等（必须实现）
   .sensor_init = sensor_init_impl, 
//读取sensor chip id(必须实现)
   .sensor_get_chip_id = sensor_get_chip_id_impl,
//获取当前模式，可以参考其他sensor实现(必须实现)
   .sensor_get_mode = sensor_get_mode_impl,
//设置当前模式，进行模式切换，可以参考其他sensor实现(必须实现)
   .sensor_set_mode = sensor_set_mode_impl,
//列举当前支持的模式，可以参考其他sensor实现(必须实现)
   .sensor_enum_mode = sensor_enum_mode_impl,
//获取当前sensor的能力，包括位宽、分辨率和RAW格式(必须实现)
   .sensor_get_caps = sensor_get_caps_impl,
//获取当前设备的连接状态
   .sensor_conn_check = sensor_conn_check_impl,
//使能或者关闭码流(必须实现)
   .sensor_set_stream = sensor_set_stream_impl,
//获取当前的again(必须实现)
   .sensor_get_again = sensor_get_again_impl,
//设置当前的again(必须实现)
   .sensor_set_again = sensor_set_again_impl,
//获取当前的Dgain
   .sensor_get_dgain = sensor_get_dgain_impl,
//设置当前的Dgain
   .sensor_set_dgain = sensor_set_dgain_impl,
//获取当前的曝光时间(必须实现)
   .sensor_get_intg_time = sensor_get_intg_time_impl,
//设置当前的曝光时间(必须实现)
   .sensor_set_intg_time = sensor_set_intg_time_impl,
//获取当前曝光参数
   .sensor_get_exp_parm = sensor_get_exp_parm_impl,
//设置当前曝光参数
   .sensor_set_exp_parm = sensor_set_exp_parm_impl,
//获取当前的帧率
   .sensor_get_fps = sensor_get_fps_impl,
//设置当前帧率
   .sensor_set_fps = sensor_set_fps_impl,
//获取当前ISP状态
   .sensor_get_isp_status = sensor_get_isp_status_impl,
//设置blc
   .sensor_set_blc = sensor_set_blc_impl,
//设置wb
   .sensor_set_wb = sensor_set_wb_impl,
//获取tpg配置
   .sensor_get_tpg = sensor_get_tpg_impl,
//设置tpg
   .sensor_set_tpg = sensor_set_tpg_impl,
//读取expand_curve数据
   .sensor_get_expand_curve = sensor_get_expand_curve_impl,
//读取sensor otp数据
   .sensor_get_otp_data = sensor_get_otp_data_impl,
//设置sensor mirror
   .sensor_mirror_set = sensor_mirror_set_impl,
//自动对焦相关函数，设置对焦距离
   .sensor_set_focus_pos = sensor_autofocus_dev_set_position,
//自动对焦相关函数，获取对焦距离
   .sensor_get_focus_pos = sensor_autofocus_dev_get_position,
//自动对焦相关函数，获取自动对焦能力
   .sensor_get_foucs_cap = sensor_autofocus_dev_get_capability,
//自动对焦相关函数，设置自动对焦上电
   .sensor_set_focus_power = sensor_autofocus_dev_power,

};
```

### 应用层适配

#### Sensor 类型映射

在`~/src/rtsmart/mpp/userapps/src/sensor/mpi_sensor_type_to_mirror.c`中，添加 IMX219 的模式与镜像配置映射（根据开发板型号适配）。

```cpp
#elif defined(CONFIG_BOARD_K230_CANMV_01STUDIO)

static struct sensor_type_mirror_t type_mirror_tbl[] = {

...

#if defined (CONFIG_MPP_ENABLE_SENSOR_IMX219)

   {.type = IMX219_MIPI_CSI0_2LANE_1920x1080_30FPS_10BIT_LINEAR, .mirror = 0},

   {.type = IMX219_MIPI_CSI0_2LANE_1080x1920_30FPS_10BIT_LINEAR, .mirror = 0},

   {.type = IMX219_MIPI_CSI1_2LANE_1920x1080_30FPS_10BIT_LINEAR, .mirror = 0},

   {.type = IMX219_MIPI_CSI1_2LANE_1080x1920_30FPS_10BIT_LINEAR, .mirror = 0},

   {.type = IMX219_MIPI_CSI2_2LANE_1920x1080_30FPS_10BIT_LINEAR, .mirror = 0},

   {.type = IMX219_MIPI_CSI2_2LANE_1080x1920_30FPS_10BIT_LINEAR, .mirror = 0},

#endif // CONFIG_MPP_ENABLE_SENSOR_IMX219

};
```

#### 默认配置添加

在`~/src/rtsmart/mpp/userapps/src/sensor/mpi_sensor.c`中，添加 IMX219 的默认参数配置，包括 CSI 接口、分辨率、帧率、数据格式等。

```cpp
static const k_vicap_sensor_info sensor_info_list[] = {

...

#if defined (CONFIG_MPP_ENABLE_SENSOR_IMX219)

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_0)

   {

       "imx219_csi0",

       "imx219-1920x1080",

       1920,

       1080,

       VICAP_CSI0,

       VICAP_MIPI_2LANE,

       VICAP_SOURCE_CSI0,

       K_FALSE,

       VICAP_MIPI_PHY_1200M,

       VICAP_CSI_DATA_TYPE_RAW10,

       VICAP_LINERA_MODE,

       VICAP_FLASH_DISABLE,

       VICAP_VI_FIRST_FRAME_FS_TR0,

       0,

       30,

       IMX219_MIPI_CSI0_2LANE_1920x1080_30FPS_10BIT_LINEAR,

   },

   {

       "imx219_csi0",

       "imx219-1080x1920",

       1080,

       1920,

       VICAP_CSI0,

       VICAP_MIPI_2LANE,

       VICAP_SOURCE_CSI0,

       K_FALSE,

       VICAP_MIPI_PHY_1200M,

       VICAP_CSI_DATA_TYPE_RAW10,

       VICAP_LINERA_MODE,

       VICAP_FLASH_DISABLE,

       VICAP_VI_FIRST_FRAME_FS_TR0,

       0,

       60,

       IMX219_MIPI_CSI0_2LANE_1080x1920_30FPS_10BIT_LINEAR,

   },

#endif // CONFIG_MPP_ENABLE_CSI_DEV_0

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_1)

   {

       "imx219_csi1",

       "imx219-1920x1080",

       1920,

       1080,

       VICAP_CSI1,

       VICAP_MIPI_2LANE,

       VICAP_SOURCE_CSI1,

       K_FALSE,

       VICAP_MIPI_PHY_1200M,

       VICAP_CSI_DATA_TYPE_RAW10,

       VICAP_LINERA_MODE,

       VICAP_FLASH_DISABLE,

       VICAP_VI_FIRST_FRAME_FS_TR0,

       0,

       30,

       IMX219_MIPI_CSI1_2LANE_1920x1080_30FPS_10BIT_LINEAR,

   },

   {

       "imx219_csi1",

       "imx219-1080x1920",

       1080,

       1920,

       VICAP_CSI1,

       VICAP_MIPI_2LANE,

       VICAP_SOURCE_CSI1,

       K_FALSE,

       VICAP_MIPI_PHY_1200M,

       VICAP_CSI_DATA_TYPE_RAW10,

       VICAP_LINERA_MODE,

       VICAP_FLASH_DISABLE,

       VICAP_VI_FIRST_FRAME_FS_TR0,

       0,

       60,

       IMX219_MIPI_CSI1_2LANE_1080x1920_30FPS_10BIT_LINEAR,

   },

#endif // CONFIG_MPP_ENABLE_CSI_DEV_1

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_2)

   {

       "imx219_csi2",

       "imx219-1920x1080",

       1920,

       1080,

       VICAP_CSI2,

       VICAP_MIPI_2LANE,

       VICAP_SOURCE_CSI2,

       K_FALSE,

       VICAP_MIPI_PHY_1200M,

       VICAP_CSI_DATA_TYPE_RAW10,

       VICAP_LINERA_MODE,

       VICAP_FLASH_DISABLE,

       VICAP_VI_FIRST_FRAME_FS_TR0,

       0,

       30,

       IMX219_MIPI_CSI2_2LANE_1920x1080_30FPS_10BIT_LINEAR,

   },

   {

       "imx219_csi2",

       "imx219-1080x1920",

       1080,

       1920,

       VICAP_CSI2,

       VICAP_MIPI_2LANE,

       VICAP_SOURCE_CSI2,

       K_FALSE,

       VICAP_MIPI_PHY_1200M,

       VICAP_CSI_DATA_TYPE_RAW10,

       VICAP_LINERA_MODE,

       VICAP_FLASH_DISABLE,

       VICAP_VI_FIRST_FRAME_FS_TR0,

       0,

       30,

       IMX219_MIPI_CSI2_2LANE_1080x1920_30FPS_10BIT_LINEAR,

   },

#endif // CONFIG_MPP_ENABLE_CSI_DEV_2

#endif // CONFIG_MPP_ENABLE_SENSOR_IMX219

...

};
```

#### ISP 配置文件添加

在`~/src/rtsmart/mpp/userapps/src/sensor/config`目录下，添加 IMX219 对应分辨率的 ISP 配置文件（xml/json 格式）。

```shell
zhangchenli@DESKTOP-OSN5BJK:~/canmv_k230_mmp/src/rtsmart/mpp/userapps/src/sensor/config$ ls imx219*

imx219-1920x1080.xml  imx219-1920x1080_auto.json  imx219_1920x1080_manual.json
```

#### 编译拷贝配置

在`~/src/rtsmart/Makefile`中添加配置，确保编译时自动拷贝 IMX219 的应用层文件到镜像目录。

```shell
ifeq ($(CONFIG_MPP_ENABLE_SENSOR_IMX219),y)

   @rsync -a --delete $(SDK_RTSMART_SRC_DIR)/rtsmart/userapps/root/bin/imx219-* ${SDK_BUILD_IMAGES_DIR}/bin/

endif
```

### 编译运行

- 执行`make menuconfig`，在`MPP`配置中启用`IMX219` Sensor 支持
- 回到 RTOS 根目录，执行`make`编译生成镜像
- 使用烧录工具（如 rufus）将镜像写入 TF 卡
- 将 TF 卡插入开发板，上电启动，验证 IMX219 是否正常工作

### 问题调试

#### 黑屏问题排查

若对接后显示黑屏，按以下步骤排查：

##### 步骤 1：查看 ISP 状态

通过命令查看 ISP 是否有数据输入：

```shell
msh /sdcard>cat /proc/umap/vicap

----------------------------------ISP STATUS INFO----------------------------------

ISP-DEV         ISP-Interrups   MI-Interrups    FE-Interrups

0               0               0               0

1               0               0               0

2               0               0               0

ISP-DEV         MCMW0-Interrups MCMW1-Interrups MCMW2-Interrups RDMA-Interrups

0               0               0               0               0

1               0               0               0               0

2               0               0               0               0

ISP-DEV         MP-Interrups    SP1-Interrups   SP2-Interrups   ISP-OUT-Interrups

0               0               0               0               0

1               0               0               0               0

2               0               0               0               0

ISP-DEV         MIS-Interrups   MIS1-Interrups  MIS2-Interrups  MIS3-Interrups

0               0               0               0               0

1               0               0               0               0

2               0               0               0               0

ISP-DEV         Input-Frames    Output0-Frames  Output1-Frames  Output2-Frames

0               0               0               0               0

1               0               0               0               0

2               0               0               0               0

ISP-DEV         INPUT           OUTPUT0                         OUTPUT1                         OUTPUT2                      

0               1920x1080       1920x1080@YUV_SEMIPLANAR_420    N/A                             N/A                         

ISP-DEV         AE      AWB     CCM     2DNR    3DNR    DEWARP

0               On      On      On      On      Off     Off
```

- 若所有`Input-Frames`为 0，说明 Sensor 端无数据输出，需检查 Sensor 驱动或硬件连接。

##### 步骤 2：验证 I2C 通信

通过`i2c_read`命令读取 IMX219 寄存器，确认 I2C 通信是否正常：

```shell
msh />i2c_read -h

USAGE: i2c_read i2c_id salve_addr reg_addr

msh />i2c_read 0 0x10 0x3a0a

i2c_read 0 0x10 0x3a0a

0x3a0a=0x00
```

##### 步骤 3：检查 CSI 寄存器状态

读取 CSI 接口对应的寄存器值，确认 CSI 是否正常配置：

```shell
msh />devmem2 0x9000980c  # CSI0寄存器地址：0x9000980c；CSI1：0x9000a00c；CSI2：0x9000a80c

Value at address 0x9000980C (00000000c00d280c): 0x0
```

##### 步骤 4：调整 MIPI PHY 频率

MIPI CSI PHY 仅支持`VICAP_MIPI_PHY_800M`和`VICAP_MIPI_PHY_1200M`，若频率不匹配会导致数据传输失败，需在应用层配置中切换尝试：

```cpp
/**
* @brief Defines the MIPI CSI PHY freq
**/
typedef enum {

   VICAP_MIPI_PHY_800M  = 1,

   VICAP_MIPI_PHY_1200M = 2,

   VICAP_MIPI_PHY_1600M = 3, // 不支持，需排除

} k_vicap_mipi_phy_freq;
```
