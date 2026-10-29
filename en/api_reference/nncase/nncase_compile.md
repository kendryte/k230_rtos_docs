# `nncase` Model Compilation API Manual

## Overview

`nncase` is a neural network compiler designed for AI accelerators. The APIs presented in this document are `python APIs` used by users to convert trained `TFLite` models or `ONNX` models into a model format that can be accelerated using `kpu`, namely `kmodel`. The current model compilation APIs support deep learning models in formats such as `TFLite/ONNX`. The APIs provided in this document are used to compile `kmodel` on a local PC, not the code that runs on `k230`. For learning about `nncase`, please refer to: [nncase github repo](https://github.com/kendryte/nncase) .

## API Introduction

### CompileOptions

【Description】

The CompileOptions class is used to configure nncase compilation options. The description of each attribute is as follows:

| Attribute Name              |         Type          | Required | Description                                                                                                                                          |
| :-------------------------- | :-------------------: | :------: | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| target                      |        string         |    Yes   | Specify the compilation target, such as 'cpu', 'k230'                                                                                                |
| dump_ir                     |         bool          |    No    | Specify whether to dump IR, default is False                                                                                                         |
| dump_asm                    |         bool          |    No    | Specify whether to dump asm assembly file, default is False                                                                                          |
| dump_dir                    |        string         |    No    | After specifying switches such as dump_ir above, specify the dump directory here, default is ""                                                       |
| input_file                  |        string         |    No    | When the ONNX model exceeds 2GB, used to specify the parameter file path, default is ""                                                              |
| preprocess                  |         bool          |    No    | Whether to enable preprocessing, default is False. The following parameters only take effect when `preprocess=True`                                 |
| input_type                  |        string         |    No    | Specify the input data type when preprocessing is enabled, default is "float". When `preprocess` is `True`, must be specified as "uint8" or "float32" |
| input_shape                 |       list[int]       |    No    | Specify the shape of the input data when preprocessing is enabled, default is []. Must be specified when `preprocess` is `True`                       |
| input_range                 |      list[float]      |    No    | Specify the float range after dequantization of input data when preprocessing is enabled, default is [ ]. Must be specified when `preprocess` is `True` and `input_type` is `uint8` |
| input_layout                |        string         |    No    | Specify the layout of input data, default is ""                                                                                                     |
| swapRB                      |         bool          |    No    | Whether to reverse data in the `channel` dimension, default is False                                                                                |
| mean                        |      list[float]      |    No    | Mean of preprocessing normalization parameters, default is [0,0,0]                                                                                   |
| std                         |      list[float]      |    No    | Variance of preprocessing normalization parameters, default is [1,1,1]                                                                                |
| letterbox_value             |         float         |    No    | Specify the padding value for letterbox in preprocessing, default is 0                                                                               |
| output_layout               |        string         |    No    | Specify the layout of output data, default is ""                                                                                                     |
| shape_bucket_enable         |         bool          |    Yes   | Whether to enable the ShapeBucket feature, default is False. Takes effect when `dump_ir=True`                                                        |
| shape_bucket_range_info     | Dict[str, [int, int]] |    Yes   | The range of variables in each input shape dimension information, the minimum value must be greater than or equal to 1                              |
| shape_bucket_segments_count |          int          |    Yes   | The number of segments into which the range of input variables is divided                                                                            |
| shape_bucket_fix_var_map    |    Dict[str, int]     |    No    | Fix the variables in shape dimension information to specific values                                                                                   |

<a id="preprocess"></a>

#### Preprocessing Flow Description

Currently, custom preprocessing order is not supported. You can select the required preprocessing parameters for configuration according to the following flow diagram.

<div class="mermaid">
graph TD;
    NewInput("NewInput<br>(shape = input_shape<br>dtype = input_type)") -->a(input_layout != ' ')-.Y.->Transpose1["transpose"] -.->b("SwapRB == True")-.Y.->SwapRB["SwapRB"]-.->c("input_type != float32")-.Y.->Dequantize["Dequantize"]-.->d("input_HW != model_HW")-.Y.->LetterBox["LetterBox"] -.->e("std not empty<br>mean not empty")-.Y.->Normalization["Normalization"]-.->OldInput-->Model_body-->OldOutput-->f("output_layout != ' '")-.Y.->Transpose2["Transpose"]-.-> NewOutput;
    a--N-->b--N-->c--N-->d--N-->e--N-->OldInput; f--N-->NewOutput;
    subgraph origin_model
        OldInput; Model_body ; OldOutput;
    end
</div>

Parameter description:

1. `input_range` is the float range after dequantization when the input data type is fixed-point.

   a. When the input data type is uint8 with range [0,255], and `input_range` is [0,255], the dequantization only performs type conversion, converting uint8 data to float32, and the `mean` and `std` parameters should still be specified according to [0,255] data.

   b. When the input data type is uint8 with range [0,255], and `input_range` is [0,1], the dequantization will convert fixed-point numbers to floating-point numbers [0,1], and the `mean` and `std` parameters need to be specified according to data in the range 0~1.

   <div class="mermaid">
    graph TD;
        NewInput_uint8("NewInput_uint8 <br>[input_type:uint8]") --input_range:0,255 -->dequantize_0["Dequantize"]--float range:0,255--> OldInput_float32
        NewInput_uint81("NewInput_uint8 <br>[input_type:uint8]") --input_range:0,1 -->dequantize_1["Dequantize"]--float range:0,1--> OldInput_float32
   </div>

1. `input_shape` is the shape of the input data, with the layout being `input_layout`. Currently, both string (`"NHWC"`, `"NCHW"`) and index forms are supported as `input_layout`, and non-4D data processing is supported.
When `input_layout` is configured in string form, it represents the layout of the input data; when `input_layout` is configured in index form, it indicates that the input data will be transposed according to the currently configured `input_layout`, i.e., `input_layout` is the `perm` parameter of `Transpose`.

<div class="mermaid">
graph TD;
    subgraph B
        NewInput1("NewInput: 1,4,10") --"input_layout:"0,2,1""-->Transpose2("Transpose perm: 0,2,1") --> OldInput2("OldInput: 1,10,4");
    end
    subgraph A
        NewInput --"input_layout:"NHWC""--> Transpose0("Transpose: NHWC2NCHW") --> OldInput;
        NewInput("NewInput: 1,224,224,3 (NHWC)") --"input_layout:"0,3,1,2""--> Transpose1("Transpose perm: 0,3,1,2") --> OldInput("OldInput: 1,3,224,224 (NCHW)");
    end
</div>

​   The same applies to `output_layout`, as shown in the figure below.

<div class="mermaid">
graph TD;
subgraph B
    OldOutput1("OldOutput: 1,10,4,5,2") --"output_layout: "0,2,3,1,4""--> Transpose5("Transpose perm: 0,2,3,1,4") --> NewOutput1("NewOutput: 1,4,5,10,2");
    end
subgraph A
    OldOutput --"output_layout: "NHWC""--> Transpose3("Transpose: NCHW2NHWC") --> NewOutput("NewOutput<br>NHWC");
    OldOutput("OldOutput: (NCHW)") --"output_layout: "0,2,3,1""--> Transpose4("Transpose perm: 0,2,3,1") --> NewOutput("NewOutput<br>NHWC");
    end
</div>

#### Dynamic Shape Parameter Description

ShapeBucket is a solution for dynamic shapes that optimizes dynamic shapes based on the range of input lengths and the specified number of segments. This feature is disabled by default and requires the corresponding option to be enabled. Apart from specifying the corresponding field information, the rest of the process is no different from compiling a static model.

- ONNX

There will be some dimensions in the model's shape that are variable names. Here, taking the input of an ONNX model as an example:

> tokens: int64[batch_size, tgt_seq_len]
> step: float32[seq_len, batch_size]

There are three variables in the shape dimension information: `seq_len`, `tgt_seq_len`, and `batch_size`.
First, batch_size, although a variable, is actually fixed to 3 in practical applications. Therefore, add `batch_size = 3` in **fix_var_map**, and this dimension will be fixed to 3 at runtime.
`seq_len` and `tgt_seq_len` are the two that actually change, so you need to configure the actual range of these two variables, which is the **range_info** information. **segments_count** is the actual number of segments, and the range will be equally divided into that many parts, with the corresponding compilation time increasing accordingly.

The following is an example of the corresponding compilation parameters:

```python
compile_options = nncase.CompileOptions()
compile_options.shape_bucket_enable = True
compile_options.shape_bucket_range_info = {"seq_len": [1, 100], "tgt_seq_len": [1, 100]}
compile_options.shape_bucket_segments_count = 2
compile_options.shape_bucket_fix_var_map = {"batch_size": 3}
```

- TFLite

TFLite models differ from ONNX in that the dimensions are not yet labeled with names in the shape. Currently, only one dynamic dimension in the input is supported, and the name is uniformly configured as -1. The configuration method is as follows:

```cpp
compile_options = nncase.CompileOptions()
compile_options.shape_bucket_enable = True
compile_options.shape_bucket_range_info = {"-1":[1, 100]}
compile_options.shape_bucket_segments_count = 2
compile_options.shape_bucket_fix_var_map = {"batch_size" : 3}
```

After configuring these options, the entire compilation process is consistent with that of a static shape.

#### Parameter Configuration Example

Instantiate CompileOptions and configure the values of each attribute.

```python
compile_options = nncase.CompileOptions()

compile_options.target = "cpu" #"k230"
compile_options.dump_ir = True  # if False, will not dump the compile-time result.
compile_options.dump_asm = True
compile_options.dump_dir = "dump_path"
compile_options.input_file = ""

# preprocess args
compile_options.preprocess = False
if compile_options.preprocess:
    compile_options.input_type = "uint8"  # "uint8" "float32"
    compile_options.input_shape = [1,224,320,3]
    compile_options.input_range = [0,1]
    compile_options.input_layout = "NHWC" # "NHWC" ”NCHW“
    compile_options.swapRB = False
    compile_options.mean = [0,0,0]
    compile_options.std = [1,1,1]
    compile_options.letterbox_value = 0
    compile_options.output_layout = "NHWC" # "NHWC" "NCHW"

# Dynamic shape args
compile_options.shape_bucket_enable = False
if compile_options.shape_bucket_enable:
    compile_options.shape_bucket_range_info = {"seq_len": [1, 100], "tgt_seq_len": [1, 100]}
    compile_options.shape_bucket_segments_count = 2
    compile_options.shape_bucket_fix_var_map = {"batch_size": 3}
```

### ImportOptions

【Description】

The ImportOptions class, used to configure nncase import options.

【Definition】

```python
class ImportOptions:
    def __init__(self) -> None:
        pass
```

【Example】

Instantiate ImportOptions and configure the values of each property.

```python
#import_options
import_options = nncase.ImportOptions()
```

### PTQTensorOptions

【Description】

The PTQTensorOptions class, used to configure nncase PTQ options.

| Name                           | Type   | Required | Description |
| ------------------------------ | ------ | -------- | ---- |
| samples_count                  | int    |    No    |  Specifies the number of calibration samples used for quantization    |
| calibrate_method               | string |    No    |  Specifies the quantization method, optional 'NoClip' or 'Kld', default is 'Kld'   |
| finetune_weights_method        | string |    No    |  Specifies whether to fine-tune weights, optional 'NoFineTuneWeights' or 'UseSquant', default is 'NoFineTuneWeights'  |
| quant_type                     | string |    No    |  Specifies the data quantization type, optional 'uint8', 'int8', 'int16'; `quant_type` and `w_quant_type` cannot both be 'int16'  |
| w_quant_type                   | string |    No    |  Specifies the weight quantization type, optional 'uint8', 'int8', 'int16'; `quant_type` and `w_quant_type` cannot both be 'int16' |
| quant_scheme                   | string |    No    |  The path of the imported quantization parameter configuration file |
| quant_scheme_strict_mode       | bool   |    No    |  Whether to perform quantization strictly according to quant_scheme  |
| export_quant_scheme            | bool   |    No    |  Whether to export the quantization parameter configuration file  |
| export_weight_range_by_channel | bool   |    No    |  Whether to export weight quantization parameters in `bychannel` form, this parameter is recommended to be set to `True`  |

For the specific workflow of mixed quantization, see [MixQuant Instructions](https://github.com/kendryte/nncase/blob/release/2.0/docs/MixQuant.md).

【Example】

```python
# ptq_options
ptq_options = nncase.PTQTensorOptions()
ptq_options.samples_count = 6
ptq_options.finetune_weights_method = "NoFineTuneWeights"
ptq_options.quant_type = "uint8"
ptq_options.w_quant_type = "uint8"
ptq_options.set_tensor_data(generate_data(input_shape, ptq_options.samples_count, args.dataset))

ptq_options.quant_scheme = ""
ptq_options.quant_scheme_strict_mode = False
ptq_options.export_quant_scheme = True
ptq_options.export_weight_range_by_channel = True

compiler.use_ptq(ptq_options)
```

### set_tensor_data

【Description】

Sets tensor data, sets the calibration data during the model conversion process.

【Definition】

```python
    def set_tensor_data(self, data: List[List[np.ndarray]]) -> None:
        reshape_data = list(map(list, zip(*data)))
        self.cali_data = [RuntimeTensor.from_numpy(
            d) for d in itertools.chain.from_iterable(reshape_data)]
```

【Parameters】

| Name | Type                  | Description           |
| ---- | --------------------- | -------------- |
| data | List[List[np.ndarray]] | The read calibration data |

【Return Value】

None.

【Example】

```shell
# ptq_options
ptq_options = nncase.PTQTensorOptions()
ptq_options.samples_count = 6
ptq_options.set_tensor_data(generate_data(input_shape, ptq_options.samples_count, args.dataset))
compiler.use_ptq(ptq_options)
```

### Compiler

【Description】

The Compiler class, used to compile neural network models.

【Definition】

```python
class Compiler:
    _target: _nncase.Target
    _session: _nncase.CompileSession
    _compiler: _nncase.Compiler
    _compile_options: _nncase.CompileOptions
    _quantize_options: _nncase.QuantizeOptions
    _module: IRModule
```

### import_tflite

【Description】

Imports a TFLite model.

【Definition】

```python
def import_tflite(self, model_content: bytes, options: ImportOptions) -> None:
    self._compile_options.input_format = "tflite"
    self._import_module(model_content)
```

【Parameters】

| Name           | Type          | Description           |
| -------------- | ------------- | -------------- |
| model_content  | byte\[\]      | The read model content |
| import_options | ImportOptions | Import options       |

【Return Value】

None.

【Example】

```python
model_content = read_model_file(model)
compiler.import_tflite(model_content, import_options)
```

### import_onnx

【Description】

Imports an ONNX model.

【Definition】

```python
def import_onnx(self, model_content: bytes, options: ImportOptions) -> None:
    self._compile_options.input_format = "onnx"
    self._import_module(model_content)
```

【Parameters】

| Name           | Type          | Description           |
| -------------- | ------------- | -------------- |
| model_content  | byte\[\]      | The read model content |
| import_options | ImportOptions | Import options       |

【Return Value】

None.

【Example】

```python
model_content = read_model_file(model)
compiler.import_onnx(model_content, import_options)
```

### use_ptq

【Description】

Sets the PTQ configuration options.

- K230 must use quantization by default.

【Definition】

`use_ptq(ptq_options)`

【Parameters】

| Name        | Type             | Description        |
| ----------- | ---------------- | ----------- |
| ptq_options | PTQTensorOptions | PTQ configuration options |

【Return Value】

None.

【Example】

`compiler.use_ptq(ptq_options)`

### compile

【Description】

Compiles the neural network model.

【Definition】

`compile()`

【Parameters】

None.

【Return Value】

None.

【Example】

`compiler.compile()`

### gencode_tobytes

【Description】

Generates a kmodel byte stream.

【Definition】

`gencode_tobytes()`

【Parameters】

None.

【Return Value】

`bytes[]`

【Example】

```python
kmodel = compiler.gencode_tobytes()
with open(os.path.join(infer_dir, 'test.kmodel'), 'wb') as f:
    f.write(kmodel)
```

## Example

The models and python compilation scripts used in the following example:

- The original model files are located in the src/rtsmart/libs/nncase/examples/models directory
- The python compilation scripts are located in the src/rtsmart/libs/nncase/examples/scripts directory

### Compiling the TFLite Model

The mbv2_tflite.py script is as follows:

```python
import os
import argparse
import numpy as np
from PIL import Image
import nncase

def read_model_file(model_file):
    with open(model_file, 'rb') as f:
        model_content = f.read()
    return model_content

def generate_data(shape, batch, calib_dir):
    img_paths = [os.path.join(calib_dir, p) for p in os.listdir(calib_dir)]
    data = []
    for i in range(batch):
        assert i < len(img_paths), "calibration images not enough."
        img_data = Image.open(img_paths[i]).convert('RGB')
        img_data = img_data.resize((shape[3], shape[2]), Image.BILINEAR)
        img_data = np.asarray(img_data, dtype=np.uint8)
        img_data = np.transpose(img_data, (2, 0, 1))
        data.append([img_data[np.newaxis, ...]])
    return data

def main():
    parser = argparse.ArgumentParser(prog="nncase")
    parser.add_argument("--target", type=str, help='target to run')
    parser.add_argument("--model", type=str, help='model file')
    parser.add_argument("--dataset", type=str, help='calibration_dataset')
    args = parser.parse_args()

    input_shape = [1, 3, 224, 224]
    dump_dir = 'tmp/mbv2_tflite'

    # compile_options
    compile_options = nncase.CompileOptions()
    compile_options.target = args.target
    compile_options.preprocess = True
    compile_options.swapRB = False
    compile_options.input_shape = input_shape
    compile_options.input_type = 'uint8'
    compile_options.input_range = [0, 255]
    compile_options.mean = [127.5, 127.5, 127.5]
    compile_options.std = [127.5, 127.5, 127.5]
    compile_options.input_layout = 'NCHW'
    compile_options.dump_ir = True
    compile_options.dump_asm = True
    compile_options.dump_dir = dump_dir

    # compiler
    compiler = nncase.Compiler(compile_options)

    # import
    model_content = read_model_file(args.model)
    import_options = nncase.ImportOptions()
    compiler.import_tflite(model_content, import_options)

    # ptq_options
    ptq_options = nncase.PTQTensorOptions()
    ptq_options.samples_count = 6
    ptq_options.set_tensor_data(generate_data(input_shape, ptq_options.samples_count, args.dataset))
    compiler.use_ptq(ptq_options)

    # compile
    compiler.compile()

    # kmodel
    kmodel = compiler.gencode_tobytes()
    with open(os.path.join(dump_dir, 'test.kmodel'), 'wb') as f:
        f.write(kmodel)

if __name__ == '__main__':
    main()
```

Execute the following command to compile the mobilenetv2 TFLite model, with target as k230.

```sh
root@c285a41a7243:/mnt/# cd rtos_sdk/src/rtsmart/libs/nncase/examples
root@c285a41a7243:/mnt/rtos_sdk/src/rtsmart/libs/nncase/examples# python3 ./scripts/mbv2_tflite.py --target k230 --model models/mbv2.tflite --dataset calibration_dataset
```

### Compiling the ONNX Model

For ONNX models, it is recommended to use [ONNX Simplifier](https://github.com/daquexian/onnx-simplifier) for simplification first, and then use nncase to compile.

The yolov5s_onnx.py script is as follows:

```python
import os
import argparse
import numpy as np
from PIL import Image
import onnxsim
import onnx
import nncase

def parse_model_input_output(model_file):
    onnx_model = onnx.load(model_file)
    input_all = [node.name for node in onnx_model.graph.input]
    input_initializer = [node.name for node in onnx_model.graph.initializer]
    input_names = list(set(input_all) - set(input_initializer))
    input_tensors = [
        node for node in onnx_model.graph.input if node.name in input_names]

    # input
    inputs = []
    for _, e in enumerate(input_tensors):
        onnx_type = e.type.tensor_type
        input_dict = {}
        input_dict['name'] = e.name
        input_dict['dtype'] = onnx.mapping.TENSOR_TYPE_TO_NP_TYPE[onnx_type.elem_type]
        input_dict['shape'] = [(i.dim_value if i.dim_value != 0 else d) for i, d in zip(
            onnx_type.shape.dim, [1, 3, 224, 224])]
        inputs.append(input_dict)

    return onnx_model, inputs


def onnx_simplify(model_file, dump_dir):
    onnx_model, inputs = parse_model_input_output(model_file)
    onnx_model = onnx.shape_inference.infer_shapes(onnx_model)
    input_shapes = {}
    for input in inputs:
        input_shapes[input['name']] = input['shape']

    onnx_model, check = onnxsim.simplify(onnx_model, input_shapes=input_shapes)
    assert check, "Simplified ONNX model could not be validated"

    model_file = os.path.join(dump_dir, 'simplified.onnx')
    onnx.save_model(onnx_model, model_file)
    return model_file


def read_model_file(model_file):
    with open(model_file, 'rb') as f:
        model_content = f.read()
    return model_content

def generate_data_ramdom(shape, batch):
    data = []
    for i in range(batch):
        data.append([np.random.randint(0, 256, shape).astype(np.uint8)])
    return data


def generate_data(shape, batch, calib_dir):
    img_paths = [os.path.join(calib_dir, p) for p in os.listdir(calib_dir)]
    data = []
    for i in range(batch):
        assert i < len(img_paths), "calibration images not enough."
        img_data = Image.open(img_paths[i]).convert('RGB')
        img_data = img_data.resize((shape[3], shape[2]), Image.BILINEAR)
        img_data = np.asarray(img_data, dtype=np.uint8)
        img_data = np.transpose(img_data, (2, 0, 1))
        data.append([img_data[np.newaxis, ...]])
    return data

def main():
    parser = argparse.ArgumentParser(prog="nncase")
    parser.add_argument("--target", type=str, help='target to run')
    parser.add_argument("--model", type=str, help='model file')
    parser.add_argument("--dataset", type=str, help='calibration_dataset')

    args = parser.parse_args()

    input_shape = [1, 3, 320, 320]

    dump_dir = 'tmp/yolov5s_onnx'
    if not os.path.exists(dump_dir):
        os.makedirs(dump_dir)

    # onnx simplify
    model_file = onnx_simplify(args.model, dump_dir)

    # compile_options
    compile_options = nncase.CompileOptions()
    compile_options.target = args.target
    compile_options.preprocess = True
    compile_options.swapRB = False
    compile_options.input_shape = input_shape
    compile_options.input_type = 'uint8'
    compile_options.input_range = [0, 255]
    compile_options.mean = [0, 0, 0]
    compile_options.std = [255, 255, 255]
    compile_options.input_layout = 'NCHW'
    compile_options.output_layout = 'NCHW'
    compile_options.dump_ir = True
    compile_options.dump_asm = True
    compile_options.dump_dir = dump_dir

    # compiler
    compiler = nncase.Compiler(compile_options)

    # import
    model_content = read_model_file(model_file)
    import_options = nncase.ImportOptions()
    compiler.import_onnx(model_content, import_options)

    # ptq_options
    ptq_options = nncase.PTQTensorOptions()
    ptq_options.samples_count = 6
    ptq_options.set_tensor_data(generate_data(input_shape, ptq_options.samples_count, args.dataset))
    compiler.use_ptq(ptq_options)

    # compile
    compiler.compile()

    # kmodel
    kmodel = compiler.gencode_tobytes()
    with open(os.path.join(dump_dir, 'test.kmodel'), 'wb') as f:
        f.write(kmodel)

if __name__ == '__main__':
    main()
```

Execute the following command to compile the ONNX model, with target as k230.

```sh
root@c285a41a7243:/mnt/# cd rtos_sdk/src/rtsmart/libs/nncase/examples
root@c285a41a7243: /mnt/rtos_sdk/src/rtsmart/libs/nncase/examples # python3 ./scripts/yolov5s_onnx.py --target k230 --model models/yolov5s.onnx --dataset calibration_dataset
```
