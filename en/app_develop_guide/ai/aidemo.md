# AI Demo Application Guide

```{attention}
The development logic of AI Demo deployment code is implemented using a single-camera dual-channel approach. For the development logic, please refer to the document: [Single Model Development Application Guide](./single_model_example.md).
```

## Overview

The K230 AI Demo integrates modules such as face, human body, hand, license plate, word continuation, voice, and dms, covering various functions including classification, detection, segmentation, recognition, tracking, and monocular distance measurement. It provides customers with references on how to use the K230 to develop AI-related applications. The above applications are used to verify the capabilities of the K230 and enrich application scenarios. Actual application scenarios require targeted optimization to achieve better results. Reference optimization directions include adjusting thresholds, code optimization, quantization optimization, model optimization, training data optimization, etc.

## Supported Development Boards

- CanMV-K230-V1.1 / CanMV-K230-V3.0 / 01Studio CanMV K230/ Bpi-CanMV-K230D-Zero/ Lushan Pai-K230, etc.

## Source Code Description

### File Tree

The source code path is located at `src/rtsmart/examples/ai/ai_demo`, and the directory structure is as follows:

```shell
# In AI Demo subdirectories (e.g., bytetrack, face_detection, etc.), there are detailed Demo documentation README.md
.
├── anomaly_det
├── bytetrack
├── cmake
├── common_files
├── crosswalk_detect
├── distraction_reminder
├── dms_system
├── dynamic_gesture
├── eye_gaze
├── face_alignment
├── face_detection
├── face_emotion
├── face_gender
├── face_glasses
├── face_landmark
├── face_mask
├── face_mesh
├── face_parse
├── face_pose
├── face_verification
├── falldown_detect
├── finger_guessing
├── fitness
├── head_detection
├── helmet_detect
├── kws
├── licence_det
├── licence_det_rec
├── nanotracker
├── object_detect_yolov8n
├── ocr
├── person_attr
├── person_detect
├── person_distance
├── pose_detect
├── pphumanseg
├── puzzle_game
├── segment_yolov8n
├── self_learning
├── shell
├── smoke_detect
├── space_resize
├── sq_hand_det
├── sq_handkp_class
├── sq_handkp_det
├── sq_handkp_flower
├── sq_handkp_ocr
├── sq_handreco
├── traffic_light_detect
├── tts_zh
├── vehicle_attr
├── virtual_keyboard
├── yolop_lane_seg
├── CMakeLists.txt
├── Makefile
└── build_app.sh
```

The files in the `common_files` directory are shared by all Demos. The directory structure is as follows:

```shell
.
├── ai_base.cc        # Model inference wrapper class implementation, encapsulating the basic operations of nncase, including kmodel loading, setting inputs, getting outputs. Subsequent application development only needs to focus on model pre-processing and post-processing
├── ai_base.h         # Model inference wrapper class header file, defining the basic interfaces for model inference
├── ai_utils.cc       # Utility methods and classes, providing implementations for obtaining color palette, saving images, and various preprocessing methods
├── ai_utils.h        # Utility methods and classes header file, defining the interfaces for utility methods and classes
├── scoped_timing.h   # Time measurement class, used to measure code execution time
├── setting.h         # Configuration header file, mainly implementing the configuration parameters for different screen displays and the AI inference output image resolution
├── video_pipeline.cc # Single-camera dual-channel video stream wrapper implementation, implementing camera and display device initialization, getting video frames, displaying OSD results, etc.
└── video_pipeline.h  # Single-camera dual-channel video stream wrapper header file, defining the basic interfaces for video streams
```

The kmodel, image, and related dependency paths are located at `src/rtsmart/libs/kmodel/ai_poc`, which provides the kmodel, test images, and other necessary files required for ai_demo to run. During the ai_demo compilation process, the `build_app.sh` script will automatically copy them to the product directory according to the demo name.

### Demo Description

