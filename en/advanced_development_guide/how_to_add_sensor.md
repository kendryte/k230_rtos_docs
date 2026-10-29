# How to Add a Sensor

> Note: This document is a complete practical guide for adding a new Sensor driver integration (configuration, driver, application layer, debugging).
> If you only need to enable a model already supported by the SDK, see the user guide first: [How to Configure a Sensor](../userguide/how_to_configure_sensor.md).
> Recommended workflow: complete this document (driver integration) first, then proceed to [`how_to_calibrate_isp.md`](./how_to_calibrate_isp.md) and [`how_to_tune_isp.md`](./how_to_tune_isp.md).

## Overview

The K230 Sensor framework is divided into the driver layer and the application layer. The bottom layer is the hardware layer (e.g., Sensors such as ov9732, ov9286, etc.), the middle layer is the driver layer (corresponding to the /dev/sensor_xxx device node), and the upper layer implements operations on the Sensor through the media interface layer (kd_mpi_sensor_xxx) and sensor_ops. This article will use IMX219 as an example to provide a detailed introduction to the complete process of adding Sensor adaptation in the RTOS operating system, including configuration, driver development, application layer adaptation, compilation and running, and problem debugging.

This article focuses on the "driver integration" steps and does not elaborate on ISP calibration and tuning details:

1. For ISP calibration, see: [`how_to_calibrate_isp.md`](./how_to_calibrate_isp.md)
1. For ISP tuning, see: [`how_to_tune_isp.md`](./how_to_tune_isp.md)

![1740391632750](https://www.kendryte.com/api/post/attachment?id=806)

## Development Steps

### Overall Configuration

#### Add Sensor Switch Configuration

Add the IMX219 configuration item in `~/src/rtsmart/mpp/Kconfig` to support enabling/disabling the camera driver through `make menuconfig`, and configure MCLK usage options for different CSI interfaces (CSI0/CSI1/CSI2).

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

### Driver Layer Development

#### Makefile Compilation Configuration

Add IMX219 compilation rules in `~/src/rtsmart/mpp/kernel/sensor/Makefile` to ensure the corresponding driver file is automatically compiled when the configuration is enabled.

```shell
src-$(CONFIG_MPP_ENABLE_SENSOR_IMX219) += src/imx219/imx219.c
```

#### Sensor Mode Definitions

In `~/src/rtsmart/mpp/include/comm/k_sensor_comm.h`, add the resolution, frame rate, and CSI interface combination modes supported by IMX219. The type of each CSI port **must** be wrapped separately with `CONFIG_MPP_ENABLE_CSI_DEV_0/1/2` (consistent with existing sensors; when CSI1 is not enabled, the corresponding enum will not be compiled in).

```cpp
typedef enum {

...

#if defined (CONFIG_MPP_ENABLE_SENSOR_IMX219)

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_0)
   IMX219_MIPI_CSI0_2LANE_3280x2464_21FPS_12BIT_LINEAR,
   IMX219_MIPI_CSI0_2LANE_1920x1080_30FPS_12BIT_LINEAR,
   IMX219_MIPI_CSI0_2LANE_1080x1920_30FPS_12BIT_LINEAR,
#endif

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_1)
   IMX219_MIPI_CSI1_2LANE_3280x2464_21FPS_12BIT_LINEAR,
   IMX219_MIPI_CSI1_2LANE_1920x1080_30FPS_12BIT_LINEAR,
   IMX219_MIPI_CSI1_2LANE_1080x1920_30FPS_12BIT_LINEAR,
#endif

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_2)
   IMX219_MIPI_CSI2_2LANE_3280x2464_21FPS_12BIT_LINEAR,
   IMX219_MIPI_CSI2_2LANE_1920x1080_30FPS_12BIT_LINEAR,
   IMX219_MIPI_CSI2_2LANE_1080x1920_30FPS_12BIT_LINEAR,
#endif

#endif

   SENSOR_TYPE_MAX,

} k_vicap_sensor_type;
```

#### Boot-Time Scan Detection Configuration

Add IMX219 detection support in the driver initialization scan logic, including probe function registration and type name mapping.

##### Probe Function Registration

Modify `~/src/rtsmart/mpp/kernel/sensor/src/sensor_dev.c`, add the IMX219 probe function in the `sensor_probes` array, and add mode name mappings in `sth_table`.

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

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_0)
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI0_2LANE_3280x2464_21FPS_12BIT_LINEAR),
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI0_2LANE_1920x1080_30FPS_12BIT_LINEAR),
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI0_2LANE_1080x1920_30FPS_12BIT_LINEAR),
#endif // CONFIG_MPP_ENABLE_CSI_DEV_0

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_1)
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI1_2LANE_3280x2464_21FPS_12BIT_LINEAR),
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI1_2LANE_1920x1080_30FPS_12BIT_LINEAR),
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI1_2LANE_1080x1920_30FPS_12BIT_LINEAR),
#endif // CONFIG_MPP_ENABLE_CSI_DEV_1

