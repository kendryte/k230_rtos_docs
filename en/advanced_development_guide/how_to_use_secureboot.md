# K230 Secure Boot Usage Instructions

This document describes how to configure, build, flash, and verify Secure Boot in the K230 RTOS SDK.

## Secure Boot Design Overview

The Secure Boot design of the K230 RTOS SDK can be summarized in one sentence: the hardware first establishes trust in `spl`, and then `spl` continues to establish trust in the downstream `firmware`. The entire software stack maintains only two levels of security configuration.

There are four key points in the design:

- The trust chain is divided into two segments: BROM is responsible for verifying or decrypting `spl`, and U-Boot SPL is responsible for verifying or decrypting the downstream `firmware`.
- The configuration model only retains two stages, `spl` and `firmware`: `u-boot.bin`, `opensbi_rtt_system.bin`, and `rtapp` are uniformly grouped under `firmware`, sharing the same set of keys and OTP slot policies; among them, the `AES-GCM IV` and `SM4-CBC IV` of the downstream `firmware` are dynamically generated per image.
- Key materials are not directly scattered across images: symmetric keys and public key hashes are written into OTP, corresponding lock policies are generated separately, and at runtime the `OTPKEY_x` slots are used to let the hardware security unit participate in decryption and signature verification.
- Build artifacts are clearly layered: image packaging is responsible for generating the `spl` with a security header and downstream images, and the OTP tool is responsible for generating `otp_config.json`, `otp_data.kdimg`, `otp_key_lock.kdimg`, `otp_full.kdimg`, making it easy to inspect before flashing.

The following diagram illustrates the Secure Boot configuration entry points, artifact relationships, and trust chain:

<div class="mermaid">
graph TD;
  A("Board-level Secure Boot JSON<br/>only contains spl / firmware") --> B("Image packaging script<br/>generates secure images");
  A --> C("gen_otp_config.py<br/>generates OTP config and kdimg");
  A --> D("gen_uboot_secure_header.py<br/>generates auxiliary header files");
  B --> E("Secure SPL image<br/>u-boot-spl.bin");
  B --> F("Secure firmware images<br/>u-boot.bin / opensbi_rtt_system.bin / rtapp.elf.gz");
  C --> G("otp_config.json");
  C --> H("otp_data.kdimg / otp_key_lock.kdimg / otp_full.kdimg");
  H --> I("Keys, public key hashes, and lock bits in OTP");
  I --> J("BROM");
  J --> E;
  E --> K("U-Boot SPL runtime");
  D --> K;
  I --> K;
  K --> F;
</div>

After understanding these four points, the subsequent configuration, build, and flashing steps can be directly executed following the approach of "first determine the stage configuration, then generate OTP, and finally flash and verify boot."

## 1. Overall Process Overview

If you only care about how to get it running, you can directly follow the process below:

1. Select a defconfig with Secure Boot, for example, run `make k230_rtos_evb_secureboot_defconfig`.
1. Do not directly reuse the demo configuration in the repository. First run `python tools/gen_secureboot_configs.py --output-dir <your secureboot output directory>` to generate new board-level Secure Boot configuration and key materials.
1. Run `make menuconfig`, enable the Secure Boot options for `spl` and `firmware`, and disable `Prebuilt Uboot`.
1. First run `make uboot` to generate the source-version U-Boot, auxiliary header files, and OTP output files.
1. Open `otp_config.json` and confirm that the OTP slots, lock policies, and the generated `otp_data.kdimg`, `otp_key_lock.kdimg`, `otp_full.kdimg` all meet expectations.
1. Then run `make -j9` to generate the complete images, such as `fn_u-boot-spl.bin`, `fn_ug_u-boot.bin`, `opensbi_rtt_system.bin`, `rtapp.elf.gz`.
1. First flash OTP, then flash the images, power on and check the serial port log to confirm that it can be decrypted and boot normally.

If this is your first time integrating Secure Boot, the following order is recommended:

1. First verify that a regular non-Secure Boot image can boot normally.
1. Then enable the Secure Boot switch and generate `otp_config.json`, only checking the configuration and output files without rushing to burn OTP.
1. After confirming that the key/hash slots and lock policies in `otp_config.json` are correct, then flash the OTP.
1. Finally, flash the encrypted images and perform serial port boot verification.

