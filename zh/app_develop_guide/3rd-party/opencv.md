# OpenCV 示例

## OpenCV简介

`OpenCV (Open Source Computer Vision Library)`，是一个跨平台的计算机视觉库，由英特尔公司发起并参与开发，以 `BSD` 许可证授权发行，可以在商业和研究领域中免费使用。`OpenCV` 可用于开发实时的图像处理、计算机视觉以及模式识别程序。`K230 RTOS SDK` 提供了针对 `K230` 优化的升级版 `OpenCV` 加速库，相比于原始版本 `OpenCV`，可大幅减少 `OpenCV` 算子的推理时间。比如：

| 算子名称 |K230+原始版OpenCV | K230+升级版OpenCV |
| ---    |  ---      | ---             |
| 计算积分图(inter) |   34.5ms | 7.7ms |
| 仿射变换 (warpaffine) |  391.1ms |34.7ms  |

注意：
>上述算子推理时间均在K230大核+1.6GHZ的条件下测试。
>计算积分图(inter)算子：输入图像为1280x1080灰度图；积分图类型为32位浮点数。
>仿射变换 (warpaffine)算子：输入图像为1280x1080灰度图；顺时针旋转15度，缩放0.6倍；目标图像为1280x1080灰度图；

此外，`K230 RTOS SDK` 中已包含预先交叉编译好的升级版 `OpenCV` 加速库(位于`src/rtsmart/libs/opencv/`路径下)，用户直接使用该静态库编译自己的可执行程序即可。

## 编译示例

本节介绍如何使用在 `K230 RTOS SDK` 中编译好的的 `OpenCV` 静态库，来进行可执行程序的编译。`SDK` 的给出5个基于 `OpenCV` 实现的可执行程序编译示例(位于 `src/rtsmart/examples/opencv_examples/` 路径下)。

### 代码结构

该路径下的目录结构说明如下：

``` shell
|-- opencv_calculate_hist               # 计算图像直方图
|   |-- CMakeLists.txt 
|   `-- opencv_calculate_hist.cpp
|-- opencv_detect_features2d            # 特征点检测
|   |-- CMakeLists.txt
|   `-- opencv_detect_feature.cpp 
|-- opencv_find_contours                # 轮廓检测
|   |-- CMakeLists.txt
|   `-- opencv_find_contours.cpp
|-- 4_opencv_grayscale_binarize         # 灰度化和二值化
|   |-- CMakeLists.txt
|   `-- opencv_grayscale_binarize.cpp
|-- 5_opencv_obj_detect                 # 人脸和人眼检测
|   |-- CMakeLists.txt
|   `-- opencv_obj_detect.cpp
|-- CMakeLists.txt                      # CMake配置文件
|-- build_app.sh                        # 编译脚本
|-- cmake                               # 默认CMake配置
|   |-- Riscv64.cmake
|   `-- link.lds
`-- utils                               # OpenCV示例所需的所有输入图片及数据
    |-- 1.bmp
    ...
    |-- a.jpg
```

### 固件编译

如果您想在编译固件时将示例编译进固件，在 `K230 RTOS SDK` 根目录下使用`make menuconfig` 配置编译选项，将示例编译到固件中的 `sdcard/app/examples/opencv_examples`路径下，直接烧录固件运行即可。

![opencv_examples_menuconfig](https://www.kendryte.com/api/post/attachment?id=540)

### 示例编译

如果您想只编译`OpenCV`示例程序，可以进入`src/rtsmart/examples/opencv_examples`，运行`build_app.sh`文件：

```shell
./build_app.sh
```

编译成功后，在 `src/rtsmart/examples/opencv_examples/k230_bin` 文件夹中即包含了编译好的所有elf文件和测试文件。您可以拷贝到开发板上测试运行。

## 运行示例

>注意：
>
>所有测试用例运行所需的输入图像数据，均位于 `SDK` 的 `src/rtsmart/examples/opencv_examples/utils`路径下。

### opencv_calculate_hist

本示例读取一张图像，计算其每个颜色通道（蓝、绿、红）的直方图，`opencv_calculate_hist` 测试用例的运行方式如下：

```shell
msh /sdcard/app/examples/opencv_examples>./opencv_calculate_hist.elf
```

原图如下：

![image_opencv_calculate_hist](https://www.kendryte.com/api/post/attachment?id=542)

`opencv_calculate_hist`测试用例的运行结果示例如下：

![test_opencv_calculate_hist](https://www.kendryte.com/api/post/attachment?id=541)

### opencv_detect_features2d

本示例主要功能是读取一张图像，使用 FAST 特征检测器检测图像中的特征点，`opencv_detect_features2d`测试用例的运行方式如下：

```shell
msh /sdcard/app/examples/opencv_examples>./opencv_detect_features2d.elf
```

`opencv_detect_features2d`测试用例的运行结果示例如下：

原图如下：

![image_opencv_detect_features2d](https://www.kendryte.com/api/post/attachment?id=543)

`opencv_detect_features2d`测试用例的运行结果示例如下：

![test_opencv_detect_features2d](https://www.kendryte.com/api/post/attachment?id=544)

### opencv_find_contours

本示例用于读取图像，检测图像中的轮廓，并将轮廓绘制出来保存为新图像，`opencv_find_contours`测试用例的运行方式如下：

```shell
msh /sdcard/app/examples/opencv_examples>./opencv_find_contours.elf
```

`opencv_find_contours`测试用例的运行结果示例如下：

原图如下：

![image_opencv_find_contours](https://www.kendryte.com/api/post/attachment?id=542)

`opencv_find_contours`测试用例的运行结果示例如下：

![test_opencv_find_contours](https://www.kendryte.com/api/post/attachment?id=545)

### opencv_grayscale_binarize

本示例主要功能是读取一张彩色图像，将其转换为灰度图像并保存，然后对灰度图像进行二值化处理并保存处理后的图像。`opencv_grayscale_binarize`测试用例的运行方式如下：

```shell
msh /sdcard/app/examples/opencv_examples>./opencv_grayscale_binarize.elf
```

`opencv_grayscale_binarize`测试用例的运行结果示例如下：

原图如下：

![image_opencv_grayscale_binarize](https://www.kendryte.com/api/post/attachment?id=542)

灰度图如下：

![grayscale_opencv_grayscale_binarize](https://www.kendryte.com/api/post/attachment?id=546)

`opencv_grayscale_binarize`测试用例的运行结果示例如下：

![test_opencv_grayscale_binarize](https://www.kendryte.com/api/post/attachment?id=547)

### opencv_obj_detect

本示例使用级联分类器检测图像中的人脸和眼睛，并在原始图像上绘制检测结果，`opencv_obj_detect`测试用例的运行方式如下：

```shell
msh /sdcard/app/examples/opencv_examples>./opencv_obj_detect.elf
```

`opencv_obj_detect`测试用例的运行结果示例如下：

原图如下：

![image_opencv_obj_detect](https://www.kendryte.com/api/post/attachment?id=549)

`opencv_obj_detect`测试用例的运行结果示例如下：

![test_opencv_obj_detect](https://www.kendryte.com/api/post/attachment?id=548)
