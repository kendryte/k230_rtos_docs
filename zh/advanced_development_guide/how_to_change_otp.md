# 配置和烧写OTP配置文件

## OTP说明

K230/K230D内部集成了一次性可编程器件OTP（One Time Programmable）。此器件可存储MAC、启动参数等永久绑定信息，通常我们把启动配置存储其中。

> **！！！如果烧录了错误的 OTP 或者固件的电压配置不匹配硬件配置有可能导致烧坏芯片！！！**

## 根据硬件设置自动生成OTP配置bin文件

嘉楠提供了便捷的图形化WEB界面，自动生成OTP配置bin文件。在此过程中，务必与硬件工程师充分沟通，明确硬件设置以及电压设置等关键信息。

配置工具连接：[OTP配置工具](https://www.kendryte.com/zh/tools/otp_config_generation_tool)

![otp_tool](https://www.kendryte.com/api/post/attachment?id=551)

生成 bin 文件时，需依据硬件电路图仔细挑选相应配置：

* BOOT ROM打印使用的UART IOMUX：此选项用于选定 BOOT log 输出的串口（建议优先选择 UART0）
* BOOT ROM打印使用的UART电压：BOOT输出串口所采用的电压
* OSPI IO电压：OSPI域的电压
* SDIO0 IO电压：MMC0域的电压
* SDIO1 IOMUX：MMC1选择的引脚
* SDIO1 IO电压：MMC1域的电压

以01Studio开发板原理图为例，可以根据这些部分确定选项：

![1740391481653](https://www.kendryte.com/api/post/attachment?id=802)

![1740391571191](https://www.kendryte.com/api/post/attachment?id=560)

![1740391632742](https://www.kendryte.com/api/post/attachment?id=561)

![1740391686205](https://www.kendryte.com/api/post/attachment?id=562)

特别提醒：务必与硬件工程师反复核对配置的准确性。一旦配置错误并进行烧写操作，极有可能导致芯片永久性损坏，无法修复！

完成上述配置后，点击 “生成配置文件” 按钮，即可生成一个 bin 文件，示例如下：

![1740392534136](https://www.kendryte.com/api/post/attachment?id=565)

## 烧写OTP bin文件

烧写工具下载链接：[勘智开发者社区-资料下载](https://www.kendryte.com/zh/resource?selected=0-2-2)

请根据您所使用的操作系统，选择对应的版本进行下载。同时，务必注意：在未完成OTP烧录之前，切勿给开发板长时间供电，以免出现芯片烧坏情况。

![1740392907598](https://www.kendryte.com/api/post/attachment?id=567)

```{warning}
如果 UART0 通过外置 USB 转串口模块连接，请先阅读 [串口电平与转接模块安全](../app_develop_guide/peripheral/uart.md)。必须确认 UART0 使用 1.8 V 还是 3.3 V 电平，禁止使用 5 V 信号及文中图片所示的劣质 CH340G 模块。
```

给芯片接通电源，连接好 UART0 接口，打开 BurningTool 软件，选择先前生成的 bin 文件：

![1740396173639](https://www.kendryte.com/api/post/attachment?id=568)

点击 “开始” 按钮，耐心等待烧录过程结束：

![1740469056238](https://www.kendryte.com/api/post/attachment?id=569)

烧录完成后，点击 “确认” 即可。

## Secure Boot 场景下的 OTP 文件

上面介绍的是通过 OTP 配置工具手工生成 OTP 配置 bin 的流程。

如果你是在 Secure Boot 场景下通过 SDK 自动生成 OTP 文件，则输出物来自 `tools/gen_otp_config.py`，格式不是单一的原始 bin，而是带 offset 信息的 `kdimg`。

当前 Secure Boot 会生成以下文件：

* `otp_config.json`：记录槽位策略、写入值和烧录文件信息。
* `otp_data.kdimg`：只包含 OTP 数据区，目标 offset 为 `0`。
* `otp_key_lock.kdimg`：只包含 OTP 锁位区，目标 offset 为 `1024`。
* `otp_full.kdimg`：同时包含 OTP 数据区和 OTP 锁位区。

当前 Secure Boot 使用的 OTP 槽位如下：

| 阶段 | 模式 | 对称密钥槽位 | 公钥哈希槽位 |
| --- | --- | --- | --- |
| `spl` | SM4 + SM2 | `OTPKEY_4` | `OTPKEY_7` |
| `spl` | AES + RSA | `OTPKEY_2` | `OTPKEY_6` |
| `firmware` | SM4 + SM2 | `OTPKEY_5` | `OTPKEY_9` |
| `firmware` | AES + RSA | `OTPKEY_3` | `OTPKEY_8` |

锁策略为：

* 对称密钥槽位锁为 `NA`
* 公钥哈希槽位锁为 `RO`
* 每个槽位按完整 32 字节整槽加锁

这些文件在 BurningTool 中的烧录位置由 kdimg 内部分区项的 offset 控制，不需要再手工拆分或拼接成一整个原始 2KB 文件。

建议按以下方式使用：

1. 如果要分步烧录，分别导入 `otp_data.kdimg` 和 `otp_key_lock.kdimg`。
1. 如果要一次性烧录完整 OTP，直接导入 `otp_full.kdimg`。
1. 烧录前先打开 `otp_config.json`，确认槽位、offset 和写入值都符合预期。

Secure Boot 的完整配置、构建和验证流程，请结合 `how_to_use_secureboot.md` 一起阅读。