## 2. Secure Boot Model

### 2.1 Modes

| Mode Value | Algorithm Combination | Description |
| --- | --- | --- |
| `0` | No encryption + Hash | Integrity check only |
| `1` | SM4 + SM2 | National cryptography scheme |
| `2` | AES + RSA | International scheme |

### 2.2 Only Two Configuration Stages

| Configuration Stage | Typical Images | Who Decrypts/Verifies |
| --- | --- | --- |
| `spl` | `u-boot-spl.bin` | BROM |
| `firmware` | `u-boot.bin`, `opensbi_rtt_system.bin`, `rtapp.elf.gz` | U-Boot SPL |

The most critical points here are:

- The top level of the JSON only allows two objects: `spl` and `firmware`.
- `u-boot.bin`, `opensbi_rtt_system.bin`, and `rtapp.elf.gz` share the same set of `firmware` keys and OTP slot policies; among them, `AES-GCM IV` and `SM4-CBC IV` are dynamically generated per image.

## 3. Rules You Must Know Before Use

### 3.1 `spl`'s IV Cannot Be Customized

The `spl` stage must use the BROM fixed IV.

- If the JSON does not fill in `spl`'s IV, the packaging script will automatically fill in the fixed value.
- If a different IV is filled in the JSON, the script will override it with the fixed value and output a warning.

Therefore, `spl`'s IV follows the hardware rules, not the value filled in the JSON.

### 3.2 `firmware`'s AES IV Is Dynamically Generated Per Image, Not Written to OTP

The downstream `firmware`'s `AES + RSA` flow is as follows:

- Each image dynamically generates a new `AES-GCM IV` at packaging time.
- This IV is written directly into the image ciphertext payload header.
- U-Boot SPL reads this IV from the image at runtime, then combines it with the symmetric key in OTP to complete GCM decryption.

Therefore:

- `firmware`'s `AES-GCM IV` does not need to be written to OTP.
- `firmware`'s `AES-GCM IV` is not baked into U-Boot via header files.
- If you see no IV field in `otp_config.json`, this is consistent with the current design.

### 3.3 `firmware`'s SM4 IV Is Also Dynamically Generated Per Image

The downstream `firmware`'s `SM4 + SM2` flow is as follows:

- Each image dynamically generates a new `SM4-CBC IV` at packaging time.
- This IV is written directly into the image ciphertext payload header.
- U-Boot SPL reads this IV from the image at runtime, then combines it with the symmetric key in OTP to complete `SM4` decryption.

Therefore:

- `firmware`'s `SM4 IV` does not need to be written to OTP.
- `firmware`'s `SM4 IV` is not baked into U-Boot via header files.
- If you see no `SM4 IV` field in `otp_config.json`, this is consistent with the current design.

### 3.4 `firmware` Shares One Set of OTP Slots

The OTP slot strategy is as follows:

| Stage | Mode | Symmetric Key Slot | Public Key Hash Slot |
| --- | --- | --- | --- |
| `spl` | SM4 + SM2 | `OTPKEY_4` | `OTPKEY_7` |
| `spl` | AES + RSA | `OTPKEY_2` | `OTPKEY_6` |
| `firmware` | SM4 + SM2 | `OTPKEY_5` | `OTPKEY_9` |
| `firmware` | AES + RSA | `OTPKEY_3` | `OTPKEY_8` |

This set of downstream `firmware` slots needs to remain consistent with U-Boot's runtime decryption code. The runtime definitions in the source code are as follows:

- `AES + RSA` uses `OTPKEY_3` and `OTPKEY_8`
- `SM4 + SM2` uses `OTPKEY_5` and `OTPKEY_9`

### 3.5 OTP Only Stores Symmetric Key and Public Key Hash, Not IV or Signature Random

`tools/gen_otp_config.py` generates two types of OTP entries for each stage:

- Symmetric key
- Public key hash

The following content is NOT written to OTP:

- `AES-GCM IV`
- `SM4 IV`
- `SM2 random_k`
- The private key itself

The following content is NOT written to OTP:

- `AES-GCM IV`: `spl` uses the BROM fixed IV, `firmware` uses the dynamic IV carried in the image.
- `SM4 IV`: `spl` uses the fixed BROM IV, `firmware` uses the dynamic IV carried in the image.
- `SM2 random_k`: Used only as a one-time random during signing; runtime signature verification does not need it, and it should not be baked into OTP.

