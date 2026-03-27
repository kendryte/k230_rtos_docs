# LVGL 示例

## 简介

本示例演示了如何在K230平台上使用LVGL（Light and Versatile Graphics Library）图形库。LVGL是一款免费、开源的嵌入式图形库，支持丰富的图形控件、流畅的动画效果和多种输入设备，适用于MCU和MPU平台。

## 功能说明

### LVGL特性

本示例展示了LVGL在K230平台上的应用：

- **多分辨率支持**：自动适配不同分辨率的显示屏
- **触摸屏支持**：集成触摸屏输入驱动
- **丰富的UI控件**：按钮、进度条、滑块、开关等
- **响应式布局**：根据屏幕尺寸自动调整控件大小和位置
- **流畅动画**：支持控件动画效果

### LVGL控件

本示例包含以下LVGL控件演示：

- **标签（Label）**：显示文本信息
- **按钮（Button）**：响应式按钮，支持不同颜色
- **进度条（Bar）**：显示进度信息
- **滑块（Slider）**：可拖动的滑块控件
- **开关（Switch）**：开/关状态切换
- **容器（Container）**：布局容器

### 显示驱动

本示例使用K230平台的显示驱动：

- **分辨率支持**：支持最大1920x1080分辨率
- **双缓冲**：减少屏幕闪烁
- **DMA加速**：使用K230的GSDMA进行图像数据传输

### 输入设备

- **触摸屏输入**：支持电容/电阻触摸屏
- **手势识别**：支持点击、滑动等手势

## 代码位置

Demo 源码位置：`src/rtsmart/examples/3rd-party/lvgl/lvgl_basic`

## 使用说明

### 编译方法

#### 固件编译

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将LVGL示例编译进固件，然后编译固件。

#### 独立编译

进入LVGL示例目录，使用CMake进行编译：

```shell
cd src/rtsmart/examples/3rd-party/lvgl/lvgl_basic
mkdir build && cd build
cmake ..
make
```

编译成功后会生成可执行文件。

### 硬件准备

1. 准备LCD显示屏（支持MIPI DSI或RGB接口）
1. 连接触摸屏（如果使用触摸输入）
1. 确保显示屏和触摸屏正确连接到K230开发板

### 运行示例

将编译好的可执行文件拷贝到开发板，进入存放目录后运行：

```shell
./lvgl_basic
```

### 查看结果

程序运行后会启动LVGL图形界面，显示以下内容：

```text
Screen: 800x480
===========================
LVGL Multi-Resolution Demo

[Button 1] [Button 2] [Button 3]

Progress Bar:
[===========>       ] 70%

Slider:
[----O----]

Switch:
[ON]
```

界面特性：

- 顶部显示屏幕分辨率信息
- 中间显示三个颜色不同的按钮
- 下方显示进度条、滑块和开关控件
- 所有控件支持触摸交互

用户可以通过触摸屏与界面交互：

- 点击按钮查看响应
- 拖动滑块调整数值
- 切换开关状态

### 自定义界面

LVGL提供了丰富的API，用户可以根据需要自定义界面：

```c
// 创建标签
lv_obj_t* label = lv_label_create(parent);
lv_label_set_text(label, "Hello LVGL!");

// 创建按钮
lv_obj_t* btn = lv_button_create(parent);
lv_obj_t* btn_label = lv_label_create(btn);
lv_label_set_text(btn_label, "Click Me");
lv_obj_center(btn_label);

// 创建进度条
lv_obj_t* bar = lv_bar_create(parent);
lv_bar_set_value(bar, 50, LV_ANIM_OFF);
```

```{admonition} 提示
LVGL配置文件（lv_conf.h）中可以调整各种参数，如内存大小、屏幕分辨率、字体选择等。有关 LVGL 的详细API和配置，请参考 [LVGL官方文档](https://docs.lvgl.io/)。
```

```{admonition} 提示
LVGL需要定期调用 `lv_timer_handler()` 函数来刷新界面。建议在主循环中定期调用该函数。
```
