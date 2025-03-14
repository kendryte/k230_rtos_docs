# Display Demo

## 简介

VO（Video Output，视频输出）模块主动从内存相应位置读取视频和图形数据，并通过相应的显示设备输出视频和图形。芯片支持的显示/回写设备、视频层和图形层情况。VO demo是对这些接口和功能进行测试。

## 功能说明

sample_vo 对OSD、Video Layer模块进行测试。

## 代码位置

Demo 源码位置：`canmv_k230/src/rtsmart/mpp/userapps/sample/sample_vo`。

假设您已经正确编译该 Demo。启动开发板后，进入 `/sdcard/elf/userapps` 目录，`sample_vo.elf` 为测试 Demo。

## 使用说明

输入参数如下：

| 参数名 | 描述 | 默认值 |
|--------|------|--------|
| -num   | 测试模式（参考下面display_test_case） | -      |

```c
typedef enum
{
    DISPLAY_DSI_LP_MODE_TEST,   //LP mode 测试
    DISPLAY_DSI_HS_MODE_TEST,   //HS mode 测试
    DISPLAY_DSI_TEST_PATTERN,   //DSI pattern mode 测试
    DISPALY_VO_BACKGROUND_TEST, //背景颜色 mode 测试
    DISPALY_VO_WRITEBACK_TEST,  //回写 mode 测试
    DISPALY_VO_OSD0_TEST,       //OSD0 mode 测试
    DISPALY_VO_INSERT_MULTI_FRAME_OSD0_TEST, // 多帧插入OSD0 mode 测试
    DISPALY_VO_LAYER_INSERT_FRAME_TEST, //layer mode 测试
    DISPALY_VVI_BING_VO_LAYER_TEST, //VI、VO、Layer绑定 mode 测试
    DISPALY_VVI_BING_VO_OSD_TEST, //VI、VO、OSD绑定测试
    DISPALY_VVI_BING_VO_OSD_DUMP_FRAME_TEST, //VI、VO、OSD保存数据 mode 测试
    DISPALY_VO_1LAN_CASE_TEST, // VO 1LAN mode 测试
    DISPALY_VO_DSI_READ_ID,  //DSI READ ID mode 测试
    DISPALY_VO_LAYER0_ROTATION, //Layer0 旋转 mode 测试
    DISPALY_VO_CONNECTOR_TEST, //VO Connector 测试
    DISPALY_VO_LT9611_TEST,  //VO LT9611 测试
    DISPALY_VO_ST7701_480x854_TEST, //VO ST7701 480x854 测试
    DISPALY_VO_ST7701_480x800_TEST, //VO ST7701 480x800 测试
    DISPALY_VO_ILI9806_480x800_TEST, //VO ILI9806 480x800 测试
} display_test_case;
```

## 示例

```shell
./sample_vo.elf 0
```

## 查看结果

不同的模式下结果不同，需要根据具体情况判断，需要注意的是VO模块与DSI硬件紧密相关，需要根据硬件选择对应项目进行测试

```{admonition} 提示
有关 display 模块的具体接口，请参考[API文档](../../api_reference/display.md)
```
