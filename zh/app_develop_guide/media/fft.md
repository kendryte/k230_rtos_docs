# FFT Demo

## 简介

本示例展示了如何使用 K230 的 FFT API 进行快速傅里叶变换（FFT）和逆快速傅里叶变换（IFFT）的计算。通过该示例，用户可以学习如何调用相关 API 来执行 FFT 和 IFFT 操作，并验证其正确性和性能。

该 demo 首先进行 FFT 计算，然后进行 IFFT 计算，以验证 FFT 功能的准确性和效率。具体来说，demo 对不同点数（如 64、128、256 等）的数据进行 FFT 和 IFFT 操作，并记录每个点的最大差异和计算时间。输出结果包括以下信息：

1. 每个点数的 FFT 和 IFFT 操作的最大差异。
1. 每个点的具体差异值，包括实部和虚部的差异。
1. 每个点数的 FFT 和 IFFT 操作所用的时间（以微秒为单位）。
1. 最终结果是否正确（通过比较差异值来判断）。

通过这些信息，用户可以评估 FFT 和 IFFT 操作的准确性和性能。

## 使用说明

demo 源码位置：`canmv_k230/src/rtsmart/mpp/userapps/sample/sample_fft`。

假设您已经正确编译该 demo。启动开发板后，进入 `/sdcard/elf/userapps` 目录，运行 `sample_fft.elf` 进行测试。

## 示例

在命令行输入以下命令来运行 FFT 示例：

```bash
./sample_fft.elf 1
```

运行后，您将看到类似以下的输出结果：

```shell
-----fft ifft point 0064  -------
    max diff 0003 0001
    i=0045 real  hf 0000  hif fc24 org fc21 dif 0003
    i=0003 imag  hf ffff  hif 0001 org 0000 dif 0001
-----fft ifft point 0064 use 133 us result: ok

-----fft ifft point 0128  -------
    max diff 0003 0002
    i=0015 real  hf 0001  hif fca1 org fc9e dif 0003
    i=0031 imag  hf 0001  hif fffe org 0000 dif 0002
-----fft ifft point 0128 use 121 us result: ok

-----fft ifft point 0256  -------
    max diff 0003 0001
    i=0030 real  hf 0000  hif fca1 org fc9e dif 0003
    i=0007 imag  hf ffff  hif 0001 org 0000 dif 0001
-----fft ifft point 0256 use 148 us result: ok

-----fft ifft point 0512  -------
    max diff 0003 0003
    i=0060 real  hf 0000  hif fca1 org fc9e dif 0003
    i=0314 imag  hf 0001  hif fffd org 0000 dif 0003
-----fft ifft point 0512 use 206 us result: ok

-----fft ifft point 1024  -------
    max diff 0005 0002
    i=0511 real  hf 0000  hif fc00 org fc05 dif 0005
    i=0150 imag  hf 0000  hif fffe org 0000 dif 0002
-----fft ifft point 1024 use 328 us result: ok

-----fft ifft point 2048  -------
    max diff 0005 0003
    i=1022 real  hf 0000  hif fc00 org fc05 dif 0005
    i=1021 imag  hf 0000  hif 0003 org 0000 dif 0003
-----fft ifft point 2048 use 574 us result: ok

-----fft ifft point 4096  -------
    max diff 0005 0002
    i=4094 real  hf 027b  hif 041f org 0424 dif 0005
    i=0122 imag  hf 0000  hif 0002 org 0000 dif 0002
-----fft ifft point 4096 use 1099 us result: ok
```

通过这些输出，您可以验证 FFT 和 IFFT 操作的准确性和性能。

```{admonition} 提示
有关 fft 模块的具体接口，请参考[API文档](../../api_reference/fft.md)
```
