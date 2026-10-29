# Single-Model Application Development Guide

## Overview

`aidemo` provides a wide variety of AI applications, so how do we develop a single-model inference AI application and run it on the k230? This document will take face detection as an example for a detailed introduction.

## Development Guide

### Converting kmodel

First, you need a `kmodel`. For face detection, we use `face_detection_320.kmodel` or `face_detection_640.kmodel` in the `utils` directory under `src/rtsmart/examples/ai/face_detection`.

If you want to train the model yourself, you can refer to open-source materials to train a `pt/pth` model, then convert it to an `onnx/tflite` model/, and then convert it to a `kmodel`.

For the `kmodel` conversion part, please refer to the document: [nncase_compile.md](../../api_reference/nncase/nncase_compile.md).

nncase github official link: [nncase github](https://github.com/kendryte/nncase).
nncase gitee official link: [nncase gitee](https://gitee.com/kendryte/nncase).

### Developing Deployment Code

#### Module and Workflow Overview

After obtaining the `kmodel`, you can proceed with developing the on-board runtime code. First, we need to clarify the **involved modules** and the **scenario workflow**.

- **Involved Modules**:

1. **vicap (video input capture) module**: Configures the camera (Sensor) device properties and each channel's properties, including resolution, frame rate, data format, etc. It implements binding the camera data to the screen for display, and obtains camera frame data for AI inference.
1. **vo (video output) module**: Configures the display device (Display) and each display layer's properties, including position, resolution, frame rate, data format, etc. It implements real-time display of camera or other modules' display frames. It includes the video layer and osd layer, which are responsible for displaying video frames and overlaid text information, respectively. The video layer only supports yuv format, and the osd layer only supports rgb format.
1. **kpu module**: Responsible for loading `kmodel`, configuring the `tensor` of `kmodel`'s input and output, and completing model inference.
1. **ai2d module**: Responsible for preprocessing the model input image, supporting five defined preprocessing scaling methods. For usage, see the document [usage_ai2d](./usage_ai2d.md).

- **Scenario Workflow**:

The basic development structure of an AI single-model application adopts a **single-camera dual-channel processing** approach. Its core idea is to divide the image captured by the camera into two paths for processing:

- **One path of image** is directly bound to the screen for display, ensuring that the picture can be presented **in real-time and with low latency**;
- **The other path of image** is used for **AI model inference**, i.e., the image is converted to a tensor, fed into the model for processing, and detection or recognition results are obtained.

After inference is complete, the program draws these results onto a **transparent layer (OSD)**, which is then **overlaid on top of** the real-time display image. Finally, what the user sees on the screen is **the rendered image that combines the original image with the AI recognition results**.

The reason we adopt this "dual-channel processing + layer overlay" approach is to solve the performance bottleneck issue.
If the traditional flow is followed:

```shell
Acquire camera image → Create tensor → Input preprocessing → Model inference → Output postprocessing → Draw inference results → Screen display
```

If **the model inference itself is time-consuming**, the entire flow will cause image lag, especially when using complex models or handling complex tasks, and the experience will be significantly degraded.

Therefore, we separate display from AI inference: **display takes priority in real-time, and inference results are drawn asynchronously and overlaid**, thereby ensuring smooth video while also presenting AI analysis results in real-time.

As shown in the figure below, it is the flow chart of the single-camera dual-channel processing logic:

![2_chn_process](https://www.kendryte.com/api/post/attachment?id=614)

#### Code Structure Introduction

Taking face detection single-model inference as an example, the following is the existing code structure:

```shell
face_detection
├── cmake
├── src
│    ├── ai_base.cc         # Model inference encapsulation implementation
│    ├── ai_base.h          # Model inference header file
│    ├── ai_utils.cc        # Model inference utility methods
│    ├── ai_utils.h         # Model inference utility methods header file
│    ├── anchors_320.cc     # Anchor for 320-input face detection model
│    ├── anchors_640.cc     # Anchor for 640-input face detection model
│    ├── face_detection.cc  # Face detection task scenario implementation, including preprocessing, inference, postprocessing, and result drawing adapted to the scenario model
│    ├── face_detection.h   # Face detection task scenario header file
│    ├── main.cc            # Main function implementation, implementing specific AI application scenarios based on the interface provided by face_detection.h
│    ├── scoped_timing.h    # Provides timing utilities to help with development and debugging
│    ├── setting.h          # Provides macro definitions for configuration parameters, implementing display device configuration and AI inference image resolution configuration
│    ├── video_pipeline.cc  # Single-camera dual-channel development process implementation, including initialization of camera, display device, OSD layer overlay, dumping one frame of AI inference image, inserting one frame of OSD image, etc.
│    ├── video_pipeline.h   # Single-camera dual-channel development process header file
│    └── CMakeLists.txt     # CMakeLists.txt for single-camera dual-channel development process
├── utils                   # kmodel and scripts that can be used directly
├── CMakeLists.txt          # CMakeLists.txt for building the entire application (method 1)
├── build_app.sh            # Build script
└── Makefile                # Makefile for building the entire application (method 2)
```

#### Code Function Introduction

Taking face detection single-model inference as an example, the following introduces the role of different files in the existing code:

| File Name                  |         Role     |
|--------------------------- | -----------------|
|ai_base.h|Provides interfaces used during model inference|
|ai_bash.cc|Provides the interface implementation of the model inference methods defined in ai_bash.h|
|ai_utils.h|Provides common utility function interfaces|
|ai_utils.cc|Provides the implementation of the utility functions defined in ai_utils.h|
|scoped_timing.h|Provides timing utilities to help with development and debugging|
|setting.h|Provides interfaces for configuration parameters, implementing display device parameter configuration and AI inference image resolution configuration|
|video_pipeline.h|Provides the interface of the single-camera dual-channel development process, including initialization of camera, display device, OSD layer overlay, dumping one frame of AI inference image, etc.|
|video_pipeline.cc|Provides the implementation of the video processing interfaces defined in video_pipeline.h|
|face_detection.h|Provides the interfaces for preprocessing, inference, postprocessing, and result drawing of specific task scenarios (here, face detection)|
|face_detection.cc|Provides the implementation of the task scenario interfaces defined in face_detection.h|
|anchors_320.cc|Anchor data used for the face detection task|
|anchors_640.cc|Anchor data used for the face detection task|
|main.cc|Main function implementation, implementing specific AI application scenarios based on the interface provided by face_detection.h|

How should the above files be used and written when developing an AI application?

- `ai_base.h` and `ai_base.cc` implement the base class for model inference encapsulation, implementing the interfaces for `kmodel` initialization, model input/output initialization, running, and obtaining output. See the file comments for the code; `scoped_timing.h` provides timing utilities; **these files generally do not need to be modified**.

- `ai_utils.h` and `ai_utils.cc` provide general utility functions, mainly for data access and shared preprocessing methods. **If the provided methods cannot meet your needs, you can modify these two files to add new methods; if they are sufficient, no modification is needed**.

- `setting.h`, `video_pipeline.h`, and `video_pipeline.cc` implement the initialization configuration of the camera, display device, and OSD, as well as AI inference frame acquisition and OSD display overlay methods. They currently support `LT9611 HDMI 1920*1080` and `ST7701 LCD 800*480` two display modes; **if you need to add new screen support, you need to adjust this file; otherwise, you can leave it unchanged**.

- `face_detection.h`, `face_detection.cc`, and `main.cc` are the files that users **need to write themselves** when developing new AI applications. You can refer to the corresponding files under `src/rtsmart/examples/ai/face_detection` for writing. Among them, the task scenario header file and implementation file mainly **implement the input preprocessing, inference (generally calling the `run` method in `ai_base.h` directly), and model postprocessing code of the task model**; the `main.cc` file requires modifying the model inference logic, including **the instantiation of specific task scenario classes, and the invocation of preprocessing, model inference, postprocessing, and result drawing interfaces**.

#### Code Detailed Explanation

##### `setting.h` Configuration Description

The macro definition parameters configured in `setting.h` are mainly used to set the camera output image, screen display, OSD layer, AI inference image resolution, etc.

|Macro Definition Parameter|Description|
|:-:|:-:|
|`ISP_WIDTH`|ISP output width|
|`ISP_HEIGHT`|ISP output height|
|`DISPLAY_MODE`|Display mode, 0 for 1920×1080 LT9611, 1 for 800×480 ST7701|
|`DISPLAY_WIDTH`|Display screen width|
|`DISPLAY_HEIGHT`|Display screen height|
|`AI_FRAME_WIDTH`|AI inference frame width|
|`AI_FRAME_HEIGHT`|AI inference frame height|
|`AI_FRAME_CHANNEL`|AI inference frame channel count|
|`USE_OSD`|Whether to use OSD, 0 for not used, 1 for used|
|`OSD_WIDTH`|OSD layer width, used to display AI inference results|
|`OSD_HEIGHT`|OSD layer height, used to display AI inference results|
|`OSD_CHANNEL`|OSD layer channel count|

Detailed introduction as follows:

```cpp
#define ISP_WIDTH 1920
#define ISP_HEIGHT 1080
```

This is the resolution of the camera configuration. Based on this, the image is split into display and AI two channels (single-camera dual-channel). The image format and resolution for different paths can be adjusted during the split process.

```cpp
#define DISPLAY_MODE 1    //Display mode, 0 for 1920×1080 LT9611, 1 for 800×480 ST7701
#define DISPLAY_WIDTH 800
#define DISPLAY_HEIGHT 480
#define DISPLAY_ROTATE 1  //Rotation, 0 for not rotated, 1 for rotated 90 degrees
```

This path splits the camera configuration image to the display channel data, which is configured differently depending on the screen resolution and orientation. Generally, `hdmi 1080P` can keep the current configuration unchanged, i.e., `lt9611`. The `st7701` screen is also supported, with a resolution of `800*480`.

`st7701` is essentially a `480*800` vertical screen, and a 90-degree rotation needs to be implemented for display. The rotation function has now been encapsulated in the underlying vo module, and users can ignore this feature and use it directly as a horizontal screen.

```cpp
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 360
#define AI_FRAME_CHANNEL 3
```

This path splits the camera configuration image to the AI channel for model preprocessing data. You can set it according to AI requirements. Here, the output is `3*360*640` `PIXEL_FORMAT_RGB_888_PLANAR` format data. The data layout is `CHW`, which needs to meet the model's input.

> **Note:**
>
> Here you need to distinguish between the resolution of the AI channel and the resolution of the model input:
> **Resolution of the AI channel**: the resolution of the image data from the camera, **before** the AI model **preprocessing**;
> **Resolution of the model input**: the width and height of the data directly fed to the model **after model preprocessing**;
> The data of the AI channel can be accurately converted to the model input data only after preprocessing. For example, if the AI channel output from the camera has a resolution of 640×360 and the model requires an input of 320×320, the preprocessing process is required to meet the requirements.

```cpp
#define USE_OSD 1
#define OSD_WIDTH 800
#define OSD_HEIGHT 480
#define OSD_CHANNEL 4
```

This is the OSD drawing result channel configuration information, and its resolution needs to be consistent with the screen display resolution. There is no original image on the OSD frame, only the drawing result of the detection box. Overlaying this path with the screen display path produces the display effect. The created OSD frame data is a transparent image in `BGRA8888` format. After obtaining the AI results, detection boxes, key points, and other information are drawn on this frame, which is then inserted into the display channel to achieve the effect of two paths overlaid for display.

##### `ai_base.h` Partial Description

`AIBase` in `ai_base.h` is the encapsulation class that implements model inference, including model initialization, input/output shape, tensor initialization, model inference, and output retrieval.

```cpp
/**
 * @brief AI base class, encapsulating nncase-related operations
 * Mainly encapsulates nncase's loading, setting input, running, and getting output operations. Subsequent development of demos only needs to focus on the model's preprocessing and postprocessing
 */
class AIBase
{
public:
    /**
     * @brief AI base class constructor, loads kmodel and initializes kmodel input and output
     * @param kmodel_file kmodel file path
     * @param debug_mode  0 (no debug), 1 (only show time), 2 (show all print information)
     * @return None
     */
    AIBase(const char *kmodel_file,const string model_name, const int debug_mode = 1);

    /**
     * @brief AI base class destructor
     * @return None
     */
    ~AIBase();

    /**
     * @brief Get kmodel input tensor by index
     * @param idx Input data pointer
     * @return None
     */
    runtime_tensor get_input_tensor(size_t idx);

    void set_input_tensor(size_t idx,runtime_tensor &input_tensor);

    /**
     * @brief Run kmodel inference
     * @return None
     */
    void run();

    /**
     * @brief Get kmodel output, the result is stored in the corresponding class property
     * @return None
     */
    void get_output();

    runtime_tensor get_output_tensor(int idx);


protected:
    string model_name_;                    // Model name
    int debug_mode_;                       // Debug mode, 0 (no print), 1 (print time), 2 (print all)
    vector<float *> p_outputs_;            // Pointer list corresponding to kmodel output
    vector<vector<int>> input_shapes_;     //{{N,C,H,W},{N,C,H,W}...}
    vector<vector<int>> output_shapes_;    //{{N,C,H,W},{N,C,H,W}...}} or {{N,C},{N,C}...}}, etc.
private:
    /**
     * @brief Initialize kmodel input for the first time and get input shape
     * @return None
     */
    void set_input_init();

    /**
     * @brief Initialize kmodel output for the first time and get output shape
     * @return None
     */
    void set_output_init();

    interpreter kmodel_interp_;        // kmodel interpreter, built from kmodel file, responsible for model loading, input/output setting, and inference
    vector<unsigned char> kmodel_vec_; // The entire kmodel data obtained by reading the kmodel file, used to pass to the kmodel interpreter to load the kmodel
};
```

In the above encapsulation structure, the main things we may use in application development are the input and output `tensor`'s `shape`, which can be obtained from `input_shapes_` and `output_shapes_`. The output `tensor`'s data pointer can be obtained from `p_outputs_`, for example, to get the pointer to the model's first output:

```cpp
float *output0 = p_outputs_[0];
```

##### Task Scenario Header File and Implementation File

`face_detection.h` and `face_detection.cc` are the **core files that users need to implement themselves during secondary development**.

In actual projects, you can name the files according to your own application scenarios:

```bash
***.h  
***.cc
```

For example: `person_det.h`, `helmet_detect.cc`, `gesture_recog.h`, etc. In these two files, you need to implement a **task class**, which must:

```cpp
class YourTask : public AIBase
```

That is to say — **inherit AIBase and complete the specific task logic**.

This class is mainly responsible for 4 things:

| Module                    | Must write by yourself | Role              |
| --------------------- | ------- | --------------- |
| **Preprocess**  | ✅Must implement   | Convert input image to format required by the model |
| **Inference**  |  ✅Directly call the interface in AIBase   | Already encapsulated by AIBase    |
| **Postprocess** | ✅ Must implement  | Convert model output to interpretable results   |
| **Draw**       | ✅ Must implement  | Draw results onto the image        |

Here we assume the application scenario class header file and implementation are `myapp.h` and `myapp.cc`, where the structure of `myapp.h` can be written by referring to `face_detection.h`:

```cpp
#ifndef _MYAPP_H
#define _MYAPP_H

#include <iostream>
#include <vector>
#include "ai_utils.h"
#include "ai_base.h"

using std::vector;


/**
 * @brief Custom data structure used in postprocessing, such as a detection box needs to include coordinates xywh, classification index, and confidence. Define as needed
 */
typedef struct ExampleResults
{
    //Define the data structures used here as needed
} ExampleResults;

/**
 * @brief Application class to be developed, inheriting AIBase
 * Mainly encapsulates the process from preprocessing, running to postprocessing to produce results for each frame of image based on the specific application scenario
 */
class MyApp : public AIBase
{
public:
    /**
     * @brief Video stream inference, MyApp constructor, loads kmodel, initializes kmodel input and output and other parameters used by the application such as thresholds, and configures the corresponding preprocessing method
     * @param kmodel_file kmodel file path
     * @param other_params Other parameters, such as various thresholds
     * @param image_size   Frame input shape of camera AI channel image
     * @param debug_mode  0 (no debug), 1 (only show time), 2 (show all print information)
     * @return None
     */
    MyApp(char *kmodel_file, other_params, FrameCHWSize image_size, int debug_mode);

    /**
     * @brief MyApp destructor
     * @return None
     */
    ~MyApp();

    /**
     * @brief Preprocessing
     * @param input_tensor Input tensor
     * @return None
     */
    void pre_process(runtime_tensor &input_tensor);

    /**
     * @brief kmodel inference
     * @return None
     */
    void inference();

    /**
     * @brief Postprocess of kmodel inference results, using the passed image_size, restores coordinates and other information to the original image resolution, and stores the result in results
     * @param image_size  Input image shape
     * @param results Postprocess result storage container
     * @return None
     */
    void post_process(FrameCHWSize image_size,vector<ExampleReults> &results);

     /**
     * @brief Draw results
     * @param draw_frame  The transparent image (video OSD) or original image (single image inference) to be drawn on, of type cv::Mat
     * @param results     Postprocess results
     * @return None
     */
    void draw_result(cv::Mat& draw_frame,vector<ExampleReults>& results);


    std::unique_ptr<ai2d_builder> ai2d_builder_; // ai2d builder
    runtime_tensor ai2d_out_tensor_;             // ai2d output tensor
    FrameCHWSize image_size_;                    // Input image shape
    FrameCHWSize input_size_;                    // Model input shape

    //Other member variables used by the current task scenario can be defined here, such as classification diagrams
    // ***
};

#endif
```

The interfaces defined above need to be specifically implemented in `myapp.cc`, which will not be repeated here. You can refer to the code in `src/rtsmart/examples/ai/face_detection/src/face_detection.cc` for imitation.

##### Modifying the `main.cc` File

- **Workflow Overview**

`main.cc` contains the logic of the entire task, including the steps of acquiring one frame of data from the camera/reading an image, creating tensors, calling the application class's preprocessing, inference, postprocessing, and drawing results to implement the complete process of handling one frame of data. The flow chart of this process is shown below:

![model_inference_rtos](https://www.kendryte.com/api/post/attachment?id=642)

- **Video Inference Code**

The video inference code in `main.cc` is shown below. You need to imitate this part of the code according to your own scenario. Pseudocode is given here. See the comments for specific introductions:

```cpp
FrameCHWSize image_size={AI_FRAME_CHANNEL,AI_FRAME_HEIGHT, AI_FRAME_WIDTH};
// Create an empty Mat object to store the drawn frame
cv::Mat draw_frame(OSD_HEIGHT, OSD_WIDTH, CV_8UC4, cv::Scalar(0, 0, 0, 0));
// Create an empty runtime_tensor object to store input data
runtime_tensor input_tensor;
dims_t in_shape { 1, AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH };
// Create a PipeLine object to handle video stream
PipeLine pl(debug_mode);
// Initialize PipeLine object
pl.Create();
// Create a DumpRes object to store frame data
DumpRes dump_res;
// Initialize task scenario class instance and postprocess result storage container
MyApp my_app(argv[1], atof(argv[2]),atof(argv[3]), image_size, atoi(argv[5]));
vector<ExampleResults> results;

// Enter while loop, continuously dump images
while (!isp_stop)
{
    // Create a ScopedTiming object to calculate the total time
    ScopedTiming st("total time", 1);
    // Get one frame of data from PipeLine and create tensor
    pl.GetFrame(dump_res);
    input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, { (gsl::byte *)dump_res.virt_addr, compute_size(in_shape) },false, hrt::pool_shared, dump_res.phy_addr).expect("cannot create input tensor");
    hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("sync write_back failed");
    //Preprocess, inference, postprocess
    my_app.pre_process(input_tensor);
    my_app.inference();
    my_app.post_process(image_size,results);
    // Clear the drawing result of the previous frame
    draw_frame.setTo(cv::Scalar(0, 0, 0, 0));
    my_app.draw_result(draw_frame,results);
    // Insert the drawn frame into PipeLine's display video stream
    pl.InsertFrame(draw_frame.data);
    // Release the current frame data
    pl.ReleaseFrame();
}
pl.Destroy();
```

By running the video stream inference process in a separate thread, if the user inputs `q`, the variable `isp_stop` is set to `True` to implement the exit function.

- **Image Inference Code**

There is image inference code in `main.cc`, modified as follows:

```cpp

int debug_mode = atoi(argv[5]);
// Read image
cv::Mat ori_img = cv::imread(argv[4]);
//Use the image to initialize image_size
FrameCHWSize image_size={ori_img.channels(),ori_img.rows,ori_img.cols};
// Create an empty vector to store chw image data, convert the read hwc data to chw data
std::vector<uint8_t> chw_vec;
std::vector<cv::Mat> bgrChannels(3);
cv::split(ori_img, bgrChannels);
for (auto i = 2; i > -1; i--)
{
    std::vector<uint8_t> data = std::vector<uint8_t>(bgrChannels[i].reshape(1, 1));
    chw_vec.insert(chw_vec.end(), data.begin(), data.end());
}
// Create input tensor
dims_t in_shape { 1, 3, ori_img.rows, ori_img.cols };
runtime_tensor input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, hrt::pool_shared).expect("cannot create input tensor");
auto input_buf = input_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

// Initialize task scenario class instance and postprocess result storage container
MyApp my_app(argv[1], atof(argv[2]),atof(argv[3]), image_size, atoi(argv[5]));
vector<ExampleResults> results;
//Preprocess, inference, postprocess
my_app.pre_process(input_tensor);
my_app.inference();
my_app.post_process(image_size,results);
// Draw directly on the original image
my_app.draw_result(ori_img,results);
cv::imwrite("result.jpg", ori_img);
```

When modifying the inference logic, pay attention to also modifying the input parameter description and input parameter count check:

```cpp
void print_usage(const char *name)
{
    cout << "Usage: " << name << "<kmodel_det> <obj_thres> <nms_thres> <input_mode> <debug_mode>" << endl
         << "Options:" << endl
         << "  kmodel_det      Face detection kmodel path\n"
         << "  other_params    Other parameters, such as thresholds\n"
         << "  input_mode      Local image (image path)/ Camera (None) \n"
         << "  debug_mode      Whether debugging is needed, 0, 1, 2 indicate no debugging, simple debugging, and detailed debugging, respectively\n"
         << "\n"
         << endl;
}
```

```cpp
// Input parameter count check
std::cout << "case " << argv[0] << " built at " << __DATE__ << " " << __TIME__ << std::endl;
if (argc != 5)
{
    print_usage(argv[0]);
    return -1;
}
```

##### Build File `CMakeLists.txt` and Build Script `build_app.sh`

For example, for `src/CMakeLists.txt` in the face detection task source directory, you need to modify and add the subdirectory to be compiled. Here the source code is split into two CMakeLists.txt, but they can also be combined into one. Users unfamiliar with this part can ignore it:

```cmake
add_subdirectory(src) 
```

For `face_detection/src/CMakeLists.txt` in the face detection task subdirectory, you need to modify the files to be compiled and the generated executable file elf name:

```cmake
set(src main.cc face_detection.cc anchors_320.cc anchors_640.cc ai_base.cc ai_utils.cc video_pipeline.cc)
set(bin face_detection.elf)
```

The build script file `face_detection/build_app.h` defines the environment variables used for compilation. At the same time, you need to modify the elf file copy path:

```shell
# Copy the generated elf and kmodel and other files to the k230_bin directory
collect_outputs() {
    local elf_file="${BUILD_DIR}/bin/face_detection.elf"

    if [ -f "${elf_file}" ]; then
        echo "[INFO] Collecting ELF and utility files to ${K230_BIN_DIR}..."
        cp -u "${elf_file}" "${K230_BIN_DIR}/"
        cp -u utils/* "${K230_BIN_DIR}/" 2>/dev/null || true
    else
        echo "[WARN] ELF file not found: ${elf_file}"
    fi
}
```

### Compile Code

#### Switch Development Board and Compile Application

Return to the `RTOS` root directory and view the supported development boards:

```shell
make list-def
```

Switch the development board to use and compile, switch to the development board you are using:

```shell
make ***_defconfig

make -j
```

After the execution is completed, the compiled image will be generated in the `output` directory. We hope that users can place the application code in the `src/rtsmart/examples/ai` directory, and you can refer to the `face_detection` implementation in that directory.

- **Compilation Method One**

After the code modifications described in the above sections are completed, enter the same-level directory as `build_app.sh` and execute:

```bash
build_app.sh
```

After the script execution is completed, the compilation intermediate products are located in the `build` directory, and the deployment summary file is located in the `k230_bin` directory.

- **Compilation Method Two**

Execute `make menuconfig` in the root directory of the `RTOS SDK`, select `RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build Face Detection Programs`, save and exit. As shown in the figure below:

![rtos_facedet_menuconfig](https://www.kendryte.com/api/post/attachment?id=836)

Because a `Makefile` is provided, directly execute

```bash
make -j
```

In this way, the deployment summary file will be directly compiled into the `/sdcard/app/examples/ai/face_detection` directory of the firmware during the compilation process. You can also **directly enter the corresponding directory** and execute:

```bash
make -j
```

This command can also achieve compilation, and the compiled products will be generated in the `k230_bin` directory. The compilation process implements incremental compilation.

### Development Board Deployment

Flash the firmware and power it on. For firmware flashing, refer to the documentation: [how_to_flash](../../userguide/how_to_flash.md).

You can see a virtual disk `CanMV` at the drive letter. Copy the compiled elf file under `k230_bin`, the kmodel file, and other used files (such as test images) to the `CanMV/sdcard` directory.

Then use a serial port tool to connect to the development board, and execute the `face_detect_isp.sh` or `face_detect_image.sh` script in the command line. Note that the parameters must match the position and type in the code.

### Debugging Guide

#### Check whether the model input/output shape is reasonable

Print the member variables `input_shapes_` and `output_shapes_` of the `AIBase` class in `ai_base.h` to check whether the input and output dimensions are correct.

#### View data by dumping raw data

`ai_utils.h` provides three interfaces: `dump_binary_file`, `dump_binary_file`, and `dump_color_image`, which are used to dump binary files, grayscale images, and color images. View the dumped images to check whether the data meets the requirements. For example, `BGR` and `RGB` data are different.

#### Locate the specific location of runtime bugs by printing

Add `std::cout` statements or logging mechanisms in the code, recompile and run on the board repeatedly, and check the error location.

#### Add timing statistics tools to check anomalies

For demos where the overall runtime is obviously abnormal, you can add statements to print time and check whether the module runtime is abnormal. The source code provides the `scoped_timing.h` tool for time statistics. The example code is as follows:

```cpp
{
    ScopedTiming st("test", 1);
    /*
    * Write test code here
    */
}
```

#### For memory issues, you can use the cat command to check the usage

There is a file for viewing memory usage information under `/proc` on the development board RTOS. The supported modules for viewing are shown in the figure below:

![cat_info](https://www.kendryte.com/api/post/attachment?id=512)

For example, you can check the memory of the multimedia part through the following command at the development board serial port:

```shell
cat /proc/media-mem
```

The returned result is shown in the figure below:

![cat_info](https://www.kendryte.com/api/post/attachment?id=513)

Other modules can also be checked using the `cat` command, for example:

```shell
cat /proc/umap/vicap

cat /proc/umap/vb

cat /proc/umap/vo
```

For system memory usage, you can use the `list_page` command to check:

```shell
list_page
```

The command execution result is shown in the figure below:

![list_page](https://www.kendryte.com/api/post/attachment?id=514)

The data shows the number of free pages, used pages, and maximum used pages. The data is displayed in hexadecimal format, and each page size is 4KB. By adding the memory of `free pages` and `used pages`, you can get the maximum available memory.

#### Model performance does not meet requirements

If the model performance does not meet your requirements, you can optimize it from the following four aspects:

- Adjust the model parameters, such as confidence threshold, NMS threshold, etc.;
- Adjust the input resolution of the model, and confirm the reasonableness of the pre-processing, for example, adjust the resolution from `320*320` to `640*640`;
- Adjust the quantization method of model conversion, refer to the documentation: [Quantization Parameters](./nncase.md#ptqtensoroptions) for `calibrate_method`, `quant_type`, and `w_quant_type`. For example, change `w_quant_type` to `int6`;
- Replace with a more reasonable model. If the current model does not meet the requirements, you can try other models for the current task;
