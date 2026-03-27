# 三摄AI应用开发指南

## 概述

三路摄像头AI应用是指在K230开发板上同时使用三路摄像头进行AI推理，实现多路视频流的处理和分析。本示例选择三路GC2093摄像头，分别连接到K230开发板的三个MIPI摄像头接口上。实现一路人脸检测，一路手掌检测，一路YOLO 80类别检测。

## 开发指南

### 涉及模块和任务流程

- **涉及的模块**：

1. **vicap（video input capture）模块**：配置摄像头(Sensor)设备属性和各通道属性，包括分辨率、帧率、数据格式等。实现将摄像头的数据以绑定的形式送到屏幕显示，并获取用于AI推理的摄像头帧数据。
1. **vo （video output）模块**：配置显示设备(Display)和各显示层属性，包括位置、分辨率、帧率、数据格式等。实现实时显示摄像头或其他模块送来的显示帧。包括video层和osd层，分别负责显示视频帧和叠加的文本信息。video层只支持yuv格式，osd层只支持rgb格式。
1. **kpu模块**：负责加载`kmodel`、配置`kmodel`的输入输出`tensor`，并完成模型推理。
1. **ai2d模块**：负责模型输入图像的预处理，支持五种定义的预处理放大，使用方法见文档[usage_ai2d](./usage_ai2d.md)。

- **任务流程**：

三路摄像头被Pipeline管理，通过传入的sensor id来区分不同的摄像头获取供AI推理的帧数据。每个摄像头两路，一路绑定到vo模块的video层用于实时显示原图像，一路送给AI模型进行推理，推理结果通过osd层显示。本示例共占用三个video层，三个osd层实现分屏叠加显示。

上述流程如下图所示：

