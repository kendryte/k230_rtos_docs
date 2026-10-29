# K230 Secure Boot 使用说明

本文档说明如何在 K230 RTOS SDK 中配置、构建、烧录并验证 Secure Boot。

## Secure Boot 设计简介

K230 RTOS SDK 的 Secure Boot 设计可以概括为一句话：由硬件先建立 `spl` 的信任，再由 `spl` 继续建立下游 `firmware` 的信任，整个软件栈只维护两级安全配置。

设计上有四个关键点：

- 信任链分两段：BROM 负责校验或解密 `spl`，U-Boot SPL 负责校验或解密下游 `firmware`。
- 配置模型只保留 `spl` 和 `firmware` 两个阶段：`u-boot.bin`、`opensbi_rtt_system.bin`、`rtapp` 统一归到 `firmware`，共享同一套密钥和 OTP 槽位策略；其中下游 `firmware` 的 `AES-GCM IV` 和 `SM4-CBC IV` 都按镜像动态生成。
- 密钥材料不直接散落在镜像里：对称密钥和公钥哈希写入 OTP，对应锁策略单独生成，运行时通过 `OTPKEY_x` 槽位让硬件安全单元参与解密和验签。
- 构建产物分层清晰：镜像打包负责生成带安全头的 `spl` 和下游镜像，OTP 工具负责生成 `otp_config.json`、`otp_data.kdimg`、`otp_key_lock.kdimg`、`otp_full.kdimg`，方便先检查再烧录。

下面这张图说明 Secure Boot 的配置入口、产物关系和信任链：

<div class="mermaid">
graph TD;
  A("板级 Secure Boot JSON<br/>只包含 spl / firmware") --> B("镜像打包脚本<br/>生成安全镜像");
  A --> C("gen_otp_config.py<br/>生成 OTP 配置和 kdimg");
  A --> D("gen_uboot_secure_header.py<br/>生成辅助头文件");
  B --> E("安全 SPL 镜像<br/>u-boot-spl.bin");
  B --> F("安全 firmware 镜像<br/>u-boot.bin / opensbi_rtt_system.bin / rtapp.elf.gz");
  C --> G("otp_config.json");
  C --> H("otp_data.kdimg / otp_key_lock.kdimg / otp_full.kdimg");
  H --> I("OTP 中的密钥、公钥哈希和锁位");
  I --> J("BROM");
  J --> E;
  E --> K("U-Boot SPL 运行时");
  D --> K;
  I --> K;
  K --> F;
</div>

理解这四点后，后面的配置、构建和烧录步骤就可以直接按“先确定阶段配置，再生成 OTP，最后烧录并验证启动”的思路来执行。

## 1. 先看整体流程

如果只关心怎么落地，可以直接按下面流程操作：

1. 选择一个带 Secure Boot 的 defconfig，例如执行 `make k230_rtos_evb_secureboot_defconfig`。
1. 不要直接复用仓库里的 demo 配置，先执行 `python tools/gen_secureboot_configs.py --output-dir <你的 secureboot 输出目录>` 生成新的板级 Secure Boot 配置和密钥材料。
1. 执行 `make menuconfig`，打开 `spl` 和 `firmware` 的 Secure Boot 选项，并关闭 `Prebuilt Uboot`。
1. 先执行 `make uboot`，生成源码版 U-Boot、辅助头文件以及 OTP 输出文件。
1. 打开 `otp_config.json`，确认 OTP 槽位、锁策略和生成的 `otp_data.kdimg`、`otp_key_lock.kdimg`、`otp_full.kdimg` 都符合预期。
1. 再执行 `make -j9`，生成完整镜像，例如 `fn_u-boot-spl.bin`、`fn_ug_u-boot.bin`、`opensbi_rtt_system.bin`、`rtapp.elf.gz`。
1. 先烧录 OTP，再烧录镜像，上电检查串口日志，确认能够正常解密并启动。

如果你是第一次接入 Secure Boot，推荐按下面顺序做：