### 3.6 Default Lock Policy for Symmetric Key and Public Key Hash

The lock policy of `tools/gen_otp_config.py` is:

- Symmetric key entries use the `NA` lock policy.
- Public key hash entries use the `RO` lock policy.

The lock bits for each OTP slot are written as a full 32-byte slot, not just the first half corresponding to the actual data length. In other words, even if the `SM4` symmetric key itself is only 16 bytes, the full 32-byte slot will be locked in the end.

Therefore, in `otp_key_lock.kdimg`, you will see:

- `NA` written for the symmetric key slot
- `RO` written for the public key hash slot

The actual burning address is controlled by the offset in the kdimg partition entry.

This is not abnormal behavior. U-Boot does not directly read the plaintext key at runtime; instead, it calls the hardware crypto unit through the PUFS API by the `OTPKEY_x` slot. A key can be locked as `NA`, but the hardware can still use it by slot.

### 3.7 RT-Smart Runtime Code Execution Constraints

Secure Boot only trusts content in the boot chain that has already been protected by `firmware` rules; it does not trust raw executables re-read from the file system at runtime.

Therefore, when `CONFIG_SECURE_BOOT_FIRMWARE_ENABLE=y`, the RT-Smart execution model needs to be understood according to the following rules:

- The allowed RT-App entry is `@preload`, which is an internal auto-exec trigger that does not correspond to a real ELF in the file system, and cannot be manually executed as a regular command from `msh`; at runtime it is changed to read the `rtapp` that has been preloaded into memory during the boot stage.
- It is not allowed to directly load raw ELF from the file system.
- It is not allowed to re-load `/lib/ld.so` from the file system at runtime.
- It is not allowed to enable dynamic module mechanisms such as `dlmodule`, `dlopen`, or `.mo` module execution.

In addition, `CONFIG_RTT_AUTO_EXEC_CMD` also has clear constraints in the Secure Boot scenario:

- This configuration must start with `@preload`.
- If it is configured as another command, the system will print a prompt at startup and skip auto exec, instead of falling back to executing applications from the file system.

## 4. How to Configure

### 4.1 Kconfig Options

Secure Boot related configuration items include one set of `spl` and one set of `firmware`:

- `CONFIG_SECURE_BOOT_SPL_ENABLE`
- `CONFIG_SECURE_BOOT_SPL_SM4_SM2` / `CONFIG_SECURE_BOOT_SPL_AES_RSA`
- `CONFIG_SECURE_BOOT_FIRMWARE_ENABLE`
- `CONFIG_SECURE_BOOT_FIRMWARE_SM4_SM2` / `CONFIG_SECURE_BOOT_FIRMWARE_AES_RSA`
- `CONFIG_SECURE_BOOT_CONFIG_FILE`
- `CONFIG_RTT_AUTO_EXEC_CMD`

Among them, `CONFIG_RTT_AUTO_EXEC_CMD` requires special attention:

- In non-Secure Boot scenarios, it can still be configured as a regular shell auto-execution command.
- In Secure Boot scenarios, it must be configured as a string starting with `@preload`; when there are no arguments, it is recommended to set it to `@preload`, and application arguments can directly follow it.
- The `@preload` here is only used for the internal auto-exec entry and is not a general-purpose command interface provided to `msh`.
- For complete Fast Boot configuration and verification methods, see [How to Use Fast Boot and Configure RT-Smart Auto-Run](../userguide/how_to_use_fast_boot.md).

If you need to directly query or rehearse OTP security configuration at runtime, you also need to pay attention to the following three Kconfigs:

- `RT_PUFS_ENABLE_BUILTIN_CMD`: Enables kernel-side `pufs_otp` / `pufs_otp_sec` commands.
- `RT_USING_PUFS_FILE_HASH`: Enables `sha256` and the compatible entry `pufs_file_hash`.
- `RT_PUFS_OTP_WRITE_ENABLE`: Controls whether OTP write, lock, key-to-OTP, and zeroize operations are actually committed to hardware; when disabled, only dry-run is performed.

The repository provides a directly referenceable example defconfig:

```sh
make k230_rtos_evb_secureboot_defconfig
```

