# `AI2D` Runtime API Manual

## Overview

`AI2D` runtime APIs are used to configure `AI2D` parameters on AI devices, generate related register configurations, and execute `AI2D` preprocessing calculations. The APIs provided in this document are used to write code that runs on `k230` using `C++` on a local PC, compile it into an executable file, and then copy it to `k230` for execution.

> Note:
>
> 1. Affine and Resize functions are mutually exclusive and cannot be enabled simultaneously;
> 2. The input format of the Shift function can only be Raw16;
> 3. Pad value is configured per channel, and the number of corresponding list elements must equal the number of channels;
> 4. In the current version, when only one function of AI2D is needed, other parameters also need to be configured, with flag set to false, and other fields do not need to be configured;
> 5. When multiple functions are configured, the execution order is Crop->Shift->Resize/Affine->Pad. Pay attention to matching when configuring parameters.

### Supported Format Conversion

| Input Format      | Output Format             | Notes                            |
| ----------------- | ------------------------- | -------------------------------- |
| YUV420_NV12       | RGB_planar/YUV420_NV12    |                                  |
| YUV420_NV21       | RGB_planar/YUV420_NV21    |                                  |
| YUV420_I420       | RGB_planar/YUV420_I420    |                                  |
| YUV400            | YUV400                    |                                  |
| NCHW(RGB_planar)  | NCHW(RGB_planar)          |                                  |
| RGB_packed        | RGB_planar/RGB_packed     |                                  |
| RAW16             | RAW16/8                   | Depth map, perform shift operation |

### Function Description

| Function             | Description                                                                                                                                       | Notes                  |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| Affine               | Supports input format YUV420, YUV400, RGB (planar/packed)  Supports depth map RAW16 format  Supports output format YUV400, RGB, depth map          |                        |
| Crop/Resize/Padding  | Supports input YUV420, YUV400, RGB  Supports depth map RAW16 format  Resize supports middle NCHW arrangement format  Supports output format YUV420, YUV400, RGB | Only supports constant padding |
| Shift                | Supports input format Raw16  Supports output format Raw8                                                                                         |                        |
| Sign Bit             | Supports signed and unsigned input                                                                                                                |                        |

## Parameter Type Introduction

### ai2d_format

【Description】

ai2d_format is used to configure the optional data formats for input and output.

【Definition】

```cpp
enum class ai2d_format
{
    YUV420_NV12 = 0,
    YUV420_NV21 = 1,
    YUV420_I420 = 2,
    NCHW_FMT = 3,
    RGB_packed = 4,
    RAW16 = 5,
}
```

### ai2d_interp_method

【Description】

ai2d_interp_method is used to configure the optional interpolation methods.

【Definition】

```cpp
 enum class ai2d_interp_method
{
    tf_nearest = 0,
    tf_bilinear = 1,
    cv2_nearest = 2,
    cv2_bilinear = 3,
}
```

### ai2d_interp_mode

【Description】

ai2d_interp_mode is used to configure the optional interpolation modes.

【Definition】

```cpp
enum class ai2d_interp_mode
{
    none = 0,
    align_corner = 1,
    half_pixel = 2,
}
```

### ai2d_pad_mode

【Description】

ai2d_pad_mode is used to configure the optional padding modes. Currently, only constant padding is supported.

【Definition】

```cpp
enum class ai2d_pad_mode
{
    constant = 0,
    copy = 1,
    mirror = 2,
}
```

### ai2d_datatype_t

【Description】

ai2d_datatype_t is used to set the data types during AI2D computation.

【Definition】

```cpp
struct ai2d_datatype_t
{
    ai2d_format src_format;
    ai2d_format dst_format;
    datatype_t src_type;
    datatype_t dst_type;
    ai2d_data_loc src_loc = ai2d_data_loc::ddr;
    ai2d_data_loc dst_loc = ai2d_data_loc::ddr;
}
```

【Parameters】

| Name       | Type            | Description                          |
| ---------- | --------------- | ------------------------------------ |
| src_format | ai2d_format     | Input data format                    |
| dst_format | ai2d_format     | Output data format                   |
| src_type   | datatype_t      | Input data type                      |
| dst_type   | datatype_t      | Output data type                     |
| src_loc    | ai2d_data_loc   | Input data location, default ddr     |
| dst_loc    | ai2d_data_loc   | Output data location, default ddr    |

【Example】

```cpp
ai2d_datatype_t ai2d_dtype { ai2d_format::RAW16, ai2d_format::NCHW_FMT, datatype_t::dt_uint16, datatype_t::dt_uint8 };
```

### ai2d_crop_param_t

【Description】

ai2d_crop_param_t is used to configure crop-related parameters.

【Definition】

```cpp
struct ai2d_crop_param_t
{
    bool crop_flag = false;
    int32_t start_x = 0;
    int32_t start_y = 0;
    int32_t width = 0;
    int32_t height = 0;
}
```

【Parameters】

