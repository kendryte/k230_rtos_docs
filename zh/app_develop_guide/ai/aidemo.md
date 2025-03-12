# AI Demo 应用指南

## 概述

K230 AI Demo集成了人脸、人体、手部、车牌、单词续写、语音、dms等模块，包含了分类、检测、分割、识别、跟踪、单目测距等多种功能，给客户提供如何使用K230开发AI相关应用的参考。上述应用用于验证K230的能力，丰富应用场景，实际应用场景需要有针对性的进行优化，以达到更好的效果。参考优化方向包括调整阈值、代码优化、量化优化、模型优化、训练数据优化等方向。

## 支持开发板

- CanMV-K230-V1.1 / CanMV-K230-V3.0 / 01Studio CanMV K230/ Bpi-CanMV-K230D-Zero/ 庐山派-K230

## 源码说明

### 文件树

源码路径位于 `src/rtsmart/examples/ai_poc`，目录结构如下：

```shell
# AI Demo子目录（eg：bytetrack、face_detection等）中有详细的Demo说明文档
.
├── anomaly_det
├── bytetrack
├── cmake
├── crosswalk_detect
├── demo_mix
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
├── build_app_rtos_only.sh
└── build_app_sub_rtos_only.sh
```

kmodel、image及相关依赖路径位于 `src/rtsmart/libs/kmodel/ai_poc`，目录结构如下：

```shell
.
├── images # Demo测试图片
│   ├── 000.png
│   ├── 1000.jpg
│   ├── 1024x1111.jpg
│   ├── 1024x1331.jpg
│   ├── 1024x624.jpg
│   ├── 1024x768.jpg
│   ├── 333.jpg
│   ├── 640x340.jpg
│   ├── bus.jpg
│   ├── bytetrack_data
│   ├── car.jpg
│   ├── cw.jpg
│   ├── falldown_elder.jpg
│   ├── helmet.jpg
│   ├── hrnet_demo.jpg
│   ├── identification_card.png
│   ├── input_flower.jpg
│   ├── input_hd.jpg
│   ├── input_ocr.jpg
│   ├── input_pd.jpg
│   ├── licence.jpg
│   ├── person.png
│   ├── road.jpg
│   ├── smoke1.jpg
│   └── traffic.jpg
├── kmodel  # Demo测试kmodel模型
│   ├── anomaly_det.kmodel
│   ├── bytetrack_yolov5n.kmodel
│   ├── cropped_test127.kmodel
│   ├── crosswalk.kmodel
│   ├── eye_gaze.kmodel
│   ├── face_alignment.kmodel
│   ├── face_alignment_post.kmodel
│   ├── face_detection_320.kmodel
│   ├── face_detection_640.kmodel
│   ├── face_detection_hwc.kmodel
│   ├── face_emotion.kmodel
│   ├── face_gender.kmodel
│   ├── face_glasses.kmodel
│   ├── face_landmark.kmodel
│   ├── face_mask.kmodel
│   ├── face_parse.kmodel
│   ├── face_pose.kmodel
│   ├── face_recognition.kmodel
│   ├── flower_rec.kmodel
│   ├── gesture.kmodel
│   ├── hand_det.kmodel
│   ├── handkp_det.kmodel
│   ├── hand_reco.kmodel
│   ├── head_detection.kmodel
│   ├── helmet.kmodel
│   ├── hifigan.kmodel
│   ├── human_seg_2023mar.kmodel
│   ├── kws.kmodel
│   ├── licence_reco.kmodel
│   ├── LPD_640.kmodel
│   ├── nanotrack_backbone_sim.kmodel
│   ├── nanotracker_head_calib_k230.kmodel
│   ├── ocr_det_int16.kmodel
│   ├── ocr_det.kmodel
│   ├── ocr_rec_int16.kmodel
│   ├── ocr_rec.kmodel
│   ├── person_attr_yolov5n.kmodel
│   ├── person_detect_yolov5n.kmodel
│   ├── person_pulc.kmodel
│   ├── recognition.kmodel
│   ├── traffic.kmodel
│   ├── translate_decoder.kmodel
│   ├── translate_encoder.kmodel
│   ├── vehicle_attr_yolov5n.kmodel
│   ├── vehicle.kmodel
│   ├── yolop.kmodel
│   ├── yolov5n-falldown.kmodel
│   ├── yolov5s_smoke_best.kmodel
│   ├── yolov8n_320.kmodel
│   ├── yolov8n_640.kmodel
│   ├── yolov8n-pose.kmodel
│   ├── yolov8n_seg_320.kmodel
│   ├── yolov8n_seg_640.kmodel
│   ├── zh_fastspeech_1_f32.kmodel
│   ├── zh_fastspeech_1.kmodel
│   └── zh_fastspeech_2.kmodel
└── utils  # Demo测试使用的其他工具文件，比如OCR字典，关键词唤醒预置音频等
    ├── Asci0816.zf
    ├── bfm_tri.bin
    ├── bu.bin
    ├── dict_6625.txt
    ├── dict_ocr_16.txt
    ├── dict_ocr.txt
    ├── file
    ├── HZKf2424.hz
    ├── jiandao.bin
    ├── libsentencepiece.a
    ├── llama.bin
    ├── memory.bin
    ├── ncc_code.bin
    ├── pintu.bin
    ├── reply_wav
    ├── shang.bin
    ├── shitou.bin
    ├── tokenizer.bin
    ├── trans_src.model
    ├── trans_tag.model
    ├── wav_play.elf
    ├── xia.bin
    ├── you.bin
    └── zuo.bin
```

