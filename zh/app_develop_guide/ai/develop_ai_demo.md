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
│    ├── anchors_320.cc
│    ├── anchors_640.cc
│    ├── face_detection.cc
│    ├── face_detection.h
│    ├── main.cc
│    ├── scoped_timing.hpp
│    ├── utils.cc
│    ├── utils.h
│    ├── vi_vo.h
│    └── CMakeLists.txt
├── utils
├── Makefile
├── CMakeLists.txt
└── build_app.sh
```

#### 已有代码功能

下面介绍已有的代码中不同文件的作用：

| 文件名称                    |         作用     |
|--------------------------- | -----------------|
|ai_base.h|提供模型推理过程中使用的接口|
|ai_bash.cc|提供ai_bash.h中定义的模型推理方法的接口实现|
|scoped_timing.hpp|提供计时工具，帮助开发调试|
|utils.h|提供二进制数据读取，图片保存,预处理等共用工具函数接口|
|utils.cc|提供utils.h中定义的工具函数实现|
|vi_vo.h|根据开发板类型配置摄像头、显示等底层参数|
|face_detection.h|提供具体任务场景（这里是人脸检测）的预处理、推理、后处理、结果绘制等接口|
|face_detection.cc|提供了face_detection.h定义的任务场景接口实现|
|anchors_320.cc|人脸检测任务使用到的anchors数据|
|anchors_640.cc|人脸检测任务使用到的anchors数据|
|main.cc|主函数实现，基于face_detection.h提供的接口实现具体的AI应用场景|

在开发一个AI应用时，上述文件的应该如何使用和编写呢？

- `ai_base.h`和 `ai_base.cc` 实现了模型推理过程中的 `kmodel` 初始化、模型输入输出初始化、运行和获取输出的接口，代码见文件注释；`scoped_timing.hpp` 提供了计时工具；**这几个文件一般是不需要更改的**。
- `utils.h` 和 `utils.cc` 提供了通用的工具函数，主要是数据存取和共用的预处理方法，**如果提供的方法无法满足您的需求，您可以修改这两个文件新增方法，如已满足则无需修改**。
- `vi_vo.h` 提供了不同开发板的初始化配置，现在支持 `CanMV-K230-V1.1/CanMV-K230-V3.0/01Studio-CanMV-K230/Bpi-CanMV-K230D-Zero/CanMV-K230-LCKFB` 开发板；**如果您需要增加新的开发板支持或新的屏幕支持，才需要调整该文件，否则可以保持不变**。
- `face_detection.h`、 `face_detection.cc` 和 `main.cc` 是用户在开发新的AI应用时**需要自行编写**的文件，编写参考 `src/rtsmart/examples/face_detection` 下的对应文件即可。其中任务场景的头文件和实现文件主要**实现该任务模型的输入前处理、推理（一般直接调用`ai_base.h`中的`run`方法），模型后处理部分的代码**；`main.cc` 文件需要修改模型推理部分的逻辑，包括**具体任务场景类的实例初始化，前处理、模型推理、后处理和结果绘制接口的调用**。

#### 代码开发和修改部分

##### `vi_vo.h` 配置说明

这是摄像头配置的分辨率，在这个基础上会分流给显示和AI部分，分流过程中给不同路的图像分辨率可以调整。

```cpp
#define ISP_INPUT_WIDTH (1920)
#define ISP_INPUT_HEIGHT (1080)
```

这一路是从摄像头配置图像分流给显示通道的数据，受到屏幕分辨率和横竖屏的影响配置不同。一般`hdmi 1080P`可以保持当前配置不变，即`LT9611`。还支持 `ST7701`屏幕，分辨率为480*800的竖屏，如果使用该屏幕显示，需要加90度旋转。

```cpp
#define ISP_CHN0_WIDTH  (1920)
#define ISP_CHN0_HEIGHT (1080)
```

这一路是从摄像头配置图像分流给AI通道进行模型预处理的数据，您可以按照AI的需求进行设置，这里输出是 `3*720*1280` 的 `RGB888` 格式的数据。

> **注意：**
>
> 这里需要区分AI通道的分辨率和模型输入的分辨率，模型输入的分辨率是**模型预处理之后**直接传送给模型的数据，AI通道的分辨率指的是**来自摄像头，在AI模型预处理前**的图像分辨率。预处理之后AI通道的数据才能准换成模型输入的数据。比如，摄像头AI通道的输出的分辨率是1280×720，模型要求输入为640×640，因此必须经过预处理过程才能符合要求。

```cpp
// 这是摄像头到AI一路的输出图片分辨率和通道，其格式为RGB888
#define SENSOR_CHANNEL (3)    
#define SENSOR_HEIGHT (720)  
#define SENSOR_WIDTH (1280)   
```

下面是OSD绘制结果通道配置信息，其分辨率大小需要和屏幕分辨率一致。OSD帧上没有原图，只有检测框的绘制结果。将这一路和屏幕显示一路叠加起来才是显示的效果。创建的OSD帧数据是一帧ARGB格式的透明图像，得到AI结果后在该帧上绘制检测框、关键点等信息，然后插入到显示通道中，实现两路叠加的效果显示。**为什么不在原图上绘制呢？因为模型推理需要时间，如果等待模型推理完成，再在原图上绘制，会导致帧率降低。**

```cpp
#define vicap_install_osd                   (1)
#define osd_id                              K_VO_OSD3
#define osd_width                           (1920)
#define osd_height                          (1080)
```

上述四部分可以调整不同通道的数据配置。

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
#include "utils.h"
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
     * @brief 静态图推理，MyApp构造函数，加载kmodel,并初始化kmodel输入、输出和应用使用的其他参数比如阈值等
     * @param kmodel_file kmodel文件路径
     * @param other_params 其他参数
     * @param debug_mode  0（不调试）、 1（只显示时间）、2（显示所有打印信息）
     * @return None
     */
    MyApp(const char *kmodel_file,other_params other_params, const int debug_mode = 1);

    /**
     * @brief 视频流推理，MyApp构造函数，加载kmodel,并初始化kmodel输入、输出和应用使用的其他参数比如阈值等
     * @param kmodel_file kmodel文件路径
     * @param other_params 其他参数
     * @param isp_shape   摄像头AI通道图像一帧输入shape（chw）
     * @param vaddr       摄像头AI通道获取图像对应虚拟地址
     * @param paddr       摄像头AI通道获取图像对应物理地址
     * @param debug_mode  0（不调试）、 1（只显示时间）、2（显示所有打印信息）
     * @return None
     */
    MyApp(const char *kmodel_file, other_params, FrameCHWSize isp_shape, uintptr_t vaddr, uintptr_t paddr, const int debug_mode);

    /**
     * @brief MyApp析构函数
     * @return None
     */
    ~MyApp();

    /**
     * @brief 图片预处理,使用opencv做预处理，pre_process重载
     * @param ori_img 原始图片
     * @param dst 处理后NCHW的图像数据
     * @return None
     */
    void pre_process(cv::Mat ori_img, std::vector<uint8_t> &dst);

    /**
     * @brief 图片预处理，使用ai2d做预处理，pre_process重载
     * @param ori_img 原始图片
     * @return None
     */
    void pre_process(cv::Mat ori_img);

    /**
     * @brief 视频流预处理，使用ai2d做预处理，pre_process重载
     * @return None
     */
    void pre_process();

    /**
     * @brief kmodel推理
     * @return None
     */
    void inference();

    /**
     * @brief kmodel推理结果后处理
     * @param frame_size 原始读图片宽高/摄像头给AI通道的帧宽高，用于将结果映射到到原始图像大小，比如框的位置和宽高，要从模型输入分辨率映射回原图分辨率
     * @param results 后处理结果存储容器
     * @return None
     */
    void post_process(FrameSize frame_size, vector<ExampleReults> &results);

     /**
     * @brief 绘制结果
     * @param src_img     原图cv::Mat实例/main.cc中创建的osd_frame cv::Mat实例
     * @param results     后处理结果
     * @param pic_mode    ture(原图片)，false(osd)
     * @return None
     */
    void draw_result(cv::Mat& src_img,vector<Results>& results, bool pic_mode = true);


    std::unique_ptr<ai2d_builder> ai2d_builder_; // ai2d构建器
    runtime_tensor ai2d_in_tensor_;              // ai2d输入tensor
    runtime_tensor ai2d_out_tensor_;             // ai2d输出tensor
    uintptr_t vaddr_;                            // isp的虚拟地址
    FrameCHWSize isp_shape_;                     // isp对应的地址大小

    //这里可以定义其他当前任务场景使用的成员变量
    // ***
};

#endif
```

