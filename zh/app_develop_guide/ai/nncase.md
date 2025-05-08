# NNCASE 应用指南

## 概述

### 什么是nncase

nncase是一个为 AI 加速器设计的神经网络编译器, 目前支持的 target有CPU/K210/K510/K230等。

nncase提供的功能：

- 支持多输入多输出网络，支持多分支结构;
- 静态内存分配，不需要堆内存;
- 算子合并和优化;
- 支持 float 和uint8/int8量化推理;
- 支持训练后量化，使用浮点模型和量化校准集;
- 平坦模型，支持零拷贝加载;

nncase支持的神经网络模型格式：

- TFLite
- ONNX

### nncase架构

![nncase架构](https://www.kendryte.com/api/post/attachment?id=509)

nncase软件栈包括compiler和runtime两部分。

Compiler: 用于在PC上编译神经网络模型，最终生成kmodel文件。主要包括importer, IR, Evaluator, Quantize, Transform优化, Tiling, Partition, Schedule, Codegen等模块。

- Importer: 将其它神经网络框架的模型导入到nncase中；
- IR: 中间表示, 分为importer导入的Neutral IR(设备无关)和Neutral IR经lowering转换生成的Target IR(设备相关)；
- Evaluator: Evaluator提供IR的解释执行能力，常被用于Constant Folding/PTQ Calibration等场景；
- Transform: 用于IR转换和图的遍历优化等；
- Quantize: 训练后量化, 对要量化的tensor加入量化标记, 根据输入的校正集, 调用 Evaluator进行解释执行, 收集tensor的数据范围, 插入量化/反量化结点, 最后优化消除不必要的量化/反量化结点等；
- Tiling: 受限于NPU较低的存储器容量，需要将大块计算进行拆分。另外，计算存在大量数据复用时选择Tiling参数会对时延和带宽产生影响；
- Partition: 将图按ModuleType进行切分, 切分后的每个子图会对应RuntimeModule, 不同类型的RuntimeModule对应不同的Device(CPU/K230)；
- Schedule: 根据优化后图中的数据依赖关系生成计算顺序并分配Buffer；
- Codegen: 对每个子图分别调用ModuleType对应的codegen，生成RuntimeModule；

Runtime: 集成于用户App， 提供加载kmodel/设置输入数据/KPU执行/获取输出数据等功能。

### 开发环境

#### 操作系统

支持的操作系统包括Ubuntu 18.04/Ubuntu 20.04/Windows 10/Windows 11。

#### 软件环境

| 序号 | 软件            | 版本号               |
| ---- | --------------- | -------------------- |
| 1    | python          | 3.6/3.7/3.8/3.9/3.10 |
| 2    | pip             | \>=20.3              |
| 3    | numpy           | 1.19.5               |
| 4    | onnx            | 1.9.0                |
| 5    | onnx-simplifier | 0.3.6                |
| 6    | Onnxoptimizer   | 0.2.6                |
| 7    | Onnxruntime     | 1.8.0                |
| 8    | dotnet-runtime  | 7.0                  |

## 算子支持

### TFLite算子

| Operator                | Is Supported |
| ----------------------- | ------------ |
| ABS                     | Yes          |
| ADD                     | Yes          |
| ARG_MAX                 | Yes          |
| ARG_MIN                 | Yes          |
| AVERAGE_POOL_2D         | Yes          |
| BATCH_MATMUL            | Yes          |
| CAST                    | Yes          |
| CEIL                    | Yes          |
| CONCATENATION           | Yes          |
| CONV_2D                 | Yes          |
| COS                     | Yes          |
| CUSTOM                  | Yes          |
| DEPTHWISE_CONV_2D       | Yes          |
| DIV                     | Yes          |
| EQUAL                   | Yes          |
| EXP                     | Yes          |
| EXPAND_DIMS             | Yes          |
| FLOOR                   | Yes          |
| FLOOR_DIV               | Yes          |
| FLOOR_MOD               | Yes          |
| FULLY_CONNECTED         | Yes          |
| GREATER                 | Yes          |
| GREATER_EQUAL           | Yes          |
| L2_NORMALIZATION        | Yes          |
| LEAKY_RELU              | Yes          |
| LESS                    | Yes          |
| LESS_EQUAL              | Yes          |
| LOG                     | Yes          |
| LOGISTIC                | Yes          |
| MAX_POOL_2D             | Yes          |
| MAXIMUM                 | Yes          |
| MEAN                    | Yes          |
| MINIMUM                 | Yes          |
| MUL                     | Yes          |
| NEG                     | Yes          |
| NOT_EQUAL               | Yes          |
| PAD                     | Yes          |
| PADV2                   | Yes          |
| MIRROR_PAD              | Yes          |
| PACK                    | Yes          |
| POW                     | Yes          |
| REDUCE_MAX              | Yes          |
| REDUCE_MIN              | Yes          |
| REDUCE_PROD             | Yes          |
| RELU                    | Yes          |
| PRELU                   | Yes          |
| RELU6                   | Yes          |
| RESHAPE                 | Yes          |
| RESIZE_BILINEAR         | Yes          |
| RESIZE_NEAREST_NEIGHBOR | Yes          |
| ROUND                   | Yes          |
| RSQRT                   | Yes          |
| SHAPE                   | Yes          |
| SIN                     | Yes          |
| SLICE                   | Yes          |
| SOFTMAX                 | Yes          |
| SPACE_TO_BATCH_ND       | Yes          |
| SQUEEZE                 | Yes          |
| BATCH_TO_SPACE_ND       | Yes          |
| STRIDED_SLICE           | Yes          |
| SQRT                    | Yes          |
| SQUARE                  | Yes          |
| SUB                     | Yes          |
| SUM                     | Yes          |
| TANH                    | Yes          |
| TILE                    | Yes          |
| TRANSPOSE               | Yes          |
| TRANSPOSE_CONV          | Yes          |
| QUANTIZE                | Yes          |
| FAKE_QUANT              | Yes          |
| DEQUANTIZE              | Yes          |
| GATHER                  | Yes          |
| GATHER_ND               | Yes          |
| ONE_HOT                 | Yes          |
| SQUARED_DIFFERENCE      | Yes          |
| LOG_SOFTMAX             | Yes          |
| SPLIT                   | Yes          |
| HARD_SWISH              | Yes          |

### ONNX算子

| Operator              | Is Supported |
| --------------------- | ------------ |
| Abs                   | Yes          |
| Acos                  | Yes          |
| Acosh                 | Yes          |
| And                   | Yes          |
| ArgMax                | Yes          |
| ArgMin                | Yes          |
| Asin                  | Yes          |
| Asinh                 | Yes          |
| Add                   | Yes          |
| AveragePool           | Yes          |
| BatchNormalization    | Yes          |
| Cast                  | Yes          |
| Ceil                  | Yes          |
| Celu                  | Yes          |
| Clip                  | Yes          |
| Compress              | Yes          |
| Concat                | Yes          |
| Constant              | Yes          |
| ConstantOfShape       | Yes          |
| Conv                  | Yes          |
| ConvTranspose         | Yes          |
| Cos                   | Yes          |
| Cosh                  | Yes          |
| CumSum                | Yes          |
| DepthToSpace          | Yes          |
| DequantizeLinear      | Yes          |
| Div                   | Yes          |
| Dropout               | Yes          |
| Elu                   | Yes          |
| Exp                   | Yes          |
| Expand                | Yes          |
| Equal                 | Yes          |
| Erf                   | Yes          |
| Flatten               | Yes          |
| Floor                 | Yes          |
| Gather                | Yes          |
| GatherElements        | Yes          |
| GatherND              | Yes          |
| Gemm                  | Yes          |
| GlobalAveragePool     | Yes          |
| GlobalMaxPool         | Yes          |
| Greater               | Yes          |
| GreaterOrEqual        | Yes          |
| GRU                   | Yes          |
| Hardmax               | Yes          |
| HardSigmoid           | Yes          |
| HardSwish             | Yes          |
| Identity              | Yes          |
| InstanceNormalization | Yes          |
| LayerNormalization    | Yes          |
| LpNormalization       | Yes          |
| LeakyRelu             | Yes          |
| Less                  | Yes          |
| LessOrEqual           | Yes          |
| Log                   | Yes          |
| LogSoftmax            | Yes          |
| LRN                   | Yes          |
| LSTM                  | Yes          |
| MatMul                | Yes          |
| MaxPool               | Yes          |
| Max                   | Yes          |
| Min                   | Yes          |
| Mul                   | Yes          |
| Neg                   | Yes          |
| Not                   | Yes          |
| OneHot                | Yes          |
| Pad                   | Yes          |
| Pow                   | Yes          |
| PRelu                 | Yes          |
| QuantizeLinear        | Yes          |
| RandomNormal          | Yes          |
| RandomNormalLike      | Yes          |
| RandomUniform         | Yes          |
| RandomUniformLike     | Yes          |
| ReduceL1              | Yes          |
| ReduceL2              | Yes          |
| ReduceLogSum          | Yes          |
| ReduceLogSumExp       | Yes          |
| ReduceMax             | Yes          |
| ReduceMean            | Yes          |
| ReduceMin             | Yes          |
| ReduceProd            | Yes          |
| ReduceSum             | Yes          |
| ReduceSumSquare       | Yes          |
| Relu                  | Yes          |
| Reshape               | Yes          |
| Resize                | Yes          |
| ReverseSequence       | Yes          |
| RoiAlign              | Yes          |
| Round                 | Yes          |
| Rsqrt                 | Yes          |
| Selu                  | Yes          |
| Shape                 | Yes          |
| Sign                  | Yes          |
| Sin                   | Yes          |
| Sinh                  | Yes          |
| Sigmoid               | Yes          |
| Size                  | Yes          |
| Slice                 | Yes          |
| Softmax               | Yes          |
| Softplus              | Yes          |
| Softsign              | Yes          |
| SpaceToDepth          | Yes          |
| Split                 | Yes          |
| Sqrt                  | Yes          |
| Squeeze               | Yes          |
| Sub                   | Yes          |
| Sum                   | Yes          |
| Tanh                  | Yes          |
| Tile                  | Yes          |
| TopK                  | Yes          |
| Transpose             | Yes          |
| Trilu                 | Yes          |
| ThresholdedRelu       | Yes          |
| Upsample              | Yes          |
| Unsqueeze             | Yes          |
| Where                 | Yes          |

## API 文档

`nncase` 软件栈包括 `compiler` 和 `runtime` 两部分，分别用于模型转换和 KPU 模型推理。针对这两部分提供了 Python 和 C++ 的 API，API 手册见：[nncase API 手册](../../api_reference/nncase/index.md) 。

## 使用步骤

### 环境搭建

- **Linux**

首先安装 `dotnet-sdk-7.0`,并配置 `dotnet` 环境变量，不要在 `anaconda` 虚拟环境中安装dotnet：

```shell
sudo apt-get update
sudo apt-get install dotnet-sdk-7.0
export DOTNET_ROOT=/usr/share/dotnet
```

然后安装 `nncase` 和 `nncase-kpu` :

```shell
pip install nncase nncase-kpu
```

- **Windows**

首先安装`dotnet-sdk-7.0`，安装步骤见 `Microsoft` 官方文档：[在Windows上安装.NET](https://learn.microsoft.com/zh-cn/dotnet/core/install/windows) 。

然后在线安装 `nncase`, 在 [Release](https://github.com/kendryte/nncase/releases) 中选择对应版本的 `nncase_kpu-2.x.x-py2.py3-none-win_amd64.whl` 下载，然后在本地使用 `pip install` 安装。

```shell
pip install nncase
pip install nncase_kpu-2.x.x-py2.py3-none-win_amd64.whl
```

- **Docker**

用户若没有Ubuntu环境, 可使用nncase docker(Ubuntu 20.04 + Python 3.8 + dotnet-7.0)

```shell
cd /path/to/nncase_sdk
docker pull ghcr.io/kendryte/k230_sdk
docker run -it --rm -v `pwd`:/mnt -w /mnt ghcr.io/kendryte/k230_sdk /bin/bash -c "/bin/bash"
```

- **查看版本信息**

```shell
root@469e6a4a9e71:/mnt# python3
Python 3.8.10 (default, May 26 2023, 14:05:08)
[GCC 9.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import _nncase
>>> print(_nncase.__version__)
2.9.0
```

### 模型转换

`nncase` 用户指南文档见：[github: user_guide](https://github.com/kendryte/nncase/tree/master/examples/user_guide) 或 [gitee: user_guide](https://gitee.com/kendryte/nncase/tree/master/examples/user_guide) 。

使用 `nncase` 将 `tflite/onnx` 模型转换成 `kmodel` ，模型转换代码的关键在于根据自身需求进行选项配置，主要是 `CompileOptions` 、 `PTQTensorOptions` 和 `ImportOptions`。

#### CompileOptions

`CompileOptions` 类, 用于配置 `nncase` 编译选项，各属性说明如下：

| 属性名称                    |         类型          | 是否必须 | 描述                                                                                                                   |
| :-------------------------- | :-------------------: | :------: | ---------------------------------------------------------------------------------------------------------------------- |
| target                      |        string         |    是    | 指定编译目标, 如'cpu', 'k230'                                                                                          |
| dump_ir                     |         bool          |    否    | 指定是否dump IR, 默认为False                                                                                           |
| dump_asm                    |         bool          |    否    | 指定是否dump asm汇编文件, 默认为False                                                                                  |
| dump_dir                    |        string         |    否    | 前面指定dump_ir等开关后, 这里指定dump的目录, 默认为""                                                                  |
| input_file                  |        string         |    否    | ONNX模型超过2GB时，用于指定参数文件路径，默认为""                                                                      |
| preprocess                  |         bool          |    否    | 是否开启前处理，默认为False。以下参数仅在 `preprocess=True`时生效                                                      |
| input_type                  |        string         |    否    | 开启前处理时指定输入数据类型，默认为"float"。当 `preprocess`为 `True`时，必须指定为"uint8"或者"float32"                |
| input_shape                 |       list[int]       |    否    | 开启前处理时指定输入数据的shape，默认为[]。当 `preprocess`为 `True`时，必须指定                                        |
| input_range                 |      list[float]      |    否    | 开启前处理时指定输入数据反量化后的浮点数范围，默认为[ ]。当 `preprocess`为 `True`且 `input_type`为 `uint8`时，必须指定 |
| input_layout                |        string         |    否    | 指定输入数据的layout，默认为""                                                                                         |
| swapRB                      |         bool          |    否    | 是否在 `channel`维度反转数据，默认为False                                                                              |
| mean                        |      list[float]      |    否    | 前处理标准化参数均值，默认为[0,0,0]                                                                                    |
| std                         |      list[float]      |    否    | 前处理标准化参数方差，默认为[1,1,1]                                                                                    |
| letterbox_value             |         float         |    否    | 指定前处理letterbox的填充值，默认为0                                                                                   |
| output_layout               |        string         |    否    | 指定输出数据的layout, 默认为""                                                                                         |
| shape_bucket_enable         |         bool          |    是    | 是否开启ShapeBucket功能，默认为False。在 `dump_ir=True`时生效                                                          |
| shape_bucket_range_info     | Dict[str, [int, int]] |    是    | 每个输入shape维度信息中的变量的范围，最小值必须大于等于1                                                               |
| shape_bucket_segments_count |          int          |    是    | 输入变量的范围划分为几段                                                                                               |
| shape_bucket_fix_var_map    |    Dict[str, int]     |    否    | 固定shape维度信息中的变量为特定的值|

关于前处理的配置说明，请参考 API 文档：[nncase 模型编译API手册前处理流程](../../api_reference/nncase/nncase_compile.md#211-前处理流程说明)。将部分前处理操作封装在模型内可以提高开发板推理时的前处理效率，支持的前处理包括：`swapRB`(RGB->BGR or BGR->RGB)、`Transpose`(NHWC->NCHW or NCHW->NHWC)、`Normalization`（减均值除方差）、`Dequantize`等。比如：onnx模型需要的输入是`RGB`的，我们使用`opencv`读取的图片是`BGR`，正常onnx模型推理的预处理我们需要先将`BGR`转成`RGB`给onnx模型使用。转kmodel的时候我们就可以设置 `swapRB` 为 `True` ，这样kmodel中自带交换`RB`通道的预处理步骤，在进行kmodel推理的预处理时，我们就可以忽略交换`RB`通道的步骤，将此步骤放到kmodel内部。

#### PTQTensorOptions

`PTQTensorOptions` 类, 用于配置 `nncase PTQ` 选项：

| 名称                           | 类型   | 是否必须 | 描述 |
| ------------------------------ | ------ | -------- | ---- |
| samples_count                  | int    |    否    |  指定用于量化的校正集数量    |
| calibrate_method               | string |    否    |  指定量化方法，可选'NoClip'、'Kld'，默认为'Kld'   |
| finetune_weights_method        | string |    否    |  指定是否对权重进行微调，可选'NoFineTuneWeights'、'UseSquant'，默认为'NoFineTuneWeights'  |
| quant_type                     | string |    否    |  指定数据量化类型，可选'uint8'，'int8'，'int16'，`quant_type`和`w_quant_type`两种类型不可同时为'int16'  |
| w_quant_type                   | string |    否    |  指定权重量化类型，可选'uint8'，'int8'，'int16'，`quant_type`和`w_quant_type`两种类型不可同时为'int16' |
| quant_scheme                   | string |    否    |  导入量化参数配置文件的路径 |
| quant_scheme_strict_mode       | bool   |    否    |  是否严格按照quant_scheme执行量化  |
| export_quant_scheme            | bool   |    否    |  是否导出量化参数配置文件  |
| export_weight_range_by_channel | bool   |    否    |  是否导出 `bychannel`形式的weights量化参数，该参数建议设置为 `True`  |

混合量化具体使用流程见 [MixQuant说明](https://github.com/kendryte/nncase/blob/release/2.0/docs/MixQuant.md)。

关于量化的配置说明，请参考 API 文档：[nncase 模型编译API手册PTQ选项配置](../../api_reference/nncase/nncase_compile.md#23-ptqtensoroptions)。如果转换的kmodel达不到效果，可以修改 `quant_type` 和 `w_quant_type` 参数，修改模型数据和权重的量化类型，但是这两个参数不能同时设置为 `int16`。

#### 校正集设置

| 名称 | 类型                  | 描述           |
| ---- | --------------------- | -------------- |
| data | List[List[np.ndarray]] | 读取的校准数据 |

量化过程中使用的校正数据通过 `set_tensor_data` 方法进行设置，接口参数类型为 `List[List[np.ndarray]]`，比如：模型有一个输入，校正数据量设置为10，传入的校正数据维度为 `[10,1,3,224,224]`；如果模型有两个输入，校正数据量设置为10，传入的校正数据维度为 `[[10,1,3,224,224],[10,1,3,320,320]]`。

#### ImportOptions

ImportOptions类, 用于配置nncase导入选项，配置编译器的待转换模型。可以配置 `tflite/onnx`。使用示例如下：

```python
# 读取并导入tflite模型
model_content = read_model_file(model)
compiler.import_tflite(model_content, import_options)

# 读取并导入onnx模型
model_content = read_model_file(model)
compiler.import_onnx(model_content, import_options)
```

#### YOLOv8 ONNX转kmodel示例

```python
import os
import argparse
import numpy as np
from PIL import Image
import onnxsim
import onnx
import nncase
import shutil
import math

def parse_model_input_output(model_file,input_shape):
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
            onnx_type.shape.dim, input_shape)]
        inputs.append(input_dict)

    return onnx_model, inputs


def onnx_simplify(model_file, dump_dir,input_shape):
    onnx_model, inputs = parse_model_input_output(model_file,input_shape)
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
    return np.array(data)


def main():
    parser = argparse.ArgumentParser(prog="nncase")
    parser.add_argument("--target", default="k230",type=str, help='target to run,k230/cpu')
    parser.add_argument("--model",type=str, help='model file')
    parser.add_argument("--dataset_path", type=str, help='calibration_dataset')
    parser.add_argument("--input_width", type=int, default=320, help='model input_width')
    parser.add_argument("--input_height", type=int, default=320, help='model input_height')
    parser.add_argument("--ptq_option", type=int, default=0, help='ptq_option:0,1,2,3,4,5')

    args = parser.parse_args()

    # 更新参数为32倍数
    input_width = int(math.ceil(args.input_width / 32.0)) * 32
    input_height = int(math.ceil(args.input_height / 32.0)) * 32

    # 模型的输入shape，维度要跟input_layout一致
    input_shape=[1,3,input_height,input_width]

    dump_dir = 'tmp'
    if not os.path.exists(dump_dir):
        os.makedirs(dump_dir)

    # onnx simplify
    model_file = onnx_simplify(args.model, dump_dir,input_shape)

    # 设置CompileOptions
    compile_options = nncase.CompileOptions()
    compile_options.target = args.target

    # 是否采用kmodel模型做预处理
    compile_options.preprocess = True
    # onnx模型需要RGB的，k230上的摄像头给出的数据也是RGB格式的，因此不需要开启交换RB
    compile_options.swapRB = False
    # 输入图像的shape
    compile_options.input_shape = input_shape
    # 模型输入格式‘uint8’或者‘float32’
    compile_options.input_type = 'uint8'

    # 如果输入是‘uint8’格式，输入反量化之后的范围
    compile_options.input_range = [0, 1]
    # 预处理的mean/std值，每个channel一个，该数据由YOLOv8源码获取
    compile_options.mean = [0, 0, 0] 
    compile_options.std = [1, 1, 1]

    # 设置输入的layout，onnx默认‘NCHW’即可
    compile_options.input_layout = "NCHW"

    # 创建Compiler实例
    compiler = nncase.Compiler(compile_options)

    # 导入onnx模型
    model_content = read_model_file(model_file)
    import_options = nncase.ImportOptions()
    compiler.import_onnx(model_content, import_options)

    # 配置量化方式
    ptq_options = nncase.PTQTensorOptions()
    ptq_options.samples_count = 10

    if args.ptq_option == 0:
        ptq_options.calibrate_method = 'NoClip'
        ptq_options.quant_type = 'uint8'
        ptq_options.w_quant_type = 'uint8'
    elif args.ptq_option == 1:
        ptq_options.calibrate_method = 'NoClip'
        ptq_options.quant_type = 'uint8'
        ptq_options.w_quant_type = 'int16'
    elif args.ptq_option == 2:
        ptq_options.calibrate_method = 'NoClip'
        ptq_options.quant_type = 'int16'
        ptq_options.w_quant_type = 'uint8'
    elif args.ptq_option == 3:
        ptq_options.calibrate_method = 'Kld'
        ptq_options.quant_type = 'uint8'
        ptq_options.w_quant_type = 'uint8'
    elif args.ptq_option == 4:
        ptq_options.calibrate_method = 'Kld'
        ptq_options.quant_type = 'uint8'
        ptq_options.w_quant_type = 'int16'
    elif args.ptq_option == 5:
        ptq_options.calibrate_method = 'Kld'
        ptq_options.quant_type = 'int16'
        ptq_options.w_quant_type = 'uint8'
    else:
        pass

    # 设置校正数据
    ptq_options.set_tensor_data(generate_data(input_shape, ptq_options.samples_count, args.dataset_path))
    compiler.use_ptq(ptq_options)

    # 启动编译
    compiler.compile()

    # 写入kmodel文件
    kmodel = compiler.gencode_tobytes()
    base,ext=os.path.splitext(args.model)
    kmodel_name=base+".kmodel"
    with open(kmodel_name, 'wb') as f:
        f.write(kmodel)


if __name__ == '__main__':
    main()

```

模型转换成功后需要将代码部署在开发板上，这个需要使用 `nncase_runtime` 编写 C++ 代码。

### 部署代码编写

部署代码的编写以YOLOv8检测为例，源代码在 `src/rtsmart/examples/kpu_run_yolov8` 目录下，在该目录下执行 `build_app.sh` 就可以在该目录下的 `k230_bin` 目录下得到编译好的图像推理和摄像头推理的可执行文件。使用KPU 运行时 API 对模型进行推理的流程如下。

<div class="mermaid">
graph TD;
    LoadModel("初始化interpreter实例<br>加载模型") -->SetInput("获取输入shape<br>初始化输入tensors")-->SetOutput("获取输出shape<br>初始化输出tensors")-->GetFrame("读取待推理数据<br>读取图片/来自摄像头")-->SetPreprocessParam("设置预处理参数，包括AI2D预处理方法配置、输入tensor、输出tensor")-->PreProcess("执行预处理，使读入的图片或视频帧符合**模型输入**")-->KPURun("执行模型推理")-->GetOutput("获取模型推理的输出指针")-->PostProcess("根据具体的场景对输出做后处理")-->DrawResult("将后处理的结果绘制在图片/屏幕上");
</div>

`AI2D` 提供的预处理方法是使用硬件实现，可以提高运行的效率。`Interpreter` 用于完成在KPU上推理模型。它们的输入输出都是 `host_runtime_tensor` 类型的数据。模型的输入可能是一个，也可能是多个；AI2D的处理结果一般都是给到模型使用的。在一开始初始化 `ai2d_builder` 和 `Interpreter` 的时候，一般将两个组件的输入输出tensor一并初始化。两个组件的示意图如下：

![AI2D](https://www.kendryte.com/api/post/attachment?id=511)

因为 `AI2D` 的输出tensor会给到模型的输入tensor做推理，所以单输入时可以将 `AI2D` 的输出tensor和`Interpreter` 的输入tensor绑定为一个，这样可以节省一个tensor的内存。如果不使用 `AI2D` 进行预处理，可以使用 `OpenCV` 对输入数据做预处理，然后创建`host_runtime_tensor`。示意图如下：

![pipe_inference](https://www.kendryte.com/api/post/attachment?id=510)

这里对图像推理代码的 `main` 方法进行解析，源代码如下：

```c++
int main(int argc, char *argv[])
{
    std::cout << "case " << argv[0] << " build " << __DATE__ << " " << __TIME__ << std::endl;
    if (argc < 4)
    {
        std::cerr << "Usage: " << argv[0] << " <kmodel> <image> <debug_mode>" << std::endl;
        return -1;
    }

    int debug_mode=atoi(argv[3]);

    // 加载模型
    interpreter interp;     
    std::ifstream ifs(argv[1], std::ios::binary);
    interp.load_model(ifs).expect("Invalid kmodel");

    //初始化shape容器和输出数据指针容器，用于存储多个输入和多个输出的shape信息以及推理输出数据的指针
    vector<vector<int>> input_shapes;   
    vector<vector<int>> output_shapes;
    vector<float *> p_outputs;

    // 获取模型的输入信息，并初始化输入tensor
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

    // 获取模型输出的shape信息，并初始化输出的tensor
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

    // 读入图片，并将数据处理成CHW和RGB格式
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

    // 计算预处理参数，这里计算的是短边padding的参数值
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

    // 创建AI2D输入tensor，并将CHW_RGB数据拷贝到tensor中，并回写到DDR
    dims_t ai2d_in_shape{1, 3, ori_h, ori_w};
    runtime_tensor ai2d_in_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, ai2d_in_shape, hrt::pool_shared).expect("cannot create input tensor");
    auto input_buf = ai2d_in_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
    memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
    hrt::sync(ai2d_in_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

    // 创建AI2D输出tensor,因为AI2D的输出tensor给到模型的输入tensor去推理，这里为了节省内存，直接获取kmodel的输入tensor，使得AI2D处理后的输出直接给到kmodel输入
    runtime_tensor ai2d_out_tensor = interp.input_tensor(0).expect("cannot get input tensor");
    dims_t out_shape = ai2d_out_tensor.shape();

    // 设置AI2D参数，AI2D支持5种预处理方法，crop/shift/pad/resize/affine。这里开启pad和resize，并配置padding的大小和数值，设置resize的插值方法，如果要配置其他的预处理方法也是类似
    ai2d_datatype_t ai2d_dtype{ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, ai2d_in_tensor.datatype(), ai2d_out_tensor.datatype()};
    ai2d_crop_param_t crop_param{false, 0, 0, 0, 0};
    ai2d_shift_param_t shift_param{false, 0};
    ai2d_pad_param_t pad_param{true, {{0, 0}, {0, 0}, {top, bottom}, {left, right}}, ai2d_pad_mode::constant, {114, 114, 114}};
    ai2d_resize_param_t resize_param{true, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
    ai2d_affine_param_t affine_param{false, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};

    // 构造ai2d_builder
    ai2d_builder builder(ai2d_in_shape, out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param);
    builder.build_schedule();
    // 执行ai2d，实现从ai2d_in_tensor->ai2d_out_tensor的预处理过程
    builder.invoke(ai2d_in_tensor,ai2d_out_tensor).expect("error occurred in ai2d running");

    // 执行模型推理的过程
    interp.run().expect("error occurred in running model");

    // 获取模型输出数据的指针
    p_outputs.clear();
    for (int i = 0; i < interp.outputs_size(); i++)
    {
        auto out = interp.output_tensor(i).expect("cannot get output tensor");
        auto buf = out.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_read).unwrap().buffer();
        float *p_out = reinterpret_cast<float *>(buf.data());
        p_outputs.push_back(p_out);
    }

    // 模型推理结束后，进行后处理
    // 标签名称
    std::vector<std::string> classes{"apple","banana","orange"};
    // 置信度阈值
    float conf_thresh=0.25;
    // nms阈值
    float nms_thresh=0.45;
    //类别数
    int class_num=classes.size();
    // 根据类别数获取颜色，用于后续画图
    std::vector<cv::Scalar> class_colors = getColorsForClasses(class_num);

    // output0 [num_class+4,(w/8)*(h/8)+(w/16)*(h/16)+(w/32)*(h/32)]
    float *output0 = p_outputs[0];
    // 每个框的特征长度，ckass_num个分数+4个坐标
    int f_len=class_num+4;
    // 根据模型的输入分辨率计算总输出框数
    int num_box=((input_shapes[0][2]/8)*(input_shapes[0][3]/8)+(input_shapes[0][2]/16)*(input_shapes[0][3]/16)+(input_shapes[0][2]/32)*(input_shapes[0][3]/32));
    // 申请框数据内存
    float *output_det = new float[num_box * f_len];
    // 将输出数据排布从[num_class+4,(w/8)*(h/8)+(w/16)*(h/16)+(w/32)*(h/32)]调整为[(w/8)*(h/8)+(w/16)*(h/16)+(w/32)*(h/32),num_class+4],方便后续处理
    for(int r = 0; r < num_box; r++)
    {
        for(int c = 0; c < f_len; c++)
        {
            output_det[r*f_len + c] = output0[c*num_box + r];
        }
    }

    // 解析每个框的信息，class_num+4为一个框，前四个数据为坐标值，后面的class_num个分数，选择分数最大的作为识别的类别，因为开始的时候做了padding+resize，所以模型推理的坐标是基于与处理后的图像的结果，要先把框的坐标使用ratio映射回原图
    std::vector<Bbox> bboxes;
    for(int i=0;i<num_box;i++){
        float* vec=output_det+i*f_len;
        float box[4]={vec[0],vec[1],vec[2],vec[3]};
        float* class_scores=vec+4;
        float* max_class_score_ptr=std::max_element(class_scores,class_scores+class_num);
        float score=*max_class_score_ptr;
        int max_class_index = max_class_score_ptr - class_scores; // 计算索引
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

    //执行非最大抑制以消除具有较低置信度的冗余重叠框（NMS）
    std::vector<int> nms_result;
    nms(bboxes, conf_thresh, nms_thresh, nms_result);

    // 将识别的框绘制到原图片上并保存为结果图片result,jpg
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

视频流推理代码类似，只不过推理帧数据不在使用opencv从图片中读取，而是从摄像头中获取。

### 代码编译并运行

代码编写完成后，编写 `CMakeLists.txt` 或者 `Makefile` 对源码进行编译，针对上述示例，您可以在 `src/rtsmart/examples/kpu_run_yolov8` 目录下执行 `build_app.sh` 脚本进行编译。编译生成物在 `k230_bin` 目录下，将其拷贝到烧录固件的TF卡中，执行对应的命令运行程序。

推理yolov8n 静态图：

```shell
./yolov8_image.elf best.kmodel test.jpg 2
```

推理yolov8 摄像头数据：

```shell
./yolov8_camera.elf best.kmodel 0.3 0.45 2
```

上述过程详细在于说明模型转换和使用kpu进行模型推理的步骤，并不适用于所有的场景，您可以参考上述代码进行不同场景的应用开发。
