# 修改和烧写OTP配置文件

## OTP说明

K230/K230D内部集成了一次性可编程器件OTP（One Time Programmable）。此器件可存储MAC、启动参数等永久绑定信息，通常我们把启动配置存储其中。

## 根据硬件设置自动生成OTP配置bin文件

嘉楠提供了便捷的图形化WEB界面，自动生成OTP配置bin文件。在此过程中，务必与硬件工程师充分沟通，明确硬件设置以及电压设置等关键信息。

配置工具连接：[OTP配置工具](https://developer.canaan-creative.com/zh/tools/otp_config_generation_tool)

![otp_tool](https://developer.canaan-creative.com/api/post/attachment?id=551)

生成 bin 文件时，需依据硬件电路图仔细挑选相应配置：

* BOOT ROM打印使用的UART IOMUX：此选项用于选定 BOOT log 输出的串口（建议优先选择 UART0）
* BOOT ROM打印使用的UART电压：BOOT输出串口所采用的电压
* OSPI IO电压：OSPI域的电压
* SDIO0 IO电压：MMC0域的电压
* SDIO1 IOMUX：MMC1选择的引脚
* SDIO1 IO电压：MMC1域的电压

以01Studio开发板原理图为例，可以根据这些部分确定选项：

![1740391481653](https://developer.canaan-creative.com/api/post/attachment?id=559)

![1740391571191](https://developer.canaan-creative.com/api/post/attachment?id=560)

![1740391632742](https://developer.canaan-creative.com/api/post/attachment?id=561)

![1740391686205](https://developer.canaan-creative.com/api/post/attachment?id=562)

特别提醒：务必与硬件工程师反复核对配置的准确性。一旦配置错误并进行烧写操作，极有可能导致芯片永久性损坏，无法修复！

完成上述配置后，点击 “生成配置文件” 按钮，即可生成一个 bin 文件，示例如下：

![1740392534136](https://developer.canaan-creative.com/api/post/attachment?id=565)

## 烧写OTP bin文件

烧写工具下载链接：[嘉楠开发者社区-资料下载](https://developer.canaan-creative.com/zh/resource?selected=0-2-2)

请根据您所使用的操作系统，选择对应的版本进行下载。同时，务必注意：在烧录过程未全部完成之前，切勿给开发板长时间供电，以免出现芯片烧坏情况。

![1740392907598](https://developer.canaan-creative.com/api/post/attachment?id=567)

给芯片接通电源，连接好 UART0 接口，打开 BurningTool 软件，选择先前生成的 bin 文件：

![1740396173639](https://developer.canaan-creative.com/api/post/attachment?id=568)

点击 “开始” 按钮，耐心等待烧录过程结束：

![1740469056238](https://developer.canaan-creative.com/api/post/attachment?id=569)

烧录完成后，点击 “确认” 即可。