### Demo 说明

| Demo 子目录           | 场景                     |      说明                  |
| :-------------------- | ------------------------ |--------------------------- |
| anomaly_det           | 异常检测                 | 异常检测示例提供的模型使用patchcore异常检测方法训练得到，能够从输入图片中辨别出玻璃瓶口是否存在异常。异常检测通常会被应用在工业图像检测、医疗图像分析、安防监控等领域。                            |
| bytetrack             | 多目标跟踪               | ByteTrack多目标追踪示例使用YOLOv5作为目标检测算法，应用卡尔曼滤波算法进行边界框预测，应用匈牙利算法进行目标和轨迹间的匹配。  |
| crosswalk_detect      | 人行横道检测              | 人行横道检测使用YOLOV5网络，该应用对图片或视频中的人行横道进行检测，可用于辅助驾驶等场景。                        |
| demo_mix              | demo串烧合集             | Demo串烧使用不同的手势控制应用切换，食指比1手势进入动态手势识别，食指中指比2手势进入人脸姿态角识别，三指比3手势进入人脸跟踪。可以作为智能跟踪拍摄车的软件部分实现隔空调整底盘位置，隔空调整相机角度，追踪人脸目标。                             |
| distraction_reminder  | 非正视检测                  | 非正视检测示例主要采用了人脸姿态估计作为基础，通过逻辑判断实现对司机注意力不集中于前方的提醒。人脸检测采用了retina-face模型，人脸朝向估计98个2D关键点拟合                        |
| dms_system            | 驾驶员监控系统             | dms示例以手掌检测和人脸检测为基础，通过逻辑判断实现对行驶车辆司机的违规行为（抽烟、打电话、喝水）进行提醒。人脸检测采用了retina-face网络结构，backbone选取0.25-mobilenet。手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2。 |
| dynamic_gesture       | 视觉动态手势识别            | 视觉动态手势识别可以对上下左右摆手和五指捏合五个动作进行识别，用于隔空操作控制场景。 手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测采用了resnet50网络结构,动态手势识别采用了tsm结构，backbone选取了mobilenetV2。                            |
| eye_gaze              | 注视估计                 |   注视估计示例根据人脸预测人正在看哪里，对视频帧或图片，先进行人脸检测，然后对每个人脸进行注视估计，预测出注视向量，并以箭头的方式显示到屏幕上。该应用采用retina-face网络实现人脸检测，使用L2CS-Net实现注视估计。注视估计可以应用到汽车安全领域。                          |
| face_alignment        | 人脸对齐                 | 人脸对齐示例可得到图像或视频中的每个人脸的深度图（depth）或归一化投影坐标编码图。人脸检测采用了retina-face网络结构，backbone选取0.25-mobilenet，人脸对齐网络基于3DDFA(3D Dense Face Alignment)实现。            |
| face_detection        | 人脸检测                 |  人脸检测实例可得到图像或视频中的每个人脸检测框以及每个人脸的左眼球/右眼球/鼻尖/左嘴角/右嘴角五个关键点位置。人脸检测采用了retina-face网络结构，backbone选取0.25-mobilenet。                           |
| face_emotion          | 面部表情识别              | 面部表情识别使用两个模型实现图像/视频中每个人的表情识别的功能，可识别的表情类别包括Neutral、Happiness、Sadness、Anger、Disgust、Fear、Surprise。人脸检测使用retina-face网络结构；表情分类选用mobilenet为backbone进行分类，得到人物表情。                            |
| face_gender           | 性别分类                 | 人脸性别分类示例使用两个模型实现判断图像/视频中每个人的性别的功能，每个人物性别用M或F表示，其中M表示男性（Male），F表示女性（Female）。 人脸检测使用retina-face网络结构；性别分类选用EfficientNetB3为backbone进行分类，得到人物性别。                           |
| face_glasses          | 是否佩戴眼镜分类         | 是否佩戴眼镜分类示例使用两个模型实现判断图像/视频每个人是否佩戴眼镜。 人脸检测检测模型使用retina-face网络结构；人脸眼镜分类模型选用SqueezeNet-1.1为backbone，用于对每个人脸框判断眼镜佩戴情况。                           |
| face_landmark         | 人脸密集关键点            | 人脸密集关键点检测应用使用两个模型实现检测图像/视频中每张人脸的106关键点，并根据106关键点绘制人脸、五官等轮廓，不同轮廓使用不用的颜色表示。人脸检测使用retina-face网络结构；密集关键点检测选用0.5-mobilenet为backbone，用于对每张人脸检测106个关键点，106关键点包括人脸的脸颊、嘴巴、眼睛、鼻子和眉毛区域。                            |
| face_mask             | 是否佩戴口罩分类          | 是否佩戴口罩分类应用使用两个模型实现判断图像/视频每个人是否佩戴口罩。在需要佩戴口罩的应用场景中，若发现有人没有佩戴口罩，可进行相关提醒。人脸检测检测模型使用retina-face网络结构；人脸口罩分类模型使用mobilenet-v2为backbone，用于对每个人脸框判断口罩佩戴情况。                            |
| face_mesh             | 3D人脸网格              |  3D人脸网格可得到图像或视频中的每个人脸的三维网格结构。人脸检测采用了retina-face网络结构，backbone选取0.25-mobilenet，人脸对齐网络基于3DDFA(3D Dense Face Alignment)实现。|
| face_parse            | 人脸分割                  | 人脸分割示例使用两个模型实现对图像/视频中每个人脸的分割功能，人脸分割包含对人脸眼睛、鼻子、嘴巴等部位按照像素进行区分，不同的区域用不同的颜色表示。 人脸检测采用了retina-face网络结构，人脸部位分割使用DeepNetV3网络结构，backbone使用mobilenet-1.0。                           |
| face_pose             | 人脸姿态估计             | 人脸姿态估计使用两个模型实现对图像/视频中每个人的脸部朝向的角度进行估计的功能。人脸朝向用一般用欧拉角（roll/yaw/pitch）表示，其中roll代表了人脸左右摇头的程度；yaw代表了人脸左右旋转的程度；pitch代表了人脸低头抬头的程度。人脸检测采用了retina-face模型，人脸朝向估计98个2D关键点拟合。                            |
| face_verification     | 人脸身份验证             | 人脸身份验证是一种基于人脸生物特征的身份验证技术，旨在确认个体是否是其所声称的身份。该技术通过分析和比对用户的脸部特征来验证其身份，通常是在人脸验证系统通过对比两张图片，确定两张图像中的人脸是否属于同一个人。 人脸检测采用了retina-face模型，人脸朝特征化使用ResNet50,输出512维特征。                           |
| falldown_detect       | 跌倒检测                 |  跌倒检测可以对图片或视频中的人的跌倒状态进行检测。该示例使用yolov5n模型实现。                           |
| finger_guessing       | 猜拳游戏                 |  猜拳游戏示例通过手部手势识别区分石头鸡剪刀布，包括手掌检测和手部21关键点识别两个模型，通过21个关键点的位置约束确定手势类别。手掌检测部分采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测部分采用了resnet50网络结构。                          |
| fitness               | 蹲起动作计数             |  蹲起动作计数示例实现视频中人的蹲起动作计数功能，适用于健身状态检测等场景。使用yolov8n-pose模型实现。                           |
| head_detection        | 人头检测计数             |  人头检测计数示例实现了获取图片或视频中出现的人头的坐标和数量的功能。使用yolov8模型实现。                           |
| helmet_detect         | 安全帽检测               | 安全帽检测实例实现了对图片或视频中出现的人是否佩戴安全帽进行检测，适用于建筑制造业的安全预防场景。使用yolov5模型实现。                            |
| kws                   | 关键词唤醒               |关键词唤醒通过音频识别模型检测音频流中是否包含训练时设定的关键词，如果检测到对应的关键词，给出语音响应。本示例提供的模型为WeNet训练得到，正负样本分别采用在k230开发板上采集的“xiaonan”音频和开源数据集speech_commands。                             |
| licence_det           | 车牌检测                 | 车牌检测可以检测图像或视频中的出现的车牌。 车牌检测采用了retinanet网络结构。                          |
| licence_det_rec       | 车牌识别                 | 车牌识别可以识别图图像或视频中出现的车牌的位置以及牌照信息。车牌检测采用了retinanet网络结构，车牌识别采用了以MobileNetV3为backbone的RLNet网络结构。                            |
| nanotracker           | 单目标跟踪               | 单目标跟踪在前几秒在注册框中防止特征明显的待跟踪物品实现追踪注册，然后实时对该物品进行视觉追踪。 跟踪算法使用NanoTrack。                           |
| object_detect_yolov8n | YOLOV8多目标检测         | YOLOv8多目标检测检测示例实现COCO数据集80类别检测。使用yolov8n模型。                            |
| ocr                   | ocr检测+识别             | OCR识别示例可检测到图像或视频中的文本位置以及相应的文字内容。OCR识别任务采用了CRNN网络结构，OCR检测任务采用了DBnet的网络结构。                           |
| person_attr           | 人体属性                 | 人体属性检测可以识别图片或视频中的人体位置坐标，性别、年龄、是否佩戴眼镜、是否持物。人体检测使用YOLOv5模型实现，人体属性使用PULC人模型实现。                            |
| person_detect         | 人体检测                 |  人体检测可以检测图片或视频中的人体位置坐标信息，并用检测框标记出来。本示例使用yolov5模型实现。                           |
| person_distance       | 行人测距                 |  行人测距是先通过行人检测检测行人，再通过检测框在图像中的大小去估算目标距离。其中行人检测采用了yolov5n的网络结构。使用该应用，可得到图像或视频中的每个行人的检测框以及估算的距离。该技术可应用在车辆辅助驾驶系统、智能交通等领域。该应用需要根据摄像头调整计算数据，现有示例可能识别不准。                   |
| pose_detect           | 人体关键点检测           |  人体关键点检测模型的输出是一组代表图像或视频中人体对象上的关键点（17个），以及每个点的置信度得分，并使用不同颜色的线将关键点连接成人体的形状。本示例使用yolov8n-pose模型实现。                           |
| pphumanseg            | 人像分割                 | 人像分割指对图片或视频中的人体轮廓范围进行识别，将其与背景进行分离，返回分割后的二值图、灰度图、前景人像图等，实现背景图像的替换与合成。 可应用于人像抠图、照片合成、人像特效、背景特效等场景，大大提升图片和视频工具效率。本示例使用pphumanseg模型实现。                            |
| puzzle_game           | 拼图游戏                 | 拼图游戏可得到图像或视频中的每个手掌的21个骨骼关键点位置。并且可以实现拼图游戏的功能，张开拇指和中指，将其中点放到空格旁边的非空格，拟合两指，当前非空格会移动到空格内。 示例中手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测采用了resnet50网络结构。                           |
| segment_yolov8n       | YOLOV8多目标分割         | YOLOv8多目标分割检测示例实现COCO数据集80类别分割掩码。使用yolov8n-seg模型。                            |
| self_learning         | 自学习（度量学习分类）    | 自学习通过在注册框内注册物品特征，然后再不重新训练的前提下识别框内的物品。程序启动后输入i打断运行，输入n为新建特征，输入d是删除特征，特征注册完毕后会继续开始识别检测框内的物品和注册的物品的相似程度，并完成分类，按esc键退出程序。特征化模型使用ppshitu_lite模型。                           |
| smoke_detect          | 吸烟检测                 |  吸烟检测对图片或视频中存在的吸烟行为进行实时监测识别。该示例使用yolov5模型实现。                           |
| space_resize          | 手势隔空缩放             | 手势隔空缩放可得到图像或视频中的每个手掌的21个骨骼关键点位置，并且我们通过拇指中指来实现隔空缩放图像。手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测采用了resnet50网络结构。                            |
| sq_hand_det           | 手掌检测                 |  手掌检测可获取图像或视频中的每个手掌的检测框。手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2。                           |
| sq_handkp_class       | 手掌关键点手势分类       |   手掌关键点手势分类可得到图像或视频中的每个手掌的21个骨骼关键点位置,并根据关键点的位置二维约束获得静态手势。共支持握拳，五指张开，一手势，yeah手势，三手势，八手势，六手势，点赞，拇指食指小拇指张开共9种手势。本示例中手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测采用了resnet50网络结构。                          |
| sq_handkp_det         | 手掌关键点检测           | 手掌关键点检测示例可得到图像或视频中的每个手掌的21个骨骼关键点位置。手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测采用了resnet50网络结构。                           |
| sq_handkp_flower      | 指尖区域花卉分类         | 指尖区域花卉识别可得到图像或视频中的两个手掌的食指指尖包围区域内的花卉类别。可支持102种花卉的种类识别。本示例手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测采用了resnet50网络结构。花朵分类backbone选取了1.0-mobilenetV2。                            |
| sq_handkp_ocr         | 手指区域OCR识别          | 手指区域OCR识别可得到图像或视频中的每个手掌的食指左上区域范围内识别到的文字。手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测采用了resnet50网络结构。文字检测采用了retinanet网络结构，文字识别采用了以MobileNetV3为backbone的RLnet网络结构。                            |
| sq_handreco           | 手势识别                 | 手势识别可得到图像或视频中的每个手势的类别。仅支持五指张开、八手势、  yeah手势三种。 本示例中手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手势识别backbone选取了1.0-mobilenetV2。                        |
| traffic_light_detect  | 交通信号灯检测           | 可检测到图像或视频中的交红绿黄信号灯。本示例使用yolov5模型实现。                            |
| translate_en_ch       | 英翻中翻译               | 英翻中翻译可以实现简单的英翻中翻译任务，效果一般。机器翻译模型应用了transformer结构。                       |
| tts_zh                | 中文转语音               | 中文文字转语音（text to chinese speech, tts_zh）使用三个模型实现。用户默认输入三次文字，生成文字对应的wav文件。 本示例将FastSpeech2模型拆分成两个模型，Encoder+Variance Adaptor为fastspeech1，Decoder为fastspeech2，声码器选择hifigan。持续时间特征在fastspeech1之后添加。                       |
| vehicle_attr          | 车辆属性识别             | 车辆属性识别可以识别图像或视频中每个车辆，并返回该车辆的位置坐标、车型、车身颜色。本示例采用了yolov5网络结构实现了车辆检测，车辆属性检测使用PULC模型。                         |
| virtual_keyboard      | 隔空虚拟键盘             | 隔空虚拟键盘可以使用屏幕上的虚拟键盘输出字符。拇指和食指捏合是输入动作。本示例中手掌检测采用了yolov5网络结构，backbone选取了1.0-mobilenetV2，手掌关键点检测采用了resnet50网络结构。                          |
| yolop_lane_seg        | 路面车道线分割           | 路面车道线分割可在图像或视频中实现路面分割，即检测到车道线和可行驶区域，并加以颜色区分。本示例使用yolop模型实现。         |

