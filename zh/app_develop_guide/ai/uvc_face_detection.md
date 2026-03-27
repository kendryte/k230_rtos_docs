# UVC+AI应用开发指南

## 概述

UVC+AI应用是嵌入式系统中常用的一种应用场景，它结合了UVC视频流和AI推理能力，实现了对视频流中目标的检测和识别。本文档以人脸检测应用为例，介绍了如何开发一个基于UVC+AI的人脸检测应用。

本示例中的模型推理部分和文档[单模型推理](./single_model_example.md)中的模型推理部分相同，只是PipeLine的数据源换成了UVC摄像头。这里需要注意的是，UVC摄像头不支持多通道，因此本示例基于单通道UVC摄像头进行开发，这是和MIPI摄像头推理的主要区别。

## 开发指南

### 涉及模块和任务流程

- **涉及的模块**：

1. **uvc模块**：用于从UVC摄像头获取用于AI推理的摄像头帧数据。仅支持`1920*1080`和`640*480`的分辨率。
1. **vo （video output）模块**：配置显示设备(Display)和各显示层属性，包括位置、分辨率、帧率、数据格式等。用于显示摄像头或其他模块送来的显示帧。包括video层和osd层，分别负责显示视频帧和叠加的文本信息。video层只支持yuv格式，osd层只支持rgb格式。
1. **vdec模块**：负责从UVC摄像头获取视频流数据，并将其从JPEG解码为YUV420数据帧。
1. **noai_2d模块**：负责将vdec模块解码后的YUV420数据帧转换为RGB数据帧用于AI模型推理，并将在原始帧上绘制的结果转换为YUV420SP数据帧用于显示。
1. **kpu模块**：负责加载`kmodel`、配置`kmodel`的输入输出`tensor`，并完成模型推理。
1. **ai2d模块**：负责模型输入图像的预处理，支持五种定义的预处理放大，使用方法见文档[usage_ai2d](./usage_ai2d.md)。

- **场景的流程**：

UVC摄像头采集到的视频流数据首先通过vdec模块解码为YUV420数据帧，然后通过noai_2d模块转换为RGB888数据帧。RGB888数据帧送入AI模型进行推理并在原图上绘制识别结果，同时将RGB888数据帧转换为YUV420SP数据帧用于显示。

如下图所示，为UVC摄像头处理逻辑的流程图：