上述定义的接口需要在`myapp.cc`中做具体实现，此处不再赘述。

##### `main.cc`文件的修改

当任务场景类编写完成后，修改`main.cc`中的内容，调用编写的任务场景类。对于从摄像头获取数据并进行推理的代码，修改如下：

```cpp

// 初始化任务场景类实例，并初始化后处理结果存储容器
MyApp my_app(argv[1], atof(argv[2]),atof(argv[3]), {SENSOR_CHANNEL, SENSOR_HEIGHT, SENSOR_WIDTH}, reinterpret_cast<uintptr_t>(vaddr), reinterpret_cast<uintptr_t>(paddr), atoi(argv[5]));
vector<ExampleResults> results;

// 进如while循环，不断地dump图片
while (!isp_stop)
{

    ScopedTiming st("total time", 1);
    {
        ScopedTiming st("read capture", atoi(argv[5]));
        // 从vivcap中读取一帧图像到dump_info
        memset(&dump_info, 0, sizeof(k_video_frame_info));
        ret = kd_mpi_vicap_dump_frame(vicap_dev, VICAP_CHN_ID_1, VICAP_DUMP_YUV, &dump_info, 1000);
        if (ret)
        {
            printf("sample_vicap...kd_mpi_vicap_dump_frame failed.\n");
            continue;
        }
        // 将dump的一帧数据拷贝到vaddr这里，MyApp的视频预处理函数会从vaddr这里拿一帧数据
        auto vbvaddr = kd_mpi_sys_mmap_cached(dump_info.v_frame.phys_addr[0], size);
        memcpy(vaddr, (void *)vbvaddr, SENSOR_HEIGHT * SENSOR_WIDTH * 3);  
        kd_mpi_sys_munmap(vbvaddr, size);
    }

    // 清空上一帧的后处理结果
    results.clear();
    // 调用任务类实例的pre_process，完成视频流帧的预处理
    my_app.pre_process();
    // 调用任务类实例的inference,完成视频流帧的模型推理
    my_app.inference();
    // 调用任务类实例的post_process，完成视频流帧推理后的后处理步骤
    my_app.post_process({SENSOR_WIDTH, SENSOR_HEIGHT}, results);

    // 构造一帧空白的osd_frame，用户绘制结果
    cv::Mat osd_frame(osd_height, osd_width, CV_8UC4, cv::Scalar(0, 0, 0, 0));

    // 根据不同开发板的屏幕情况，如果使用LT9611，直接调用draw_result绘制结果即可；
    // 如果使用ST7701屏幕，因为是一个480*800的竖屏，并且想使用其进行横向显示，因
    // 此需要先将创建的竖空图旋转成横向空图，然后在横向空图上绘制，绘制结束后在旋转成竖向空图。
    // 当前例子中，我们默认设置k230D BPi开发板，CanMV-V3开发板，CanMV立创开发板使用ST7701 480*800p屏幕显示，其他的使用HDMI显示。
    #if defined(CONFIG_BOARD_K230D_CANMV) || defined(CONFIG_BOARD_K230_CANMV_V3P0) || defined(CONFIG_BOARD_K230_CANMV_LCKFB)
    {
        ScopedTiming st("osd draw", atoi(argv[5]));
        cv::rotate(osd_frame, osd_frame, cv::ROTATE_90_COUNTERCLOCKWISE);
        fd.draw_result(osd_frame,results,false);
        cv::rotate(osd_frame, osd_frame, cv::ROTATE_90_CLOCKWISE);
    }
    #elif defined(CONFIG_BOARD_K230_CANMV_01STUDIO)
    {
        ScopedTiming st("osd draw", atoi(argv[5]));
        fd.draw_result(osd_frame,results,false);
    }
    #else
    {
        ScopedTiming st("osd draw", atoi(argv[5]));
        fd.draw_result(osd_frame,results,false);
    }
    #endif

    {
        // 将绘制结果的osd_frame的数据拷贝到pic_vaddr，然后在vo显示通道插入一帧结果，并释放dump帧
        ScopedTiming st("osd copy", atoi(argv[5]));
        memcpy(pic_vaddr, osd_frame.data, osd_width * osd_height * 4);
        kd_mpi_vo_chn_insert_frame(osd_id + 3, &vf_info); // K_VO_OSD0
        ret = kd_mpi_vicap_dump_release(vicap_dev, VICAP_CHN_ID_1, &dump_info);
        if (ret)
        {
            printf("sample_vicap...kd_mpi_vicap_dump_release failed.\n");
        }
    }
}
```