1. 先验证普通非 Secure Boot 镜像能正常启动。
1. 再打开 Secure Boot 开关并生成 `otp_config.json`，只检查配置和输出文件，不急着烧 OTP。
1. 确认 `otp_config.json` 中的 key/hash 槽位和锁策略正确后，再烧录 OTP。
1. 最后烧录加密镜像并做串口启动验证。

## 2. Secure Boot 模型

### 2.1 模式

| 模式值 | 算法组合 | 说明 |
| --- | --- | --- |
| `0` | 无加密 + Hash | 仅完整性校验 |
| `1` | SM4 + SM2 | 国密方案 |
| `2` | AES + RSA | 国际方案 |

### 2.2 只有两个配置阶段

| 配置阶段 | 典型镜像 | 谁负责解密/校验 |
| --- | --- | --- |
| `spl` | `u-boot-spl.bin` | BROM |
| `firmware` | `u-boot.bin`、`opensbi_rtt_system.bin`、`rtapp.elf.gz` | U-Boot SPL |

这里最关键的一点是：

- JSON 顶层只允许 `spl` 和 `firmware` 两个对象。
- `u-boot.bin`、`opensbi_rtt_system.bin`、`rtapp.elf.gz` 共用同一套 `firmware` 密钥和 OTP 槽位策略；其中 `AES-GCM IV` 和 `SM4-CBC IV` 都按镜像动态生成。

## 3. 使用前必须知道的规则

### 3.1 `spl` 的 IV 不能自定义

`spl` 阶段必须使用 BROM 固定 IV。

- 如果 JSON 中没有填写 `spl` 的 IV，打包脚本会自动补成固定值。
- 如果 JSON 中填写了不同的 IV，脚本会覆盖为固定值，并输出 warning。

因此，`spl` 的 IV 以硬件规则为准，不以 JSON 中的填写值为准。

### 3.2 `firmware` 的 AES IV 按镜像动态生成，不写入 OTP

下游 `firmware` 的 `AES + RSA` 流程如下：

- 每个镜像在打包时动态生成新的 `AES-GCM IV`。
- 该 IV 会直接写入镜像密文载荷头部。
- U-Boot SPL 运行时从镜像中读取这个 IV，再结合 OTP 中的对称密钥完成 GCM 解密。

因此：

- `firmware` 的 `AES-GCM IV` 不需要写入 OTP。
- `firmware` 的 `AES-GCM IV` 不通过头文件固化进 U-Boot。
- 如果你看到 `otp_config.json` 中没有 IV 字段，这是符合当前设计的。

### 3.3 `firmware` 的 SM4 IV 也按镜像动态生成

下游 `firmware` 的 `SM4 + SM2` 流程如下：

- 每个镜像在打包时动态生成新的 `SM4-CBC IV`。
- 该 IV 会直接写入镜像密文载荷头部。
- U-Boot SPL 运行时从镜像中读取这个 IV，再结合 OTP 中的对称密钥完成 `SM4` 解密。

因此：

- `firmware` 的 `SM4 IV` 不需要写入 OTP。
- `firmware` 的 `SM4 IV` 不通过头文件固化进 U-Boot。
- 如果你看到 `otp_config.json` 中没有 `SM4 IV` 字段，这是符合当前设计的。

### 3.4 `firmware` 共用一组 OTP 槽位

OTP 槽位策略如下：

| 阶段 | 模式 | 对称密钥槽位 | 公钥哈希槽位 |
| --- | --- | --- | --- |
| `spl` | SM4 + SM2 | `OTPKEY_4` | `OTPKEY_7` |
| `spl` | AES + RSA | `OTPKEY_2` | `OTPKEY_6` |
| `firmware` | SM4 + SM2 | `OTPKEY_5` | `OTPKEY_9` |
| `firmware` | AES + RSA | `OTPKEY_3` | `OTPKEY_8` |

这组下游 `firmware` 槽位需要和 U-Boot 运行时解密代码保持一致。源码中的运行时定义如下：

