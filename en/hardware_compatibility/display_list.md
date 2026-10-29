# Display Screen Support List

The display-related configuration of the current SDK is located in `MPP Configuration -> Display Configuration`.

> Note: The support list is continuously updated as the SDK evolves. Please refer to the current source code `src/rtsmart/mpp/Kconfig` for the authoritative list.

## Panel / Bridge Chip Driver Layer

The current SDK includes built-in support for various display panels and bridge chips, covering output paths such as DSI, SPI, and HDMI.

Each display solution generally consists of two parts:

- Panel driver (Panel): Responsible for initializing the LCD/screen itself and configuring display parameters
- Bridge chip driver (Bridge): Used to convert DSI/other interfaces into HDMI or other display interfaces

The current drivers support multiple panels and bridge chips, and provide configuration options for different resolutions. The system supports a maximum display output of 1920×1080@60Hz or an equivalent bandwidth capacity.

| Panel/Bridge Chip | Configuration Macro |
| :--- | :--- |
| HDMI Bridge: LT9611 | `MPP_DSI_ENABLE_HDMI_LT9611` |
| LCD Panel: HX8399 | `MPP_DSI_ENABLE_LCD_HX8399` |
| LCD Panel: ST7701 | `MPP_DSI_ENABLE_LCD_ST7701` |
| LCD Panel: ILI9806 | `MPP_DSI_ENABLE_LCD_ILI9806` |
| LCD Panel: ILI9881 | `MPP_DSI_ENABLE_LCD_ILI9881` |
| LCD Panel: NT35516 | `MPP_DSI_ENABLE_LCD_NT35516` |
| LCD Panel: NT35532 | `MPP_DSI_ENABLE_LCD_NT35532` |
| LCD Panel: GC9503 | `MPP_DSI_ENABLE_LCD_GC9503` |
| LCD Panel: ST7102 | `MPP_DSI_ENABLE_LCD_ST7102` |
| LCD Panel: AML020T | `MPP_DSI_ENABLE_LCD_AML020T` |
| LCD Panel: JD9852 | `MPP_DSI_ENABLE_LCD_JD9852` |
| SPI LCD Panel: ST7789 | `MPP_SPI_ENABLE_LCD_ST7789` |

## How to Adapt a New Screen

For the complete procedure, including menuconfig pin configuration, panel driver registration, and initialization sequence addition, please refer to:

- [How to Add a Display Driver](../advanced_development_guide/how_to_add_display.md)
