# Configuring and Burning the OTP Configuration File

## OTP Description

The K230/K230D integrates a One-Time Programmable (OTP) device. This device can store permanent binding information such as MAC address and boot parameters, and is typically used to store boot configuration.

> **!!! Burning an incorrect OTP, or having firmware voltage configuration that does not match the hardware configuration, may damage the chip!!!**

## Automatically Generate the OTP Configuration BIN File Based on Hardware Settings

Canaan provides a convenient graphical WEB interface to automatically generate the OTP configuration BIN file. During this process, be sure to fully communicate with hardware engineers to clarify hardware settings, voltage settings, and other key information.

Configuration tool link: [OTP Configuration Tool](https://www.kendryte.com/zh/tools/otp_config_generation_tool)

![otp_tool](https://www.kendryte.com/api/post/attachment?id=551)

When generating the BIN file, carefully select the corresponding configuration based on the hardware circuit diagram:

* UART IOMUX used by BOOT ROM printing: This option is used to select the serial port for BOOT log output (UART0 is recommended)
* UART voltage used by BOOT ROM printing: The voltage used by the BOOT output serial port
* OSPI IO voltage: The voltage of the OSPI domain
* SDIO0 IO voltage: The voltage of the MMC0 domain
* SDIO1 IOMUX: The pins selected for MMC1
* SDIO1 IO voltage: The voltage of the MMC1 domain

Taking the 01Studio development board schematic as an example, the options can be determined based on these parts:

![1740391481653](https://www.kendryte.com/api/post/attachment?id=802)

![1740391571191](https://www.kendryte.com/api/post/attachment?id=560)

![1740391632742](https://www.kendryte.com/api/post/attachment?id=561)

![1740391686205](https://www.kendryte.com/api/post/attachment?id=562)

Special reminder: Be sure to repeatedly verify the accuracy of the configuration with hardware engineers. Once a configuration error occurs and burning is performed, the chip is very likely to be permanently damaged and cannot be repaired!

After completing the above configuration, click the "Generate Configuration File" button to generate a BIN file. An example is as follows:

![1740392534136](https://www.kendryte.com/api/post/attachment?id=565)

## Burning the OTP BIN File

Burning tool download link: [Kendryte Developer Community - Downloads](https://www.kendryte.com/zh/resource?selected=0-2-2)

Please select the corresponding version to download based on your operating system. Also, please note: Do not power the development board for a long time before the OTP burning is complete, to avoid burning the chip.

![1740392907598](https://www.kendryte.com/api/post/attachment?id=567)

```{warning}
If UART0 is connected through an external USB-to-serial adapter module, please read [Serial Level and Adapter Module Safety](../app_develop_guide/peripheral/uart.md) first. You must confirm whether UART0 uses a 1.8 V or 3.3 V level; using 5 V signals and the inferior CH340G module shown in the image in the document is prohibited.
```

Power on the chip, connect the UART0 interface properly, open the BurningTool software, and select the previously generated BIN file:

![1740396173639](https://www.kendryte.com/api/post/attachment?id=568)

Click the "Start" button and wait patiently for the burning process to complete:

![1740469056238](https://www.kendryte.com/api/post/attachment?id=569)

After burning is complete, click "Confirm".

## OTP File in Secure Boot Scenarios

The above describes the process of manually generating the OTP configuration BIN file through the OTP configuration tool.

If you are automatically generating the OTP file through the SDK in a Secure Boot scenario, the output comes from `tools/gen_otp_config.py`, and the format is not a single raw BIN, but a `kdimg` with offset information.

The current Secure Boot generates the following files:

* `otp_config.json`: Records the slot strategy, written values, and burning file information.
* `otp_data.kdimg`: Contains only the OTP data area, with the target offset of `0`.
* `otp_key_lock.kdimg`: Contains only the OTP lock area, with the target offset of `1024`.
* `otp_full.kdimg`: Contains both the OTP data area and the OTP lock area.

The OTP slots currently used by Secure Boot are as follows:

| Stage | Mode | Symmetric Key Slot | Public Key Hash Slot |
| --- | --- | --- | --- |
| `spl` | SM4 + SM2 | `OTPKEY_4` | `OTPKEY_7` |
| `spl` | AES + RSA | `OTPKEY_2` | `OTPKEY_6` |
| `firmware` | SM4 + SM2 | `OTPKEY_5` | `OTPKEY_9` |
| `firmware` | AES + RSA | `OTPKEY_3` | `OTPKEY_8` |

The lock strategy is:

* The symmetric key slot lock is `NA`
* The public key hash slot lock is `RO`
* Each slot is locked by the full 32-byte slot

The burning positions of these files in BurningTool are controlled by the offset of the partition items inside the kdimg, and there is no need to manually split or splice them into a single raw 2KB file.

It is recommended to use them as follows:

1. If you want to burn in steps, import `otp_data.kdimg` and `otp_key_lock.kdimg` separately.
1. If you want to burn the complete OTP in one go, import `otp_full.kdimg` directly.
1. Before burning, open `otp_config.json` to confirm that the slot, offset, and written values are as expected.

For the complete Secure Boot configuration, build, and verification process, please read it together with `how_to_use_secureboot.md`.