## 编译及运行程序

### 固件编译

#### 搭建环境并安装依赖

- 使用本地Linux主机，或者安装虚拟机，或者安装WSL;
- 安装必要的依赖软件；
  
```shell
# 添加 i386 架构支持
sudo bash -c 'dpkg --add-architecture i386 && \
  apt-get clean all && \
  apt-get update && \
  apt-get install -y --fix-broken --fix-missing --no-install-recommends \
    sudo vim wget curl git git-lfs openssh-client net-tools sed tzdata expect mtd-utils inetutils-ping locales \
    sed make cmake binutils build-essential diffutils gcc g++ bash patch gzip bzip2 perl tar cpio unzip rsync \
    file bc findutils dosfstools mtools bison flex autoconf automake python3 python3-pip python3-dev python-is-python3 \
    lib32z1 scons libncurses5-dev kmod fakeroot pigz tree doxygen gawk pkg-config libyaml-dev libconfuse2 libconfuse-dev \
    libssl-dev libc6-dev-i386 libncurses5:i386'
```

- 安装Python依赖；

```shell
pip3 install -U pyyaml pycryptodome gmssl
```

- 安装repo工具，并添加环境变量；
  
```shell
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
echo 'export PATH="${HOME}/.bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

#### 下载源码并编译固件

```shell
cd ~
mkdir rtos_k230_sdk
cd rtos_k230_sdk