![triple_camera_ai_pipeline](https://www.kendryte.com/api/post/attachment?id=854)

### 代码结构介绍

示例代码位于`src/rtsmart/examples/ai/triple_camera_ai`目录下。本示例对三摄配置做了简化封装，方便用户仿写。下面是已有的代码结构：

```shell
triple_camera_ai
├── cmake
├── src
│    ├── ai_base.cc         # 模型推理封装实现
│    ├── ai_base.h          # 模型推理头文件
│    ├── ai_utils.cc        # 模型推理工具方法
│    ├── ai_utils.h         # 模型推理工具方法头文件
│    ├── anchors_320.cc     # 320输入人脸检测模型使用的anchor
│    ├── face_detection.cc  # 人脸检测任务场景实现，包括适应该场景模型的前处理、推理、后处理、结果绘制等
│    ├── hand_detection.cc  # 手掌检测任务场景实现，包括适应该场景模型的前处理、推理、后处理、结果绘制等
│    ├── hand_detection.h   # 手掌检测任务场景头文件
│    ├── yolov8_detect.cc   # YOLO 80类别检测任务场景实现，包括适应该场景模型的前处理、推理、后处理、结果绘制等
│    ├── yolov8_detect.h    # YOLO 80类别检测任务场景头文件
│    ├── main.cc            # 主函数实现，基于三个任务头文件提供的接口实现具体的AI应用场景
│    ├── scoped_timing.h    # 提供计时工具，帮助开发调试
│    ├── setting.h          # 提供配置参数的宏定义，实现显示设备配置和AI推理图像分辨率的配置
│    ├── video_pipeline.cc  # 三路摄像头配置流程实现，包括摄像头初始化、显示设备初始化、dump一帧AI推理图像、插入一帧显示图像等
│    ├── video_pipeline.h   # 三路摄像头配置流程头文件
│    └── CMakeLists.txt     # 三路摄像头配置流程的CMakeLists.txt
├── utils                   # 可以直接使用的kmodel和脚本
├── CMakeLists.txt          # CMakeLists.txt，用于构建整个应用（方式一）
├── build_app.sh            # 编译脚本
└── Makefile                # Makefile，用于构建整个应用（方式二）
```

### 代码功能介绍

下面介绍已有的代码中不同文件的作用：

| 文件名称                    |         作用     |
|--------------------------- | -----------------|
|ai_base.h|提供模型推理过程中使用的接口|
|ai_bash.cc|提供ai_bash.h中定义的模型推理方法的接口实现|
|ai_utils.h|提供共用的工具函数接口|
|ai_utils.cc|提供ai_utils.h中定义的工具函数实现|
|scoped_timing.h|提供计时工具，帮助开发调试|
|setting.h|提供配置参数的接口，实现显示设备参数配置和AI推理图像分辨率的配置|
|video_pipeline.h|提供三路摄像头配置流程的接口，包括摄像头初始化、显示设备初始化、dump一帧AI推理图像、插入一帧显示图像等|
|video_pipeline.cc|提供video_pipeline.h中定义的三路摄像头配置流程接口实现|
|face_detection.h|提供具体任务场景（这里是人脸检测）的预处理、推理、后处理、结果绘制等接口|
|face_detection.cc|提供了face_detection.h定义的任务场景接口实现|
|hand_detection.h|提供具体任务场景（这里是手掌检测）的预处理、推理、后处理、结果绘制等接口|
|hand_detection.cc|提供了hand_detection.h定义的任务场景接口实现|
|yolov8_detect.h|提供具体任务场景（这里是YOLO 80类别检测）的预处理、推理、后处理、结果绘制等接口|
|yolov8_detect.cc|提供了yolov8_detect.h定义的任务场景接口实现|
|anchors_320.cc|人脸检测任务使用到的anchors数据|
|main.cc|主函数实现，基于face_detection.h、hand_detection.h和yolov8_detect.h提供的接口实现具体的AI应用场景，使用三个任务场景分别对三路摄像头捕获的图像进行人脸检测、手掌检测和YOLO 80类别检测，多线程之间KPU独占，需要添加线程同步锁|

- `ai_base.h`和 `ai_base.cc` 实现了模型推理的封装基类，实现了 `kmodel` 初始化、模型输入输出初始化、运行和获取输出的接口，代码见文件注释；`scoped_timing.h` 提供了计时工具；**这几个文件一般是不需要更改的**。

- `ai_utils.h` 和 `ai_utils.cc` 提供了通用的工具函数，主要是数据存取和共用的预处理方法，**如果提供的方法无法满足您的需求，您可以修改这两个文件新增方法，如已满足则无需修改**。

- `setting.h`、`video_pipeline.h`和`video_pipeline.cc` 实现了UVC摄像头、显示设备、解码器、noai2d格式转换、dump帧和插入显示帧等配置和操作，AI推理帧获取和OSD显示叠加方法，现在支持`LT9611 HDMI 1920*1080`和`ST7701 LCD 800*480`两种显示模式；**如果您需要增加新的屏幕支持，才需要调整该文件，否则可以保持不变**。同时如果需要添加新的摄像头通道，也需要修改此文件。

- `face_detection.h`、 `face_detection.cc`、`hand_detection.h`、`hand_detection.cc`、`yolov8_detect.h`、`yolov8_detect.cc` 和 `main.cc` 是用户在开发应用时需要着重关注的文件，编写参考 `src/rtsmart/examples/ai/triple_camera_ai` 下的对应文件即可，用户可以按照自己需要的场景替换应用任务。其中任务场景的头文件和实现文件主要**实现该任务模型的输入前处理、推理（一般直接调用`ai_base.h`中的`run`方法），模型后处理部分的代码**；`main.cc` 文件需要修改多线程模型推理部分的逻辑，包括**具体任务场景类的实例初始化，前处理、模型推理、后处理和结果绘制接口的调用**。

### 代码详解

#### `setting.h` 配置说明

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
#define DISPLAY_WIDTH 400
#define DISPLAY_HEIGHT 240
#define DISPLAY_ROTATE 1  // 旋转，0为不旋转，1为旋转90度
```

这一路是从摄像头配置图像分流给显示通道的数据，受到屏幕分辨率和横竖屏的影响配置不同。一般`hdmi 1080P`可以保持当前配置不变，即`lt9611`。还支持 `st7701`屏幕，分辨率为`800*480`。**这里因为要在屏幕上分屏显示三路摄像头的图像，因此需要将`800*480`的图像分屏显示为`400*240`**。

`st7701`本质是`480*800`的竖屏，显示时需要实现90度旋转，现在已经将旋转功能封装在了底层vo模块中了，用户可以忽略该功能，直接将其当做横屏使用。

```cpp
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 360
#define AI_FRAME_CHANNEL 3
```

这一路是从摄像头配置图像分流给AI通道进行模型预处理的数据，您可以按照AI的需求进行设置，这里输出是 `3*360*640` 的 `PIXEL_FORMAT_RGB_888_PLANAR` 格式的数据。数据排布为`CHW`，需要满足模型的输入。

> **注意：**
>
> 这里需要区分AI通道的分辨率和模型输入的分辨率:
> **AI通道的分辨率**: 来自摄像头，在AI模型**预处理前**的图像数据分辨率;
> **模型输入的分辨率**: 模型**预处理之后**直接传送给模型的数据宽高;
> 预处理之后AI通道的数据才能准换成模型输入的数据。比如，摄像头AI通道的输出的分辨率是640×360，模型要求输入为320×320，因此必须经过预处理过程才能符合要求。

```cpp
#define USE_OSD 1
#define OSD_WIDTH 400
#define OSD_HEIGHT 240
#define OSD_CHANNEL 4
```

这是OSD绘制结果通道配置信息，其分辨率大小需要和屏幕显示分辨率一致。OSD帧上没有原图，只有检测框的绘制结果。将这一路和屏幕显示一路叠加起来才是显示的效果。创建的OSD帧数据是一帧`BGRA8888`格式的透明图像，得到AI结果后在该帧上绘制检测框、关键点等信息，然后插入到显示通道中，实现两路叠加的效果显示。**在配置OSD层时，设置该层的x和y参数配置画面显示位置**。显示逻辑位置如下图所示：

![triple_camera_display](https://www.kendryte.com/api/post/attachment?id=855)

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

上述定义的接口需要在`myapp.cc`中做具体实现，此处不再赘述。

##### `main.cc`文件的修改

- **流程概述**

`main.cc`中是整个任务的逻辑，包括从指定的摄像头获取一帧数据、创建tensor、调用应用类的前处理、推理、后处理、绘制结果等步骤实现完整处理一帧数据的过程。

三摄任务需要使用多线程实现，每个线程负责一个应用任务。这里需要特别说明KPU是独占的，同一时刻只允许一个模型进行推理，所以需要添加线程锁实现资源管理。

`main.cc`中的子线程代码文档[单模型应用开发指南](./single_model_example.md)和[双模型应用开发指南](./double_model_example.md)中的实现区别不大。因为使用了多线程`PipeLine`的初始化放在主线程实现，并作为参数传递给子线程用于获取AI模型的推理数据帧和插入OSD帧。主线程代码如下所示：

```cpp
int main(int argc, char *argv[])
{
    cout << "case " << argv[0]
         << " built at " << __DATE__ << " " << __TIME__ << endl;

    if (argc != 11)
    {
        print_usage(argv[0]);
        return -1;
    }

    int debug_mode = atoi(argv[5]);

    // 1. 创建视频管线
    PipeLine pl(debug_mode);
    pl.Create();

    // 2. 摄像头模式
    std::thread t0(face_det_video_proc, std::ref(pl),argv, 0, 4);

    std::thread t1(hand_det_video_proc, std::ref(pl),argv, 1, 5);

    std::thread t2(yolov8_det_video_proc, std::ref(pl),argv, 2, 6);

    // 主线程等待退出指令
    while (getchar() != 'q')
    {
        usleep(10000);
    }

    // 通知线程退出
    face_det_isp_stop.store(true);
    t0.join();
    person_det_isp_stop.store(true);
    t1.join();
    hand_det_isp_stop.store(true);
    t2.join();
    // 3. 销毁管线
    pl.Destroy();
    cout << "exit success" << endl;
    return 0;
}
```

程序的退出通过三个线程循环变量控制：

```cpp
std::atomic<bool> face_det_isp_stop(false);
std::atomic<bool> person_det_isp_stop(false);
std::atomic<bool> hand_det_isp_stop(false);
```

当输入`q`并回车时，将三个线程循环标志变量设置为`true`，线程会退出循环并结束。

#### 构建文件`CMakeLists.txt`和编译脚本`build_app.sh`

对于源码目录中的`src/CMakeLists.txt`，需要修改添加需要编译的子目录，这里将源码拆分成了两个`CMakeLists.txt`，也可以合成一个，对这部分不熟悉的用户可以忽略：

```cmake
add_subdirectory(src) 
```

对于三摄AI应用任务子目录内的 `triple_camera_ai/src/CMakeLists.txt`，需要修改待编译的文件和生成的可执行文件elf名称：

```cmake
set(src main.cc face_detection.cc anchors_320.cc hand_detection.cc yolov8_detect.cc ai_base.cc ai_utils.cc video_pipeline.cc)
set(bin triple_cam_ai.elf)
```

编译脚本文件`triple_camera_ai/build_app.sh`定义了编译使用的环境变量，同时需要修改elf文件拷贝路径：

```shell
# 将生成的elf和kmodel等文件拷贝到k230_bin目录
collect_outputs() {
    local elf_file="${BUILD_DIR}/bin/triple_cam_ai.elf"

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

执行结束后，在`output`目录下会生成编译的镜像。

- **编译方法一**

上面章节讲述的代码修改完成后，进入到`src/rtsmart/examples/ai/triple_camera_ai`目录下，执行：

```bash
build_app.sh
```

脚本执行完成后，编译中间产物位于`build`目录下，部署汇总文件位于`k230_bin`目录下。

- **编译方法二**

在`RTOS SDK`根目录下执行`make menuconfig`，选择`RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build Triple Camera AI Programs`，保存并退出。如下图：

![rtos_triple_cam_ai_menuconfig](https://www.kendryte.com/api/post/attachment?id=856)

因为附带提供了`Makefile文件`，直接执行

```bash
make -j
```

这样部署汇总文件会在编译过程中直接编译到固件中的`/sdcard/app/examples/ai/triple_camera_ai`目录下。也可以**直接进入到对应的目录下**执行：

```bash
make -j
```

该命令也可实现编译，编译产物将生成在`k230_bin` 目录下。编译过程实现了增量编译。

### 开发板部署

烧录固件上电，固件烧录参考文档：[how_to_flash](../../userguide/how_to_flash.md)。

在盘符处可以看到一个虚拟磁盘`CanMV`,将`k230_bin`下编译的elf文件、kmodel文件以及其他使用的文件比如测试图片等拷贝到`CanMV/sdcard`目录下。

然后使用串口工具连接开发板，在命令行执行`run.sh`，注意参数要和代码中的位置和类型相符。

部署效果如下图所示：

![triple_cam_ai_deploy_res](https://www.kendryte.com/api/post/attachment?id=857)