#if defined (CONFIG_MPP_ENABLE_CSI_DEV_2)
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI2_2LANE_3280x2464_21FPS_12BIT_LINEAR),
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI2_2LANE_1920x1080_30FPS_12BIT_LINEAR),
   SENSOR_TYPE_NAME(IMX219_MIPI_CSI2_2LANE_1080x1920_30FPS_12BIT_LINEAR),
#endif // CONFIG_MPP_ENABLE_CSI_DEV_2

#endif

   /* last type set to U32 MAX */

   {__UINT32_MAX__, "UNKNOWN"},

};
```

> **CSI Isolation**: The `k_sensor_comm.h` enumeration, the CSI-divided types in `sth_table` (`list_sensor`), `mpi_sensor.c` / `mpi_sensor_type_to_mirror.c`, and the types divided by CSI all need to be enclosed with `CONFIG_MPP_ENABLE_CSI_DEV_0/1/2`. When a CSI channel is not enabled, the corresponding `*_CSIx_*` will not be included in the firmware. `CSI0 LANE NUM=4LANE` no longer hides CSI1 in software, but CSI0 4LANE and CSI1 cannot be initialized simultaneously at runtime. See [How to Configure the Sensor](../userguide/how_to_configure_sensor.md) for details.

##### Probe Function Declaration

Declare the IMX219 probe function in `~/src/rtsmart/mpp/kernel/sensor/src/sensor_dev.h`.

```c
extern k_s32 sensor_imx219_probe(struct k_sensor_probe_cfg *cfg, struct sensor_driver_dev *dev);
```

#### Driver File Directory Creation

Copy the existing similar Sensor (e.g., gc2093) driver directory, and modify it to the IMX219-specific directory and file names.

```bash
cp -rf gc2093 imx219

cd imx219

mv gc2093.c imx219.c

# The new directory structure is as follows

aaa@DESKTOP-OSN5BJK:~/canmv_k230_mmp/src/rtsmart/mpp/kernel/sensor/src/imx219$ ls

