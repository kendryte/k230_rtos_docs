# AI2D Application Development Guide

## Overview

`AI2D` is a hardware-accelerated image preprocessing module used to complete data processing before inference on the development board, in order to reduce CPU overhead and improve overall performance. `AI2D` provides **5 hardware-accelerated image preprocessing capabilities**, namely **Crop / Shift / Resize / Pad / Affine**.
In visual tasks such as object detection, a common **letterbox** preprocessing pipeline can be implemented by combining `Resize` and `Pad`.

`AI2D` is mainly used in the **deployment stage on the development board** to accelerate the preprocessing process and improve inference speed. Its **C++ runtime interface** is documented in: [AI2D Runtime API Manual](../../api_reference/nncase/ai2d_runtime.md)

The example source code in this document is located in the directory:

```bash
src/rtsmart/examples/ai/usage_ai2d
```

Run `build_app.sh` in this directory to complete the compilation; the generated executable is located in the `k230_bin` directory.
Copy the generated artifacts to the development board to run the example program.

When using `AI2D`, please be sure to pay attention to the following points.

> **Note:**
>
> 1. **`Affine` and `Resize` are mutually exclusive**, they cannot be enabled at the same time;
> 1. **`Shift` only supports the `Raw16` input format**;
> 1. **`Pad` fill values are configured per channel**, and the number of list elements must match the number of channels of the input image;
> 1. In the current version, **even if only a single AI2D function is used, the parameters for the other functions still need to be configured**, but you only need to set the corresponding `flag` to `false`; the other fields can be left blank;
> 1. When multiple functions are configured simultaneously, **the AI2D execution order is fixed as**:
>
>    ```bash
>    Crop → Shift → Resize / Affine → Pad
>    ```
>
>    Please ensure that the parameter configurations for each stage are consistent in terms of dimensions, format, etc.

## Preprocessing Methods

### Resize Method

The `Resize` method is a widely used operation in image preprocessing, primarily used to change the size of an image. Whether enlarging or reducing an image, this method can accomplish it. The source code is located in the `src/rtsmart/examples/ai/usage_ai2d/test_resize` directory. The process for implementing `Resize` is as follows:

<div class="mermaid">
graph TD;
    ReadData("Read Data<br>(from pictures/camera)") -->SetInput("Initialize AI2D input tensor")-->SetOutput("Initialize AI2D output tensor<br>according to preprocessed shape")-->SetParam("Configure Resize parameters<br>ai2d_resize_param_t")-->InitBuilder("Construct ai2d_builder instance<br>execute build_schedule")-->Run("Call invoke interface to run<br>configured preprocessing method")-->GetOutput("Get output data from<br>configured AI2D output tensor");
</div>

Here is example code that uses `AI2D` to implement the `Resize` process, resizing the read image to a resolution of `640*320`.

```c++
int main(int argc, char *argv[])
{
    std::cout << "case " << argv[0] << " build " << __DATE__ << " " << __TIME__ << std::endl;
    if (argc < 3)
    {
        std::cerr << "Usage: " << argv[0] << "<image> <debug_mode>" << std::endl;
        return -1;
    }

    int debug_mode=atoi(argv[2]);

    // Read image and process data into CHW and RGB format
    cv::Mat ori_img = cv::imread(argv[1]);
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

    // Create AI2D input tensor, copy CHW_RGB data into the tensor, and write back to DDR
    dims_t ai2d_in_shape{1, 3, ori_h, ori_w};
    runtime_tensor ai2d_in_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto input_buf = ai2d_in_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
    hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    // resize parameters
    int out_w=640;
    int out_h=320;
    int size=out_w*out_h;

    // Create AI2D output tensor
    dims_t ai2d_out_shape{1, 3, out_h, out_w};
    runtime_tensor ai2d_out_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_out_shape, hrt::pool_shared).expect("cannot create input tensor");

    // Set AI2D parameters; AI2D supports 5 preprocessing methods: crop/shift/pad/resize/affine. Enable resize here
    ai2d_datatype_t ai2d_dtype{ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, ai2d_in_tensor.datatype(), ai2d_out_tensor.datatype()};
    ai2d_crop_param_t crop_param{false, 0, 0, 0, 0};
    ai2d_shift_param_t shift_param{false, 0};
    ai2d_pad_param_t pad_param{false, {{0, 0}, {0, 0}, {0, 0}, {0, 0}}, ai2d_pad_mode::constant, {0,0,0}};
    ai2d_resize_param_t resize_param{true, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{false, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};

    // Construct ai2d_builder
    ai2d_builder builder(ai2d_in_shape, ai2d_out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param);
    builder.build_schedule();
    // Execute ai2d to implement the preprocessing process from ai2d_in_tensor->ai2d_out_tensor
    builder.invoke(ai2d_in_tensor,ai2d_out_tensor).expect("error occurred in ai2d running");

    // Get processing result and save it as an image
    auto output_buf = ai2d_out_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    cv::Mat image_r = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data());
    cv::Mat image_g = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data()+size);
    cv::Mat image_b = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data()+2*size);
    
    std::vector<cv::Mat> color_vec(3);
    color_vec.clear();
    color_vec.push_back(image_b);
    color_vec.push_back(image_g);
    color_vec.push_back(image_r);
    cv::Mat color_img;
    cv::merge(color_vec, color_img);
    cv::imwrite("test_resize.jpg", color_img);

    return 0;
}
```