- `AES + RSA` 使用 `OTPKEY_3` 和 `OTPKEY_8`
- `SM4 + SM2` 使用 `OTPKEY_5` 和 `OTPKEY_9`

### 3.5 OTP 里只放对称密钥和公钥哈希，不放 IV 或签名随机数

`tools/gen_otp_config.py` 会为每个阶段生成两类 OTP 条目：

- 对称密钥
- 公钥哈希

以下内容不会写入 OTP：

- `AES-GCM IV`
- `SM4 IV`
- `SM2 random_k`
- 私钥本身

以下内容不会写入 OTP：

- `AES-GCM IV`：`spl` 使用 BROM 固定 IV，`firmware` 使用镜像中携带的动态 IV。
- `SM4 IV`：`spl` 使用固定 BROM IV，`firmware` 使用镜像中携带的动态 IV。
- `SM2 random_k`：仅在签名时作为一次性随机数使用，运行期验签不需要，也不应固化到 OTP。

### 3.6 对称密钥和公钥哈希的默认锁策略

`tools/gen_otp_config.py` 的锁策略是：

- 对称密钥条目使用 `NA` 锁策略。
- 公钥哈希条目使用 `RO` 锁策略。

每个 OTP 槽位的锁位都是按 32 字节整槽写入，不会只锁实际数据长度对应的前半段字节。也就是说，哪怕 `SM4` 对称密钥本身只有 16 字节，最终也会锁住完整的 32 字节槽位。

因此在 `otp_key_lock.kdimg` 中，你会看到：

- 对称密钥槽位写入 `NA`
- 公钥哈希槽位写入 `RO`

实际烧录地址由 kdimg 分区项中的 offset 控制。

这不是异常行为。U-Boot 在运行时并不会去直接读取明文密钥，而是通过 PUFS API 按 `OTPKEY_x` 槽位调用硬件加解密单元。密钥可以被锁为 `NA`，但硬件仍然可以按槽位使用它。

### 3.7 RT-Smart 运行期代码执行约束

Secure Boot 只信任启动链中已经被 `firmware` 规则保护的内容，不信任运行期从文件系统重新读入的原始可执行文件。

因此在 `CONFIG_SECURE_BOOT_FIRMWARE_ENABLE=y` 时，需要按下面的规则理解 RT-Smart 的执行模型：

- 允许执行的 RT-App 入口是 `@preload`，它是一个内部 auto-exec 触发符，不对应文件系统中的真实 ELF，也不能从 `msh` 里当作普通命令手工执行；运行时会改为读取启动阶段已经预加载到内存中的 `rtapp`。
- 不允许从文件系统直接加载裸 ELF。
- 不允许在运行期再从文件系统加载 `/lib/ld.so`。
- 不允许启用 `dlmodule`、`dlopen`、`.mo` 模块执行这类动态模块机制。

另外，`CONFIG_RTT_AUTO_EXEC_CMD` 在 Secure Boot 场景下也有明确约束：

- 该配置必须以 `@preload` 开头。
- 如果配置成其他命令，系统会在启动时打印提示并跳过 auto exec，而不会回退去执行文件系统中的应用。

## 4. 如何配置

### 4.1 Kconfig 选项

Secure Boot 相关配置项包括一组 `spl` 和一组 `firmware`：

- `CONFIG_SECURE_BOOT_SPL_ENABLE`
- `CONFIG_SECURE_BOOT_SPL_SM4_SM2` / `CONFIG_SECURE_BOOT_SPL_AES_RSA`
- `CONFIG_SECURE_BOOT_FIRMWARE_ENABLE`
- `CONFIG_SECURE_BOOT_FIRMWARE_SM4_SM2` / `CONFIG_SECURE_BOOT_FIRMWARE_AES_RSA`
- `CONFIG_SECURE_BOOT_CONFIG_FILE`
- `CONFIG_RTT_AUTO_EXEC_CMD`

其中 `CONFIG_RTT_AUTO_EXEC_CMD` 需要特别注意：

