# K230视频输出API参考

## 概述

VO（Video Output，视频输出）模块主动从内存相应位置读取视频和图形数据，并通过相应的显示设备输出视频和图形。芯片支持的显示/回写设备、视频层和图形层情况。

LAYER层支持：

|            | LAYER0             | LAYER1             | LAYER2                    |
|------------|--------------------|--------------------|---------------------------|
| 输入格式   | YUV420 NV12        | YUV420 NV12        | YUV420 NV12 YUV422 NV16 ? |
| 最大分辨率 | 1920x1080          | 1920x1080          | 1920x1080                 |
| 叠加显示   | 支持可配置叠加顺序 | 支持可配置叠加顺序 | 支持可配置叠加顺序        |
| Rotation   | √                  | √                  | -                         |
| Scaler     | √                  | -                  | -                         |
| Mirror     | √                  | √                  | -                         |
| Gray       | √                  | √                  | -                         |
| 独立开关   | √                  | √                  | √                         |

OSD 层支持

|                    | OSD0                                                      | OSD1                                                      | OSD2                                                      | OSD3                                                      |
|--------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|-----------------------------------------------------------|
| 输入格式           | RGB888  RGB565 ARGB8888 Monochrome-8-bit RGB4444 RGB1555  | RGB888  RGB565 ARGB8888 Monochrome-8-bit RGB4444 RGB1555  | RGB888  RGB565 ARGB8888 Monochrome-8-bit RGB4444 RGB1555  | RGB888  RGB565 ARGB8888 Monochrome-8-bit RGB4444 RGB1555  |
| 最大分辨率         | 1920x1080                                                 | 1920x1080                                                 | 1920x1080                                                 | 1920x1080                                                 |
| 叠加显示           | 支持可配置叠加顺序                                        | 支持可配置叠加顺序                                        | 支持可配置叠加顺序                                        | 支持可配置叠加顺序                                        |
| ARGB 265 等级ALPHA | √                                                         | √                                                         | √                                                         | √                                                         |
| 独立开关           | √                                                         | √                                                         | √                                                         | √                                                         |

### 硬件描述

本次硬件介绍是以evblp3 做的介绍

#### Mipi接口

在evblp3 上的硬件引脚如下：

![图片包含 图示 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/d7197713d3821fdd3e5c0f2b10dfd5b1.png)

- 屏幕触摸iic用的iic4 （scl：gpio7，sda gpio8）
- 屏幕触摸 rst：gpio29， int：gpio30
- 屏幕的rst：gpio9，backlight：gpio31
- Mipi的引脚和屏幕的引脚一一对应

#### 实物图

![图片包含 游戏机, 电子, 电路 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/69dbfc0ef3144c90f5978f1019482030.png)

- 图中1为mipi接口，采用的是软排线
- 图中2为mipi信号测试点、包含四路data线和一路clk线

### 软件描述

视频输出软件配置分为3部分配置：phy 配置、dsi配置、VO配置，

#### PHY的配置流程

phy的频率需要配置三个参数、计算PLL、配置voc、配置freq，根据这三个参数就可以确定txphy的频率，每一个的参数计算如下。

##### 计算phy的pll

数据速率由 PLL 输出时钟相位频率的两倍给出：数据速率 (Gbps) = PLL Fout(GHz) \* 2，输出频率是输入参考频率和倍频/分频比的函数。 计算phy 的pll共分为4种范围做的计算，不同的频率对应着不同的频率，它可以通过以下方式确定：

| M      | m+2 |
|--------|-----|
| N      | n+1 |
| Fclkin | 24M |

For：

![文本, 信件 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/e99b3eec46b58875ae936ea4ab23d86b.png)

然而在这个需要遵循下边的限制：

![图片包含 文本 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/cfd696fc1b6157fbf0220a4f1545a963.png)

For：

![文本, 信件 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/e0df5cfd79b26cd1c688cb8f82000188.png)

For：

![文本, 信件 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/fb853b016887c1d58cc45f4507d9276c.png)

![文本 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/9cd0c8d3bd975f1f19a5eec9b846d00b.png)

For：

![文本 中度可信度描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/659e3d039a5c3c623b3ffd6fb24ee777.png)

上边的每一个for 对应着一个pll的等级、不同的等级对应着不同的计算公式和限制，计算示例如下：

Example：

mipi 的速率为 445.5M：所以pll的速率就是222.75M，应该选择第二个公式，计算如下

222750000 = 1M / 2N = (m+2) / 2(n+1) \* 24000000 , 整理完成公式如下：

222.75n + 198.75 = 12m ，通过excel 计算如下：

![表格 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/8ff8dac9c9f9b815001733e37e44e4cc.png)

得出来的m = 295 ，n = 15。

配置pll中的m 和n都是整数值、如果所有的值都不是整数，就需要在m 和 n的值做加1和减1处理、反推回去看哪个频率理你需要的最近，再去验证是否可用，不可以就重复上边的操作。

##### 配置phy的voc

配置phy 的voc 可以根据表格查询即可：

![表格 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/174b1b96f4a280ab5350f4ed5452d43f.png)

![表格 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/8e1970bbd7ffb862547feaf8a59cab48.png)

Example：

mipi 的速率为 445.5M：所以pll的速率就是222.75M，voc = 010111 = 0x17

##### 配置freq

配置phy 的freq 可以根据表格查询即可：

![表格 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/95941399975cca1c16253927129d8e19.png)

![表格 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/22628c5b4acf510370e51188734fe172.png)

![表格 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/4a233637850b4e84b5208317666c4314.png)

Example：

mipi 的速率为 445.5M：pll的速率就是222.75M，freq 选择0100101, 配置这个的时候需要将最高位bit\[7\] = 1，所有freq = 10100101= 0xa5

#### DSI的配置

DSI（Display Serial Interface）是MIPI 定义的一组通信协议的一部分联盟，主要实现 MIPI DSI 规范中定义的所有协议功能的数字控制器，包含了具有两个和四个通道的双向 PHY。

DSI在软件中主要配置屏幕显示用的timing和发送命令的功能。

##### 配置显示器的timing