通过单独开一个线程运行视频流推理过程，如果用户输入`q`，将变量`isp_stop`置为`True`，实现退出功能。

`main.cc` 中存在图片推理的代码，修改如下：

```cpp

//读取一张图片，并获取图片的宽高
cv::Mat ori_img = cv::imread(argv[4]);
int ori_w = ori_img.cols;
int ori_h = ori_img.rows;

//初始化MyApp实例
MyApp my_app(argv[1], atof(argv[2]),atof(argv[3]), atoi(argv[5]));
//调用预处理方法pre_process，对读入的图片进行预处理
my_app.pre_process(ori_img);
//调用inference方法，对读入的图片进行模型推理
my_app.inference();
// 初始化后处理结果容器
vector<ExampleResults> results;
//调用post_process方法，对模型推理输出进行后处理
my_app.post_process({ori_w, ori_h}, results);
// 将后处理的结果绘制在原图上
my_app.draw_result(ori_img,results);
//将原图保存为图片
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

任务子目录内的 `face_detection/face_detection/CMakeLists.txt`，需要修改待编译的文件和生成的可执行文件elf名称：

```cmake
set(src main.cc utils.cc ai_base.cc face_detection.cc anchors_320.cc anchors_640.cc)
set(bin face_detection.elf)
```

任务目录中的`face_detection/CMakeLists.txt`，需要修改添加的子目录：

```cmake
add_subdirectory(face_detection) 
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
make list_def
```

切换使用的开发板并编译，这里以01studio开发板为例：

```shell
make k230_canmv_01studio_defconfig
make
```

执行结束后，在`output`目录下会生成编译的镜像。

上述代码修改完成后，进入到`build_app.sh`的同级目录下，执行`build_app.sh`脚本，编译产物将生成在`k230_bin` 目录下。

### 开发板部署

使用`rufus`将生成的镜像烧录到TF卡，然后将`k230_bin`下编译的elf文件、kmodel文件以及其他使用的文件拷贝到TF卡上，然后使用串口工具连接开发板，使用命令行启动程序。

### 调试指南

#### 打印模型输入输出shape是否合理

通过打印输出`ai_base.h`中的`AIBase`类的成员变量`input_shapes_`和`output_shapes_`查看输入输出的维度是否正确。

#### 通过dump原始数据查看数据

`utils.h` 中提供了`dump_binary_file`、`dump_binary_file`和`dump_color_image`三个接口，用于dump二进制文件、灰度图和彩图，通过dump得到的图片查看数据是否符合要求。比如`BGR`和`RGB`数据是不同的。

#### 通过打印定位运行bug的具体位置

在代码中添加`std::cout`语句，重复编译，查看报错位置。

#### 添加时间统计工具查看异常

对于整体运行时间明显异常的demo，可以添加打印时间的语句，查看模块运行耗时异常。源码中提供了`scoped_timing.hpp` 工具用于时间统计。示例代码如下：

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

![cat_info](https://developer.canaan-creative.com/api/post/attachment?id=512)

比如对于mmz内存可以在开发板串口处通过如下命令查看：

```shell
cat /proc/media-mem
```

返回结果如下图所示：

![cat_info](https://developer.canaan-creative.com/api/post/attachment?id=513)

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

![list_page](https://developer.canaan-creative.com/api/post/attachment?id=514)

数据中显示的是剩余页数、使用页数和最大使用页数，数据是以16进制的形式显示，每页的大小为4KB。通过将`free pages`和`used pages`的内存相加可以获得最大可用内存。

#### 模型的效果不满足要求

如果模型效果不满足您的要求，可以从以下四个方面进行调优：

- 调整模型的参数，比如置信度阈值、NMS阈值等；
- 调整模型的输入分辨率，确认前处理的合理性，比如将分辨率从`320*320`调整到`640*640`;
- 调整模型转换的量化方式，参考文档：[量化参数](./nncase.md#422-ptqtensoroptions) 中的`calibrate_method` 、`quant_type`和`w_quant_type`。比如，将`w_quant_type`改为`int6`;
- 更换更加合理的模型，如果当前模型不满足需求，可以更换当前任务的其他模型尝试;