imx219.c  sensor_csi0_mode_list.c  sensor_csi1_mode_list.c  sensor_csi2_mode_list.c  sensor_reg_table.c
```

#### Register Configuration

For the 3 resolution modes, add the corresponding register initialization sequences (needs to be obtained from the camera module manufacturer), and the sequence ends with `{REG_NULL, 0x00}`.

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

#### CSI Mode Configuration (sensor_csi*_mode_list.c)

Modify `sensor_csi0_mode_list.c`, `sensor_csi1_mode_list.c`, and `sensor_csi2_mode_list.c`, and add the mode configuration for the corresponding CSI interface, including parameters such as resolution, frame rate, number of MIPI lanes, data format, etc. (Note: Currently, only CSI0 supports MCLK).

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

#### AE Parameter Configuration

Add the auto-exposure (AE) parameter configuration in `sensor_csi*_mode_list.c`, including frame length, exposure time increment, gain range, etc.

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

       .integration_time_increment = 0.000027652, // Calculation method: 1000/(FPS×frame_length) = 1000/(30×1166)≈0.02858

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

#### Core Driver Implementation (imx219.c)

##### Register Definition

According to the IMX219 chip manual, define the key register addresses such as chip ID, exposure, and gain.

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

##### Probe Function Implementation

Read the chip ID via I2C at startup to confirm whether the IMX219 is connected, and initialize the mode list for the corresponding CSI interface.

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

   //set clock

   sensor_set_mclk(&sensor_mode->mclk_setting[0]);

   /** NEW SENSOR MODIFY START */

   snprintf(dev->sensor_name, sizeof(dev->sensor_name), "imx219_csi%d", cfg->csi_num);

   //power on

   _sensor_power_state_set(dev, 1, 1);

   /* probe different slave address */

   dev->i2c_info.reg_addr_size = SENSOR_REG_VALUE_16BIT;

   dev->i2c_info.reg_val_size = SENSOR_REG_VALUE_8BIT;

   dev->i2c_info.slave_addr = 0x10;

   //read chip ID

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

##### Sensor Function Mapping

Implement the function mapping for the Sensor's power control, initialization, parameter configuration (gain, exposure, frame rate, etc.). The functions marked below as required to be implemented need to be configured according to the camera datasheet document.

```cpp
static const k_sensor_function sensor_functions = {
//sensor power-on initialization (must be implemented)
   .sensor_power = sensor_power_impl,
//initialization configuration function, used to reset sensor, control gpio, etc. (must be implemented)
   .sensor_init = sensor_init_impl, 
//read sensor chip id (must be implemented)
   .sensor_get_chip_id = sensor_get_chip_id_impl,
//get current mode, you can refer to other sensor implementations (must be implemented)
   .sensor_get_mode = sensor_get_mode_impl,
//set current mode, perform mode switching, you can refer to other sensor implementations (must be implemented)
   .sensor_set_mode = sensor_set_mode_impl,
//enumerate currently supported modes, you can refer to other sensor implementations (must be implemented)
   .sensor_enum_mode = sensor_enum_mode_impl,
//get current sensor capabilities, including bit width, resolution and RAW format (must be implemented)
   .sensor_get_caps = sensor_get_caps_impl,
//get the connection status of the current device
   .sensor_conn_check = sensor_conn_check_impl,
//enable or disable the stream (must be implemented)
   .sensor_set_stream = sensor_set_stream_impl,
//get current again (must be implemented)
   .sensor_get_again = sensor_get_again_impl,
//set current again (must be implemented)
   .sensor_set_again = sensor_set_again_impl,
//get current Dgain
   .sensor_get_dgain = sensor_get_dgain_impl,
//set current Dgain
   .sensor_set_dgain = sensor_set_dgain_impl,
//get current exposure time (must be implemented)
   .sensor_get_intg_time = sensor_get_intg_time_impl,
//set current exposure time (must be implemented)
   .sensor_set_intg_time = sensor_set_intg_time_impl,
//get current exposure parameters
   .sensor_get_exp_parm = sensor_get_exp_parm_impl,
//set current exposure parameters
   .sensor_set_exp_parm = sensor_set_exp_parm_impl,
//get current frame rate
   .sensor_get_fps = sensor_get_fps_impl,
//set current frame rate
   .sensor_set_fps = sensor_set_fps_impl,
//get current ISP status
   .sensor_get_isp_status = sensor_get_isp_status_impl,
//set blc
   .sensor_set_blc = sensor_set_blc_impl,
//set wb
   .sensor_set_wb = sensor_set_wb_impl,
//get tpg configuration
   .sensor_get_tpg = sensor_get_tpg_impl,
//set tpg
   .sensor_set_tpg = sensor_set_tpg_impl,
//read expand_curve data
   .sensor_get_expand_curve = sensor_get_expand_curve_impl,
//read sensor otp data
   .sensor_get_otp_data = sensor_get_otp_data_impl,
//set sensor mirror
   .sensor_mirror_set = sensor_mirror_set_impl,
//auto-focus related function, set focus position
   .sensor_set_focus_pos = sensor_autofocus_dev_set_position,
//auto-focus related function, get focus position
   .sensor_get_focus_pos = sensor_autofocus_dev_get_position,
//auto-focus related function, get auto-focus capability
   .sensor_get_foucs_cap = sensor_autofocus_dev_get_capability,
//auto-focus related function, set auto-focus power-on
   .sensor_set_focus_power = sensor_autofocus_dev_power,

};
```

### Application Layer Adaptation

#### Sensor Type Mapping

In `~/src/rtsmart/mpp/userapps/src/sensor/mpi_sensor_type_to_mirror.c`, add the mode and mirror configuration mapping for IMX219 (adapt according to the development board model).

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

#### Default Configuration Addition

In `~/src/rtsmart/mpp/userapps/src/sensor/mpi_sensor.c`, add the default parameter configuration for IMX219, including CSI interface, resolution, frame rate, data format, etc.

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

#### ISP Configuration File Addition

In the `~/src/rtsmart/mpp/userapps/src/sensor/config` directory, add the ISP configuration files (xml/json format) for the corresponding IMX219 resolutions.

```shell
zhangchenli@DESKTOP-OSN5BJK:~/canmv_k230_mmp/src/rtsmart/mpp/userapps/src/sensor/config$ ls imx219*