After compilation, run on the development board:

```shell
./test_resize.elf test.jpg 2
```

The comparison between the original image and the preprocessed image after execution is as follows:

![resize_res](https://www.kendryte.com/api/post/attachment?id=507)

### Crop Method

The `Crop` method is an operation used to extract (crop) a region of interest (ROI) from an original image. It can select a portion of the image as a new image based on specified coordinates and dimensions. The source code is located in `src/rtsmart/examples/ai/usage_ai2d/test_crop`. The process for implementing `Crop` is as follows:

<div class="mermaid">
graph TD;
    ReadData("Read Data<br>(from pictures/camera)") -->SetInput("Initialize AI2D input tensor")-->SetOutput("Initialize AI2D output tensor<br>according to preprocessed shape")-->SetParam("Configure Crop parameters<br>ai2d_crop_param_t")-->InitBuilder("Construct ai2d_builder instance<br>execute build_schedule")-->Run("Call invoke interface to run<br>configured preprocessing method")-->GetOutput("Get output data from<br>configured AI2D output tensor");
</div>

Here is example code that uses AI2D to implement the `Crop` process, cropping the read image at position `[10,10]` to a resolution of `[400,400]`.

```c++
int main(int argc, char *argv[])
{
    std::cout << "case " << argv[0] << " build " << __DATE__ << " " << __TIME__ << std::endl;
    if (argc < 3)
    {
        std::cerr << "Usage: " << argv[0] << "<image> <debug_mode>" << std::endl;
        return -1;
    }

    int debug_mode=atoi(argv[2]);

    // Read image and process data into CHW and RGB format
    cv::Mat ori_img = cv::imread(argv[1]);
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

    // Create AI2D input tensor, copy CHW_RGB data into the tensor, and write back to DDR
    dims_t ai2d_in_shape{1, 3, ori_h, ori_w};
    runtime_tensor ai2d_in_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto input_buf = ai2d_in_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
    hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    // crop parameters
    int crop_x=10;
    int crop_y=10;
    int crop_w=400;
    int crop_h=400;

    // Create AI2D output tensor
    dims_t ai2d_out_shape{1, 3,crop_h, crop_w};
    runtime_tensor ai2d_out_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_out_shape, hrt::pool_shared).expect("cannot create input tensor");

    // Set AI2D parameters; AI2D supports 5 preprocessing methods: crop/shift/pad/resize/affine. Enable crop here
    ai2d_datatype_t ai2d_dtype{ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, ai2d_in_tensor.datatype(), ai2d_out_tensor.datatype()};
    ai2d_crop_param_t crop_param{true, crop_x, crop_y, crop_w, crop_h};
    ai2d_shift_param_t shift_param{false, 0};
    ai2d_pad_param_t pad_param{false, {{0, 0}, {0, 0}, {0, 0}, {0, 0}}, ai2d_pad_mode::constant, {114, 114, 114}};
    ai2d_resize_param_t resize_param{false, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{false, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};

    // Construct ai2d_builder
    ai2d_builder builder(ai2d_in_shape, ai2d_out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param);
    builder.build_schedule();
    // Execute ai2d to implement the preprocessing process from ai2d_in_tensor->ai2d_out_tensor
    builder.invoke(ai2d_in_tensor,ai2d_out_tensor).expect("error occurred in ai2d running");

    // Get processing result and save it as an image
    auto output_buf = ai2d_out_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    cv::Mat image_r = cv::Mat(crop_h, crop_w, CV_8UC1, output_buf.data());
    cv::Mat image_g = cv::Mat(crop_h, crop_w, CV_8UC1, output_buf.data()+crop_h*crop_w);
    cv::Mat image_b = cv::Mat(crop_h, crop_w, CV_8UC1, output_buf.data()+2*crop_h*crop_w);
    
    std::vector<cv::Mat> color_vec(3);
    color_vec.clear();
    color_vec.push_back(image_b);
    color_vec.push_back(image_g);
    color_vec.push_back(image_r);
    cv::Mat color_img;
    cv::merge(color_vec, color_img);
    cv::imwrite("test_crop.jpg", color_img);

    return 0;
}
```

After compilation, run on the development board:

```shell
./test_crop.elf test.jpg 2
```

The comparison between the original image and the preprocessed image after execution is as follows:

![crop_res](https://www.kendryte.com/api/post/attachment?id=505)

### Pad Method

The `Pad` (padding) method is a technique used in the image preprocessing stage to pad the edges of an image. It changes the size of the image by adding pixel values around the image (top, bottom, left, right). These added pixel values can be customized. The source code is located in `src/rtsmart/examples/ai/usage_ai2d/test_pad`. The process for implementing `Pad` is as follows:

<div class="mermaid">
graph TD;
    ReadData("Read Data<br>(from pictures/camera)") -->SetInput("Initialize AI2D input tensor")-->SetOutput("Initialize AI2D output tensor<br>according to preprocessed shape")-->SetParam("Configure Pad parameters<br>ai2d_pad_param_t")-->InitBuilder("Construct ai2d_builder instance<br>execute build_schedule")-->Run("Call invoke interface to run<br>configured preprocessing method")-->GetOutput("Get output data from<br>configured AI2D output tensor");
</div>

Here is example code that uses AI2D to implement the `Pad` process, padding the read image with 100, 100, 200, 200 pixels at top, bottom, left, and right respectively.

```c++
int main(int argc, char *argv[])
{
    std::cout << "case " << argv[0] << " build " << __DATE__ << " " << __TIME__ << std::endl;
    if (argc < 3)
    {
        std::cerr << "Usage: " << argv[0] << "<image> <debug_mode>" << std::endl;
        return -1;
    }

    int debug_mode=atoi(argv[2]);

    // Read image and process data into CHW and RGB format
    cv::Mat ori_img = cv::imread(argv[1]);
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

    // Create AI2D input tensor, copy CHW_RGB data into the tensor, and write back to DDR
    dims_t ai2d_in_shape{1, 3, ori_h, ori_w};
    runtime_tensor ai2d_in_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto input_buf = ai2d_in_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
    hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    // padding parameters
    int pad_top=100;
    int pad_bottom=100;
    int pad_left=200;
    int pad_right=200;
    std::vector<int> pad_val={114,114,114};
    int out_w=ori_w+pad_left+pad_right;
    int out_h=ori_h+pad_top+pad_bottom;
    int size=(ori_w+pad_left+pad_right)*(ori_h+pad_top+pad_bottom);

    // Create AI2D output tensor
    dims_t ai2d_out_shape{1, 3, out_h, out_w};
    runtime_tensor ai2d_out_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_out_shape, hrt::pool_shared).expect("cannot create input tensor");

    // Set AI2D parameters; AI2D supports 5 preprocessing methods: crop/shift/pad/resize/affine. Enable pad here
    ai2d_datatype_t ai2d_dtype{ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, ai2d_in_tensor.datatype(), ai2d_out_tensor.datatype()};
    ai2d_crop_param_t crop_param{false, 0, 0, 0, 0};
    ai2d_shift_param_t shift_param{false, 0};
    ai2d_pad_param_t pad_param{true, {{0, 0}, {0, 0}, {pad_top, pad_bottom}, {pad_left, pad_right}}, ai2d_pad_mode::constant, pad_val};
    ai2d_resize_param_t resize_param{false, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{false, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};

    // Construct ai2d_builder
    ai2d_builder builder(ai2d_in_shape, ai2d_out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param);
    builder.build_schedule();
    // Execute ai2d to implement the preprocessing process from ai2d_in_tensor->ai2d_out_tensor
    builder.invoke(ai2d_in_tensor,ai2d_out_tensor).expect("error occurred in ai2d running");

    // Get processing result and save it as an image
    auto output_buf = ai2d_out_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    cv::Mat image_r = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data());
    cv::Mat image_g = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data()+size);
    cv::Mat image_b = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data()+2*size);
    
    std::vector<cv::Mat> color_vec(3);
    color_vec.clear();
    color_vec.push_back(image_b);
    color_vec.push_back(image_g);
    color_vec.push_back(image_r);
    cv::Mat color_img;
    cv::merge(color_vec, color_img);
    cv::imwrite("test_pad.jpg", color_img);

    return 0;
}
```

After compilation, run on the development board:

```shell
./test_pad.elf test.jpg 2
```

The comparison between the original image and the preprocessed image after execution is as follows:

![pad_res](https://www.kendryte.com/api/post/attachment?id=506)

### Affine Method

The `Affine` (affine transformation) method is a technique used in image preprocessing to perform geometric transformations on an image. It can implement various geometric transformation operations such as rotation, translation, and scaling of an image, while maintaining the image's "straightness" (i.e., straight lines remain straight after transformation) and "parallelism" (i.e., parallel lines remain parallel after transformation). The source code is located in `src/rtsmart/examples/ai/usage_ai2d/test_affine`. The process for implementing `Affine` is as follows:

<div class="mermaid">
graph TD;
    ReadData("Read Data<br>(from pictures/camera)") -->SetInput("Initialize AI2D input tensor")-->SetOutput("Initialize AI2D output tensor<br>according to preprocessed shape")-->SetParam("Configure Affine parameters<br>ai2d_affine_param_t")-->InitBuilder("Construct ai2d_builder instance<br>execute build_schedule")-->Run("Call invoke interface to run<br>configured preprocessing method")-->GetOutput("Get output data from<br>configured AI2D output tensor");
</div>

Here is example code that uses AI2D to implement the `Affine` process, scaling the read image by 0.5x and translating it by 200 pixels in both the x and y directions.

```c++
int main(int argc, char *argv[])
{
    std::cout << "case " << argv[0] << " build " << __DATE__ << " " << __TIME__ << std::endl;
    if (argc < 3)
    {
        std::cerr << "Usage: " << argv[0] << "<image> <debug_mode>" << std::endl;
        return -1;
    }

    int debug_mode=atoi(argv[2]);

    // Read image and process data into CHW and RGB format
    cv::Mat ori_img = cv::imread(argv[1]);
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

    // Create AI2D input tensor, copy CHW_RGB data into the tensor, and write back to DDR
    dims_t ai2d_in_shape{1, 3, ori_h, ori_w};
    runtime_tensor ai2d_in_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto input_buf = ai2d_in_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
    hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    // affine parameters, create affine transformation matrix, scale by 0.5x, translate 200px in X/Y directions
    std::vector<float> affine_matrix = {0.5,0.0,200.0,
                                        0.0,0.5,200.0};
    int out_w=0.5*ori_w;
    int out_h=0.5*ori_h;
    int size=out_w*out_h;

    // Create AI2D output tensor
    dims_t ai2d_out_shape{1, 3, out_h, out_w};
    runtime_tensor ai2d_out_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_out_shape, hrt::pool_shared).expect("cannot create input tensor");

    // Set AI2D parameters; AI2D supports 5 preprocessing methods: crop/shift/pad/resize/affine. Enable affine here
    ai2d_datatype_t ai2d_dtype{ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, ai2d_in_tensor.datatype(), ai2d_out_tensor.datatype()};
    ai2d_crop_param_t crop_param{false, 0, 0, 0, 0};
    ai2d_shift_param_t shift_param{false, 0};
    ai2d_pad_param_t pad_param{false, {{0, 0}, {0, 0}, {0, 0}, {0, 0}}, ai2d_pad_mode::constant, {0,0,0}};
    ai2d_resize_param_t resize_param{false, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{true, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, affine_matrix};

    // Construct ai2d_builder
    ai2d_builder builder(ai2d_in_shape, ai2d_out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param);
    builder.build_schedule();
    // Execute ai2d to implement the preprocessing process from ai2d_in_tensor->ai2d_out_tensor
    builder.invoke(ai2d_in_tensor,ai2d_out_tensor).expect("error occurred in ai2d running");

    // Get processing result and save it as an image
    auto output_buf = ai2d_out_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    cv::Mat image_r = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data());
    cv::Mat image_g = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data()+size);
    cv::Mat image_b = cv::Mat(out_h, out_w, CV_8UC1, output_buf.data()+2*size);
    
    std::vector<cv::Mat> color_vec(3);
    color_vec.clear();
    color_vec.push_back(image_b);
    color_vec.push_back(image_g);
    color_vec.push_back(image_r);
    cv::Mat color_img;
    cv::merge(color_vec, color_img);
    cv::imwrite("test_affine.jpg", color_img);

    return 0;
}
```

After compilation, run on the development board:

```shell
./test_affine.elf test.jpg 2
```

The comparison between the original image and the preprocessed image after execution is as follows:

![affine_res](https://www.kendryte.com/api/post/attachment?id=504)

### Shift Method

The `Shift` method is a bitwise right-shift method in data preprocessing; each right shift by one bit makes the original data become 1/2 of its original value. Please note that the input data format for `Shift` must be `RAW16`. The source code is located in `src/rtsmart/examples/ai/usage_ai2d/test_shift`. The process for implementing `Affine` is as follows:

<div class="mermaid">
graph TD;
    ReadData("Read Data<br>(from pictures/camera)") -->SetInput("Initialize AI2D input tensor")-->SetOutput("Initialize AI2D output tensor<br>according to preprocessed shape")-->SetParam("Configure Shift parameters<br>ai2d_shift_param_t")-->InitBuilder("Construct ai2d_builder instance<br>execute build_schedule")-->Run("Call invoke interface to run<br>configured preprocessing method")-->GetOutput("Get output data from<br>configured AI2D output tensor");
</div>

Here is example code that uses AI2D to implement the `Shift` process; here, data filled entirely with 240 is created, and through a right shift of one bit using `Shift`, all the data becomes 120.

```c++
int main(int argc, char *argv[])
{
    std::cout << "case " << argv[0] << " build " << __DATE__ << " " << __TIME__ << std::endl;
    if (argc < 2)
    {
        std::cerr << "Usage: " << argv[0] << "<debug_mode:0,1,2>" << std::endl;
        return -1;
    }

    int debug_mode=atoi(argv[1]);

    // Create original data with bit depth of 16, initialized to 240
    cv::Mat ori_img(320, 320, CV_16UC3, cv::Scalar(240, 240, 240));
    cv::imwrite("ori_img.jpg",ori_img);

    //hwc,bgr
    int ori_w = ori_img.cols;
    int ori_h = ori_img.rows;
    
    // Create AI2D input tensor
    dims_t ai2d_in_shape{1,ori_h, ori_w,3};
    runtime_tensor ai2d_in_tensor = host_runtime_tensor::create(typecode_t::dt_uint16, ai2d_in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto input_buf = ai2d_in_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    memcpy(reinterpret_cast<uint16_t *>(input_buf.data()), ori_img.data , ori_h*ori_w*3*sizeof(uint16_t));
    hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    int out_w=ori_w;
    int out_h=ori_h;
    // Create AI2D output tensor
    dims_t ai2d_out_shape{1,out_h, out_w,3};
    runtime_tensor ai2d_out_tensor = host_runtime_tensor::create(typecode_t::dt_uint16, ai2d_out_shape, hrt::pool_shared).expect("cannot create input tensor");

    // Set AI2D parameters; AI2D supports 5 preprocessing methods: crop/shift/pad/resize/affine. Enable shift here, right shift by 1 bit, data becomes 1/2 of original
    ai2d_datatype_t ai2d_dtype{ai2d_format::RAW16, ai2d_format::RAW16, ai2d_in_tensor.datatype(), ai2d_out_tensor.datatype()};
    ai2d_crop_param_t crop_param{false, 0, 0, 0, 0};
    ai2d_shift_param_t shift_param{true, 1};
    ai2d_pad_param_t pad_param{false, {{0, 0}, {0, 0}, {0, 0}, {0, 0}}, ai2d_pad_mode::constant, {0,0,0}};
    ai2d_resize_param_t resize_param{false, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{false, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};

    // Construct ai2d_builder
    ai2d_builder builder(ai2d_in_shape, ai2d_out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param);
    builder.build_schedule();
    // Execute ai2d to implement the preprocessing process from ai2d_in_tensor->ai2d_out_tensor
    builder.invoke(ai2d_in_tensor,ai2d_out_tensor).expect("error occurred in ai2d running");

    // Get processing result and save it as an image
    auto output_buf = ai2d_out_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    cv::Mat image_r = cv::Mat(out_h, out_w, CV_16UC3, output_buf.data());
    cv::imwrite("test_shift.jpg", image_r);

    return 0;
}
```

After compilation, run on the development board:

```shell
./test_shift.elf 2
```

The comparison between the original image and the preprocessed image after execution is as follows:

![shift_res](https://www.kendryte.com/api/post/attachment?id=508)
