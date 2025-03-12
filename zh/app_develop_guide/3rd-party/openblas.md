# OpenBLAS 示例

## OpenBLAS简介

`OpenBLAS` 是一个基于 `BSD` 许可(开源)发行的优化`BLAS`计算库。`BLAS(Basic Linear Algebra Subprograms，基础线性代数程序集)`是一个应用程序接口(API)标准，用以规范发布基础线性代数操作的数值库(如矢量或矩阵乘法)，`OpenBLAS` 是 `BLAS` 标准的一种具体实现。

在 `K230 RTOS SDK` 中，已包含预先交叉编译好的 `OpenBLAS` 库位于`src/rtsmart/libs/openblas/`路径下，用户直接使用该静态库编译自己的可执行程序即可。

## 编译示例

本节介绍如何使用 `SDK` 中预置的 `OpenBLAS` 静态库，来进行可执行程序的编译。`SDK` 中已包含4个基于 `OpenBLAS` 实现的可执行程序编译示例(位于`src/rtsmart/libs/openblas/`路径下)。

### 代码结构

该路径下的目录结构说明如下：

```shell
|-- openblas_cblas_saxpy            # saxpy示例，实现y = alpha * x + y
|   |-- CMakeLists.txt
|   `-- openblas_cblas_saxpy.cpp
|-- openblas_cblas_sgemm            # sgemm示例，实现C = alpha * A * B + beta * C
|   |-- CMakeLists.txt
|   `-- openblas_cblas_sgemm.cpp
|-- openblas_cblas_sger             # sger示例，实现A = alpha * x * y^T + beta * A
|   |-- CMakeLists.txt
|   `-- openblas_cblas_sger.cpp
|-- openblas_fortran_dgemm          # Fortran接口示例，实现C = alpha * A * B + beta * C
|   |-- CMakeLists.txt
|   `-- openblas_fortran_dgemm.cpp
|-- CMakeLists.txt                  # CMake配置文件
|-- build_app.sh                    # 编译脚本
|-- cmake                           # 默认CMake配置
|   |-- Riscv64.cmake
|   `-- link.lds
```

### 固件编译

如果您想在编译固件时将示例编译进固件，在 `K230 RTOS SDK` 根目录下使用`make menuconfig` 配置编译选项，示例将被编译到固件中的 `sdcard/app/examples/openblas_examples` 路径下，直接烧录固件运行即可。

![openblas_examples_menuconfig](https://developer.canaan-creative.com/api/post/attachment?id=550)

### 示例编译

如果您想只编译`OpenBLAS`示例程序，可以进入`src/rtsmart/examples/openblas_examples`，运行`build_app.sh`文件：

```shell
./build_app.sh
```

编译成功后，在 `src/rtsmart/examples/openblas_examples/k230_bin` 文件夹中即包含了编译好的所有elf文件和测试文件。您可以拷贝到开发板上测试运行。

## 运行示例

### openblas_cblas_saxpy

运行方式及输出结果示例如下：

```shell
msh /sdcard/app/examples/openblas_examples>./openblas_cblas_saxpy.elf
*********************************************************
This is the result:
4 7 11 14
*********************************************************
This is the reference:
4 7 11 14
{Test PASS}.
```

### openblas_cblas_sgemm

运行方式及输出结果示例如下：

```shell
msh /sdcard/app/examples/openblas_examples>./openblas_cblas_sgemm.elf
*********************************************************
This is the result:
7 10 15 22
*********************************************************
This is the reference:
7 10 15 22
{Test PASS}.
```

### openblas_cblas_sger

运行方式及输出结果示例如下：

```shell
msh /sdcard/app/examples/openblas_examples>./openblas_cblas_sger.elf
*********************************************************
This is the result:
20 40 10 20 30 60
*********************************************************
This is the reference:
20 40 10 20 30 60
{Test PASS}.

```

### openblas_fortran_dgemm

运行方式及输出结果示例如下：

```shell
msh /sdcard/app/examples/openblas_examples>./openblas_fortran_dgemm.elf
m=2,n=3,k=4,alpha=1.200000,beta=0.001000,sizeofc=6
This is matrix A

1.000000 2.000000 3.000000 1.000000 2.000000 3.000000 1.000000 2.000000
This is matrix B

1.000000 2.000000 3.000000 1.000000 2.000000 3.000000 1.000000 2.000000 3.000000 1.000000 2.000000 3.000000
*********************************************************
This is the result:
16.801 18.002 18.003 16.801 15.602 22.803
*********************************************************
This is the reference:
16.801 18.002 18.003 16.801 15.602 22.803
{Test PASS}.
```
