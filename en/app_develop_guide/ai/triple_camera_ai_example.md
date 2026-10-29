# Triple-Camera AI Application Development Guide

## Overview

The triple-camera AI application refers to simultaneously using three cameras on the K230 development board for AI inference, achieving multi-channel video stream processing and analysis. This example selects three GC2093 cameras, connected to the three MIPI camera interfaces of the K230 development board. It implements one channel of face detection, one channel of palm detection, and one channel of YOLO 80-class detection.

## Development Guide

### Involved Modules and Task Flow

- **Involved modules**:

1. **vicap (video input capture) module**: Configures camera (Sensor) device properties and each channel properties, including resolution, frame rate, data format, etc. It delivers camera data to the screen for display in a bound manner, and obtains camera frame data for AI inference.
1. **vo (video output) module**: Configures display device (Display) and each display layer properties, including position, resolution, frame rate, data format, etc. It implements real-time display of camera or other module-sent display frames. It includes a video layer and an OSD layer, which are responsible for displaying video frames and overlaid text information, respectively. The video layer only supports yuv format, and the OSD layer only supports rgb format.
1. **kpu module**: Responsible for loading `kmodel`, configuring the input and output `tensor` of `kmodel`, and completing model inference.
1. **ai2d module**: Responsible for preprocessing the model input image, supporting five defined preprocessing scaling methods. See the document [usage_ai2d](./usage_ai2d.md) for usage.

- **Task flow**:

The three cameras are managed by the Pipeline, and different cameras are distinguished by the sensor id passed in to obtain frame data for AI inference. Each camera has two channels: one is bound to the video layer of the vo module for real-time display of the original image, and the other is sent to the AI model for inference. The inference results are displayed through the OSD layer. This example uses three video layers and three OSD layers to achieve split-screen overlay display.

The above flow is shown in the figure below:

![triple_camera_ai_pipeline](https://www.kendryte.com/api/post/attachment?id=854)

### Code Structure Introduction

The example code is located in the `src/rtsmart/examples/ai/triple_camera_ai` directory. This example has simplified the triple-camera configuration encapsulation to make it easier for users to write similar code. The existing code structure is as follows:

```shell
triple_camera_ai
├── cmake
├── src
│    ├── ai_base.cc         # Model inference encapsulation implementation
│    ├── ai_base.h          # Model inference header file
│    ├── ai_utils.cc        # Model inference utility methods
│    ├── ai_utils.h         # Model inference utility methods header file
│    ├── anchors_320.cc     # Anchors used by the 320-input face detection model
│    ├── face_detection.cc  # Face detection task scenario implementation, including preprocessing, inference, postprocessing, and result drawing adapted to this scenario model
│    ├── hand_detection.cc  # Palm detection task scenario implementation, including preprocessing, inference, postprocessing, and result drawing adapted to this scenario model
│    ├── hand_detection.h   # Palm detection task scenario header file
│    ├── yolov8_detect.cc   # YOLO 80-class detection task scenario implementation, including preprocessing, inference, postprocessing, and result drawing adapted to this scenario model
│    ├── yolov8_detect.h    # YOLO 80-class detection task scenario header file
│    ├── main.cc            # Main function implementation, implementing specific AI application scenarios based on the interfaces provided by the three task header files
│    ├── scoped_timing.h    # Provides timing utilities to help with development and debugging
│    ├── setting.h          # Provides macro definitions for configuration parameters, implementing display device configuration and AI inference image resolution configuration
│    ├── video_pipeline.cc  # Triple-camera configuration flow implementation, including camera initialization, display device initialization, dumping one frame of AI inference image, inserting one frame of display image, etc.
│    ├── video_pipeline.h   # Triple-camera configuration flow header file
│    └── CMakeLists.txt     # CMakeLists.txt for triple-camera configuration flow
├── utils                   # kmodel and scripts that can be used directly
├── CMakeLists.txt          # CMakeLists.txt, used to build the entire application (Method 1)
├── build_app.sh            # Build script
└── Makefile                # Makefile, used to build the entire application (Method 2)
```

### Code Function Introduction

The following describes the roles of different files in the existing code:

| File Name                    |         Function     |
|--------------------------- | -----------------|
|ai_base.h|Provides interfaces used in the model inference process|
|ai_bash.cc|Provides the implementation of the model inference methods defined in ai_bash.h|
|ai_utils.h|Provides common utility function interfaces|
|ai_utils.cc|Provides the implementation of the utility functions defined in ai_utils.h|
|scoped_timing.h|Provides timing utilities to help with development and debugging|
|setting.h|Provides configuration parameter interfaces, implementing display device parameter configuration and AI inference image resolution configuration|
|video_pipeline.h|Provides interfaces for the triple-camera configuration flow, including camera initialization, display device initialization, dumping one frame of AI inference image, inserting one frame of display image, etc.|
|video_pipeline.cc|Provides the implementation of the triple-camera configuration flow interfaces defined in video_pipeline.h|
|face_detection.h|Provides interfaces for specific task scenarios (here face detection), including preprocessing, inference, postprocessing, and result drawing|
|face_detection.cc|Provides the implementation of the task scenario interfaces defined in face_detection.h|
|hand_detection.h|Provides interfaces for specific task scenarios (here palm detection), including preprocessing, inference, postprocessing, and result drawing|
|hand_detection.cc|Provides the implementation of the task scenario interfaces defined in hand_detection.h|
|yolov8_detect.h|Provides interfaces for specific task scenarios (here YOLO 80-class detection), including preprocessing, inference, postprocessing, and result drawing|
|yolov8_detect.cc|Provides the implementation of the task scenario interfaces defined in yolov8_detect.h|
|anchors_320.cc|Anchor data used by the face detection task|
|main.cc|Main function implementation, implementing specific AI application scenarios based on the interfaces provided by face_detection.h, hand_detection.h, and yolov8_detect.h, using three task scenarios to perform face detection, palm detection, and YOLO 80-class detection on the images captured by the three cameras. The KPUs are exclusive between multiple threads, requiring the addition of thread synchronization locks|

- `ai_base.h` and `ai_base.cc` implement the encapsulation base class for model inference, implementing the interfaces for `kmodel` initialization, model input and output initialization, running, and getting output. See the file comments for the code; `scoped_timing.h` provides timing utilities; **these files generally do not need to be modified**.

- `ai_utils.h` and `ai_utils.cc` provide common utility functions, mainly data access and common preprocessing methods. **If the provided methods cannot meet your needs, you can modify these two files to add new methods; if they are sufficient, no modification is needed**.

- `setting.h`, `video_pipeline.h`, and `video_pipeline.cc` implement the configuration and operations of UVC camera, display device, decoder, noai2d format conversion, dump frame and insert display frame, as well as AI inference frame acquisition and OSD display overlay methods. They currently support `LT9611 HDMI 1920*1080` and `ST7701 LCD 800*480` display modes; **you only need to modify these files if you need to add new screen support; otherwise, they can remain unchanged**. At the same time, if you need to add new camera channels, you also need to modify these files.

- `face_detection.h`, `face_detection.cc`, `hand_detection.h`, `hand_detection.cc`, `yolov8_detect.h`, `yolov8_detect.cc`, and `main.cc` are the files that users need to focus on when developing applications. For writing reference, see the corresponding files under `src/rtsmart/examples/ai/triple_camera_ai`. Users can replace the application tasks according to their own needs. The header file and implementation file of the task scenario mainly **implement the input preprocessing, inference (usually directly calling the `run` method in `ai_base.h`), and model postprocessing code for the task model**; the `main.cc` file needs to modify the logic of the multi-thread model inference, including **the instance initialization of specific task scenario classes, and the calls to preprocessing, model inference, postprocessing, and result drawing interfaces**.

### Code Details

#### `setting.h` Configuration Description

The macro definition parameters configured in `setting.h` are mainly used to set the camera output image, screen display, OSD layer, and the resolution of the AI inference image.

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

Details are as follows:

```cpp
#define ISP_WIDTH 1920
#define ISP_HEIGHT 1080
```

This is the resolution configured for the camera. On this basis, the image will be split into two channels for display and AI (single camera dual-channel). The image format and resolution given to different channels can be adjusted during the split process.

```cpp
#define DISPLAY_MODE 1    //Display mode, 0 for 1920×1080 LT9611, 1 for 800×480 ST7701
#define DISPLAY_WIDTH 400
#define DISPLAY_HEIGHT 240
#define DISPLAY_ROTATE 1  // Rotation, 0 for no rotation, 1 for 90-degree rotation
```

This channel is the data split from the camera configuration image to the display channel, and the configuration varies depending on the screen resolution and portrait/landscape orientation. Generally, `hdmi 1080P` can keep the current configuration unchanged, i.e., `lt9611`. The `st7701` screen is also supported, with a resolution of `800*480`. **Because the images from the three cameras need to be displayed in split-screen on the screen here, the `800*480` image needs to be split-screen displayed as `400*240`**.

`st7701` is essentially a `480*800` portrait screen, and 90-degree rotation needs to be implemented during display. The rotation function has now been encapsulated in the underlying vo module, and users can ignore this function and directly use it as a landscape screen.

```cpp
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 360
#define AI_FRAME_CHANNEL 3
```

This channel is the data split from the camera configuration image to the AI channel for model preprocessing. You can set it according to the AI requirements. The output here is data in `PIXEL_FORMAT_RGB_888_PLANAR` format of `3*360*640`. The data layout is `CHW`, which needs to satisfy the model input.

> **Note:**
>
> Here you need to distinguish between the resolution of the AI channel and the resolution of the model input:
> **AI channel resolution**: The resolution of the image data from the camera, **before** AI model **preprocessing**;
> **Model input resolution**: The data width and height directly delivered to the model **after preprocessing**;
> Only after preprocessing can the data of the AI channel be accurately converted into the model input data. For example, if the output resolution of the camera AI channel is 640×360 and the model requires an input of 320×320, a preprocessing process must be performed to meet the requirements.

```cpp
#define USE_OSD 1
#define OSD_WIDTH 400
#define OSD_HEIGHT 240
#define OSD_CHANNEL 4
```

This is the OSD drawing result channel configuration information, and its resolution needs to be consistent with the screen display resolution. There is no original image on the OSD frame, only the drawing result of the detection box. Overlaying this channel with the screen display channel gives the display effect. The created OSD frame data is a transparent image in `BGRA8888` format. After obtaining the AI results, detection boxes, key points, and other information are drawn on this frame, and then it is inserted into the display channel to achieve a two-channel overlay effect. **When configuring the OSD layer, set the x and y parameters of this layer to configure the display position of the image**. The display logical position is shown in the figure below:

![triple_camera_display](https://www.kendryte.com/api/post/attachment?id=855)

#### `ai_base.h` Description

`AIBase` in `ai_base.h` is the encapsulation class that implements model inference, including model initialization, input and output shape, tensor initialization, model inference, and output acquisition.

```cpp
/**
 * @brief AI base class, encapsulates nncase-related operations
 * Mainly encapsulates the loading, input setting, running, and output acquisition operations of nncase. Subsequent demo development only needs to focus on the model's preprocessing and postprocessing
 */
class AIBase
{
public:
    /**
     * @brief AI base class constructor, loads kmodel, and initializes kmodel input and output
     * @param kmodel_file kmodel file path
     * @param debug_mode  0 (no debugging), 1 (only show time), 2 (show all print information)
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

In the above encapsulation structure, what we may mainly use in application development are the `shape` of the input and output `tensor`, which can be obtained from `input_shapes_` and `output_shapes_`. The data pointer of the output `tensor` can be obtained from `p_outputs_`. For example, to get the pointer of the model's first output:

```cpp
float *output0 = p_outputs_[0];
```

#### Task Scenario Header File and Implementation File

`face_detection.h` and `face_detection.cc` are **the core files that users need to implement themselves during secondary development**.

In actual projects, you can name the files according to your own application scenario:

```bash
***.h  
***.cc
```

For example: `person_det.h`, `helmet_detect.cc`, `gesture_recog.h`, etc. In these two files, you need to implement a **Task Class**, which must:

```cpp
class YourTask : public AIBase
```

That is to say — **inherit AIBase and complete the specific task logic**.

This class is mainly responsible for 4 things:

| Module                    | Whether Must Be Written by Yourself | Function              |
| --------------------- | ------- | --------------- |
| **Preprocess**  | ✅Must implement   | Convert the input image into the format required by the model |
| **Inference**  |  ✅Directly call the interface in AIBase   | Already encapsulated by AIBase    |
| **Postprocess** | ✅ Must implement  | Convert the model output into understandable results   |
| **Draw**       | ✅ Must implement  | Draw the results on the image        |

Here, it is assumed that the header file and implementation of the application scenario class are `myapp.h` and `myapp.cc`. The structure of `myapp.h` can be written following `face_detection.h`:

```cpp
#ifndef _MYAPP_H
#define _MYAPP_H

#include <iostream>
#include <vector>
#include "ai_utils.h"
#include "ai_base.h"

using std::vector;


/**
 * @brief Custom data structure used in the postprocessing process, e.g., a detection box needs to include coordinates xywh, classification index, and confidence, which can be defined as needed
 */
typedef struct ExampleResults
{
    //The data structure used here needs to be defined as needed
} ExampleResults;

/**
 * @brief Application class to be developed, inheriting AIBase
 * Mainly encapsulates the process from preprocessing, running to postprocessing to give results for each frame of image based on specific application scenarios
 */
class MyApp : public AIBase
{
public:
    /**
     * @brief Video stream inference, MyApp constructor, loads kmodel, initializes kmodel input and output and other parameters used by the application such as thresholds, and configures the corresponding preprocessing method
     * @param kmodel_file kmodel file path
     * @param other_params Other parameters, such as various thresholds
     * @param image_size   The shape of one frame of input image from the camera AI channel
     * @param debug_mode  0 (no debugging), 1 (only show time), 2 (show all print information)
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
     * @brief Postprocess the kmodel inference result, using the passed-in image_size, restore the coordinates and other information to the original image resolution, and store the results in results
     * @param image_size  The shape of the input image
     * @param results Postprocess result storage container
     * @return None
     */
    void post_process(FrameCHWSize image_size,vector<ExampleReults> &results);

     /**
     * @brief Draw results
     * @param draw_frame  The transparent image (video OSD) or original image (single image inference) to draw results on, of type cv::Mat
     * @param results     Postprocess results
     * @return None
     */
    void draw_result(cv::Mat& draw_frame,vector<ExampleReults>& results);


    std::unique_ptr<ai2d_builder> ai2d_builder_; // ai2d builder
    runtime_tensor ai2d_out_tensor_;             // ai2d output tensor
    FrameCHWSize image_size_;                    // The shape of the input image
    FrameCHWSize input_size_;                    // The shape of the model input

    //Other member variables used by the current task scenario can be defined here, such as classification diagrams
    // ***
};

#endif
```

The interfaces defined above need to be specifically implemented in `myapp.cc`, which will not be repeated here.

##### Modification of `main.cc` File

- **Flow Overview**

`main.cc` contains the logic of the entire task, including the steps of obtaining one frame of data from a specified camera, creating a tensor, calling the application class's preprocessing, inference, postprocessing, and drawing results to achieve the complete processing of one frame of data.

The triple-camera task needs to be implemented using multiple threads, with each thread responsible for one application task. It needs to be specially noted here that the KPU is exclusive, and only one model is allowed to perform inference at the same time, so thread locks need to be added for resource management.

This example probes the sensors on CSI0, CSI1, and CSI2 using **2LANE** only; it does not provide a `-L` lane option. When using three cameras together, make sure the sensors have corresponding 2LANE configurations.

The sub-thread code in `main.cc` is not much different from the implementation in the documents [Single Model Application Development Guide](./single_model_example.md) and [Double Model Application Development Guide](./double_model_example.md). Because multi-threading is used, the initialization of `PipeLine` is implemented in the main thread and passed as a parameter to the sub-threads to obtain the AI model inference data frames and insert OSD frames. The main thread code is as follows:

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

    // 1. Create video pipeline (all three sensors are probed as 2LANE)
    PipeLine pl(debug_mode);
    if (pl.Create() != 0) {
        cout << "PipeLine Create failed, exit" << endl;
        return -1;
    }

    // 2. Camera mode
    std::thread t0(face_det_video_proc, std::ref(pl),argv, 0, 4);

    std::thread t1(hand_det_video_proc, std::ref(pl),argv, 1, 5);

    std::thread t2(yolov8_det_video_proc, std::ref(pl),argv, 2, 6);

    // The main thread waits for the exit command
    while (getchar() != 'q')
    {
        usleep(10000);
    }

    // Notify threads to exit
    face_det_isp_stop.store(true);
    t0.join();
    person_det_isp_stop.store(true);
    t1.join();
    hand_det_isp_stop.store(true);
    t2.join();
    // 3. Destroy the pipeline
    pl.Destroy();
    cout << "exit success" << endl;
    return 0;
}
```

The program exit is controlled by three thread loop variables:

```cpp
std::atomic<bool> face_det_isp_stop(false);
std::atomic<bool> person_det_isp_stop(false);
std::atomic<bool> hand_det_isp_stop(false);
```

When `q` is entered and the enter key is pressed, the three thread loop flag variables are set to `true`, and the threads will exit the loop and end.

#### Build file `CMakeLists.txt` and compilation script `build_app.sh`

For `src/CMakeLists.txt` in the source code directory, modifications are needed to add the subdirectories to be compiled. Here the source code is split into two `CMakeLists.txt`, which can also be combined into one. Users unfamiliar with this part can ignore it:

```cmake
add_subdirectory(src) 
```

For `triple_camera_ai/src/CMakeLists.txt` within the triple-camera AI application task subdirectory, modifications are needed to the files to be compiled and the generated executable ELF name:

```cmake
set(src main.cc face_detection.cc anchors_320.cc hand_detection.cc yolov8_detect.cc ai_base.cc ai_utils.cc video_pipeline.cc)
set(bin triple_cam_ai.elf)
```

The compilation script `triple_camera_ai/build_app.sh` defines the environment variables used for compilation, and also needs to modify the ELF file copy path:

```shell
# Copy the generated ELF and kmodel files to the k230_bin directory
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

### Compile Code

#### Switch Development Board and Compile Application

Return to the `RTOS` root directory and view the supported development boards:

```shell
make list-def
```

Switch the development board being used and compile. Switch to the development board you are using:

```shell
make ***_defconfig

make -j
```

After execution completes, the compiled image will be generated in the `output` directory.

- **Compilation Method One**

After the code modifications described in the previous sections are completed, navigate to the `src/rtsmart/examples/ai/triple_camera_ai` directory and execute:

```bash
build_app.sh
```

After the script execution is complete, the intermediate compilation products are located in the `build` directory, and the deployment summary files are located in the `k230_bin` directory.

- **Compilation Method Two**

Execute `make menuconfig` in the `RTOS SDK` root directory, select `RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build Triple Camera AI Programs`, save and exit. As shown in the figure below:

![rtos_triple_cam_ai_menuconfig](https://www.kendryte.com/api/post/attachment?id=856)

Because a `Makefile` is provided, directly execute

```bash
make -j
```

In this way, the deployment summary files will be directly compiled into the firmware at the `/sdcard/app/examples/ai/triple_camera_ai` directory during the compilation process. You can also **directly navigate to the corresponding directory** and execute:

```bash
make -j
```

This command can also achieve compilation, and the compilation products will be generated in the `k230_bin` directory. The compilation process supports incremental compilation.

### Development Board Deployment

Flash the firmware and power it on. For firmware flashing, refer to the documentation: [how_to_flash](../../userguide/how_to_flash.md).

You can see a virtual disk `CanMV` at the drive letter. Copy the elf file compiled under `k230_bin`, the kmodel file, and other used files such as test images to the `CanMV/sdcard` directory.

Then use a serial port tool to connect to the development board, and execute `run.sh` on the command line. Note that the parameters must match the positions and types in the code.

The deployment effect is shown in the figure below:

![triple_cam_ai_deploy_res](https://www.kendryte.com/api/post/attachment?id=857)