- 非 Secure Boot 场景下，它仍然可以配置成普通 shell 自动执行命令。
- Secure Boot 场景下，它必须配置为以 `@preload` 开头的字符串；无参数时建议设置为 `@preload`，应用参数可直接跟在其后。
- 这里的 `@preload` 只用于内部 auto-exec 入口，不是提供给 `msh` 的通用命令接口。
- Fast Boot 的完整配置和验证方法见[如何使用 Fast Boot 与配置 RT-Smart 自动运行](../userguide/how_to_use_fast_boot.md)。

如果要在运行期直接查询或演练 OTP 安全配置，还需要关注下面三个 Kconfig：

- `RT_PUFS_ENABLE_BUILTIN_CMD`：打开内核侧 `pufs_otp` / `pufs_otp_sec` 命令。
- `RT_USING_PUFS_FILE_HASH`：打开 `sha256` 和兼容入口 `pufs_file_hash`。
- `RT_PUFS_OTP_WRITE_ENABLE`：控制 OTP 写入、锁定、key-to-OTP、zeroize 是否真的提交到硬件；关闭时只做 dry-run。

仓库中提供了一个可直接参考的示例 defconfig：

```sh
make k230_rtos_evb_secureboot_defconfig
```

该示例默认使用 `SM4 + SM2`。如果你要使用 `AES + RSA`，可以在 `menuconfig` 中切换算法后保存。

一个 `AES + RSA` 的 `.config` 片段示例如下：

```config
CONFIG_SECURE_BOOT_CONFIG_FILE="secureboot/secure_config_aes_rsa_pem.json"
CONFIG_SECURE_BOOT_SPL_ENABLE=y
CONFIG_SECURE_BOOT_SPL_AES_RSA=y
CONFIG_SECURE_BOOT_FIRMWARE_ENABLE=y
CONFIG_SECURE_BOOT_FIRMWARE_AES_RSA=y
```

建议将 `CONFIG_SECURE_BOOT_CONFIG_FILE` 配置为你自己生成的板级相对路径，例如：

```config
CONFIG_SECURE_BOOT_CONFIG_FILE="secureboot_local/secure_config_sm4_sm2.json"
```

### 4.2 JSON 配置文件结构

不要直接拿仓库里的 demo 配置量产。

推荐先生成一份新的 Secure Boot 配置和密钥材料，例如：

```sh
python tools/gen_secureboot_configs.py --output-dir boards/k230_evb/secureboot_local
```

生成后再把 `CONFIG_SECURE_BOOT_CONFIG_FILE` 指向该目录中的 JSON。

默认情况下，生成器会同时写出：

- `secure_config_aes_rsa_pem.json`
- `secure_config_sm4_sm2.json`
- `spl_rsa_pub.pem` / `spl_rsa_priv.pem`
- `firmware_rsa_pub.pem` / `firmware_rsa_priv.pem`

推荐将 Secure Boot 配置和密钥材料统一放在板级目录下，例如：

```text
boards/k230_evb/secureboot_local/
```

JSON 顶层结构如下：

```json
{
  "spl": {
    "firmware": {
      "version_bytes": "00000000"
    },
    "aes": {
      "key": "24501ad384e473963d476edcfe08205237acfd49b5b8f33857f8114e863fec7f",
      "auth_data": ""
    },
    "rsa": {
      "key_size": 2048,
      "public_key_file": "spl_rsa_pub.pem",
      "private_key_file": "spl_rsa_priv.pem"
    }
  },
  "firmware": {
    "firmware": {
      "version_bytes": "00000000"
    },
    "aes": {
      "key": "24501ad384e473963d476edcfe08205237acfd49b5b8f33857f8114e863fec7f",
      "auth_data": ""
    },
    "rsa": {
      "key_size": 2048,
      "public_key_file": "firmware_rsa_pub.pem",
      "private_key_file": "firmware_rsa_priv.pem"
    }
  }
}
```

请注意：