每个厂家的屏幕都会有一组时序用来做屏幕的控制，主要包含了帧的控制时序和一行的控制时序，如下图所示：

![图示 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/01cabbb3d5c1dc60d0baa95a0f87104f.png)

![图示, 示意图 描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/507a7bd277508dc177ebb0c4cfb49b9e.png)

DSI中也会用到这些参数、配置的时序和屏幕一致即可。

##### DSI的命令下发

需要dsi 先进入lp模式、然后就可以发送命令，需要的api如下：

- [kd_mpi_dsi_set_attr](#kd_mpi_dsi_set_attr)
- [kd_mpi_dsi_send_cmd](#kd_mpi_dsi_send_cmd)

发送的数据是按照8位发送的，会根据数量自动选择发送长包还是短包。

##### DSI 的自测模式

DSI 自测模式会按照自己配置的dsi timing 产生color bar 的数据发送出去，这样不依赖vo从ddr读取数据，测试模式显示如下图：

![背景图案 中度可信度描述已自动生成](https://kendryte-download.canaan-creative.com/developer/pictures/25246d8f3ff85d6e9b1de1b03369fbb3.png)

DSI 和vo之间采用的是24位接口，所以配置出来的color bar 是上图的效果，使用方法只需要配置完成dsi之后使能color bar即可，api如下

- [kd_mpi_dsi_set_test_pattern](#kd_mpi_dsi_set_test_pattern)

#### VO的配置

VO（video output）主要是VO（Video Output，视频输出）模块主动从内存相应位置读取视频和图形数据，并通过相应的显示设备输出视频和图形，VO这部分包含两个配置、一个是timing 的配置、另一个是视频层的配置

##### VO 时序配置

VO的时序配置和dsi 的时序配置采用的一样的配置参数，具体的行和列一样，看dsi timing 介绍即可

##### V1.2.3.2 O的layer层配置

VO layer 层目前支持3个layer层、4个osd层。Layer层只能显示yuv的图像格式（layer0 和 layer1 支持的功能在[概述](#概述)中的图表）。

##### VO 的回写功能配置

VO 还支持回写功能、这个可以验证VO配置的是否正确，VO配置完成之后会将数据写回到ddr 当中，方便验证VO的配置是否出现异常

#### VO模块的调试方法

##### 屏幕的测试方法

- 可以通过LP命令配置屏幕进入自测模式、看产生的图像是否正常
- 通过LP命令读取屏幕寄存器看是否有返回

##### DSI 的测试方法

- 配置完dsi之后，让屏幕进入自测模式，量取信号看时候正常，也可以看屏幕是否产生color bar 的图像
- 查看phy的err 状态寄存器、看是否有err 状态，可以通过proc查看

##### VO的测试方法

- VO配置完成之后、打开writeback 功能，查看是否和配置的要求一致
- 读取DSI的err状态寄存器，查看VO和dsi之间数据传输是否出现underflow和overflow，如果出现、适当的调整timing再次尝试

## API 参考

### TXPHY

该功能模块提供以下API：

- [kd_mpi_set_mipi_phy_attr](#kd_mpi_set_mipi_phy_attr)

#### kd_mpi_set_mipi_phy_attr

【描述】

设置phy 的频率

【语法】

k_s32 kd_mpi_set_mipi_phy_attr(k_vo_mipi_phy_attr \*attr)

【参数】

| 参数名称 | 描述               | 输入/输出 |
|----------|--------------------|-----------|
| attr     | Phy 的频率结构描述 [k_vo_mipi_phy_attr](#k_vo_mipi_phy_attr) | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

### DSI

该功能模块提供以下API：

- [kd_mpi_dsi_set_attr](#kd_mpi_dsi_set_attr)
- [kd_mpi_dsi_enable](#kd_mpi_dsi_enable)
- [kd_mpi_dsi_send_cmd](#kd_mpi_dsi_send_cmd)
- [kd_mpi_dsi_read_pkg](#kd_mpi_dsi_read_pkg)
- [kd_mpi_dsi_set_test_pattern](#kd_mpi_dsi_set_test_pattern)

#### kd_mpi_dsi_set_attr

【描述】

配置dsi 属性参数

【语法】

k_s32 kd_mpi_dsi_set_attr(k_display_mode \*attr)

| 参数名称 | 描述         | 输入/输出 |
|----------|--------------|-----------|
| attr     | dsi 属性参数 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_dsi_enable

【描述】

打开dsi

【语法】

k_s32 kd_mpi_dsi_enable(k_u32 enable)

【参数】

| 参数名称 | 描述         | 输入/输出 |
|----------|--------------|-----------|
| enable     | dsi 使能状态（1：enable，0：disble） | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_dsi_send_cmd

【描述】

Dsi 发送命令

【语法】

k_s32 kd_mpi_dsi_send_cmd(k_u8 \*data, k_s32 cmd_len)

【参数】

| 参数名称 | 描述       | 输入/输出 |
|----------|------------|-----------|
| data     | 发送的数据 | 输入      |
| cmd_len  | 数据长度   | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_dsi_read_pkg

【描述】

Dsi 读取命令

【语法】

k_s32 kd_mpi_dsi_read_pkg(k_u8 addr, k_u16 cmd_len, k_u32 \*rv_data)

【参数】

| 参数名称 | 描述       | 输入/输出 |
|----------|------------|-----------|
| addr     | 接受的数据 | 输入      |
| cmd_len  | 数据长度   | 输入      |
| rv_data  | 返回的数据 | 输出      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_dsi_set_test_pattern

【描述】

配置dsi 进入自测模式

【语法】

k_s32 kd_mpi_dsi_set_test_pattern(void)

【参数】、

无

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

### VO

- [kd_mpi_vo_init](#kd_mpi_vo_init)
- [kd_mpi_vo_set_dev_param](#kd_mpi_vo_set_dev_param)
- [kd_mpi_vo_enable_video_layer](#kd_mpi_vo_enable_video_layer)
- [kd_mpi_vo_disable_video_layer](#kd_mpi_vo_disable_video_layer)
- [kd_mpi_vo_enable](#kd_mpi_vo_enable)
- [kd_mpi_vo_chn_insert_frame](#kd_mpi_vo_chn_insert_frame)
- [kd_mpi_vo_chn_dump_frame](#kd_mpi_vo_chn_dump_frame)
- [kd_mpi_vo_chn_dump_release](#kd_mpi_vo_chn_dump_release)
- [kd_mpi_vo_osd_enable](#kd_mpi_vo_osd_enable)
- [kd_mpi_vo_osd_disable](#kd_mpi_vo_osd_disable)
- [kd_mpi_vo_set_video_osd_attr](#kd_mpi_vo_set_video_osd_attr)
- [kd_mpi_vo_set_wbc_attr](#kd_mpi_vo_set_wbc_attr)
- [kd_mpi_vo_enable_wbc](#kd_mpi_vo_enable_wbc)
- [kd_mpi_vo_disable_wbc](#kd_mpi_vo_disable_wbc)
- [kd_display_reset](#kd_display_reset)
- [kd_display_set_backlight](#kd_display_set_backlight)
- [kd_mpi_vo_set_user_sync_info](#kd_mpi_vo_set_user_sync_info)
- kd_mpi_vo_draw_frame

#### kd_mpi_vo_init

【描述】

Vo 初始化默认参数

【语法】

k_s32 kd_mpi_vo_init(void);

【参数】

无

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_set_dev_param

【描述】

Dsi 发送命令

【语法】

k_s32 kd_mpi_vo_set_dev_param(k_vo_pub_attr \*attr)

【参数】

| 参数名称 | 描述                             | 输入/输出 |
|----------|----------------------------------|-----------|
| attr     | 视频输出设备公共属性结构体指针。 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_enable_video_layer

【描述】

配置layer 层属性参数

【语法】

k_s32 kd_mpi_vo_enable_video_layer([k_vo_layer](#k_vo_layer) layer)

【参数】

| 参数名称 | 描述                                                 | 输入/输出 |
|----------|------------------------------------------------------|-----------|
| layer    | 视频输出视频层号 取值范围 【0 – K_MAX_VO_LAYER_NUM】 |  输入     |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_disable_video_layer

【描述】

关闭视频层

【语法】

k_s32 kd_mpi_vo_disable_video_layer([k_vo_layer](#k_vo_layer) layer)

【参数】

| 参数名称 | 描述                                                 | 输入/输出 |
|----------|------------------------------------------------------|-----------|
| layer    | 视频输出视频层号 取值范围 【0 – K_MAX_VO_LAYER_NUM】 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：
- 库文件：

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_enable

【描述】

打开vo

【语法】

k_u8 kd_mpi_vo_enable(void);

【参数】

无

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：
- 库文件：

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_chn_insert_frame

【描述】

插入帧到vo的通道

【语法】

k_s32 kd_mpi_vo_chn_insert_frame(k_u32 chn_num, [k_video_frame_info](#k_video_frame_info) \*vf_info)

【参数】

| 参数名称 | 描述                 | 输入/输出 |
|----------|----------------------|-----------|
| chn_num  | 通道数量             | 输入      |
| vf_info  | 视频帧的结构体指针。 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h k_video_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_chn_dump_frame

【描述】

从vo 的通道中抓取一帧数据

【语法】

k_s32 kd_mpi_vo_chn_dump_frame(k_u32 chn_num, [k_video_frame_info](#k_video_frame_info) \*vf_info, k_u32 timeout_ms);

【参数】

| 参数名称   | 描述               | 输入/输出 |
|------------|--------------------|-----------|
| chn_num    | 通道id             | 输入      |
| vf_info    | 视频帧的结构体指针 | 输入      |
| timeout_ms | 超时时间           | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h k_video_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_chn_dump_release

【描述】

释放抓取帧

【语法】

k_s32 kd_mpi_vo_chn_dump_release(k_u32 chn_num, const [k_video_frame_info](#k_video_frame_info) \*vf_info);

【参数】

| 参数名称 | 描述               | 输入/输出 |
|----------|--------------------|-----------|
| chn_num  | 通道id             | 输入      |
| vf_info  | 视频帧的结构体指针 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件： mpi_vo_api.h k_video_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_osd_enable

【描述】

打开osd层

【语法】

k_s32 kd_mpi_vo_osd_enable([k_vo_osd](#k_vo_osd) layer)

【参数】

| 参数名称 | 描述                                               | 输入/输出 |
|----------|----------------------------------------------------|-----------|
| layer    | 视频输出视频层号 取值范围 【0 – K_MAX_VO_OSD_NUM】 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_osd_disable

【描述】

关闭osd层

【语法】

k_s32 kd_mpi_vo_osd_disable([k_vo_osd](#k_vo_osd) layer)

【参数】

| 参数名称 | 描述                                               | 输入/输出 |
|----------|----------------------------------------------------|-----------|
| layer    | 视频输出视频层号 取值范围 【0 – K_MAX_VO_OSD_NUM】 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_set_video_osd_attr

【描述】

设置osd层属性

【语法】

k_s32 kd_mpi_vo_set_video_osd_attr([k_vo_osd](#k_vo_osd) layer, [k_vo_video_osd_attr](#k_vo_video_osd_attr) \*attr)

【参数】

| 参数名称       | 描述                                               | 输入/输出 |
|----------------|----------------------------------------------------|-----------|
| layer          | 视频输出视频层号 取值范围 【0 – K_MAX_VO_OSD_NUM】 | 输入      |
| osd 层属性参数 | osd 层属性参数                                     | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_set_wbc_attr

【描述】

设置回写属性

【语法】

k_s32 kd_mpi_vo_set_wbc_attr([k_vo_wbc_attr](#k_vo_wbc_attr) \*attr)

【参数】

| 参数名称 | 描述               | 输入/输出 |
|----------|--------------------|-----------|
| attr     | writeback 属性参数 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_enable_wbc

【描述】

使能writeback

【语法】

k_s32 kd_mpi_vo_enable_wbc(void)

【参数】

无

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_disable_wbc

【描述】

关闭writeback

【语法】

k_s32 kd_mpi_vo_disable_wbc(void)

【参数】

无

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_display_reset

【描述】

复位视频输出子系统

【语法】

k_s32 kd_display_reset(void)

【参数】

无

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_display_set_backlight

【描述】

复位屏幕和打开背光

【语法】

k_s32 kd_display_set_backlight(void)

【参数】

无

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_set_user_sync_info

【描述】

设置用户接口时序信息，用于配置时钟源、时钟大小和时钟分频比

【语法】

k_s32 kd_mpi_vo_set_user_sync_info(k_u32 pre_div,k_u32 clk_en)

【参数】

| 参数名称 | 描述            | 输入/输出 |
| -------- | --------------- | --------- |
| pre_div  | 用户分频数      | 输入      |
| clk_en   | 分频enable 使能 | 输入       |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_vo_draw_frame

【描述】

画框

【语法】

k_s32 kd_mpi_vo_draw_frame([k_vo_draw_frame](#k_vo_draw_frame) \*frame)

【参数】

| 参数名称 | 描述           | 输入/输出 |
|----------|----------------|-----------|
| frame    | 画框的属性参数 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h
- 库文件：libvo.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_get_connector_info

【描述】

获取connecor 连接器的数据结构通过连接类型

【语法】

k_s32 kd_mpi_get_connector_info([k_connector_type](#k_connector_type) connector_type, [k_connector_info](#k_connector_info) \*connector_info)

【参数】

| 参数名称        | 描述           | 输入/输出 |
|----------------|----------------|-----------|
| connector_type | 连接器的类型    | 输入      |
| connector_info | 连接器的数据结构 | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h k_connector_comm.h
- 库文件：libvo.a libconnector.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_connector_open

【描述】

获取connecor 连接器的数据结构通过连接类型

【语法】

k_s32 kd_mpi_connector_open(const char \*connector_name)

【参数】

| 参数名称        | 描述           | 输入/输出 |
|----------------|----------------|-----------|
| connector_name | 连接器的设备节点    | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| fd     | 成功返回打开fd 的id             |
| 小于0   | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h k_connector_comm.h
- 库文件：libvo.a libconnector.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_connector_power_set

【描述】

打开connector 的电源

【语法】

k_s32 kd_mpi_connector_power_set(k_s32 fd, k_bool on)

【参数】

| 参数名称        | 描述           | 输入/输出 |
|----------------|----------------|-----------|
| fd             | 连接器的设备节点    | 输入      |
| on             | 连接器设备的开关    | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h k_connector_comm.h
- 库文件：libvo.a libconnector.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_connector_init

【描述】

vo connector 初始化

【语法】

k_s32 kd_mpi_connector_init(k_s32 fd, [k_connector_info](#k_connector_info) info)

【参数】

| 参数名称        | 描述           | 输入/输出 |
|----------------|----------------|-----------|
| fd             | 连接器的设备节点    | 输入      |
| info           | 连接器初始化的参数    | 输入      |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0      | 成功。             |
| 非0    | 失败，参见错误码。 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h k_connector_comm.h
- 库文件：libvo.a libconnector.a

【注意】

无

【举例】

无

【相关主题】

无

#### kd_mpi_connector_get_negotiated_data

【描述】

Display驱动和显示器自动协商分辨率，协商成功后会将协商后的数据保存到negotiated_data变量

【语法】

k_s32 kd_mpi_connector_get_negotiated_data(k_s32 fd, [k_connector_negotiated_data](#k_connector_negotiated_data) *negotiated_data);

【参数】

| 参数名称 | 描述 | 输入/输出 |
| ----------------|----------------|-----------|
| fd | 文件描述符 | 输入 |
| negotiated_data | Display驱动和HDMI显示器协商后的数据 | 输入 |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| >= 1 | 成功，自适应成功后Display驱动支持的分辨率数量 |
| -1 | 失败，参见错误码 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h k_connector_comm.h
- 库文件：libvo.a libconnector.a

【注意】

kd_mpi_connector_get_negotiated_data()仅仅只会和显示器进行协商，协商成功后不会将最佳分辨率设置到VO、DSI、HDMI模块上

【举例】

无

【相关主题】

无

#### kd_mpi_connector_adapt_resolution

【描述】

Display驱动和显示器自动协商分辨率，协商成功后会将协商后的数据保存到negotiated_data变量，同时会将最佳的分辨率设置到VO、DSI、HDMI模块

【语法】

k_s32 kd_mpi_connector_adapt_resolution(k_connector_type type, [k_connector_negotiated_data](#k_connector_negotiated_data) *negotiated_data)

【参数】

| 参数名称 | 描述 | 输入/输出 |
| ----------------|----------------|-----------|
| type | 连接器的设备节点，HDMI接口通常设置为LT9611_MIPI_ADAPT_RESOLUTION | 输入 |
| negotiated_data | Display驱动和HDMI显示器协商后的数据 | 输入 |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0 | 成功 |
| -1 | 失败，参见错误码 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h k_connector_comm.h
- 库文件：libvo.a libconnector.a

【注意】

1 kd_mpi_connector_adapt_resolution()内部通过调用kd_mpi_connector_get_negotiated_data()和显示器进行协商

2 当应用程序调用kd_mpi_connector_adapt_resolution()函数完成自适应设置后，仍然可以调用
kd_mpi_get_connector_info()、kd_mpi_connector_open()、kd_mpi_connector_power_set()、kd_mpi_connector_init()重新设置输出分辨率

【举例】

无

【相关主题】

无

#### kd_mpi_connector_set_mirror

【描述】

设置屏幕mirror 功能

【语法】

k_s32 kd_mpi_connector_set_mirror(k_s32 fd, k_connector_mirror mirror)

【参数】

| 参数名称 | 描述 | 输入/输出 |
| ----------------|----------------|-----------|
| fd | 文件描述符 | 输入 |
| mirror | 屏幕mirror 的功能 | 输入 |

【返回值】

| 返回值 | 描述               |
|--------|--------------------|
| 0 | 成功 |
| -1 | 失败，参见错误码 |

【芯片差异】

无

【需求】

- 头文件：mpi_vo_api.h k_vo_comm.h k_connector_comm.h
- 库文件：libvo.a libconnector.a

【注意】

1 kd_mpi_connector_adapt_resolution()内部通过调用kd_mpi_connector_get_negotiated_data()和显示器进行协商

2 当应用程序调用kd_mpi_connector_adapt_resolution()函数完成自适应设置后，仍然可以调用
kd_mpi_get_connector_info()、kd_mpi_connector_open()、kd_mpi_connector_power_set()、kd_mpi_connector_init()重新设置输出分辨率

【举例】

无

【相关主题】

无

## 数据类型

### VO

#### k_vo_intf_sync

【说明】

定义视频中的分辨率和帧率

【定义】

typedef enum {
&emsp;K_VO_OUT_1080P30,
&emsp;K_VO_OUT_1080P60,
} k_vo_intf_sync;

【成员】

| 成员名称               | 描述                                           |
|------------------------|------------------------------------------------|
| K_VO_OUT_1080P30       | 1080 是表示1920x1080 个pix。30 表示 30fps      |
| K_VO_OUT_1080P60       | 1080 是表示1920x1080 个pix。60 表示 60fps      |
| K_VO_OUT_1080x1920P30  | 1080x1920 是表示1080x1920 个pix。30 表示 30fps |
| K_VO_OUT_11080x1920P60 | 1080x1920 是表示1080x1920 个pix。60 表示 60fps |

【注意事项】

无

【相关数据类型及接口】

#### k_vo_intf_type

【说明】

定义视频中的分辨率和帧率

【定义】

typedef enum {
&emsp;K_VO_INTF_MIPI = 0,
} k_vo_intf_type;

【成员】

| 成员名称       | 描述      |
|----------------|-----------|
| K_VO_INTF_MIPI | Mipi 接口 |

【注意事项】

无

【相关数据类型及接口】

#### k_pixel_format

【说明】

显示中layer 支持的数据格式，下边结构体中只列举了显示支持的数据格式，并不是所有的数据格式

【定义】

typedef enum
{
    PIXEL_FORMAT_RGB_444 = 0,
    PIXEL_FORMAT_RGB_555,
    PIXEL_FORMAT_RGB_565,
    PIXEL_FORMAT_RGB_888,
    PIXEL_FORMAT_BGR_444,
    PIXEL_FORMAT_BGR_555,
    PIXEL_FORMAT_BGR_565,
    PIXEL_FORMAT_BGR_888,
    PIXEL_FORMAT_ARGB_1555,
    PIXEL_FORMAT_ARGB_4444,
    PIXEL_FORMAT_ARGB_8565,
    PIXEL_FORMAT_ARGB_8888,
    PIXEL_FORMAT_ARGB_2BPP,
    PIXEL_FORMAT_ABGR_1555,
    PIXEL_FORMAT_ABGR_4444,
    PIXEL_FORMAT_ABGR_8565,
    PIXEL_FORMAT_ABGR_8888,
    PIXEL_FORMAT_BGRA_8888,
    PIXEL_FORMAT_RGB_MONOCHROME_8BPP,
    PIXEL_FORMAT_RGB_BAYER_8BPP,
    PIXEL_FORMAT_RGB_BAYER_10BPP,
    PIXEL_FORMAT_RGB_BAYER_12BPP,
    PIXEL_FORMAT_RGB_BAYER_14BPP,
    PIXEL_FORMAT_RGB_BAYER_16BPP,
    PIXEL_FORMAT_YVU_PLANAR_422,
    PIXEL_FORMAT_YVU_PLANAR_420,
    PIXEL_FORMAT_YVU_PLANAR_444,
    PIXEL_FORMAT_YVU_SEMIPLANAR_422,
    PIXEL_FORMAT_YVU_SEMIPLANAR_420,
    PIXEL_FORMAT_YVU_SEMIPLANAR_444,
    PIXEL_FORMAT_YUV_SEMIPLANAR_422,
    PIXEL_FORMAT_YUV_SEMIPLANAR_420,
    PIXEL_FORMAT_YUV_SEMIPLANAR_444,
    PIXEL_FORMAT_YUYV_PACKAGE_422,
    PIXEL_FORMAT_YVYU_PACKAGE_422,
    PIXEL_FORMAT_UYVY_PACKAGE_422,
    PIXEL_FORMAT_VYUY_PACKAGE_422,
    PIXEL_FORMAT_YYUV_PACKAGE_422,
    PIXEL_FORMAT_YYVU_PACKAGE_422,
    PIXEL_FORMAT_UVYY_PACKAGE_422,
    PIXEL_FORMAT_VUYY_PACKAGE_422,
    PIXEL_FORMAT_VY1UY0_PACKAGE_422,
    PIXEL_FORMAT_YUV_PACKAGE_444,
    PIXEL_FORMAT_YUV_400,
    PIXEL_FORMAT_UV_420,
    PIXEL_FORMAT_BGR_888_PLANAR,
    PIXEL_FORMAT_RGB_888_PLANAR,
    PIXEL_FORMAT_HSV_888_PACKAGE,
    PIXEL_FORMAT_HSV_888_PLANAR,
    PIXEL_FORMAT_LAB_888_PACKAGE,
    PIXEL_FORMAT_LAB_888_PLANAR,
    PIXEL_FORMAT_S8C1,
    PIXEL_FORMAT_S8C2_PACKAGE,
    PIXEL_FORMAT_S8C2_PLANAR,
    PIXEL_FORMAT_S8C3_PLANAR,
    PIXEL_FORMAT_S16C1,
    PIXEL_FORMAT_U8C1,
    PIXEL_FORMAT_U16C1,
    PIXEL_FORMAT_S32C1,
    PIXEL_FORMAT_U32C1,
    PIXEL_FORMAT_U64C1,
    PIXEL_FORMAT_S64C1,
    PIXEL_FORMAT_RGB_565_LE = 300,
    PIXEL_FORMAT_BGR_565_LE,
    PIXEL_FORMAT_BUTT
} k_pixel_format;

【成员】

| 成员名称                         | 描述        |
|----------------------------------|-------------|
| PIXEL_FORMAT_YVU_PLANAR_420      | YUV420 NV12 |
| PIXEL_FORMAT_YVU_PLANAR_422      | YUV422 NV16 |
| PIXEL_FORMAT_RGB_565             | RGB565      |
| PIXEL_FORMAT_RGB_888             | RGB888      |
| PIXEL_FORMAT_RGB_MONOCHROME_8BPP |  8 BIT RGB  |
| PIXEL_FORMAT_ARGB_8888           | ARGB8888    |
| PIXEL_FORMAT_ARGB_4444           | ARGB4444    |
| PIXEL_FORMAT_ARGB_1555           | ARGB1444    |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_osd

【说明】

OSD 的数量和每一个osd 的编号

【定义】

typedef enum {
&emsp;K_VO_OSD0,
&emsp;K_VO_OSD1,
&emsp;K_VO_OSD2,
&emsp;K_VO_OSD3,
&emsp;K_MAX_VO_OSD_NUM,
} k_vo_osd;

【成员】

| 成员名称         | 描述                |
|------------------|---------------------|
| K_VO_OSD0        | 第0层osd            |
| K_VO_OSD1        | 第1层osd            |
| K_VO_OSD2        | 第2层osd            |
| K_VO_OSD3        | 第3层osd            |
| K_MAX_VO_OSD_NUM |  Osd 层最大数量标志 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_layer

【说明】

layer 的数量和每一个layer的编号

【定义】

typedef enum {
&emsp;K_VO_LYAER0 = 0,
&emsp;K_VO_LYAER1,
&emsp;K_VO_LYAER2,
&emsp;K_MAX_VO_LAYER_NUM,
} k_vo_layer;

成员】

| 成员名称           | 描述                  |
|--------------------|-----------------------|
| K_VO_LYAER0        | 第0层layer            |
| K_VO_LYAER1        | 第1层layer            |
| K_VO_LYAER2        | 第2层layer            |
| K_VO_LYAER3        | 第3层layer            |
| K_MAX_VO_LAYER_NUM |  layer 层最大数量标志 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_rotation

【说明】

Layer rotation 支持的功能

【定义】

typedef enum {
&emsp;K_ROTATION_0 = (0x01L \<\< 0),
&emsp;K_ROTATION_90 = (0x01L \<\< 1),
&emsp;K_ROTATION_180 = (0x01L \<\< 2),
&emsp;K_ROTATION_270 = (0x01L \<\< 3),
} k_vo_rotation;

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_mirror_mode

【说明】

Layer mirror 支持的功能。

【定义】

typedef enum {
&emsp;K_VO_MIRROR_NONE = (0x01L \<\< 4),
&emsp;K_VO_MIRROR_HOR = (0x01L \<\< 5),
&emsp;K_VO_MIRROR_VER = (0x01L \<\< 6),
&emsp;K_VO_MIRROR_BOTH = (0x01L \<\< 7),
} k_vo_mirror_mode;

【成员】

| 成员名称         | 描述                    |
|------------------|-------------------------|
| K_VO_MIRROR_NONE | Layer 不做mirror        |
| K_VO_MIRROR_HOR  | Layer 只做水平mirrot    |
| K_VO_MIRROR_VER  | Layer只做垂直mirror     |
| K_VO_MIRROR_BOTH | Layer做垂直和水平mirror |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_user_sync_info

【说明】

用户自定义做时钟分频。

【定义】

typedef struct
{
    k_u32 pre_div;
    k_u32 clk_en;

} k_vo_user_sync_info;

【成员】

| 成员名称 | 描述             |
|----------|------------------|
| pre_div  | Clkext 分频      |
| clk_en   | Display 时钟使能 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_point

【说明】

定义坐标信息结构体。

【定义】

typedef struct {
&emsp;k_u32 x;
&emsp;k_u32 y;
}k_vo_point;

【成员】

| 成员名称 | 描述   |
|----------|--------|
| x        | 横坐标 |
| y        | 纵坐标 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_size

【说明】

定义大小信息结构体。

【定义】

typedef struct {
&emsp;k_u32 width;
&emsp;k_u32 height;
} k_vo_size;

【成员】

| 成员名称 | 描述 |
|----------|------|
| width    | 宽度 |
| height   | 高度 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_video_layer_attr

【说明】

定义 display layer 层属性

【定义】

typedef struct
{
    k_vo_point display_rect;
    k_vo_size img_size;
    k_pixel_format pixel_format;
    k_u32 stride;
    k_u32 func;
    k_vo_scaler_attr scaler_attr;

} k_vo_video_layer_attr;

【成员】

| 成员名称      | 描述                                                                                                                                                            |
|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| display_rect; | OSD图层的的起始位置                                                                                                                                             |
| img_size      | 图像分辨率结构体，即合成画面的尺寸                                                                                                                              |
| pixel_format  | 视频层支持的数据格式                                                                                                                                            |
| stride        | 图像的stride                                                                                                                                                    |
| func            | 设置旋转角度（0、90、180、270）|
| scaler_attr   |  缩放设置 |

【注意事项】

alptha_tpye 仅对osd 层使用

【相关数据类型及接口】

无

#### k_vo_wbc_attr

【说明】

定义 writeback属性。

【定义】

typedef struct {
&emsp;[k_vo_size](#k_vo_size) target_size;
&emsp;[k_pixel_format](#k_pixel_format) pixel_format;
&emsp;k_u32 stride;
&emsp;k_u32 y_phy_addr;
} k_vo_wbc_attr;

【成员】

| 成员名称       | 描述       |
|---------------|------------|
| target_size   | 回写的目标大小  |
| pixel_format  | 回写的数据格式 |
| stride;       | 回写的stride   |
| y_addr        | 图像回写的物理地址    |

【注意事项】

y_addr 需要分配空间

【相关数据类型及接口】

无

#### k_vo_pub_attr

【说明】

配置视频输出设备的公共属性。

【定义】

typedef struct {
&emsp;k_u32 bg_color;
&emsp;[k_vo_intf_type](#k_vo_intf_type) intf_type;
&emsp;[k_vo_intf_sync](#k_vo_intf_sync) intf_sync;
&emsp;[k_vo_display_resolution](#k_vo_display_resolution) \*sync_info;
&emsp;}k_vo_pub_attr;

【成员】

|           |                          |
|-----------|--------------------------|
| 成员名称  | 描述                     |
| bg_color  | 背景色                   |
| type      | 接口类型，目前只支持mipi |
| intf_sync | 视频中的分辨率和帧率     |
| sync_info | 图像输出的时序           |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_scaler_attr

【说明】

定义 scaler 属性

【定义】

typedef struct{
&emsp;k_size out_size;
&emsp;k_u32 stride;
}k_vo_scaler_attr;

【成员】

| 成员名称 | 描述               |
|----------|--------------------|
| out_size | 输出的尺寸         |
| stride   | 输入的stride       |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_draw_frame

【说明】

定义 画框的 属性

【定义】

typedef struct {
&emsp;k_u32 draw_en;
&emsp;k_u32 line_x_start;
&emsp;k_u32 line_y_start;
&emsp;k_u32 line_x_end;
&emsp;k_u32 line_y_end;
&emsp;k_u32 frame_num;
}k_vo_draw_frame;

【成员】

| 成员名称     | 描述                     |
|--------------|--------------------------|
| draw_en      | 画框使能                 |
| line_x_start | X 方向的起始             |
| line_y_start | y方向的起始              |
| line_x_end   | X方向的终点              |
| line_y_end   | y方向的终点              |
| frame_num    | 当前框的num号 【0 - 16】 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_display_resolution

【说明】

Display timing属性。

【定义】

typedef struct{
&emsp;k_u32 pclk;
&emsp;k_u32 phyclk;
&emsp;k_u32 htotal;
&emsp;k_u32 hdisplay;
&emsp;k_u32 hsync_len;
&emsp;k_u32 hback_porch;
&emsp;k_u32 hfront_porch;
&emsp;k_u32 vtotal;
&emsp;k_u32 vdisplay;
&emsp;k_u32 vsync_len;
&emsp;k_u32 vback_porch;
&emsp;k_u32 vfront_porch;
} k_vo_display_resolution;

【成员】

| 成员名称     | 描述               |
|--------------|--------------------|
| pclk         | Vo 的pix clk 频率  |
| phyclk       |  d-phy 的频率      |
| htotal       | 一行的总像素       |
| hdisplay     | 一行的有效像素个数 |
| hsync_len    | 行同步的像素个数   |
| hback_porch  | 后肩 的像素个数    |
| hfront_porch | 前肩 的像素个数    |
| vtotal       | 总行数             |
| vdisplay     | 一帧有效的行数     |
| vsync_len    | 帧同步的像素个数   |
| vback_porch  | 后肩 的行数        |
| vfront_porch | 前肩 的行数        |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_mipi_phy_attr

【说明】

定义 mipi phy 频率的结构体

【定义】

typedef struct
{
    k_u32 n;
    k_u32 m;
    k_u32 voc;
    k_u32 phy_lan_num;
    k_u32 hs_freq;
} k_vo_mipi_phy_attr;

【成员】

| 成员名称    | 描述           |
|-------------|----------------|
| n           | Pll 系数       |
| m           | Pll 系数       |
| voc         | Pll 系数       |
| phy_lan_num | Phy 的lan 数量 |
| hs_freq     | Phy 的频率范围 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_video_osd_attr

【说明】

配置osd层的公共属性。

【定义】

typedef struct {
&emsp;[k_vo_point](#k_vo_size) display_rect;
&emsp;[k_vo_size](#k_vo_size) img_size;
&emsp;[k_pixel_format](#k_pixel_format) pixel_format;
&emsp;k_u32 stride;
&emsp;k_u8 global_alptha;
} k_vo_video_osd_attr;

【成员】

| 成员名称      | 描述       |
|---------------|------------|
| display_rect  | 位置信息   |
| img_size      | 有效的size |
| pixel_format  | 数据格式   |
| stride;       | Stride     |
| global_alptha | 透明度     |

【注意事项】

无

【相关数据类型及接口】

无

#### k_video_frame_info

【说明】

一帧的信息。

【定义】

typedef struct {
&emsp;k_video_frame v_frame;
&emsp;k_u32 pool_id;
&emsp;k_mod_id mod_id;
} k_video_frame_info;

【成员】

| 成员名称 | 描述        |
|----------|-------------|
| v_frame  | 帧的信息    |
| pool_id  | VB pool ID  |
| mod_id   | Video帧的id |

【注意事项】

无

【相关数据类型及接口】

无

#### k_connector_type

【说明】

连接屏幕的类型（由于会增加支持的屏幕数量，请参考SDK中最新定义）。

【定义】

typedef enum {
&emsp;HX8377_V2_MIPI_4LAN_1080X1920_30FPS;
&emsp;LT9611_MIPI_4LAN_1920X1080_60FPS;
&emsp;LT9611_MIPI_4LAN_1920X1080_30FPS;
} k_connector_type;

【成员】

| 成员名称 | 描述                                           |
|----------|-----------------------------------------------|
| v_frame  | 帧的信息                                      |
| HX8377_V2_MIPI_4LAN_1080X1920_30FPS  | hx8377屏幕初始化  |
| LT9611_MIPI_4LAN_1920X1080_60FPS   | hdmi 1080p60 初始化 |
| LT9611_MIPI_4LAN_1920X1080_30FPS   | hdmi 1080p30 初始化 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_dsi_lan_num

【说明】

dsi 的 lane 数量。

【定义】

typedef enum {
&emsp;K_DSI_1LAN = 0,
&emsp;K_DSI_2LAN = 1,
&emsp;K_DSI_4LAN = 3,
} k_dsi_lan_num;

【成员】

| 成员名称 | 描述        |
|----------|-------------|
| K_DSI_1LAN  | 1线模式    |
| K_DSI_2LAN  | 2线模式 |
| K_DSI_4LAN   | 4线模式 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_dsi_work_mode

【说明】

dsi 的工作模式

【定义】

typedef enum{
&emsp;K_BURST_MODE = 0,
&emsp;K_NON_BURST_MODE_WITH_SYNC_EVENT = 1,
&emsp;K_NON_BURST_MODE_WITH_PULSES = 2,
} k_dsi_work_mode;

【成员】

| 成员名称 | 描述        |
|----------|-------------|
| K_BURST_MODE  | dsi 工作在brust mode    |
| K_NON_BURST_MODE_WITH_SYNC_EVENT  | dsi 工作在 non brust event mode |
| K_NON_BURST_MODE_WITH_PULSES   | dsi 工作在 non brust pulses mode |

【注意事项】

无

【相关数据类型及接口】

无

#### k_vo_dsi_cmd_mode

【说明】

dsi 发送命令的模式。

【定义】

typedef enum {
&emsp;K_VO_LP_MODE,
&emsp;K_VO_HS_MODE,
} k_vo_dsi_cmd_mode;

【成员】

| 成员名称 | 描述        |
|----------|-------------|
| K_VO_LP_MODE  | lp 模式发送命令    |
| K_VO_HS_MODE  | hs 模式发送命令 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_connectori_phy_attr

【说明】

connector 连接器 配置phy 的信息。

【定义】

typedef struct {
&emsp;k_u32 n;
&emsp;k_u32 m;
&emsp;k_u32 voc;
&emsp;k_u32 hs_freq;
} k_connectori_phy_attr;

【成员】

| 成员名称 | 描述        |
|----------|-------------|
| n        | Pll 系数    |
| m        | Pll 系数    |
| voc      | Pll 系数    |
| hs_freq  | Phy 的频率范围 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_connector_info

【说明】

连接器的信息。

【定义】

typedef struct {
&emsp;const char *connector_name;
&emsp;k_u32 screen_test_mode;
&emsp;k_u32 dsi_test_mode;
&emsp;k_u32 bg_color;
&emsp;k_u32 intr_line;
&emsp;k_u32 pixclk_div;
&emsp;[k_dsi_lan_num](#k_dsi_lan_num) lan_num;
&emsp;[k_dsi_work_mode](#k_dsi_work_mode) work_mode;
&emsp;[k_vo_dsi_cmd_mode](#k_vo_dsi_cmd_mode) cmd_mode;
&emsp;[k_connectori_phy_attr](#k_connectori_phy_attr) phy_attr;
&emsp;[k_vo_display_resolution](#k_vo_display_resolution) resolution;
&emsp;[k_connector_type](#k_connector_type) type;
} k_connector_info;

【成员】

| 成员名称 | 描述        |
|----------|-------------|
| connector_name  | 连接器的设备节点    |
| screen_test_mode  | 屏幕测试模式  |
| dsi_test_mode   | DSI测试模式 |
| bg_color  | 背景颜色    |
| intr_line  | 屏幕线数  |
| pixclk_div   | 时钟分频数 |
| lan_num  | Lan模式设置：1LAN、2LAN、4LAN|
| work_mode  | 工作模式  |
| cmd_mode   | 命令模式 |
| phy_attr  | 显示的物理地址    |
| resolution  | 分辨率 |
| k_connector_info   | 当前connector的信息 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_connector_negotiated_data

【说明】

Display驱动和HDMI显示器协商后的数据

【定义】

typedef struct {
&emsp;k_u32 connection_status;
&emsp;k_u32 negotiated_count;
&emsp;k_connector_type negotiated_types[256];
} k_connector_negotiated_data;

【成员】

| 成员名称 | 描述        |
| --- | --- |
| connection_status | HDMI接口连接状态    |
| negotiated_count  | Display驱动和HDMI显示器协商后，Display驱动支持的分辨率数量 |
| negotiated_types[256] | Display驱动和HDMI显示器协商后，Display驱动支持的分辨率列表, negotiated_types[0]表示最佳分辨率 |

【注意事项】

无

【相关数据类型及接口】

无

#### k_connector_mirror

【说明】

Display驱动的mirror 功能

【定义】

typedef enum {
&emsp;K_CONNECTOR_MIRROR_HOR = 1,
&emsp;K_CONNECTOR_MIRROR_VER,
&emsp;K_CONNECTOR_MIRROR_BOTH,
}k_connector_mirror;

【成员】

| 成员名称 | 描述        |
| --- | --- |
| K_CONNECTOR_MIRROR_HOR | 横向mirror    |
| K_CONNECTOR_MIRROR_VER  | 纵向mirror |
| K_CONNECTOR_MIRROR_BOTH| 横向和纵向都mirror |

【注意事项】

无

【相关数据类型及接口】

无

## 错误码

表 41 VO API 错误码

| 错误代码   | 宏定义                 | 描述           |
|------------|------------------------|----------------|
| 0xa00b8006 | K_ERR_VO_NULL_PTR      | 参数空指针错误 |
| 0xa00b8001 | K_ERR_VO_INVALID_DEVID | 无效dev id     |
| 0xa00b8002 | K_ERR_VO_INVALID_CHNID | 无效 chn id    |
| 0xa00b8005 | K_ERR_VO_UNEXIST       | 视频缓存不存在 |
| 0xa00b8004 | K_ERR_VO_EXIST         | 视频缓存存在   |
| 0xa00b8003 | K_ERR_VO_ILLEGAL_PARAM | 参数设置无效   |
| 0xa00b8010 | K_ERR_VO_NOTREADY      | vo还未就绪     |
| 0xa00b8012 | K_ERR_VO_BUSY          | 系统忙         |
| 0xa00b8007 | K_ERR_VO_NOT_CONFIG    | 不允许配置     |
| 0xa00b8008 | K_ERR_VO_NOT_SUPPORT   | 不支持的操作   |
| 0xa00b8009 | K_ERR_VO_NOT_PERM      | 操作不允许     |
| 0xa00b800c | K_ERR_VO_NOMEM         | 分配内存失败   |
| 0xa00b800d | K_ERR_VO_NOBUF         | 没有buff       |
| 0xa00b800e | K_ERR_VO_BUF_EMPTY     | Buf 为空       |
| 0xa00b800f | K_ERR_VO_BUF_FULL      | Buf 为满       |
| 0xa00b8011 | K_ERR_VO_BADADDR       | 错误的地址     |
| 0xa00b8012 | K_ERR_VO_BUSY          | 系统忙         |
