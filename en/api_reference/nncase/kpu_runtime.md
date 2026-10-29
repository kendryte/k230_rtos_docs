# `KPU` Runtime API Manual

## Overview

KPU runtime APIs are used to load kmodel on AI devices, set input data, execute KPU/CPU computations, retrieve output data, etc. This document provides C++ APIs. The related header files and static libraries are located in the `src/rtsmart/libs/nncase/riscv64` directory. The APIs provided in this document are used to write code in `C++` on the local PC that runs on `k230`, compile it into an executable file, and then copy it to `k230` to run.

```shell
$ tree -L 3 riscv64/
riscv64/
├── gsl
│   └── gsl-lite.hpp
├── nncase
│   ├── include
│   │   └── nncase
│   └── lib
│       ├── cmake
│       ├── libfunctional_k230.a
│       ├── libnncase.rt_modules.k230.a
│       └── libNncase.Runtime.Native.a
└── rvvlib
    ├── include
    │   ├── k230_math.h
    │   ├── nms.h
    │   └── rvv_math.h
    └── librvv.a

8 directories, 8 files
```

## API Introduction

### hrt::create

【Description】

Creates a runtime_tensor.

【Definition】

```cpp
(1) NNCASE_API result<runtime_tensor> create(typecode_t datatype, dims_t shape, memory_pool_t pool = pool_shared_first) noexcept;
(2) NNCASE_API result<runtime_tensor> create(typecode_t datatype, dims_t shape, gsl::span<gsl::byte> data, bool copy,
       memory_pool_t pool = pool_shared_first) noexcept;
(3)NNCASE_API result<runtime_tensor>create(typecode_t datatype, dims_t shape, strides_t strides, gsl::span<gsl::byte> data, bool copy, memory_pool_t pool = pool_shared_first, uintptr_t physical_address = 0) noexcept;
```

【Parameters】

| Name              | Type                    | Description                                              |
| ----------------- | ----------------------- | -------------------------------------------------------- |
| datatype          | typecode_t              | Data type, such as dt_float32, dt_uint8, etc.            |
| shape             | dims_t                  | Shape of the tensor                                      |
| data              | gsl::span\<gsl::byte\>  | User-space data buffer                                   |
| copy              | bool                    | Whether to copy                                          |
| pool              | memory_pool_t           | Memory pool type, default value is pool_shared_first     |
| physical_address  | uintptr_t               | Physical address of the user-specified buffer            |

【Return Value】

`result<runtime_tensor>`

【Example】

```cpp
// create input tensor
auto input_desc = interp.input_desc(0);
auto input_shape = interp.input_shape(0);
auto input_tensor = host_runtime_tensor::create(input_desc.datatype, input_shape, hrt::pool_shared).expect("cannot create input tensor");
```

### hrt::sync

【Description】

Synchronizes the cache of a tensor.

- For user input data, you need to call the sync_write_back of this interface to ensure that the data has been flushed into ddr.
- For the output data after gnne/ai2d computation, the gnne/ai2d runtime has done sync_invalidate processing by default.

【Definition】

`NNCASE_API result<void> sync(runtime_tensor &tensor, sync_op_t op, bool force = false) noexcept;`

【Parameters】

| Name   | Type            | Description                                                                                  |
| ------ | --------------- | -------------------------------------------------------------------------------------------- |
| tensor | runtime_tensor  | The tensor to operate on                                                                     |
| op     | sync_op_t       | sync_invalidate (invalidates the tensor's cache) or sync_write_back (writes the tensor's cache to ddr) |
| force  | bool            | Whether to force execution                                                                   |

【Return Value】

`result<void>`

【Example】

```cpp
hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("sync write_back failed");
```

### interpreter::load_model

【Description】

Loads a kmodel.

【Definition】

`NNCASE_NODISCARD result<void> load_model(gsl::span<const gsl::byte> buffer) noexcept;`

【Parameters】

| Name   | Type                           | Description    |
| ------ | ------------------------------ | -------------- |
| buffer | gsl::span \<const gsl::byte\>  | kmodel buffer  |

【Return Value】

`result<void>`

【Example】

```cpp
interpreter interp;
auto model = read_binary_file<unsigned char>(kmodel);
interp.load_model({(const gsl::byte *)model.data(), model.size()}).expect("cannot load model.");
```

### interpreter::inputs_size

【Description】

Gets the number of model inputs.

【Definition】

`size_t inputs_size() const noexcept;`

【Parameters】