- `firmware` 段是所有下游镜像共享的唯一安全配置。
- 对于 `AES + RSA`：通常不需要在 JSON 中填写 `aes.iv`；`spl` 会使用 BROM 固定 IV，`firmware` 则按镜像动态生成 IV。
- 对于 `SM4 + SM2`：`spl.sm4.iv` 使用 BROM 固定 IV，生成脚本会写入这个固定值；`firmware` 按镜像动态生成 IV，JSON 中通常不包含 `firmware.sm4.iv`。

### 4.3 字段说明

#### 通用字段

- `firmware.version_bytes`：4 字节版本号。

#### AES + RSA 模式

- `aes.iv`：可选。`spl` 阶段使用固定 BROM IV；`firmware` 阶段默认每个镜像自动生成新的 `AES-GCM IV` 并写入镜像，因此通常不需要手工配置。
- `aes.key`：32 字节 AES 密钥。
- `aes.auth_data`：可选附加认证数据。
- `rsa.key_size`：使用 2048。
- `rsa.public_key_file` / `rsa.private_key_file`：可直接引用 PEM 文件。
- 也支持直接写 `rsa.modulus`、`rsa.exponent`、`rsa.private_exponent`。

#### SM4 + SM2 模式

- `sm4.key`：16 字节密钥。
- `sm4.iv`：`spl` 阶段使用固定 BROM IV；`firmware` 阶段每个镜像都会自动生成新的 `SM4-CBC IV` 并写入镜像，因此通常不需要配置 `firmware.sm4.iv`。
- `sm2.private_key`、`sm2.public_key_x`、`sm2.public_key_y`、`sm2.id`：SM2 必填材料。
- `sm2.random_k`：不再要求用户配置。当前签名流程会为每次签名自动生成新的随机 `k`，即使 JSON 中保留该字段也会被忽略。

## 5. 构建步骤

### 5.1 激活环境并选择配置

```sh
source ~/.canmv_venv/bin/activate # 可选
make k230_rtos_evb_secureboot_defconfig
make menuconfig
```

如果不使用 `k230_rtos_evb_secureboot_defconfig`，也可以先选择自己的板级 defconfig，再在 `menuconfig` 中手动打开 Secure Boot。

### 5.2 先编译源码版 U-Boot

```sh
make uboot
```

这个步骤除了编译 U-Boot 外，还会生成两类关键文件：

- 辅助头文件：`src/uboot/uboot/board/kendryte/common/secure_boot_config_autogen.h`
- OTP 输出文件：`output/<defconfig>/images/uboot/otp_config.json`、`otp_data.kdimg`、`otp_key_lock.kdimg`、`otp_full.kdimg`

如果你修改了密钥配置或者 Secure Boot 模式，这一步必须重跑。`firmware` 镜像使用的动态 IV 由镜像打包阶段写入载荷，不依赖头文件中的固定值。

### 5.3 再构建完整镜像

```sh
make -j9
```

顶层构建会继续打包：

- `fn_u-boot-spl.bin`
- `fn_ug_u-boot.bin`
- `opensbi_rtt_system.bin`
- `rtapp.elf.gz`

其中 `u-boot.bin`、`opensbi_rtt_system.bin`、`rtapp.elf.gz` 都会使用同一套 `firmware` Secure Boot 配置。

## 6. 构建完成后重点检查哪些文件

以 `k230_rtos_evb_secureboot_defconfig` 为例，建议重点检查下面这些输出物：

| 文件 | 用途 |
| --- | --- |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/fn_u-boot-spl.bin` | 打包后的 SPL 镜像 |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/fn_ug_u-boot.bin` | 打包后的 U-Boot 主镜像 |
| `output/k230_rtos_evb_secureboot_defconfig/images/opensbi/opensbi_rtt_system.bin` | 打包后的 OpenSBI + RT-Smart 镜像 |
| `output/k230_rtos_evb_secureboot_defconfig/images/rtapp/rtapp.elf.gz` | 打包后的 RT-App 镜像 |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/otp_config.json` | OTP 槽位和写入值说明 |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/otp_data.kdimg` | 仅包含 OTP 数据区的 kdimg |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/otp_key_lock.kdimg` | 仅包含 OTP 锁位区的 kdimg |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/otp_full.kdimg` | 同时包含 OTP 数据区和锁位区的 kdimg |