| Name      | Type | Description                            |
| --------- | ---- | -------------------------------------- |
| crop_flag | bool | Whether to enable the crop function    |
| start_x   | int  | Starting pixel in the width direction  |
| start_y   | int  | Starting pixel in the height direction |
| width     | int  | Crop length in the width direction     |
| height    | int  | Crop length in the height direction    |

【Example】

```cpp
ai2d_crop_param_t crop_param { true, 40, 30, 400, 600 };
```

### ai2d_shift_param_t

【Description】

ai2d_shift_param_t is used to configure shift-related parameters.

【Definition】

```cpp
struct ai2d_shift_param_t
{
    bool shift_flag = false;
    int32_t shift_val = 0;
}
```

【Parameters】

| Name       | Type | Description                            |
| ---------- | ---- | -------------------------------------- |
| shift_flag | bool | Whether to enable the shift function   |
| shift_val  | int  | Number of bits for right shift         |

【Example】

`ai2d_shift_param_t shift_param { true, 2 };`

### ai2d_pad_param_t

【Description】

ai2d_pad_param_t is used to configure pad-related parameters.

【Definition】

```cpp
struct ai2d_pad_param_t
{
    bool pad_flag = false;
    runtime_paddings_t paddings;
    ai2d_pad_mode pad_mode = ai2d_pad_mode::constant;
    std::vector<int32_t> pad_val; // by channel
}
```

【Parameters】

| Name     | Type                    | Description                                                                                                                                  |
| -------- | ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| pad_flag | bool                    | Whether to enable the pad function                                                                                                           |
| paddings | runtime_paddings_t      | Padding for each dimension, shape=`[4, 2]`, representing the number of paddings before and after for dim0 to dim4, where dim0/dim1 are fixed as {0, 0} |
| pad_mode | ai2d_pad_mode           | Padding mode, only constant padding is supported                                                                                             |
| pad_val  | std::vector\<int32_t\>  | Padding value for each channel                                                                                                              |

【Example】

```cpp
ai2d_pad_param_t pad_param { false, { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 60, 60 } }, ai2d_pad_mode::constant, { 255 } };
```

### ai2d_resize_param_t

【Description】

ai2d_resize_param_t is used to configure resize-related parameters.

【Definition】

```cpp
struct ai2d_resize_param_t
{
    bool resize_flag = false;
    ai2d_interp_method interp_method = ai2d_interp_method::tf_bilinear;
    ai2d_interp_mode interp_mode = ai2d_interp_mode::none;
}
```

【Parameters】

| Name          | Type               | Description                            |
| ------------- | ------------------ | -------------------------------------- |
| resize_flag   | bool               | Whether to enable the resize function  |
| interp_method | ai2d_interp_method | Resize interpolation method            |
| interp_mode   | ai2d_interp_mode   | Resize mode                            |

【Example】

```cpp
ai2d_resize_param_t resize_param { true, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel };
```

### ai2d_affine_param_t

【Description】

ai2d_affine_param_t is used to configure affine-related parameters.

【Definition】

```cpp
struct ai2d_affine_param_t
{
    bool affine_flag = false;
    ai2d_interp_method interp_method = ai2d_interp_method::cv2_bilinear;
    uint32_t cord_round = 0;
    uint32_t bound_ind = 0;
    int32_t bound_val = 0;
    uint32_t bound_smooth = 0;
    std::vector<float> M;
}
```

【Parameters】

| Name          | Type                  | Description                                                                                                                                                                                |
| ------------- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| affine_flag   | bool                  | Whether to enable the affine function                                                                                                                                                      |
| interp_method | ai2d_interp_method    | Interpolation method used by Affine                                                                                                                                                       |
| cord_round    | uint32_t              | Integer boundary 0 or 1                                                                                                                                                                   |
| bound_ind     | uint32_t              | Boundary pixel mode 0 or 1                                                                                                                                                                 |
| bound_val     | uint32_t              | Boundary fill value                                                                                                                                                                        |
| bound_smooth  | uint32_t              | Boundary smoothing 0 or 1                                                                                                                                                                 |
| M             | std::vector\<float\>  | The vector corresponding to the affine transformation matrix. If the affine transformation is $Y=\[a_0, a_1; a_2, a_3\] \cdot X + \[b_0, b_1\] $, then $ M=\{a_0,a_1,b_0,a_2,a_3,b_1\} $ |

【Example】

```cpp
ai2d_affine_param_t affine_param { true, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, { 0.5, 0.1, 0.0, 0.1, 0.5, 0.0 } };
```

## API Introduction

### ai2d_builder:: ai2d_builder

【Description】

The constructor of ai2d_builder.

【Definition】

```cpp
ai2d_builder(dims_t &input_shape, dims_t &output_shape, ai2d_datatype_t ai2d_dtype, ai2d_crop_param_t crop_param, ai2d_shift_param_t shift_param, ai2d_pad_param_t pad_param, ai2d_resize_param_t resize_param, ai2d_affine_param_t affine_param);
```

【Parameters】

