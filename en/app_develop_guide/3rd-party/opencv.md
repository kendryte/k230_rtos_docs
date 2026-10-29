# OpenCV Examples

## Introduction to OpenCV

`OpenCV (Open Source Computer Vision Library)` is a cross-platform computer vision library initiated and developed by Intel Corporation. It is released under the `BSD` license and can be used free of charge in commercial and research fields. `OpenCV` can be used to develop real-time image processing, computer vision, and pattern recognition programs. The `K230 RTOS SDK` provides an upgraded `OpenCV` acceleration library optimized for `K230`. Compared with the original version of `OpenCV`, it can significantly reduce the inference time of `OpenCV` operators. For example:

| Operator Name |K230+Original OpenCV | K230+Upgraded OpenCV |
| ---    |  ---      | ---             |
| Integral Image Calculation (inter) |   34.5ms | 7.7ms |
| Affine Transformation (warpaffine) |  391.1ms |34.7ms  |

Note:
>The above operator inference times are all tested under the conditions of K230 big core + 1.6GHZ.
>Integral Image Calculation (inter) operator: input image is 1280x1080 grayscale image; integral image type is 32-bit floating point.
>Affine Transformation (warpaffine) operator: input image is 1280x1080 grayscale image; rotate 15 degrees clockwise, scale by 0.6; target image is 1280x1080 grayscale image;

In addition, the `K230 RTOS SDK` already contains a pre-cross-compiled upgraded version of the `OpenCV` acceleration library (located in the `src/rtsmart/libs/opencv/` path), and users can directly use this static library to compile their own executable programs.

## Compiling Examples

This section describes how to use the `OpenCV` static library compiled in the `K230 RTOS SDK` to compile executable programs. The `SDK` provides 5 executable program compilation examples based on `OpenCV` (located in the `src/rtsmart/examples/3rd-party/opencv` path).

### Code Structure

The directory structure under this path is described as follows:

``` shell
|-- opencv_calculate_hist               # Calculate image histogram
|   |-- CMakeLists.txt 
|   `-- opencv_calculate_hist.cpp
|-- opencv_detect_features2d            # Feature point detection
|   |-- CMakeLists.txt
|   `-- opencv_detect_feature.cpp 
|-- opencv_find_contours                # Contour detection
|   |-- CMakeLists.txt
|   `-- opencv_find_contours.cpp
|-- 4_opencv_grayscale_binarize         # Grayscale and binarization
|   |-- CMakeLists.txt
|   `-- opencv_grayscale_binarize.cpp
|-- 5_opencv_obj_detect                 # Face and eye detection
|   |-- CMakeLists.txt
|   `-- opencv_obj_detect.cpp
|-- CMakeLists.txt                      # CMake configuration file
|-- build_app.sh                        # Compilation script
|-- cmake                               # Default CMake configuration
|   |-- Riscv64.cmake
|   `-- link.lds
`-- utils                               # All input images and data required for OpenCV examples
    |-- 1.bmp
    ...
    |-- a.jpg
```

### Firmware Compilation

If you want to compile the examples into the firmware during firmware compilation, use `make menuconfig` in the `K230 RTOS SDK` root directory to configure the compilation options, select `RT-Smart UserSpace Examples Configuration`->`Enable build 3rd-party examples`->`Enable Build OpenCV Sample Programs`, save and exit. As shown in the figure below:

![openblas_examples_menuconfig](https://www.kendryte.com/api/post/attachment?id=860)

The examples will be compiled into the firmware under the `sdcard/app/examples/3rd-party/opencv` path, and you can directly flash the firmware and run it.

### Example Compilation

If you only want to compile the `OpenCV` example programs, you can enter `src/rtsmart/examples/3rd-party/opencv` and run the `build_app.sh` file:

```shell
./build_app.sh
```

After successful compilation, the `src/rtsmart/examples/3rd-party/opencv/k230_bin` folder contains all the compiled elf files and test files. You can copy them to the development board for testing and running.

## Running Examples

>Note:
>
>All input image data required to run the test cases is located in the `SDK` at the `src/rtsmart/examples/3rd-party/opencv/utils` path.

### opencv_calculate_hist

This example reads an image and calculates the histogram for each color channel (blue, green, red). The `opencv_calculate_hist` test case is run as follows:

```shell
msh /sdcard/app/examples/3rd-party/opencv>./opencv_calculate_hist.elf
```

The original image is as follows:

![image_opencv_calculate_hist](https://www.kendryte.com/api/post/attachment?id=542)

An example of the running result of the `opencv_calculate_hist` test case is as follows:

![test_opencv_calculate_hist](https://www.kendryte.com/api/post/attachment?id=541)

### opencv_detect_features2d

The main function of this example is to read an image and use the FAST feature detector to detect feature points in the image. The `opencv_detect_features2d` test case is run as follows:

```shell
msh /sdcard/app/examples/3rd-party/opencv>./opencv_detect_features2d.elf
```

An example of the running result of the `opencv_detect_features2d` test case is as follows:

The original image is as follows:

![image_opencv_detect_features2d](https://www.kendryte.com/api/post/attachment?id=543)

An example of the running result of the `opencv_detect_features2d` test case is as follows:

![test_opencv_detect_features2d](https://www.kendryte.com/api/post/attachment?id=544)

### opencv_find_contours

This example is used to read an image, detect contours in the image, and draw the contours and save them as a new image. The `opencv_find_contours` test case is run as follows:

```shell
msh /sdcard/app/examples/3rd-party/opencv>./opencv_find_contours.elf
```

An example of the running result of the `opencv_find_contours` test case is as follows:

The original image is as follows:

![image_opencv_find_contours](https://www.kendryte.com/api/post/attachment?id=542)

An example of the running result of the `opencv_find_contours` test case is as follows:

![test_opencv_find_contours](https://www.kendryte.com/api/post/attachment?id=545)

### opencv_grayscale_binarize

The main function of this example is to read a color image, convert it to a grayscale image and save it, then binarize the grayscale image and save the processed image. The `opencv_grayscale_binarize` test case is run as follows:

```shell
msh /sdcard/app/examples/3rd-party/opencv>./opencv_grayscale_binarize.elf
```

An example of the running result of the `opencv_grayscale_binarize` test case is as follows:

The original image is as follows:

![image_opencv_grayscale_binarize](https://www.kendryte.com/api/post/attachment?id=542)

The grayscale image is as follows:

![grayscale_opencv_grayscale_binarize](https://www.kendryte.com/api/post/attachment?id=546)

An example of the running result of the `opencv_grayscale_binarize` test case is as follows:

![test_opencv_grayscale_binarize](https://www.kendryte.com/api/post/attachment?id=547)

### opencv_obj_detect

This example uses a cascade classifier to detect faces and eyes in the image, and draws the detection results on the original image. The `opencv_obj_detect` test case is run as follows:

```shell
msh /sdcard/app/examples/3rd-party/opencv>./opencv_obj_detect.elf
```

An example of the running result of the `opencv_obj_detect` test case is as follows:

The original image is as follows:

![image_opencv_obj_detect](https://www.kendryte.com/api/post/attachment?id=549)

An example of the running result of the `opencv_obj_detect` test case is as follows:

![test_opencv_obj_detect](https://www.kendryte.com/api/post/attachment?id=548)