## 7. OTP 文件怎么理解

### 7.1 `otp_config.json`

这个文件是最重要的检查入口。烧录前请先确认：

- `slot_policy` 是否符合预期。
- `stages` 中是否只出现了你启用的阶段。
- `spl` 和 `firmware` 的密钥、公钥哈希是否写入了正确槽位。
- 不要期待在这个文件里看到 `IV` 或 `SM2 random_k`，这些信息不会写入 OTP。

对于 `AES + RSA`：

- `spl` 写入 `OTPKEY_2` 和 `OTPKEY_6`
- `firmware` 写入 `OTPKEY_3` 和 `OTPKEY_8`

对于 `SM4 + SM2`：

- `spl` 写入 `OTPKEY_4` 和 `OTPKEY_7`
- `firmware` 写入 `OTPKEY_5` 和 `OTPKEY_9`

### 7.2 `otp_data.kdimg`

这是一个 kdimg 容器，内部只有一个分区项：

- 分区名为 `otp_data`
- 烧录目标 offset 为 `0`
- 内容只覆盖 OTP 数据区，不包含锁位区

### 7.3 `otp_key_lock.kdimg`

这也是一个 kdimg 容器，内部只有一个分区项：

- 分区名为 `otp_key_lock`
- 烧录目标 offset 为 `1024`
- 内容只覆盖 OTP 锁位区

默认情况下：

- `spl` 对称密钥槽位会被锁。
- `firmware` 对称密钥槽位也会被锁。
- `spl` 和 `firmware` 的公钥哈希槽位会被锁为 `RO`。

如果同时启用了 `spl` 和 `firmware`，理论上应该能在对应槽位位置看到两组锁位，而不只是一组。

### 7.4 `otp_full.kdimg`

这是一个包含两个分区项的 kdimg：

- `otp_data`，target offset 为 `0`
- `otp_key_lock`，target offset 为 `1024`

适合一次性烧录完整 OTP 内容。

### 7.5 运行期 OTP 安全配置接口

除了离线生成 `otp_config.json` 和 kdimg 之外，SDK 还提供了运行期的 OTP 安全配置接口，主要用于查询状态、设置少量安全位以及在确认后锁定配置字。

> 建议在量产时必须配置以下选项，除 `disable_isp` 可视使用需求来决定。

支持的安全位包括：

- `disable_spi2axi`
- `disable_jtag`
- `force_secure_boot`
- `disable_isp`

这四个状态分别位于三个 RT OTP 配置字中：

- `0x0000`：`disable_spi2axi`
- `0x0004`：`disable_jtag`
- `0x000C`：`force_secure_boot` 和 `disable_isp`

其中 `disable_spi2axi` 的语义是：

- `0`：允许 SPI2AXI，默认值
- `1`：禁止 SPI2AXI

这些位遵循 OTP 的一次性编程语义：

- 只能从 `0 -> 1`
- 不能从 `1 -> 0`
- 锁定后对应配置字只能继续读，不能再写

用户态 HAL 对应接口为：

- `drv_pufs_otp_apply_security_config()`
- `drv_pufs_otp_get_security_config_state()`
- `drv_pufs_otp_lock_security_config_words()`

其中 `drv_pufs_otp_get_security_config_state()` 返回的状态结构除了逻辑位本身，还会返回：

- `spi2axi_word_lock`
- `jtag_word_lock`
- `boot_ctrl_word_lock`

内核态命令入口为：

- `pufs_otp read <addr> <len>`：读取扁平 OTP 地址空间中的原始内容
- `pufs_otp_sec query`：查询当前 SPI2AXI / JTAG / Secure Boot / ISP 状态以及对应 lock 状态
- `pufs_otp_sec write <spi2axi|jtag|secure_boot|isp|all> [...]`：把指定安全位写成 `1`
- `pufs_otp_sec lock`：把 `0x0000`、`0x0004` 和 `0x000C` 三个配置字锁成 `RO`