![uvc_process](https://www.kendryte.com/api/post/attachment?id=652)

### 代码结构介绍

以UVC+人脸检测任务为例，下面是已有的代码结构：

```shell
uvc_face_detection
├── cmake
├── src
│    ├── ai_base.cc         # 模型推理封装实现
│    ├── ai_base.h          # 模型推理头文件
│    ├── ai_utils.cc        # 模型推理工具方法
│    ├── ai_utils.h         # 模型推理工具方法头文件
│    ├── anchors_320.cc     # 320输入人脸检测模型使用的anchor
│    ├── anchors_640.cc     # 640输入人脸检测模型使用的anchor
│    ├── face_detection.cc  # 人脸检测任务场景实现，包括适应该场景模型的前处理、推理、后处理、结果绘制等
│    ├── face_detection.h   # 人脸检测任务场景头文件
│    ├── main.cc            # 主函数实现，基于face_detection.h提供的接口实现具体的AI应用场景
│    ├── scoped_timing.h    # 提供计时工具，帮助开发调试
│    ├── setting.h          # 提供配置参数的宏定义，实现显示设备配置和AI推理图像分辨率的配置
│    ├── uvc_pipeline.cc    # UVC摄像头配置流程实现，包括JPEG帧数据、显示设备、解码器、格式转换noai_2d和dump一帧AI推理图像、插入一帧显示图像等
│    ├── uvc_pipeline.h     # UVC摄像头配置流程头文件
│    └── CMakeLists.txt     # UVC摄像头配置流程的CMakeLists.txt
├── utils                   # 可以直接使用的kmodel和脚本
├── CMakeLists.txt          # CMakeLists.txt，用于构建整个应用（方式一）
├── build_app.sh            # 编译脚本
└── Makefile                # Makefile，用于构建整个应用（方式二）
```

### 代码功能介绍

以UVC+人脸检测任务为例，下面介绍已有的代码中不同文件的作用：

| 文件名称                    |         作用     |
|--------------------------- | -----------------|
|ai_base.h|提供模型推理过程中使用的接口|
|ai_bash.cc|提供ai_bash.h中定义的模型推理方法的接口实现|
|ai_utils.h|提供共用的工具函数接口|
|ai_utils.cc|提供ai_utils.h中定义的工具函数实现|
|scoped_timing.h|提供计时工具，帮助开发调试|
|setting.h|提供配置参数的接口，实现显示设备参数配置和AI推理图像分辨率的配置|
|uvc_pipeline.h|提供UVC摄像头配置流程的接口，包括JPEG帧数据、显示设备、解码器、格式转换noai_2d和dump一帧AI推理图像、插入一帧显示图像等|
|uvc_pipeline.cc|提供uvc_pipeline.h中定义的UVC摄像头配置流程接口实现|
|face_detection.h|提供具体任务场景（这里是人脸检测）的预处理、推理、后处理、结果绘制等接口|
|face_detection.cc|提供了face_detection.h定义的任务场景接口实现|
|anchors_320.cc|人脸检测任务使用到的anchors数据|
|anchors_640.cc|人脸检测任务使用到的anchors数据|
|main.cc|主函数实现，基于face_detection.h提供的接口实现具体的AI应用场景|

- `ai_base.h`和 `ai_base.cc` 实现了模型推理的封装基类，实现了 `kmodel` 初始化、模型输入输出初始化、运行和获取输出的接口，代码见文件注释；`scoped_timing.h` 提供了计时工具；**这几个文件一般是不需要更改的**。

- `ai_utils.h` 和 `ai_utils.cc` 提供了通用的工具函数，主要是数据存取和共用的预处理方法，**如果提供的方法无法满足您的需求，您可以修改这两个文件新增方法，如已满足则无需修改**。

- `setting.h`、`uvc_pipeline.h`和`uvc_pipeline.cc` 实现了UVC摄像头、显示设备、解码器、noai2d格式转换、dump帧和插入显示帧等配置和操作，AI推理帧获取和OSD显示叠加方法，现在支持`LT9611 HDMI 1920*1080`和`ST7701 LCD 800*480`两种显示模式；**如果您需要增加新的屏幕支持，才需要调整该文件，否则可以保持不变**。

- `face_detection.h`、 `face_detection.cc` 和 `main.cc` 是用户在开发新的AI应用时**需要自行编写**的文件，编写参考 `src/rtsmart/examples/ai/uvc_face_detection` 下的对应文件即可。其中任务场景的头文件和实现文件主要**实现该任务模型的输入前处理、推理（一般直接调用`ai_base.h`中的`run`方法），模型后处理部分的代码**；`main.cc` 文件需要修改模型推理部分的逻辑，包括**具体任务场景类的实例初始化，前处理、模型推理、后处理和结果绘制接口的调用**。

### 代码详解

#### `setting.h` 配置说明

`setting.h`中配置的宏定义参数主要用于设置摄像头出图、屏幕显示、OSD层、获取AI推理图像的分辨率等。

|宏定义参数|说明|
|:-:|:-:|
|`UVC_WIDTH`|UVC摄像头输出宽度|
|`UVC_HEIGHT`|UVC摄像头输出高度|
|`DISPLAY_MODE`|显示模式，0为1920×1080 LT9611，1为800×480 ST7701|
|`DISPLAY_WIDTH`|显示屏幕宽度|
|`DISPLAY_HEIGHT`|显示屏幕高度|
|`AI_FRAME_WIDTH`|AI推理帧宽度|
|`AI_FRAME_HEIGHT`|AI推理帧高度|
|`AI_FRAME_CHANNEL`|AI推理帧通道数|

下面进行详细介绍：

```cpp
#define UVC_WIDTH 640
#define UVC_HEIGHT 480
```

这是UVC摄像头配置的分辨率，现在支持`1920*1080`和`640*480`两种，可以在HDMI和LCD屏幕上显示。

```cpp
#define DISPLAY_MODE 1    //显示模式，0为1920×1080 lt9611，1为800×480 st7701
#define DISPLAY_WIDTH 640
#define DISPLAY_HEIGHT 480
#define DISPLAY_ROTATE 1  // 旋转，0为不旋转，1为旋转90度
```

这部分参数主要用于配置显示屏幕的分辨率。

```cpp
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 480
#define AI_FRAME_CHANNEL 3
```

这一路是从UVC摄像头配置图像分流给AI通道进行模型预处理的数据，宽高必须和UVC摄像头出图分辨率一致，这里输出的是 `JPEG` 格式的数据。数据需要通过解码器解码为`YUV420`数据，并通过noai2d转换成`RGB888`格式数据，数据排布为`HWC`，需要满足模型的输入。

#### `ai_base.h` 部分说明

`ai_base.h` 中的`AIBase` 是实现模型推理的封装类，包括模型初始化，输入输出shape、tensor初始化、模型推理、获取输出等功能。

```cpp
/**
 * @brief AI基类，封装nncase相关操作
 * 主要封装了nncase的加载、设置输入、运行、获取输出操作，后续开发demo只需要关注模型的前处理、后处理即可
 */
class AIBase
{
public:
    /**
     * @brief AI基类构造函数，加载kmodel,并初始化kmodel输入、输出
     * @param kmodel_file kmodel文件路径
     * @param debug_mode  0（不调试）、 1（只显示时间）、2（显示所有打印信息）
     * @return None
     */
    AIBase(const char *kmodel_file,const string model_name, const int debug_mode = 1);

    /**
     * @brief AI基类析构函数
     * @return None
     */
    ~AIBase();

    /**
     * @brief 根据索引获取kmodel输入tensor
     * @param idx 输入数据指针
     * @return None
     */
    runtime_tensor get_input_tensor(size_t idx);

    void set_input_tensor(size_t idx,runtime_tensor &input_tensor);

    /**
     * @brief 推理kmodel
     * @return None
     */
    void run();

    /**
     * @brief 获取kmodel输出，结果保存在对应的类属性中
     * @return None
     */
    void get_output();

    runtime_tensor get_output_tensor(int idx);


protected:
    string model_name_;                    // 模型名字
    int debug_mode_;                       // 调试模型，0（不打印），1（打印时间），2（打印所有）
    vector<float *> p_outputs_;            // kmodel输出对应的指针列表
    vector<vector<int>> input_shapes_;     //{{N,C,H,W},{N,C,H,W}...}
    vector<vector<int>> output_shapes_;    //{{N,C,H,W},{N,C,H,W}...}} 或 {{N,C},{N,C}...}}等
private:
    /**
     * @brief 首次初始化kmodel输入，并获取输入shape
     * @return None
     */
    void set_input_init();

    /**
     * @brief 首次初始化kmodel输出，并获取输出shape
     * @return None
     */
    void set_output_init();

    interpreter kmodel_interp_;        // kmodel解释器，从kmodel文件构建，负责模型的加载、输入输出设置和推理
    vector<unsigned char> kmodel_vec_; // 通过读取kmodel文件得到整个kmodel数据，用于传给kmodel解释器加载kmodel
};
```

在上述封装结构中，我们在应用开发时可能用到的主要是输入输出`tensor`的`shape`，这一部分可以在`input_shapes_`和`output_shapes_`中获取，输出`tensor`的数据指针可以从`p_outputs_`中获取，比如想要得到模型第一个输出的指针：

```cpp
float *output0 = p_outputs_[0];
```

#### 任务场景头文件和实现文件

`face_detection.h` 和 `face_detection.cc` 是**用户在二次开发时需要自行实现的核心文件**。

在实际项目中，你可以根据自己的应用场景，将文件命名为：

```bash
***.h  
***.cc
```

例如：`person_det.h`、`helmet_detect.cc`、`gesture_recog.h` 等。在这两个文件中，你需要实现一个**任务场景类（Task Class）**，该类必须：

```cpp
class YourTask : public AIBase
```

也就是说 —— **继承 AIBase，并完成具体任务逻辑**。

这个类主要负责 4 件事：

| 模块                    | 是否必须自己写 | 作用              |
| --------------------- | ------- | --------------- |
| **前处理 (Preprocess)**  | ✅必须实现   | 把输入图像转换为模型需要的格式 |
| **模型推理 (Inference)**  |  ✅直接调用AIBase中的接口   | 已由 AIBase 封装    |
| **后处理 (Postprocess)** | ✅ 必须实现  | 把模型输出转成可理解的结果   |
| **结果绘制 (Draw)**       | ✅ 必须实现  | 把结果画到图像上        |

这里假设应用场景类的头文件和实现为`myapp.h`和`myapp.cc`，其中`myapp.h`的结构可以仿照`face_detection.h`编写：

```cpp
#ifndef _MYAPP_H
#define _MYAPP_H

#include <iostream>
#include <vector>
#include "ai_utils.h"
#include "ai_base.h"

using std::vector;


/**
 * @brief 后处理过程中使用的自定义数据结构，比如检测框就需要包含坐标xywh、分类索引以及置信度，这里按需定义
 */
typedef struct ExampleResults
{
    //这里需要按需定义使用的数据结构
} ExampleResults;

/**
 * @brief 待开发应用类,继承AIBase
 * 主要封装基于具体应用场景的对于每一帧图片，从预处理、运行到后处理给出结果的过程
 */
class MyApp : public AIBase
{
public:
    /**
     * @brief 视频流推理，MyApp构造函数，加载kmodel,并初始化kmodel输入、输出和应用使用的其他参数比如阈值等，并配置对应的预处理方法
     * @param kmodel_file kmodel文件路径
     * @param other_params 其他参数，比如各种阈值
     * @param image_size   摄像头AI通道图像一帧输入shape
     * @param debug_mode  0（不调试）、 1（只显示时间）、2（显示所有打印信息）
     * @return None
     */
    MyApp(char *kmodel_file, other_params, FrameCHWSize image_size, int debug_mode);

    /**
     * @brief MyApp析构函数
     * @return None
     */
    ~MyApp();

    /**
     * @brief 预处理
     * @param input_tensor 输入张量
     * @return None
     */
    void pre_process(runtime_tensor &input_tensor);

    /**
     * @brief kmodel推理
     * @return None
     */
    void inference();

    /**
     * @brief kmodel推理结果后处理，使用传入的image_size，将坐标等信息复原到原图分辨率，并将结果存入results
     * @param image_size  输入图片的shape
     * @param results 后处理结果存储容器
     * @return None
     */
    void post_process(FrameCHWSize image_size,vector<ExampleReults> &results);

     /**
     * @brief 绘制结果
     * @param draw_frame  待绘制结果的透明图像（视频OSD）或者原图（单图推理），类型为cv::Mat
     * @param results     后处理结果
     * @return None
     */
    void draw_result(cv::Mat& draw_frame,vector<ExampleReults>& results);


    std::unique_ptr<ai2d_builder> ai2d_builder_; // ai2d构建器
    runtime_tensor ai2d_out_tensor_;             // ai2d输出tensor
    FrameCHWSize image_size_;                    // 输入图片的shape
    FrameCHWSize input_size_;                    // 模型输入的shape

    //这里可以定义其他当前任务场景使用的成员变量,比如分类图纸
    // ***
};

#endif
```

上述定义的接口需要在`myapp.cc`中做具体实现，此处不再赘述。您可以参考`src/rtsmart/examples/ai/face_detection/src/face_detection.cc`中的代码仿写。

##### `main.cc`文件的修改

- **流程概述**

`main.cc`中是整个任务的逻辑，包括从UVC摄像头获取一帧数据、创建tensor、调用应用类的前处理、推理、后处理、绘制结果等步骤实现完整处理一帧数据的过程。`main.cc`中视频推理的代码如下所示，您需要根据自身的场景仿写这部分的代码，这里给出伪代码，具体介绍见注释：

```cpp
FrameCHWSize image_size={AI_FRAME_CHANNEL,AI_FRAME_HEIGHT, AI_FRAME_WIDTH};
// 创建一个空的runtime_tensor对象，用于存储输入数据
dims_t in_shape { 1, AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH };
runtime_tensor input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8,in_shape, hrt::pool_shared).expect("cannot create input tensor");
auto input_buf = input_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();

// 创建一个UVC_PipeLine对象，用于处理视频流
UVC_PipeLine pl(debug_mode);
// 初始化PipeLine对象
pl.Create();
// 创建一个DumpRes对象，用于存储帧数据
DumpRes dump_res;
// 初始化任务场景类实例，并初始化后处理结果存储容器
MyApp my_app(argv[1], atof(argv[2]),atof(argv[3]), image_size, atoi(argv[5]));
vector<ExampleResults> results;

std::vector<uint8_t> chw_vec;
std::vector<cv::Mat> rgbChannels(3);
cv::Mat ori_img;
int ret=0;
// 进如while循环，不断地dump图片
while (!isp_stop)
{
    // 创建一个ScopedTiming对象，用于计算总时间
    ScopedTiming st("total time", 1);
    // 从PipeLine中获取一帧数据，并创建tensor
    ret=pl.GetFrame(dump_res);
    if(ret){
        printf("GetFrame fail\n");
        continue;
    }
    {
        ScopedTiming st("create tensor", debug_mode);
        // 获取当前帧的图像帧虚拟地址。并在此基础上创建cv::Mat对象ori_img
        void* vaddr=reinterpret_cast<void*>(dump_res.virt_addr);
        ori_img = cv::Mat(image_size.height, image_size.width, CV_8UC3, vaddr);
        // 将ori_img从hwc格式转换为chw格式，存储在chw_vec中
        chw_vec.clear();
        rgbChannels.clear();
        cv::split(ori_img, rgbChannels);
        for (auto i = 0; i < 3; i++)
        {
            std::vector<uint8_t> data = std::vector<uint8_t>(rgbChannels[i].reshape(1, 1));
            chw_vec.insert(chw_vec.end(), data.begin(), data.end());
        }
        memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
        hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");
    }
    // usleep(30000);
    results.clear();
    //前处理，推理，后处理
    my_app.pre_process(input_tensor);
    my_app.inference();
    my_app.post_process(image_size,results);
    //这里和MIPI摄像头不同的是直接在原图上绘制，而不是在透明图像上绘制
    my_app.draw_result(ori_img,results);
    // 释放帧数据
    pl.ReleaseFrame(dump_res);
}
pl.Destroy();
```

通过单独开一个线程运行视频流推理过程，如果用户输入`q`，将变量`isp_stop`置为`True`，实现退出功能。

#### 构建文件`CMakeLists.txt`和编译脚本`build_app.sh`

对于源码目录中的`src/CMakeLists.txt`，需要修改添加需要编译的子目录，这里将源码拆分成了两个`CMakeLists.txt`，也可以合成一个，对这部分不熟悉的用户可以忽略：

```cmake
add_subdirectory(src) 
```

对于人脸检测任务子目录内的 `uvc_face_detection/src/CMakeLists.txt`，需要修改待编译的文件和生成的可执行文件elf名称：

```cmake
set(src main.cc face_detection.cc anchors_320.cc anchors_640.cc ai_base.cc ai_utils.cc uvc_pipeline.cc)
set(bin uvc_face_detection.elf)
```

编译脚本文件`uvc_face_detection/build_app.h`定义了编译使用的环境变量，同时需要修改elf文件拷贝路径：

```shell
# 将生成的elf和kmodel等文件拷贝到k230_bin目录
collect_outputs() {
    local elf_file="${BUILD_DIR}/bin/uvc_face_detection.elf"

    if [ -f "${elf_file}" ]; then
        echo "[INFO] Collecting ELF and utility files to ${K230_BIN_DIR}..."
        cp -u "${elf_file}" "${K230_BIN_DIR}/"
        cp -u utils/* "${K230_BIN_DIR}/" 2>/dev/null || true
    else
        echo "[WARN] ELF file not found: ${elf_file}"
    fi
}
```

### 编译代码

#### 切换开发板并编译应用

回到 `RTOS` 根目录下，查看支持的开发板：

```shell
make list-def
```

切换使用的开发板并编译，切换您使用的开发板：

```shell
make ***_defconfig

make -j
```

执行结束后，在`output`目录下会生成编译的镜像。我们希望用户可以将应用代码放到`src/rtsmart/examples/ai`目录下，您可以参照该目录下的`uvc_face_detection`实现。

- **编译方法一**

上面章节讲述的代码修改完成后，进入到`build_app.sh`的同级目录下，执行：

```bash
build_app.sh
```

脚本执行完成后，编译中间产物位于`build`目录下，部署汇总文件位于`k230_bin`目录下。

- **编译方法二**

在`RTOS SDK`根目录下执行`make menuconfig`，选择`RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build UVC+AI Programs`，保存并退出。如下图：

![rtos_uvc_facedet_menuconfig](https://www.kendryte.com/api/post/attachment?id=842)

因为附带提供了`Makefile文件`，直接执行

```bash
make -j
```

这样部署汇总文件会在编译过程中直接编译到固件中的`/sdcard/app/examples/ai/uvc_face_detection`目录下。也可以**直接进入到对应的目录下**执行：

```bash
make -j
```

该命令也可实现编译，编译产物将生成在`k230_bin` 目录下。编译过程实现了增量编译。

### 开发板部署

烧录固件上电，固件烧录参考文档：[how_to_flash](../../userguide/how_to_flash.md)。

在盘符处可以看到一个虚拟磁盘`CanMV`,将`k230_bin`下编译的elf文件、kmodel文件以及其他使用的文件比如测试图片等拷贝到`CanMV/sdcard`目录下。

然后使用串口工具连接开发板，在命令行执行`uvc_face_detect_isp.sh`，注意参数要和代码中的位置和类型相符。

部署效果如下图所示：

![uvc_deploy_res](https://www.kendryte.com/api/post/attachment?id=843)
