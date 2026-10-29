# OpenBLAS Example

## Introduction to OpenBLAS

`OpenBLAS` is an optimized `BLAS` computational library distributed under the `BSD` license (open source). `BLAS (Basic Linear Algebra Subprograms)` is an application programming interface (API) standard that specifies the publication of numerical libraries for basic linear algebra operations (such as vector or matrix multiplication). `OpenBLAS` is a specific implementation of the `BLAS` standard.

In the `K230 RTOS SDK`, the pre-cross-compiled `OpenBLAS` library is included at the path `src/rtsmart/libs/openblas/`. Users can directly use this static library to compile their own executable programs.

## Compiling the Example

This section describes how to use the pre-built `OpenBLAS` static library in the `SDK` to compile an executable program. The `SDK` includes 4 executable program compilation examples based on `OpenBLAS` (located at the path `src/rtsmart/examples/3rd-party/openblas/`).

### Code Structure

The directory structure under this path is described as follows:

```shell
|-- openblas_cblas_saxpy            # saxpy example, implements y = alpha * x + y
|   |-- CMakeLists.txt
|   `-- openblas_cblas_saxpy.cpp
|-- openblas_cblas_sgemm            # sgemm example, implements C = alpha * A * B + beta * C
|   |-- CMakeLists.txt
|   `-- openblas_cblas_sgemm.cpp
|-- openblas_cblas_sger             # sger example, implements A = alpha * x * y^T + beta * A
|   |-- CMakeLists.txt
|   `-- openblas_cblas_sger.cpp
|-- openblas_fortran_dgemm          # Fortran interface example, implements C = alpha * A * B + beta * C
|   |-- CMakeLists.txt
|   `-- openblas_fortran_dgemm.cpp
|-- CMakeLists.txt                  # CMake configuration file
|-- build_app.sh                    # Build script
|-- cmake                           # Default CMake configuration
|   |-- Riscv64.cmake
|   `-- link.lds
```

### Firmware Compilation

If you want to compile the example into the firmware when building the firmware, use `make menuconfig` in the `K230 RTOS SDK` root directory to configure the build options, select `RT-Smart UserSpace Examples Configuration`->`Enable build 3rd-party examples`->`Enable Build OpenBlas Sample Programs`, save and exit. As shown in the figure below:

![openblas_examples_menuconfig](https://www.kendryte.com/api/post/attachment?id=859)

The example will be compiled into the firmware at the path `sdcard/app/examples/3rd-party/openblas`, and you can directly flash the firmware and run it.

### Example Compilation

If you only want to compile the `OpenBLAS` example program, you can enter `src/rtsmart/examples/3rd-party/openblas` and run the `build_app.sh` file:

```shell
./build_app.sh
```

After successful compilation, the `src/rtsmart/examples/3rd-party/openblas/k230_bin` folder contains all the compiled elf files and test files. You can copy them to the development board for testing and running.

## Running Examples

### openblas_cblas_saxpy

The running method and output result example are as follows:

```shell
msh /sdcard/app/examples/3rd-party/openblas>./openblas_cblas_saxpy.elf
*********************************************************
This is the result:
4 7 11 14
*********************************************************
This is the reference:
4 7 11 14
{Test PASS}.
```

### openblas_cblas_sgemm

The running method and output result example are as follows:

```shell
msh /sdcard/app/examples/3rd-party/openblas>./openblas_cblas_sgemm.elf
*********************************************************
This is the result:
7 10 15 22
*********************************************************
This is the reference:
7 10 15 22
{Test PASS}.
```

### openblas_cblas_sger

The running method and output result example are as follows:

```shell
msh /sdcard/app/examples/3rd-party/openblas>./openblas_cblas_sger.elf
*********************************************************
This is the result:
20 40 10 20 30 60
*********************************************************
This is the reference:
20 40 10 20 30 60
{Test PASS}.

```

### openblas_fortran_dgemm

The running method and output result example are as follows:

```shell
msh /sdcard/app/examples/3rd-party/openblas>./openblas_fortran_dgemm.elf
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