This example uses `SM4 + SM2` by default. If you want to use `AES + RSA`, you can switch the algorithm in `menuconfig` and save.

An example `.config` snippet for `AES + RSA` is as follows:

```config
CONFIG_SECURE_BOOT_CONFIG_FILE="secureboot/secure_config_aes_rsa_pem.json"
CONFIG_SECURE_BOOT_SPL_ENABLE=y
CONFIG_SECURE_BOOT_SPL_AES_RSA=y
CONFIG_SECURE_BOOT_FIRMWARE_ENABLE=y
CONFIG_SECURE_BOOT_FIRMWARE_AES_RSA=y
```

It is recommended to configure `CONFIG_SECURE_BOOT_CONFIG_FILE` as a board-level relative path generated by yourself, for example:

```config
CONFIG_SECURE_BOOT_CONFIG_FILE="secureboot_local/secure_config_sm4_sm2.json"
```

### 4.2 JSON Configuration File Structure

Do not directly use the demo configuration in the repository for mass production.

It is recommended to first generate a new Secure Boot configuration and key material, for example:

```sh
python tools/gen_secureboot_configs.py --output-dir boards/k230_evb/secureboot_local
```

After generation, point `CONFIG_SECURE_BOOT_CONFIG_FILE` to the JSON in that directory.

By default, the generator writes out:

- `secure_config_aes_rsa_pem.json`
- `secure_config_sm4_sm2.json`
- `spl_rsa_pub.pem` / `spl_rsa_priv.pem`
- `firmware_rsa_pub.pem` / `firmware_rsa_priv.pem`

It is recommended to place Secure Boot configuration and key material under the board-level directory, for example:

```text
boards/k230_evb/secureboot_local/
```

The JSON top-level structure is as follows:

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

Please note:

- The `firmware` section is the unique security configuration shared by all downstream images.
- For `AES + RSA`: usually there is no need to fill in `aes.iv` in JSON; `spl` uses the BROM fixed IV, while `firmware` dynamically generates the IV per image.
- For `SM4 + SM2`: `spl.sm4.iv` uses the BROM fixed IV, and the generation script writes this fixed value; `firmware` dynamically generates the IV per image, and the JSON usually does not contain `firmware.sm4.iv`.

### 4.3 Field Description

#### Common Fields

- `firmware.version_bytes`: 4-byte version number.

#### AES + RSA Mode

- `aes.iv`: Optional. The `spl` stage uses the fixed BROM IV; the `firmware` stage defaults to automatically generating a new `AES-GCM IV` for each image and writing it into the image, so manual configuration is usually not required.
- `aes.key`: 32-byte AES key.
- `aes.auth_data`: Optional additional authentication data.
- `rsa.key_size`: Use 2048.
- `rsa.public_key_file` / `rsa.private_key_file`: Can directly reference PEM files.
- Also supports directly writing `rsa.modulus`, `rsa.exponent`, `rsa.private_exponent`.

#### SM4 + SM2 Mode

- `sm4.key`: 16-byte key.
- `sm4.iv`: The `spl` stage uses the fixed BROM IV; the `firmware` stage automatically generates a new `SM4-CBC IV` for each image and writes it into the image, so configuring `firmware.sm4.iv` is usually not required.
- `sm2.private_key`, `sm2.public_key_x`, `sm2.public_key_y`, `sm2.id`: SM2 required material.
- `sm2.random_k`: No longer required to be configured by the user. The current signing process automatically generates a new random `k` for each signature, even if this field is retained in JSON it will be ignored.

## 5. Build Steps

### 5.1 Activate Environment and Select Configuration

```sh
source ~/.canmv_venv/bin/activate # optional
make k230_rtos_evb_secureboot_defconfig
make menuconfig
```

If you do not use `k230_rtos_evb_secureboot_defconfig`, you can also first select your own board-level defconfig, and then manually enable Secure Boot in `menuconfig`.

### 5.2 Compile the Source Version of U-Boot First

```sh
make uboot
```

In addition to compiling U-Boot, this step also generates two types of key files:

- Auxiliary header file: `src/uboot/uboot/board/kendryte/common/secure_boot_config_autogen.h`
- OTP output files: `output/<defconfig>/images/uboot/otp_config.json`, `otp_data.kdimg`, `otp_key_lock.kdimg`, `otp_full.kdimg`