| Demo Subdirectory      | Scenario                  |      Description                  |
| :-------------------- | ------------------------ |--------------------------- |
| anomaly_det           | Anomaly Detection         | The model provided by the anomaly detection example is trained using the patchcore anomaly detection method, which can identify whether there is an anomaly at the mouth of a glass bottle from the input image. Anomaly detection is commonly applied in industrial image inspection, medical image analysis, security surveillance and other fields.                            |
| bytetrack             | Multi-Object Tracking     | The ByteTrack multi-object tracking example uses YOLOv5 as the object detection algorithm, applies the Kalman filter algorithm for bounding box prediction, and applies the Hungarian algorithm for matching between targets and trajectories.  |
| crosswalk_detect      | Crosswalk Detection        | Crosswalk detection uses the YOLOV5 network. This application detects crosswalks in images or videos, and can be used in scenarios such as assisted driving.                        |
| distraction_reminder  | Non-Forward Gaze Detection                  | The non-forward gaze detection example mainly uses face pose estimation as the basis, and uses logical judgment to remind drivers when their attention is not focused on the front. Face detection uses the retina-face model, and face orientation estimation uses 98 2D keypoint fitting                        |
| dms_system            | Driver Monitoring System             | The dms example is based on palm detection and face detection, and uses logical judgment to remind drivers of violations (smoking, making phone calls, drinking water) while driving. Face detection uses the retina-face network structure, with the backbone selected as 0.25-mobilenet. Palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2. |
| dynamic_gesture       | Visual Dynamic Gesture Recognition            | Visual dynamic gesture recognition can recognize five actions: waving up, down, left, right, and pinching five fingers together, used for contactless operation control scenarios. Palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2. Palm keypoint detection uses the resnet50 network structure. Dynamic gesture recognition uses the tsm structure, with the backbone selected as mobilenetV2.                            |
| eye_gaze              | Gaze Estimation                 |   The gaze estimation example predicts where a person is looking based on their face. For video frames or images, face detection is performed first, and then gaze estimation is performed on each face to predict the gaze vector, which is displayed on the screen as an arrow. This application uses the retina-face network for face detection and L2CS-Net for gaze estimation. Gaze estimation can be applied in the field of automotive safety.                          |
| face_alignment        | Face Alignment                 | The face alignment example can obtain the depth map or normalized projected coordinate encoding map of each face in images or videos. Face detection uses the retina-face network structure, with the backbone selected as 0.25-mobilenet. The face alignment network is implemented based on 3DDFA (3D Dense Face Alignment).            |
| face_detection        | Face Detection                 |  The face detection example can obtain the detection box for each face in images or videos, as well as the positions of five key points for each face: left eye, right eye, nose tip, left mouth corner, and right mouth corner. Face detection uses the retina-face network structure, with the backbone selected as 0.25-mobilenet.                           |
| face_emotion          | Facial Expression Recognition              | Facial expression recognition uses two models to implement expression recognition for each person in images/videos. The recognizable expression categories include Neutral, Happiness, Sadness, Anger, Disgust, Fear, and Surprise. Face detection uses the retina-face network structure; expression classification uses mobilenet as the backbone for classification to obtain the person's expression.                            |
| face_gender           | Gender Classification                 | The face gender classification example uses two models to implement the function of determining the gender of each person in images/videos. Each person's gender is represented by M or F, where M stands for Male and F stands for Female. Face detection uses the retina-face network structure; gender classification uses EfficientNetB3 as the backbone for classification to obtain the person's gender.                           |
| face_glasses          | Glasses Wearing Classification         | The glasses wearing classification example uses two models to implement the determination of whether each person in images/videos is wearing glasses. The face detection model uses the retina-face network structure; the face glasses classification model uses SqueezeNet-1.1 as the backbone to determine the glasses wearing status for each face box.                           |
| face_landmark         | Dense Face Keypoints            | The dense face keypoint detection application uses two models to detect 106 keypoints for each face in images/videos, and draws the contours of the face and facial features based on the 106 keypoints, with different contours represented in different colors. Face detection uses the retina-face network structure; dense keypoint detection uses 0.5-mobilenet as the backbone to detect 106 keypoints for each face. The 106 keypoints include the face's cheeks, mouth, eyes, nose, and eyebrow areas.                            |
| face_mask             | Mask Wearing Classification          | The mask wearing classification application uses two models to implement the determination of whether each person in images/videos is wearing a mask. In application scenarios where masks are required, if someone is found not wearing a mask, relevant reminders can be issued. The face detection model uses the retina-face network structure; the face mask classification model uses mobilenet-v2 as the backbone to determine the mask wearing status for each face box.                            |
| face_mesh             | 3D Face Mesh              |  3D face mesh can obtain the 3D mesh structure of each face in images or videos. Face detection uses the retina-face network structure, with the backbone selected as 0.25-mobilenet. The face alignment network is implemented based on 3DDFA (3D Dense Face Alignment).|
| face_parse            | Face Segmentation                  | The face segmentation example uses two models to implement the segmentation function for each face in images/videos. Face segmentation includes pixel-level differentiation of face areas such as eyes, nose, and mouth, with different areas represented in different colors. Face detection uses the retina-face network structure. Face part segmentation uses the DeepNetV3 network structure, with the backbone using mobilenet-1.0.                           |
| face_pose             | Face Pose Estimation             | Face pose estimation uses two models to implement the function of estimating the face orientation angles of each person in images/videos. Face orientation is generally represented by Euler angles (roll/yaw/pitch), where roll represents the degree of the face shaking left and right; yaw represents the degree of the face rotating left and right; pitch represents the degree of the face looking down and up. Face detection uses the retina-face model, and face orientation estimation uses 98 2D keypoint fitting.                            |
| face_verification     | Face Identity Verification             | Face identity verification is an identity verification technology based on facial biometric features, aimed at confirming whether an individual is the identity they claim to be. This technology verifies identity by analyzing and comparing the user's facial features, usually by comparing two images in a face verification system to determine whether the faces in the two images belong to the same person. Face detection uses the retina-face model, and face feature extraction uses ResNet50, outputting 512-dimensional features.                           |
| falldown_detect       | Fall Detection                 |  Fall detection can detect the falling state of people in images or videos. This example is implemented using the yolov5n model.                           |
| finger_guessing       | Rock-Paper-Scissors Game                 |  The rock-paper-scissors game example distinguishes rock-paper-scissors through hand gesture recognition, including two models: palm detection and hand 21 keypoint recognition. The gesture category is determined through the position constraints of the 21 keypoints. The palm detection part uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and the palm keypoint detection part uses the resnet50 network structure.                          |
| fitness               | Squat Movement Counting             |  The squat movement counting example implements the function of counting squat movements in videos, suitable for scenarios such as fitness state detection. It is implemented using the yolov8n-pose model.                           |
| head_detection        | Head Detection and Counting             |  The head detection and counting example implements the function of getting the coordinates and quantity of heads appearing in images or videos. It is implemented using the yolov8 model.                           |
| helmet_detect         | Helmet Detection               | The helmet detection example implements the detection of whether people appearing in images or videos are wearing helmets, suitable for safety prevention scenarios in the construction and manufacturing industries. It is implemented using the yolov5 model.                            |
| kws                   | Keyword Wake-Up               |Keyword wake-up detects whether the audio stream contains the keywords set during training through an audio recognition model. If the corresponding keyword is detected, a voice response is given. The model provided in this example is trained using WeNet. The positive and negative samples respectively use the "xiaonan" audio collected on the k230 development board and the open-source dataset speech_commands.                             |
| licence_det           | License Plate Detection                 | License plate detection can detect license plates appearing in images or videos. License plate detection uses the retinanet network structure.                          |
| licence_det_rec       | License Plate Recognition                 | License plate recognition can identify the position of license plates and license plate information appearing in images or videos. License plate detection uses the retinanet network structure, and license plate recognition uses the RLNet network structure with MobileNetV3 as the backbone.                            |
| nanotracker           | Single-Object Tracking               | In single-object tracking, the user places a feature-obvious object to be tracked in the registration box in the first few seconds to complete tracking registration, and then visually tracks the object in real-time. The tracking algorithm uses NanoTrack.                           |
| object_detect_yolov8n | YOLOV8 Multi-Object Detection         | The YOLOv8 multi-object detection example implements 80-category detection on the COCO dataset. The yolov8n model is used.                            |
| ocr                   | OCR Detection + Recognition             | The OCR recognition example can detect the text positions and corresponding text content in images or videos. The OCR recognition task uses the CRNN network structure, and the OCR detection task uses the DBnet network structure.                           |
| person_attr           | Person Attributes                 | Person attribute detection can identify the position coordinates of people in images or videos, gender, age, whether wearing glasses, and whether holding objects. Person detection is implemented using the YOLOv5 model, and person attributes are implemented using the PULC person model.                            |
| person_detect         | Person Detection                 |  Person detection can detect the position coordinate information of people in images or videos, and mark them with detection boxes. This example is implemented using the yolov5 model.                           |
| person_distance       | Pedestrian Distance Measurement                 |  Pedestrian distance measurement first detects pedestrians through pedestrian detection, and then estimates the target distance through the size of the detection box in the image. Pedestrian detection uses the yolov5n network structure. Using this application, the detection box for each pedestrian in images or videos and the estimated distance can be obtained. This technology can be applied in fields such as vehicle assisted driving systems and intelligent transportation. This application needs to adjust the calculation data according to the camera, and the existing example may not recognize accurately.                   |
| pose_detect           | Person Keypoint Detection           |  The output of the person keypoint detection model is a set of keypoints (17) representing the person object in images or videos, along with the confidence score for each point. Lines of different colors are used to connect the keypoints into the shape of a human body. This example is implemented using the yolov8n-pose model.                           |
| pphumanseg            | Portrait Segmentation                 | Portrait segmentation refers to identifying the outline range of the human body in images or videos, separating it from the background, and returning the segmented binary image, grayscale image, foreground portrait image, etc., to achieve the replacement and synthesis of background images. It can be applied in scenarios such as portrait matting, photo synthesis, portrait special effects, and background special effects, greatly improving the efficiency of image and video tools. This example is implemented using the pphumanseg model.                            |
| puzzle_game           | Jigsaw Puzzle Game                 | The jigsaw puzzle game can obtain the 21 skeletal keypoint positions of each palm in images or videos. It can also implement the jigsaw puzzle game function: spread the thumb and middle finger, place the midpoint of the two fingers on a non-empty space next to the empty space, fit the two fingers, and the current non-empty space will move into the empty space. In the example, palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                           |
| segment_yolov8n       | YOLOV8 Multi-Object Segmentation         | The YOLOv8 multi-object segmentation detection example implements 80-category segmentation masks on the COCO dataset. The yolov8n-seg model is used.                            |
| self_learning         | Self-Learning (Metric Learning Classification)    | Self-learning registers item features within the registration box, and then identifies the items within the box without retraining. After the program starts, input i to interrupt the run, input n to create a new feature, and input d to delete a feature. After feature registration is complete, it will continue to start identifying the similarity between the items in the detection box and the registered items, and complete classification. Press the esc key to exit the program. The feature extraction model uses the ppshitu_lite model.                           |
| smoke_detect          | Smoking Detection                 |  Smoking detection performs real-time monitoring and recognition of smoking behavior in images or videos. This example is implemented using the yolov5 model.                           |
| space_resize          | Gesture Air Zooming             | Gesture air zooming can obtain the 21 skeletal keypoint positions of each palm in images or videos, and we use the thumb and middle finger to achieve air zooming of images. Palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                            |
| sq_hand_det           | Palm Detection                 |  Palm detection can obtain the detection box of each palm in images or videos. Palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2.                           |
| sq_handkp_class       | Palm Keypoint Gesture Classification       |   Palm keypoint gesture classification can obtain the 21 skeletal keypoint positions of each palm in images or videos, and obtain static gestures based on the two-dimensional constraints of the keypoint positions. A total of 9 gestures are supported: fist, five fingers open, one gesture, yeah gesture, three gesture, eight gesture, six gesture, thumbs up, and thumb + index + little finger open. In this example, palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                          |
| sq_handkp_det         | Palm Keypoint Detection           | The palm keypoint detection example can obtain the 21 skeletal keypoint positions of each palm in images or videos. Palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                           |
| sq_handkp_flower      | Fingertip Area Flower Classification         | Fingertip area flower recognition can obtain the flower category within the area surrounded by the index fingertips of two palms in images or videos. It can support the recognition of 102 kinds of flowers. In this example, palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure. The flower classification backbone is selected as 1.0-mobilenetV2.                            |
| sq_handkp_ocr         | Finger Area OCR Recognition          | Finger area OCR recognition can obtain the text recognized within the area of the upper left of the index finger of each palm in images or videos. Palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure. Text detection uses the retinanet network structure, and text recognition uses the RLnet network structure with MobileNetV3 as the backbone.                            |
| sq_handreco           | Gesture Recognition                 | Gesture recognition can obtain the category of each gesture in images or videos. Only three gestures are supported: five fingers open, eight gesture, and yeah gesture. In this example, palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and gesture recognition backbone is selected as 1.0-mobilenetV2.                        |
| traffic_light_detect  | Traffic Light Detection           | It can detect red, green, and yellow traffic lights in images or videos. This example is implemented using the yolov5 model.                            |
| translate_en_ch       | English to Chinese Translation               | English to Chinese translation can implement simple English to Chinese translation tasks, with average results. The machine translation model uses the transformer structure.                       |
| tts_zh                | Chinese Text-to-Speech               | Chinese text to speech (tts_zh) is implemented using three models. By default, the user inputs text three times, and the corresponding wav files are generated. In this example, the FastSpeech2 model is split into two models: Encoder+Variance Adaptor as fastspeech1, and Decoder as fastspeech2. The vocoder uses hifigan. The duration features are added after fastspeech1.                       |
| vehicle_attr          | Vehicle Attribute Recognition             | Vehicle attribute recognition can identify each vehicle in images or videos, and return the vehicle's position coordinates, vehicle type, and body color. This example uses the yolov5 network structure for vehicle detection, and the PULC model for vehicle attribute detection.                         |
| virtual_keyboard      | Air Virtual Keyboard             | The air virtual keyboard can use the virtual keyboard on the screen to output characters. Pinching the thumb and index finger is the input action. In this example, palm detection uses the yolov5 network structure, with the backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                          |
| yolop_lane_seg        | Road Lane Segmentation           | Road lane segmentation can implement road surface segmentation in images or videos, that is, detecting lane lines and drivable areas, and distinguishing them with colors. This example is implemented using the yolop model.         |