imx219-1920x1080.xml  imx219-1920x1080_auto.json  imx219_1920x1080_manual.json
```

#### Compile and Copy Configuration

Add configuration in `~/src/rtsmart/mpp/userapps/src/sensor/Makefile` to ensure the IMX219 application layer files are automatically copied to the image directory during compilation.

```shell
ISP_SENSOR_CONFIG_PATTERNS += $(if $(filter y,$(CONFIG_MPP_ENABLE_SENSOR_IMX335)),imx219-*)
```

### Build and Run

- Execute `make menuconfig`, and enable `IMX219` Sensor support in the `MPP` configuration
- Return to the RTOS root directory, execute `make` to compile and generate the image
- Use a flashing tool (such as rufus) to write the image to the TF card
- Insert the TF card into the development board, power it on, and verify whether the IMX219 is working properly

### Troubleshooting

#### Black Screen Issue Investigation

If the display is black after connection, follow these steps to investigate:

##### Step 1: Check ISP Status

Check whether the ISP has data input through the command:

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

- If all `Input-Frames` are 0, it means the Sensor side has no data output. Check the Sensor driver or hardware connection.

##### Step 2: Verify I2C Communication

Read the IMX219 register through the `i2c_read` command to confirm whether the I2C communication is normal:

```shell
msh />i2c_read -h

USAGE: i2c_read i2c_id salve_addr reg_addr

msh />i2c_read 0 0x10 0x3a0a

i2c_read 0 0x10 0x3a0a

0x3a0a=0x00
```

##### Step 3: Check CSI Register Status

Read the register value corresponding to the CSI interface to confirm whether the CSI is configured properly:

```shell
msh />devmem2 0x9000980c  # CSI0 register address: 0x9000980c; CSI1: 0x9000a00c; CSI2: 0x9000a80c

Value at address 0x9000980C (00000000c00d280c): 0x0
```

##### Step 4: Adjust MIPI PHY Frequency

MIPI CSI PHY only supports `VICAP_MIPI_PHY_800M` and `VICAP_MIPI_PHY_1200M`. If the frequency does not match, data transmission will fail. Switch and try in the application layer configuration:

```cpp
/**
* @brief Defines the MIPI CSI PHY freq
**/
typedef enum {

   VICAP_MIPI_PHY_800M  = 1,

   VICAP_MIPI_PHY_1200M = 2,

   VICAP_MIPI_PHY_1600M = 3, // Not supported, must be excluded

} k_vicap_mipi_phy_freq;
```
