# KPU Application Development Guide

## Overview

**KPU (Knowledge Processing Unit)** is a hardware acceleration engine designed for edge AI on the K230. It is a highly optimized **deep learning accelerator** that can **efficiently execute dense computation tasks in neural network models**. KPU supports various mainstream visual neural network model architectures and is suitable for a wide range of edge visual AI application scenarios. The figure below shows the position of KPU in the K230:

![kpu_in_system](https://www.kendryte.com/api/post/attachment?id=610)

## Overall KPU Inference Flow

When using the **KPU Runtime API** to perform inference on a model, the overall flow is as follows:

<div class="mermaid">
graph TD;
    LoadModel("Initialize Interpreter<br/>Load Model") -->
    SetInput("Get Input Shape<br/>Initialize Input Tensor") -->
    SetOutput("Get Output Shape<br/>Initialize Output Tensor") -->
    GetFrame("Get Data to be Inferred<br/>Read Image or Camera Frame") -->
    SetPreprocessParam("Set Preprocessing Parameters<br/>Configure AI2D / Input-Output Tensor") -->
    PreProcess("Execute Preprocessing<br/>Make Input Data Match Model Requirements") -->
    KPURun("Execute KPU Model Inference") -->
    GetOutput("Get Model Output Pointer") -->
    PostProcess("Post-process Model Output") -->
    DrawResult("Draw Result to Image or Screen");
</div>

The main components involved in the inference process are `AI2D` and `KPU`.

* **AI2D**

  * Responsible for image preprocessing before model inference
  * The preprocessing process is implemented by hardware, which can significantly improve runtime efficiency

* **Interpreter**

  * Responsible for executing model inference on KPU

The input and output data types of both are **`host_runtime_tensor`**.

The input Tensor of the model:

* May be **single input**
* May also be **multiple inputs**

The output Tensor of AI2D is generally used directly as the input of the model. During the program initialization phase, it is common to **initialize both simultaneously**:

* `ai2d_builder`
* `Interpreter`

And uniformly complete the creation and configuration of input/output Tensor. The logical relationship between the two is shown in the figure below:

![AI2D](https://www.kendryte.com/api/post/attachment?id=511)

For **single-input models**, you can bind:

* **AI2D's output Tensor**
* **Interpreter's input Tensor**

as the same `host_runtime_tensor`, thereby:

* Avoiding intermediate copies
* Saving one Tensor's worth of memory
* Improving overall execution efficiency

If AI2D is not used for preprocessing, you can also choose:

* Use **OpenCV** to complete preprocessing on the CPU
* Then manually create the corresponding `host_runtime_tensor` as model input

The overall flow is shown in the figure below:

![pipe\_inference](https://www.kendryte.com/api/post/attachment?id=510)

## Model Inference Example

This section takes the **YOLOv8 object detection model** as an example to introduce the overall flow of the deployment code based on KPU.

The example source code is located at:

```bash
src/rtsmart/examples/ai/usage_kpu
```

After entering the above directory, execute:

```bash
./build_app.sh
```

After compilation is complete, you can find the compiled executable files in the directory:

```bash
k230_bin/
```

which includes:

* **Image inference example**
* **Camera real-time inference example**

Copy the corresponding executable file to the development board to run it.

## Code Analysis

The following will take the **image inference example** as an example to analyze the `main` function in the code step by step, explaining the complete implementation flow of model loading, preprocessing, inference, and post-processing.

The source code is as follows:

```c++
int main(int argc, char *argv[])
{
    // Print program name and compilation time
    std::cout << "case " << argv[0] << " build " << __DATE__ << " " << __TIME__ << std::endl;

    // Parameter validation
    if (argc < 4)
    {
        std::cerr << "Usage: " << argv[0] << " <kmodel> <image> <debug_mode>" << std::endl;
        return -1;
    }

    // Debug mode
    int debug_mode=atoi(argv[3]);

    // =========================
    // 1. Initialize interpreter and load KModel
    // =========================
    interpreter interp;     
    std::ifstream ifs(argv[1], std::ios::binary);
    interp.load_model(ifs).expect("Invalid kmodel");

    // Initialize input/output shape containers and output pointer container
    vector<vector<int>> input_shapes;   
    vector<vector<int>> output_shapes;
    vector<float *> p_outputs;

    // =========================
    // 2. Initialize input Tensor, get input Shape
    // =========================
    for (int i = 0; i < interp.inputs_size(); i++)
    {
        auto desc = interp.input_desc(i);
        auto shape = interp.input_shape(i);
        auto tensor = host_runtime_tensor::create(desc.datatype, shape, hrt::pool_shared).expect("cannot create input tensor");
        interp.input_tensor(i, tensor).expect("cannot set input tensor");
        vector<int> in_shape;
        if (debug_mode> 1)
            std::cout<<"input "<< std::to_string(i) <<" datatype: "<<std::to_string(desc.datatype)<<" , shape: ";
        for (int j = 0; j < shape.size(); ++j)
        {
            in_shape.push_back(shape[j]);
            if (debug_mode> 1)
                std::cout<<shape[j]<<" ";
        }
        if (debug_mode> 1)
            std::cout<<std::endl;
        input_shapes.push_back(in_shape);
    }

    // =========================
    // 3. Initialize output Tensor, get output Shape
    // =========================
    for (size_t i = 0; i < interp.outputs_size(); i++)
    {
        auto desc = interp.output_desc(i);
        auto shape = interp.output_shape(i);
        auto tensor = host_runtime_tensor::create(desc.datatype, shape, hrt::pool_shared).expect("cannot create output tensor");
        interp.output_tensor(i, tensor).expect("cannot set output tensor");
        vector<int> out_shape;
        if (debug_mode> 1)
            std::cout<<"output "<< std::to_string(i) <<" datatype: "<<std::to_string(desc.datatype)<<" , shape: ";
        for (int j = 0; j < shape.size(); ++j)
        {
            out_shape.push_back(shape[j]);
            if (debug_mode> 1)
                std::cout<<shape[j]<<" ";
        }
        if (debug_mode> 1)
            std::cout<<std::endl;
        output_shapes.push_back(out_shape);
    }

    // =========================
    // 4. Read image and convert to CHW + RGB; determine whether the input format is HWC or CHW based on the model input
    // =========================
    cv::Mat ori_img = cv::imread(argv[2]);
    int ori_w = ori_img.cols;
    int ori_h = ori_img.rows;
    std::vector<uint8_t> chw_vec;
    std::vector<cv::Mat> bgrChannels(3);
    cv::split(ori_img, bgrChannels);
    for (auto i = 2; i > -1; i--)
    {
        std::vector<uint8_t> data = std::vector<uint8_t>(bgrChannels[i].reshape(1, 1));
        chw_vec.insert(chw_vec.end(), data.begin(), data.end());
    }

    // =========================
    // 5. Calculate Pad + Resize parameters, pad on the short side while maintaining the original aspect ratio
    // =========================
    int width = input_shapes[0][3];
    int height = input_shapes[0][2];
    float ratiow = (float)width / ori_w;
    float ratioh = (float)height / ori_h;
    float ratio = ratiow < ratioh ? ratiow : ratioh;
    int new_w = (int)(ratio * ori_w);
    int new_h = (int)(ratio * ori_h);
    float dw = (float)(width - new_w) / 2;
    float dh = (float)(height - new_h) / 2;
    int top = (int)(roundf(0));
    int bottom = (int)(roundf(dh * 2 + 0.1));
    int left = (int)(roundf(0));
    int right = (int)(roundf(dw * 2 - 0.1));

    // =========================
    // 6. Construct AI2D input Tensor and write data
    // =========================
    dims_t ai2d_in_shape{1, 3, ori_h, ori_w};
    runtime_tensor ai2d_in_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto input_buf = ai2d_in_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
    hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    // =========================
    // 7. Directly use the model input Tensor as AI2D output
    // =========================
    runtime_tensor ai2d_out_tensor = interp.input_tensor(0).expect("cannot get input tensor");
    dims_t out_shape = ai2d_out_tensor.shape();

    // =========================
    // 8. Configure AI2D preprocessing parameters, using both pad and resize preprocessing methods
    // =========================
    ai2d_datatype_t ai2d_dtype{ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, ai2d_in_tensor.datatype(), ai2d_out_tensor.datatype()};
    ai2d_crop_param_t crop_param{false, 0, 0, 0, 0};
    ai2d_shift_param_t shift_param{false, 0};
    ai2d_pad_param_t pad_param{true, {{0, 0}, {0, 0}, {top, bottom}, {left, right}}, ai2d_pad_mode::constant, {114, 114, 114}};
    ai2d_resize_param_t resize_param{true, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{false, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};

    // =========================
    // 9. Build and execute AI2D
    // =========================
    ai2d_builder builder(ai2d_in_shape, out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param);
    builder.build_schedule();
    builder.invoke(ai2d_in_tensor,ai2d_out_tensor).expect("error occurred in ai2d running");

    // =========================
    // 10. Execute model inference
    // =========================
    interp.run().expect("error occurred in running model");

    // =========================
    // 11. Get model output
    // =========================
    p_outputs.clear();
    for (int i = 0; i < interp.outputs_size(); i++)
    {
        auto out = interp.output_tensor(i).expect("cannot get output tensor");
        auto buf = out.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_read).unwrap().buffer();
        float *p_out = reinterpret_cast<float *>(buf.data());
        p_outputs.push_back(p_out);
    }

    // =========================
    // 12. Post-processing (decoding + NMS), decode detection boxes from model output and perform non-maximum suppression
    // =========================
    std::vector<std::string> classes{"apple","banana","orange"};
    float conf_thresh=0.25;
    float nms_thresh=0.45;
    int class_num=classes.size();
    std::vector<cv::Scalar> class_colors = getColorsForClasses(class_num);

    // Transpose the output so that each detection box's features are in contiguous memory, facilitating processing
    float *output0 = p_outputs[0];
    int f_len=class_num+4;
    int num_box=((input_shapes[0][2]/8)*(input_shapes[0][3]/8)+(input_shapes[0][2]/16)*(input_shapes[0][3]/16)+(input_shapes[0][2]/32)*(input_shapes[0][3]/32));
    float *output_det = new float[num_box * f_len];

    for(int r = 0; r < num_box; r++)
    {
        for(int c = 0; c < f_len; c++)
        {
            output_det[r*f_len + c] = output0[c*num_box + r];
        }
    }

    // Parse detection boxes and map back to original image coordinates
    std::vector<Bbox> bboxes;
    for(int i=0;i<num_box;i++){
        float* vec=output_det+i*f_len;
        float box[4]={vec[0],vec[1],vec[2],vec[3]};
        float* class_scores=vec+4;
        float* max_class_score_ptr=std::max_element(class_scores,class_scores+class_num);
        float score=*max_class_score_ptr;
        int max_class_index = max_class_score_ptr - class_scores;
        if(score>conf_thresh){
            Bbox bbox;
            float x_=box[0]/ratio*1.0;
            float y_=box[1]/ratio*1.0;
            float w_=box[2]/ratio*1.0;
            float h_=box[3]/ratio*1.0;
            int x=int(MAX(x_-0.5*w_,0));
            int y=int(MAX(y_-0.5*h_,0));
            int w=int(w_);
            int h=int(h_);
            if (w <= 0 || h <= 0) { continue; }
            bbox.box=cv::Rect(x,y,w,h);
            bbox.confidence=score;
            bbox.index=max_class_index;
            bboxes.push_back(bbox);
        }

    }

    // Execute non-maximum suppression
    std::vector<int> nms_result;
    nms(bboxes, conf_thresh, nms_thresh, nms_result);

    // =========================
    // 13. Draw detection results and save
    // =========================
    for (int i = 0; i < nms_result.size(); i++) {
        int res=nms_result[i];
        cv::Rect box=bboxes[res].box;
        int idx=bboxes[res].index;
        cv::rectangle(ori_img, box, class_colors[idx], 2, 8);
        cv::putText(ori_img, classes[idx], cv::Point(box.x + 5, box.y - 10), cv::FONT_HERSHEY_DUPLEX, 1, class_colors[idx], 2, 0);
    }
    cv::imwrite("result.jpg", ori_img); 
    
    delete[] output_det;

    return 0;
}
```

The video stream inference code is similar, except that the inference frame data is no longer read from an image using OpenCV, but is obtained from the camera. The following will take **camera real-time video stream inference** as an example, and analyze the `camera_inference` function in the code step by step, explaining the complete implementation flow of model loading, preprocessing, inference, and post-processing.

The code structure tree is as follows:

```shell
yolov8_run_camera
├── main.cc            # Inference core code, including the entire inference process
├── scoped_timing.h    # Timing utility header file
├── setting.h          # Basic configuration file, configuring screen, resolution, and other parameters
├── video_pipeline.cc  # Video processing pipeline implementation, including video display initialization, frame acquisition, display, etc.
├── video_pipeline.h   # Video processing pipeline header file, defining functions such as video display initialization, frame acquisition, display, etc.
└── CMakeLists.txt     # CMake build file, used to compile the project
```

The source code is as follows:

```c++
int camera_inference(char *argv[])
{
    /************************************************************
     * Phase 0: Parameter parsing and basic variable initialization
     ************************************************************/
    int debug_mode = atoi(argv[4]);

    // AI input image size (CHW)
    FrameCHWSize image_size = {AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH};

    // OSD layer (RGBA), used to draw detection boxes and text
    cv::Mat draw_frame(OSD_HEIGHT, OSD_WIDTH, CV_8UC4, cv::Scalar(0, 0, 0, 0));

    /************************************************************
     * Phase 1: Video pipeline initialization (ISP → DRM → OSD)
     ************************************************************/
    PipeLine pl(debug_mode);
    pl.Create();

    // Stores one frame of data acquired by ISP (virtual address + physical address)
    DumpRes dump_res;

    /************************************************************
     * Phase 2: KModel loading and Interpreter initialization
     ************************************************************/
    interpreter interp;
    std::ifstream ifs(argv[1], std::ios::binary);
    interp.load_model(ifs).expect("Invalid kmodel");

    /************************************************************
     * Phase 3: Input / Output Tensor initialization and Shape recording
     ************************************************************/
    vector<vector<int>> input_shapes;
    vector<vector<int>> output_shapes;
    vector<float *> p_outputs;

    // ---------- Initialize model input Tensor ----------
    for (int i = 0; i < interp.inputs_size(); i++)
    {
        auto desc = interp.input_desc(i);
        auto shape = interp.input_shape(i);

        auto tensor = host_runtime_tensor::create(
            desc.datatype, shape, hrt::pool_shared)
            .expect("cannot create input tensor");

        interp.input_tensor(i, tensor).expect("cannot set input tensor");

        vector<int> in_shape;
        if (debug_mode > 1)
            std::cout << "input " << i << " datatype: " << desc.datatype << " , shape: ";

        for (int j = 0; j < shape.size(); ++j)
        {
            in_shape.push_back(shape[j]);
            if (debug_mode > 1)
                std::cout << shape[j] << " ";
        }

        if (debug_mode > 1)
            std::cout << std::endl;

        input_shapes.push_back(in_shape);
    }

    // ---------- Initialize model output Tensor ----------
    for (size_t i = 0; i < interp.outputs_size(); i++)
    {
        auto desc = interp.output_desc(i);
        auto shape = interp.output_shape(i);

        auto tensor = host_runtime_tensor::create(
            desc.datatype, shape, hrt::pool_shared)
            .expect("cannot create output tensor");

        interp.output_tensor(i, tensor).expect("cannot set output tensor");

        vector<int> out_shape;
        if (debug_mode > 1)
            std::cout << "output " << i << " datatype: " << desc.datatype << " , shape: ";

        for (int j = 0; j < shape.size(); ++j)
        {
            out_shape.push_back(shape[j]);
            if (debug_mode > 1)
                std::cout << shape[j] << " ";
        }

        if (debug_mode > 1)
            std::cout << std::endl;

        output_shapes.push_back(out_shape);
    }

    /************************************************************
     * Phase 4: Calculate Resize + Padding parameters (YOLO LetterBox)
     ************************************************************/
    int width  = input_shapes[0][3];
    int height = input_shapes[0][2];

    float ratiow = (float)width  / AI_FRAME_WIDTH;
    float ratioh = (float)height / AI_FRAME_HEIGHT;
    float ratio  = ratiow < ratioh ? ratiow : ratioh;

    int new_w = (int)(ratio * AI_FRAME_WIDTH);
    int new_h = (int)(ratio * AI_FRAME_HEIGHT);

    float dw = (float)(width  - new_w) / 2;
    float dh = (float)(height - new_h) / 2;

    int top    = (int)(roundf(0));
    int bottom = (int)(roundf(dh * 2 + 0.1));
    int left   = (int)(roundf(0));
    int right  = (int)(roundf(dw * 2 - 0.1));

    /************************************************************
     * Phase 5: AI2D Tensor and Builder configuration
     ************************************************************/
    dims_t ai2d_in_shape{1, AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH};

    runtime_tensor ai2d_in_tensor;

    // Directly reuse the model input Tensor as AI2D output, avoiding extra copies
    runtime_tensor ai2d_out_tensor =
        interp.input_tensor(0).expect("cannot get input tensor");

    dims_t out_shape = ai2d_out_tensor.shape();

    // AI2D data type configuration (NCHW → NCHW, uint8)
    ai2d_datatype_t ai2d_dtype{
        ai2d_format::NCHW_FMT,
        ai2d_format::NCHW_FMT,
        typecode_t::dt_uint8,
        typecode_t::dt_uint8};

    // Parameters for each AI2D functional module
    ai2d_crop_param_t   crop_param{false, 0, 0, 0, 0};
    ai2d_shift_param_t  shift_param{false, 0};
    ai2d_pad_param_t    pad_param{
        true,
        {{0, 0}, {0, 0}, {top, bottom}, {left, right}},
        ai2d_pad_mode::constant,
        {114, 114, 114}};
    ai2d_resize_param_t resize_param{
        true,
        ai2d_interp_method::tf_bilinear,
        ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{
        false,
        ai2d_interp_method::cv2_bilinear,
        0, 0, 127, 1,
        {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};

    // Build AI2D scheduler
    ai2d_builder builder(
        ai2d_in_shape,
        out_shape,
        ai2d_dtype,
        crop_param,
        shift_param,
        pad_param,
        resize_param,
        affine_param);

    builder.build_schedule();

    /************************************************************
     * Phase 6: Initialization of post-processing and drawing related parameters
     ************************************************************/
    std::vector<std::string> classes{"apple", "banana", "orange"};

    float conf_thresh = atof(argv[2]);
    float nms_thresh  = atof(argv[3]);
    int class_num     = classes.size();

    std::vector<cv::Scalar> class_colors =
        getColorsForClasses(class_num);

    float *output0;
    int f_len = class_num + 4;

    int num_box =
        ((input_shapes[0][2] / 8)  * (input_shapes[0][3] / 8) +
         (input_shapes[0][2] / 16) * (input_shapes[0][3] / 16) +
         (input_shapes[0][2] / 32) * (input_shapes[0][3] / 32));

    float *output_det = new float[num_box * f_len];

    std::vector<Bbox> bboxes;

    /************************************************************
     * Phase 7: Main loop (capture → preprocess → inference → post-process → display)
     ************************************************************/
    while (!isp_stop)
    {
        // ---------- Get one frame of ISP image ----------
        pl.GetFrame(dump_res);

        // ---------- Create AI2D input Tensor (zero-copy binding to ISP Buffer) ----------
        ai2d_in_tensor = host_runtime_tensor::create(
            typecode_t::dt_uint8,
            ai2d_in_shape,
            {(gsl::byte *)dump_res.virt_addr,
             compute_size(ai2d_in_shape)},
            false,
            hrt::pool_shared,
            dump_res.phy_addr)
            .expect("cannot create input tensor");

        hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true)
            .expect("sync write_back failed");

        // ---------- Execute AI2D preprocessing ----------
        builder.invoke(ai2d_in_tensor, ai2d_out_tensor)
            .expect("error occurred in ai2d running");

        // ---------- Execute model inference ----------
        interp.run().expect("error occurred in running model");

        // ---------- Get model output ----------
        p_outputs.clear();
        for (int i = 0; i < interp.outputs_size(); i++)
        {
            auto out = interp.output_tensor(i).expect("cannot get output tensor");
            auto buf = out.impl()->to_host().unwrap()
                           ->buffer().as_host().unwrap()
                           .map(map_access_::map_read).unwrap()
                           .buffer();
            p_outputs.push_back(reinterpret_cast<float *>(buf.data()));
        }

        /********************************************************
         * Phase 8: Post-processing (decoding + confidence filtering + NMS)
         ********************************************************/
        output0 = p_outputs[0];

        // Transpose output layout (C x N → N x C)
        for (int r = 0; r < num_box; r++)
        {
            for (int c = 0; c < f_len; c++)
            {
                output_det[r * f_len + c] =
                    output0[c * num_box + r];
            }
        }

        bboxes.clear();

        for (int i = 0; i < num_box; i++)
        {
            float *vec = output_det + i * f_len;
            float box[4] = {vec[0], vec[1], vec[2], vec[3]};
            float *class_scores = vec + 4;

            auto max_class_score_ptr =
                std::max_element(class_scores,
                                 class_scores + class_num);

            float score = *max_class_score_ptr;
            int max_class_index =
                max_class_score_ptr - class_scores;

            if (score > conf_thresh)
            {
                Bbox bbox;

                float x_ = box[0] / ratio;
                float y_ = box[1] / ratio;
                float w_ = box[2] / ratio;
                float h_ = box[3] / ratio;

                int x = int(MAX(x_ - 0.5 * w_, 0));
                int y = int(MAX(y_ - 0.5 * h_, 0));
                int w = int(w_);
                int h = int(h_);

                if (w <= 0 || h <= 0)
                    continue;

                bbox.box = cv::Rect(x, y, w, h);
                bbox.confidence = score;
                bbox.index = max_class_index;
                bboxes.push_back(bbox);
            }
        }

        // ---------- Execute NMS ----------
        std::vector<int> nms_result;
        nms(bboxes, conf_thresh, nms_thresh, nms_result);

        /********************************************************
         * Phase 9: OSD drawing and display
         ********************************************************/
        draw_frame.setTo(cv::Scalar(0, 0, 0, 0));

        for (int i = 0; i < nms_result.size(); i++)
        {
            int res = nms_result[i];
            cv::Rect box = bboxes[res].box;
            int idx = bboxes[res].index;
            float score = bboxes[res].confidence;

            int x = int(box.x * float(OSD_WIDTH) / AI_FRAME_WIDTH);
            int y = int(box.y * float(OSD_HEIGHT) / AI_FRAME_HEIGHT);
            int w = int(box.width  * float(OSD_WIDTH) / AI_FRAME_WIDTH);
            int h = int(box.height * float(OSD_HEIGHT) / AI_FRAME_HEIGHT);

            cv::Rect new_box(x, y, w, h);

            cv::rectangle(draw_frame, new_box, class_colors[idx], 2, 8);
            cv::putText(draw_frame,
                        classes[idx] + " " + std::to_string(score),
                        cv::Point(MIN(new_box.x + 5, OSD_HEIGHT),
                                  MAX(new_box.y - 10, 0)),
                        cv::FONT_HERSHEY_DUPLEX,
                        1,
                        class_colors[idx],
                        2,
                        0);
        }

        // ---------- OSD composition and frame release ----------
        pl.InsertFrame(draw_frame.data);
        pl.ReleaseFrame(dump_res);
    }

    /************************************************************
     * Phase 10: Resource release
     ************************************************************/
    delete[] output_det;
    pl.Destroy();
    return 0;
}
```

### Code Compilation and Running

After the code is written, write a `CMakeLists.txt` or `Makefile` to compile the source code. For the above example, you can execute the `build_app.sh` script in the `src/rtsmart/examples/ai/usage_kpu/` directory to compile. The compiled artifacts are in the `k230_bin` directory. Copy them to the TF card with the flashed firmware, and execute the corresponding command to run the program.

Infer with yolov8n static image:

```shell
./yolov8_image.elf best.kmodel test.jpg 2
```

The image inference result will be saved as an image, as shown below:

![image_inference_res](https://www.kendryte.com/api/post/attachment?id=845)

Infer with yolov8 camera data:

```shell
./yolov8_camera.elf best.kmodel 0.5 0.45 2
```

The camera inference result will be displayed on the screen in real time, as shown below:

![camera_inference_res](https://www.kendryte.com/api/post/attachment?id=846)

The above process is detailed in explaining the steps of model conversion and model inference using kpu. It does not apply to all scenarios. You can refer to the above code for application development in different scenarios.