一个典型的运行期调用流程如下：

```c
pufs_otp_security_state_t state;

drv_pufs_otp_get_security_config_state(&dev, &state);
drv_pufs_otp_apply_security_config(&dev,
                                   true,   /* disable_spi2axi */
                                   false,  /* disable_jtag */
                                   false,  /* force_secure_boot */
                                   false); /* disable_isp */
drv_pufs_otp_lock_security_config_words(&dev);
```

对应的板上命令可以写成：

```sh
pufs_otp_sec query
pufs_otp_sec write spi2axi
```

如果启用了文件摘要命令，还可以使用：

- `sha256 <path>`：固定计算文件的 SHA-256
- `pufs_file_hash <path> [sha224|sha256|sha384|sha512|sha512_224|sha512_256|sm3]`：兼容入口，支持手工指定摘要算法

这组命令主要用于板上验证，不替代量产阶段的 OTP 生成和烧录流程。

### 7.6 Dry-run 行为怎么理解

`RT_PUFS_OTP_WRITE_ENABLE` 默认关闭。在默认配置下，OTP 相关操作不会真的写硬件，而是进入 dry-run 模式。

dry-run 的行为包括：

- 会先检查 lock 状态、地址范围和 OTP 位方向是否合法
- 如果请求非法，例如试图做 `1 -> 0`，会直接拒绝
- 如果请求合法，则打印“准备写什么、写到哪里”，但不会真正提交到 OTP

RT OTP 和 CDE OTP 的 dry-run 日志都已经细化到逐 word 级别，典型日志格式如下：

- `OTP WRITE DRY-RUN WORD: addr=0x004 cur=0x00000000 new=0x00000001`
- `CDE WRITE DRY-RUN WORD: offset=0x000 cur=0x00000000 new=0x00000001`

因此在正式打开 `RT_PUFS_OTP_WRITE_ENABLE` 前，建议先通过 dry-run 检查：

- 目标地址或 offset 是否正确
- `cur` 和 `new` 的差异是否符合预期
- 是否只发生了允许的 `0 -> 1` 置位

## 8. 烧录和验证建议

### 8.1 烧录 OTP 前先做三件事

1. 确认板级电压、启动介质和串口配置正确。
1. 打开 `otp_config.json`，逐项确认槽位、算法和写入值。
1. 确认当前镜像已经能正常构建，并且明文启动流程没有问题。

### 8.2 烧录 OTP

OTP 烧录操作请配合 `how_to_change_otp.md` 一起使用。

如果当前只是想先确认运行期 API 或命令的行为，建议先保持 `RT_PUFS_OTP_WRITE_ENABLE=n`，使用 dry-run 观察日志，不要直接在开发板上提交 OTP 写入。

实际烧录时，建议按以下顺序：

1. 先根据需要选择 `otp_data.kdimg` + `otp_key_lock.kdimg`，或者直接选择 `otp_full.kdimg`。
1. 确认 `otp_config.json` 中的 key/hash 槽位已经和当前配置匹配，例如 `firmware` 的 `AES + RSA` 为 `OTPKEY_3/8`，`SM4 + SM2` 为 `OTPKEY_5/9`。
1. 再烧录加密后的镜像。
1. 最后上电检查串口日志。

### 8.3 启动验证

正常情况下应能看到：

- `spl` 正常进入 U-Boot。
- `u-boot`、`opensbi_rtt_system.bin` 或 `rtapp.elf.gz` 能被正常解密加载。
- OpenSBI、RT-Smart 和应用流程继续启动。

## 9. 常见失败现象