# 生成ssh密钥并将其添加到github或者gitee
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
cat ~/.ssh/id_rsa.pub

# 使用github
repo init -u https://github.com/canmv-k230/manifest -b master -m rtsmart.xml --repo-url=https://github.com/canmv-k230/git-repo.git

# 使用gitee
repo init -u https://gitee.com/canmv-k230/manifest -b master -m rtsmart.xml --repo-url=https://gitee.com/canmv-k230/git-repo.git

repo sync
# 下载工具链
make dl_toolchain
# 列出可用的配置选项
make list_def
# 选择对应的板子配置文件
make xxxx_defconfig
# 开始编译
time make log
```

编译生成的固件在output目录下。

#### 编译带 AI Demo 的固件

在RT-Smart SDK 根目录下使用 `make menuconfig` 配置 `RT-Smart Configuration->Enable build RTsmart examples->Enable build ai examples` 使能。退出时保存配置，回到根目录下重新执行 `make` 命令。

### AI Demo 编译

#### 切换不同的开发板

在RT-Smart SDK 根目录下使用 `make list_def` 命令查看开发板类型，使用 `make ***_defconfig` 命令选择AI Demo支持的开发板(`k230_canmv_01studio_defconfig`/`k230_canmv_defconfig`/`k230_canmv_v3p0_defconfig`/`k230d_canmv_bpi_zero_defconfig`)，然后执行 `make` 命令实现开发板切换和固件编译。

#### 默认显示支持

这里列出几种常见开发板在`AIDemo`中的显示配置。

| 开发板类型 | 开发板宏定义 |默认编译说明|
| :----- | :--- |:---|
| k230_canmv_defconfig  | CONFIG_BOARD_K230_CANMV | 默认使用LT9611 HDMI 1080P显示，当前代码仅支持此种模式|
| k230_canmv_01studio_defconfig |CONFIG_BOARD_K230_CANMV_01STUDIO|默认使用LT9611 HDMI 1080P显示，可以在编译参数指定lcd，使用ST7701 480*800显示|
| k230_canmv_v3p0_defconfig |CONFIG_BOARD_K230_CANMV_V3P0|默认使用ST77011 LCD 480*800屏幕显示，当前代码仅支持此种模式|
|k230_canmv_lckfb_defconfig  |CONFIG_BOARD_K230_CANMV_LCKFB|默认使用ST77011 LCD 480*800屏幕显示，当前代码仅支持此种模式|
|k230d_canmv_bpi_zero_defconfig  |CONFIG_BOARD_K230D_CANMV_BPI_ZERO|默认使用ST77011 LCD 480*800屏幕显示，当前代码仅支持此种模式|

还有几种开发板没有列出支持，AI模型部分没有区别，仅在显示部分存在区别，您可以按照`src/rtsmart/mpp/include/comm/k_autoconf_comm.h` 中的宏定义确定开发板类型，并更改 `vi_vo.h`文件进行适配。

#### AI Demo 编译

在RT-Smart SDK 根目录下，进入 `src/rtsmart/examples/ai_poc`目录，按照如下命令进行编译：

```shell
cd src/rtsmart/examples/ai_poc

