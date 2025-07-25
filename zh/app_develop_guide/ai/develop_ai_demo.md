# 如何开发开发一个 AI Demo

## 概述

`ai_poc` 提供了各式各样的 AI 应用，那么我们如何开发一个自己的 AI 应用并在 k230 上运行呢？ 本文档将以人脸检测为例介绍如何通过已有结构开发一个应用。

## 开发步骤

### 转换kmodel

首先是要有一个`kmodel`，对于人脸检测我们就使用 `src/rtsmart/examples/face_detection` 中 `utils` 目录下的 `kmodel` 模型。如果你想自己训练模型，可以参考开源资料，训练得到`pt/pth`模型，然后将模型转换成`onnx/tflite`模型/，然后再将模型转换成`kmodel`。 `kmodel`转换部分请参考文档：[nncase_compile.md](../../api_reference/nncase/nncase_compile.md)。nncase官方链接：[nncase github](https://github.com/kendryte/nncase) 或 [nncase gitee](https://gitee.com/kendryte/nncase) 。

### 编写部署代码

然后您需要使用 `kpu runtime API` 和 `ai2d runtime API` 编写部署在 K230 开发板上运行的代码。这里介绍这部分的开发步骤。

#### 已有代码结构

下面是已有的代码结构：

```shell
face_detection
├── cmake
├── face_detection
│    ├── ai_base.cc
│    ├── ai_base.h
│    ├── ai_utils.cc
│    ├── ai_utils.h
│    ├── anchors_320.cc
│    ├── anchors_640.cc
│    ├── face_detection.cc
│    ├── face_detection.h
│    ├── main.cc
│    ├── scoped_timing.h
│    ├── setting.h
│    ├── video_pipeline.cc
│    ├── video_pipeline.h
│    └── CMakeLists.txt
├── utils
├── CMakeLists.txt
└── build_app.sh
```

#### 已有代码功能

下面介绍已有的代码中不同文件的作用：

| 文件名称                    |         作用     |
|--------------------------- | -----------------|
|ai_base.h|提供模型推理过程中使用的接口|
|ai_bash.cc|提供ai_bash.h中定义的模型推理方法的接口实现|
|ai_utils.h|提供共用的工具函数接口|
|ai_utils.cc|提供ai_utils.h中定义的工具函数实现|
|scoped_timing.h|提供计时工具，帮助开发调试|
|setting.h|提供配置参数的接口，实现显示设备参数配置和AI推理图像分辨率的配置|
|video_pipeline.h|提供单摄双通道开发流程的接口，包括摄像头、显示设备、OSD层叠加的初始化和dump一帧AI推理图像等|
|video_pipeline.cc|提供video_pipeline.h中定义的视频处理接口实现|
|face_detection.h|提供具体任务场景（这里是人脸检测）的预处理、推理、后处理、结果绘制等接口|
|face_detection.cc|提供了face_detection.h定义的任务场景接口实现|
|anchors_320.cc|人脸检测任务使用到的anchors数据|
|anchors_640.cc|人脸检测任务使用到的anchors数据|
|main.cc|主函数实现，基于face_detection.h提供的接口实现具体的AI应用场景|

在开发一个AI应用时，上述文件的应该如何使用和编写呢？

- `ai_base.h`和 `ai_base.cc` 实现了模型推理过程中的 `kmodel` 初始化、模型输入输出初始化、运行和获取输出的接口，代码见文件注释；`scoped_timing.h` 提供了计时工具；**这几个文件一般是不需要更改的**。
- `ai_utils.h` 和 `ai_utils.cc` 提供了通用的工具函数，主要是数据存取和共用的预处理方法，**如果提供的方法无法满足您的需求，您可以修改这两个文件新增方法，如已满足则无需修改**。
- `setting.h`、`video_pipeline.h`和`video_pipeline.cc` 实现了摄像头、显示设备和OSD等初始化配置，AI推理帧获取和OSD显示叠加方法，现在支持`LT9611 HDMI 1920*1080`和`ST7701 LCD 800*480`两种显示模式；**如果您需要增加新的屏幕支持，才需要调整该文件，否则可以保持不变**。
- `face_detection.h`、 `face_detection.cc` 和 `main.cc` 是用户在开发新的AI应用时**需要自行编写**的文件，编写参考 `src/rtsmart/examples/face_detection` 下的对应文件即可。其中任务场景的头文件和实现文件主要**实现该任务模型的输入前处理、推理（一般直接调用`ai_base.h`中的`run`方法），模型后处理部分的代码**；`main.cc` 文件需要修改模型推理部分的逻辑，包括**具体任务场景类的实例初始化，前处理、模型推理、后处理和结果绘制接口的调用**。

#### 代码开发和修改部分

##### 开发逻辑

`ai_demo` 的基本开发结构采用了**单摄像头双通道处理**的方式。其核心思路是将摄像头采集到的图像分为两路处理：

- **一路图像**直接绑定到屏幕进行显示，以保证画面能够**实时、低延迟地呈现**；
- **另一路图像**则用于**AI 模型推理**，即将图像转换为 tensor，送入模型进行处理，得到检测或识别的结果。

推理完成后，程序会将这些结果绘制到一个**透明图层（OSD）**上，并与实时显示的那一路图像**叠加显示**。最终，用户在屏幕上看到的就是**融合了原始图像与 AI 识别结果的效果图**。

我们之所以采用这种“双通道处理 + 图层叠加”的方式，是为了解决性能瓶颈问题。
如果采用传统的流程：

```shell
获取一帧图像 → 预处理 → 创建 tensor → 模型推理 → 后处理 → 在图像上绘制结果 → 显示
```

如果**模型推理本身耗时较长**，整个流程会导致图像卡顿，尤其在使用复杂模型或处理复杂任务时尤为明显，体验会大打折扣。

因此，我们将显示与 AI 推理分离：**实时显示优先，推理结果异步绘制并叠加**，从而在保证画面流畅的同时，又能实时呈现 AI 分析的结果。

如下图所示，为该双通道处理逻辑的流程图：

![2_chn_process](https://www.kendryte.com/api/post/attachment?id=614)

##### `setting.h` 配置说明

`setting.h`中配置的宏定义参数主要用于设置摄像头出图、屏幕显示、OSD层、获取AI推理图像的分辨率等。

|宏定义参数|说明|
|:-:|:-:|
|`ISP_WIDTH`|ISP输出宽度|
|`ISP_HEIGHT`|ISP输出高度|
|`DISPLAY_MODE`|显示模式，0为1920×1080 LT9611，1为800×480 ST7701|
|`DISPLAY_WIDTH`|显示屏幕宽度|
|`DISPLAY_HEIGHT`|显示屏幕高度|
|`AI_FRAME_WIDTH`|AI推理帧宽度|
|`AI_FRAME_HEIGHT`|AI推理帧高度|
|`AI_FRAME_CHANNEL`|AI推理帧通道数|
|`USE_OSD`|是否使用OSD，0为不使用，1为使用|
|`OSD_WIDTH`|OSD图层宽度,用于显示AI推理结果|
|`OSD_HEIGHT`|OSD图层高度,用于显示AI推理结果|
|`OSD_CHANNEL`|OSD图层通道数|

下面进行详细介绍：

```cpp
#define ISP_WIDTH 1920
#define ISP_HEIGHT 1080
```

这是摄像头配置的分辨率，在这个基础上会分流给显示和AI两个通道（单摄双通道），分流过程中给不同路的图像格式和分辨率可以调整。

```cpp
#define DISPLAY_MODE 1    //显示模式，0为1920×1080 LT9611，1为800×480 ST7701
#define DISPLAY_WIDTH 800
#define DISPLAY_HEIGHT 480
#define DISPLAY_ROTATE 1  // 旋转，0为不旋转，1为旋转90度
```

这一路是从摄像头配置图像分流给显示通道的数据，受到屏幕分辨率和横竖屏的影响配置不同。一般`hdmi 1080P`可以保持当前配置不变，即`LT9611`。还支持 `ST7701`屏幕，分辨率为`800*480`。它本质是`480*800`的竖屏，显示时需要实现90度旋转，现在已经将旋转功能封装在了`video_pipeline.cc`中了，不关心的用户可以忽略该功能。

```cpp
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 360
#define AI_FRAME_CHANNEL 3
```

这一路是从摄像头配置图像分流给AI通道进行模型预处理的数据，您可以按照AI的需求进行设置，这里输出是 `3*360*640` 的 `RGB888` 格式的数据。数据排布为`CHW`，需要满足模型的输入。

> **注意：**
>
> 这里需要区分AI通道的分辨率和模型输入的分辨率，模型输入的分辨率是**模型预处理之后**直接传送给模型的数据宽高，AI通道的分辨率指的是**来自摄像头，在AI模型预处理前**的图像数据分辨率。预处理之后AI通道的数据才能准换成模型输入的数据。比如，摄像头AI通道的输出的分辨率是640×360，模型要求输入为320×320，因此必须经过预处理过程才能符合要求。

```cpp
#define USE_OSD 1
#define OSD_WIDTH 800
#define OSD_HEIGHT 480
#define OSD_CHANNEL 4
```

这是OSD绘制结果通道配置信息，其分辨率大小需要和屏幕分辨率一致。OSD帧上没有原图，只有检测框的绘制结果。将这一路和屏幕显示一路叠加起来才是显示的效果。创建的OSD帧数据是一帧ARGB格式的透明图像，得到AI结果后在该帧上绘制检测框、关键点等信息，然后插入到显示通道中，实现两路叠加的效果显示。

##### `ai_base.h` 部分说明

`ai_base.h` 中的`AIBase` 是实现模型推理的封装类，包括模型初始化，输入输出shape、tensor初始化、模型推理、获取输出等功能。

```cpp
/**
 * @brief AI基类，封装nncase相关操作，实现模型的加载，输入输出设置和推理
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

protected:
    string model_name_;                    // 模型名字
    int debug_mode_;                       // 调试模型，0（不打印），1（打印时间），2（打印所有）
    vector<float *> p_outputs_;            // kmodel输出对应的指针列表
    vector<vector<int>> input_shapes_;     //{{N,C,H,W},{N,C,H,W}...}
    vector<vector<int>> output_shapes_;    //{{N,C,H,W},{N,C,H,W}...}} 或 {{N,C},{N,C}...}}等
    vector<int> each_input_size_by_byte_;  //{0,layer1_length,layer1_length+layer2_length,...}
    vector<int> each_output_size_by_byte_; //{0,layer1_length,layer1_length+layer2_length,...}
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

##### 任务场景头文件和实现文件

`face_detection.h` 和 `face_detection.cc` 是开发过程中需要用户自己编写代码的部分，您可以使用您应用场景的文件名`***.h`和`***.cc`，在这两个文件中构造任务场景类，该类继承AIBase实现模型推理部分，用户需要自行编写前后处理和结果绘制部分。如果`utils.h`已经包含您需要的前处理方法，则您只需要编写后处理和结果绘制部分。**前处理指的是通过一些操作使得输入数据符合模型需要的输入，后处理指的是将模型计算输出的纯数据处理成任务场景需要的内容(比如检测框、类别索引、关键点坐标等)**。

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

上述定义的接口需要在`myapp.cc`中做具体实现，此处不再赘述。您可以参考`src/rtsmart/examples/face_detection/face_detection/face_detection.cc`中的代码仿写。

##### `main.cc`文件的修改

- **流程概述**

`main.cc`中是整个任务的逻辑，包括从摄像头获取一帧数据/读入一张图片、创建tensor、调用应用类的前处理、推理、后处理、绘制结果等步骤实现完整处理一帧数据的过程。该过程的流程图如下所示：

![model_inference_rtos](https://www.kendryte.com/api/post/attachment?id=642)

- **视频推理代码**

`main.cc`中视频推理的代码如下所示，您需要根据自身的场景仿写这部分的代码，具体介绍见注释：

```cpp
FrameCHWSize image_size={AI_FRAME_CHANNEL,AI_FRAME_HEIGHT, AI_FRAME_WIDTH};
// 创建一个空的Mat对象，用于存储绘制的帧
cv::Mat draw_frame(OSD_HEIGHT, OSD_WIDTH, CV_8UC4, cv::Scalar(0, 0, 0, 0));
// 创建一个空的runtime_tensor对象，用于存储输入数据
runtime_tensor input_tensor;
dims_t in_shape { 1, AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH };
// 创建一个PipeLine对象，用于处理视频流
PipeLine pl(debug_mode);
// 初始化PipeLine对象
pl.Create();
// 创建一个DumpRes对象，用于存储帧数据
DumpRes dump_res;
// 初始化任务场景类实例，并初始化后处理结果存储容器
MyApp my_app(argv[1], atof(argv[2]),atof(argv[3]), image_size, atoi(argv[5]));
vector<ExampleResults> results;

// 进如while循环，不断地dump图片
while (!isp_stop)
{
    // 创建一个ScopedTiming对象，用于计算总时间
    ScopedTiming st("total time", 1);
    // 从PipeLine中获取一帧数据，并创建tensor
    pl.GetFrame(dump_res);
    input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, { (gsl::byte *)dump_res.virt_addr, compute_size(in_shape) },false, hrt::pool_shared, dump_res.phy_addr).expect("cannot create input tensor");
    hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("sync write_back failed");
    //前处理，推理，后处理
    my_app.pre_process(input_tensor);
    my_app.inference();
    my_app.post_process(image_size,results);
    // 清空上一帧绘制的结果
    draw_frame.setTo(cv::Scalar(0, 0, 0, 0));
    my_app.draw_result(draw_frame,results);
    // 将绘制的帧插入到PipeLine的显示视频流中
    pl.InsertFrame(draw_frame.data);
    // 释放当前帧数据
    pl.ReleaseFrame();
}
pl.Destroy();
```

通过单独开一个线程运行视频流推理过程，如果用户输入`q`，将变量`isp_stop`置为`True`，实现退出功能。

- **图片推理代码**

`main.cc` 中存在图片推理的代码，修改如下：

```cpp

int debug_mode = atoi(argv[5]);
// 读取图片
cv::Mat ori_img = cv::imread(argv[4]);
//使用图片初始化image_size
FrameCHWSize image_size={ori_img.channels(),ori_img.rows,ori_img.cols};
// 创建一个空的向量，用于存储chw图像数据,将读入的hwc数据转换成chw数据
std::vector<uint8_t> chw_vec;
std::vector<cv::Mat> bgrChannels(3);
cv::split(ori_img, bgrChannels);
for (auto i = 2; i > -1; i--)
{
    std::vector<uint8_t> data = std::vector<uint8_t>(bgrChannels[i].reshape(1, 1));
    chw_vec.insert(chw_vec.end(), data.begin(), data.end());
}
// 创建输入tensor
dims_t in_shape { 1, 3, ori_img.rows, ori_img.cols };
runtime_tensor input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, hrt::pool_shared).expect("cannot create input tensor");
auto input_buf = input_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