| Name          | Type                | Description        |
| ------------- | ------------------- | ------------------ |
| input_shape   | dims_t              | Input shape        |
| output_shape  | dims_t              | Output shape       |
| ai2d_dtype    | ai2d_datatype_t     | ai2d data type     |
| crop_param    | ai2d_crop_param_t   | crop parameters    |
| shift_param   | ai2d_shift_param_t  | shift parameters   |
| pad_param     | ai2d_pad_param_t    | pad parameters     |
| resize_param  | ai2d_resize_param_t | resize parameters  |
| affine_param  | ai2d_affine_param_t | affine parameters  |

【Return Value】

None

【Example】

```cpp
dims_t in_shape { 1, ai2d_input_c_, ai2d_input_h_, ai2d_input_w_ };          
auto out_span = ai2d_out_tensor_.shape();                                    
dims_t out_shape { out_span.begin(), out_span.end() };                       
ai2d_datatype_t ai2d_dtype { ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, typecode_t::dt_uint8, typecode_t::dt_uint8 };
ai2d_crop_param_t crop_param { false, 0, 0, 0, 0 };                          
ai2d_shift_param_t shift_param { false, 0 };                                 
ai2d_pad_param_t pad_param { true, { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 70, 70 } }, ai2d_pad_mode::constant, { 0, 0, 0 } };
ai2d_resize_param_t resize_param { true, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel };
ai2d_affine_param_t affine_param { false };                                  
ai2d_builder_.reset(new ai2d_builder(in_shape, out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param));
```

### ai2d_builder:: build_schedule

【Description】

Generates the parameters required for AI2D computation.

【Definition】

```c++
result<void> build_schedule();
```

【Parameters】

None.

【Return Value】

`result<void>`

【Example】

```c++
ai2d_builder_->build_schedule();
```

### ai2d_builder::invoke

【Description】

Configures the registers and starts AI2D computation.

【Definition】

```c++
result<void> invoke(runtime_tensor &input, runtime_tensor &output);
```

【Parameters】

| Name    | Type            | Description       |
| ------- | --------------- | ----------------- |
| input   | runtime_tensor  | Input tensor      |
| output  | runtime_tensor  | Output tensor     |

【Return Value】

```c
result<void>。
```

【Example】

```c++
// run ai2d                                                                  
ai2d_builder_->invoke(ai2d_in_tensor, ai2d_out_tensor_).expect("error occurred in ai2d running");
```

## Example

```cpp
static void test_pad_mini_test(const char *gmodel_file, const char *expect_file)
{
    // input tensor
    dims_t in_shape { 1, 100, 150, 3 };
    auto in_tensor = host_runtime_tensor::create(dt_uint8, in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto mapped_in_buf = std::move(hrt::map(in_tensor, map_access_t::map_write).unwrap());
    read_binary_file(gmodel_file, reinterpret_cast<char *>(mapped_in_buf.buffer().data()));
    mapped_in_buf.unmap().expect("unmap input tensor failed");
    hrt::sync(in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    // output tensor
    dims_t out_shape { 1, 100, 160, 3 };
    auto out_tensor = host_runtime_tensor::create(dt_uint8, out_shape, hrt::pool_shared).expect("cannot create output tensor");

    // config ai2d，这里配置的是padding预处理
    ai2d_datatype_t ai2d_dtype { ai2d_format::RGB_packed, ai2d_format::RGB_packed, dt_uint8, dt_uint8 };
    ai2d_crop_param_t crop_param { false, 0, 0, 0, 0 };
    ai2d_shift_param_t shift_param { false, 0 };
    ai2d_pad_param_t pad_param { true, { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 10, 0 } }, ai2d_pad_mode::constant, { 255, 10, 5 } };
    ai2d_resize_param_t resize_param { false, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel };
    ai2d_affine_param_t affine_param { false };

    // run
    ai2d_builder builder { in_shape, out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param };
    auto start = std::chrono::steady_clock::now();
    builder.build_schedule().expect("error occurred in ai2d build_schedule");
    builder.invoke(in_tensor, out_tensor).expect("error occurred in ai2d invoke");
    auto stop = std::chrono::steady_clock::now();
    double duration = std::chrono::duration<double, std::milli>(stop - start).count();
    std::cout << "ai2d run: duration = " << duration << " ms, fps = " << 1000 / duration << std::endl;

    // compare
    auto mapped_out_buf = std::move(hrt::map(out_tensor, map_access_t::map_read).unwrap());
    auto actual = mapped_out_buf.buffer().data();
    auto expected = read_binary_file<unsigned char>(expect_file);
    int ret = memcmp(reinterpret_cast<void *>(actual), reinterpret_cast<void *>(expected.data()), expected.size());
    if (!ret)
    {
        std::cout << "compare output succeed!" << std::endl;
    }
    else
    {
        auto cos = cosine(reinterpret_cast<const uint8_t *>(actual), reinterpret_cast<const uint8_t *>(expected.data()), expected.size());
        std::cerr << "compare output failed: cosine similarity = " << cos << std::endl;
    }
}
```

The above code needs to be compiled into an `elf` executable file using the compilation tool in the `k230 sdk` environment, and then copied to the development board to run.
