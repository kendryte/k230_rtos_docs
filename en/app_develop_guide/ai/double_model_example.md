
# Dual-Model Application Development Guide

## Overview

In the document [Single-Model Application Development Guide](./single_model_example.md), we introduced how to develop an AI application for single-model inference and run it on the k230. For multi-model inference scenarios, we can also refer to the single-model development guide. This guide uses face recognition as an example to introduce the development of a dual-model inference application. The difference from single-model applications is that it requires implementing the loading and configuration of multiple models.

## Development Guide

### Converting kmodel

First, you need to have a `kmodel`. For face recognition, we can use the `face_detection_320.kmodel` and `face_recognition.kmodel` already prepared in the `utils` directory under `src/rtsmart/examples/ai/face_recognition`.

If you want to train the model yourself, you can refer to open-source materials to train and obtain a `pt/pth` model, then convert the model to an `onnx/tflite` model, and then convert the model to `kmodel`.

For the `kmodel` conversion part, please refer to the document: [nncase_compile.md](../../api_reference/nncase/nncase_compile.md).

nncase github official link: [nncase github](https://github.com/kendryte/nncase).
nncase gitee official link: [nncase gitee](https://gitee.com/kendryte/nncase).

### Developing Deployment Code

#### Modules and Workflow Overview

After obtaining the `kmodel`, you can start developing the code for running on the board. First, we need to clarify the **involved modules** and the **workflow of the scenario**.

- **Involved Modules**:

1. **vicap (video input capture) module**: Configures the camera (Sensor) device properties and channel attributes, including resolution, frame rate, data format, etc. It sends camera data to the screen in a bound manner for display, and obtains camera frame data for AI inference.
1. **vo (video output) module**: Configures the display device (Display) and display layer attributes, including position, resolution, frame rate, data format, etc. It implements real-time display of display frames sent from the camera or other modules. It includes the video layer and osd layer, which are responsible for displaying video frames and overlaid text information respectively. The video layer only supports yuv format, and the osd layer only supports rgb format.
1. **kpu module**: Responsible for loading `kmodel`, configuring the input and output `tensor` of `kmodel`, and completing model inference.
1. **ai2d module**: Responsible for preprocessing the model input images, supporting five defined preprocessing zooms. For usage, see the document [usage_ai2d](./usage_ai2d.md).

- **Workflow of the Scenario**:

The basic development structure of AI dual-model application development can also adopt the **single-camera dual-channel processing** approach. The core idea is to split the images captured by the camera into two paths for processing:

- **One path of images** is directly bound to the screen for display, ensuring that the picture can be presented **in real-time and with low latency**;
- **The other path of images** is used for **AI model inference**, that is, the image is converted into a tensor, sent to the model for processing, and detection and recognition results are obtained.

After inference is complete, the program draws these results onto a **transparent layer (OSD)**, which is **overlaid** with the real-time display path of the image. Ultimately, what the user sees on the screen is an **effect image that combines the original image and AI recognition results**.

The reason we adopt this "dual-channel processing + layer overlay" approach is to solve the performance bottleneck problem.
If the traditional workflow is adopted:

```shell
Get camera image → Create tensor → Input preprocessing → Model inference → Output postprocessing → Draw inference results → Screen display
```

If the **model inference itself takes a long time**, the entire process will cause image stuttering, especially when using complex models or handling complex tasks, which will significantly degrade the experience.

Therefore, we separate display from AI inference: **real-time display takes priority, and inference results are asynchronously drawn and overlaid**, thereby ensuring smooth picture display while also presenting the results of AI analysis in real-time.

As shown in the figure below, it is the flowchart of the single-camera dual-channel processing logic for dual-model serial inference:

![double_model_pipeline](https://www.kendryte.com/api/post/attachment?id=840)

As shown in the figure below, it is the flowchart of the single-camera dual-channel processing logic for dual-model parallel inference:

![double_model_pipeline](https://www.kendryte.com/api/post/attachment?id=841)

> Note: It should be noted here that KPU inference is an exclusive process. If you use multi-threading to achieve parallel inference, you need to add synchronization locks to prevent conflicts caused by multiple threads accessing the KPU simultaneously.

#### Code Structure Introduction

Taking face recognition dual-model inference as an example, the existing code structure is as follows:

```shell
face_recognition
├── cmake
├── src
│    ├── ai_base.cc         # Model inference encapsulation implementation
│    ├── ai_base.h          # Model inference header file
│    ├── ai_utils.cc        # Model inference utility methods
│    ├── ai_utils.h         # Model inference utility methods header file
│    ├── anchors_320.cc     # Anchors used for the 320-input face detection model
│    ├── anchors_640.cc     # Anchors used for the 640-input face detection model
│    ├── face_detection.cc  # Implementation of the face detection task scenario, including preprocessing, inference, postprocessing, and result drawing adapted to the scenario model
│    ├── face_detection.h   # Header file for the face detection task scenario
│    ├── face_recognition.cc  # Implementation of the face recognition task scenario, including preprocessing, inference, postprocessing, and result drawing adapted to the scenario model, as well as interfaces for face database initialization, adding faces, face counting, face matching, etc.
│    ├── face_recognition.h   # Header file for the face recognition task scenario
│    ├── main.cc            # Implementation of the main function, implementing specific AI application scenarios based on the interfaces provided by face_detection.h
│    ├── scoped_timing.h    # Provides timing utilities to help with development and debugging
│    ├── setting.h          # Provides macro definitions for configuration parameters, implementing display device configuration and AI inference image resolution configuration
│    ├── video_pipeline.cc  # Implementation of the single-camera dual-channel development workflow, including initialization of camera, display device, OSD layer overlay, dumping one frame of AI inference image, inserting one frame of OSD image, etc.
│    ├── video_pipeline.h   # Header file for the single-camera dual-channel development workflow
│    └── CMakeLists.txt     # CMakeLists.txt for the single-camera dual-channel development workflow
├── utils                   # Kmodels and scripts that can be used directly
├── CMakeLists.txt          # CMakeLists.txt, used to build the entire application (Method 1)
├── build_app.sh            # Build script
└── Makefile                # Makefile, used to build the entire application (Method 2)
```

#### Code Function Introduction

Taking face detection single-model inference as an example, the following describes the role of different files in the existing code:

| File Name                    |         Role     |
|--------------------------- | -----------------|
|ai_base.h|Provides interfaces used during model inference|
|ai_bash.cc|Provides the implementation of the model inference methods defined in ai_bash.h|
|ai_utils.h|Provides common utility function interfaces|
|ai_utils.cc|Provides the implementation of the utility functions defined in ai_utils.h|
|scoped_timing.h|Provides timing utilities to help with development and debugging|
|setting.h|Provides interfaces for configuration parameters, implementing display device parameter configuration and AI inference image resolution configuration|
|video_pipeline.h|Provides interfaces for the single-camera dual-channel development workflow, including initialization of camera, display device, OSD layer overlay, dumping one frame of AI inference image, etc.|
|video_pipeline.cc|Provides the implementation of the video processing interfaces defined in video_pipeline.h|
|face_detection.h|Provides interfaces for preprocessing, inference, postprocessing, and result drawing for specific task scenarios (here, face detection)|
|face_detection.cc|Provides the implementation of the task scenario interfaces defined in face_detection.h|
|face_recognition.h|Provides interfaces for preprocessing, inference, postprocessing, and result drawing for specific task scenarios (here, face recognition), as well as interfaces for face database initialization, adding faces, face counting, face matching, etc.|
|face_recognition.cc|Provides the implementation of the task scenario interfaces defined in face_recognition.h|
|anchors_320.cc|Anchor data used for the face detection task|
|anchors_640.cc|Anchor data used for the face detection task|
|main.cc|Implementation of the main function, implementing specific AI application scenarios based on the interfaces provided by face_detection.h|

When developing an AI application, how should the above files be used and written?

- `ai_base.h` and `ai_base.cc` implement the encapsulation base class for model inference, including `kmodel` initialization, model input and output initialization, running, and getting output interfaces. See the file comments for the code; `scoped_timing.h` provides timing utilities; **these files generally do not need to be changed**.

- `ai_utils.h` and `ai_utils.cc` provide general utility functions, mainly data access and common preprocessing methods. **If the provided methods cannot meet your needs, you can modify these two files to add new methods. If they already meet your needs, no modification is required**.

- `setting.h`, `video_pipeline.h`, and `video_pipeline.cc` implement initialization configurations for the camera, display device, and OSD, as well as AI inference frame acquisition and OSD display overlay methods. They currently support two display modes: `LT9611 HDMI 1920*1080` and `ST7701 LCD 800*480`; **you only need to adjust these files if you need to add new screen support; otherwise, they can remain unchanged**.

- `face_detection.h`, `face_detection.cc`, `face_recognition.h`, `face_recognition.cc`, and `main.cc` are the files that **users need to write themselves** when developing new AI applications. You can refer to the corresponding files under `src/rtsmart/examples/ai/face_recognition` for writing. The task scenario header and implementation files mainly **implement the input preprocessing, inference (generally directly calling the `run` method in `ai_base.h`), and model postprocessing code for the task model**; the `main.cc` file needs to modify the model inference logic, including **instantiation of specific task scenario classes, and calls to the preprocessing, model inference, postprocessing, and result drawing interfaces**.

#### Code Details

##### `setting.h` Configuration Description

The macro definition parameters configured in `setting.h` are mainly used to set the camera output image, screen display, OSD layer, and the resolution of the AI inference image, etc.

|Macro Definition Parameter|Description|
|:-:|:-:|
|`ISP_WIDTH`|ISP output width|
|`ISP_HEIGHT`|ISP output height|
|`DISPLAY_MODE`|Display mode, 0 is 1920×1080 LT9611, 1 is 800×480 ST7701|
|`DISPLAY_WIDTH`|Display screen width|
|`DISPLAY_HEIGHT`|Display screen height|
|`AI_FRAME_WIDTH`|AI inference frame width|
|`AI_FRAME_HEIGHT`|AI inference frame height|
|`AI_FRAME_CHANNEL`|AI inference frame channel number|
|`USE_OSD`|Whether to use OSD, 0 is not used, 1 is used|
|`OSD_WIDTH`|OSD layer width, used to display AI inference results|
|`OSD_HEIGHT`|OSD layer height, used to display AI inference results|
|`OSD_CHANNEL`|OSD layer channel number|

The details are as follows:

```cpp
#define ISP_WIDTH 1920
#define ISP_HEIGHT 1080
```

This is the resolution configured for the camera. Based on this, the image will be split into two channels: display and AI (single-camera dual-channel). The image format and resolution for different paths can be adjusted during the split process.

```cpp
#define DISPLAY_MODE 1    //Display mode, 0 is 1920×1080 LT9611, 1 is 800×480 ST7701
#define DISPLAY_WIDTH 800
#define DISPLAY_HEIGHT 480
#define DISPLAY_ROTATE 1  // Rotation, 0 is no rotation, 1 is 90-degree rotation
```

This path is the data split from the camera configured image to the display channel, and the configuration varies depending on the screen resolution and orientation. Generally, `hdmi 1080P` can keep the current configuration unchanged, that is, `lt9611`. The `st7701` screen is also supported, with a resolution of `800*480`.

`st7701` is essentially a `480*800` vertical screen, which requires a 90-degree rotation when displayed. The rotation function is now encapsulated in the underlying vo module, and users can ignore this feature and directly use it as a horizontal screen.

```cpp
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 360
#define AI_FRAME_CHANNEL 3
```

This path is the data split from the camera configured image to the AI channel for model preprocessing. You can set it according to the AI requirements. The output here is data in `3*360*640` `PIXEL_FORMAT_RGB_888_PLANAR` format. The data arrangement is `CHW`, which needs to meet the model input.

> **Note:**
>
> It is necessary to distinguish between the resolution of the AI channel and the resolution of the model input:
> **AI channel resolution**: the resolution of the image data from the camera **before AI model preprocessing**;
> **Model input resolution**: the width and height of the data sent directly to the model **after preprocessing**;
> The AI channel data after preprocessing can be accurately converted into the model input data. For example, if the output resolution of the camera AI channel is 640×360 and the model requires an input of 320×320, a preprocessing process is required to meet the requirements.

```cpp
#define USE_OSD 1
#define OSD_WIDTH 800
#define OSD_HEIGHT 480
#define OSD_CHANNEL 4
```

This is the configuration information of the OSD drawing result channel, and its resolution needs to be consistent with the screen display resolution. There is no original image on the OSD frame, only the drawing results of the detection boxes. This path is overlaid with the screen display path to produce the display effect. The created OSD frame data is a transparent image in `BGRA8888` format. After obtaining the AI results, the detection boxes, key points, and other information are drawn on this frame, and then inserted into the display channel to achieve the effect of two-path overlay display.

##### `ai_base.h` Partial Description

`AIBase` in `ai_base.h` is an encapsulation class that implements model inference, including model initialization, input and output shapes, tensor initialization, model inference, and output acquisition.

```cpp
/**
 * @brief AI base class, encapsulating nncase-related operations
 * It mainly encapsulates nncase loading, input setting, running, and output acquisition operations. Subsequent demo development only needs to focus on the model preprocessing and postprocessing.
 */
class AIBase
{
public:
    /**
     * @brief AI base class constructor, loads kmodel, and initializes kmodel input and output
     * @param kmodel_file kmodel file path
     * @param debug_mode  0 (no debugging), 1 (only shows time), 2 (shows all print information)
     * @return None
     */
    AIBase(const char *kmodel_file,const string model_name, const int debug_mode = 1);

    /**
     * @brief AI base class destructor
     * @return None
     */
    ~AIBase();

    /**
     * @brief Get the kmodel input tensor by index
     * @param idx input data pointer
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
     * @brief Get kmodel output, the result is stored in the corresponding class properties
     * @return None
     */
    void get_output();

    runtime_tensor get_output_tensor(int idx);


protected:
    string model_name_;                    // Model name
    int debug_mode_;                       // Debug mode, 0 (no printing), 1 (print time), 2 (print all)
    vector<float *> p_outputs_;            // Pointer list corresponding to kmodel output
    vector<vector<int>> input_shapes_;     //{{N,C,H,W},{N,C,H,W}...}
    vector<vector<int>> output_shapes_;    //{{N,C,H,W},{N,C,H,W}...}} or {{N,C},{N,C}...}} etc.
private:
    /**
     * @brief Initialize kmodel input for the first time, and get the input shape
     * @return None
     */
    void set_input_init();

    /**
     * @brief Initialize kmodel output for the first time, and get the output shape
     * @return None
     */
    void set_output_init();

    interpreter kmodel_interp_;        // kmodel interpreter, built from the kmodel file, responsible for model loading, input and output setting, and inference
    vector<unsigned char> kmodel_vec_; // The entire kmodel data obtained by reading the kmodel file, used to pass to the kmodel interpreter to load the kmodel
};
```

In the above encapsulation structure, what we may mainly use in application development is the `shape` of the input and output `tensor`, which can be obtained from `input_shapes_` and `output_shapes_`. The data pointer of the output `tensor` can be obtained from `p_outputs_`, for example, to get the pointer of the first output of the model:

```cpp
float *output0 = p_outputs_[0];
```

##### Task Scenario Header and Implementation Files

`face_detection.h`, `face_detection.cc`, `face_recognition.h`, and `face_recognition.cc` are the **core files that users need to implement themselves during secondary development**.

In actual projects, you can name the files according to your own application scenario:

```bash
***.h  
***.cc
```

In these two files, you need to implement a **Task Class**, which must:

```cpp
class YourTask : public AIBase
```

That is to say —— **inherit AIBase and complete the specific task logic**.

This class is mainly responsible for 4 things:

| Module                    | Whether you must write it yourself | Role              |
| --------------------- | ------- | --------------- |
| **Preprocess**  | ✅Must implement   | Convert the input image to the format required by the model |
| **Inference**  |  ✅Directly call the interface in AIBase   | Already encapsulated by AIBase    |
| **Postprocess** | ✅ Must implement  | Convert the model output into understandable results   |
| **Draw**       | ✅ Must implement  | Draw the results onto the image        |

Here we assume the header and implementation files of the application scenario class are `myapp.h` and `myapp.cc`. The structure of `myapp.h` can be written by imitating `face_detection.h` and `face_recognition.h`. Taking serial inference as an example, the pseudocode is given here:

```cpp
#ifndef _MYAPP_H
#define _MYAPP_H

#include <iostream>
#include <vector>
#include "ai_utils.h"
#include "ai_base.h"

using std::vector;


/**
 * @brief Custom data structure used in the postprocessing process. For example, a detection box needs to include the coordinates xywh, the classification index, and the confidence. Define as needed.
 */
typedef struct ExampleResults
{
    //Define the data structure as needed
} ExampleResults;

/**
 * @brief Application class to be developed, inheriting AIBase
 * It mainly encapsulates the process from preprocessing, running to postprocessing for each frame of image based on a specific application scenario.
 */
class MyApp : public AIBase
{
public:
    /**
     * @brief Video stream inference, MyApp constructor, loads kmodel, and initializes kmodel input, output, and other parameters used by the application such as thresholds, and configures the corresponding preprocessing method
     * @param kmodel_file kmodel file path
     * @param other_params other parameters, such as various thresholds
     * @param image_size   Input shape of one frame of the camera AI channel image
     * @param debug_mode  0 (no debugging), 1 (only shows time), 2 (shows all print information)
     * @return None
     */
    MyApp(char *kmodel_file, other_params, FrameCHWSize image_size, int debug_mode);

    /**
     * @brief MyApp destructor
     * @return None
     */
    ~MyApp();

    /**
     * @brief Preprocess
     * @param input_tensor input tensor
     * @return None
     */
    void pre_process(runtime_tensor &input_tensor);

    /**
     * @brief kmodel inference
     * @return None
     */
    void inference();

    /**
     * @brief Postprocess the kmodel inference results, use the passed-in image_size, restore the coordinates and other information to the original image resolution, and store the results in results
     * @param image_size  Shape of the input image
     * @param results Postprocessing result storage container
     * @return None
     */
    void post_process(FrameCHWSize image_size,vector<ExampleReults> &results);

     /**
     * @brief Draw results
     * @param draw_frame  The transparent image (video OSD) or original image (single-image inference) on which the results are to be drawn, of type cv::Mat
     * @param results     Postprocessing results
     * @return None
     */
    void draw_result(cv::Mat& draw_frame,vector<ExampleReults>& results);


    std::unique_ptr<ai2d_builder> ai2d_builder_; // ai2d builder
    runtime_tensor ai2d_out_tensor_;             // ai2d output tensor
    FrameCHWSize image_size_;                    // Shape of the input image
    FrameCHWSize input_size_;                    // Shape of the model input

    //You can define other member variables used by the current task scenario here, such as the classification diagram
    // ***
};

#endif
```

The interfaces defined above need to be specifically implemented in `myapp.cc`, which will not be described in detail here. You can refer to the code in `src/rtsmart/examples/ai/face_recognition/src` for imitation.

##### Modifying the `main.cc` File

- **Workflow Overview**

`main.cc` contains the logic of the entire task, including the steps of obtaining one frame of data from the camera/reading an image, creating a tensor, calling the application class's preprocessing, inference, postprocessing, and drawing results to achieve the complete process of processing one frame of data. The flowchart of this process is shown below:

![double_model_inference_rtos](https://www.kendryte.com/api/post/attachment?id=838)

- **Video Inference Code**

The video inference code in `main.cc` is as follows. You need to imitate this part of the code according to your own scenario. Pseudocode is given here. For details, see the comments:

```cpp
FrameCHWSize image_size={AI_FRAME_CHANNEL,AI_FRAME_HEIGHT, AI_FRAME_WIDTH};
// Create an empty Mat object to store the drawn frame
cv::Mat draw_frame(OSD_HEIGHT, OSD_WIDTH, CV_8UC4, cv::Scalar(0, 0, 0, 0));
// Create an empty runtime_tensor object to store the input data
runtime_tensor input_tensor;
dims_t in_shape { 1, AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH };
// Create a PipeLine object to process the video stream
PipeLine pl(debug_mode);
// Initialize the PipeLine object
pl.Create();
// Create a DumpRes object to store frame data
DumpRes dump_res;
// Initialize the task scenario class instance, and initialize the postprocessing result storage container
MyApp_1 my_app_1(argv[1], atof(argv[2]),atof(argv[3]), image_size, atoi(argv[8]));
vector<ExampleResults> results_1;

MyApp_2 my_app_2(argv[5], atof(argv[6]),atof(argv[7]), image_size, atoi(argv[8]));
vector<ExampleResults> results_2;

// Enter a while loop to continuously dump images
while (!isp_stop)
{
    // Create a ScopedTiming object to calculate the total time
    ScopedTiming st("total time", 1);
    // Get one frame of data from PipeLine, and create a tensor
    pl.GetFrame(dump_res);
    input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, { (gsl::byte *)dump_res.virt_addr, compute_size(in_shape) },false, hrt::pool_shared, dump_res.phy_addr).expect("cannot create input tensor");
    hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("sync write_back failed");
    //Preprocess, inference, postprocess
    my_app_1.pre_process(input_tensor);
    my_app_1.inference();
    my_app_1.post_process(image_size,results_1);

    for (auto &result : results_1)
    {
        my_app_2.pre_process(input_tensor);
        my_app_2.inference();
        my_app_2.post_process(image_size,results_2);
    }
    // Clear the drawing results of the previous frame
    draw_frame.setTo(cv::Scalar(0, 0, 0, 0));
    my_app_1.draw_result(draw_frame,results_1);
    my_app_2.draw_result(draw_frame,results_2);
    // Insert the drawn frame into the display video stream of PipeLine
    pl.InsertFrame(draw_frame.data);
    // Release the current frame data
    pl.ReleaseFrame();
}
pl.Destroy();
```

By running the video stream inference process in a separate thread, if the user inputs `q`, the variable `isp_stop` is set to `True` to achieve the exit function.

- **Image Inference Code**

There is image inference code in `main.cc`, which is modified as follows:

```cpp

int debug_mode = atoi(argv[5]);
// Read the image
cv::Mat ori_img = cv::imread(argv[4]);
//Use the image to initialize image_size
FrameCHWSize image_size={ori_img.channels(),ori_img.rows,ori_img.cols};
// Create an empty vector to store chw image data, and convert the read hwc data into chw data
std::vector<uint8_t> chw_vec;
std::vector<cv::Mat> bgrChannels(3);
cv::split(ori_img, bgrChannels);
for (auto i = 2; i > -1; i--)
{
    std::vector<uint8_t> data = std::vector<uint8_t>(bgrChannels[i].reshape(1, 1));
    chw_vec.insert(chw_vec.end(), data.begin(), data.end());
}
// Create the input tensor
dims_t in_shape { 1, 3, ori_img.rows, ori_img.cols };
runtime_tensor input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, hrt::pool_shared).expect("cannot create input tensor");
auto input_buf = input_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

// Initialize the task scenario class instance, and initialize the postprocessing result storage container
MyApp_1 my_app_1(argv[1], atof(argv[2]),atof(argv[3]), image_size, atoi(argv[8]));
vector<ExampleResults> results_1;

MyApp_2 my_app_2(argv[5], atof(argv[6]),atof(argv[7]), image_size, atoi(argv[8]));
vector<ExampleResults> results_2;

//Preprocess, inference, postprocess
my_app_1.pre_process(input_tensor);
my_app_1.inference();
my_app_1.post_process(image_size,results_1);

for (auto &result : results_1)
{
    my_app_2.pre_process(input_tensor);
    my_app_2.inference();
    my_app_2.post_process(image_size,results_2);
}
// Clear the drawing results of the previous frame
draw_frame.setTo(cv::Scalar(0, 0, 0, 0));
my_app_1.draw_result(ori_img,results_1);
my_app_2.draw_result(ori_img,results_2);
cv::imwrite("result.jpg", ori_img);
```

When modifying the inference logic, note that the input parameter description and the input parameter number verification part also need to be modified:

```cpp
void print_usage(const char *name)
{
    cout << "Usage: " << name << "<kmodel_det> <det_thres> <nms_thres> <kmodel_recg> <recg_thres> <db_dir> <debug_mode>" << endl
         << "Options:" << endl
         << "  kmodel_det               Face detection kmodel path\n"
         << "  det_thres                Face detection threshold\n"
         << "  nms_thres                Face detection nms threshold\n"
         << "  kmodel_recg              Face recognition kmodel path\n"
         << "  recg_thres               Face recognition threshold\n"
         << "  db_dir                   Database directory\n"
         << "  debug_mode               Whether debugging is required, 0, 1, 2 respectively represent no debugging, simple debugging, and detailed debugging\n"
         << "\n"
         << endl;
}
```

```cpp
// Input parameter number verification
std::cout << "case " << argv[0] << " built at " << __DATE__ << " " << __TIME__ << std::endl;
std::cout << "Press 'q+Enter'  to exit." << std::endl;
if (argc != 8)
{
    print_usage(argv[0]);
    return -1;
}
```

##### Build File `CMakeLists.txt` and Build Script `build_app.sh`

For example, for the `src/CMakeLists.txt` in the face recognition task source code directory, you need to modify and add the subdirectory to be compiled. The source code is split into two CMakeLists.txt files here, which can also be combined into one. Users who are not familiar with this part can ignore it:

```cmake
add_subdirectory(src) 
```

For the `face_recognition/src/CMakeLists.txt` in the face detection task subdirectory, you need to modify the files to be compiled and the name of the generated executable elf file:

```cmake
set(src main.cc ai_utils.cc video_pipeline.cc ai_base.cc face_detection.cc face_recognition.cc anchors_320.cc anchors_640.cc)
set(bin face_recognition.elf)
```

The build script file `face_recognition/build_app.h` defines the environment variables used for compilation, and you also need to modify the elf file copy path:

```shell
# Copy the generated elf and kmodel and other files to the k230_bin directory
collect_outputs() {
    local elf_file="${BUILD_DIR}/bin/face_recognition.elf"

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

Return to the `RTOS` root directory and check the supported development boards:

```shell
make list-def
```

Switch the development board to be used and compile, switch to your development board:

```shell
make ***_defconfig

make -j
```

After execution, the compiled image will be generated in the `output` directory. We hope users can place their application code in the `src/rtsmart/examples/ai` directory. You can refer to the `face_recognition` implementation in this directory.

- **Compile Method 1**

After completing the code modifications described in the previous section, navigate to the same directory as `build_app.sh` and execute:

```bash
build_app.sh
```

After the script execution is complete, the intermediate compilation products are located in the `build` directory, and the deployment summary files are located in the `k230_bin` directory.

- **Compile Method 2**

Execute `make menuconfig` in the `RT-Smart SDK` root directory, select `RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build Face Recognition Programs`, save and exit. As shown in the figure below:

![rtos_facerec_menuconfig](https://www.kendryte.com/api/post/attachment?id=839)

Because a `Makefile` is provided, directly execute

```bash
make -j
```

This way, the deployment summary files will be directly compiled into the `/sdcard/app/examples/ai/face_recognition` directory in the firmware during the compilation process. You can also **directly navigate to the corresponding directory** and execute:

```bash
make -j
```

This command can also achieve compilation, and the compilation products will be generated in the `k230_bin` directory. The compilation process implements incremental compilation.

#### Development Board Deployment

Flash the firmware and power on. For firmware flashing, refer to the document: [how_to_flash](../../userguide/how_to_flash.md).

You can see a virtual disk `CanMV` at the drive letter. Copy the elf files compiled under `k230_bin`, kmodel files, and other used files such as test images to the `CanMV/sdcard` directory.

Then use the serial port tool to connect to the development board, and execute the `run.sh` script on the command line. Note that the parameters must match the position and type in the code.

Run parameters:

```bash
Usage: face_recognition.elf <kmodel_det> <det_thres> <nms_thres> <kmodel_recg> <recg_thres> <db_dir> <debug_mode>
```

| Parameter   | Description                                              | Value Range       |
| ----------- | -------------------------------------------------------- | ----------------- |
| kmodel_det  | Path of face detection kmodel                            | kmodel path       |
| det_thres   | Face detection threshold                                 | 0.0~1.0           |
| nms_thres   | Face detection nms threshold                             | 0.0~1.0           |
| kmodel_recg | Path of face recognition kmodel                          | kmodel path       |
| recg_thres  | Face recognition threshold                               | 0~100             |
| db_dir      | Database directory                                       | Database directory path |
| debug_mode  | Whether debugging is needed, 0, 1, 2 respectively indicate no debugging, simple debugging, and detailed debugging | 0, 1, 2           |

## Feature Support

| Feature               | Supported | Command |
| --------------------- | --------- | ------- |
| Print help description | ✔        |h/help|
| Dump registered frames | ✔        |i|
| Clear face database   | ✔        |d|
| Face registration     | ✔        |Input face name|
| Query number of registered persons | ✔        |n|
| Exit program          | ✔        |q|

> Note:
> When taking a registration screenshot, please ensure there is only one clearly visible face in the frame.
> Names should use recognizable English characters and avoid special symbols.

### Debugging Guide

#### Check whether the model's input and output shapes are reasonable

Print the member variables `input_shapes_` and `output_shapes_` of the `AIBase` class in `ai_base.h` to check whether the input and output dimensions are correct.

#### View data by dumping raw data

`ai_utils.h` provides three interfaces: `dump_binary_file`, `dump_binary_file`, and `dump_color_image`, which are used to dump binary files, grayscale images, and color images. Check whether the dumped data meets the requirements. For example, `BGR` and `RGB` data are different.

#### Locate the specific location of a running bug by printing

Add `std::cout` statements or logging mechanisms in the code, repeatedly compile and run on the board, and check the error location.

#### Add timing tools to check for anomalies

For demos where the overall runtime is significantly abnormal, you can add statements to print the time to check for abnormal module execution time. The source code provides the `scoped_timing.h` utility for timing statistics. The example code is as follows:

```cpp
{
    ScopedTiming st("test", 1);
    /*
    * Write test code here
    */
}
```

#### For memory issues, you can use the cat command to check usage

Under the development board RTOS, there are memory usage information files in `/proc` for viewing. The supported modules are shown in the figure below:

![cat_info](https://www.kendryte.com/api/post/attachment?id=512)

For example, you can check the memory usage of the multimedia part through the development board serial port using the following command:

```shell
cat /proc/media-mem
```

The return result is shown in the figure below:

![cat_info](https://www.kendryte.com/api/post/attachment?id=513)

Other modules can also be viewed using the `cat` command, for example:

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

The data shows the number of free pages, used pages, and maximum used pages. The data is displayed in hexadecimal format, and each page is 4KB in size. The maximum available memory can be obtained by adding the memory of `free pages` and `used pages`.

#### Model performance does not meet requirements

If the model performance does not meet your requirements, you can optimize from the following four aspects:

- Adjust the model parameters, such as confidence threshold, NMS threshold, etc.;
- Adjust the model's input resolution to confirm the reasonableness of preprocessing, for example, change the resolution from `320*320` to `640*640`;
- Adjust the quantization method for model conversion, refer to the documentation: [Quantization Parameters](./nncase.md#ptqtensoroptions) for `calibrate_method`, `quant_type`, and `w_quant_type`. For example, change `w_quant_type` to `int6`;
- Replace with a more reasonable model. If the current model does not meet the requirements, you can try other models for the current task;
