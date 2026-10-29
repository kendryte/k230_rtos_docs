# UVC+AI Application Development Guide

## Overview

UVC+AI application is a common application scenario in embedded systems. It combines UVC video streaming with AI inference capabilities to achieve detection and recognition of targets in the video stream. This document uses the face detection application as an example to introduce how to develop a UVC+AI-based face detection application.

The model inference part in this example is the same as the model inference part in the document [Single Model Inference](./single_model_example.md), only the PipeLine data source is replaced with a UVC camera. It should be noted here that the UVC camera does not support multiple channels, so this example is developed based on a single-channel UVC camera, which is the main difference from MIPI camera inference.

## Development Guide

### Involved Modules and Task Flow

- **Involved modules**:

1. **uvc module**: Used to obtain camera frame data from the UVC camera for AI inference. Only supports resolutions of `1920*1080` and `640*480`.
1. **vo (video output) module**: Configures the display device (Display) and the properties of each display layer, including position, resolution, frame rate, data format, etc. Used to display display frames sent from the camera or other modules. Includes video layer and osd layer, which are responsible for displaying video frames and overlaid text information respectively. The video layer only supports yuv format, and the osd layer only supports rgb format.
1. **vdec module**: Responsible for obtaining video stream data from the UVC camera and decoding it from JPEG to YUV420 data frames.
1. **noai_2d module**: Responsible for converting the YUV420 data frames decoded by the vdec module into RGB data frames for AI model inference, and converting the results drawn on the original frame into YUV420SP data frames for display.
1. **kpu module**: Responsible for loading `kmodel`, configuring the input and output `tensor` of `kmodel`, and completing model inference.
1. **ai2d module**: Responsible for preprocessing the model input image, supports five defined preprocessing zooms, see the document [usage_ai2d](./usage_ai2d.md) for usage.

- **Scenario flow**:

The video stream data collected by the UVC camera is first decoded into YUV420 data frames through the vdec module, and then converted into RGB888 data frames through the noai_2d module. The RGB888 data frames are sent to the AI model for inference and the recognition results are drawn on the original image, while the RGB888 data frames are converted into YUV420SP data frames for display.

As shown in the figure below, it is a flow chart of the UVC camera processing logic:

![uvc_process](https://www.kendryte.com/api/post/attachment?id=652)

### Code Structure Introduction

Taking the UVC+face detection task as an example, the existing code structure is as follows:

```shell
uvc_face_detection
├── cmake
├── src
│    ├── ai_base.cc         # Model inference encapsulation implementation
│    ├── ai_base.h          # Model inference header file
│    ├── ai_utils.cc        # Model inference utility methods
│    ├── ai_utils.h         # Model inference utility methods header file
│    ├── anchors_320.cc     # anchors used by the 320-input face detection model
│    ├── anchors_640.cc     # anchors used by the 640-input face detection model
│    ├── face_detection.cc  # Face detection task scenario implementation, including preprocessing, inference, postprocessing, and result drawing adapted to this scenario model
│    ├── face_detection.h   # Face detection task scenario header file
│    ├── main.cc            # Main function implementation, implementing specific AI application scenarios based on the interfaces provided by face_detection.h
│    ├── scoped_timing.h    # Provides timing tools to help development and debugging
│    ├── setting.h          # Provides macro definitions for configuration parameters, implementing display device configuration and AI inference image resolution configuration
│    ├── uvc_pipeline.cc    # UVC camera configuration flow implementation, including JPEG frame data, display device, decoder, format conversion noai_2d, dumping one frame of AI inference image, inserting one frame of display image, etc.
│    ├── uvc_pipeline.h     # UVC camera configuration flow header file
│    └── CMakeLists.txt     # CMakeLists.txt for UVC camera configuration flow
├── utils                   # kmodel and scripts that can be used directly
├── CMakeLists.txt          # CMakeLists.txt, used to build the entire application (Method 1)
├── build_app.sh            # Build script
└── Makefile                # Makefile, used to build the entire application (Method 2)
```

### Code Function Introduction

Taking the UVC+face detection task as an example, the functions of different files in the existing code are as follows:

| File Name                    |         Function     |
|--------------------------- | -----------------|
|ai_base.h|Provides the interfaces used in the model inference process|
|ai_bash.cc|Provides the implementation of the model inference methods defined in ai_bash.h|
|ai_utils.h|Provides common utility function interfaces|
|ai_utils.cc|Provides the implementation of the utility functions defined in ai_utils.h|
|scoped_timing.h|Provides timing tools to help development and debugging|
|setting.h|Provides interfaces for configuration parameters, implementing display device parameter configuration and AI inference image resolution configuration|
|uvc_pipeline.h|Provides interfaces for the UVC camera configuration flow, including JPEG frame data, display device, decoder, format conversion noai_2d, dumping one frame of AI inference image, inserting one frame of display image, etc.|
|uvc_pipeline.cc|Provides the implementation of the UVC camera configuration flow interfaces defined in uvc_pipeline.h|
|face_detection.h|Provides preprocessing, inference, postprocessing, result drawing and other interfaces for specific task scenarios (here is face detection)|
|face_detection.cc|Provides the implementation of the task scenario interfaces defined in face_detection.h|
|anchors_320.cc|Anchors data used by the face detection task|
|anchors_640.cc|Anchors data used by the face detection task|
|main.cc|Main function implementation, implementing specific AI application scenarios based on the interfaces provided by face_detection.h|

- `ai_base.h` and `ai_base.cc` implement the encapsulated base class for model inference, implementing the `kmodel` initialization, model input and output initialization, running, and output retrieval interfaces. See the file comments for the code; `scoped_timing.h` provides timing tools; **These files generally do not need to be modified**.

- `ai_utils.h` and `ai_utils.cc` provide general utility functions, mainly data access and common preprocessing methods. **If the provided methods cannot meet your needs, you can modify these two files to add new methods; if they are sufficient, no modification is needed**.

- `setting.h`, `uvc_pipeline.h`, and `uvc_pipeline.cc` implement the configuration and operations of the UVC camera, display device, decoder, noai2d format conversion, dump frames, and insert display frames, as well as AI inference frame acquisition and OSD display overlay methods. Currently, it supports two display modes: `LT9611 HDMI 1920*1080` and `ST7701 LCD 800*480`; **You only need to modify this file if you need to add new screen support; otherwise, it can remain unchanged**.

- `face_detection.h`, `face_detection.cc`, and `main.cc` are files that users **need to write themselves** when developing new AI applications. You can refer to the corresponding files under `src/rtsmart/examples/ai/uvc_face_detection` for writing. Among them, the header file and implementation file of the task scenario mainly **implement the input preprocessing, inference (generally directly call the `run` method in `ai_base.h`), and model postprocessing part of the task model**; the `main.cc` file needs to modify the logic of the model inference part, including **the instantiation of the specific task scenario class, and the calls to the preprocessing, model inference, postprocessing, and result drawing interfaces**.

### Code Details

#### `setting.h` Configuration Description

The macro definition parameters configured in `setting.h` are mainly used to set the camera output image, screen display, OSD layer, and the resolution of the AI inference image, etc.

|Macro Definition Parameter|Description|
|:-:|:-:|
|`UVC_WIDTH`|UVC camera output width|
|`UVC_HEIGHT`|UVC camera output height|
|`DISPLAY_MODE`|Display mode, 0 is 1920×1080 LT9611, 1 is 800×480 ST7701|
|`DISPLAY_WIDTH`|Display screen width|
|`DISPLAY_HEIGHT`|Display screen height|
|`AI_FRAME_WIDTH`|AI inference frame width|
|`AI_FRAME_HEIGHT`|AI inference frame height|
|`AI_FRAME_CHANNEL`|AI inference frame number of channels|

The details are as follows:

```cpp
#define UVC_WIDTH 640
#define UVC_HEIGHT 480
```

This is the resolution configured for the UVC camera, which currently supports `1920*1080` and `640*480`, and can be displayed on HDMI and LCD screens.

```cpp
#define DISPLAY_MODE 1    //Display mode, 0 is 1920×1080 lt9611, 1 is 800×480 st7701
#define DISPLAY_WIDTH 640
#define DISPLAY_HEIGHT 480
#define DISPLAY_ROTATE 1  // Rotation, 0 is no rotation, 1 is rotation 90 degrees
```

These parameters are mainly used to configure the resolution of the display screen.

```cpp
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 480
#define AI_FRAME_CHANNEL 3
```

This path is the data that is diverted from the UVC camera configuration image to the AI channel for model preprocessing. The width and height must be consistent with the UVC camera output image resolution. The output here is data in `JPEG` format. The data needs to be decoded by the decoder into `YUV420` data, and converted into `RGB888` format data through noai2d. The data layout is `HWC`, which needs to meet the model input.

#### `ai_base.h` Part Description

`AIBase` in `ai_base.h` is an encapsulated class that implements model inference, including model initialization, input and output shape, tensor initialization, model inference, and output retrieval.

```cpp
/**
 * @brief AI base class, encapsulating nncase-related operations
 * Mainly encapsulates nncase loading, input setting, running, and output retrieval operations. Subsequent demo development only needs to focus on model preprocessing and postprocessing
 */
class AIBase
{
public:
    /**
     * @brief AI base class constructor, loads kmodel, and initializes kmodel input and output
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
     * @brief Get kmodel output, the result is saved in the corresponding class property
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
     * @brief Initialize kmodel input for the first time, and get input shape
     * @return None
     */
    void set_input_init();

    /**
     * @brief Initialize kmodel output for the first time, and get output shape
     * @return None
     */
    void set_output_init();

    interpreter kmodel_interp_;        // kmodel interpreter, built from the kmodel file, responsible for model loading, input and output setting, and inference
    vector<unsigned char> kmodel_vec_; // The entire kmodel data obtained by reading the kmodel file, used to pass to the kmodel interpreter to load kmodel
};
```

In the above encapsulation structure, what we may use during application development is mainly the `shape` of the input and output `tensor`, which can be obtained from `input_shapes_` and `output_shapes_`. The data pointer of the output `tensor` can be obtained from `p_outputs_`, for example, to get the pointer of the first output of the model:

```cpp
float *output0 = p_outputs_[0];
```

#### Task Scenario Header File and Implementation File

`face_detection.h` and `face_detection.cc` are the **core files that users need to implement themselves during secondary development**.

In actual projects, you can name the files according to your own application scenario:

```bash
***.h  
***.cc
```

For example: `person_det.h`, `helmet_detect.cc`, `gesture_recog.h`, etc. In these two files, you need to implement a **Task Class**, which must:

```cpp
class YourTask : public AIBase
```

That is to say —— **Inherit AIBase and complete the specific task logic**.

This class is mainly responsible for 4 things:

| Module                    | Whether Must Be Written by Yourself | Function              |
| --------------------- | ------- | --------------- |
| **Preprocess**  | ✅Must Implement   | Convert the input image to the format required by the model |
| **Inference**  |  ✅Directly call the interface in AIBase   | Already encapsulated by AIBase    |
| **Postprocess** | ✅ Must Implement  | Convert model output into understandable results   |
| **Draw**       | ✅ Must Implement  | Draw the results on the image        |

Here, assume the header file and implementation of the application scenario class are `myapp.h` and `myapp.cc`, where the structure of `myapp.h` can be written by imitating `face_detection.h`:

```cpp
#ifndef _MYAPP_H
#define _MYAPP_H

#include <iostream>
#include <vector>
#include "ai_utils.h"
#include "ai_base.h"

using std::vector;


/**
 * @brief Custom data structure used in the postprocessing process. For example, a detection box needs to contain the coordinates xywh, classification index, and confidence. Define as needed
 */
typedef struct ExampleResults
{
    //The data structure to be used needs to be defined as needed
} ExampleResults;

/**
 * @brief Application class to be developed, inherits from AIBase
 * Mainly encapsulates the process of preprocessing, running, and postprocessing for each frame of image based on a specific application scenario
 */
class MyApp : public AIBase
{
public:
    /**
     * @brief Video stream inference, MyApp constructor, loads kmodel, and initializes kmodel input, output, and other parameters used by the application, such as thresholds, and configures the corresponding preprocessing method
     * @param kmodel_file kmodel file path
     * @param other_params Other parameters, such as various thresholds
     * @param image_size   Input shape of one frame of the camera AI channel image
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
     * @brief Preprocess
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
     * @brief kmodel inference result postprocessing, using the passed-in image_size, restores coordinate and other information to the original image resolution, and stores the result in results
     * @param image_size  Shape of the input image
     * @param results Postprocessing result storage container
     * @return None
     */
    void post_process(FrameCHWSize image_size,vector<ExampleReults> &results);

     /**
     * @brief Draw result
     * @param draw_frame  Transparent image (video OSD) or original image (single image inference) to be drawn on, of type cv::Mat
     * @param results     Postprocessing result
     * @return None
     */
    void draw_result(cv::Mat& draw_frame,vector<ExampleReults>& results);


    std::unique_ptr<ai2d_builder> ai2d_builder_; // ai2d builder
    runtime_tensor ai2d_out_tensor_;             // ai2d output tensor
    FrameCHWSize image_size_;                    // Shape of the input image
    FrameCHWSize input_size_;                    // Shape of the model input

    //Other member variables used by the current task scenario can be defined here, such as the classification map
    // ***
};

#endif
```

The interfaces defined above need to be implemented in `myapp.cc`, which will not be repeated here. You can refer to the code in `src/rtsmart/examples/ai/face_detection/src/face_detection.cc` and write accordingly.

##### Modification of `main.cc` File

- **Process Overview**

`main.cc` contains the logic of the entire task, including the steps of obtaining a frame of data from the UVC camera, creating a tensor, calling the application class's preprocessing, inference, postprocessing, and drawing results to implement the complete processing of one frame of data. The code for video inference in `main.cc` is as follows. You need to imitate this part of the code according to your own scenario. Pseudocode is given here, and the specific introduction is in the comments:

```cpp
FrameCHWSize image_size={AI_FRAME_CHANNEL,AI_FRAME_HEIGHT, AI_FRAME_WIDTH};
// Create an empty runtime_tensor object to store input data
dims_t in_shape { 1, AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH };
runtime_tensor input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8,in_shape, hrt::pool_shared).expect("cannot create input tensor");
auto input_buf = input_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();

// Create a UVC_PipeLine object to process the video stream
UVC_PipeLine pl(debug_mode);
// Initialize the PipeLine object
pl.Create();
// Create a DumpRes object to store frame data
DumpRes dump_res;
// Initialize the task scenario class instance, and initialize the postprocessing result storage container
MyApp my_app(argv[1], atof(argv[2]),atof(argv[3]), image_size, atoi(argv[5]));
vector<ExampleResults> results;

std::vector<uint8_t> chw_vec;
std::vector<cv::Mat> rgbChannels(3);
cv::Mat ori_img;
int ret=0;
// Enter the while loop, continuously dump images
while (!isp_stop)
{
    // Create a ScopedTiming object to calculate the total time
    ScopedTiming st("total time", 1);
    // Obtain a frame of data from PipeLine, and create a tensor
    ret=pl.GetFrame(dump_res);
    if(ret){
        printf("GetFrame fail\n");
        continue;
    }
    {
        ScopedTiming st("create tensor", debug_mode);
        // Get the virtual address of the current frame's image frame. And create a cv::Mat object ori_img based on this
        void* vaddr=reinterpret_cast<void*>(dump_res.virt_addr);
        ori_img = cv::Mat(image_size.height, image_size.width, CV_8UC3, vaddr);
        // Convert ori_img from hwc format to chw format, stored in chw_vec
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
    //Preprocessing, inference, postprocessing
    my_app.pre_process(input_tensor);
    my_app.inference();
    my_app.post_process(image_size,results);
    //The difference from MIPI camera is that it is drawn directly on the original image, not on a transparent image
    my_app.draw_result(ori_img,results);
    // Release frame data
    pl.ReleaseFrame(dump_res);
}
pl.Destroy();
```

The video stream inference process is run by opening a separate thread. If the user inputs `q`, the variable `isp_stop` is set to `True` to implement the exit function.

#### Build File `CMakeLists.txt` and Compilation Script `build_app.sh`

For `src/CMakeLists.txt` in the source code directory, you need to modify it to add subdirectories to be compiled. Here the source code is split into two `CMakeLists.txt` files, but they can also be combined into one. Users unfamiliar with this part can ignore it:

```cmake
add_subdirectory(src) 
```

For `uvc_face_detection/src/CMakeLists.txt` in the face detection task subdirectory, you need to modify the files to be compiled and the name of the generated executable elf:

```cmake
set(src main.cc face_detection.cc anchors_320.cc anchors_640.cc ai_base.cc ai_utils.cc uvc_pipeline.cc)
set(bin uvc_face_detection.elf)
```

The compilation script file `uvc_face_detection/build_app.h` defines the environment variables used for compilation, and you also need to modify the elf file copy path:

```shell
# Copy the generated elf and kmodel files to the k230_bin directory
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

### Compile Code

#### Switch Development Board and Compile Application

Return to the `RTOS` root directory and check the supported development boards:

```shell
make list-def
```

Switch the development board in use and compile, switch to the development board you are using:

```shell
make ***_defconfig

make -j
```

After execution, the compiled image will be generated in the `output` directory. We hope users can place application code under the `src/rtsmart/examples/ai` directory, you can refer to the `uvc_face_detection` implementation in that directory.

- **Compilation Method One**

After the code modifications described in the above sections are completed, go to the same level directory as `build_app.sh` and execute:

```bash
build_app.sh
```

After the script execution is completed, the compilation intermediate products are located in the `build` directory, and the deployment summary file is located in the `k230_bin` directory.

- **Compilation Method Two**

Execute `make menuconfig` in the `RTOS SDK` root directory, select `RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build UVC+AI Programs`, save and exit. As shown in the figure below:

![rtos_uvc_facedet_menuconfig](https://www.kendryte.com/api/post/attachment?id=842)

Because the `Makefile` is provided, directly execute

```bash
make -j
```

This way the deployment summary file will be directly compiled into the `/sdcard/app/examples/ai/uvc_face_detection` directory in the firmware during the compilation process. You can also **directly go to the corresponding directory** and execute:

```bash
make -j
```

This command can also achieve compilation, and the compilation product will be generated in the `k230_bin` directory. The compilation process implements incremental compilation.

### Development Board Deployment

Flash the firmware and power on. For firmware flashing, refer to the document: [how_to_flash](../../userguide/how_to_flash.md).

A virtual disk `CanMV` can be seen in the drive letter. Copy the compiled elf file, kmodel file, and other used files (such as test images) under `k230_bin` to the `CanMV/sdcard` directory.

Then use a serial port tool to connect to the development board, and execute `uvc_face_detect_isp.sh` in the command line. Note that the parameters must match the position and type in the code.

The deployment effect is shown in the figure below:

![uvc_deploy_res](https://www.kendryte.com/api/post/attachment?id=843)