# 不带参数默认编译所有的demo
./build_app_rtos_only.sh

# 对于01studio开发板，编译hdmi显示模式下所有的demo
./build_app_rtos_only.sh all hdmi

# 对于01studio开发板，编译lcd显示模式下所有的demo
./build_app_rtos_only.sh all lcd

# 对于01studio开发板，编译hdmi显示模式下某一个demo
./build_app_rtos_only.sh face_detection hdmi

# 对于01studio开发板，编译lcd显示模式下某一个demo
./build_app_rtos_only.sh face_detection lcd
```

编译产物在 `src/rtsmart/examples/ai_poc/k230_bin` 目录下，生成文件目录结构如下：

```bash
k230_bin/
├── face_detection
│   ├── 1024x624.jpg
│   ├── face_detect_image.sh
│   ├── face_detection_320.kmodel
│   ├── face_detection_640.kmodel
│   ├── face_detection.elf
│   └── face_detect_isp.sh
├── ...
```

#### AI Demo 上板运行

将感兴趣的demo编译产物目录，比如 `face_detection` 目录拷贝到开发板，即可在RTOS系统运行对应的 AI Demo。拷贝方法可以使用离线插拔TF卡拷贝，将 `face_detection` 目录拷贝到TF卡根目录，然后插卡上电，连接串口，进入`/sdcard/face_detection` 目录执行 Demo 对应的 `***_isp.sh` 或 `***_image.sh` 脚本。比如：

```shell
#进入开发板大核sharefs目录
cd /sdcard/face_detection
#执行相应脚本即可运行人脸检测
#详细人脸检测说明可以参考src/rtsmart/examples/ai_poc/face_detection/README.md
./face_detect_isp.sh
```