| 日志或报错 | 常见原因 |
| --- | --- |
| `Failed to generate secure boot runtime header: Missing required field '...'` | JSON 中缺少对应算法必填字段，常见于 `rsa.exponent`、`rsa.private_exponent` 等字段被误删 |
| `rsa pubkey hash mismatch` | OTP 中的 RSA 公钥哈希与镜像签名使用的公钥不一致 |
| `rsa signature verify error` | RSA 签名材料不一致或镜像被破坏 |
| `gcm init error` / `gcm final error` | `AES` 密钥不匹配、镜像载荷中的 IV 与格式不匹配，或认证材料不匹配 |
| `sm2 pubkey hash mismatch` | OTP 中的 SM2 公钥哈希与镜像使用的公钥不一致 |
| `sm2 signature verify error` | SM2 签名材料不一致或镜像被破坏 |
| `sm4 decrypt error` | `SM4` 密钥不匹配、镜像载荷中的 IV 与格式不匹配，或镜像被破坏 |
| `firmware rollback detected` | 镜像版本号小于 OTP 中记录的版本 |
| `bad magic` | 解密后的明文不是合法镜像，通常是密钥、IV 或算法不匹配 |
| `Conflicting OTP data` | 同一 OTP 槽位被写入了不同内容 |
| `OTP WRITE DENIED ... bit 1->0` | 试图把已经置位的 OTP bit 清回 `0`，违反 OTP 只能 `0 -> 1` 的规则 |
| `OTP WRITE DENIED ... locked (RO/NA)` | 目标配置字或槽位已经被锁，运行期写入被拒绝 |

## 10. 使用建议

### 10.1 调试阶段不要依赖预编译 U-Boot

调试 Secure Boot 时，建议关闭预编译模式，优先使用源码版 U-Boot。这样在你修改密钥配置或算法后，辅助头文件和 U-Boot 本体能够同步更新。

### 10.2 先验证普通启动，再烧录 OTP

推荐顺序是：

1. 先验证普通镜像能正常启动。
1. 再验证 Secure Boot 镜像能正常构建。
1. 最后再烧录 OTP。

这样可以把镜像问题和 OTP 问题分开排查。

### 10.3 修改安全材料后先重编 U-Boot

只要修改了下游 `firmware` 的密钥或算法，就应该先重新执行：

```sh
make uboot
```

否则辅助头文件和相关打包产物仍可能保留旧配置。

### 10.4 先用运行期查询命令核对板上状态

如果板子已经写入过部分 OTP，建议在继续操作前先通过命令读取当前状态：

```sh
pufs_otp_sec query
pufs_otp read 0x0004 4
pufs_otp read 0x000C 4
```

这样可以先确认：

- JTAG / Secure Boot / ISP 位是否已经被编程
- 对应配置字是否已经被锁定
- 板上状态是否和 `otp_config.json`、量产预期一致

### 10.5 在开发阶段把文件系统执行面收紧理解清楚

Secure Boot 打开后，启动链信任的是 `spl -> firmware`，不信任运行期从文件系统重新取回的原始 ELF。

因此开发阶段不要把下面这些行为当成“Secure Boot 仍然有效”的前提：

- 从文件系统手工加载裸 ELF
- 运行期再加载 `/lib/ld.so`
- 打开 `dlmodule`、`dlopen` 或类似动态模块装载能力

如果确实需要做后装应用分发，应该设计新的受保护应用格式，并复用现有 firmware 级别的验签/解密链路。

## 11. 相关文件

如需继续查看实现细节，可参考：

- 顶层配置：`.config`
- Secure Boot Kconfig：`Kconfig.secureboot`
- 示例 defconfig：`configs/k230_rtos_evb_secureboot_defconfig`
- 板级示例配置：`boards/k230_evb/secureboot/`
- U-Boot 打包脚本：`tools/gen_image_uboot.py`
- OpenSBI + RT-Smart 打包脚本：`tools/gen_image_opensbi.py`
- RT-App 打包脚本：`tools/gen_image_rtapp.py`
- OTP 生成脚本：`tools/gen_otp_config.py`
- U-Boot 辅助头文件生成脚本：`tools/gen_uboot_secure_header.py`
- Secure Boot 配置解析：`tools/image_tools/k230_image_generator.py`
