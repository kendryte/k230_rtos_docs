# KPU 应用开发指南

## 概述

**KPU（Knowledge Processing Unit）** 是K230上为应对边缘AI设计的硬件加速引擎，是一个高度优化的**深度学习加速器**，其可以**高效执行神经网络模型中的密集计算任务**。KPU支持各种主流的视觉神经网络模型结构，适用于广泛的边缘视觉AI应用场景。下图展示了KPU在K230中的位置：

![kpu_in_system](https://www.kendryte.com/api/post/attachment?id=610)

## KPU 推理整体流程

使用 **KPU 运行时 API** 对模型进行推理时，整体流程如下所示：

<div class="mermaid">
graph TD;
    LoadModel("初始化 Interpreter<br/>加载模型") -->
    SetInput("获取输入 Shape<br/>初始化输入 Tensor") -->
    SetOutput("获取输出 Shape<br/>初始化输出 Tensor") -->
    GetFrame("获取待推理数据<br/>读取图片或摄像头帧") -->
    SetPreprocessParam("设置预处理参数<br/>配置 AI2D / 输入输出 Tensor") -->
    PreProcess("执行预处理<br/>使输入数据符合模型要求") -->
    KPURun("执行 KPU 模型推理") -->
    GetOutput("获取模型输出指针") -->
    PostProcess("对模型输出进行后处理") -->
    DrawResult("将结果绘制到图像或屏幕");
</div>

推理过程中主要涉及到的组件为 `AI2D` 和 `KPU`。

* **AI2D**

  * 负责模型推理前的图像预处理
  * 预处理过程由硬件实现，可显著提升运行效率

* **Interpreter**

  * 负责在 KPU 上执行模型推理

二者的输入与输出数据类型 **均为 `host_runtime_tensor`**。

模型的输入 Tensor：

* 可能是 **单输入**
* 也可能是 **多输入**

而 AI2D 的输出 Tensor 一般直接作为模型的输入使用。在程序初始化阶段，通常会**同时初始化**：

* `ai2d_builder`
* `Interpreter`

并统一完成输入 / 输出 Tensor 的创建与配置。二者的逻辑关系如下图所示：

![AI2D](https://www.kendryte.com/api/post/attachment?id=511)

对于 **单输入模型**，可以将：

* **AI2D 的输出 Tensor**
* **Interpreter 的输入 Tensor**

绑定为同一个 `host_runtime_tensor`，从而：

* 避免中间拷贝
* 节省一份 Tensor 内存
* 提高整体执行效率

如果不使用 AI2D 进行预处理，也可以选择：

* 使用 **OpenCV** 在 CPU 上完成预处理
* 然后手动创建对应的 `host_runtime_tensor` 作为模型输入

整体流程如下图所示：

![pipe\_inference](https://www.kendryte.com/api/post/attachment?id=510)

## 模型推理示例

本节以 **YOLOv8 目标检测模型** 为例，介绍基于 KPU 的部署代码整体流程。

示例源码位于：

```bash
src/rtsmart/examples/ai/usage_kpu
```

进入上述目录后，执行：

```bash
./build_app.sh
```

编译完成后，可在当前目录下的：

```bash
k230_bin/
```

目录中获得编译好的可执行文件，包含：

* **图像推理示例**
* **摄像头实时推理示例**

将对应可执行文件拷贝至开发板即可运行。

## 代码解析说明

下面将以 **图像推理示例** 为例，对代码中的 `main` 函数进行逐步解析，说明模型加载、预处理、推理以及后处理的完整实现流程。

源代码如下：

```c++
int main(int argc, char *argv[])
{
    // 打印程序名称与编译时间
    std::cout << "case " << argv[0] << " build " << __DATE__ << " " << __TIME__ << std::endl;

    // 参数校验
    if (argc < 4)
    {
        std::cerr << "Usage: " << argv[0] << " <kmodel> <image> <debug_mode>" << std::endl;
        return -1;
    }

    // 调试模式
    int debug_mode=atoi(argv[3]);

    // =========================
    // 1. 初始化interpreter并加载 KModel 模型
    // =========================
    interpreter interp;     
    std::ifstream ifs(argv[1], std::ios::binary);
    interp.load_model(ifs).expect("Invalid kmodel");

    // 初始化输入输出 shape 容器及输出指针容器
    vector<vector<int>> input_shapes;   
    vector<vector<int>> output_shapes;
    vector<float *> p_outputs;

    // =========================
    // 2. 初始化输入 Tensor，获取输入 Shape
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
    // 3. 初始化输出 Tensor，获取输出 Shape
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
    // 4. 读取图片并转为 CHW + RGB，依据模型输入确定输入是哪种格式的（HWC 或 CHW）
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
    // 5. 计算 Pad + Resize 参数，按照短边padding，保持原宽高比例
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
    // 6. 构造 AI2D 输入 Tensor 并写入数据
    // =========================
    dims_t ai2d_in_shape{1, 3, ori_h, ori_w};
    runtime_tensor ai2d_in_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto input_buf = ai2d_in_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
    hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    // =========================
    // 7. 直接使用模型输入 Tensor 作为 AI2D 输出
    // =========================
    runtime_tensor ai2d_out_tensor = interp.input_tensor(0).expect("cannot get input tensor");
    dims_t out_shape = ai2d_out_tensor.shape();

    // =========================
    // 8. 配置 AI2D 预处理参数，使用pad+resize两种预处理方法
    // =========================
    ai2d_datatype_t ai2d_dtype{ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, ai2d_in_tensor.datatype(), ai2d_out_tensor.datatype()};
    ai2d_crop_param_t crop_param{false, 0, 0, 0, 0};
    ai2d_shift_param_t shift_param{false, 0};
    ai2d_pad_param_t pad_param{true, {{0, 0}, {0, 0}, {top, bottom}, {left, right}}, ai2d_pad_mode::constant, {114, 114, 114}};
    ai2d_resize_param_t resize_param{true, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{false, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};

    // =========================
    // 9. 构建并执行 AI2D
    // =========================
    ai2d_builder builder(ai2d_in_shape, out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param);
    builder.build_schedule();
    builder.invoke(ai2d_in_tensor,ai2d_out_tensor).expect("error occurred in ai2d running");

    // =========================
    // 10. 执行模型推理
    // =========================
    interp.run().expect("error occurred in running model");

    // =========================
    // 11. 获取模型输出
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
    // 12. 后处理（解码 + NMS），根据模型输出解码检测框并执行非极大值抑制
    // =========================
    std::vector<std::string> classes{"apple","banana","orange"};
    float conf_thresh=0.25;
    float nms_thresh=0.45;
    int class_num=classes.size();
    std::vector<cv::Scalar> class_colors = getColorsForClasses(class_num);

    //将输出做transpose,让每个检测框的特征在连续内存中，方便处理
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

    // 解析检测框并映射回原图坐标
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

    // 执行非极大值抑制
    std::vector<int> nms_result;
    nms(bboxes, conf_thresh, nms_thresh, nms_result);

    // =========================
    // 13. 绘制检测结果并保存
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

视频流推理代码类似，只不过推理帧数据不在使用opencv从图片中读取，而是从摄像头中获取。下面将以 **摄像头实时视频流推理** 为例，对代码中的 `camera_inference` 函数进行逐步解析，说明模型加载、预处理、推理以及后处理的完整实现流程。

代码结构树如下：

```shell
yolov8_run_camera
├── main.cc            # 推理核心代码，包括推理的全部过程
├── scoped_timing.h    # 计时工具头文件
├── setting.h          # 基础配置文件，配置屏幕、分辨率等参数
├── video_pipeline.cc  # 视频处理管线实现，包括视频显示初始化、帧获取、显示等
├── video_pipeline.h   # 视频处理管线头文件，定义视频显示初始化、帧获取、显示等函数
└── CMakeLists.txt     # CMake构建文件，用于编译项目
```

源代码如下：

```c++
int camera_inference(char *argv[])
{
    /************************************************************
     * Phase 0: 参数解析与基础变量初始化
     ************************************************************/
    int debug_mode = atoi(argv[4]);

    // AI 输入图像尺寸（CHW）
    FrameCHWSize image_size = {AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH};

    // OSD 图层（RGBA），用于绘制检测框与文字
    cv::Mat draw_frame(OSD_HEIGHT, OSD_WIDTH, CV_8UC4, cv::Scalar(0, 0, 0, 0));

    /************************************************************
     * Phase 1: 视频管线初始化（ISP → DRM → OSD）
     ************************************************************/
    PipeLine pl(debug_mode);
    pl.Create();

    // 存放 ISP 获取的一帧数据（虚拟地址 + 物理地址）
    DumpRes dump_res;

    /************************************************************
     * Phase 2: KModel 加载与 Interpreter 初始化
     ************************************************************/
    interpreter interp;
    std::ifstream ifs(argv[1], std::ios::binary);
    interp.load_model(ifs).expect("Invalid kmodel");

    /************************************************************
     * Phase 3: 输入 / 输出 Tensor 初始化与 Shape 记录
     ************************************************************/
    vector<vector<int>> input_shapes;
    vector<vector<int>> output_shapes;
    vector<float *> p_outputs;

    // ---------- 初始化模型输入 Tensor ----------
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

    // ---------- 初始化模型输出 Tensor ----------
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
     * Phase 4: 计算 Resize + Padding 参数（YOLO LetterBox）
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
     * Phase 5: AI2D Tensor 与 Builder 配置
     ************************************************************/
    dims_t ai2d_in_shape{1, AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH};

    runtime_tensor ai2d_in_tensor;

    // 直接复用模型输入 Tensor 作为 AI2D 输出，避免额外拷贝
    runtime_tensor ai2d_out_tensor =
        interp.input_tensor(0).expect("cannot get input tensor");

    dims_t out_shape = ai2d_out_tensor.shape();

    // AI2D 数据类型配置（NCHW → NCHW，uint8）
    ai2d_datatype_t ai2d_dtype{
        ai2d_format::NCHW_FMT,
        ai2d_format::NCHW_FMT,
        typecode_t::dt_uint8,
        typecode_t::dt_uint8};

    // 各 AI2D 功能模块参数
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

    // 构建 AI2D 调度器
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
     * Phase 6: 后处理与绘制相关参数初始化
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
     * Phase 7: 主循环（采集 → 预处理 → 推理 → 后处理 → 显示）
     ************************************************************/
    while (!isp_stop)
    {
        // ---------- 获取一帧 ISP 图像 ----------
        pl.GetFrame(dump_res);

        // ---------- 创建 AI2D 输入 Tensor（零拷贝绑定 ISP Buffer） ----------
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

        // ---------- 执行 AI2D 预处理 ----------
        builder.invoke(ai2d_in_tensor, ai2d_out_tensor)
            .expect("error occurred in ai2d running");

        // ---------- 执行模型推理 ----------
        interp.run().expect("error occurred in running model");

        // ---------- 获取模型输出 ----------
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
         * Phase 8: 后处理（解码 + 置信度筛选 + NMS）
         ********************************************************/
        output0 = p_outputs[0];

        // 转置输出布局（C x N → N x C）
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

        // ---------- 执行 NMS ----------
        std::vector<int> nms_result;
        nms(bboxes, conf_thresh, nms_thresh, nms_result);

        /********************************************************
         * Phase 9: OSD 绘制与显示
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

        // ---------- OSD 合成并释放帧 ----------
        pl.InsertFrame(draw_frame.data);
        pl.ReleaseFrame(dump_res);
    }

    /************************************************************
     * Phase 10: 资源释放
     ************************************************************/
    delete[] output_det;
    pl.Destroy();
    return 0;
}
```

### 代码编译并运行

代码编写完成后，编写 `CMakeLists.txt` 或者 `Makefile` 对源码进行编译，针对上述示例，您可以在 `src/rtsmart/examples/ai/usage_kpu/` 目录下执行 `build_app.sh` 脚本进行编译。编译生成物在 `k230_bin` 目录下，将其拷贝到烧录固件的TF卡中，执行对应的命令运行程序。

推理yolov8n 静态图：

```shell
./yolov8_image.elf best.kmodel test.jpg 2
```

图像推理结果会保存为图片，推理结果如下图：

![image_inference_res](https://www.kendryte.com/api/post/attachment?id=845)

推理yolov8 摄像头数据：

```shell
./yolov8_camera.elf best.kmodel 0.5 0.45 2
```

摄像头推理结果会实时显示在屏幕上，推理效果如下图：

![camera_inference_res](https://www.kendryte.com/api/post/attachment?id=846)

上述过程详细在于说明模型转换和使用kpu进行模型推理的步骤，并不适用于所有的场景，您可以参考上述代码进行不同场景的应用开发。
