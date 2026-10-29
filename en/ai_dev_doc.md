# AI Development Documentation

## Basic Principles of KPU Hardware

In edge computing scenarios (such as IoT devices, smart cameras, industrial inspection terminals, wearable devices, etc.), devices are typically deployed at sites far from cloud data centers, facing challenges of **high real-time requirements, limited network bandwidth, sensitive data privacy, and strict power consumption constraints**. Running complex AI models (such as image recognition, object detection, voice wake-up) in these scenarios often encounters problems of **excessive computation, slow processing speed, and high power consumption** if relying solely on traditional general-purpose CPUs, making it difficult to meet the requirements of real-time response and energy efficiency ratio.

**KPU (Knowledge Processing Unit)** is a hardware acceleration engine specifically designed by Canaan Technology to address edge AI computing challenges. It is essentially a highly optimized **deep learning coprocessor/accelerator**, whose core function is to **efficiently execute dense computational tasks in neural network models** (particularly operations such as convolution, matrix multiplication, and activation functions).

**Core Advantages of KPU**: Specialization and Efficiency. Compared with general-purpose CPUs, the advantages of KPU lie in its **specialized architecture**:

- **Parallel Computing Capability:** KPU internally contains a large number of processing units (PE) specifically designed for neural network computation, capable of simultaneously processing massive data (such as feature maps, weights), significantly accelerating the model inference process.
- **Optimized Data Flow and Memory Access:** Deep optimization is performed for neural network computation patterns (such as data reuse), reducing unnecessary data movement, maximizing memory bandwidth utilization, and reducing latency.
- **High Energy Efficiency Ratio:** Specialized circuit design avoids the overhead of CPU executing general-purpose instructions. When performing the same AI computation tasks, KPU typically provides **tens to hundreds of times the computational efficiency of CPU (TOPS/W)**, achieving high-performance AI processing within the limited power budget of edge devices.
- **Reduced CPU Load:** Offloading heavy AI computation tasks to KPU for execution frees up valuable CPU resources to handle other critical tasks such as device control, communication, and user interaction, improving overall system responsiveness and stability.

KPU supports various mainstream neural network model structures, suitable for a wide range of edge vision AI application scenarios, including but not limited to:

- **Image Classification:** Identify object categories in images (such as identifying fruit types, industrial parts).
- **Object Detection:** Locate and identify multiple objects and their positions in images (such as detecting pedestrians, vehicles, defects).
- **Semantic Segmentation:** Classify each pixel in an image (such as distinguishing roads, sky, buildings; medical image analysis).
- **Face Detection and Recognition:** On-device face verification, access control attendance.
- **Pose Estimation:** Analyze human joint positions (such as fitness action guidance).

**Positioning of KPU in the System:**

It usually exists as an independent IP core in SoC (System on Chip), working collaboratively with CPU, memory, peripherals, etc. The CPU is responsible for system management, task scheduling, and application logic, while efficiently handing over computation-intensive AI model inference tasks to KPU for execution. The figure below shows the position of KPU in a typical edge AI SoC.

