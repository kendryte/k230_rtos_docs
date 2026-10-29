# FreeType Example

## Introduction

This example demonstrates how to use the FreeType font rendering library on the K230 platform. FreeType is a free, high-quality, portable font engine used to convert character outlines into bitmaps or scalable vector images (such as alpha masks).

## Functionality Description

### FreeType Features

This example showcases the application of FreeType on the K230 platform:

- **Font Rendering**: Render TrueType fonts into bitmaps
- **BMP Image Generation**: Save the rendered text as a BMP image file
- **Alpha Blending**: Support text rendering with transparency
- **Multi-Character Support**: Support Unicode character set

### Example Functions

This example implements the following functions:

- **Font Initialization**: Load TrueType font files
- **Text Rendering**: Render specified text content
- **Bitmap Generation**: Save the rendering results as a BMP image
- **Color Configuration**: Customize text color

### FreeType Interface

The main FreeType interfaces used in this example:

- Font file loading
- Font size setting
- Character outline loading
- Character bitmap rendering
- Alpha blending processing

## Code Location

Demo source code location: `src/rtsmart/examples/3rd-party/freetype/freetype_basic`

## Usage Instructions

### Compilation Method

#### Firmware Compilation

In the `K230 RTOS SDK` root directory, use `make menuconfig` to configure the compilation options, select to compile the FreeType example into the firmware, and then compile the firmware.

#### Standalone Compilation

Enter the FreeType example directory and use the Makefile to compile:

```shell
cd src/rtsmart/examples/3rd-party/freetype/freetype_basic
make
```

After successful compilation, an executable file will be generated.

### Running Example

Copy the compiled executable to the development board, navigate to the directory where it is stored, and run:

```shell
./freetype_basic
```

### Viewing the Result

After the program runs, it will:

1. Initialize the FreeType library
1. Load the font file
1. Render the specified text
1. Save it as a BMP image file

Output example:

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

The generated BMP image file (output.bmp) contains the rendered text and can be exported to a computer for viewing.

### Customizing Text and Font

Users can modify the following parameters in the source code to customize the output:

```c
// Modify the font file path
const char* font_path = "/path/to/your/font.ttf";

// Modify the text to be rendered
const char* text = "Your text here";

// Modify the font size
int font_size = 24;

// Modify the text color
uint32_t color = 0xFFFFFF; // white

// Modify the image dimensions
int width = 640;
int height = 480;
```

### Supported Font Formats

FreeType supports the following font formats:

- TrueType (.ttf)
- OpenType (.otf)
- Type 1 (.pfa, .pfb)
- CID Font (.cid)
- CFF
- SFNT-based bitmap fonts
- X11 PCF (.pcf)
- Windows FNT (.fnt)

```{admonition} Tip
The bitmap rendered by FreeType needs to be combined with a display driver to be shown on the screen. This example saves the result as a BMP file, which can be ported to actual display applications. For detailed FreeType APIs, please refer to the [FreeType official documentation](https://freetype.org/freetype2/docs/).
```

```{admonition} Tip
The FreeType library has been optimized on the K230 platform and supports hardware acceleration. In performance-demanding applications, caching mechanisms can be used to improve rendering efficiency.
```