None.

【Return Value】

`size_t`

【Example】

`auto inputs_size = interp.inputs_size();`

### interpreter::outputs_size

【Description】

Gets the number of model outputs.

【Definition】

`size_t outputs_size() const noexcept;`

【Parameters】

None.

【Return Value】

`size_t`

【Example】

`auto outputs_size = interp.outputs_size();`

### interpreter:: input_shape

【Description】

Gets the shape of the specified input of the model.

【Definition】

`const runtime_shape_t &input_shape(size_t index) const noexcept;`

【Parameters】

| Name  | Type     | Description        |
| ----- | -------- | ------------------ |
| index | size_t   | Index of the input |

【Return Value】

`runtime_shape_t`

【Example】

`auto shape = interp.input_shape(0);`

### interpreter:: output_shape

【Description】

Gets the shape of the specified output of the model.

【Definition】

`const runtime_shape_t &output_shape(size_t index) const noexcept;`

【Parameters】

| Name  | Type     | Description         |
| ----- | -------- | ------------------- |
| index | size_t   | Index of the output |

【Return Value】

`runtime_shape_t`

【Example】

`auto shape = interp.output_shape(0);`

### interpreter:: input_tensor

【Description】

Gets/sets the input tensor of the specified index.

【Definition】

```cpp
(1) result<runtime_tensor> input_tensor(size_t index) noexcept;
(2) result<void> input_tensor(size_t index, runtime_tensor tensor) noexcept;
```

【Parameters】

| Name   | Type            | Description                          |
| ------ | --------------- | ------------------------------------ |
| index  | size_t          | Index of the input                   |
| tensor | runtime_tensor  | The runtime tensor corresponding to the input |

【Return Value】

```cpp
(1) result<runtime_tensor>
(2) result<void>
```

【Example】

```cpp
// set input
interp.input_tensor(0, input_tensor).expect("cannot set input tensor");
```

### interpreter:: output_tensor

【Description】

Gets/sets the output tensor of the specified index.

【Definition】

```cpp
(1) result<runtime_tensor> output_tensor(size_t index) noexcept;
(2) result<void> output_tensor(size_t index, runtime_tensor tensor) noexcept;
```

【Parameters】

| Name   | Type            | Description                          |
| ------ | --------------- | ------------------------------------ |
| index  | size_t          | Index of the output                  |
| tensor | runtime_tensor  | The runtime tensor corresponding to the output |

【Return Value】

```cpp
(1) result<runtime_tensor>
(2) result<void>
```

【Example】

```cpp
// get output
auto output_tensor = interp.output_tensor(0).expect("cannot get output tensor");
```

### interpreter:: run

【Description】

Executes KPU computation.

【Definition】

`result<void> run() noexcept;`

【Parameters】

None.

【Return Value】

Returns result \<void\>.

【Example】

```cpp
// run
interp.run().expect("error occurred in running model");
```

## Example