If you modify the key configuration or Secure Boot mode, this step must be re-run. The dynamic IV used by the `firmware` image is written into the payload during the image packaging stage, and does not depend on the fixed values in the header file.

### 5.3 Then Build the Complete Image

```sh
make -j9
```

The top-level build will continue packaging:

- `fn_u-boot-spl.bin`
- `fn_ug_u-boot.bin`
- `opensbi_rtt_system.bin`
- `rtapp.elf.gz`

Among them, `u-boot.bin`, `opensbi_rtt_system.bin`, and `rtapp.elf.gz` all use the same set of `firmware` Secure Boot configuration.

## 6. Which files to focus on after the build completes

Taking `k230_rtos_evb_secureboot_defconfig` as an example, it is recommended to focus on verifying the following outputs:

| File | Purpose |
| --- | --- |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/fn_u-boot-spl.bin` | Packaged SPL image |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/fn_ug_u-boot.bin` | Packaged U-Boot main image |
| `output/k230_rtos_evb_secureboot_defconfig/images/opensbi/opensbi_rtt_system.bin` | Packaged OpenSBI + RT-Smart image |
| `output/k230_rtos_evb_secureboot_defconfig/images/rtapp/rtapp.elf.gz` | Packaged RT-App image |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/otp_config.json` | OTP slot and write-value description |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/otp_data.kdimg` | kdimg containing only the OTP data area |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/otp_key_lock.kdimg` | kdimg containing only the OTP lock-bit area |
| `output/k230_rtos_evb_secureboot_defconfig/images/uboot/otp_full.kdimg` | kdimg containing both the OTP data area and the lock-bit area |

## 7. How to understand the OTP files

### 7.1 `otp_config.json`

This file is the most important verification entry point. Before burning, please confirm:

- Whether `slot_policy` matches expectations.
- Whether `stages` only contains the stages you have enabled.
- Whether the `spl` and `firmware` keys and public key hashes are written to the correct slots.
- Do not expect to see `IV` or `SM2 random_k` in this file; this information will not be written to OTP.

For `AES + RSA`:

- `spl` writes to `OTPKEY_2` and `OTPKEY_6`
- `firmware` writes to `OTPKEY_3` and `OTPKEY_8`

For `SM4 + SM2`:

- `spl` writes to `OTPKEY_4` and `OTPKEY_7`
- `firmware` writes to `OTPKEY_5` and `OTPKEY_9`

### 7.2 `otp_data.kdimg`

This is a kdimg container with only one partition entry inside:

- The partition name is `otp_data`
- The burn target offset is `0`
- The content covers only the OTP data area, not the lock-bit area

### 7.3 `otp_key_lock.kdimg`

This is also a kdimg container with only one partition entry inside:

- The partition name is `otp_key_lock`
- The burn target offset is `1024`
- The content covers only the OTP lock-bit area

By default:

- The `spl` symmetric key slots will be locked.
- The `firmware` symmetric key slots will also be locked.
- The public key hash slots for `spl` and `firmware` will be locked as `RO`.

If both `spl` and `firmware` are enabled, you should theoretically see two sets of lock bits at the corresponding slot positions, not just one set.

### 7.4 `otp_full.kdimg`

This is a kdimg containing two partition entries:

- `otp_data`, with target offset `0`
- `otp_key_lock`, with target offset `1024`

It is suitable for burning the complete OTP content in one go.

### 7.5 Runtime OTP security configuration interface

In addition to offline generation of `otp_config.json` and kdimg, the SDK also provides runtime OTP security configuration interfaces, which are mainly used to query status, set a small number of security bits, and lock the configuration words after confirmation.

> It is recommended that the following options must be configured in mass production, except for `disable_isp`, which can be decided based on usage requirements.

The supported security bits include:

- `disable_spi2axi`
- `disable_jtag`
- `force_secure_boot`
- `disable_isp`

These four states reside in three RT OTP configuration words:

- `0x0000`: `disable_spi2axi`
- `0x0004`: `disable_jtag`
- `0x000C`: `force_secure_boot` and `disable_isp`

The semantics of `disable_spi2axi` are:

- `0`: SPI2AXI is allowed, the default value
- `1`: SPI2AXI is prohibited

These bits follow the OTP one-time programming semantics:

- Can only transition from `0 -> 1`
- Cannot transition from `1 -> 0`
- After locking, the corresponding configuration word can only be read, not written again

The user-space HAL corresponding interfaces are:

- `drv_pufs_otp_apply_security_config()`
- `drv_pufs_otp_get_security_config_state()`
- `drv_pufs_otp_lock_security_config_words()`

The state structure returned by `drv_pufs_otp_get_security_config_state()`, in addition to the logical bits themselves, also returns:

- `spi2axi_word_lock`
- `jtag_word_lock`
- `boot_ctrl_word_lock`

The kernel-space command entries are:

- `pufs_otp read <addr> <len>`: read the raw content in the flat OTP address space
- `pufs_otp_sec query`: query the current SPI2AXI / JTAG / Secure Boot / ISP status and the corresponding lock status
- `pufs_otp_sec write <spi2axi|jtag|secure_boot|isp|all> [...]`: write the specified security bits to `1`
- `pufs_otp_sec lock`: lock the three configuration words `0x0000`, `0x0004`, and `0x000C` as `RO`

A typical runtime call flow is as follows:

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

The corresponding on-board commands can be written as:

```sh
pufs_otp_sec query
pufs_otp_sec write spi2axi
```

If the file digest command is also enabled, you can also use:

- `sha256 <path>`: compute the SHA-256 of a file deterministically
- `pufs_file_hash <path> [sha224|sha256|sha384|sha512|sha512_224|sha512_256|sm3]`: a compatible entry point that supports manually specifying the digest algorithm

This set of commands is primarily used for on-board verification and does not replace the OTP generation and burning process in the mass production stage.

### 7.6 How to understand Dry-run behavior

`RT_PUFS_OTP_WRITE_ENABLE` is disabled by default. Under the default configuration, OTP-related operations will not actually write to the hardware, but will enter dry-run mode.

The behavior of dry-run includes:

- It will first check whether the lock status, address range, and OTP bit direction are valid
- If the request is invalid, for example, attempting a `1 -> 0`, it will be rejected directly
- If the request is valid, it will print "what is to be written, and where", but will not actually commit to OTP

The dry-run logs for both RT OTP and CDE OTP have been refined to the per-word level, with the typical log format as follows:

- `OTP WRITE DRY-RUN WORD: addr=0x004 cur=0x00000000 new=0x00000001`
- `CDE WRITE DRY-RUN WORD: offset=0x000 cur=0x00000000 new=0x00000001`

Therefore, before officially enabling `RT_PUFS_OTP_WRITE_ENABLE`, it is recommended to first use dry-run to check:

- Whether the target address or offset is correct
- Whether the difference between `cur` and `new` is as expected
- Whether only the permitted `0 -> 1` setting has occurred

## 8. Burning and Verification Recommendations

### 8.1 Do Three Things Before Burning OTP

1. Confirm that the board-level voltage, boot medium, and serial port configuration are correct.
1. Open `otp_config.json` and verify each slot, algorithm, and write value item by item.
1. Confirm that the current image can be built normally and that the plaintext boot process has no issues.

### 8.2 Burning OTP

Please use the OTP burning operation together with `how_to_change_otp.md`.

If the current goal is only to verify the behavior of the runtime API or commands, it is recommended to keep `RT_PUFS_OTP_WRITE_ENABLE=n` first, use dry-run to observe the logs, and do not directly submit OTP writes on the development board.

When actually burning, it is recommended to follow the order below:

1. First, select `otp_data.kdimg` + `otp_key_lock.kdimg` as needed, or directly select `otp_full.kdimg`.
1. Confirm that the key/hash slots in `otp_config.json` match the current configuration, for example, `firmware`'s `AES + RSA` is `OTPKEY_3/8`, and `SM4 + SM2` is `OTPKEY_5/9`.
1. Then burn the encrypted image.
1. Finally, power on and check the serial port logs.

### 8.3 Boot Verification

Under normal circumstances, you should see:

- `spl` enters U-Boot normally.
- `u-boot`, `opensbi_rtt_system.bin`, or `rtapp.elf.gz` can be decrypted and loaded normally.
- OpenSBI, RT-Smart, and the application flow continue to start.

## 9. Common Failure Symptoms

| Log or Error Message | Common Cause |
| --- | --- |
| `Failed to generate secure boot runtime header: Missing required field '...'` | The corresponding required field for the algorithm is missing in the JSON. This is commonly seen when fields like `rsa.exponent` and `rsa.private_exponent` are accidentally deleted |
| `rsa pubkey hash mismatch` | The RSA public key hash in the OTP does not match the public key used to sign the image |
| `rsa signature verify error` | The RSA signature material is inconsistent, or the image is corrupted |
| `gcm init error` / `gcm final error` | The `AES` key does not match, the IV in the image payload does not match the format, or the authentication material is inconsistent |
| `sm2 pubkey hash mismatch` | The SM2 public key hash in the OTP does not match the public key used by the image |
| `sm2 signature verify error` | The SM2 signature material is inconsistent, or the image is corrupted |
| `sm4 decrypt error` | The `SM4` key does not match, the IV in the image payload does not match the format, or the image is corrupted |
| `firmware rollback detected` | The image version number is smaller than the version recorded in the OTP |
| `bad magic` | The decrypted plaintext is not a valid image, usually due to mismatched key, IV, or algorithm |
| `Conflicting OTP data` | Different contents have been written to the same OTP slot |
| `OTP WRITE DENIED ... bit 1->0` | Attempting to clear an already-set OTP bit back to `0`, violating the OTP `0 -> 1`-only rule |
| `OTP WRITE DENIED ... locked (RO/NA)` | The target configuration word or slot has already been locked, and the runtime write is denied |

## 10. Usage Recommendations

### 10.1 Do Not Rely on Pre-compiled U-Boot During Debugging

When debugging Secure Boot, it is recommended to disable the pre-compiled mode and prefer the source-code version of U-Boot. This way, after you modify the key configuration or algorithm, the auxiliary header files and the U-Boot binary can be updated synchronously.

### 10.2 Verify Normal Boot First, Then Burn OTP

The recommended order is:

1. First verify that the normal image can boot correctly.
1. Then verify that the Secure Boot image can be built correctly.
1. Finally, burn the OTP.

This way, image issues and OTP issues can be troubleshot separately.

### 10.3 Rebuild U-Boot After Modifying Security Materials

Whenever you modify the key or algorithm of the downstream `firmware`, you should first re-execute:

```sh
make uboot
```

Otherwise, the auxiliary header files and related packaging artifacts may still retain the old configuration.

### 10.4 Use Runtime Query Commands to Verify On-Board Status First

If the board has already had part of the OTP written, it is recommended to read the current status via commands before continuing:

```sh
pufs_otp_sec query
pufs_otp read 0x0004 4
pufs_otp read 0x000C 4
```

This allows you to first confirm:

- Whether the JTAG / Secure Boot / ISP bits have been programmed
- Whether the corresponding configuration words have been locked
- Whether the on-board status is consistent with `otp_config.json` and the mass production expectations

### 10.5 Clearly Understand the Tightened Filesystem Execution Surface During Development

Once Secure Boot is enabled, the boot chain trusts `spl -> firmware` and does not trust the raw ELF re-fetched from the filesystem at runtime.

Therefore, during the development phase, do not treat the following behaviors as a premise that "Secure Boot is still effective":

- Manually loading raw ELF from the filesystem
- Loading `/lib/ld.so` again at runtime
- Enabling `dlmodule`, `dlopen`, or similar dynamic module loading capabilities

If post-installation application distribution is truly needed, a new protected application format should be designed, and the existing firmware-level signature verification/decryption chain should be reused.

## 11. Related Files

For further implementation details, refer to:

- Top-level configuration: `.config`
- Secure Boot Kconfig: `Kconfig.secureboot`
- Example defconfig: `configs/k230_rtos_evb_secureboot_defconfig`
- Board-level example configuration: `boards/k230_evb/secureboot/`
- U-Boot packaging script: `tools/gen_image_uboot.py`
- OpenSBI + RT-Smart packaging script: `tools/gen_image_opensbi.py`
- RT-App packaging script: `tools/gen_image_rtapp.py`
- OTP generation script: `tools/gen_otp_config.py`
- U-Boot auxiliary header generation script: `tools/gen_uboot_secure_header.py`
- Secure Boot configuration parsing: `tools/image_tools/k230_image_generator.py`
