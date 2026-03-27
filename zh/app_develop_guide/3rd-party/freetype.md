# FreeType 示例

## 简介

本示例演示了如何在K230平台上使用FreeType字体渲染库。FreeType是一个免费、高质量、可移植的字体引擎，用于将字符轮廓转换为位图或可缩放矢量图像（如alpha蒙版）。

## 功能说明

### FreeType特性

本示例展示了FreeType在K230平台上的应用：

- **字体渲染**：将TrueType字体渲染为位图
- **BMP图像生成**：将渲染的文字保存为BMP图像文件
- **Alpha混合**：支持透明度的文字渲染
- **多字符支持**：支持Unicode字符集

### 示例功能

本示例实现了以下功能：

- **字体初始化**：加载TrueType字体文件
- **文字渲染**：渲染指定的文本内容
- **位图生成**：将渲染结果保存为BMP图像
- **颜色配置**：自定义文字颜色

### FreeType接口

本示例使用的FreeType主要接口：

- 字体文件加载
- 字体大小设置
- 字符轮廓加载
- 字符位图渲染
- Alpha混合处理

## 代码位置

Demo 源码位置：`src/rtsmart/examples/3rd-party/freetype/freetype_basic`

## 使用说明

### 编译方法

#### 固件编译

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将FreeType示例编译进固件，然后编译固件。

#### 独立编译

进入FreeType示例目录，使用Makefile进行编译：

```shell
cd src/rtsmart/examples/3rd-party/freetype/freetype_basic
make
```

编译成功后会生成可执行文件。

### 运行示例

将编译好的可执行文件拷贝到开发板，进入存放目录后运行：

```shell
./freetype_basic
```

### 查看结果

程序运行后会：

1. 初始化FreeType库
1. 加载字体文件
1. 渲染指定的文本
1. 保存为BMP图像文件

输出示例：

```text
FreeType Example
===============

Loading font: /path/to/font.ttf
Font size: 24 points

Rendering text: "Hello FreeType!"
Rendering complete.

Saving image to: output.bmp
Saved image to output.bmp

Test completed successfully!
```

生成的BMP图像文件（output.bmp）包含渲染后的文本，可以导出到电脑查看。

### 自定义文本和字体

用户可以修改源代码中的以下参数来定制输出：

```c
// 修改字体文件路径
const char* font_path = "/path/to/your/font.ttf";

// 修改渲染的文本
const char* text = "Your text here";

// 修改字体大小
int font_size = 24;

// 修改文字颜色
uint32_t color = 0xFFFFFF; // 白色

// 修改图像尺寸
int width = 640;
int height = 480;
```

### 支持的字体格式

FreeType支持以下字体格式：

- TrueType (.ttf)
- OpenType (.otf)
- Type 1 (.pfa, .pfb)
- CID Font (.cid)
- CFF
- SFNT-based bitmap字体
- X11 PCF (.pcf)
- Windows FNT (.fnt)

```{admonition} 提示
FreeType渲染的位图需要结合显示驱动显示到屏幕上。本示例将结果保存为BMP文件，可以移植到实际的显示应用中。有关 FreeType 的详细API，请参考 [FreeType官方文档](https://freetype.org/freetype2/docs/)。
```

```{admonition} 提示
FreeType库在K230平台上已经过优化，支持硬件加速。在性能要求高的应用中，可以使用缓存机制来提高渲染效率。
```
