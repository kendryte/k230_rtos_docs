# Multi-Object Tracking (MOT) Application Development Guide

```{attention}
The development logic of this example code uses a single-camera dual-channel implementation. For the development logic of bytetrack and ocsort, refer to the document: [Single Model Development Application Guide](./single_model_example.md). For the development logic of deepsort and botsort, refer to the document: [Double Model Development Application Guide](./double_model_example.md).
```

## Overview of Multi-Object Tracking

Multi-Object Tracking (MOT) aims to detect multiple targets in a video sequence and maintain consistent identities (IDs) for each target across consecutive frames. A typical MOT pipeline includes:

1. **Object Detection** —— Use detectors such as YOLO to detect targets (e.g., pedestrians, vehicles) in each frame.
1. **State Prediction** —— Predict the motion of targets between adjacent frames, usually using a Kalman filter.
1. **Data Association** —— Match current detection results with existing tracks based on motion information, appearance features, or a combination of both.
1. **Track Management** —— Initialize new tracks, update existing tracks, and delete lost tracks.

This example supports four algorithms: **DeepSORT, ByteTrack, OCSort, and BoTSORT**. They represent different design trade-offs in terms of accuracy, robustness, computational overhead, and dependence on appearance features.

## Algorithm Introduction

### DeepSORT

DeepSORT is an extension of the classic SORT (Simple Online and Realtime Tracking) algorithm. SORT relies solely on motion information (bounding box geometric relationships and Kalman filter predictions), whereas DeepSORT introduces **deep appearance features (ReID)**, significantly improving identity consistency in occlusion and re-identification scenarios.

**Core Components**:

* **Motion Model**:

  * Constant velocity Kalman filter
  * State typically includes position, scale, aspect ratio, and their velocities

* **Appearance Model**:

  * Use deep CNN to extract feature embedding vectors for each detected target
  * Features are usually L2-normalized vectors (e.g., 512 dimensions)

* **Data Association**:

  * First stage: Mahalanobis distance gating using Kalman filter predictions
  * Second stage: Matching based on combined cost via the Hungarian algorithm:

    * Motion distance (Mahalanobis distance)
    * Appearance distance (cosine similarity)

* **Track Lifecycle**:

  * Track states include *Tentative*, *Confirmed*, and *Deleted*
  * Tracks are only confirmed after several consecutive successful matches

### ByteTrack

ByteTrack is a modern MOT algorithm designed to **maximize tracking performance without using appearance features**. Its core idea is: **low-confidence detection results, although often discarded, still contain valuable motion information**. Traditional trackers typically only use high-confidence detections for association, ignoring low-confidence detections. ByteTrack divides detection results into:

* **High-score detections**: used for reliable matching;
* **Low-score detections**: used to recover potentially lost tracks;

Matching process:

1. **High-score matching stage**:

   * Use IoU distance to match predicted tracks with high-confidence detections
   * Solved using the Hungarian algorithm

1. **Low-score matching stage**:

   * Further match unmatched tracks with low-confidence detections
   * Helps recover targets during occlusion or motion blur

1. **Track Management**:

   * New tracks are initialized only by high-score detections
   * Low-score detections are never used to create new tracks

Key features of ByteTrack include:

* Pure motion modeling (Kalman filter + IoU matching)
* No ReID model required
* Extremely fast and easy to deploy

### OCSort

OCSort is an improvement based on SORT/ByteTrack-style trackers, addressing the issue of inaccurate motion prediction by the Kalman filter during **剧烈运动 or camera movement**. OCSort introduces **Observation-Centric Motion Modeling**, placing greater emphasis on recent observations rather than long-term velocity estimates.

Key techniques include:

* **Estimating velocity based on recent observations**, rather than relying entirely on Kalman state
* **Adaptive association strategy**, which is more robust in the following situations:

  * Sudden acceleration
  * Camera shake or fast panning

OCSort uses IoU matching similar to SORT/ByteTrack, introduces direction consistency constraints, and focuses on geometric consistency rather than appearance features.

### BoTSORT

BoTSORT combines the advantages of **ByteTrack** and **DeepSORT**, aiming to achieve stronger identity consistency while maintaining high speed. BoTSORT integrates:

* **ByteTrack-style detection association strategy** (high-score and low-score detections)
* **Optional appearance-based ReID features** (similar to DeepSORT)
* **Better motion modeling compared to classic SORT**

Data association strategy:

1. **Primary association stage**:

   * Match high-confidence detections with tracks
   * The cost function may include:

     * IoU distance
     * Appearance distance (cosine distance), if ReID is enabled

1. **Secondary association stage**:

   * Use low-confidence detections to match remaining tracks
   * Helps reduce mistakenly deleted tracks

### Comparison and Application Scenarios

| Algorithm        | Uses ReID | Motion Model Focus              | Complexity | Core Features                                                                                                                                                                          |
| ------------- | ------- | ------------------ | --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **DeepSORT**  | Yes       | Kalman filter + appearance features       | High   | Introduces deep appearance features (ReID), significantly improving identity consistency in occlusion and target re-identification (Re-identification) scenarios, with strong ID stability.                  |
| **ByteTrack** | No       | Kalman filter + IoU        | Low   | Fast speed and simple structure. Maximizes tracking performance without using appearance features; not only uses high-confidence detections but also leverages effective motion information from low-confidence detections to recover potentially lost tracks.               |
| **OCSort**    | No       | Observation-centric motion model        | Medium   | Introduces **Observation-Centric** motion modeling, estimating velocity based on recent observations rather than fully relying on Kalman predictions, making it more stable in cases of detection jitter and short-term loss.           |
| **BoTSORT**   | Yes       | Kalman filter + IoU + ReID | High   | Introduces Camera Motion Compensation (CMC) and improved Kalman state modeling for more precise bounding box localization; fuses motion and appearance information through multi-stage matching and IoU + ReID distance fusion strategy, performing excellently in complex scenarios. |

K230 integrates these algorithms into the same type of application, requiring no refactoring of underlying code. Simply switching the object detection model and adjusting tracking algorithm parameters allows rapid adaptation, accelerating development and deployment while greatly reducing development costs.

## Compile Code

Go back to the `RTOS` root directory and check the supported development boards:

```shell
make list-def
```

Switch the development board being used and compile. Switch to the development board you are using:

```shell
make ***_defconfig

make -j
```

After the execution is complete, the compiled image will be generated in the `output` directory.

* **Compilation Method One**

After the code modifications described in the previous sections are completed, navigate to one of the algorithm directories at the same level as `src/rtsmart/examples/ai/multi_object_tracking`, and execute:

```bash
build_app.sh
```

After the script execution is complete, the compilation intermediate products are located in the `build` directory, and the deployment summary files are located in the `k230_bin` directory.

* **Compilation Method Two**

Execute `make menuconfig` in the `RTOS SDK` root directory, select `RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build MOT(Multi-Object Tracking) Programs`->`Botsort tracking algorithm`, save and exit. As shown in the figure below:

![rtos_facedet_menuconfig](https://www.kendryte.com/api/post/attachment?id=849)

Since a `Makefile` is provided, directly execute

```bash
make -j
```

This way, the deployment summary files will be directly compiled into the firmware at `/sdcard/app/examples/ai/multi_object_tracking/botsort_track_app` during the compilation process.

You can also **directly navigate to the corresponding directory** and execute:

```bash
make -j
```

This command can also achieve compilation, and the compilation products will be generated in the `k230_bin` directory. The compilation process implements incremental compilation.

## Board Deployment

Flash the firmware and power on. For firmware flashing, refer to the document: [how_to_flash](../../userguide/how_to_flash.md).

You can see a virtual disk `CanMV` at the drive letter. Copy the elf file, kmodel file, and other used files such as test images compiled under `k230_bin` to the `CanMV/sdcard` directory.

Then use a serial port tool to connect to the development board and execute the `run.sh` command on the command line.

After the program starts, you should be able to see the video output on the screen. The deployment result is shown in the figure below:

![multi_object_tracking](https://www.kendryte.com/api/post/attachment?id=851)

If you want to use an HDMI monitor for display, please modify the source file `~/canmv_k230/src/rtsmart/examples/ai/multi_object_tracking/botsort_track_app/src/setting.h`, and change:

```c
#define DISPLAY_TYPE 'st7701'
```

to:

```c
#define DISPLAY_TYPE 'lt9611'
```

Then re-execute the above application compilation process.