## Build and Run the Program

### Switch Development Board and Build the Application

Go back to the `RTOS` root directory and check the supported development boards:

```shell
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
echo 'export PATH="${HOME}/.bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

#### Download Source Code and Build Firmware

```shell
cd ~
mkdir rtos_k230_sdk
cd rtos_k230_sdk

# Generate ssh key and add it to github or gitee
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
cat ~/.ssh/id_rsa.pub

# Using github
repo init -u https://github.com/canmv-k230/manifest -b master --repo-url=https://github.com/canmv-k230/git-repo.git

# Using gitee
repo init -u https://gitee.com/canmv-k230/manifest -b master --repo-url=https://gitee.com/canmv-k230/git-repo.git

repo sync
# Download toolchain
make dl_toolchain
# List available configuration options
make list-def
```

Switch the development board in use and build, switch to the development board you are using:

```shell
make ***_defconfig

make -j
```

After execution, the compiled image will be generated in the `output` directory.

- **Build Method One**

After the code modifications described in the above sections are completed, enter the `src/rtsmart/examples/ai/ai_demo` directory and execute:

```bash
# Build only face_detection
./build_app.sh face_detection

#Build all AIDemos
./build_app.sh
```

After the script execution is completed, the build intermediate artifacts are located in the `build` directory, and the deployment summary file is located in the `k230_bin` directory.

- **Build Method Two**

In the `RTOS SDK` root directory, execute `make menuconfig`, select `RT-Smart UserSpace Examples Configuration`->`Enable build ai examples`->`Enable Build AI Demo Programs`->`Select the demo to build`, save and exit. As shown below:

![rtos_ai_demo_menuconfig](https://www.kendryte.com/api/post/attachment?id=858)

Because a `Makefile` is also provided, directly execute

```bash
make -j
```

This way the deployment summary file will be directly compiled into the firmware's `/sdcard/app/examples/ai/ai_demo/<demo_name>` directory during the build process. You can also enter the `/sdcard/app/examples/ai/ai_demo` directory and execute:

```bash
make -j
```

This command can also compile the selected demo, and the build artifacts will be generated in the `k230_bin` directory. The build process implements incremental compilation.

### Development Board Deployment

Flash the firmware and power on. For firmware flashing, refer to the document: [how_to_flash](../../userguide/how_to_flash.md).

You can see a virtual disk `CanMV` at the drive letter. Copy the compiled elf files, kmodel files, and other used files (such as test images) of the corresponding demo under `k230_bin` to the `CanMV/sdcard` directory.

Then use a serial port tool to connect to the development board, and execute the `***_isp.sh` or `***_image.sh` script corresponding to the Demo in the command line. For example:

```shell
#Enter the development board big-core sharefs directory
cd /sdcard/face_detection
#Execute the corresponding script to run face detection
#For detailed face detection instructions, refer to the source code and scripts in the src/rtsmart/examples/ai/face_detection directory
./face_detect_isp.sh
```