![kpu_in_system](https://www.kendryte.com/api/post/attachment?id=610)

## K230 AI Application Examples Showcase

### Application Examples Introduction

The application examples of the RT-Smart SDK are located in the `src/rtsmart/examples/ai` directory. Here we will introduce each type of example one by one to facilitate quick start.

| Application Directory           | Description                                                                                           | Applicable Scenario                                 |
| :------------------------ | :------------------------------------------------------------------------------------------- | :----------------------------------- |
| **usage_ai2d**            | Demonstrates the **5 preprocessing methods** supported by AI2D hardware: read image → create Tensor → AI2D preprocessing → save result.                               | Learn **how to use AI2D for preprocessing**                   |
| **usage_kpu**             | Taking YOLOv8 as an example, demonstrates the full-process code from input settings, preprocessing, inference, to output post-processing. Supports image and video inference, developed based on low-level API, without scenario encapsulation.                         | An essential example for learning the **KPU inference full process**               |
| **face_detection**        | Face detection example, providing complete reference code for **single-model tasks**.                                                                 | Suitable for developing your own **single-model AI applications**                |
| **face_recognition**      | Face recognition example, demonstrating the implementation of **dual-model tasks**, can be directly used in practical scenarios.                                                         | A good reference for **multi-model AI applications**                |
| **triple_camera_ai**      | Triple-camera + AI inference application example, with camera, display, format conversion and other modules encapsulated, allowing you to focus directly on development logic.                                                 | Reference for developing **triple-camera + AI inference applications**              |
| **uvc_face_detection**    | Face detection example based on UVC camera, with camera, display, format conversion and other modules encapsulated, allowing you to focus directly on inference logic.                                              | Reference for developing **UVC camera AI applications**             |
| **yolo**                  | Packaged YOLO deployment tool, supports **YOLOv5 / YOLOv8 / YOLO11**, covers four types of tasks: classification, detection, segmentation, and rotation detection, supports image/video deployment modes, one compilation for multiple running methods. | **Quickly test YOLO series models**                   |
| **ai_demo**               | Includes **50+ AI application examples**, comprehensively demonstrating the powerful performance and diverse scenario support of the K230 chip. The examples uniformly encapsulate camera, display, multimedia, etc., allowing you to focus on model inference.               | Key attention for those who want to experience various AI applications at once                 |
| **multi_object_tracking** | Multi-object tracking example, with camera, display, format conversion and other modules encapsulated, provides multiple tracking algorithms.                                                          | Enriches the reference for **multi-object tracking applications**                   |
| **cloudplat_deploy_code** | Deployment code for online training platform and AICube. Users need to use the `deploy_config.json` and kmodel obtained from the platform after compilation.                   | Facilitates users to deploy and use the kmodel trained by the online cloud training platform and AICube |

### AI Demo Introduction

To help developers quickly get started and intuitively experience the powerful edge AI capabilities of K230, the CanMV K230 image comes with a rich variety of AI example programs (AI Demo).

These out-of-the-box Demos cover two major categories: single-model applications (such as face detection) and multi-model applications (such as hand keypoints). Users can experience mainstream AI functions through zero-configuration, one-click running without building an environment from scratch, including but not limited to:

- Visual Applications: object recognition, face detection, gesture recognition, human recognition, license plate recognition, OCR text recognition.
- Audio Applications: keyword recognition (KWS), Chinese speech synthesis (TTS), etc.

Through these Demos, developers can quickly verify model performance, become familiar with the AI inference capabilities of K230, and lay a solid foundation for subsequent customized development.

**Running Method:**

All Demo source code is open, structurally clear, and uniformly stored in the `src/rtsmart/examples/ai/ai_demo` directory. Users can build their own compilation environment, and complete the compilation, running, debugging, and in-depth research of aidemo, understanding the API calls, data processing flow, and model integration methods, greatly accelerating their own application development process. For details, please refer to the documentation: [AI Demo Application Guide](./app_develop_guide/ai/aidemo.md).

**Notes:**

- Some Demos may not run properly on the K230D chip due to high memory usage.

- For the differences between K230 and K230D, please refer to: **[Product Center](https://www.kendryte.com/zh/products)**

| Demo Subdirectory           | Scenario                     |      Description                  |Link|
| :-------------------- | ------------------------ |--------------------------- |---|
| anomaly_det           | Anomaly Detection                 | The model provided in the anomaly detection example is trained using the patchcore anomaly detection method, which can identify whether there is an anomaly at the glass bottle mouth from the input image. Anomaly detection is usually applied in industrial image inspection, medical image analysis, security monitoring and other fields.                            |[anomaly_det](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/anomaly_det)|
| bytetrack             | Multi-Object Tracking               | The ByteTrack multi-object tracking example uses YOLOv5 as the object detection algorithm, applies the Kalman filter algorithm for bounding box prediction, and applies the Hungarian algorithm for matching between targets and trajectories.  |[bytetrack](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/bytetrack)|
| crosswalk_detect      | Crosswalk Detection              | Crosswalk detection uses the YOLOV5 network. This application detects crosswalks in images or videos, and can be used in scenarios such as assisted driving.                        |[crosswalk_detect](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/crosswalk_detect)|
| distraction_reminder  | Non-Forward-Gaze Detection                  | The non-forward-gaze detection example mainly uses face pose estimation as the basis, and realizes reminders for drivers not paying attention to the front through logical judgment. Face detection uses the retina-face model, and face orientation estimation fits 98 2D keypoints.                        | [distraction_reminder](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/distraction_reminder)|
| dms_system            | Driver Monitoring System             | The dms example is based on palm detection and face detection, and realizes reminders for violations (smoking, phone calls, drinking) by drivers of moving vehicles through logical judgment. Face detection uses the retina-face network structure, with backbone selected as 0.25-mobilenet. Palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2. | [dms_system](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/dms_system)|
| dynamic_gesture       | Visual Dynamic Gesture Recognition            | Visual dynamic gesture recognition can recognize five actions: waving up, down, left, right, and five-finger pinch, used in air operation control scenarios. Palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, palm keypoint detection uses the resnet50 network structure, and dynamic gesture recognition uses the tsm structure, with backbone selected as mobilenetV2.                            | [dynamic_gesture](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/dynamic_gesture)|
| eye_gaze              | Gaze Estimation                 |   The gaze estimation example predicts where a person is looking based on the face. For video frames or images, face detection is performed first, then gaze estimation is performed on each face, the gaze vector is predicted, and displayed on the screen in the form of arrows. This application uses the retina-face network for face detection, and uses L2CS-Net for gaze estimation. Gaze estimation can be applied in the field of automotive safety.                          | [eye_gaze](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/eye_gaze)|
| face_alignment        | Face Alignment                 | The face alignment example can obtain the depth map or normalized projection coordinate encoding map of each face in an image or video. Face detection uses the retina-face network structure, with backbone selected as 0.25-mobilenet. The face alignment network is implemented based on 3DDFA (3D Dense Face Alignment).            | [face_alignment](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_alignment)|
| face_detection        | Face Detection                 |  The face detection example can obtain the face detection box of each face in an image or video, as well as the positions of the five keypoints of each face: left eye/right eye/nose tip/left mouth corner/right mouth corner. Face detection uses the retina-face network structure, with backbone selected as 0.25-mobilenet.                           | [face_detection](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_detection)|
| face_emotion          | Facial Expression Recognition              | Facial expression recognition uses two models to realize the function of recognizing the expression of each person in an image/video. Recognizable expression categories include Neutral, Happiness, Sadness, Anger, Disgust, Fear, and Surprise. Face detection uses the retina-face network structure; expression classification uses mobilenet as the backbone for classification to obtain the person's expression.                            | [face_emotion](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_emotion)|
| face_gender           | Gender Classification                 | The face gender classification example uses two models to realize the function of determining the gender of each person in an image/video. The gender of each person is represented by M or F, where M stands for Male and F stands for Female. Face detection uses the retina-face network structure; gender classification uses EfficientNetB3 as the backbone for classification to obtain the person's gender.                           | [face_gender](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_gender)|
| face_glasses          | Glasses Wearing Classification         | The glasses wearing classification example uses two models to realize the function of determining whether each person in an image/video is wearing glasses. The face detection model uses the retina-face network structure; the face glasses classification model uses SqueezeNet-1.1 as the backbone to determine the glasses wearing situation for each face box.                           | [face_glasses](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_glasses)|
| face_landmark         | Dense Face Keypoints            | The dense face keypoint detection application uses two models to detect 106 keypoints for each face in an image/video, and draws the contours of the face and facial features based on the 106 keypoints, with different contours represented in different colors. Face detection uses the retina-face network structure; dense keypoint detection uses 0.5-mobilenet as the backbone to detect 106 keypoints for each face, including the face's cheeks, mouth, eyes, nose, and eyebrow areas.                            | [face_landmark](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_landmark)|
| face_mask             | Mask Wearing Classification          | The mask wearing classification application uses two models to realize the function of determining whether each person in an image/video is wearing a mask. In application scenarios where masks need to be worn, if someone is found not wearing a mask, relevant reminders can be made. The face detection model uses the retina-face network structure; the face mask classification model uses mobilenet-v2 as the backbone to determine the mask wearing situation for each face box.                            | [face_mask](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_mask)|
| face_mesh             | 3D Face Mesh              |  The 3D face mesh can obtain the 3D mesh structure of each face in an image or video. Face detection uses the retina-face network structure, with backbone selected as 0.25-mobilenet. The face alignment network is implemented based on 3DDFA (3D Dense Face Alignment).| [face_mesh](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_mesh)|
| face_parse            | Face Segmentation                  | The face segmentation example uses two models to realize the segmentation function for each face in an image/video. Face segmentation includes distinguishing the eyes, nose, mouth, and other parts of the face at the pixel level, with different regions represented in different colors. Face detection uses the retina-face network structure, and face part segmentation uses the DeepNetV3 network structure, with mobilenet-1.0 as the backbone.                           | [face_parse](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_parse)|
| face_pose             | Face Pose Estimation             | Face pose estimation uses two models to realize the function of estimating the face orientation angle of each person in an image/video. Face orientation is generally expressed by Euler angles (roll/yaw/pitch), where roll represents the degree of head shaking left and right; yaw represents the degree of head rotation left and right; pitch represents the degree of head bowing and raising. Face detection uses the retina-face model, and face orientation estimation fits 98 2D keypoints.                            | [face_pose](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_pose)|
| face_verification     | Face Identity Verification             | Face identity verification is an identity verification technology based on face biometrics, aimed at confirming whether an individual is the identity they claim to be. This technology verifies identity by analyzing and comparing the user's facial features, usually by comparing two images in a face verification system to determine whether the faces in the two images belong to the same person. Face detection uses the retina-face model, and face feature extraction uses ResNet50, outputting 512-dimensional features.                           | [face_verification](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/face_verification)|
| falldown_detect       | Fall Detection                 |  Fall detection can detect the fall status of a person in an image or video. This example uses the yolov5n model.                           | [falldown_detect](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/falldown_detect)|
| finger_guessing       | Finger Guessing Game                 |  The finger guessing game example distinguishes rock-paper-scissors through hand gesture recognition, including two models: palm detection and hand 21-keypoint recognition. The gesture category is determined by the position constraints of 21 keypoints. The palm detection part uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and the palm keypoint detection part uses the resnet50 network structure.                          | [finger_guessing](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/finger_guessing)|
| fitness               | Squat Action Counting             |  The squat action counting example implements the function of counting squat actions of a person in a video, suitable for scenarios such as fitness state detection. Implemented using the yolov8n-pose model.                           | [fitness](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/fitness)|
| head_detection        | Head Detection and Counting             |  The head detection and counting example implements the function of obtaining the coordinates and number of heads appearing in an image or video. Implemented using the yolov8 model.                           | [head_detection](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/head_detection)|
| helmet_detect         | Helmet Detection               | The helmet detection example implements the detection of whether a person appearing in an image or video is wearing a helmet, suitable for safety prevention scenarios in the construction and manufacturing industry. Implemented using the yolov5 model.                            | [helmet_detect](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/helmet_detect)|
| kws                   | Keyword Wake-Up               | Keyword wake-up detects whether the audio stream contains the keyword set during training through the audio recognition model, and gives a voice response if the corresponding keyword is detected. The model provided in this example is trained by WeNet. The positive and negative samples are respectively the "xiaonan" audio collected on the k230 development board and the open-source dataset speech_commands.                             | [kws](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/kws)|
| licence_det           | License Plate Detection                 | License plate detection can detect license plates appearing in images or videos. License plate detection uses the retinanet network structure.                          | [licence_det](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/licence_det)|
| licence_det_rec       | License Plate Recognition                 | License plate recognition can identify the position of the license plate and the license plate information appearing in an image or video. License plate detection uses the retinanet network structure, and license plate recognition uses the RLNet network structure with MobileNetV3 as the backbone.                            | [licence_det_rec](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/licence_det_rec)|
| nanotracker           | Single Object Tracking               | Single object tracking is implemented by placing an object with distinct features in the registration box in the first few seconds to achieve tracking registration, and then visually tracking the object in real time. The tracking algorithm uses NanoTrack.                           | [nanotracker](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/nanotracker)|
| object_detect_yolov8n | YOLOV8 Multi-Object Detection         | The YOLOv8 multi-object detection example implements 80-class detection of the COCO dataset. Uses the yolov8n model.                            | [object_detect_yolov8n](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/object_detect_yolov8n)|
| ocr                   | OCR Detection+Recognition             | The OCR recognition example can detect the text position and corresponding text content in an image or video. The OCR recognition task uses the CRNN network structure, and the OCR detection task uses the DBnet network structure.                           | [ocr](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/ocr)|
| person_attr           | Person Attributes                 | Person attribute detection can identify the position coordinates of a person in an image or video, gender, age, whether wearing glasses, and whether holding objects. Person detection is implemented using the YOLOv5 model, and person attributes are implemented using the PULC person model.                            | [person_attr](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/person_attr)|
| person_detect         | Person Detection                 |  Person detection can detect the position coordinate information of a person in an image or video, and mark it with a detection box. This example is implemented using the yolov5 model.                           | [person_detect](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/person_detect)|
| person_distance       | Pedestrian Distance Measurement                 |  Pedestrian distance measurement first detects pedestrians through pedestrian detection, and then estimates the target distance through the size of the detection box in the image. Among them, pedestrian detection uses the yolov5n network structure. Using this application, the detection box and estimated distance of each pedestrian in an image or video can be obtained. This technology can be applied in vehicle assisted driving systems, intelligent transportation, and other fields. This application needs to adjust the calculation data according to the camera, and the existing example may not recognize accurately.                   | [person_distance](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/person_distance)|
| pose_detect           | Person Keypoint Detection           |  The output of the person keypoint detection model is a set of keypoints (17) representing the human body object in the image or video, and the confidence score of each point, and uses lines of different colors to connect the keypoints into the shape of the human body. This example is implemented using the yolov8n-pose model.                           | [pose_detect](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/pose_detect)|
| pphumanseg            | Portrait Segmentation                 | Portrait segmentation refers to identifying the human body contour range in an image or video, separating it from the background, and returning the segmented binary map, grayscale map, foreground portrait map, etc., to achieve replacement and synthesis of background images. It can be applied in scenarios such as portrait matting, photo synthesis, portrait special effects, and background special effects, greatly improving the efficiency of image and video tools. This example is implemented using the pphumanseg model.                            | [pphumanseg](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/pphumanseg)|
| puzzle_game           | Puzzle Game                 | The puzzle game can obtain the positions of 21 skeletal keypoints of each palm in an image or video. It can also realize the function of a puzzle game: spread the thumb and middle finger, place the midpoint next to a non-empty space, and fit the two fingers. The current non-empty space will move into the empty space. In the example, palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                           | [puzzle_game](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/puzzle_game)|
| segment_yolov8n       | YOLOV8 Multi-Object Segmentation         | The YOLOv8 multi-object segmentation detection example implements 80-class segmentation masks of the COCO dataset. Uses the yolov8n-seg model.                            | [segment_yolov8n](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/segment_yolov8n)|
| self_learning         | Self-Learning (Metric Learning Classification)    | Self-learning registers the features of an object within the registration box, and then recognizes the object within the box without retraining. After the program starts, input i to interrupt the running, input n to create a new feature, input d to delete the feature. After the feature registration is completed, it will continue to start recognizing the similarity between the object in the detection box and the registered object, and complete the classification. Press the esc key to exit the program. The feature extraction model uses the ppshitu_lite model.                           | [self_learning](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/self_learning)|
| smoke_detect          | Smoking Detection                 |  Smoking detection performs real-time monitoring and recognition of smoking behaviors in images or videos. This example is implemented using the yolov5 model.                           | [smoke_detect](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/smoke_detect)|
| space_resize          | Gesture Air Zoom             | The gesture air zoom can obtain the positions of 21 skeletal keypoints of each palm in an image or video, and we use the thumb and middle finger to achieve air zoom of the image. Palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                            | [space_resize](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/space_resize)|
| sq_hand_det           | Palm Detection                 |  Palm detection can obtain the detection box of each palm in an image or video. Palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2.                           | [sq_hand_det](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/sq_hand_det)|
| sq_handkp_class       | Palm Keypoint Gesture Classification       |   The palm keypoint gesture classification can obtain the positions of 21 skeletal keypoints of each palm in an image or video, and obtain static gestures based on the 2D constraints of the keypoint positions. It supports a total of 9 gestures: fist, five-finger open, one gesture, yeah gesture, three gesture, eight gesture, six gesture, thumbs up, and thumb+index+pinky open. In this example, palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                          | [sq_handkp_class](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/sq_handkp_class)|
| sq_handkp_det         | Palm Keypoint Detection           | The palm keypoint detection example can obtain the positions of 21 skeletal keypoints of each palm in an image or video. Palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                           | [sq_handkp_det](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/sq_handkp_det)|
| sq_handkp_flower      | Fingertip Area Flower Classification         | The fingertip area flower recognition can obtain the flower category within the index fingertip surrounding area of two palms in an image or video. It can support recognition of 102 kinds of flowers. In this example, palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure. The flower classification backbone is selected as 1.0-mobilenetV2.                            | [sq_handkp_flower](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/sq_handkp_flower)|
| sq_handkp_ocr         | Finger Area OCR Recognition          | The finger area OCR recognition can recognize text within the upper-left area of the index finger of each palm in an image or video. Palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure. Text detection uses the retinanet network structure, and text recognition uses the RLnet network structure with MobileNetV3 as the backbone.                            | [sq_handkp_ocr](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/sq_handkp_ocr)|
| sq_handreco           | Hand Gesture Recognition                 | Hand gesture recognition can obtain the category of each gesture in an image or video. Only three gestures are supported: five-finger open, eight gesture, and yeah gesture. In this example, palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and the gesture recognition backbone is selected as 1.0-mobilenetV2.                        | [sq_handreco](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/sq_handreco)|
| traffic_light_detect  | Traffic Light Detection           | Can detect red, green, and yellow traffic lights in images or videos. This example is implemented using the yolov5 model.                            | [traffic_light_detect](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/traffic_light_detect)|
| translate_en_ch       | English-to-Chinese Translation               | English-to-Chinese translation can implement simple English-to-Chinese translation tasks, with general effect. The machine translation model applies the transformer structure.                       | [translate_en_ch](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/translate_en_ch)|
| tts_zh                | Chinese Text-to-Speech               | Chinese text to speech (tts_zh) uses three models. The user inputs three texts by default, and generates wav files corresponding to the texts. This example splits the FastSpeech2 model into two models: Encoder+Variance Adaptor is fastspeech1, Decoder is fastspeech2, and the vocoder selects hifigan. The duration feature is added after fastspeech1.                       | [tts_zh](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/tts_zh)|
| vehicle_attr          | Vehicle Attribute Recognition             | Vehicle attribute recognition can identify each vehicle in an image or video, and return the position coordinates, model, and body color of the vehicle. This example uses the yolov5 network structure to implement vehicle detection, and the vehicle attribute detection uses the PULC model.                         | [vehicle_attr](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/vehicle_attr)|
| virtual_keyboard      | Air Virtual Keyboard             | The air virtual keyboard can use the virtual keyboard on the screen to output characters. The pinch of the thumb and index finger is the input action. In this example, palm detection uses the yolov5 network structure, with backbone selected as 1.0-mobilenetV2, and palm keypoint detection uses the resnet50 network structure.                          | [virtual_keyboard](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/virtual_keyboard)|
| yolop_lane_seg        | Road Lane Line Segmentation           | Road lane line segmentation can implement road surface segmentation in images or videos, that is, detect lane lines and drivable areas, and distinguish them with colors. This example uses the yolop model.         | [yolop_lane_seg](https://github.com/canmv-k230/k230_rtsmart_examples/tree/canmv_k230/ai/ai_demo/yolop_lane_seg)|

## Basic Process of AI Model Inference

The basic process of deploying a trained AI model on the K230 is shown in the flow diagram below:

![pipeline_model_deploy](https://www.kendryte.com/api/post/attachment?id=611)

🏷️ **Data Collection**:

Data collection refers to the process of gathering raw input data through sensing devices such as cameras and microphones. The quality and quantity of the collected data directly determine the effectiveness of model training and inference. Therefore, choosing appropriate collection equipment and strategies is crucial.

To achieve better deployment results, it is recommended to use the K230 itself to collect image data, ensuring that the data distribution is closer to the actual deployment environment.

🏷️ **Data Annotation**:

Data annotation is the process of adding semantic labels to the collected data, used for training supervised learning models. This process can be done manually or semi-automatically with the help of annotation tools.

For example, an image classification task requires assigning the correct category label to each image; an object detection task requires adding bounding boxes and their category labels to each object in the image. Accurate annotation is essential for training high-performance models with strong generalization capabilities.

🏷️ **Model Training**:

The model training phase is one of the important steps in the entire AI application development process. Its main goal is to use the annotated dataset to train a neural network model with generalization capabilities through deep learning methods. During this process, the model continuously adjusts its internal parameters to gradually fit the distribution characteristics of the data, so that it can make accurate and stable predictions when faced with unseen input data.

Model training usually relies on a large amount of high-quality sample data, covering task-related diverse scenes and categories. The sufficiency of data and the accuracy of annotation directly affect the model's learning effect and application performance. During training, the neural network model extracts features from the input data, calculates predicted outputs, generates a loss by comparing with the true labels, and then uses the backpropagation mechanism to adjust the weight parameters in the network, continuously optimizing the model's performance.

To achieve efficient training, developers need to choose a model structure suitable for the current task, such as MobileNet or ResNet for image classification, and the YOLO series for object detection. The choice of model depends not only on accuracy requirements but also on inference speed, model size, and resource constraints of the deployment platform. Especially for edge AI chips like the K230, lightweight models are of greater practical value.

In addition, the training process often needs to be carried out on a computing platform with certain computing power support (such as a GPU server or a local high-performance workstation) to ensure that the model completes optimization within a reasonable time. Modern deep learning training usually uses mature training frameworks such as **PyTorch** and **TensorFlow**, which provide rich neural network building modules, optimizers, loss functions, and data processing tools, greatly simplifying the model development process. You can choose the appropriate framework for training work based on your technical background and model requirements.

🏷️ **Model Conversion and Validation**:

Due to the limited computing resources of edge devices, models trained on high-computing platforms cannot be directly deployed. The model must be optimized and quantized through model conversion tools to generate an inference format suitable for the target hardware.

For the K230 chip:

- Use KPU (Knowledge Processing Unit) as the neural network acceleration unit;
- The supported model format is KModel;
- Use the nncase compiler to convert the trained ONNX or TFLite model into KModel;
- Structural optimization and quantization will be performed during the conversion process to reduce model size and computational complexity.

After the conversion is complete, functional verification is also required to ensure that the model meets application requirements in terms of accuracy, latency, and resource usage.

🏷️ **Model Deployment**:

The verified KModel can be loaded onto the device through the API provided by the K230 RT-Smart SDK for running.

The deployment process usually includes the following steps:

- Load the kmodel;
- Read input data such as images/audio;
- Perform data preprocessing (such as scaling, normalization, channel arrangement, etc.);
- Run model inference;
- Perform result post-processing (such as classification decoding, bounding box filtering, etc.);
- Draw/output inference results.

Different models may have different preprocessing and post-processing flows, and the corresponding code logic needs to be manually adapted according to the specific model.

🏷️ **Model Tuning**:

After deployment, the model still needs to be tuned in terms of performance and effectiveness to adapt to the actual needs of edge scenarios. Optimization measures include but are not limited to:

- Set more reasonable inference thresholds or output strategies;
- Adjust model conversion parameters (such as quantization strategy, input resolution);
- Improve model structure or training hyperparameters;
- Enrich and optimize the dataset;
- Optimize the inference process (such as thread scheduling, memory reuse).

Model tuning is a continuous iterative process that helps improve the system's stability, real-time performance, and energy efficiency ratio.

The above six steps constitute the complete process of AI model deployment and inference on the K230 chip. Each step needs to be carefully designed and executed to ensure that the final application has good performance, stability, and user experience.

## Training the Model

```{note}
🤖 **【Scenario Definition】**: Implement "recognition and localization of printed numbers" on the K230 development board.

📌 **Task Background**:
In many AI applications, we often encounter the need to "recognize certain things in images," such as recognizing faces, objects in images, or, as in this example, recognizing numbers. To better understand the basic process of object detection, we designed a simple small task————**recognize the four types of numbers "0", "1", "2", and "3" printed on paper, and mark their positions in the image**.

This task is not complicated, but it can completely practice the entire process from model deployment to image processing and result display. As an introductory tutorial, it helps everyone quickly master how to deploy AI models on the K230 platform, perform object detection, and display the detection results on the screen.

🎯 **Project Goal**:
Based on the Kendryte K230 AI SoC platform, develop a lightweight, high-performance visual recognition example that implements the following functions:

* ✅ **Recognition Categories**: Only recognize the four types of digit characters "0", "1", "2", "3";
* ✅ **Recognition Target**: Standard font numbers printed on paper;
* ✅ **Localization Function**: Not only recognize the digit category, but also **accurately obtain the position coordinates of each digit in the image** (draw a detection box), providing a basis for subsequent processing or operations;
* ✅ **Running Platform**: The application is deployed on the K230 development board, utilizing its **AI hardware acceleration, camera input, and screen display capabilities** to achieve on-device inference and real-time display.

🖼 **Expected Effect Diagram**:

![4_number_det](https://www.kendryte.com/api/post/attachment?id=645)
```

### Data Collection

```{note}
👉 Collecting training data is actually very simple! You just need to flash the MicroPython firmware into the development board first, then find that script—/sdcard/examples/16-AI-Cube/DataCollectionCamera.py, rename it to main.py, and put it in the /sdcard directory. Then power on again (that is, restart the board). After running, press the key button on the board to start collecting! Each press takes a photo, and the image is automatically saved to the /sdcard/examples/data/ folder, completely without your intervention—super worry-free!
```

Before training the model, data collection is the first step in the entire process and a crucial one. High-quality data not only improves the model's performance but also enhances the model's generalization ability in real application scenarios. According to different application requirements, data collection can be divided into **general scenarios** and **dedicated scenarios**. Detailed explanations will be given below.

📌 **Data Collection in General Scenarios**

In general artificial intelligence tasks, such as image classification, object detection, and semantic segmentation, existing public datasets can usually be used to build training samples. These datasets are organized and released by academic institutions, research organizations, or large enterprises, and have good annotation quality and a wide range of application foundations.

For example, common public image datasets include: ImageNet, COCO, MNIST, Fashion-MNIST, the CIFAR series, etc., or you can look for open-source datasets corresponding to scenarios on the network.

Although public datasets are of high quality, appropriate screening and processing are still required before actual use to ensure they meet project requirements:

- **Quality Assurance Processing**: Remove blurred, mislabeled, or low-quality samples.
- **Class Balance**: Ensure that the number of samples in each category is balanced to avoid model bias.
- **Format Unification**: Convert data to a unified format (such as JPEG, PNG, etc.).
- **Data Augmentation**: Expand the amount of data through rotation, cropping, flipping, adding noise, etc., to improve model robustness.
- **Building Custom Datasets**: Sometimes a single dataset may not meet specific needs. You can combine multiple datasets and re-annotate and clean them to build a custom dataset that better fits the business scenario.

📌 **Data Collection in Dedicated Scenarios**

For some special industries or specific application scenarios (such as industrial quality inspection, agricultural monitoring, security surveillance, medical diagnosis, etc.), it is often necessary to collect data dedicated to that scenario. In this case, public datasets may not accurately reflect the data distribution of the real environment, so **customized data collection** is required.

In some specific AI deployment scenarios, if conditions permit, you can directly **use the K230 device** for data collection. This way, **the collected data is closer to the actual deployment environment, which helps improve the model's performance on the device**.

⚠️ Here are some suggestions for the data collection process:

- **Clarify Collection Goals**: Define the collection target (such as object type, scene), lighting conditions, angle, resolution, etc.
- **Clarify Data Tasks**: Different tasks have different requirements for the dataset. On one hand, the actual deployment scenario must be considered; on the other hand, the task requirements must be considered. For example, classification tasks may require objects to occupy a large area, and large areas of background may affect the classification effect; while object detection can have multiple objects of different sizes.
- **Use Appropriate Tools**: Use the K230 development board with a camera module to write scripts for automatic collection.
- **Synchronous Annotation Information**: Try to synchronously record label information during the collection process to facilitate later annotation.
- **Preliminary Quality Check**: Eliminate invalid samples such as blur, overexposure, and severe occlusion.
  
### Data Annotation

```{note}
👉 After getting the collected images, you can start labeling them! According to the requirements of this task, you can use some common annotation tools, such as LabelImg, Labelme, or X-AnyLabeling, to add the corresponding categories to the numbers in the images and draw the target boxes. You can collect images yourself and annotate them by hand; the whole process is quite interesting. Of course, if you don't want to start from scratch, we have thoughtfully prepared a ready-made "0/1/2/3 four-class printed number recognition" dataset. Just click here to download: [0/1/2/3 four-class printed number recognition dataset](https://download.kendryte.com/developer/k230/yolo_dataset/number_det.zip). Saves time and effort, and you can directly start training!
```

Data annotation is one of the key steps in training a model. It involves annotating the raw data so that the model can learn the features and patterns of the data. When performing data annotation, the following aspects need to be considered:

- **Annotation Format**: Choose an annotation format suitable for the model, such as XML, JSON, TXT, etc.
- **Annotation Tools**: Choose suitable annotation tools, such as LabelImg, Labelme, X-AnyLabeling, VIA, etc.
- **Annotation Quality**: Ensure the accuracy and consistency of annotations to avoid annotation errors.
- **Annotation Strategy**: According to task requirements and data characteristics, choose a suitable annotation strategy, such as bounding box annotation, key point annotation, etc.

For common vision tasks, it is recommended to use X-AnyLabeling for annotation. Download link: [X-AnyLabeling-release](https://github.com/CVHub520/X-AnyLabeling/releases).
  
### Model Training

```{note}
👉 There are many methods for model training, among which the YOLO series is a particularly commonly used choice, such as YOLOv5, YOLOv8, or YOLO11. We recommend you use YOLO for training because it has good results, fast speed, and an active community. What's even better is that the dataset we provide has been organized and can be directly used to train the YOLO model! You just need to jump to this example: [YOLO Detection Example](#yolov8-fall-detection), follow the process inside, and replace the dataset part in the example with our prepared "0/1/2/3 four-class printed number recognition dataset". The goal of this section is to first train the model well and export it in ONNX format. There are more interesting contents waiting for you to unlock later!
```

Model training is the most important step in the entire AI process. It involves the construction, training, and optimization of the model. When training the model, the following aspects need to be considered:

- **Model Selection**: According to task requirements and data characteristics, choose a suitable model.
- **Model Construction**: Build the network structure of the model, including the input layer, hidden layer, and output layer.
- **Model Training**: Use the annotated data for model training, including selecting an appropriate loss function and optimizer.
- **Model Evaluation**: Use the test set to evaluate the model, evaluating the model's performance and generalization ability.
- **Model Optimization**: According to the model evaluation results, optimize the model to improve its performance and generalization ability.

The trained model needs to be converted into an onnx model or tflite model, preparing for subsequent use of nncase for model conversion to obtain a kmodel that can be inferred on the K230.

## Model Conversion

After training, we obtain an ONNX model file. However, this model cannot be run directly on K230 using the KPU, because the KPU only supports the Kmodel format.

So next, we need to use a compiler called `nncase` to "translate" the ONNX model into Kmodel, so that the KPU can understand and run it.

Let's briefly get to know this key tool — nncase!

### What is nncase

#### Introduction to nncase

`nncase` is a **neural network compiler** designed specifically for AI accelerators. The currently supported backends (targets) include: **CPU, K210, K510, K230**, and other platforms.

**Core features provided by nncase**:

- Supports **multi-input and multi-output** network structures, compatible with common **multi-branch model topologies**;
- Adopts a **static memory allocation** strategy, requiring no runtime heap memory dependency, with controllable resource usage;
- Implements **operator fusion and graph optimization**, effectively reducing redundant computation and improving inference efficiency;
- Supports **floating-point (float) inference** and **fixed-point quantized inference (uint8/int8)**;
- Supports **Post-Training Quantization (PTQ)**, which can generate efficient quantized models based on floating-point models and calibration datasets;
- The compiled model is a **Flat Model** structure, featuring **Zero-Copy Loading** capability, suitable for resource-constrained embedded scenarios.

**Supported model formats**:

nncase supports the following model formats exported from mainstream deep learning frameworks:

- **TFLite (TensorFlow Lite)**
- **ONNX (Open Neural Network Exchange)**

You can use training frameworks such as PyTorch and TensorFlow to export models to the above formats, and then use nncase to convert them into KModel for deployment on devices such as K230.

**Architecture overview**:

![nncase Architecture](https://www.kendryte.com/api/post/attachment?id=509)

The nncase software stack mainly consists of the following two major components:

- **Compiler**: Converts TFLite or ONNX models exported from high-level frameworks into the KModel format suitable for the target hardware platform, and performs structural optimization, operator scheduling, and quantization processing;
- **Runtime**: Loads and runs KModel on the target device (such as K230), and combines hardware acceleration units (such as the KPU) to achieve high-performance model inference.

🏷️ **Compiler**: Used to compile neural network models on a PC, ultimately generating kmodel files. It mainly includes modules such as importer, IR, Evaluator, Quantize, Transform optimization, Tiling, Partition, Schedule, and Codegen.

- Importer: Imports models from other neural network frameworks into nncase;
- IR: Intermediate Representation, divided into Neutral IR (device-independent) imported by the importer and Target IR (device-dependent) generated by lowering conversion from Neutral IR;
- Evaluator: The Evaluator provides the interpretation and execution capability of IR, and is commonly used in scenarios such as Constant Folding/PTQ Calibration;
- Transform: Used for IR conversion and graph traversal optimization;
- Quantize: Post-training quantization, adds quantization markers to tensors to be quantized. Based on the input calibration set, it invokes the Evaluator for interpretation and execution, collects the data range of tensors, inserts quantization/dequantization nodes, and finally optimizes to eliminate unnecessary quantization/dequantization nodes;
- Tiling: Limited by the relatively small memory capacity of the NPU, large chunks of computation need to be split. In addition, selecting Tiling parameters when there is a large amount of data reuse in computation will affect latency and bandwidth;
- Partition: Splits the graph by ModuleType. Each split subgraph corresponds to a RuntimeModule, and different types of RuntimeModules correspond to different Devices (CPU/K230);
- Schedule: Generates the computation order and allocates buffers based on the data dependency relationships in the optimized graph;
- Codegen: Calls the codegen corresponding to the ModuleType for each subgraph separately to generate the RuntimeModule;

🏷️ **Runtime**: Integrated into the user application (App), providing functions such as model loading, input setting, inference execution, and output reading. The Runtime interface shields the underlying hardware differences, allowing developers to focus more on the integration and application development of model inference logic.

The Model Conversion chapter mainly introduces the usage of the nncase compiler and simulator.

#### Installing the nncase Environment

- **Setting up nncase in a Linux environment**

First, please install `.NET SDK 7.0` and configure the `DOTNET_ROOT` environment variable. **Please note that it is not recommended to install `dotnet` in an Anaconda virtual environment, as this may cause compatibility issues.**

```bash
sudo apt-get update
sudo apt-get install dotnet-sdk-7.0
export DOTNET_ROOT=/usr/share/dotnet
```

Next, install `nncase` and `nncase-kpu` via pip:

```bash
pip install nncase nncase-kpu
```

- **Setting up nncase in a Windows environment**

First, install [.NET SDK 7.0](https://learn.microsoft.com/zh-cn/dotnet/core/install/windows). Please follow the official Microsoft documentation to complete the installation process.
Install the `nncase` library. You can install the main program `nncase` online via pip, and download the corresponding version of `nncase_kpu` from the [GitHub Releases page](https://github.com/kendryte/nncase/releases), then install it offline using pip.

```bash
pip install nncase
# Please replace `2.x.x` with the actual downloaded version number.
pip install nncase_kpu-2.x.x-py2.py3-none-win_amd64.whl
```

- **Using Docker to set up the environment**

If you have not configured a local Ubuntu environment, you can directly use the official `nncase` Docker image. This image is based on Ubuntu 20.04, with Python 3.8 and dotnet-sdk-7.0 pre-installed, making it easy to get started quickly.

```bash
cd /path/to/nncase_sdk
docker pull ghcr.io/kendryte/k230_sdk
docker run -it --rm -v `pwd`:/mnt -w /mnt ghcr.io/kendryte/k230_sdk /bin/bash
```

- **Viewing nncase version information**

After entering the Python interactive environment, you can use the following command to confirm the currently installed `nncase` version:

```python
>>> import _nncase
>>> print(_nncase.__version__)
2.9.0
```

> The example output is `2.9.0`. Please refer to the actual installed version.

### Using nncase Compiler to Convert to kmodel

![compile_kmodel](https://www.kendryte.com/api/post/attachment?id=636)

The process of compiling kmodel mainly includes the following key steps, each with its specific purpose and technical considerations:

**Setting Compilation Options**: The core purpose of this step is to adapt the model deployment to the target hardware platform. Since edge computing devices need to explicitly specify the runtime platform to ensure whether the generated kmodel needs to leverage hardware (kpu) acceleration. At the same time, configuring preprocessing parameters (such as input normalization parameters) inside the kmodel can reduce computational overhead during inference and improve overall efficiency.

**Initializing the Compiler**: The initialization of the nncase compiler is to build a standardized environment for subsequent conversion work. The compiler completes the initialization process based on the previously configured compilation options.

**Importing the Original Model**: The ONNX/TFLite models generated by current mainstream training frameworks (such as TensorFlow/PyTorch) contain generic operators, but the KPU, as a dedicated accelerator, requires specific operator formats. This step transforms the original model into an intermediate representation that can be optimized by the compiler through model parsing and operator conversion, laying the foundation for subsequent hardware-related optimizations.

**Quantization Processing**: This is a key step to enhance edge-side inference performance. Our trained FP32 model has high accuracy but suffers from issues such as large computational latency and high memory footprint. By quantizing to INT8/INT16: significantly reduce model size, improve computational speed (leveraging hardware fixed-point acceleration instructions), and reduce power consumption (reducing memory bandwidth requirements). It should be noted that quantization introduces accuracy loss, so a calibration dataset is needed to help the model determine the range to which the weights and activation values of each layer should be mapped during the quantization process, in order to retain more information and reduce quantization errors. The quantization process requires configuring quantization parameters and calibration data. For quantization parameters, see [Compilation Parameter Description](#compilation-parameter-description).

**Compiling to Generate kmodel**: Based on the aforementioned optimizations, the final generated kmodel is deeply optimized and can be directly deployed to the K230 device for efficient inference.

#### Conversion Example

Let's take the **four-class printed digit recognition** scenario as an example to convert the ONNX model obtained above into a Kmodel. Here is the compilation example script:

```python
# Import required libraries
import os
import argparse
import numpy as np
from PIL import Image  # For image reading and processing
import onnxsim         # ONNX model simplification tool
import onnx            # ONNX model processing tool
import nncase          # nncase compiler SDK
import shutil
import math

def parse_model_input_output(model_file, input_shape):
    # Load ONNX model
    onnx_model = onnx.load(model_file)
    
    # Get all input node names in the model
    input_all = [node.name for node in onnx_model.graph.input]
    
    # Get parameters that have been initialized in the model (such as weights, etc.), which are not input data
    input_initializer = [node.name for node in onnx_model.graph.initializer]
    
    # Real inputs = all inputs - initializers
    input_names = list(set(input_all) - set(input_initializer))
    
    # Extract real input tensors from the graph
    input_tensors = [node for node in onnx_model.graph.input if node.name in input_names]

    # Extract input tensor name, data type, shape, and other information
    inputs = []
    for _, e in enumerate(input_tensors):
        onnx_type = e.type.tensor_type
        input_dict = {}
        input_dict['name'] = e.name
        # Convert to NumPy data type
        input_dict['dtype'] = onnx.mapping.TENSOR_TYPE_TO_NP_TYPE[onnx_type.elem_type]
        # If a certain dimension is 0, it means the ONNX model has not fixed the shape, use the passed-in input_shape instead
        input_dict['shape'] = [(i.dim_value if i.dim_value != 0 else d) for i, d in zip(onnx_type.shape.dim, input_shape)]
        inputs.append(input_dict)

    return onnx_model, inputs

def onnx_simplify(model_file, dump_dir, input_shape):
    # Get model and input shape information
    onnx_model, inputs = parse_model_input_output(model_file, input_shape)

    # Automatically infer missing shape information
    onnx_model = onnx.shape_inference.infer_shapes(onnx_model)

    # Construct input shape mapping for onnxsim
    input_shapes = {input['name']: input['shape'] for input in inputs}

    # Simplify the model
    onnx_model, check = onnxsim.simplify(onnx_model, input_shapes=input_shapes)
    assert check, "Model simplification verification failed"

    # Save the simplified model
    model_file = os.path.join(dump_dir, 'simplified.onnx')
    onnx.save_model(onnx_model, model_file)
    return model_file

def read_model_file(model_file):
    with open(model_file, 'rb') as f:
        model_content = f.read()
    return model_content

def generate_data(shape, batch, calib_dir):
    # Get all image paths in the dataset
    img_paths = [os.path.join(calib_dir, p) for p in os.listdir(calib_dir)]
    data = []

    for i in range(batch):
        assert i < len(img_paths), "Insufficient calibration images"

        # Load image and convert to RGB format
        img_data = Image.open(img_paths[i]).convert('RGB')

        # Resize according to model input dimensions
        img_data = img_data.resize((shape[3], shape[2]), Image.BILINEAR)

        # Convert to NumPy array
        img_data = np.asarray(img_data, dtype=np.uint8)

        # Convert to NCHW format
        img_data = np.transpose(img_data, (2, 0, 1))

        # Add batch dimension
        data.append([img_data[np.newaxis, ...]])

    return np.array(data)

def main():
    # Command line argument definitions
    parser = argparse.ArgumentParser(prog="nncase")
    parser.add_argument("--target", default="k230", type=str, help='Compilation target, e.g., k230 or cpu')
    parser.add_argument("--model", type=str, help='Input ONNX model path')
    parser.add_argument("--dataset_path", type=str, help='PTQ calibration dataset path')
    parser.add_argument("--input_width", type=int, default=320, help='Model input width')
    parser.add_argument("--input_height", type=int, default=320, help='Model input height')
    parser.add_argument("--ptq_option", type=int, default=0, help='PTQ option: 0-5')

    args = parser.parse_args()

    # Align input dimensions upward to multiples of 32, meeting hardware requirements
    input_width = int(math.ceil(args.input_width / 32.0)) * 32
    input_height = int(math.ceil(args.input_height / 32.0)) * 32
    input_shape = [1, 3, input_height, input_width]  # NCHW format

    # Create temporary directory to save intermediate models
    dump_dir = 'tmp'
    if not os.path.exists(dump_dir):
        os.makedirs(dump_dir)

    # Simplify the model
    model_file = onnx_simplify(args.model, dump_dir, input_shape)

    # Compilation options settings
    compile_options = nncase.CompileOptions()
    compile_options.target = args.target                  # Specify target platform
    compile_options.preprocess = True                     # Enable preprocessing
    compile_options.swapRB = False                        # Do not swap RB channels
    compile_options.input_shape = input_shape             # Set input shape
    compile_options.input_type = 'uint8'                  # Input image data type
    compile_options.input_range = [0, 1]                  # Input image dequantization range
    compile_options.mean = [0, 0, 0]                      # Preprocessing mean
    compile_options.std = [1, 1, 1]                       # Standard deviation set to 1, no normalization
    compile_options.input_layout = "NCHW"                 # Input data format

    # Initialize compiler
    compiler = nncase.Compiler(compile_options)

    # Import ONNX model as IR
    model_content = read_model_file(model_file)
    import_options = nncase.ImportOptions()
    compiler.import_onnx(model_content, import_options)

    # PTQ option settings (Post-Training Quantization)
    ptq_options = nncase.PTQTensorOptions()
    ptq_options.samples_count = 10  # Number of calibration samples

    # Support 6 quantization schemes (choose based on accuracy vs. performance trade-off)
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

    # Set PTQ calibration data
    ptq_options.set_tensor_data(generate_data(input_shape, ptq_options.samples_count, args.dataset_path))

    # Apply PTQ
    compiler.use_ptq(ptq_options)

    # Compile model
    compiler.compile()

    # Export KModel file
    base, ext = os.path.splitext(args.model)
    kmodel_name = base + ".kmodel"
    with open(kmodel_name, 'wb') as f:
        f.write(compiler.gencode_tobytes())

# Python program main entry
if __name__ == '__main__':
    main()
```

Save the above code as the `to_kmodel.py` script, and use the following conversion command to complete the compilation:

```shell
# You need to replace the onnx model with your trained model
python to_kmodel.py --target k230 --model best.onnx --dataset_path test --input_width 320 --input_height 320 --ptq_option 0
```

Through the above code, we have successfully obtained the Kmodel model for recognizing four classes of digits. You might be curious: during the process of converting the model to Kmodel, what exactly do those parameters used mean? If I want to convert a different model in the future, do I need to modify the parameters as well? Don't worry, the following sections will guide you through the specific meanings of these conversion parameters, and teach you how to correctly configure them when converting other models, guiding you step by step, so you won't get lost!

<a id="compilation-parameter-description"></a>

#### Compilation Parameter Description

Using `nncase compiler` to convert `tflite/onnx` models to `kmodel`, the key to model conversion code lies in configuring options according to your own needs, mainly `CompileOptions`, `PTQTensorOptions`, and `ImportOptions`.

`nncase` user guide documentation: [github: user_guide](https://github.com/kendryte/nncase/tree/master/examples/user_guide).

- **Compilation Options CompileOptions**

The `CompileOptions` class is used to configure `nncase` compilation options. The properties are described as follows:

| Property Name               |         Type          | Required | Description                                                                                                                                       |
| :-------------------------- | :-------------------: | :------: | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| target                      |        string         |    Yes   | Specify the compilation target, such as 'cpu', 'k230'                                                                                             |
| dump_ir                     |         bool          |    No    | Specify whether to dump IR, default is False                                                                                                      |
| dump_asm                    |         bool          |    No    | Specify whether to dump asm assembly file, default is False                                                                                       |
| dump_dir                    |        string         |    No    | After enabling switches like dump_ir above, specify the dump directory here, default is ""                                                        |
| input_file                  |        string         |    No    | When the ONNX model exceeds 2GB, used to specify the parameter file path, default is ""                                                            |
| preprocess                  |         bool          |    No    | Whether to enable preprocessing, default is False. The following parameters only take effect when `preprocess=True`                               |
| input_type                  |        string         |    No    | Specify the input data type when preprocessing is enabled, default is "float". When `preprocess` is `True`, must be specified as "uint8" or "float32" |
| input_shape                 |       list[int]       |    No    | Specify the input data shape when preprocessing is enabled, default is []. When `preprocess` is `True`, must be specified                       |
| input_range                 |      list[float]      |    No    | Specify the floating-point range of input data after dequantization when preprocessing is enabled, default is [ ]. When `preprocess` is `True` and `input_type` is `uint8`, must be specified |
| input_layout                |        string         |    No    | Specify the layout of input data, default is ""                                                                                                  |
| swapRB                      |         bool          |    No    | Whether to reverse data in the `channel` dimension, default is False                                                                              |
| mean                        |      list[float]      |    No    | Mean of preprocessing normalization parameters, default is [0,0,0]                                                                               |
| std                         |      list[float]      |    No    | Variance of preprocessing normalization parameters, default is [1,1,1]                                                                           |
| letterbox_value             |         float         |    No    | Specify the padding value for preprocessing letterbox, default is 0                                                                               |
| output_layout               |        string         |    No    | Specify the layout of output data, default is ""                                                                                                 |
| shape_bucket_enable         |         bool          |    Yes   | Whether to enable ShapeBucket function, default is False. Takes effect when `dump_ir=True`                                                        |
| shape_bucket_range_info     | Dict[str, [int, int]] |    Yes   | The range of variables in each input shape dimension information, the minimum value must be greater than or equal to 1                          |
| shape_bucket_segments_count |          int          |    Yes   | How many segments the input variable range is divided into                                                                                       |
| shape_bucket_fix_var_map    |    Dict[str, int]     |    No    | Fix the variables in shape dimension information to specific values                                                                               |

For instructions on configuring preprocessing, please refer to the API documentation: [nncase Model Compilation API Manual Preprocessing Flow](./api_reference/nncase/nncase_compile.md#preprocess). Encapsulating some preprocessing operations inside the model can improve preprocessing efficiency during board inference. Supported preprocessing includes: `swapRB`(RGB->BGR or BGR->RGB), `Transpose`(NHWC->NCHW or NCHW->NHWC), `Normalization`(subtract mean divide variance), `Dequantize`, etc. For example: if the onnx model requires `RGB` input, but we read images using `opencv` as `BGR`, normally during preprocessing for onnx model inference we need to first convert `BGR` to `RGB` for the onnx model. When converting to kmodel, we can set `swapRB` to `True`, so that the kmodel itself contains the preprocessing step of swapping `RB` channels. During preprocessing for kmodel inference, we can ignore the step of swapping `RB` channels and place this step inside the kmodel.

- **Import Options ImportOptions**

The ImportOptions class is used to configure nncase import options, configuring the model to be converted by the compiler. It can configure `tflite/onnx`. Usage examples are as follows:

```python
# Read and import tflite model
model_content = read_model_file(model)
compiler.import_tflite(model_content, import_options)

# Read and import onnx model
model_content = read_model_file(model)
compiler.import_onnx(model_content, import_options)
```

- **Post-Training Quantization Options PTQTensorOptions**

The `PTQTensorOptions` class is used to configure `nncase PTQ` options:

| Name                        | Type   | Required | Description                                                                                                              |
| --------------------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------ |
| samples_count               | int    |    No    | Specify the number of calibration samples used for quantization                                                         |
| calibrate_method            | string |    No    | Specify the quantization method, optional 'NoClip', 'Kld', default is 'Kld'                                              |
| finetune_weights_method     | string |    No    | Specify whether to fine-tune weights, optional 'NoFineTuneWeights', 'UseSquant', default is 'NoFineTuneWeights'          |
| quant_type                  | string |    No    | Specify the data quantization type, optional 'uint8', 'int8', 'int16', `quant_type` and `w_quant_type` cannot both be 'int16' simultaneously |
| w_quant_type                | string |    No    | Specify the weight quantization type, optional 'uint8', 'int8', 'int16', `quant_type` and `w_quant_type` cannot both be 'int16' simultaneously |
| quant_scheme                | string |    No    | Path to import the quantization parameter configuration file                                                            |
| quant_scheme_strict_mode    | bool   |    No    | Whether to strictly perform quantization according to quant_scheme                                                       |
| export_quant_scheme         | bool   |    No    | Whether to export the quantization parameter configuration file                                                         |
| export_weight_range_by_channel | bool |    No    | Whether to export weights quantization parameters in `bychannel` form, it is recommended to set this parameter to `True` |

For the specific usage flow of mixed quantization, see [MixQuant Description](https://github.com/kendryte/nncase/blob/release/2.0/docs/MixQuant.md).

For instructions on configuring quantization, please refer to the table above. If the converted kmodel does not achieve the desired effect, you can modify the `quant_type` and `w_quant_type` parameters to change the quantization types of model data and weights, but these two parameters cannot both be set to `int16`.

- **Quantization Calibration Set Settings**

| Name | Type                    | Description                  |
| ---- | ----------------------- | ---------------------------- |
| data | List[List[np.ndarray]]  | Read calibration data        |

The calibration data used during the quantization process is set through the `set_tensor_data` method, with the interface parameter type being `List[List[np.ndarray]]`. For example: if the model has one input and the calibration data count is set to 10, the input calibration data dimensions would be `[10,1,3,320,320]`; if the model has two inputs and the calibration data count is set to 10, the input calibration data dimensions would be `[[10,1,3,224,224],[10,1,3,320,320]]`.

### Using the nncase Simulator to Verify the Conversion Result

Earlier we discussed how to convert a model into a Kmodel. Now it's time to "examine" the model and see how well it was converted!

Because ONNX and Kmodel may differ in their preprocessing steps, we need to prepare input data according to each of their respective requirements. Then, we run inference once with the ONNX model and once with the Kmodel, save the results, and calculate the **Cosine similarity** between them—this is like comparing how similar their outputs are.

In a nutshell: we want to see whether the converted Kmodel and the original ONNX model produce similar outputs. If the difference is too large, it suggests there may be an issue during the conversion process, and you'll need to go back and check the parameter settings～

After the model is successfully converted, you can use `nncase.Simulator` to load the Kmodel locally on your PC for inference. By calculating the cosine similarity between the ONNX model and the Kmodel outputs, you can determine whether the Kmodel output is correct. **Note that this process runs on your local computer, not on the k230 development board.**

First, you need to install the onnx-related packages in your Python environment:

```shell
pip install onnx
pip install onnxruntime
pip install onnxsim
```

To execute the simulator inference script, you need to add the nncase plugin environment variable:

- **linux**:

```shell
# The paths in the commands below are the paths of the Python environment where nncase is installed. Please adapt them according to your environment.
export NNCASE_PLUGIN_PATH=$NNCASE_PLUGIN_PATH:/usr/local/lib/python3.9/site-packages/
export PATH=$PATH:/usr/local/lib/python3.9/site-packages/
source /etc/profile
```

- **windows**:

Add the `Lib/site-packages` path under the `Python` environment where `nncase` is installed to the system environment variable `Path`.

Here is example code for verifying output similarity in the **4-class printed digit recognition** scenario:

```python
import os
import cv2
import numpy as np
import onnxruntime as ort
import nncase
import math

def get_onnx_input(img_path,mean,std,model_input_size):
    # Read the image; image data is generally RGB three-channel, with color range [0, 255.0]
    image_fp32=cv2.imread(img_path)
    # If the model input requires RGB, convert to RGB format; if BGR is required, no conversion is needed
    image_fp32=cv2.cvtColor(image_fp32, cv2.COLOR_BGR2RGB)
    # Resize to the model input size
    image_fp32 = cv2.resize(image_fp32, (model_input_size[0], model_input_size[1]))
    # Data type is float32
    image_fp32 = np.asarray(image_fp32, dtype=np.float32)
    # Data normalization: first normalize to [0,1], then subtract mean and divide by std
    image_fp32/=255.0
    for i in range(3):
        image_fp32[:, :, i] -= mean[i]
        image_fp32[:, :, i] /= std[i]
    # Arrange as NCHW or NHWC according to the model input requirements
    image_fp32 = np.transpose(image_fp32, (2, 0, 1))
    return image_fp32.copy()

def get_kmodel_input(img_path,mean,std,model_input_size):
    # Read the image; image data is generally RGB three-channel, with color range [0, 255.0]
    image_uint8=cv2.imread(img_path)
    # If the model input requires RGB, convert to RGB format; if BGR is required, no conversion is needed
    image_uint8=cv2.cvtColor(image_uint8, cv2.COLOR_BGR2RGB)
    # Resize to the model input size
    image_uint8 = cv2.resize(image_uint8, (model_input_size[0], model_input_size[1]))
    # Data type is uint8. Since preprocessing is enabled when converting to kmodel and normalization parameters are set, normalization does not need to be applied here
    image_uint8 = np.asarray(image_uint8, dtype=np.uint8)
    # Arrange as NCHW or NHWC according to the model input requirements
    image_uint8 = np.transpose(image_uint8, (2, 0, 1))
    return image_uint8.copy()

def onnx_inference(onnx_path,onnx_input_data):
    # Create an ONNX inference session (load model)
    ort_session = ort.InferenceSession(onnx_path)
    # Get the list of model output names for subsequent inference calls
    output_names = []
    model_outputs = ort_session.get_outputs()
    for i in range(len(model_outputs)):
        output_names.append(model_outputs[i].name)

    # Get the model's input information
    model_input = ort_session.get_inputs()[0]             # The first input (usually there is only one)
    model_input_name = model_input.name                   # The input name (key)
    model_input_type = np.float32                         # Input data type, assumed to be float32 here
    model_input_shape = model_input.shape                 # Input tensor shape (dimensions)

    # Process the input data; ensure it matches the model's input shape
    model_input_data = onnx_input_data.astype(model_input_type).reshape(model_input_shape)

    # Execute inference, passing in the input name and data, returns all output results
    onnx_results = ort_session.run(output_names, { model_input_name : model_input_data })
    return onnx_results

def kmodel_inference(kmodel_path,kmodel_input_data,model_input_size):
    # Initialize the nncase simulator
    sim = nncase.Simulator()
    # Read the kmodel
    with open(kmodel_path, 'rb') as f:
        kmodel = f.read()
    # Load the kmodel
    sim.load_model(kmodel)
    # Read the input data
    input_shape = [1, 3, model_input_size[1], model_input_size[0]]
    dtype = sim.get_input_desc(0).dtype
    # Process the input data; ensure it matches the model's input shape
    kmodel_input = kmodel_input_data.astype(dtype).reshape(input_shape)
    # Set the simulator input tensor; this is a single input
    sim.set_input_tensor(0, nncase.RuntimeTensor.from_numpy(kmodel_input))
    # Run inference on the kmodel using the simulator
    sim.run()
    # Get the inference outputs
    kmodel_results = []
    for i in range(sim.outputs_size):
        kmodel_result = sim.get_output_tensor(i).to_numpy()  # Convert to numpy array
        kmodel_results.append(kmodel_result)  # Save to the list
    return kmodel_results

def cosine_similarity(onnx_results,kmodel_results):
    output_size=len(kmodel_results)
    # Flatten each output to one dimension, then compute the cosine similarity
    for i in range(output_size):
        onnx_i=np.reshape(onnx_results[i], (-1))
        kmodel_i=np.reshape(kmodel_results[i], (-1))
        cos = (onnx_i @ kmodel_i) / (np.linalg.norm(onnx_i, 2) * np.linalg.norm(kmodel_i, 2))
        print('output {0} cosine similarity : {1}'.format(i, cos))
    return

if __name__ == '__main__':
    img_path="test.jpg"
    mean=[0,0,0]
    std=[1,1,1]
    model_input_size=[320,320]
    # ONNX model file
    onnx_model = "best.onnx"
    # kmodel file
    kmodel_path="best.kmodel"
    # Generate ONNX model input data
    onnx_input_data = get_onnx_input(img_path,mean,std,model_input_size)
    # Generate kmodel input data
    kmodel_input_data = get_kmodel_input(img_path,mean,std,model_input_size)
    # ONNX model inference
    onnx_results = onnx_inference(onnx_model,onnx_input_data)
    # kmodel inference
    nncase_results = kmodel_inference(kmodel_path,kmodel_input_data,model_input_size)
    # Compute output similarity
    cosine_similarity(onnx_results,nncase_results)
```

Save the above code as a file, replace the model in the code with your own converted model, and run the script to get output similar to the following:

```shell
output 0 cosine similarity : 0.9995334148406982
```

Generally, we consider the model conversion successful when the similarity is greater than 0.99, and it is usable in real deployment scenarios.

#### Generating Input Data

⚠️ **Note**: When using the ONNX model and KModel for inference, **the preprocessing steps for the input data must be handled carefully**. If specific preprocessing operations have been encapsulated inside the KModel, there is no need to manually apply these preprocessing steps to the input data before inference. However, when using the ONNX model for inference, all necessary preprocessing must be explicitly performed outside the model.

The preprocessing operations supported and that can be encapsulated by KModel include:

- Channel order conversion (e.g., RGB ↔ BGR), corresponding to the `SwapRB` parameter;
- Layout conversion (NCHW ↔ NHWC), corresponding to the `input_shape` and `input_layout` parameters;
- Data normalization, depending on the `mean` and `std` parameters;
- Input dequantization, depending on the `input_type` and `input_range` parameters;

For the differences between the ONNX and KModel inference processes, refer to the following flow diagram:

![inference_diff_onnx_kmodel](https://www.kendryte.com/api/post/attachment?id=612)

When using the ONNX model for inference, since it does not contain any preprocessing logic, the user must complete all required preprocessing steps before input.
For KModel, if the `preprocess` option was enabled during model compilation, the relevant preprocessing operations will be automatically encapsulated inside the model, and the user no longer needs to handle them manually during inference.
If `preprocess` was not enabled, its usage is the same as the ONNX model, and all preprocessing must still be completed outside the model.

Based on the flow above, developers can construct inference data that conforms to the input specifications according to the model requirements, so that it can be used during inference.
**Please note: the data generation process must strictly match the model requirements; the input processing flow may differ significantly between different models, and they must not be mixed.**

The following is example code for data preprocessing:

```python
def get_onnx_input(img_path,mean,std,model_input_size):
    # Read the image; image data is generally RGB three-channel, with color range [0, 255.0]
    image_fp32=cv2.imread(img_path)
    # If the model input requires RGB, convert to RGB format; if BGR is required, no conversion is needed
    image_fp32=cv2.cvtColor(image_fp32, cv2.COLOR_BGR2RGB)
    # Resize to the model input size
    image_fp32 = cv2.resize(image_fp32, (model_input_size[0], model_input_size[1]))
    # Data type is float32
    image_fp32 = np.asarray(image_fp32, dtype=np.float32)
    # Data normalization: first normalize to [0,1], then subtract mean and divide by std
    image_fp32/=255.0
    for i in range(3):
        image_fp32[:, :, i] -= mean[i]
        image_fp32[:, :, i] /= std[i]
    # Arrange as NCHW or NHWC according to the model input requirements
    image_fp32 = np.transpose(image_fp32, (2, 0, 1))
    return image_fp32.copy()

def get_kmodel_input(img_path,mean,std,model_input_size):
    # Read the image; image data is generally RGB three-channel, with color range [0, 255.0]
    image_uint8=cv2.imread(img_path)
    # If the model input requires RGB, convert to RGB format; if BGR is required, no conversion is needed
    image_uint8=cv2.cvtColor(image_uint8, cv2.COLOR_BGR2RGB)
    # Resize to the model input size
    image_uint8 = cv2.resize(image_uint8, (model_input_size[0], model_input_size[1]))
    # Data type is uint8. Since preprocessing is enabled when converting to kmodel and normalization parameters are set, normalization does not need to be applied here
    image_uint8 = np.asarray(image_uint8, dtype=np.uint8)
    # Arrange as NCHW or NHWC according to the model input requirements
    image_uint8 = np.transpose(image_uint8, (2, 0, 1))
    return image_uint8.copy()
```

When performing inference with the ONNX model and KModel, there are several key differences in input data preprocessing, mainly reflected in the following aspects:

- **Normalization**: The ONNX model itself does not contain any preprocessing logic, so its input data must be normalized externally (e.g., subtract the mean and divide by the standard deviation). For KModel, if normalization parameters (such as `mean` and `std`) were configured during model conversion, this normalization operation will be encapsulated inside the model, and **no repeated processing is required before inference**.

- **Data Type Difference**: The ONNX model's input is usually of type `float32`, whereas the KModel's input type depends on the `input_type` (e.g., `uint8`) and `input_range` specified during model conversion. The KModel performs dequantization internally during inference, converting the integer type back into an approximate floating-point representation.

- **Channel Order Processing**: If `SwapRB` was not enabled during model conversion (i.e., the parameter is `False`), the input image's channel order must be converted from BGR to RGB in the external preprocessing stage. If `SwapRB=True`, this channel conversion operation will be handled automatically inside the KModel, and **does not need to be performed externally**.

In summary, the external preprocessing required for the ONNX model is equal to the KModel's external preprocessing **plus** the KModel's internal preprocessing. The relationship between them can be expressed as follows:

```shell
ONNX 模型外部预处理 = KModel 外部预处理 + KModel 内部预处理
```

#### Loading the ONNX Model and Running Inference

First, use the ONNX model to perform inference and obtain the inference results of the ONNX model. Example code is as follows:

```python
def onnx_inference(onnx_path,onnx_input_data):
    # Create an ONNX inference session (load model)
    ort_session = ort.InferenceSession(onnx_path)
    # Get the list of model output names for subsequent inference calls
    output_names = []
    model_outputs = ort_session.get_outputs()
    for i in range(len(model_outputs)):
        output_names.append(model_outputs[i].name)

    # Get the model's input information
    model_input = ort_session.get_inputs()[0]             # The first input (usually there is only one)
    model_input_name = model_input.name                   # The input name (key)
    model_input_type = np.float32                         # Input data type, assumed to be float32 here
    model_input_shape = model_input.shape                 # Input tensor shape (dimensions)

    # Process the input data; ensure it matches the model's input shape
    model_input_data = onnx_input_data.astype(model_input_type).reshape(model_input_shape)

    # Execute inference, passing in the input name and data, returns all output results
    onnx_results = ort_session.run(output_names, { model_input_name : model_input_data })
    return onnx_results
```

#### Loading the kmodel and Running Inference

Then use the successfully converted kmodel to perform inference and obtain the inference results of the kmodel. Example code is as follows:

```python
def kmodel_inference(kmodel_path,kmodel_input_data,model_input_size):
    # Initialize the nncase simulator
    sim = nncase.Simulator()
    # Read the kmodel
    with open(kmodel_path, 'rb') as f:
        kmodel = f.read()
    # Load the kmodel
    sim.load_model(kmodel)
    # Read the input data
    input_shape = [1, 3, model_input_size[1], model_input_size[0]]
    dtype = sim.get_input_desc(0).dtype
    # Process the input data; ensure it matches the model's input shape
    kmodel_input = kmodel_input_data.astype(dtype).reshape(input_shape)
    # Set the simulator input tensor; this is a single input
    sim.set_input_tensor(0, nncase.RuntimeTensor.from_numpy(kmodel_input))
    # Run inference on the kmodel using the simulator
    sim.run()
    # Get the inference outputs
    kmodel_results = []
    for i in range(sim.outputs_size):
        kmodel_result = sim.get_output_tensor(i).to_numpy()  # Convert to numpy array
        kmodel_results.append(kmodel_result)  # Save to the list
    return kmodel_results
```

#### Computing the Cosine Similarity of the Outputs

After obtaining the inference results of both the ONNX model and the kmodel, calculate the cosine similarity for each output one by one. Generally, a similarity above 0.99 can be considered a successful model conversion that is ready for deployment. Example code is as follows:

```python
def cosine_similarity(onnx_results,kmodel_results):
    output_size=len(kmodel_results)
    # Flatten each output to one dimension, then compute the cosine similarity
    for i in range(output_size):
        onnx_i=np.reshape(onnx_results[i], (-1))
        kmodel_i=np.reshape(kmodel_results[i], (-1))
        cos = (onnx_i @ kmodel_i) / (np.linalg.norm(onnx_i, 2) * np.linalg.norm(kmodel_i, 2))
        print('output {0} cosine similarity : {1}'.format(i, cos))
    return
```

## Model Deployment

```{note}
👉 Earlier we converted the kmodel and verified it. Of course, the next step is———**run it on the board!** In this chapter, we'll talk about how to load the model and perform inference using the provided nncase runtime API in the K230 RT-Smart environment.

So here's the question: the model is ready, but how do we prepare the input data? We need to process the input image according to the model's "taste" — things like size, format, normalization, etc. — to make sure it "eats" it correctly. Then we feed the processed data in and let the model start inferring. After inference, the model gives us a bunch of "output results" — what do they mean? We need to parse them, for example to extract useful information like categories and coordinates.

Finally, of course we can't keep it hidden! We'll display the recognized content on the screen, such as drawing boxes and labeling numbers, so that the entire pipeline from image acquisition, model inference, to result display runs **smoothly and end-to-end**!

This chapter will walk you through this complete process and make the model really "come alive"～

Regarding the more complex processes mentioned in this chapter, they are encapsulated in the SDK's `src/rtsmart/examples/ai/ai_demo/common_files/video_pipeline.cc`. Users only need to call `pl.GetFrame(dump_res)` to get one frame of MIPI image. The UVC process is also encapsulated in `src/rtsmart/examples/ai/uvc_face_detection/src/uvc_pipeline.cc`. For usage code, refer to the `main.cc` file in the example. Users can focus on the model inference code. For development documentation, refer to: [Single Model Application Development](./app_develop_guide/ai/single_model_example.md).
```

For a practical AI program, it includes not only model inference, but also different modules such as image input, preprocessing/postprocessing programs, and result display. The following figure shows a complete block diagram of a typical AI application:

![deploy_pipeline](https://www.kendryte.com/api/post/attachment?id=650)

🚀 Deployment Process Explanation: Deployment can be understood as the process of "making the model actually work." Below, we'll walk through it step by step.

**1️⃣ Get Image Data (Input Data Source)**
First, we need to obtain an image. Usually it's captured in real-time from a camera, or a test image can be loaded from local storage. After getting the image, you can use the image's data pointer to create a `runtime_tensor`. On the K230 development board, you typically use the `kd_mpi_vicap_dump_frame` interface to get one frame of data and create a `runtime_tensor` from the virtual address.

**2️⃣ Construct Input Tensor (Prepare Data to Feed the Model)**
Once you have the image, you need to "package" it into a format the model can process — `runtime_tensor`. This step is to feed the model with a standard data structure.

**3️⃣ Preprocessing (ai2d Module)**
The model has specific requirements for the input image, such as size, format, channel order, etc. In this step, we use the ai2d module to process the image tensor into the "shape" the model needs.

**4️⃣ Model Inference (Using the KPU Inference Module)**
After the image is processed, it's fed into the KPU (K230's neural network acceleration module) for inference. The KPU returns a result tensor, which contains the model's output, such as detection boxes, classification probabilities, etc.

**5️⃣ Postprocessing (Extract Useful Information)**
The KPU outputs a bunch of numbers, and we need to parse out the "good stuff." For example, what number is recognized? Where is the box located in the image? These all need to be handled by postprocessing algorithms. For the YOLO model, postprocessing includes confidence filtering, NMS (Non-Maximum Suppression), etc.

**6️⃣ Display Recognition Results (Visualization)**
The last step is to "draw" out the recognized content! We can draw detection boxes, numeric labels, etc. on the screen to make the results clear at a glance. Generally, two layers are used for display: one for the original image, and another for the recognition results (such as boxes and numbers). Overlay display ensures clearer and more flexible results.

Summary: The core deployment workflow is: get image → process into input → feed to model → get results → interpret results → display! Once this pipeline runs through, your model is truly "live and working"! 🎉

💡 **Firmware Introduction**: Please follow the steps in the documentation below to set up the build environment and compile the firmware to ensure the **latest features** are supported! For the tutorial, see: [Firmware Compilation](./userguide/how_to_build.md).

### Get Input and Create Tensor

Earlier we said that once the model is running, it needs input data to start inferring, right? So where does this image data come from? In this section, we'll talk about——**where images come from, and how they gradually become a format the model can "eat"!**

There are actually three ways to obtain images: you can use a local image stored on the board in advance (such as a test image you've copied in beforehand), use the on-board MIPI camera to capture real-time footage, or connect a UVC camera to capture images. Regardless of which method you choose, ultimately you need to get an **RGB888P format data pointer** — this is like the "raw material." If the obtained data format doesn't match, some modules need to be used for conversion.

```{note}
👉 The difference between **`RGB888` and `RGB888P`** mainly lies in **how pixel data is arranged in memory**.

**RGB888 format**: The R, G, B components of each pixel are stored contiguously and directly together, with data layout as `HWC`.
**Memory layout**:

[R0][G0][B0]  [R1][G1][B1]  [R2][G2][B2]  ...
[Rw][Gw][Bw]  ...

Each pixel takes up **3 bytes** (8-bit R + 8-bit G + 8-bit B = 24 bits).

**RGB888P format**: All R components are placed together, all G components together, and all B components together, with data layout as `CHW`.
**Memory layout**:
[R0][R1][R2]...[Rn]    ← All red components
[G0][G1][G2]...[Gn]    ← All green components
[B0][B1][B2]...[Bn]    ← All blue components

Each component's memory block size is `width × height` bytes.

Therefore, how to create the input `tensor` depends on the `input_layout` of `nncase.CompileOptions` when converting the model, or you can use `netron` to view the input layout of the `onnx` model.
```

After getting the image, we can't directly send it to the model. We use the API provided by the `nncase::runtime` module to convert this array into a **runtime_tensor**. At this point, the data is "packaged" and can be safely sent into the model for inference!

So what is a tensor? You can think of it as a "language" the model understands — it's like a box that holds data. The model takes in a tensor, and after inference, the output is also a tensor. In the `nncase::runtime` module, this is encapsulated as `runtime_tensor`. As long as you construct it according to the requirements, you can use it directly.

![create_tensor](https://www.kendryte.com/api/post/attachment?id=651)

The figure above illustrates the process of obtaining an input image and creating a tensor. The model inference input is of type `runtime_tensor`, which can be created from a data pointer.

Common input data sources include:

- Image files
- MIPI camera
- UVC camera

This section provides detailed introductions to these three input data sources.
  
#### Image File Input

Read an image from the development board, create a `cv::Mat` instance, and create a `runtime tensor` instance from the `data pointer of the cv::Mat instance`. The example code is shown below. `opencv` reads an image, and the default `cv::Mat` instance is in `BGR HWC format`. First convert it to `RGB CHW` format, then create an empty tensor, map out a writable memory area on the Host side, copy the data into the tensor, and then sync it to the device:

```cpp
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <nncase/runtime/interpreter.h>
#include <nncase/runtime/runtime_op_utility.h>
#include "scoped_timing.h"

using namespace std;
using namespace nncase::runtime;

/**
 * @brief Single image/frame size
 */
typedef struct FrameCHWSize
{
    int channel;
    int height; // High
    int width;  // Wide
} FrameCHWSize;

std::string image_path = "/sdcard/test.jpg";
// Read image
cv::Mat ori_img = cv::imread(image_path);
FrameCHWSize image_size={ori_img.channels(),ori_img.rows,ori_img.cols};
// Create an empty vector for storing chw image data, convert the read hwc data to chw data
std::vector<uint8_t> chw_vec;
std::vector<cv::Mat> bgrChannels(3);
cv::split(ori_img, bgrChannels);
for (auto i = 2; i > -1; i--)
{
    std::vector<uint8_t> data = std::vector<uint8_t>(bgrChannels[i].reshape(1, 1));
    chw_vec.insert(chw_vec.end(), data.begin(), data.end());
}
// Create tensor
dims_t in_shape { 1, 3, ori_img.rows, ori_img.cols };
runtime_tensor input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, hrt::pool_shared).expect("cannot create input tensor");
auto input_buf = input_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");
```
  
#### MIPI Video Stream Input

The k230 vicap module is responsible for image acquisition and data processing and supports MIPI-interface cameras. MIPI cameras can acquire image data through the vicap module. The vicap module supports multi-channel image acquisition and can convert the acquired image data into the `runtime_tensor` type for inference with kmodel models. For vicap module configuration and usage, refer to the [VICAP API Documentation](./api_reference/mpp/vicap.md).

🏷️ **Single-Channel Image Acquisition**

Each MIPI camera can output up to 3 image channels, and each channel can have a different resolution or format.
Here, one channel output is used as an example. The data processing flow is shown in the figure below:

![1_chn_process](https://www.kendryte.com/api/post/attachment?id=613)

The input data during model inference can also come from the MIPI camera video stream. To ensure that the output data is arranged in CHW order, we generally specify the camera output data format as `PIXEL_FORMAT_RGB_888_PLANAR`. The code for configuring the VICAP device output is as follows. The following code is pseudocode and cannot actually be run:

```cpp
// 定义ISP出图分辨率和单通道的出图分辨率
#define ISP_WIDTH 1920
#define ISP_HEIGHT 1080
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 360
#define AI_FRAME_CHANNEL 3

k_s32 ret = 0;
k_u32 pool_id;
k_vb_pool_config pool_config;

//---------------------------- 配置video buffer------------------------------------------------
memset(&config, 0, sizeof(k_vb_config));
config.max_pool_cnt = 64;
// 设置vb配置
ret = kd_mpi_vb_set_config(&config);
if (ret) {
    printf("vb_set_config failed ret:%d\n", ret);
    return ret;
}
// 设置vb附加配置，如DCF信息/ISP统计信息/ISP实时参数等
k_vb_supplement_config supplement_config;
memset(&supplement_config, 0, sizeof(supplement_config));
supplement_config.supplement_config |= VB_SUPPLEMENT_JPEG_MASK;
ret = kd_mpi_vb_set_supplement_config(&supplement_config);
if (ret) {
    printf("vb_set_supplement_config failed ret:%d\n", ret);
    return ret;
}
// vb初始化
ret = kd_mpi_vb_init();
if (ret) {
    printf("vb_init failed ret:%d\n", ret);
    return ret;
}
//------------------------------------------------------------------------------------------------

//------------------------------- 配置Sensor & vicap-----------------------------------------------------
//sensor类型自动探测，获取sensor类型
k_vicap_sensor_type sensor_type;

k_vicap_probe_config probe_cfg = {0};
k_vicap_sensor_info sensor_info;
probe_cfg.csi_num = CONFIG_MPP_SENSOR_DEFAULT_CSI;
probe_cfg.width = ISP_WIDTH;
probe_cfg.height = ISP_HEIGHT;
probe_cfg.fps = 30;
if(0x00 != kd_mpi_sensor_adapt_get_ex(&probe_cfg, &sensor_info, VICAP_MIPI_LANE_PREF_ANY)) {
    printf("vicap, can't probe sensor on %d, output %dx%d@%d\n", probe_cfg.csi_num, probe_cfg.width, probe_cfg.height, probe_cfg.fps);
    return -1;
}
sensor_type =  sensor_info.sensor_type;
memset(&sensor_info, 0, sizeof(k_vicap_sensor_info));
ret = kd_mpi_vicap_get_sensor_info(sensor_type, &sensor_info);
if (ret) {
    printf("vicap, the sensor type not supported!\n");
    return ret;
}

//设置vicap设备ID和通道ID
k_vicap_dev vicap_dev=VICAP_DEV_ID_0;
k_vicap_chn vicap_chn_to_ai=VICAP_CHN_ID_1;

//初始化vicap的设备，配置设备属性
k_vicap_dev_attr dev_attr;
memset(&dev_attr, 0, sizeof(k_vicap_dev_attr));
dev_attr.acq_win.h_start = 0;
dev_attr.acq_win.v_start = 0;
dev_attr.acq_win.width = ISP_WIDTH;
dev_attr.acq_win.height = ISP_HEIGHT;
dev_attr.mode = VICAP_WORK_ONLINE_MODE;
dev_attr.pipe_ctrl.data = 0xFFFFFFFF;
dev_attr.pipe_ctrl.bits.af_enable = 0;
dev_attr.pipe_ctrl.bits.ahdr_enable = 0;
dev_attr.pipe_ctrl.bits.dnr3_enable = 0;
dev_attr.cpature_frame = 0;
dev_attr.sensor_info = sensor_info;
ret = kd_mpi_vicap_set_dev_attr(vicap_dev, dev_attr);
if (ret) {
    printf("vicap, kd_mpi_vicap_set_dev_attr failed.\n");
    return ret;
}

// VICAP 通道 1：输出给 AI 使用（RGB Planar）
k_vicap_chn_attr chn1_attr;
memset(&chn1_attr, 0, sizeof(k_vicap_chn_attr));
chn1_attr.out_win.width  = AI_FRAME_WIDTH;
chn1_attr.out_win.height = AI_FRAME_HEIGHT;
chn1_attr.crop_win       = dev_attr.acq_win;
chn1_attr.scale_win      = chn1_attr.out_win;
chn1_attr.crop_enable    = K_FALSE;
chn1_attr.scale_enable   = K_FALSE;
chn1_attr.chn_enable     = K_TRUE;
chn1_attr.pix_format     = PIXEL_FORMAT_RGB_888_PLANAR; // AI 常用输入格式
chn1_attr.buffer_num     = VICAP_MAX_FRAME_COUNT;
chn1_attr.buffer_size    = VICAP_ALIGN_UP((AI_FRAME_WIDTH * AI_FRAME_HEIGHT * 3 ), VICAP_ALIGN_1K);
chn1_attr.buffer_pool_id = VB_INVALID_POOLID;
printf("kd_mpi_vicap_set_chn_attr, buffer_size[%d]\n", chn1_attr.buffer_size);

ret = kd_mpi_vicap_set_chn_attr(vicap_dev, vicap_chn_to_ai, chn1_attr);
if (ret) {
    printf("kd_mpi_vicap_set_chn_attr failed.\n");
    return ret;
}
// 设置不同vicap设备加载ISP参数的方式，默认为0
ret = kd_mpi_vicap_set_database_parse_mode(vicap_dev, VICAP_DATABASE_PARSE_XML_JSON);
if (ret) {
    printf("kd_mpi_vicap_set_database_parse_mode failed.\n");
    return ret;
}
// vicap设备初始化
ret = kd_mpi_vicap_init(vicap_dev);
if (ret) {
    printf("kd_mpi_vicap_init failed.\n");
}
printf("kd_mpi_vicap_start_stream\n");
// 启动vicap设备输出数据流
ret = kd_mpi_vicap_start_stream(vicap_dev);
if (ret) {
    printf("kd_mpi_vicap_init failed.\n");
}
//----------------------------------------------------------------------------------------------------------
// 初始化一帧数据，然后使用kd_mpi_vicap_dump_frame获取一帧数据
k_video_frame_info dump_info;
memset(&dump_info, 0, sizeof(k_video_frame_info));
ret = kd_mpi_vicap_dump_frame(vicap_dev, VICAP_CHN_ID_1, VICAP_DUMP_YUV, &dump_info, 1000);
if (ret)
{
    printf("kd_mpi_vicap_dump_frame failed.\n");
}
// 映射到虚拟地址
auto vbvaddr = kd_mpi_sys_mmap(dump_info.v_frame.phys_addr[0], AI_FRAME_CHANNEL*AI_FRAME_HEIGHT*AI_FRAME_WIDTH);
uintptr_t virt_addr=reinterpret_cast<uintptr_t>(vbvaddr);
uintptr_t phy_addr=reinterpret_cast<uintptr_t>(dump_info.v_frame.phys_addr[0]);

// 在虚拟地址基础上创建tensor
input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, { (gsl::byte *)virt_addr, compute_size(in_shape) },false, hrt::pool_shared, phy_addr).expect("cannot create input tensor");
hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("sync write_back failed");

//释放当前帧
ret = kd_mpi_vicap_dump_release(vicap_dev, VICAP_CHN_ID_1, &dump_info);
if (ret)
{
    printf("kd_mpi_vicap_dump_release failed.\n");
}
```

🏷️ **Dual-Channel Image Acquisition**

When running AI model inference on an edge device, the model requires a large amount of computation, so **the inference process usually takes a considerable amount of time**, ranging from a few milliseconds to several hundred milliseconds. If a single-channel processing flow is used:

```text
Image acquisition → Format conversion → Data preprocessing → Model inference → Result post-processing → Original image drawing → Image display
```

This serial execution method results in high image display latency, especially when the model is large or system resources are limited. Screen updates become noticeably slower, affecting the user experience.

To address this issue, **a dual-channel processing architecture is recommended**, using an asynchronous processing strategy in which **one channel is used for real-time display and the other channel is used for model inference**. This architecture processes image acquisition and model inference in parallel, effectively reducing display latency and improving frame continuity. The dual-channel processing mechanism is as follows:

- **Display channel**: Directly acquires images and pushes them to the screen to achieve low-latency real-time image display. Data from this channel can be implemented using binding.
- **Inference channel**: Independently acquires images and executes the complete AI inference process, including format conversion, preprocessing, model inference, and post-processing.
- **OSD layer composition**: Draws model inference results, such as detection boxes and keypoints, as an OSD layer, and then combines them with the original image through hardware overlay before outputting them for display.

Although the inference results will have a certain visual delay, that is, the detection boxes from the previous frame are displayed on the current frame, overall frame continuity is better and the user experience is smoother.

![2_chn_process](https://www.kendryte.com/api/post/attachment?id=614)

The pseudocode for dual-channel color image mode is shown below. The following code cannot be run directly and is provided for illustration only:

```cpp
#define ISP_WIDTH 1920
#define ISP_HEIGHT 1080
#define DISPLAY_MODE 1   
#define DISPLAY_WIDTH 800
#define DISPLAY_HEIGHT 480
#define DISPLAY_ROTATE 1
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 360
#define AI_FRAME_CHANNEL 3
#define USE_OSD 1
#define OSD_WIDTH 800
#define OSD_HEIGHT 480
#define OSD_CHANNEL 4

k_s32 ret = 0;
k_u32 pool_id;
k_vb_pool_config pool_config;

//---------------------------- 配置video buffer------------------------------------------------
memset(&config, 0, sizeof(k_vb_config));
config.max_pool_cnt = 64;

// 设置vb配置
ret = kd_mpi_vb_set_config(&config);
if (ret) {
    printf("vb_set_config failed ret:%d\n", ret);
    return ret;
}
// 设置vb附加配置，如DCF信息/ISP统计信息/ISP实时参数等
k_vb_supplement_config supplement_config;
memset(&supplement_config, 0, sizeof(supplement_config));
supplement_config.supplement_config |= VB_SUPPLEMENT_JPEG_MASK;
ret = kd_mpi_vb_set_supplement_config(&supplement_config);
if (ret) {
    printf("vb_set_supplement_config failed ret:%d\n", ret);
    return ret;
}
// vb初始化
ret = kd_mpi_vb_init();
if (ret) {
    printf("vb_init failed ret:%d\n", ret);
    return ret;
}
//------------------------------------------------------------------------------------------------
// ---------------------------------配置屏幕-------------------------------------------------------
k_connector_info connector_info;
memset(&connector_info, 0, sizeof(k_connector_info));

// 根据 connector 类型获取硬件参数
ret = kd_mpi_get_connector_info(connector_type, &connector_info);
if (ret) {
    printf("the connector type not supported!\n");
    return ret;
}

// 打开 connector 设备
k_s32 connector_fd = kd_mpi_connector_open(connector_info.connector_name);
if (connector_fd < 0) {
    printf("%s, connector open failed.\n", __func__);
    return K_ERR_VO_NOTREADY;
}

// 打开电源
ret = kd_mpi_connector_power_set(connector_fd, K_TRUE);
if (ret) {
    printf("ERROR: kd_mpi_connector_power_set failed, ret=%d\n", ret);
    return ret;
}

// 初始化 connector（配置时序、分辨率等）
ret = kd_mpi_connector_init(connector_fd, connector_info);
if (ret) {
    printf("ERROR: kd_mpi_connector_init failed, ret=%d\n", ret);
    return ret;
}

// 关闭设备句柄（配置完成即可关闭）
ret = kd_mpi_connector_close(connector_fd);
if (ret) {
    printf("ERROR: kd_mpi_connector_close failed, ret=%d\n", ret);
    return ret;
}

//--------------------------------------------------------------------------------------------------

//-----------------------------------配置vo-----------------------------------------------------------
k_s32 vo_dev_id=K_VO_DISPLAY_DEV_ID;
k_s32 vo_bind_chn_id=K_VO_DISPLAY_CHN_ID1;
//初始化VO配置，包括分辨率、是否旋转、显示位置
//Layer1设置
k_vo_layer_id vo_chn_id = K_VO_LAYER_VIDEO1;
k_vo_layer_attr vo_attr;

kd_mpi_vo_disable_layer(vo_chn_id);  // 先关闭 layer，避免旧配置干扰

memset(&vo_attr, 0, sizeof(k_vo_layer_attr));
vi_vo_attr.layer_id        = vo_chn_id;
vi_vo_attr.position.x      = 0;
vi_vo_attr.position.y      = 0;
vi_vo_attr.img_size.width  = DISPLAY_WIDTH;
vi_vo_attr.img_size.height = DISPLAY_HEIGHT;
vi_vo_attr.pixel_format    = PIXEL_FORMAT_YUV_SEMIPLANAR_420; // NV12
vi_vo_attr.global_alpha   = 0xFF;                            // 不透明
// 根据 DISPLAY_MODE 是否需要旋转
vi_vo_attr.func            = DISPLAY_MODE? GDMA_ROTATE_DEGREE_90 : GDMA_ROTATE_DEGREE_0;
// 若旋转，需要额外的 DMA buffer
vi_vo_attr.rot_buf_nr      = DISPLAY_MODE? 2 : 0;
vi_vo_attr.rot_buf_bpp     = 0;

ret = kd_mpi_vo_set_layer_attr(vo_chn_id, &vo_attr);
if (ret != K_SUCCESS) {
    printf("ERROR: kd_mpi_vo_set_layer_attr failed, ret=%d\n", ret);
    return ret;
}

ret = kd_mpi_vo_enable_layer(vo_chn_id);
if (ret != K_SUCCESS) {
    printf("ERROR: kd_mpi_vo_enable_layer failed, ret=%d\n", ret);
    return ret;
}

printf("VICAP to VO: layer=%d configured for %ux%u NV12, rotate90=%d\n",
        vo_chn_id, DISPLAY_WIDTH, DISPLAY_HEIGHT, DISPLAY_MODE ? 1 : 0);

//---------------------------------------------------------------------------------------------------

//------------------------------- 配置Sensor & vicap-----------------------------------------------------
//sensor类型自动探测
//设置vicap设备ID和通道ID，0通道出YUV420SP的图像直接给到vo显示，1通道出RGB888P图像在此数据上创建tensor给AI模型推理
k_vicap_dev vicap_dev=VICAP_DEV_ID_0;
k_vicap_chn vicap_chn_to_vo=VICAP_CHN_ID_0;
k_vicap_chn vicap_chn_to_ai=VICAP_CHN_ID_1;

k_vicap_probe_config probe_cfg = {0};
k_vicap_sensor_info sensor_info;
probe_cfg.csi_num = CONFIG_MPP_SENSOR_DEFAULT_CSI + 1;
probe_cfg.width = ISP_WIDTH;
probe_cfg.height = ISP_HEIGHT;
probe_cfg.fps = 30;
if(0x00 != kd_mpi_sensor_adapt_get_ex(&probe_cfg, &sensor_info, VICAP_MIPI_LANE_PREF_ANY)) {
    printf("vicap, can't probe sensor on %d, output %dx%d@%d\n", probe_cfg.csi_num, probe_cfg.width, probe_cfg.height, probe_cfg.fps);
    return -1;
}
sensor_type =  sensor_info.sensor_type;
memset(&sensor_info, 0, sizeof(k_vicap_sensor_info));
ret = kd_mpi_vicap_get_sensor_info(sensor_type, &sensor_info);
if (ret) {
    printf("vicap, the sensor type not supported!\n");
    return ret;
}

//初始化vicap的设备，配置设备属性
k_vicap_dev_attr dev_attr;
memset(&dev_attr, 0, sizeof(k_vicap_dev_attr));
dev_attr.acq_win.h_start = 0;
dev_attr.acq_win.v_start = 0;
dev_attr.acq_win.width = ISP_WIDTH;
dev_attr.acq_win.height = ISP_HEIGHT;
dev_attr.mode = VICAP_WORK_ONLINE_MODE;
dev_attr.pipe_ctrl.data = 0xFFFFFFFF;
dev_attr.pipe_ctrl.bits.af_enable = 0;
dev_attr.pipe_ctrl.bits.ahdr_enable = 0;
dev_attr.pipe_ctrl.bits.dnr3_enable = 0;
dev_attr.cpature_frame = 0;
dev_attr.sensor_info = sensor_info;
ret = kd_mpi_vicap_set_dev_attr(vicap_dev, dev_attr);
if (ret) {
    printf("vicap, kd_mpi_vicap_set_dev_attr failed.\n");
    return ret;
}

// 配置vicap的通道0，设置出图格式为PIXEL_FORMAT_YUV_SEMIPLANAR_420，该通道会绑定到vo的layer1，用于直接显示当前图像
k_vicap_chn_attr chn0_attr;
memset(&chn0_attr, 0, sizeof(k_vicap_chn_attr));
chn0_attr.out_win.width  = DISPLAY_WIDTH;
chn0_attr.out_win.height = DISPLAY_HEIGHT;
chn0_attr.crop_win       = dev_attr.acq_win;
chn0_attr.scale_win      = chn0_attr.out_win;
chn0_attr.crop_enable    = K_FALSE;
chn0_attr.scale_enable   = K_FALSE;
chn0_attr.chn_enable     = K_TRUE;
chn0_attr.pix_format     = PIXEL_FORMAT_YUV_SEMIPLANAR_420; // NV12
chn0_attr.buffer_num     = VICAP_MAX_FRAME_COUNT;
chn0_attr.buffer_size    = VICAP_ALIGN_UP((DISPLAY_WIDTH * DISPLAY_HEIGHT * 3 / 2), VICAP_ALIGN_1K);
chn0_attr.buffer_pool_id = VB_INVALID_POOLID;
printf("vicap ...kd_mpi_vicap_set_chn_attr, buffer_size[%d]\n", chn0_attr.buffer_size);
ret = kd_mpi_vicap_set_chn_attr(vicap_dev, vicap_chn_to_vo, chn0_attr);
if (ret) {
    printf("vicap, kd_mpi_vicap_set_chn_attr failed.\n");
    return ret;
}

//初始化绑定信息，绑定vicap的通道0到vo的通道1
k_mpp_chn vicap_mpp_chn;
k_mpp_chn vo_mpp_chn;
vicap_mpp_chn.mod_id = K_ID_VI;
vicap_mpp_chn.dev_id = vicap_dev;
vicap_mpp_chn.chn_id = vicap_chn_to_vo;
vo_mpp_chn.mod_id = K_ID_VO;
vo_mpp_chn.dev_id = vo_dev_id;
vo_mpp_chn.chn_id = vo_bind_chn_id;
ret = kd_mpi_sys_bind(&vicap_mpp_chn, &vo_mpp_chn);
if (ret) {
    printf("kd_mpi_sys_bind failed:0x%x\n", ret);
}

//配置通道1，设置出图格式为PIXEL_FORMAT_RGB_888_PLANAR
k_vicap_chn_attr chn1_attr;
memset(&chn1_attr, 0, sizeof(k_vicap_chn_attr));
chn1_attr.out_win.width  = AI_FRAME_WIDTH;
chn1_attr.out_win.height = AI_FRAME_HEIGHT;
chn1_attr.crop_win       = dev_attr.acq_win;
chn1_attr.scale_win      = chn1_attr.out_win;
chn1_attr.crop_enable    = K_FALSE;
chn1_attr.scale_enable   = K_FALSE;
chn1_attr.chn_enable     = K_TRUE;
chn1_attr.pix_format     = PIXEL_FORMAT_RGB_888_PLANAR; // AI 常用输入格式
chn1_attr.buffer_num     = VICAP_MAX_FRAME_COUNT;
chn1_attr.buffer_size    = VICAP_ALIGN_UP((AI_FRAME_WIDTH * AI_FRAME_HEIGHT * 3 ), VICAP_ALIGN_1K);
chn1_attr.buffer_pool_id = VB_INVALID_POOLID;
printf("kd_mpi_vicap_set_chn_attr, buffer_size[%d]\n", chn1_attr.buffer_size);
ret = kd_mpi_vicap_set_chn_attr(vicap_dev, vicap_chn_to_ai, chn1_attr);
if (ret) {
    printf("kd_mpi_vicap_set_chn_attr failed.\n");
    return ret;
}
// 设置不同vicap设备加载ISP参数的方式，默认为0
ret = kd_mpi_vicap_set_database_parse_mode(vicap_dev, VICAP_DATABASE_PARSE_XML_JSON);
if (ret) {
    printf("kd_mpi_vicap_set_database_parse_mode failed.\n");
    return ret;
}
// vicap设备初始化
ret = kd_mpi_vicap_init(vicap_dev);
if (ret) {
    printf("kd_mpi_vicap_init failed.\n");
}
printf("kd_mpi_vicap_start_stream\n");
// 启动vicap设备输出数据流
ret = kd_mpi_vicap_start_stream(vicap_dev);
if (ret) {
    printf("kd_mpi_vicap_init failed.\n");
}
//----------------------------------------------------------------------------------------------------------
// 初始化一帧数据，然后使用kd_mpi_vicap_dump_frame获取一帧数据
k_video_frame_info dump_info;
memset(&dump_info, 0, sizeof(k_video_frame_info));
ret = kd_mpi_vicap_dump_frame(vicap_dev, VICAP_CHN_ID_1, VICAP_DUMP_YUV, &dump_info, 1000);
if (ret)
{
    printf("kd_mpi_vicap_dump_frame failed.\n");
}
// 映射到虚拟地址
auto vbvaddr = kd_mpi_sys_mmap(dump_info.v_frame.phys_addr[0], AI_FRAME_CHANNEL*AI_FRAME_HEIGHT*AI_FRAME_WIDTH);
uintptr_t virt_addr=reinterpret_cast<uintptr_t>(vbvaddr);
uintptr_t phy_addr=reinterpret_cast<uintptr_t>(dump_info.v_frame.phys_addr[0]);

// 在虚拟地址基础上创建tensor
input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, { (gsl::byte *)virt_addr, compute_size(in_shape) },false, hrt::pool_shared, phy_addr).expect("cannot create input tensor");
hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("sync write_back failed");

//释放当前帧
ret = kd_mpi_vicap_dump_release(vicap_dev, VICAP_CHN_ID_1, &dump_info);
if (ret)
{
    printf("kd_mpi_vicap_dump_release failed.\n");
}
```
  
#### UVC Video Stream Input

The latest code for k230 RT-Smart supports USB cameras. The UVC module provides camera detection, configuration, and image acquisition functions, supporting single-camera operation. The captured video stream images can also be used as input for kmodel inference. For UVC module documentation, see: [RTOS UVC Introduction](./app_develop_guide/media/uvc.md).

The UVC inference flow is shown in the figure below:

![uvc_process](https://www.kendryte.com/api/post/attachment?id=652)

Here is the pseudocode for creating a `runtime_tensor`. This code is for illustration only and cannot run directly:

```cpp
#define UVC_WIDTH 640
#define UVC_HEIGHT 480
#define DISPLAY_MODE 1   
#define DISPLAY_WIDTH 640
#define DISPLAY_HEIGHT 480
#define DISPLAY_ROTATE 1
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 480
#define AI_FRAME_CHANNEL 3

// Decoder device ID and channel ID (usually default 0)
k_vdec_chn_attr vdec_attr;
k_s32 vdec_dev_id = 0;
k_s32 vdec_bind_chn_id = 0;
k_s32 vdec_pool_id;
k_video_frame_info vdec_frame_info; ///< Decoder output video frame info
k_vdec_supplement_info supplement_info; ///< Decoder supplementary info

// nonai 2D related
k_u32 nonai2d_dev_id = 0;               ///< nonai 2D device ID
// YUV420SP to RGB888 channel
k_u32 nonai2d_rgb888_chn_id = 0;        ///< nonai 2D RGB888 channel ID
k_nonai_2d_chn_attr attr_2d_rgb888;     ///< nonai 2D RGB888 channel attribute
k_video_frame_info rgb888_frame_info;   ///< nonai 2D RGB888 video frame info
k_s32 nonai2d_rgb888_pool_id;
// RGB888 to YUV420SP channel
k_u32 nonai2d_yuv420sp_chn_id = 1;      ///< nonai 2D YUV420SP channel ID
k_nonai_2d_chn_attr attr_2d_yuv420sp;   ///< nonai 2D YUV420SP channel attribute
k_video_frame_info yuv420sp_frame_info; ///< nonai 2D YUV420SP video frame info
k_s32 nonai2d_yuv420sp_pool_id;

// Set to JPEG decode mode (1 means JPEG format)
unsigned char is_jpeg = 1;
// Initialize UVC format structure
uvc_format init_format = { UVC_WIDTH, UVC_HEIGHT, is_jpeg, 0 };
uvc_frame cur_frame;

k_s32 ret = 0; 

// Decoder create vb method
static k_s32 vdec_vb_create_pool(int width, int height)
{
    k_vb_pool_config pool_config;

    memset(&pool_config, 0, sizeof(pool_config));
    pool_config.blk_cnt = 6;
    pool_config.blk_size = ALIGN_UP(width * height, 0x1000) * 2;
    pool_config.mode = VB_REMAP_MODE_NOCACHE;

    return kd_mpi_vb_create_pool(&pool_config);
}

// nonai_2d create vb method
static k_s32 nonai_2d_vb_create_pool()
{
    k_vb_pool_config pool_config;
    memset(&pool_config, 0, sizeof(pool_config));

    pool_config.blk_cnt =  2;
    pool_config.blk_size = ALIGN_UP((DISPLAY_WIDTH * DISPLAY_HEIGHT * 3), VICAP_ALIGN_1K);
    pool_config.mode = VB_REMAP_MODE_NOCACHE;

    return kd_mpi_vb_create_pool(&pool_config);
}

// ---------------------------- Configure video buffer -----------------------------------
k_vb_config config;
memset(&config, 0, sizeof(k_vb_config));
config.max_pool_cnt = 64;

// Set VB configuration
ret = kd_mpi_vb_set_config(&config);
if (ret) {
    printf("vb_set_config failed ret:%d\n", ret);
    return ret;
}

// Set VB supplementary configuration
k_vb_supplement_config supplement_config;
memset(&supplement_config, 0, sizeof(supplement_config));
supplement_config.supplement_config |= VB_SUPPLEMENT_JPEG_MASK;
ret = kd_mpi_vb_set_supplement_config(&supplement_config);
if (ret) {
    printf("vb_set_supplement_config failed ret:%d\n", ret);
    return ret;
}

// Initialize VB system
ret = kd_mpi_vb_init();
if (ret) {
    printf("vb_init failed ret:%d\n", ret);
    return ret;
}
// -----------------------------------------------------------------------------------------------

// ---------------------------- Configure JPEG decoder (VDEC) ----------------------------------------
vdec_pool_id = vdec_vb_create_pool(UVC_WIDTH, UVC_HEIGHT);
if (vdec_pool_id == VB_INVALID_POOLID) {
    printf("fail to create vdec pool\n");
    return -1;
}

ret = kd_mpi_vdec_attach_vb_pool(vdec_bind_chn_id,vdec_pool_id);
if (ret) {
    printf("kd_mpi_vdec_attach_vb_pool fail, ret = %d\n", ret);
    return -1;
}

// Decoder attribute configuration, JPEG->YUV420
vdec_attr.pic_width = UVC_WIDTH;
vdec_attr.pic_height = UVC_HEIGHT;
vdec_attr.frame_buf_cnt = 6;
vdec_attr.stream_buf_size = ALIGN_UP(UVC_WIDTH * UVC_HEIGHT, 0x1000);  // Input buffer size
vdec_attr.frame_buf_size = vdec_attr.stream_buf_size * 2;              // Decoded frame buffer size
vdec_attr.type = K_PT_JPEG;                                            // Decode type: JPEG
vdec_attr.frame_buf_pool_id = vdec_pool_id;                            // Memory pool ID used

// Create decode channel
ret = kd_mpi_vdec_create_chn(vdec_bind_chn_id, &vdec_attr);
if (ret) {
    printf("kd_mpi_vdec_create_chn fail, ret = %d\n", ret);
    return -1;
}

// Start decode channel
ret = kd_mpi_vdec_start_chn(vdec_bind_chn_id);
if (ret) {
    printf("kd_mpi_vdec_start_chn fail, ret = %d\n", ret);
    return -1;
}

// Decode frame initialization, supplementary info parameter configuration
memset(&vdec_frame_info, 0, sizeof(k_video_frame_info));
memset(&supplement_info, 0, sizeof(k_vdec_supplement_info));
supplement_info.type=K_PT_JPEG;
supplement_info.is_valid_frame=K_TRUE;
supplement_info.end_of_stream=K_FALSE;
// -----------------------------------------------------------------------------------------------

// ----------------------------nonai_2d format conversion -------------------------------------------------
nonai2d_rgb888_pool_id = nonai_2d_vb_create_pool();
if (nonai2d_rgb888_pool_id == VB_INVALID_POOLID) {
    printf("fail to create nonai2d pool\n");
    return -1;
}

ret = kd_mpi_nonai_2d_attach_vb_pool(nonai2d_rgb888_chn_id,nonai2d_rgb888_pool_id);
if (ret){
    printf("kd_mpi_nonai_2d_attach_vb_pool fail, ret = %d\n", ret);
    return -1;
}

// Configure nonai2d_rgb888_chn_id channel, implement YUV420->RGB888, for AI model use
attr_2d_rgb888.mode = K_NONAI_2D_CALC_MODE_CSC;
attr_2d_rgb888.dst_fmt = PIXEL_FORMAT_RGB_888;
ret = kd_mpi_nonai_2d_create_chn(nonai2d_rgb888_chn_id, &attr_2d_rgb888);
if (ret) {
    printf("kd_mpi_nonai_2d_create_chn fail, ret = %d\n", ret);
    return -1;
}
ret = kd_mpi_nonai_2d_start_chn(nonai2d_rgb888_chn_id);
if (ret) {
    printf("kd_mpi_nonai_2d_start_chn fail, ret = %d\n", ret);
    return -1;
}
memset(&rgb888_frame_info, 0, sizeof(k_video_frame_info));

// Configure nonai2d_yuv420sp_chn_id channel, implement RGB888->YUV420SP, this channel is bound to VO display
nonai2d_yuv420sp_pool_id = nonai_2d_vb_create_pool();
if (nonai2d_yuv420sp_pool_id == VB_INVALID_POOLID) {
    printf("fail to create nonai2d pool\n");
    return -1;
}

ret = kd_mpi_nonai_2d_attach_vb_pool(nonai2d_yuv420sp_chn_id,nonai2d_yuv420sp_pool_id);
if (ret){
    printf("kd_mpi_nonai_2d_attach_vb_pool fail, ret = %d\n", ret);
    return -1;
}
// Configure nonai2d_yuv420sp_chn_id channel, implement RGB888->YUV420SP, this channel is bound to VO display
attr_2d_yuv420sp.mode = K_NONAI_2D_CALC_MODE_CSC;
attr_2d_yuv420sp.dst_fmt = PIXEL_FORMAT_YUV_SEMIPLANAR_420;
ret = kd_mpi_nonai_2d_create_chn(nonai2d_yuv420sp_chn_id, &attr_2d_yuv420sp);
if (ret) {
    printf("kd_mpi_nonai_2d_create_chn fail, ret = %d\n", ret);
    return -1;
}
ret = kd_mpi_nonai_2d_start_chn(nonai2d_yuv420sp_chn_id);
if (ret) {
    printf("kd_mpi_nonai_2d_start_chn fail, ret = %d\n", ret);
    return -1;
}
memset(&yuv420sp_frame_info, 0, sizeof(k_video_frame_info));

// -----------------------------------------------------------------------------------------------

// ---------------------------- Initialize and start UVC capture -------------------------------------------
ret = uvc_init(&init_format);
if (ret) {
    printf("uvc_init fail\n");
    return -1;
}

ret = uvc_start_stream();
if (ret) {
    printf("uvc start stream fail\n");
    return -1;
}
// -----------------------------------------------------------------------------------------------

int ret = 0;
memset(&vdec_frame_info, 0, sizeof(k_video_frame_info));
memset(&rgb888_frame_info, 0, sizeof(k_video_frame_info));
memset(&yuv420sp_frame_info, 0, sizeof(k_video_frame_info));
// Get one UVC video frame (with 5000ms timeout)
ret = uvc_get_frame(&cur_frame, 5000);
if (ret) {
    printf("uvc_get_frame fail\n");
}

// Send frame data to JPEG decoder
ret = kd_mpi_vdec_send_stream(vdec_bind_chn_id, &cur_frame.v_stream, 1000);
if (ret) {
    printf("kd_mpi_vdec_send_stream fail\n");
}
// Get decoded data frame
ret=kd_mpi_vdec_get_frame(vdec_bind_chn_id,&vdec_frame_info,&supplement_info,1000);
if (ret) {
    printf("kd_mpi_vdec_get_frame failed. %d\n", ret);
}
// Send decoded data frame to nonai2d_rgb888_chn_id channel
ret = kd_mpi_nonai_2d_send_frame(nonai2d_rgb888_chn_id, &vdec_frame_info, 1000);
if (ret) {
    printf("kd_mpi_nonai_2d_send_frame failed. %d\n", ret);
}
// Get processed RGB888 data frame from nonai2d_rgb888_chn_id channel
ret = kd_mpi_nonai_2d_get_frame(nonai2d_rgb888_chn_id, &rgb888_frame_info, 1000);
if (ret) {
    printf("kd_mpi_nonai_2d_get_frame failed. %d\n", ret);
}
// Map RGB888 data frame physical address to virtual address
auto vbvaddr = kd_mpi_sys_mmap(rgb888_frame_info.v_frame.phys_addr[0], AI_FRAME_CHANNEL*AI_FRAME_HEIGHT*AI_FRAME_WIDTH);
uintptr_t virt_addr=reinterpret_cast<uintptr_t>(vbvaddr);
uintptr_t phy_addr=reinterpret_cast<uintptr_t>(rgb888_frame_info.v_frame.phys_addr[0]);

// Create an empty runtime_tensor object for storing input data
dims_t in_shape { 1, AI_FRAME_CHANNEL, AI_FRAME_HEIGHT, AI_FRAME_WIDTH };
runtime_tensor input_tensor = host_runtime_tensor::create(typecode_t::dt_uint8, in_shape, hrt::pool_shared).expect("cannot create input tensor");
auto input_buf = input_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_write).unwrap().buffer();
void* vaddr=reinterpret_cast<void*>(virt_addr);
cv::Mat ori_img = cv::Mat(image_size.height, image_size.width, CV_8UC3, vaddr);
std::vector<uint8_t> chw_vec;
std::vector<cv::Mat> rgbChannels(3);
cv::split(ori_img, rgbChannels);
// Convert RGB888 data layout to RGB888P data
for (auto i = 0; i < 3; i++)
{
    std::vector<uint8_t> data = std::vector<uint8_t>(rgbChannels[i].reshape(1, 1));
    chw_vec.insert(chw_vec.end(), data.begin(), data.end());
}
memcpy(reinterpret_cast<char *>(input_buf.data()), chw_vec.data(), chw_vec.size());
hrt::sync(input_tensor, sync_op_t::sync_write_back, true).expect("write back input failed");

// Get processed YUV420SP data frame from nonai2d_yuv420sp_chn_id channel
ret = kd_mpi_nonai_2d_release_frame(nonai2d_rgb888_chn_id, &rgb888_frame_info);
if (ret) {
    printf("kd_mpi_nonai_2d_release_frame failed. %d\n", ret);
}
// Release VDEC frame resources
ret = kd_mpi_vdec_release_frame(vdec_bind_chn_id, &vdec_frame_info);
if (ret) {
    printf("kd_mpi_vdec_release_frame failed. %d\n", ret);
}
// Release UVC frame resources
ret = uvc_put_frame(&cur_frame);
if (ret) {
    printf("uvc_put_frame fail\n");
}
```
  
### Image Tensor Preprocessing

We have successfully converted the image data into a tensor before, but the problem arises—this tensor may not match the model's "taste". For example, the size is wrong, or the color channels are not correct. At this point, we need to step in and process the tensor so that it becomes a format acceptable to the model. This entire processing is called "preprocessing," and the one that does this work is today's protagonist—the **ai2d** module!

**🛠️ Why Do We Need Preprocessing?**
Models are "picky eaters" and only accept data of specific sizes and formats, for example: the input must be 320x320 in size; it must be in RGB order, not BGR; whether the channel is first (CHW) or last (HWC) must also match. If it doesn't match, it will cause recognition errors, or even the model may simply refuse to work and report an error.

**⚡ ai2d Module: Hardware-Accelerated, Super-Fast Processing!**
ai2d is a module on the K230 platform specifically designed for image tensor preprocessing. It runs on hardware, is very fast, and is suitable for embedded real-time tasks. It can help you complete: resizing, cropping, padding, affine transformations, and other operations, so that the image data is processed into tensor data that meets the model's input requirements.

The figure below shows the input/output flow and format of preprocessing through the ai2d module on the K230 platform:

![preprocess](https://www.kendryte.com/api/post/attachment?id=653)

#### Introduction to the Preprocessing Process

When deploying a model, the input image's `runtime_tensor` does not necessarily match the model's input specifications. For example, the image captured by the camera may be `1280×720`, while the model's input requires `320×320`. In this case, the image needs to be **preprocessed**.

Preprocessing operations include but are not limited to the following common methods:

- **Resize**: Adjust the original image to the size required by the model input;
- **Crop**: Retain the key areas of the image and remove redundant parts;
- **Normalization**: Map pixel values to a specified range (such as `[0, 1]` or `[-1, 1]`);
- **Padding**: Perform edge padding to maintain the image's aspect ratio and avoid stretching deformation.

Which specific preprocessing methods to use should be configured to match the **ONNX model's training preprocessing process**. At the same time, during the process of converting the ONNX model to KModel, some preprocessing steps (such as normalization, color channel conversion, etc.) can be encapsulated into the model through compiler parameters. These operations do not need to be re-implemented during deployment and are automatically completed by KModel.

> ⚠️ **Note**:
> A clear understanding of the preprocessing flow is required, especially when performing image **Aspect Ratio Padding**. Users can choose different strategies:
>
> - **Bilateral Padding**: Padding is applied on both the top/bottom and left/right sides of the image, centering the image;
> - **Unilateral Padding**: Padding is applied only on one side of the image (such as top/left or bottom/right), maintaining alignment on one side.
>
> Different padding methods will affect the coordinate restoration logic of the model inference output, so the corresponding coordinate transformation rules need to be **matched** during the post-processing stage to ensure that the results are correctly mapped back to the original image.

#### Introduction to the ai2d Module

In the RT-Smart solution, common image preprocessing operations are usually implemented through the `ai2d_builder` module of `nncase` with hardware acceleration. This module supports five main preprocessing methods, including:

- **Resize**
- **Crop**
- **Pad**
- **Affine**
- **Shift**

Using the `ai2d` module can effectively reduce the CPU computation burden, improve preprocessing efficiency, and is suitable for image adaptation operations before model inference. For details on the related API usage, please refer to the official documentation: [ai2d API Documentation](./api_reference/nncase/ai2d_runtime.md). For application examples, refer to the documentation: [AI2D Application Guide](./app_develop_guide/ai/usage_ai2d.md).

```{attention}
(1) **Affine and Resize are mutually exclusive**: The two cannot be enabled simultaneously; only one of the geometric transformations can be selected.  
(2) **Shift only supports Raw16 input format**, used for high-bit shift operations of specific formats.  
(3) **Pad Value is configured per channel**: A list consistent with the number of input image channels should be provided, for example, an RGB image needs to configure padding values for three channels.  
(4) **The execution order of functions is Crop → Shift → Resize/Affine → Pad**: This order must be followed when configuring multiple preprocessing steps. If the preprocessing flow does not match this order, it is recommended to initialize multiple `ai2d` instances and complete the required processing step by step.
```

By properly configuring the `ai2d` module, efficient and flexible image preprocessing can be achieved to meet the requirements of different models for input data.

Here, taking the **printed digit recognition** task as an example, which uses an aspect-ratio-preserving resize and padding preprocessing process, we introduce how to use the `ai2d` module. The **core code** (this code is for illustration only and cannot be run directly) is as follows:

```cpp
int input_w=1280;
int input_h=720;
int output_w=320;
int output_h=320;
// -------These two tensors need to be created by yourself------
runtime_tensor input_tensor;
runtime_tensor output_tensor;
// -------------------------------

// Calculate padding parameters. Here, single-side padding is chosen, with padding only on the right and bottom sides. First, calculate the scaling ratio based on the short side, then calculate the padding pixel width on both sides
float ratiow = (float)output_w / input_w;
float ratioh = (float)output_h / input_h;
float ratio = ratiow < ratioh ? ratiow : ratioh;
int new_w = (int)(ratio * input_w);
int new_h = (int)(ratio * input_h);
int top = 0;
int bottom = output_h - new_h;
int left = 0;
int right = output_w - new_w;

// Set the parameters of ai2d, including input format, output format, input data type, output data type, crop parameters, shift parameters, pad parameters, resize parameters, affine parameters. Set the method you want to use to true, and configure the operation parameters. The resize+pad method is used here
ai2d_datatype_t ai2d_dtype{ai2d_format::NCHW_FMT, ai2d_format::NCHW_FMT, typecode_t::dt_uint8, typecode_t::dt_uint8};
ai2d_crop_param_t crop_param{false, 0, 0, 0, 0};
ai2d_shift_param_t shift_param{false, 0};
ai2d_pad_param_t pad_param{true, {{0, 0}, {0, 0}, {top, bottom}, {left, right}}, ai2d_pad_mode::constant, {padding[0], padding[1], padding[2]}};
ai2d_resize_param_t resize_param{true, ai2d_interp_method::tf_bilinear, ai2d_interp_mode::half_pixel};
ai2d_affine_param_t affine_param{false, ai2d_interp_method::cv2_bilinear, 0, 0, 127, 1, {0.5, 0.1, 0.0, 0.1, 0.5, 0.0}};
// Set input and output dimensions
dims_t in_shape = {1,3,input_h,input_w};
dims_t out_shape = {1,3,output_h,output_w};
// Initialize the ai2d_builder instance
std::unique_ptr<ai2d_builder> ai2d_builder_; // ai2d builder
//Set parameters
ai2d_builder_.reset(new ai2d_builder(in_shape, out_shape, ai2d_dtype, crop_param, shift_param, pad_param, resize_param, affine_param));
ai2d_builder_->build_schedule();
// Execute preprocessing
ai2d_builder_->invoke(input_tensor,output_tensor_).expect("error occurred in ai2d running");

//Finally, the processed data can be obtained from output_tensor
```

Regarding the five preprocessing methods of `ai2d`, examples are provided in the source code `src/rtsmart/examples/ai/usage_ai2d`. Executing `build_app.sh` in the directory can compile the executable file, and the build product is in the `k230_bin` directory, which can be copied to the development board for execution and viewing the results.
  
### KPU Inference

We've already preprocessed the image and prepared the input tensor—now it's finally time for the **star of the show** to appear, and that's our "neural network acceleration unit"—**KPU**!

KPU is the hardware accelerator on the K230 specifically designed to run neural network models. Its job is: **leave the model to me, I'll handle the inference!**
However, before we begin, we need to tell it: hey, which model am I going to use! So you need to put the `.kmodel` file into the K230 board in advance, and then load this model into KPU in your code.

Next, we need to set up the input—the tensor we processed earlier with the ai2d module comes in handy now, serving as the model input passed to KPU. Then, we can let KPU start running the model at blazing speed!

Once the model finishes running, KPU returns the result to us. This result is an **output tensor** containing the raw data inferred by the model. However, this format is not human-readable and not very useful, so we need to do a "translation" step. First, map the output `tensor` to a data pointer, extract the output data, and then perform post-processing operations, such as determining which number is recognized, where its position is, and so on.

The following diagram shows the process of using KPU for model inference. The model inference process includes loading the model, setting model inputs, executing model inference, and obtaining model outputs:

![kpu_run](https://www.kendryte.com/api/post/attachment?id=654)

KPU is an acceleration engine specifically designed for deep learning, which accelerates the computation process of neural network models. For the API documentation of this module, see the link: [nncase KPU Runtime API Documentation](./api_reference/nncase/kpu_runtime.md). **For application examples of KPU, see the source code `src/rtsmart/examples/ai/usage_kpu`**.

Here is the core code for using the `kpu` module to perform KPU inference (this code is for illustration only and cannot be run directly):

```cpp
//Assume this model has one input and one output
runtime_tensor input_tensor;
runtime_tensor output_tensor;
const char* kmodel_path="./test.kmodel";

// Load model
interpreter interp;     
std::ifstream ifs(kmodel_path, std::ios::binary);
interp.load_model(ifs).expect("Invalid kmodel");
//Set input tensor, only one is set here, if there are multiple, you can set them by index
interp.input_tensor(0, input_tensor).expect("cannot set input tensor");
//interp.input_tensor(1, input_tensor_1).expect("cannot set input tensor");

//Set output tensor, only one is set here, if there are multiple, you can set them by index
interp.output_tensor(0, output_tensor).expect("cannot set input tensor");
//interp.output_tensor(1, output_tensor_1).expect("cannot set input tensor");

// Execute kpu inference
interp.run().expect("error occurred in running model");

// Get the pointer to the model output data, from which you can extract data for post-processing
auto buf = output_tensor.impl()->to_host().unwrap()->buffer().as_host().unwrap().map(map_access_::map_read).unwrap().buffer();
float *p_out = reinterpret_cast<float *>(buf.data());
```

For the **four-class printed digit recognition task**, the kpu model inference has only one output, with an output shape of [1,8,2100]. The output data shape is shown in the figure below:

![output_shape](https://www.kendryte.com/api/post/attachment?id=634)

### Post-processing

Model inference is done! KPU gave us a long string of "number arrays" as the result, but don't get too excited yet—these numbers don't make any sense at first glance. So, the next task is to **translate this data into content that humans can understand**, such as: which number appears in the image? Where is it located? How reliable is this recognition result?

For example, the output shape of our "four-class printed digit recognition" model is `[1, 8, 2100]`, which means there are a total of 2100 candidate boxes, and each box is described by 8 numbers. What are they specifically? The first 4 are the box positions (center X, Y coordinates, plus width and height), and the last 4 are the "scores" for the four digits (0, 1, 2, 3), which represent the model's confidence in each class.

The first step we need to do is to pick out the highest score from these 4 scores, get its class index and corresponding score, which represents what digit this box is most likely to be, and how confident the model is about this digit.

Then, we need to process the positions. The model outputs the box's "center point + width and height", but we are usually more accustomed to using "top-left coordinates + bottom-right coordinates", which makes it convenient for subsequent NMS operations.

So what is NMS (Non-Maximum Suppression)? You can think of it as "deduplication". Sometimes the model is too "enthusiastic" and produces several boxes for the same digit—we don't need that many—only keep the one with the highest score, and delete all others with too much overlap. Clean and tidy! This step is called NMS, and almost all object detection models have this step in post-processing. It's very critical!

Finally, there's one more detail: the model performs inference on the input size. For example, we input a 320×320 image, but the original image might be of a different size, so we need to "restore" these coordinates proportionally to the original image to draw the boxes correctly.

After all these operations, we have transformed a bunch of "mysterious numbers" from the model output into clear recognition results: **which number appears in the image, where it is, how reliable the recognition is, and the boxes are drawn!** This step is the legendary "post-processing" phase, and only then is the entire process truly complete!

The following diagram illustrates the main work of the post-processing process:

![postprocess](https://www.kendryte.com/api/post/attachment?id=655)

After model inference is complete, the model's output `tensor` is mapped to a `float` type pointer. Users can implement post-processing according to the requirements of the application scenario. For example, post-process the output of the YOLOv8 model to obtain the coordinates and class information of the detection boxes. First, we need to understand the meaning of the output. For an output of [1,8,2100], the 8 represents that 4 data points are coordinate information and 4 are class scores. The post-processing process needs to find the class index and class score with the highest score, and restore the coordinate information to the original image size using the ratio calculated during preprocessing, convert from the **center point + width and height format** to the **top-left and bottom-right coordinate format**, then use the confidence threshold to filter out some boxes, and use NMS (Non-Maximum Suppression) to filter out redundant overlapping boxes. The final result is the detection box information based on the original image. For **four-class printed digit recognition**, we provide the **core code** for post-processing of this task (this code is for illustration only and cannot be run directly) as follows:

```cpp
//Define detection box type
typedef struct Bbox{
    cv::Rect box;
    float confidence;
    int index;
}Bbox;

// Post-processing IOU calculation
float get_iou_value(cv::Rect rect1, cv::Rect rect2)
{
    int xx1, yy1, xx2, yy2;
 
    xx1 = std::max(rect1.x, rect2.x);
    yy1 = std::max(rect1.y, rect2.y);
    xx2 = std::min(rect1.x + rect1.width - 1, rect2.x + rect2.width - 1);
    yy2 = std::min(rect1.y + rect1.height - 1, rect2.y + rect2.height - 1);
 
    int insection_width, insection_height;
    insection_width = std::max(0, xx2 - xx1 + 1);
    insection_height = std::max(0, yy2 - yy1 + 1);
 
    float insection_area, union_area, iou;
    insection_area = float(insection_width) * insection_height;
    union_area = float(rect1.width*rect1.height + rect2.width*rect2.height - insection_area);
    iou = insection_area / union_area;

    return iou;
}

//NMS non-maximum suppression, bboxes is the list of Bbox instances to be processed, indices is the index of remaining bboxes after NMS
void nms(std::vector<Bbox> &bboxes,  float confThreshold, float nmsThreshold, std::vector<int> &indices)
{
    sort(bboxes.begin(), bboxes.end(), [](Bbox a, Bbox b) { return a.confidence > b.confidence; });
    int updated_size = bboxes.size();
    for (int i = 0; i < updated_size; i++)
    {
        if (bboxes[i].confidence < confThreshold)
            continue;
        indices.push_back(i);
        for (int j = i + 1; j < updated_size;)
        {
            float iou = get_iou_value(bboxes[i].box, bboxes[j].box);
            if (iou > nmsThreshold)
            {
                bboxes.erase(bboxes.begin() + j);
                updated_size = bboxes.size();
            }
            else
            {
                j++;    
            }
        }
    }
}

// Post-processing after model inference is complete
//Output pointer obtained from previous step
float *p_out;
// Label names
std::vector<std::string> classes{"0","1","2","3"};
// Confidence threshold
float conf_thresh=0.25;
// nms threshold
float nms_thresh=0.45;
//Number of classes
int class_num=classes.size();

// output0 [num_class+4,(w/8)*(h/8)+(w/16)*(h/16)+(w/32)*(h/32)]
float *output0 = p_out;
// Feature length of each box, ckass_num scores + 4 coordinates
int f_len=class_num+4;
// Calculate total output box count based on the model's input resolution
int num_box=((input_shapes[0][2]/8)*(input_shapes[0][3]/8)+(input_shapes[0][2]/16)*(input_shapes[0][3]/16)+(input_shapes[0][2]/32)*(input_shapes[0][3]/32));
// Allocate box data memory
float *output_det = new float[num_box * f_len];
// Adjust output data layout from [num_class+4,(w/8)*(h/8)+(w/16)*(h/16)+(w/32)*(h/32)] to [(w/8)*(h/8)+(w/16)*(h/16)+(w/32)*(h/32),num_class+4] for easier subsequent processing
for(int r = 0; r < num_box; r++)
{
    for(int c = 0; c < f_len; c++)
    {
        output_det[r*f_len + c] = output0[c*num_box + r];
    }
}

// Parse each box's information, class_num+4 represents one box, the first four data are coordinate values, followed by class_num scores, select the one with the highest score as the recognized class, because padding+resize was done at the beginning, the model's inference coordinates are based on the preprocessed image result, the box coordinates need to be mapped back to the original image using ratio first
std::vector<Bbox> bboxes;
for(int i=0;i<num_box;i++){
    float* vec=output_det+i*f_len;
    float box[4]={vec[0],vec[1],vec[2],vec[3]};
    float* class_scores=vec+4;
    float* max_class_score_ptr=std::max_element(class_scores,class_scores+class_num);
    float score=*max_class_score_ptr;
    int max_class_index = max_class_score_ptr - class_scores; // Calculate index
    if(score>conf_thresh){
        Bbox bbox;
        // Restore to original image ratio
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

//Execute non-maximum suppression to eliminate redundant overlapping boxes with lower confidence (NMS)
std::vector<int> nms_result;
nms(bboxes, conf_thresh, nms_thresh, nms_result);
```

The above code shows the post-processing steps for the YOLOv8 four-class printed digit recognition model.
  
### Result Drawing

Now we have the recognition results! We know the "identity" and "position" of each digit, and the next step is to make these results **"visible"**—that is, draw the detection boxes and label the digits on the image, telling everyone: "Look! There's a 1 here!" "That's a 3 over there!"

However, things aren't that simple—your model performed recognition on a 320×320 image, but the screen might be 800×480, 1920×1080, or even other sizes. If you directly draw the model's boxes on the screen, the positions might be all wrong! So we need to do a very important thing: **"map" the image coordinates to screen coordinates**, that is, convert the box positions proportionally so that they fit perfectly on the screen.

When drawing these recognition information, we generally don't modify the original image directly, but create a "transparent layer" called **OSD (On-Screen Display) that is the same size as the screen**, like sticking a glass film on a photo, where we draw boxes and label classes without affecting the underlying picture.

The final step is to overlay this OSD layer with the original image and display them together on the screen! This way you can clearly see: each digit is recognized, and the boxes are drawn properly!

The following diagram shows the process of drawing results:

![draw_result](https://www.kendryte.com/api/post/attachment?id=656)

Taking the detection boxes of **four-class printed digit recognition** as an example, the detection box coordinates we calculated are based on the input original image resolution. If we want to display them on the screen, we need to convert the coordinates proportionally to the coordinates under the screen resolution, then draw the effect on the initialized transparent `cv::Mat`, and then call the `kd_mpi_vo_chn_insert_frame` method of the `vo` module to achieve overlay display. Taking LT9611 as an example, the core code is given below (this code is for illustration only and cannot be run directly):

```cpp
#define ISP_WIDTH 1920
#define ISP_HEIGHT 1080
#define DISPLAY_MODE 0   
#define DISPLAY_WIDTH 1920
#define DISPLAY_HEIGHT 1080
#define DISPLAY_ROTATE 0
#define AI_FRAME_WIDTH 640
#define AI_FRAME_HEIGHT 360
#define AI_FRAME_CHANNEL 3
#define USE_OSD 1
#define OSD_WIDTH 1920
#define OSD_HEIGHT 1080
#define OSD_CHANNEL 4

// vb related
k_vb_config config;
// Screen related
k_connector_type connector_type=LT9611_MIPI_4LAN_1920X1080_30FPS;

k_vo_layer_id vi_vo_id=K_VO_LAYER_VIDEO1;     // VO layer ID for displaying camera video
k_vo_layer_attr vi_vo_attr;// VO layer attributes (resolution, pixel format, rotation, etc.)
k_s32 vo_dev_id;            // VO device ID

// ============================
// OSD (overlay display layer) related
// ============================
k_vo_layer_id osd_vo_id=K_VO_LAYER_OSD0;        // OSD layer ID (overlay on video)
k_vo_layer_attr osd_vo_attr;   // OSD layer attributes (ARGB, resolution, etc.)
k_u32 osd_pool_id=VB_INVALID_POOLID;             // VB memory pool ID used by OSD
k_vb_blk_handle handle;        // Memory block handle requested from VB pool
k_video_frame_info osd_frame_info; // OSD frame information (describing physical address, format, etc.)
void *insert_osd_vaddr;        // Virtual address of OSD memory block (CPU writes drawing results)

k_s32 ret = 0;

// =============================================================================================
// 1. Configure Video Buffer (VB) system
// =============================================================================================
memset(&config, 0, sizeof(k_vb_config));
config.max_pool_cnt = 64;  // Support up to 64 memory pools

// Set VB global configuration
ret = kd_mpi_vb_set_config(&config);
if (ret) {
    printf("vb_set_config failed ret:%d\n", ret);
    return ret;
}

// Set VB supplement configuration (JPEG, ISP statistics, etc.)
k_vb_supplement_config supplement_config;
memset(&supplement_config, 0, sizeof(supplement_config));
supplement_config.supplement_config |= VB_SUPPLEMENT_JPEG_MASK;
ret = kd_mpi_vb_set_supplement_config(&supplement_config);
if (ret) {
    printf("vb_set_supplement_config failed ret:%d\n", ret);
    return ret;
}

// Initialize VB subsystem
ret = kd_mpi_vb_init();
if (ret) {
    printf("vb_init failed ret:%d\n", ret);
    return ret;
}

// =============================================================================================
// 2. Create OSD dedicated VB memory pool (used for ARGB8888 overlay layer)
// =============================================================================================
// Used to store one frame of OSD data (such as AI result drawing)
if(USE_OSD == 1){
    k_vb_pool_config pool_config;
    memset(&pool_config, 0, sizeof(pool_config));
    pool_config.blk_cnt = 3; // 3 buffer blocks to avoid frame conflicts
    pool_config.blk_size = VICAP_ALIGN_UP((OSD_WIDTH * OSD_HEIGHT * OSD_CHANNEL), VICAP_ALIGN_1K);
    pool_config.mode = VB_REMAP_MODE_NOCACHE; // Non-cache mapping to avoid cache consistency issues
    osd_pool_id = kd_mpi_vb_create_pool(&pool_config);
}

// =============================================================================================
// 3. Screen (Connector) configuration
// =============================================================================================
k_connector_info connector_info;
memset(&connector_info, 0, sizeof(k_connector_info));

// Get hardware parameters based on connector type
ret = kd_mpi_get_connector_info(connector_type, &connector_info);
if (ret) {
    printf("the connector type not supported!\n");
    return ret;
}

// Open connector device
k_s32 connector_fd = kd_mpi_connector_open(connector_info.connector_name);
if (connector_fd < 0) {
    printf("%s, connector open failed.\n", __func__);
    return K_ERR_VO_NOTREADY;
}

// Power on
ret = kd_mpi_connector_power_set(connector_fd, K_TRUE);
if (ret) {
    printf("ERROR: kd_mpi_connector_power_set failed, ret=%d\n", ret);
    return ret;
}

// Initialize connector (configure timing, resolution, etc.)
ret = kd_mpi_connector_init(connector_fd, connector_info);
if (ret) {
    printf("ERROR: kd_mpi_connector_init failed, ret=%d\n", ret);
    return ret;
}

// Close device handle (can be closed after configuration is complete)
ret = kd_mpi_connector_close(connector_fd);
if (ret) {
    printf("ERROR: kd_mpi_connector_close failed, ret=%d\n", ret);
    return ret;
}

// =============================================================================================
// 4. Configure VO (video output layer: used to display camera image)
// =============================================================================================
kd_mpi_vo_disable_layer(vi_vo_id);  // Disable layer first to avoid interference from old configuration

memset(&vi_vo_attr, 0, sizeof(vi_vo_attr));
vi_vo_attr.layer_id        = vi_vo_id;
vi_vo_attr.position.x      = 0;
vi_vo_attr.position.y      = 0;
vi_vo_attr.img_size.width  = DISPLAY_WIDTH;
vi_vo_attr.img_size.height = DISPLAY_HEIGHT;
vi_vo_attr.pixel_format    = PIXEL_FORMAT_YUV_SEMIPLANAR_420; // NV12
vi_vo_attr.global_alpha   = 0xFF;                            // Opaque
// Whether rotation is needed based on DISPLAY_MODE
vi_vo_attr.func            = DISPLAY_MODE? GDMA_ROTATE_DEGREE_90 : GDMA_ROTATE_DEGREE_0;
// If rotated, additional DMA buffer is needed
vi_vo_attr.rot_buf_nr      = DISPLAY_MODE? 2 : 0;
vi_vo_attr.rot_buf_bpp     = 0;

ret = kd_mpi_vo_set_layer_attr(vi_vo_id, &vi_vo_attr);
if (ret != K_SUCCESS) {
    printf("ERROR: kd_mpi_vo_set_layer_attr failed, ret=%d\n", ret);
    return ret;
}

ret = kd_mpi_vo_enable_layer(vi_vo_id);
if (ret != K_SUCCESS) {
    printf("ERROR: kd_mpi_vo_enable_layer failed, ret=%d\n", ret);
    return ret;
}

printf("VICAP to VO: layer=%d configured for %ux%u NV12, rotate90=%d\n",
        vi_vo_id, DISPLAY_WIDTH, DISPLAY_HEIGHT, DISPLAY_MODE ? 1 : 0);

// =============================================================================================
// 5. Configure OSD layer (ARGB8888 overlay layer)
// =============================================================================================
if(USE_OSD == 1){
    kd_mpi_vo_disable_layer(osd_vo_id);

    memset(&osd_vo_attr, 0, sizeof(osd_vo_attr));
    osd_vo_attr.layer_id        = osd_vo_id;
    osd_vo_attr.position.x      = 0;
    osd_vo_attr.position.y      = 0;
    osd_vo_attr.img_size.width  = OSD_WIDTH;
    osd_vo_attr.img_size.height = OSD_HEIGHT;
    osd_vo_attr.pixel_format    = PIXEL_FORMAT_ARGB_8888;  // OSD commonly uses BGRA/ARGB
    osd_vo_attr.global_alpha    = 0xFF;
    osd_vo_attr.func            = DISPLAY_MODE? GDMA_ROTATE_DEGREE_90 : GDMA_ROTATE_DEGREE_0;
    osd_vo_attr.rot_buf_nr      = DISPLAY_MODE? 2 : 0;
    osd_vo_attr.rot_buf_bpp     = 0;

    ret = kd_mpi_vo_set_layer_attr(osd_vo_id, &osd_vo_attr);
    if (ret != K_SUCCESS) {
        printf("ERROR: kd_mpi_vo_set_layer_attr failed, ret=%d\n", ret);
        return ret;
    }

    ret = kd_mpi_vo_enable_layer(osd_vo_id);
    if (ret != K_SUCCESS) {
        printf("ERROR: kd_mpi_vo_enable_layer failed, ret=%d\n", ret);
        return ret;
    }

    printf("OSD to VO: layer=%d configured for %ux%u BGRA8888, rotate90=%d\n",
            osd_vo_id, OSD_WIDTH, OSD_HEIGHT, DISPLAY_ROTATE ? 1 : 0);

    // --------------------- Get a buffer from OSD VB pool for writing overlay data ---------------------
    k_s32 size = VICAP_ALIGN_UP(OSD_HEIGHT * OSD_WIDTH * OSD_CHANNEL, VICAP_ALIGN_1K);

    // Request a buffer from the specified memory pool
    handle = kd_mpi_vb_get_block(osd_pool_id, size, NULL);
    if (handle == VB_INVALID_HANDLE)
    {
        printf("%s get vb block error\n", __func__);
        return -1;
    }

    // Get the physical address of this buffer block
    k_u64 phys_addr = kd_mpi_vb_handle_to_phyaddr(handle);
    if (phys_addr == 0)
    {
        printf("%s get phys addr error\n", __func__);
        return -1;
    }

    // Map to user-space virtual address (non-cache)
    k_u32* virt_addr = (k_u32 *)kd_mpi_sys_mmap(phys_addr, size);
    if (virt_addr == NULL)
    {
        printf("%s mmap error\n", __func__);
        return -1;
    }

    // Initialize OSD frame descriptor structure
    memset(&osd_frame_info, 0, sizeof(osd_frame_info));
    osd_frame_info.v_frame.width        = OSD_WIDTH;
    osd_frame_info.v_frame.height       = OSD_HEIGHT;
    osd_frame_info.v_frame.stride[0]    = OSD_WIDTH*4;
    osd_frame_info.v_frame.pixel_format = PIXEL_FORMAT_BGRA_8888;
    osd_frame_info.mod_id               = K_ID_VO;
    osd_frame_info.pool_id              = osd_pool_id;
    osd_frame_info.v_frame.phys_addr[0] = phys_addr;

    // Save virtual address for subsequent memcpy to write OSD data
    insert_osd_vaddr = virt_addr;
    printf("phys_addr is %lx g_pool_id is %d \n", phys_addr, osd_pool_id);
}

// sensor vicap initialization is omitted here, channel 0 is bound to VIDEO_LAYER1 of vo

// Bind VICAP → VO (direct video display)
vicap_mpp_chn.mod_id = K_ID_VI;
vicap_mpp_chn.dev_id = vicap_dev;
vicap_mpp_chn.chn_id = vicap_chn_to_vo;
vo_mpp_chn.mod_id    = K_ID_VO;
vo_mpp_chn.dev_id    = vo_dev_id;
vo_mpp_chn.chn_id    = vi_vo_id;
ret = kd_mpi_sys_bind(&vicap_mpp_chn, &vo_mpp_chn);
if (ret) {
    printf("kd_mpi_sys_bind failed:0x%x\n", ret);
}

//Suppose here is a BGRA transparent image
cv::Mat osd_data;

// Copy image data to vb buffer block
memcpy(insert_osd_vaddr, osd_data, OSD_WIDTH * OSD_HEIGHT * OSD_CHANNEL);
//Call vo module's kd_mpi_vo_chn_insert_frame interface to insert drawing result into OSD layer
ret=kd_mpi_vo_chn_insert_frame(osd_chn_id + 3, &osd_frame_info);
if (ret)
{
    printf("kd_mpi_vo_chn_insert_frame failed.\n");
}

// The above and another channel overlay gives the final display result
```

Through the above steps, we have basically completed the complete steps of developing an application using RT-Smart. Users start from model conversion and need to have a good understanding of the entire model inference process.
  
### Display Device Introduction

For display output, the k230 provides two display devices. You can choose to use either `HDMI/LCD screen`. For the API documentation of the corresponding module, see the link: [Video Output Module API Documentation](./api_reference/mpp/display.md#kd_mpi_vo_chn_insert_frame). The two methods are described below:

🏷️ **HDMI**: The device type is `LT9611`. You can refer to the API documentation to view the supported resolution, frame rate, and number of OSDs during initialization. For dual-channel AI inference, generally another layer is created, and an OSD transparent image the same size as the screen display resolution is pasted on top to display the inference results. OSD only supports display in the four layers `K_VO_OSD0`/`K_VO_OSD1`/`K_VO_OSD2`/`K_VO_OSD3`. The example code is as follows:

```cpp
k_connector_type connector_type=LT9611_MIPI_4LAN_1920X1080_30FPS;
// ---------------------------------Configure screen-------------------------------------------------------
k_connector_info connector_info;
memset(&connector_info, 0, sizeof(k_connector_info));

// Get hardware parameters based on connector type
ret = kd_mpi_get_connector_info(connector_type, &connector_info);
if (ret) {
    printf("the connector type not supported!\n");
    return ret;
}

// Open connector device
k_s32 connector_fd = kd_mpi_connector_open(connector_info.connector_name);
if (connector_fd < 0) {
    printf("%s, connector open failed.\n", __func__);
    return K_ERR_VO_NOTREADY;
}

// Power on
ret = kd_mpi_connector_power_set(connector_fd, K_TRUE);
if (ret) {
    printf("ERROR: kd_mpi_connector_power_set failed, ret=%d\n", ret);
    return ret;
}

// Initialize connector (configure timing, resolution, etc.)
ret = kd_mpi_connector_init(connector_fd, connector_info);
if (ret) {
    printf("ERROR: kd_mpi_connector_init failed, ret=%d\n", ret);
    return ret;
}

// Close device handle (can be closed after configuration is complete)
ret = kd_mpi_connector_close(connector_fd);
if (ret) {
    printf("ERROR: kd_mpi_connector_close failed, ret=%d\n", ret);
    return ret;
}
//--------------------------------------------------------------------------------------------------
```

🏷️ **LCD**: The device type is `ST7701` or `HX8399`. You can refer to the API documentation to view the supported resolution, frame rate, and number of OSDs during initialization. For dual-channel AI inference, generally another layer is created, and an OSD transparent image the same size as the screen display resolution is pasted on top to display the inference results. OSD only supports display in the four layers `K_VO_OSD0`/`K_VO_OSD1`/`K_VO_OSD2`/`K_VO_OSD3`. The example code is as follows:

```cpp
k_connector_type connector_type=ST7701_V1_MIPI_2LAN_480X800_30FPS;
// ---------------------------------Configure screen-------------------------------------------------------
k_connector_info connector_info;
memset(&connector_info, 0, sizeof(k_connector_info));

// Get hardware parameters based on connector type
ret = kd_mpi_get_connector_info(connector_type, &connector_info);
if (ret) {
    printf("the connector type not supported!\n");
    return ret;
}

// Open connector device
k_s32 connector_fd = kd_mpi_connector_open(connector_info.connector_name);
if (connector_fd < 0) {
    printf("%s, connector open failed.\n", __func__);
    return K_ERR_VO_NOTREADY;
}

// Power on
ret = kd_mpi_connector_power_set(connector_fd, K_TRUE);
if (ret) {
    printf("ERROR: kd_mpi_connector_power_set failed, ret=%d\n", ret);
    return ret;
}

// Initialize connector (configure timing, resolution, etc.)
ret = kd_mpi_connector_init(connector_fd, connector_info);
if (ret) {
    printf("ERROR: kd_mpi_connector_init failed, ret=%d\n", ret);
    return ret;
}

// Close device handle (can be closed after configuration is complete)
ret = kd_mpi_connector_close(connector_fd);
if (ret) {
    printf("ERROR: kd_mpi_connector_close failed, ret=%d\n", ret);
    return ret;
}
//--------------------------------------------------------------------------------------------------
```

### Four-Class Printed Digit Recognition Deployment Code

If you use YOLO to implement four-class printed digit detection and recognition, the SDK has prepared complete code for you, **not only supporting single image inference**, but also **continuous recognition of real-time video streams**! Whether you want to test the model effect on a static image, or perform real-time detection after connecting to a camera, you can quickly get started. You only need to use the `kmodel` exported in the previous steps, together with the example scripts we provide, to easily deploy and run on the K230 development board!

If you want to verify the recognition accuracy and positioning effect of the model on images, you can directly run our **image recognition code**; if you want to experience the "video effect" during real-time recognition, try the **dual-channel video recognition code** and see if the boxes can accurately track the position when the number appears on the screen!

Next, you can boldly try the deployment process, feel the running effect of K230 edge AI, and AI can read the digital world you capture!

💡 **Firmware Introduction**: Please follow the steps in the documentation below to set up the compilation environment and compile the firmware to ensure that **the latest features** are supported! See the documentation tutorial: [Firmware Compilation](./userguide/how_to_build.md).

#### yolo compilation

Navigate to the `src/rtsmart/examples/ai/yolo` directory and execute `build_app.sh`. The compiled firmware is in the `k230_bin` directory.

#### Model File Copy

After the development board is flashed with the firmware and powered on, you can find the virtual USB drive `CanMV` at the disk location. The disk is divided into two partitions: `/sdcard` and `/data`. Copy the converted `kmodel` and the compiled executable `elf file`, as well as test images and label files (txt format, one class per line), to a directory on the development board.

#### Image Recognition Command

Here is the complete **4-class printed digit recognition** image inference command. You can use the kmodel obtained from the above steps for testing:

```shell
./yolo.elf -model_type yolov8 -task_type detect -task_mode image -image_path num.jpg -kmodel_path best.kmodel -labels_txt_filepath number_labels.txt -conf_thres 0.5 -nms_thres 0.45 -debug_mode 0
```

#### Dual-Channel Video Recognition Command

Here is the complete **4-class printed digit recognition** video inference command. You can use the kmodel obtained from the above steps for testing:

```shell
./yolo.elf -ai_frame_width 640 -ai_frame_height 360 -display_mode 0 -model_type yolov8 -task_type detect -task_mode video -kmodel_path best.kmodel -labels_txt_filepath number_labels.txt -conf_thres 0.5 -nms_thres 0.45 -debug_mode 0
```

## YOLO Deployment

YOLO is a commonly used model in vision tasks, supporting classification, detection, segmentation, rotated object detection, and other tasks. We have chosen the classic YOLOv5, YOLOv8, and YOLO11 from the YOLO series as the foundation, and encapsulated the deployment code for YOLOv5, YOLOv8, and YOLO11 to facilitate users in quickly deploying YOLO models. For specific content, see the link: [YOLO Application Guide](./app_develop_guide/ai/yolo.md).

### YOLOv5 Cat and Dog Classification

Implement the deployment of a cat and dog classification model based on the YOLOv5 model on K230.

#### YOLOv5 Source Code and Training Environment Setup

For setting up the `YOLOv5` training environment, please refer to [ultralytics/yolov5: YOLOv5 🚀 in PyTorch > ONNX > CoreML > TFLite (github.com)](https://github.com/ultralytics/yolov5)

```shell
git clone https://github.com/ultralytics/yolov5.git
cd yolov5
pip install -r requirements.txt
```

If you have already set up the environment, please ignore this step.

#### Training Data Preparation

Please download the provided sample dataset. The sample dataset uses cat and dog classification as the scenario, and uses YOLOv5 to complete the training.

```shell
cd yolov5
wget https://download.kendryte.com/developer/k230/yolo_dataset/cat_dog.zip
unzip cat_dog.zip
```

⚠️ **For Windows systems, please copy the link directly to the browser to download, and unzip it to the corresponding directory**.

If you have already downloaded the data, please ignore this step.

#### Using YOLOv5 to Train the Cat and Dog Classification Model

Execute the command in the `yolov5` directory to train the cat and dog classification model using `yolov5`:

```shell
python classify/train.py --model yolov5n-cls.pt --data cat_dog --epochs 100 --batch-size 8 --imgsz 224 --device '0'
```

#### Converting the Cat and Dog Classification kmodel

Model conversion requires the following libraries to be installed in the training environment:

```Shell
# linux platform: nncase and nncase-kpu can be installed online, nncase-2.x requires dotnet-7 to be installed
sudo apt-get install -y dotnet-sdk-7.0
pip install --upgrade pip
pip install nncase==2.11.0
pip install nncase-kpu==2.11.0

# windows platform: please install dotnet-7 yourself and add environment variables. nncase can be installed online using pip, but the nncase-kpu library needs to be installed offline. Download nncase_kpu-2.*-py2.py3-none-win_amd64.whl from https://github.com/kendryte/nncase/releases
# Enter the corresponding python environment, and use pip to install in the directory where nncase_kpu-2.*-py2.py3-none-win_amd64.whl is downloaded
pip install nncase_kpu-2.*-py2.py3-none-win_amd64.whl

# In addition to nncase and nncase-kpu, other libraries used by the script include:
pip install onnx==1.15.0
pip install onnxruntime==1.19.0
pip install onnxsim==0.4.36
```

Download the script tool and unzip the model conversion script tool `test_yolov5.zip` into the `yolov5` directory;

```shell
wget https://download.kendryte.com/developer/k230/yolo_files/test_yolov5.zip
unzip test_yolov5.zip
```

Follow the commands below to first export the `pt` model under `runs/train-cls/exp/weights` to an `onnx` model, and then convert it to a `kmodel` model:

```shell
# Export onnx, please choose the pt model path yourself
python export.py --weight runs/train-cls/exp/weights/best.pt --imgsz 224 --batch 1 --include onnx
cd test_yolov5/classify
# Replace the images in the test directory with part of your own training data, convert kmodel, please choose the onnx model path yourself, the generated kmodel is in the same directory level as the onnx model
python to_kmodel.py --target k230 --model ../../runs/train-cls/exp/weights/best.onnx --dataset ../test --input_width 224 --input_height 224 --ptq_option 0
cd ../../
```

💡 **Model Conversion Script (to_kmodel.py) Parameter Description**:

| Parameter Name | Description | Notes                                                                                                                                                                                                                                                                                                                                  | Type      |
| -------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| target         | Target Platform | Options are k230/cpu, corresponding to k230 kpu and cpu;                                                                                                                                                                                                                                                                          | str       |
| model          | Model Path | Path of the ONNX model to be converted;                                                                                                                                                                                                                                                                                              | str       |
| dataset        | Calibration Image Set | Image data used during model conversion, used in the quantization stage, can be taken from part of the training data                                                                                                                                                                                                                | str       |
| input_width    | Input Width | Width of the model input                                                                                                                                                                                                                                                                                                              | int       |
| input_height   | Input Height | Height of the model input                                                                                                                                                                                                                                                                                                             | int       |
| ptq_option     | Quantization Method | Quantization strategies are `Kld` and `NoClip`, combined with data and weights quantization accuracy, 0 is `NoClip`+[uint8,uint8], 1 is `NoClip`+[uint8,int16], 2 is `NoClip`+[int16,uint8], 3 is `Kld`+[uint8,uint8], 4 is `Kld`+[uint8,int16], 5 is `Kld`+[int16,uint8]                                                                | 0/1/2/3/4/5 |

#### Deploying the Model on k230 Using RT-Smart

##### Setting Up the Compilation Environment

💡 **Firmware Introduction**: Please follow the steps in the document below to set up the compilation environment and compile the firmware to ensure that **the latest features** are supported! See the documentation tutorial at: [Firmware Compilation](./userguide/how_to_build.md).

##### yolo Compilation

Enter the `src/rtsmart/examples/ai/yolo` directory, execute `build_app.sh`, and the compiled firmware is generated in the `k230_bin` directory.

##### Model File Copy

After the development board is flashed with the firmware and powered on, you can find a virtual U disk `CanMV` at the disk location. The disk is divided into two partitions: `/sdcard` and `/data`. Copy the converted `kmodel`, the compiled executable `elf file`, test images, and label files (in txt format, with each line representing a class) to a directory on the development board.

##### YOLO Module

The `YOLO` module is deployment code developed based on the `YOLO series models`, implementing the deployment process of such models. The supported situations are as follows:

- Integrates four models: `YOLOv5, YOLOv8, YOLO11, YOLO26`;
- Supports four types of tasks, among which `YOLOv5` supports three: classification (classify), detection (detect), and segmentation (segment); `YOLOv8, YOLO11, YOLO26` support five tasks: classification (classify), detection (detect), segmentation (segment), rotated object detection (obb), and keypoint detection;
- Supports two inference modes, including image and video stream;
- Supports three display modes, including `LT9611 (hdmi,1920×1080)`, `ST7701 (lcd screen,800×480)`, `HX8377 (lcd screen,1920×1080)`;

- **Parameter Description**

| Parameter Name           | Default Value    | Description                                                                                                                          |
|--------------------------|------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| `-ai_frame_width`        | 640              | Sets the width of the AI frame, with a default value of 640. You can choose the value to use yourself.                                    |
| `-ai_frame_height`       | 360              | Sets the height of the AI frame, with a default value of 360. You can choose the value to use yourself.                                   |
| `-display_mode`          | 0                | Sets the display mode, with a default value of 0:<br> - Mode 0: LT9611 <br> - Mode 1: ST7701 <br> - Mode 2: HX8377                   |
| `-model_type`            | yolov8           | Sets the model type, with a default value of yolov8. Optional values: yolov5/yolov8/yolo11/yolo26.                                   |
| `-task_type`             | detect           | Sets the task type, with a default value of detect. Optional values: classify/detect/segment/obb/pose.                                |
| `-task_mode`             | video            | Sets the task mode, with a default value of video. Optional values: image/video                                                      |
| `-image_path`            | test.jpg         | Sets the image path, with a default value of test.jpg.                                                                               |
| `-kmodel_path`           | yolov8n.kmodel   | Sets the kmodel path, with a default value of yolov8n.kmodel.                                                                        |
| `-labels_txt_filepath`   | coco_labels.txt  | Sets the label text file path, with a default value of coco_labels.txt. Each label occupies one line.                                |
| `-conf_thres`            | 0.35             | Sets the confidence threshold, with a default value of 0.35.                                                                          |
| `-nms_thres`             | 0.65             | Sets the non-maximum suppression threshold, with a default value of 0.65.                                                             |
| `-mask_thres`            | 0.5              | Sets the mask threshold, with a default value of 0.5. Task-specific parameter for segmentation.                                       |
| `-kp_num`                | 17               | Sets the number of keypoints, with a default value of 17 (human skeleton keypoint scenario).                                         |
| `-kp_dim`                | 3                | Sets the model keypoint dimension, only 2/3 are supported, with a default value of 3 (human skeleton keypoint scenario).              |
| `-debug_mode`            | 0                | Sets the debug mode, with a default value of 0. Optional values: 0/1, 0 means no debugging, 1 means debug printing.                  |

##### Deploying the Model to Implement Image Inference

For image inference, please refer to the following command, **modify the parameters according to the actual situation**;

```shell
./yolo.elf -model_type yolov5 -task_type classify -task_mode image -image_path test.jpg -kmodel_path yolov5n_cat_dog_cls.kmodel -labels_txt_filepath cat_dog_labels.txt -conf_thres 0.5 -debug_mode 0
```

##### Deploying the Model to Implement Video Inference

For video inference, please refer to the following command, **modify the parameters according to the actual situation**;

```shell
./yolo.elf -ai_frame_width 640 -ai_frame_height 360 -display_mode 0 -model_type yolov5 -task_type classify -task_mode video -kmodel_path yolov5n_cat_dog_cls.kmodel -labels_txt_filepath cat_dog_labels.txt -conf_thres 0.5 -debug_mode 0
```

##### Deployment Effect

Select two pictures of cats and dogs and use kmodel for classification. The effect is shown in the figure below:

![cat_dog_cls_res](https://www.kendryte.com/api/post/attachment?id=646)

<a id="yolov8-fall-detection"></a>

### YOLOv8 Fall Detection

Deploy a fall detection model based on the YOLOv8 model on the K230.

#### YOLOv8 Source Code and Training Environment Setup

For setting up the `YOLOv8` training environment, please refer to [ultralytics/ultralytics: Ultralytics YOLO 🚀 (github.com)](https://github.com/ultralytics/ultralytics)

```shell
# Pip install the ultralytics package including all requirements in a Python>=3.8 environment with PyTorch>=1.8.
pip install ultralytics
```

If you have already set up the environment, please ignore this step.

#### Training Data Preparation

Download the provided fall detection dataset and extract it.

```shell
cd yolov8
wget https://download.kendryte.com/developer/k230/yolo_dataset/fall_det.zip
unzip fall_det.zip
```

⚠️ **For Windows systems, please copy the link directly to the browser to download, and extract it to the corresponding directory**.

If you have already downloaded the data, please ignore this step.

#### Training the Fall Detection Model Using YOLOv8

Execute the following command in the `yolov8` directory to train the fall detection model using `yolov8`:

```shell
yolo detect train data=fall_det.yaml model=yolov8n.pt epochs=300 imgsz=320
```

#### Converting the Fall Detection kmodel

Model conversion requires installing the following libraries in the training environment:

```Shell
# linux platform: nncase and nncase-kpu can be installed online, nncase-2.x requires dotnet-7 installation
sudo apt-get install -y dotnet-sdk-7.0
pip install --upgrade pip
pip install nncase==2.11.0
pip install nncase-kpu==2.11.0

# windows platform: please install dotnet-7 yourself and add environment variables. pip online installation of nncase is supported, but the nncase-kpu library needs to be installed offline. Download nncase_kpu-2.*-py2.py3-none-win_amd64.whl from https://github.com/kendryte/nncase/releases
# Enter the corresponding python environment, and use pip to install in the directory where nncase_kpu-2.*-py2.py3-none-win_amd64.whl is downloaded
pip install nncase_kpu-2.*-py2.py3-none-win_amd64.whl

# In addition to nncase and nncase-kpu, other libraries used by the script include:
pip install onnx==1.15.0
pip install onnxruntime==1.19.0
pip install onnxsim==0.4.36
```

Download the script tool and extract the model conversion script tool `test_yolov8.zip` to the `yolov8` directory;

```shell
wget https://download.kendryte.com/developer/k230/yolo_files/test_yolov8.zip
unzip test_yolov8.zip
```

Follow the commands below to first export the `pt` model under `runs/detect/train/weights` to an `onnx` model, and then convert it to a `kmodel` model:

```shell
# Export onnx, please choose the pt model path yourself
yolo export model=runs/detect/train/weights/best.pt format=onnx imgsz=320
cd test_yolov8/detect
# Replace the images in the test directory with part of your own training data, convert kmodel, please choose the onnx model path yourself, the generated kmodel will be in the same level directory as the onnx model
python to_kmodel.py --target k230 --model ../../runs/detect/train/weights/best.onnx --dataset ../test --input_width 320 --input_height 320 --ptq_option 1
cd ../../
```

💡 **Model conversion script (to_kmodel.py) parameter description**:

| Parameter Name | Description | Explanation                                                                                                                                                                                                                                                                                            | Type     |
|----------------|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| target         | Target Platform | Options are k230/cpu, corresponding to k230 kpu and cpu;                                                                                                                                                                                                                                              | str      |
| model          | Model Path  | The path of the ONNX model to be converted;                                                                                                                                                                                                                                                            | str      |
| dataset        | Calibration Image Set | Image data used for model conversion, used in the quantization stage. You can replace part of the images from the training set.                                                                                                                                                                       | str      |
| input_width    | Input Width | The width of the model input                                                                                                                                                                                                                                                                            | int      |
| input_height   | Input Height | The height of the model input                                                                                                                                                                                                                                                                          | int      |
| ptq_option     | Quantization Method | The quantization strategies are `Kld` and `NoClip`, combined with data and weights quantization precision. 0 is `NoClip`+[uint8,uint8], 1 is `NoClip`+[uint8,int16], 2 is `NoClip`+[int16,uint8], 3 is `Kld`+[uint8,uint8], 4 is `Kld`+[uint8,int16], 5 is `Kld`+[int16,uint8]                                  | 0/1/2/3/4/5 |

#### Deploying the Model on k230 Using RT-Smart

##### Setting Up the Build Environment

💡 **Firmware Introduction**: Please follow the steps in the document below to set up the build environment and compile the firmware to ensure that the **latest features** are supported! See the documentation tutorial: [Firmware Compilation](./userguide/how_to_build.md).

##### yolo Compilation

Go to the `src/rtsmart/examples/ai/yolo` directory and execute `build_app.sh`. The compiled firmware is generated in the `k230_bin` directory.

##### Model File Copy

After the firmware is flashed on the development board and powered on, you can find the virtual U disk `CanMV` on the disk. The disk is divided into two partitions: `/sdcard` and `/data`. Copy the converted `kmodel`, the compiled executable `elf file`, as well as test images and label files (txt format, each line represents one class) to a directory on the development board.

##### YOLO Module

The `YOLO` module is a deployment code developed based on the `YOLO series models`, which implements the deployment process of such models. Its supported situations are as follows:

- Integrates four models: `YOLOv5, YOLOv8, YOLO11, YOLO26`;
- Supports four types of tasks. Among them, `YOLOv5` supports three types: classify, detect, and segment. `YOLOv8, YOLO11, YOLO26` support five types of tasks: classify, detect, segment, oriented object detection (obb), and keypoint detection;
- Supports two inference modes, including image and video stream;
- Supports three display modes, including `LT9611 (hdmi,1920×1080)`, `ST7701 (lcd screen,800×480)`, `HX8377 (lcd screen,1920×1080)`;

- **Parameter Description**

| Parameter Name         | Default Value   | Description                                                                                              |
|------------------------|-----------------|----------------------------------------------------------------------------------------------------------|
| `-ai_frame_width`      | 640             | Set the AI frame width, the default value is 640, you can choose the value you use.                       |
| `-ai_frame_height`     | 360             | Set the AI frame height, the default value is 360, you can choose the value you use.                      |
| `-display_mode`        | 0               | Set the display mode, the default value is 0:<br> - Mode 0: LT9611 <br> - Mode 1: ST7701 <br> - Mode 2: HX8377 |
| `-model_type`          | yolov8          | Set the model type, the default value is yolov8, optional values: yolov5/yolov8/yolo11/yolo26.            |
| `-task_type`           | detect          | Set the task type, the default value is detect, optional values: classify/detect/segment/obb/pose.         |
| `-task_mode`           | video           | Set the task mode, the default value is video, optional values: image/video                               |
| `-image_path`          | test.jpg        | Set the image path, the default value is test.jpg.                                                        |
| `-kmodel_path`         | yolov8n.kmodel  | Set the kmodel path, the default value is yolov8n.kmodel.                                                 |
| `-labels_txt_filepath` | coco_labels.txt | Set the label text file path, the default value is coco_labels.txt, each label occupies one line.          |
| `-conf_thres`          | 0.35            | Set the confidence threshold, the default value is 0.35.                                                  |
| `-nms_thres`           | 0.65            | Set the non-maximum suppression threshold, the default value is 0.65.                                     |
| `-mask_thres`          | 0.5             | Set the mask threshold, the default value is 0.5, a specific parameter for the segmentation task.         |
| `-kp_num`              | 17              | Set the number of keypoints, the default value is 17 (human skeleton keypoint scenario).                  |
| `-kp_dim`              | 3               | Set the keypoint dimension of the model, only 2/3 is supported, the default value is 3 (human skeleton keypoint scenario). |
| `-debug_mode`          | 0               | Set the debug mode, the default value is 0, optional values: 0/1, 0 is no debugging, 1 is debugging print. |

##### Deploying the Model to Implement Image Inference

For image inference, please refer to the following command, **modify the parameters according to the actual situation**;

```shell
./yolo.elf -model_type yolov8 -task_type detect -task_mode image -image_path test.jpg -kmodel_path yolov8n_fall_det.kmodel -labels_txt_filepath fall_labels.txt -conf_thres 0.5 -nms_thres 0.45 -debug_mode 0
```

##### Deploying the Model to Implement Video Inference

For video inference, please refer to the following command, **modify the parameters according to the actual situation**;

```shell
./yolo.elf -ai_frame_width 640 -ai_frame_height 360 -display_mode 0 -model_type yolov8 -task_type detect -task_mode video -kmodel_path yolov8n_fall_det.kmodel -labels_txt_filepath fall_labels.txt -conf_thres 0.5 -nms_thres 0.45 -debug_mode 0
```

##### Deployment Effect

Select a fall image to perform fall detection using kmodel. The comparison between the original image and the inference result is shown in the figure below:

![fall_det_res](https://www.kendryte.com/api/post/attachment?id=647)

### YOLO11 Fruit Segmentation

#### YOLO11 Source Code and Training Environment Setup

For `YOLO11` training environment setup, please refer to [ultralytics/ultralytics: Ultralytics YOLO 🚀 (github.com)](https://github.com/ultralytics/ultralytics)

```shell
# Pip install the ultralytics package including all requirements in a Python>=3.8 environment with PyTorch>=1.8.
pip install ultralytics
```

If you have already set up the environment, please ignore this step.

#### Training Data Preparation

Download the provided fruit segmentation dataset and extract it.

```shell
cd yolo11
wget https://download.kendryte.com/developer/k230/yolo_dataset/fruit_seg.zip
unzip fruit_seg.zip
```

⚠️ **For Windows systems, please copy the link directly to the browser to download, and extract it to the corresponding directory**.

If you have already downloaded the data, please ignore this step.

#### Using YOLO11 to Train the Fruit Segmentation Model

Execute the command in the `yolo11` directory, using `yolo11` to train a three-class fruit segmentation model:

```shell
yolo segment train data=fruits_seg.yaml model=yolo11n-seg.pt epochs=100 imgsz=320
```

#### Converting Fruit Segmentation kmodel

Model conversion requires the following libraries to be installed in the training environment:

```Shell
# linux platform: nncase and nncase-kpu can be installed online, nncase-2.x requires installing dotnet-7
sudo apt-get install -y dotnet-sdk-7.0
pip install --upgrade pip
pip install nncase==2.11.0
pip install nncase-kpu==2.11.0

# windows platform: please install dotnet-7 by yourself and add environment variables. nncase can be installed online using pip, but the nncase-kpu library needs to be installed offline. Download nncase_kpu-2.*-py2.py3-none-win_amd64.whl from https://github.com/kendryte/nncase/releases
# Enter the corresponding python environment, and use pip to install in the directory where nncase_kpu-2.*-py2.py3-none-win_amd64.whl is downloaded
pip install nncase_kpu-2.*-py2.py3-none-win_amd64.whl

# In addition to nncase and nncase-kpu, other libraries used by the script include:
pip install onnx==1.15.0
pip install onnxruntime==1.19.0
pip install onnxsim==0.4.36
```

Download the script tool, and extract the model conversion script tool `test_yolo11.zip` to the `yolo11` directory;

```shell
wget https://download.kendryte.com/developer/k230/yolo_files/test_yolo11.zip
unzip test_yolo11.zip
```

Follow the commands below to first export the `pt` model under `runs/segment/train/weights` to an `onnx` model, and then convert it to a `kmodel` model:

```shell
# Export onnx, please choose the pt model path by yourself
yolo export model=runs/segment/train/weights/best.pt format=onnx imgsz=320
cd test_yolo11/segment
# The images in test can be selected from the training set and replaced. Convert kmodel, please choose the onnx model path by yourself. The generated kmodel is in the same directory as the onnx model
python to_kmodel.py --target k230 --model ../../runs/segment/train/weights/best.onnx --dataset ../test --input_width 320 --input_height 320 --ptq_option 1
cd ../../
```

💡 **Model conversion script (to_kmodel.py) parameter description**:

| Parameter Name | Description | Explanation | Type |
| ------------ | -------- | ------------------------------------------------------------| ----- |
| target       | Target Platform | The options are k230/cpu, corresponding to k230 kpu and cpu;                              | str   |
| model        | Model Path | The path of the ONNX model to be converted;                                        | str   |
| dataset      | Calibration Image Set  | The image data used during model conversion, used in the quantization stage, can be taken from the training set and replaced                    | str   |
| input_width  | Input Width | The width of the model input                                             | int   |
| input_height | Input Height | The height of the model input                                             | int   |
| ptq_option   | Quantization Method | The quantization strategies are `Kld` and `NoClip`, combined with data and weights quantization accuracy, 0 is `NoClip`+[uint8,uint8], 1 is `NoClip`+[uint8,int16], 2 is `NoClip`+[int16,uint8], 3 is `Kld`+[uint8,uint8], 4 is `Kld`+[uint8,int16], 5 is `Kld`+[int16,uint8] | 0/1/2/3/4/5 |

#### Deploying the Model on k230 Using RT-Smart

##### Setting Up the Compilation Environment

💡 **Firmware Introduction**: Please follow the steps in the documentation below to set up the compilation environment and compile the firmware to ensure that the **latest features** are supported! For the documentation tutorial, see: [Firmware Compilation](./userguide/how_to_build.md).

##### YOLO Compilation

Enter the `src/rtsmart/examples/ai/yolo` directory and execute `build_app.sh`. The compiled firmware is in the `k230_bin` directory.

##### Copying Model Files

After the development board is flashed with firmware and powered on, you can find the virtual U disk `CanMV` at the disk location. The disk is divided into two partitions: `/sdcard` and `/data`. Copy the converted `kmodel`, the compiled executable `elf file`, test images, and label file (txt format, with each line representing one class) to a certain directory on the development board.

##### YOLO Module

The `YOLO` module is a deployment code developed based on the `YOLO series models`, implementing the deployment process of such models. The supported situations are as follows:

- Integrates four types of models: `YOLOv5, YOLOv8, YOLO11, YOLO26`;
- Supports four types of tasks, among which `YOLOv5` supports three types: classify, detect, and segment; `YOLOv8, YOLO11, YOLO26` support five types of tasks: classify, detect, segment, oriented object detection (obb), and keypoint detection;
- Supports two inference modes, including image and video stream (video);
- Supports three display modes, including `LT9611 (hdmi,1920×1080)`, `ST7701 (lcd screen,800×480)`, `HX8377 (lcd screen,1920×1080)`;

- **Parameter Description**

| Parameter Name               | Default Value          | Description                                                                 |
|------------------------|----------------|----------------------------------------------------------------------|
| `-ai_frame_width`      | 640            | Set the width of the AI frame, the default value is 640, you can choose the value to use by yourself.                                      |
| `-ai_frame_height`     | 360            | Set the height of the AI frame, the default value is 360, you can choose the value to use by yourself.                                      |
| `-display_mode`        | 0              | Set the display mode, the default value is 0:<br> - Mode 0: LT9611 <br> - Mode 1: ST7701 <br> - Mode 2: HX8377 |
| `-model_type`          | yolov8         | Set the model type, the default value is yolov8, optional values: yolov5/yolov8/yolo11/yolo26.          |
| `-task_type`           | detect         | Set the task type, the default value is detect, optional values: classify/detect/segment/obb/pose.       |
| `-task_mode`           | video          | Set the task mode, the default value is video, optional values: image/video |
| `-image_path`          | test.jpg       | Set the image path, the default value is test.jpg.                                      |
| `-kmodel_path`         | yolov8n.kmodel | Set the kmodel path, the default value is yolov8n.kmodel.                            |
| `-labels_txt_filepath` | coco_labels.txt| Set the label text file path, the default value is coco_labels.txt, each label occupies a separate line.                        |
| `-conf_thres`          | 0.35           | Set the confidence threshold, the default value is 0.35.                                        |
| `-nms_thres`           | 0.65           | Set the non-maximum suppression threshold, the default value is 0.65.                                  |
| `-mask_thres`          | 0.5            | Set the mask threshold, the default value is 0.5, a parameter specific to the segmentation task.                          |
| `-kp_num`              | 17             | Set the number of keypoints, the default value is 17 (human body skeleton keypoint scenario).                       |
| `-kp_dim`              | 3               | Set the model keypoint dimension, only 2/3 is supported, the default value is 3 (human body skeleton keypoint scenario).       |
| `-debug_mode`          | 0              | Set the debug mode, the default value is 0, optional values: 0/1, 0 means no debugging, 1 means debug printing.             |

##### Deploying the Model for Image Inference

For image inference, please refer to the following command, **modify the parameters according to the actual situation**;

```shell
./yolo.elf -model_type yolo11 -task_type segment -task_mode image -image_path test.jpg -kmodel_path yolo11n_fruit_seg.kmodel -labels_txt_filepath fruit_labels.txt -conf_thres 0.5 -nms_thres 0.45 -mask_thres 0.5 -debug_mode 0
```

##### Deploying the Model for Video Inference

For video inference, please refer to the following command, **modify the parameters according to the actual situation**;

```shell
./yolo.elf -ai_frame_width 640 -ai_frame_height 360 -display_mode 0 -model_type yolo11 -task_type segment -task_mode video -kmodel_path yolo11n_fruit_seg.kmodel -labels_txt_filepath fruit_labels.txt -conf_thres 0.5 -nms_thres 0.45 -mask_thres 0.5 -debug_mode 0
```

##### Deployment Effect

Select a fruit image and use kmodel for fruit segmentation. The comparison between the original image and the inference result is shown in the figure below:

![fruit_seg_res](https://www.kendryte.com/api/post/attachment?id=648)

### YOLO11 Rotated Object Detection

#### YOLO11 Source Code and Training Environment Setup

For setting up the `YOLO11` training environment, please refer to [ultralytics/ultralytics: Ultralytics YOLO 🚀 (github.com)](https://github.com/ultralytics/ultralytics)

```shell
# Pip install the ultralytics package including all requirements in a Python>=3.8 environment with PyTorch>=1.8.
pip install ultralytics
```

If you have already set up the environment, please ignore this step.

#### Training Data Preparation

Download the desktop pen rotated object detection dataset and extract it.

```shell
cd yolo11
wget https://download.kendryte.com/developer/k230/yolo_dataset/pen_obb.zip
unzip pen_obb.zip
```

⚠️ **For Windows systems, please copy the link directly to the browser to download, and extract it to the corresponding directory**.

If you have already downloaded the data, please ignore this step.

#### Using the YOLO11 Rotated Object Detection Model

Run the following command in the `yolo11` directory to use `yolo11` to train a single-class rotated object detection model:

```shell
yolo obb train data=pen_obb.yaml model=yolo11n-obb.pt epochs=100 imgsz=320
```

#### Converting Rotated Object Detection kmodel

Model conversion requires installing the following libraries in the training environment:

```Shell
# linux platform: nncase and nncase-kpu can be installed online, nncase-2.x requires dotnet-7 installation
sudo apt-get install -y dotnet-sdk-7.0
pip install --upgrade pip
pip install nncase==2.11.0
pip install nncase-kpu==2.11.0

# windows platform: please install dotnet-7 by yourself and add environment variables. pip online installation of nncase is supported, but the nncase-kpu library needs to be installed offline. Download nncase_kpu-2.*-py2.py3-none-win_amd64.whl at https://github.com/kendryte/nncase/releases
# Enter the corresponding python environment, and use pip to install in the directory where nncase_kpu-2.*-py2.py3-none-win_amd64.whl is downloaded
pip install nncase_kpu-2.*-py2.py3-none-win_amd64.whl

# In addition to nncase and nncase-kpu, other libraries used by the script include:
pip install onnx==1.15.0
pip install onnxruntime==1.19.0
pip install onnxsim==0.4.36
```

Download the script tool and extract the model conversion script tool `test_yolo11.zip` into the `yolo11` directory;

```shell
wget https://download.kendryte.com/developer/k230/yolo_files/test_yolo11.zip
unzip test_yolo11.zip
```

Follow the commands below to first export the `pt` model under `runs/obb/train/weights` to an `onnx` model, and then convert it to a `kmodel` model:

```shell
# Export onnx, please choose the pt model path by yourself
yolo export model=runs/obb/train/weights/best.pt format=onnx imgsz=320
cd test_yolo11/obb
# The images under test can be selected from the training set to replace. To convert kmodel, please choose the onnx model path by yourself. The generated kmodel is in the same directory as the onnx model
python to_kmodel.py --target k230 --model ../../runs/obb/train/weights/best.onnx --dataset ../test_obb --input_width 320 --input_height 320 --ptq_option 0
cd ../../
```

💡 **Model conversion script (to_kmodel.py) parameter description**:

| Parameter Name | Description | Explanation                                                                                                                                                                                                                                                                                                              | Type      |
| -------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------- |
| target         | Target Platform | Options are k230/cpu, corresponding to k230 kpu and cpu;                                                                                                                                                                                                                                                          | str       |
| model          | Model Path | Path of the ONNX model to be converted;                                                                                                                                                                                                                                                                              | str       |
| dataset        | Calibration Image Set | Image data used during model conversion, used in the quantization stage, can be replaced by selecting part of the training set                                                                                                                                                                                | str       |
| input_width    | Input Width | Width of the model input                                                                                                                                                                                                                                                                                            | int       |
| input_height   | Input Height | Height of the model input                                                                                                                                                                                                                                                                                           | int       |
| ptq_option     | Quantization Method | Quantization strategies are `Kld` and `NoClip`, combining data and weights quantization accuracy. 0 is `NoClip`+[uint8,uint8], 1 is `NoClip`+[uint8,int16], 2 is `NoClip`+[int16,uint8], 3 is `Kld`+[uint8,uint8], 4 is `Kld`+[uint8,int16], 5 is `Kld`+[int16,uint8] | 0/1/2/3/4/5 |

#### Deploying the Model on k230 using RT-Smart

##### Building the Compilation Environment

💡 **Firmware Introduction**: Please follow the steps in the document below to build the compilation environment and compile the firmware to ensure that **the latest features** are supported! The document tutorial is at: [Firmware Compilation](./userguide/how_to_build.md).

##### yolo Compilation

Enter the `src/rtsmart/examples/ai/yolo` directory and execute `build_app.sh`. The compiled firmware is generated in the `k230_bin` directory.

##### Model File Copy

After the development board is flashed with the firmware and powered on, you can find the virtual U-disk `CanMV` in the disk. The disk is divided into two partitions: `/sdcard` and `/data`. Copy the converted `kmodel`, the compiled executable `elf file`, test images, and label file (txt format, each line represents one class) to a directory on the development board.

##### YOLO Module

The `YOLO` module is the deployment code developed based on the `YOLO series models`, implementing the deployment process of such models. Its supported scenarios are as follows:

- Integrates four types of models: `YOLOv5, YOLOv8, YOLO11, YOLO26`;
- Supports four types of tasks, among which `YOLOv5` supports classification (classify), detection (detect), and segmentation (segment); `YOLOv8, YOLO11, YOLO26` support five types of tasks: classification (classify), detection (detect), segmentation (segment), rotated object detection (obb), and keypoint detection;
- Supports two inference modes, including image (image) and video stream (video);
- Supports three display modes, including `LT9611 (hdmi, 1920×1080)`, `ST7701 (lcd screen, 800×480)`, `HX8377 (lcd screen, 1920×1080)`;

- **Parameter Description**

| Parameter Name         | Default Value    | Description                                                                                                                                  |
|------------------------|------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `-ai_frame_width`      | 640              | Set the width of the AI frame, the default value is 640, you can choose the value to use by yourself.                                         |
| `-ai_frame_height`     | 360              | Set the height of the AI frame, the default value is 360, you can choose the value to use by yourself.                                        |
| `-display_mode`        | 0                | Set the display mode, the default value is 0:<br> - Mode 0: LT9611 <br> - Mode 1: ST7701 <br> - Mode 2: HX8377                            |
| `-model_type`          | yolov8           | Set the model type, the default value is yolov8, optional values: yolov5/yolov8/yolo11/yolo26.                                              |
| `-task_type`           | detect           | Set the task type, the default value is detect, optional values: classify/detect/segment/obb/pose.                                           |
| `-task_mode`           | video            | Set the task mode, the default value is video, optional values: image/video                                                                 |
| `-image_path`          | test.jpg         | Set the image path, the default value is test.jpg.                                                                                          |
| `-kmodel_path`         | yolov8n.kmodel   | Set the kmodel path, the default value is yolov8n.kmodel.                                                                                   |
| `-labels_txt_filepath` | coco_labels.txt  | Set the label text file path, the default value is coco_labels.txt, each label occupies one line.                                            |
| `-conf_thres`          | 0.35             | Set the confidence threshold, the default value is 0.35.                                                                                    |
| `-nms_thres`           | 0.65             | Set the non-maximum suppression threshold, the default value is 0.65.                                                                        |
| `-mask_thres`          | 0.5              | Set the mask threshold, the default value is 0.5, a parameter specific to the segmentation task.                                            |
| `-kp_num`              | 17               | Set the number of keypoints, the default value is 17 (for human skeletal keypoint scenarios).                                               |
| `-kp_dim`              | 3                | Set the model keypoint dimension, only 2/3 is supported, the default value is 3 (for human skeletal keypoint scenarios).                   |
| `-debug_mode`          | 0                | Set the debug mode, the default value is 0, optional values: 0/1, 0 is no debugging, 1 is debugging print.                                 |

##### Deploying the Model for Image Inference

For image inference, please refer to the following command, **modify the parameters according to the actual situation**;

```shell
./yolo.elf -model_type yolo11 -task_type obb -task_mode image -image_path test.jpg -kmodel_path yolo11n_pen_obb.kmodel -labels_txt_filepath pen_labels.txt -conf_thres 0.5 -nms_thres 0.45 -debug_mode 0
```

##### Deploying the Model for Video Inference

For video inference, please refer to the following command, **modify the parameters according to the actual situation**;

```shell
./yolo.elf -ai_frame_width 640 -ai_frame_height 360 -display_mode 0 -model_type yolo11 -task_type obb -task_mode video -kmodel_path yolo11n_pen_obb.kmodel -labels_txt_filepath pen_labels.txt -conf_thres 0.5 -nms_thres 0.45 -debug_mode 0
```

##### Deployment Effect

Select a desktop pen image and use the kmodel for rotated object detection. The comparison between the original image and the inference result is shown below:

![pen_obb_res](https://www.kendryte.com/api/post/attachment?id=649)

## Auxiliary Tools

### Online Training Platform

#### Introduction to Cloud Training Platform

The Canaan Developer Community model training feature is a training platform opened to simplify the development process and improve development efficiency. This platform enables users to focus on the implementation of visual scenarios, more quickly complete the process from data annotation to obtaining the KModel in the deployment package, and deploy it on the K230 and K230D chip development boards equipped with Canaan Technology's Kendryte® series AIoT chips. Users only need to upload the dataset and simply configure the parameters to start training.

![plat](https://www.kendryte.com/api/post/attachment?id=600)

📌Platform address: **[Canaan Cloud Training Platform](https://www.kendryte.com/zh/training/start)**

📌Platform usage documentation reference: **[Canaan Cloud Training Platform Documentation Tutorial](https://www.kendryte.com/web/CloudPlatDoc.html)**, please pay attention to the format of the dataset!

#### Supported Tasks Introduction

The cloud training platform supports 7 visual tasks for the K230 series chips. The task introduction is as follows:

💡 **Task Introduction**:

| Task Name | Task Description |
| ----- | --------------------------------------------------------------------------------------------------------------------- |
| Image Classification | Classify images, obtain the category result and score of the image. |
| Image Detection | Detect target objects in images, and provide the location information, category information, and score of the objects. |
| Semantic Segmentation | Segment the target regions in the image, cut out different label regions in the image, which is a pixel-level task. |
| OCR Detection | Detect text regions in images, and provide the location information of text regions. |
| OCR Recognition | Recognize text content in images. |
| Metric Learning | Train a model that can feature-ize images, use the model to create a feature library, and classify new categories without retraining the model through feature comparison, also known as self-learning. |
| Multi-label Classification | Perform multi-category classification on images. Some images may not only belong to a single category. Sky and sea can exist simultaneously, obtaining the multi-label classification result of the image. |

#### Deployment Steps

##### Deployment Package Description

After training is complete, the deployment package corresponding to the training task can be downloaded. After the downloaded deployment zip package is decompressed, the directory is as follows:

```shell
📦 task_name
├── 📁 **_result
│   ├── test_0.jpg
│   ├── test_1.jpg
│   └──...
├── mp_deployment_source
├── **_image_1_2_2.py
├── **_image_1_3.py
├── **_video_1_2_2.py
├── **_video_1_3.py
└── README.pdf
```

The content is shown in the figure:

![Deployment Package](https://www.kendryte.com/api/post/attachment?id=657)

Among them, `mp_deployment_source` is the code package deployed on the K230 image, which internally contains the deployment configuration file and the deployed KModel. Note: The configuration file `deploy_config.json` and `***.kmodel` generated by the platform are the keys to deployment on k230, and they are available in various SDKs.

##### File Copying

✅ **Firmware Selection**: Please refer to the steps in the following document to set up the compilation environment and compile the firmware to ensure that **the latest features** are supported! For the documentation tutorial, see: [Firmware Compilation](./userguide/how_to_build.md).

✅ **Firmware Flashing**: Flash the firmware according to the development board type, firmware flashing reference: [Firmware Flashing](./userguide/how_to_flash.md).

✅ **Deployment Code**: The deployment code is located at `rtos_sdk/src/rtsmart/examples/ai/cloudplat_deploy_code` in the compilation environment. You need to enter this directory to execute `./build_app.sh` to complete the compilation. The compilation product is located in the `k230_bin` directory. For the usage method, refer to the `README.md` in this directory.

##### Script Execution

**Parameter Configuration**:

You can configure parameters in `setting.h` in `common_files`. The analysis of parameter configuration is as follows, mainly used to configure screen display:

|Macro Definition Parameter|Description|
|:-:|:-:|
|`ISP_WIDTH`|ISP output width|
|`ISP_HEIGHT`|ISP output height|
|`DISPLAY_MODE`|Display mode, 0 is 1920×1080 LT9611, 1 is 800×480 ST7701|
|`DISPLAY_WIDTH`|Display screen width|
|`DISPLAY_HEIGHT`|Display screen height|
|`AI_FRAME_WIDTH`|AI inference frame width|
|`AI_FRAME_HEIGHT`|AI inference frame height|
|`AI_FRAME_CHANNEL`|Number of AI inference frame channels|
|`USE_OSD`|Whether to use OSD, 0 is not used, 1 is used|
|`OSD_WIDTH`|OSD layer width, used to display AI inference results|
|`OSD_HEIGHT`|OSD layer height, used to display AI inference results|
|`OSD_CHANNEL`|Number of OSD layer channels|

**Source Code Compilation**:

Enter the `src/rtsmart/examples/ai/cloudplat_deploy_code` directory

```shell
# Enter directory
cd cloudplat_deploy_code

# Compile file, all task compiled elf files will be obtained in the k230_bin directory
./build_app.sh

# If you only want to compile the deployment file of a certain task, you can use ./build.sh <task name>
./build_app.sh classification
./build_app.sh detection
...
```

The compilation product is in the `k230_bin` directory.

**On-board Deployment**:

Copy the obtained `elf files`, font files, and the `kmodel`, `deploy_config.json` obtained from the Canaan training platform, and test images to a certain directory on the development board, and run the command:

```shell
# Classification - Video inference, enter `q` and press Enter to exit video inference
./classification.elf deploy_config.json None 0

# Classification - Image inference
./classification.elf deploy_config.json test.jpg 0

# Detection - Video inference, enter `q` and press Enter to exit video inference
./detection.elf deploy_config.json None 0

# Detection - Image inference
./detection.elf deploy_config.json test.jpg 0

# Semantic Segmentation - Video inference, enter `q` and press Enter to exit video inference
./segmentation.elf deploy_config.json None 0

# Semantic Segmentation - Image inference
./segmentation.elf deploy_config.json test.jpg 0

# OCR Detection - Video inference, enter `q` and press Enter to exit video inference
./ocr_detection.elf deploy_config.json None 0

# OCR Detection - Image inference
./ocr_detection.elf deploy_config.json test.jpg 0

# OCR Recognition - Image inference, this task only supports image inference
./ocr_recognition.elf deploy_config.json test.jpg 0

# OCR - Video inference, enter `q` and press Enter to exit video inference
./ocr.elf ocrdet_deploy_config.json ocrrec_deploy_config.json None 0

# OCR - Image inference
./ocr.elf ocrdet_deploy_config.json ocrrec_deploy_config.json test.jpg 0

# Metric Learning - Video inference, enter `q` and press Enter to exit video inference
./metric_learning.elf deploy_config.json None 0

# Metric Learning - Image inference
./metric_learning.elf deploy_config.json test.jpg 0

# Multi-label Classification - Video inference, enter `q` and press Enter to exit video inference
./multilabel_classification.elf deploy_config.json None 0

# Multi-label Classification - Image inference
./multilabel_classification.elf deploy_config.json test.jpg 0
```

##### Deployment Instructions

- 📢 If the effect is not ideal when deploying the model, first adjust the threshold of the corresponding task and the resolution of the inference image to test whether the result can be improved!

- 📢 Learn to locate the problem, for example, check the test images in the `**_results` directory in the deployment package. If the image is normal, it may be a problem with the deployment code, model conversion, or threshold!

- 📢 Adjust the parameters of model training, such as `epoch`, `learning_rate`, etc., to prevent insufficient training!

### AICube

#### AICube Introduction

AICube is an offline training tool provided by Canaan for developers. This platform ensures data security and enables visualized local training. The platform supports 8 tasks: image classification, object detection, semantic segmentation, OCR detection, OCR recognition, metric learning, multi-label classification, and anomaly detection. Compared to online training platforms, it allows users to leverage local GPUs for model training and convert the model into kmodel for deployment on the K230.

#### Environment Preparation and Software Installation

Before installing AICube, please check whether the following prerequisites are met:

- A device with an NVIDIA GPU, recommended with 8GB or more of video memory;

- CUDA 11.7 or above has been installed on the computer, and CUDNN has been installed;

- dotnet 7.0 has been installed on the computer, and the installation path has been added to the environment variables;

- Recommended computer memory of 8GB or more, with at least 20GB of free hard disk space;

If your computer meets the above conditions, you can download AICube and extract it for use. AICube provides installation packages for Ubuntu and Windows. Because the installation package contains the bundled **torch training environment, multiple pre-trained models, and example datasets**, the package is large. **Please download it in a suitable network environment.** The download link is available at: [AICube Download](https://www.kendryte.com/zh/resource?selected=4-2). For usage steps, please refer to the user guide of the corresponding version.

📢 **Please select the latest version when downloading**.

#### Supported Tasks Introduction

AICube supports 8 visual tasks for the K230 series chips. The task descriptions are shown in the table below:

💡 **Task Introduction**:

| Task Name | Task Description |
| ----- | --------------------------------------------------------------------------------------------------------------------- |
| Image Classification | Classify images to obtain the category result and score of the image. |
| Object Detection | Detect target objects in the image, and provide the position information, category information, and score of the objects. |
| Semantic Segmentation | Segment the target regions in the image, cutting out different labeled regions in the image. This is a pixel-level task. |
| OCR Detection | Detect text regions in the image, and provide the position information of the text regions. |
| OCR Recognition | Recognize the text content in the image. |
| Metric Learning | Train a model that can featurize images, use the model to create a feature database, and classify new categories by feature comparison without retraining the model, also known as self-learning. |
| Multi-label Classification | Classify images into multiple categories. Some images may not belong to a single category; sky and sea can exist simultaneously, obtaining the multi-label classification result of the image. |
| Anomaly Detection | Used to detect anomalous categories in a certain type of product, commonly used in fields such as industrial quality inspection. |

#### Usage Instructions

##### Function Page Introduction

AI Cube contains 5 function pages. The "Project" page mainly implements project management functions, displaying the current project and recent projects; the "Images" page displays the dataset information of the current project, making it convenient for users to view the images in the dataset; the "Split" page displays the split information, statistics of split categories, and images of different split sets; the "Training" page implements training parameter configuration, training information, and training curve display; the "Evaluation" page implements model evaluation and evaluation information display, and can configure necessary deployment parameters to generate a deployment package.

🗂️ **Project Page** illustration:

![Project Page](https://www.kendryte.com/api/post/attachment?id=616)

🗂️ **Images Page** illustration:

![Images Page](https://www.kendryte.com/api/post/attachment?id=617)

🗂️ **Split Page** illustration:

![Split Page](https://www.kendryte.com/api/post/attachment?id=618)

🗂️ **Training Page** illustration:

![Training Page](https://www.kendryte.com/api/post/attachment?id=619)

🗂️ **Evaluation Page** illustration:

![Evaluation Page](https://www.kendryte.com/api/post/attachment?id=620)

##### Creating a Dataset

Organize the dataset according to the dataset format of different tasks. The corresponding dataset format can be viewed by clicking "New Project" on the `Project Page`. At the same time, we provide example datasets for different tasks in the `example_dataset` directory; and example projects created using these example datasets are located in the `example_projects` directory.

The corresponding relationships between the example datasets of different tasks and the example tasks are as follows:

| Dataset Name    | Example Task  | Description                          |
| --------------- | ------------- | ------------------------------------ |
| vegetable_cls   | Image Classification | Vegetable classification scenario     |
| insect          | Object Detection      | Insect detection scenario             |
| Ocular_lesions  | Semantic Segmentation | Eye lesion region segmentation scenario |
| dataset_td100   | OCR Detection         | OCR text detection scenario           |
| ProductionDate  | OCR Recognition       | Production date recognition scenario  |
| drink           | Metric Learning       | Beverage bottle classification scenario |
| multilabel2000  | Multi-label Classification | Natural scenery multi-label classification scenario |
| bottle          | Anomaly Detection     | Bottle mouth anomaly detection scenario |

You can use the example datasets we provide, or organize your own datasets according to the corresponding task format in the `New Project Interface`. Most of the problems encountered in AICube are data issues. We only check the directory structure of the dataset, and do not check the annotation information inside the data. Please handle the data carefully.

##### Creating a Project

Go to `Project Page` ---> Click the `New Project` button ---> Select the task type ---> Import the dataset ---> Select the project storage path ---> Add the project name ---> Create the project.

The new project interface is shown in the figure below:

![New Project](https://www.kendryte.com/api/post/attachment?id=621)

After the project is created, it will automatically jump to the `Images Page`, where you can view the details of your dataset. Go to the `Split Page`, where you can split the dataset according to a custom ratio and view the statistical information of the split set.

##### Starting Training

Go to the `Training Page` and configure **model, data augmentation, and training parameters** on the left side.

Analysis of common parameters:

| Platform Parameter Name | Common Parameter Definition | Parameter Meaning Analysis |
| ---------------- | ----------------------- | ------------------------------------------------------------ |
| Model            | model                   | Network models of different structures used to implement different tasks;                     |
| Backbone         | model backbone          | The feature extraction part of the network structure in the model, such as the model for detection and segmentation tasks;     |
| Pretrained       | pretrain                | Whether to load the pre-trained model provided by AICube;                             |
| Pretrained Model Language | pretrain language       | **OCR Recognition** specific task parameter, select the sample language for training the pre-trained model; ignore for other tasks;        |
| Model Size       | model size              | n, s, m, l, x, variants of the same model, the difference is the model size, used to balance accuracy and speed; |
| Model Width      | model width             | The larger the width, the larger the number of parameters;                                        |
| Image Size       | model input size        | Model input resolution, a single value indicates the input is [x,x], double values indicate the input is [x,y];    |
| ASPP Dilation Rate | ASPP dilation rate      | **Semantic Segmentation** specific task parameter, the scale of different dilated convolutions and pooling operations. Different dilation rates for dilated convolutions can expand the receptive field and obtain broader contextual information; |
| Embedding Length | embedding length        | **Metric Learning** specific task parameter, the vector length of the vectorized sample;             |
| Auto Augmentation | TrivialAugment          | Parameter-free single-image random automatic data augmentation;                                  |
| Other Data Augmentation Methods | —                       | Brightness, contrast, saturation, hue, sharpness enhancement, flip, rotation, random scaling, random cropping, perspective transform, Gaussian blur, histogram equalization, gray world algorithm, CutOut, Random Erasing, Mask; |
| Learning Rate    | learning rate           | Parameter of the optimization algorithm, the adjustment step size for each iteration;                         |
| Epoch            | epoch                   | An epoch is the process of training a neural network using all training samples once;          |
| Batch Size       | batchsize               | The number of samples used in each forward and backward propagation;                           |
| Optimizer        | optimizer               | The optimization function used when optimizing the network, such as SGD, Adam, etc.;              |
| AutoAnchor       | autoanchor              | Anchor box adaptation in object detection tasks;                                 |
| NMS Option       | nms option              | Non-maximum suppression option in object detection tasks to distinguish intra-class and inter-class;             |
| Confidence Threshold | confidience threshold   | Used to filter prediction box categories. Prediction boxes with a score below this threshold will be deleted;         |
| IOU Threshold    | IOU threshold           | Perform maximum value screening on multiple overlapping boxes, calculate the scores of all detection boxes, compare them with the highest-scoring detection box in turn, and detection boxes greater than this threshold are deleted; the Box threshold in OCR detection is similar; |
| Automatic Mixed Precision | AMP                     | Use different data precision for different layers to save video memory and improve computing speed;     |
| Exponential Moving Average | EMA                     | Smoothing method to prevent the influence of outliers, weights decay exponentially over time;             |
| Early Stopping   | Early Stopping          | A method to increase model generalization and prevent overfitting;                           |
| Warmup Strategy  | WarmUp                  | Operate the learning rate in the initial stage of training to make the model converge faster;          |
| Multi-Scale Training | MST                     | Train input images of different scales to improve the detection generalization of the detection model for objects of different sizes; |
| Loss Function    | loss function           | Used to evaluate the degree of difference between the model prediction value and the true value. The smaller the loss, the better the model performance; |
| Learning Rate Scheduler | learning rate scheduler | Learning rate adjustment strategy, dynamically adjust the learning rate during the training process to adapt to the gradient descent process, including StepLR, CosineAnnealingLR, LinearLR, MultiStepLR, etc.; |
| Loss Refresh Step | loss refresh step       | Interface Loss curve drawing frequency, in units of batch;                        |
| GPU Index        | gpu index               | GPU index;                                                 |

After configuring the corresponding parameters for different tasks, you can click the `Augmented Sample Button` to view some example samples after data augmentation; click `Learning Rate Curve` to view the learning rate changes caused by different learning rate strategies; click the `Start Training Button`, the training information will be displayed in the upper right panel, the loss curve and metric curve will be drawn in the middle; the prediction results of the example samples will be iteratively displayed in the lower right panel for each epoch. The interface during training is shown in the figure below:

![Training Process](https://www.kendryte.com/api/post/attachment?id=619)

##### Model Testing

Go to the `Evaluation Page`, select the trained model, and then select the test method. The test methods are as follows:

| Test Method       | Description                                                         |
| ------------ | ------------------------------------------------------------ |
| Test Set Test | Test and evaluate the test set obtained from the split, and output the test metric data;           |
| Additional Data Test | Use labeled data in the same format as the training dataset for testing, and output test metric data; |
| Image Directory Test | Only use the trained model and parameters to infer all unlabeled samples in the image directory, without test metrics; |

Click the "Start Test" button to start the test. After the test is completed, check your model performance according to the evaluation metrics; double-click an item in the test data list to view the large image of the inference result.

##### Model Deployment

If the model performance meets your needs, you can configure deployment parameters in the chip adaptation panel, mainly the model input resolution and some basic parameters, and click the `Deploy Button` to generate a deployment package.

![Deployment Package Generation](https://www.kendryte.com/api/post/attachment?id=622)

After the deployment artifacts are generated, you can find the following files in the root directory of the current project. We mainly use `kmodel` and the configuration file `deploy_config.json`:

```shell
📦 task_name
├── 📁 cpp_deployment_source
├── 📁 mp_deployment_source
└── README.md
```

![Project Files](https://www.kendryte.com/api/post/attachment?id=623)

The `mp_deployment_source` directory contains resources for deployment on the K230 solution, including the Kmodel file and the deployment configuration file! **What we actually need are only the configuration file `deploy_config.json` and the model file `***.kmodel`**. Copy this directory to the development board.

#### Deployment Steps

##### Deployment Package Description

After training ends, the deployment artifacts for the corresponding training task can be obtained.

##### File Copying

✅ **Firmware Selection**: Please follow the steps in the document below to set up the compilation environment and compile the firmware to ensure that the **latest features** are supported! See the tutorial: [Firmware Compilation](./userguide/how_to_build.md).

✅ **Firmware Flashing**: Flash the firmware according to the development board type, refer to: [Firmware Flashing](https://www.kendryte.com/k230_rtos/zh/main/userguide/how_to_flash.html).

✅ **Deployment Code**: The deployment code is located at `rtos_sdk/src/rtsmart/examples/ai/cloudplat_deploy_code` in the compilation environment. You need to enter this directory and execute `./build_app.sh` to complete the compilation. The compiled artifacts are located in the `k230_bin` directory. For usage instructions, refer to the `README.md` in this directory.

##### Script Execution

**Parameter Configuration**:

You can configure parameters in `setting.h` under `common_files`. The explanation of parameter configuration is as follows, mainly used for configuring screen display:

|Macro Definition Parameter|Description|
|:-:|:-:|
|`ISP_WIDTH`|ISP output width|
|`ISP_HEIGHT`|ISP output height|
|`DISPLAY_MODE`|Display mode, 0 for 1920×1080 LT9611, 1 for 800×480 ST7701|
|`DISPLAY_WIDTH`|Display screen width|
|`DISPLAY_HEIGHT`|Display screen height|
|`AI_FRAME_WIDTH`|AI inference frame width|
|`AI_FRAME_HEIGHT`|AI inference frame height|
|`AI_FRAME_CHANNEL`|Number of AI inference frame channels|
|`USE_OSD`|Whether to use OSD, 0 for not using, 1 for using|
|`OSD_WIDTH`|OSD layer width, used to display AI inference results|
|`OSD_HEIGHT`|OSD layer height, used to display AI inference results|
|`OSD_CHANNEL`|Number of OSD layer channels|

**Source Code Compilation**:

Enter the `src/rtsmart/examples/ai/cloudplat_deploy_code` directory

```shell
# Enter directory
cd cloudplat_deploy_code

# Compile files, all task-compiled elf files will be obtained in the k230_bin directory
./build.sh

# If you only want to compile the deployment file for a specific task, you can use ./build.sh <task name>
./build.sh classification
./build.sh detection
...
```

The compiled artifacts are in the `k230_bin` directory.

**On-board Deployment**:

Copy the obtained `elf files`, font files, and `kmodel`, `deploy_config.json` obtained from the AICube training project, and test images to a directory on the development board, then run the commands:

```shell
# Classification - video inference, type `q` and press Enter to exit video inference
./classification.elf deploy_config.json None 0

# Classification - image inference
./classification.elf deploy_config.json test.jpg 0

# Detection - video inference, type `q` and press Enter to exit video inference
./detection.elf deploy_config.json None 0

# Detection - image inference
./detection.elf deploy_config.json test.jpg 0

# Semantic Segmentation - video inference, type `q` and press Enter to exit video inference
./segmentation.elf deploy_config.json None 0

# Semantic Segmentation - image inference
./segmentation.elf deploy_config.json test.jpg 0

# OCR Detection - video inference, type `q` and press Enter to exit video inference
./ocr_detection.elf deploy_config.json None 0

# OCR Detection - image inference
./ocr_detection.elf deploy_config.json test.jpg 0

# OCR Recognition - image inference, this task only supports image inference
./ocr_recognition.elf deploy_config.json test.jpg 0

# OCR - video inference, type `q` and press Enter to exit video inference
./ocr.elf ocrdet_deploy_config.json ocrrec_deploy_config.json None 0

# OCR - image inference
./ocr.elf ocrdet_deploy_config.json ocrrec_deploy_config.json test.jpg 0

# Metric Learning - video inference, type `q` and press Enter to exit video inference
./metric_learning.elf deploy_config.json None 0

# Metric Learning - image inference
./metric_learning.elf deploy_config.json test.jpg 0

# Multi-label Classification - video inference, type `q` and press Enter to exit video inference
./multilabel_classification.elf deploy_config.json None 0

# Multi-label Classification - image inference
./multilabel_classification.elf deploy_config.json test.jpg 0
```

##### Deployment Notes

- 📢 If the results are not ideal when deploying the model, first adjust the threshold of the corresponding task and the resolution of the inference image to test whether the results can be improved!

- 📢 Learn to locate problems, such as checking the AICube model evaluation results. If the image is normal, it may be a problem with the deployment code, model conversion, or threshold. You can choose to adjust the quantization method or adjust the deployment parameters for optimization!

- 📢 AICube has a large number of training parameters. Users with deep learning knowledge can adjust the training parameters according to possible optimization directions, and adjust the model training parameters to retrain and convert!

## FAQ
  
### How to find the problem during development?

📝 First, take different approaches based on different stages and errors:

- If errors occur during the model conversion stage, the conversion code may have issues. You need to read the nncase usage instructions and adjust the conversion code;
- If the model conversion is successful, but the performance is not as expected, you can consider adjusting the threshold, changing the quantization method for model conversion, or adjusting training parameters during training;
- If the model conversion is successful, but the frame rate is low, you can consider switching to a lighter model or reducing the model input resolution;
- If deployment fails, please check the line number where the deployment code reports an error, look up the cause of the error according to the API documentation, and adjust the code;

### Which operators does nncase support?

📝 For the onnx operators and tflite operators supported by nncase, see the links: [onnx operator support](https://github.com/kendryte/nncase/blob/master/docs/onnx_ops.md) and [tflite operator support](https://github.com/kendryte/nncase/blob/master/docs/tflite_ops.md)

### Error "ImportError: DLL load failed while importing _nncase" when converting model

📝 Please refer to the solution at the following link: [ImportError: DLL load failed while importing _nncase](https://github.com/kendryte/nncase/issues/451)

### Error "RuntimeError: Failed to initialize hostfxr" when converting model

📝 Please install dotnet-sdk-7.0. Please do not install dotnet-sdk in an Anaconda virtual environment.

Linux:

```shell
sudo apt-get update
sudo apt-get install dotnet-sdk-7.0
If you still have problems after installation, maybe you install dotnet in a virtual enviroment, set the environment variables. dotnet error
export DOTNET_ROOT=/usr/share/dotnet
```

Windows: Please refer to the official Microsoft website.

### What is the difference between the online training platform and AICube?

📝 The online training platform uses cloud computing power, requiring queuing when resources are tight. At the same time, the parameter configuration is relatively simple, with one-click training and lower flexibility; AICube uses local private computing power, with more complex environment and parameter configuration, and higher flexibility. Their purpose is to obtain kmodel and configuration files. Use the code in `src/rtsmart/examples/ai/cloudplat_deploy_code` in the firmware to compile and deploy.

### Which tasks are supported in the YOLO library?

📝 YOLOv5 supports three types of tasks: classification, detection, and segmentation. YOLOv8 and YOLO11 support four types of tasks: classification, detection, segmentation, and rotated object detection. Please choose the appropriate task type according to your needs.

### How to get support?

📝 If you encounter problems during development, you can go to the Canaan Developer Community Q&A Forum to post your questions. Forum address: [Kendryte Q&A Community](https://www.kendryte.com/answer/).

## Appendix

### API

For the K230 RT-Smart API documentation, see the link: [API Documentation](https://www.kendryte.com/k230_rtos/zh/main/api_reference/index.html)

### KTS

`K230_training_scripts (KTS)` is an end-to-end training process implementation, but the project's code is developed based on dual-system C++. You can use this tool to obtain kmodel. Project address: [K230_training_scripts](https://github.com/kendryte/K230_training_scripts).