```cpp
#include <chrono>
#include <fstream>
#include <iostream>
#include <nncase/runtime/interpreter.h>
#include <nncase/runtime/runtime_op_utility.h>

#define USE_OPENCV 1
#define preprocess 1

#if USE_OPENCV
#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#endif

using namespace nncase;
using namespace nncase::runtime;
using namespace nncase::runtime::detail;

// Model input resolution
#define INTPUT_HEIGHT 224
#define INTPUT_WIDTH 224
#define INTPUT_CHANNELS 3

template <class T>
std::vector<T> read_binary_file(const std::string &file_name)
{
    std::ifstream ifs(file_name, std::ios::binary);
    ifs.seekg(0, ifs.end);
    size_t len = ifs.tellg();
    std::vector<T> vec(len / sizeof(T), 0);
    ifs.seekg(0, ifs.beg);
    ifs.read(reinterpret_cast<char *>(vec.data()), len);
    ifs.close();
    return vec;
}

void read_binary_file(const char *file_name, char *buffer)
{
    std::ifstream ifs(file_name, std::ios::binary);
    ifs.seekg(0, ifs.end);
    size_t len = ifs.tellg();
    ifs.seekg(0, ifs.beg);
    ifs.read(buffer, len);
    ifs.close();
}

static std::vector<std::string> read_txt_file(const char *file_name)
{
    std::vector<std::string> vec;
    vec.reserve(1024);
    std::ifstream fp(file_name);
    std::string label;
    while (getline(fp, label))
    {
        vec.push_back(label);
    }
    return vec;
}

template<typename T>
static int softmax(const T* src, T* dst, int length)
{
    const T alpha = *std::max_element(src, src + length);
    T denominator{ 0 };

    for (int i = 0; i < length; ++i) {
        dst[i] = std::exp(src[i] - alpha);
        denominator += dst[i];
    }

    for (int i = 0; i < length; ++i) {
        dst[i] /= denominator;
    }

    return 0;
}

#if USE_OPENCV
std::vector<uint8_t> hwc2chw(cv::Mat &img)
{
    std::vector<uint8_t> vec;
    std::vector<cv::Mat> rgbChannels(3);
    cv::split(img, rgbChannels);
    for (auto i = 0; i < rgbChannels.size(); i++)
    {
        std::vector<uint8_t> data = std::vector<uint8_t>(rgbChannels[i].reshape(1, 1));
        vec.insert(vec.end(), data.begin(), data.end());
    }

    return vec;
}
#endif

static int inference(const char *kmodel_file, const char *image_file, const char *label_file)
{
    // load kmodel
    interpreter interp;
    
    // Load kmodel from memory
    auto kmodel = read_binary_file<unsigned char>(kmodel_file);
    interp.load_model({ (const gsl::byte *)kmodel.data(), kmodel.size() }).expect("cannot load kmodel.");
    // Load kmodel from file stream
    std::ifstream ifs(kmodel_file, std::ios::binary);
    interp.load_model(ifs).expect("cannot load kmodel");
    

    // create input tensor
    auto input_desc = interp.input_desc(0);
    auto input_shape = interp.input_shape(0);
    auto input_tensor = host_runtime_tensor::create(input_desc.datatype, input_shape, hrt::pool_shared).expect("cannot create input tensor");
    interp.input_tensor(0, input_tensor).expect("cannot set input tensor");

    // create output tensor
    // auto output_desc = interp.output_desc(0);
    // auto output_shape = interp.output_shape(0);
    // auto output_tensor = host_runtime_tensor::create(output_desc.datatype, output_shape, hrt::pool_shared).expect("cannot create output tensor");
    // interp.output_tensor(0, output_tensor).expect("cannot set output tensor");

    // set input data
    auto dst = input_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
#if USE_OPENCV
    cv::Mat img = cv::imread(image_file);
    cv::resize(img, img, cv::Size(INTPUT_WIDTH, INTPUT_HEIGHT), cv::INTER_NEAREST);
    auto input_vec = hwc2chw(img);
    memcpy(reinterpret_cast<char *>(dst.data()), input_vec.data(), input_vec.size());
#else
    read_binary_file(image_file, reinterpret_cast<char *>(dst.data()));
#endif
    hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("sync write_back failed");

    // run
    size_t counter = 1;
    auto start = std::chrono::steady_clock::now();
    for (size_t c = 0; c < counter; c++)
    {
        interp.run().expect("error occurred in running model");
    }
    auto stop = std::chrono::steady_clock::now();
    double duration = std::chrono::duration<double, std::milli>(stop - start).count();
    std::cout << "interp.run() took: " << duration / counter << " ms" << std::endl;

    // get output data
    auto output_tensor = interp.output_tensor(0).expect("cannot set output tensor");
    dst = output_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_read).unwrap().buffer();
    float *output_data = reinterpret_cast<float *>(dst.data());
    auto out_shape = interp.output_shape(0);
    auto size = compute_size(out_shape);

    // postprogress softmax by cpu
    std::vector<float> softmax_vec(size, 0);
    auto buf = softmax_vec.data();
    softmax(output_data, buf, size);
    auto it = std::max_element(buf, buf + size);
    size_t idx = it - buf;

    // load label
    auto labels = read_txt_file(label_file);
    std::cout << "image classify result: " << labels[idx] << "(" << *it << ")" << std::endl;

    return 0;
}

int main(int argc, char *argv[])
{
    std::cout << "case " << argv[0] << " built at " << __DATE__ << " " << __TIME__ << std::endl;
    if (argc != 4)
    {
        std::cerr << "Usage: " << argv[0] << " <kmodel> <image> <label>" << std::endl;
        return -1;
    }

    int ret = inference(argv[1], argv[2], argv[3]);
    if (ret)
    {
        std::cerr << "inference failed: ret = " << ret << std::endl;
        return -2;
    }
    return 0;
}
```

The above code needs to be compiled into an `elf` executable using the compilation tools in the `k230 sdk` environment, and then copied to the development board to run.