// 初始化任务场景类实例，并初始化后处理结果存储容器
MyApp my_app(argv[1], atof(argv[2]),atof(argv[3]), image_size, atoi(argv[5]));
vector<ExampleResults> results;
//前处理，推理，后处理
my_app.pre_process(input_tensor);
my_app.inference();
my_app.post_process(image_size,results);
// 直接在原图上绘制
my_app.draw_result(ori_img,results);
cv::imwrite("result.jpg", ori_img);
```

修改推理逻辑时，注意也要修改传入参数说明和传入参数个数校验部分：

```cpp
void print_usage(const char *name)
{
    cout << "Usage: " << name << "<kmodel_det> <obj_thres> <nms_thres> <input_mode> <debug_mode>" << endl
         << "Options:" << endl
         << "  kmodel_det      人脸检测kmodel路径\n"
         << "  other_params    其它参数，如阈值\n"
         << "  input_mode      本地图片(图片路径)/ 摄像头(None) \n"
         << "  debug_mode      是否需要调试，0、1、2分别表示不调试、简单调试、详细调试\n"
         << "\n"
         << endl;
}
```

```cpp
// 传入参数个数校验
std::cout << "case " << argv[0] << " built at " << __DATE__ << " " << __TIME__ << std::endl;
if (argc != 5)
{
    print_usage(argv[0]);
    return -1;
}
```

##### 构建文件`CMakeLists.txt`和编译脚本`build_app.sh`

比如对于人脸检测任务目录中的`face_detection/CMakeLists.txt`，需要修改添加需要编译的子目录，这里将源码拆分成了两个CMakeLists.txt，也可以合成一个，对这部分不熟悉的用户可以忽略：

```cmake
add_subdirectory(face_detection) 
```

对于人脸检测任务子目录内的 `face_detection/face_detection/CMakeLists.txt`，需要修改待编译的文件和生成的可执行文件elf名称：

```cmake
set(src main.cc face_detection.cc anchors_320.cc anchors_640.cc ai_base.cc ai_utils.cc video_pipeline.cc)
set(bin face_detection.elf)
```

编译脚本文件`face_detection/build_app.h`需要修改elf文件拷贝路径：

```shell
# 将生成的elf和kmodel等文件拷贝到k230_bin目录
if [ -f out/bin/face_detection.elf ]; then
      cp out/bin/face_detection.elf ${k230_bin}
      cp -p utils/* ${k230_bin}
fi
```

### 编译代码

回到 `RTOS` 根目录下，查看支持的开发板：

```shell
make list-def
```

切换使用的开发板并编译，切换您使用的开发板：

```shell
make ***_defconfig

make
```

执行结束后，在`output`目录下会生成编译的镜像。

我们希望用户可以将应用代码放到`src/rtsmart/examples`目录下，您可以参照该目录下的`face_detection`实现。上面章节讲述的代码修改完成后，进入到`build_app.sh`的同级目录下，执行`build_app.sh`脚本，编译产物将生成在`k230_bin` 目录下。

### 开发板部署

使用`rufus`将生成的镜像烧录到TF卡，然后上电，在盘符处可以看到一个虚拟磁盘`CanMV`,将`k230_bin`下编译的elf文件、kmodel文件以及其他使用的文件比如测试图片等拷贝到`CanMV/sdcard`目录下，然后使用串口工具连接开发板，在命令行启动程序，注意参数要和代码中的位置和类型相符。

### 调试指南

#### 打印模型输入输出shape是否合理

通过打印输出`ai_base.h`中的`AIBase`类的成员变量`input_shapes_`和`output_shapes_`查看输入输出的维度是否正确。

#### 通过dump原始数据查看数据

`ai_utils.h` 中提供了`dump_binary_file`、`dump_binary_file`和`dump_color_image`三个接口，用于dump二进制文件、灰度图和彩图，通过dump得到的图片查看数据是否符合要求。比如`BGR`和`RGB`数据是不同的。

#### 通过打印定位运行bug的具体位置

在代码中添加`std::cout`语句或日志机制，重复编译上板运行，查看报错位置。

#### 添加时间统计工具查看异常

对于整体运行时间明显异常的demo，可以添加打印时间的语句，查看模块运行耗时异常。源码中提供了`scoped_timing.h` 工具用于时间统计。示例代码如下：

```cpp
{
    ScopedTiming st("test", 1);
    /*
    * 这里写测试代码
    */
}
```

#### 对于内存问题可以使用cat命令查看占用情况

在开发板RTOS下的`/proc`下存在内存占用信息查看文件，支持查看的模块如下图：

![cat_info](https://www.kendryte.com/api/post/attachment?id=512)

比如对于多媒体部分内存可以在开发板串口处通过如下命令查看：

```shell
cat /proc/media-mem
```

返回结果如下图所示：

![cat_info](https://www.kendryte.com/api/post/attachment?id=513)

其他模块也可以使用`cat` 命令查看，比如：

```shell
cat /proc/umap/vicap

cat /proc/umap/vb

cat /proc/umap/vo
```

对于系统内存的占用情况，可以使用`list_page`命令查看：

```shell
list_page
```

命令执行结果如下图所示：

![list_page](https://www.kendryte.com/api/post/attachment?id=514)

数据中显示的是剩余页数、使用页数和最大使用页数，数据是以16进制的形式显示，每页的大小为4KB。通过将`free pages`和`used pages`的内存相加可以获得最大可用内存。

#### 模型的效果不满足要求

如果模型效果不满足您的要求，可以从以下四个方面进行调优：

- 调整模型的参数，比如置信度阈值、NMS阈值等；
- 调整模型的输入分辨率，确认前处理的合理性，比如将分辨率从`320*320`调整到`640*640`;
- 调整模型转换的量化方式，参考文档：[量化参数](./nncase.md#422-ptqtensoroptions) 中的`calibrate_method` 、`quant_type`和`w_quant_type`。比如，将`w_quant_type`改为`int6`;
- 更换更加合理的模型，如果当前模型不满足需求，可以更换当前任务的其他模型尝试;
