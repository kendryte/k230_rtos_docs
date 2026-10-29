# How to Use Fast Boot and Configure RT-Smart Auto-Run

## Feature Description

The RTOS SDK's Fast Boot packages an RT-Smart user-mode ELF separately as `rtapp.elf.gz`. During startup, U-Boot reads and decompresses this file from the `rtapp` partition, then passes the load address and size to RT-Smart via ATAG; RT-Smart then directly launches the in-memory ELF through the internal entry point `@preload`, avoiding reading the application from the file system after startup.

Fast Boot and auto-run are jointly controlled by two sets of configuration:

- `Fast Boot Configuration` determines which ELF is packaged.
- `RT-Smart Configuration > Rtsmart auto execute command string` determines whether RT-Smart runs the ELF after startup and which parameters are passed to it.

Configuring only one of these cannot complete Fast Boot auto-run. The target board's image layout must also contain an `rtapp`, `rtapp_a`, or `rtapp_b` partition marked as `load = true`, and use a U-Boot that supports RT-App preloading and ATAG. Most SD card and eMMC board configurations provided by the SDK already include these settings; when using SPI NAND or a custom image layout, first check the corresponding `boards/<board>/genimage-*.cfg`.

On this basis, startup time can also be shortened by reducing boot logs, increasing the serial baud rate, and enabling HS200 on supported eMMC boards. SD/TF cards can also use application preloading and log optimization without requiring HS200 support.

## Quick Start

Run the following commands from the SDK root directory in a configured build environment. If using the Docker build helper, replace `make` with `k230 make` on the host; for environment setup, see [Firmware Build](how_to_build.md).

```bash
make list-def
make <board>_defconfig
make menuconfig
```

Select the board-level configuration that matches the actual hardware. In `make menuconfig`, set:

| Menu | Setting |
| --- | --- |
| `Fast Boot Configuration` | Enable it, and point `Fast boot file path` to the ELF to launch. After the CanMV firmware enables `CanMV Components Configuration`, the default `${SDK_BUILD_IMAGES_DIR}/sdcard/micropython` can be used. Refer to the HelloWorld example below for other applications. |
| `RT-Smart Configuration` | Set `Rtsmart auto execute command string` to `@preload`, adding application parameters afterward if needed. |
| `Fast Boot Configuration > Reduce boot banners and DDR training progress logs` | Enable this option to reduce boot logs. |
| `Uboot Configuration` | Disable `Uboot Use Prebuilt Binaries` to build this version of U-Boot/SPL from source. |
| `Opensbi Configuration` | Disable `OpenSBI Use Prebuilt FW Jump` so that the OpenSBI log and baud rate configurations take effect. |

Keep the default `115200` baud rate initially; after confirming that the serial adapter supports it, change it to `2000000` as described below. The initial eMMC HS200 and RT-Smart probe optimizations are configured in subprojects, as described below.

After saving the configuration, run `make` and confirm that the packaging log does not contain `Use fake rtapp`. Then flash the complete image built in this run according to [Firmware Flashing](how_to_flash.md). The complete image is located in `output/<defconfig>/`; the exact file name is indicated by `Generated image done, at ...` at the end of the build. The `images/` directory stores the intermediate artifacts of each component.

## Kconfig Options

Select the board-level defconfig at the SDK root directory, then enter the top-level configuration menu:

```bash
make <board>_defconfig
make menuconfig
```

### Fast Boot Configuration

The options come from `Kconfig.fastboot` in the SDK root directory:

| Menu Item | Kconfig Symbol | Default | Description |
| --- | --- | --- | --- |
| `Fast Boot Configuration` | `CONFIG_FAST_BOOT_CONFIGURATION` | `y` | Enables RT-App packaging. When disabled, a placeholder `rtapp.elf.gz` is still generated, but it contains no runnable ELF. |
| `Fast boot file path` | `CONFIG_FAST_BOOT_FILE_PATH` | `${SDK_BUILD_IMAGES_DIR}/sdcard/micropython` | The path to the ELF to be packaged in the host build environment. Absolute paths and `${SDK_*}` environment variables expanded at build time are supported. |
| `Delete Origin Fastboot App` | `CONFIG_FAST_BOOT_DELETE_ORIGIIN_FILE` | `y` | Deletes the source ELF after packaging to avoid retaining one copy in both the file system and the `rtapp` partition. `ORIGIIN` in the symbol is the actual spelling in the current source code. |
| `Reduce boot banners and DDR training progress logs` | `CONFIG_FAST_BOOT_QUIET` | `y` when Fast Boot is enabled | Reduces boot logs. Changes to the OpenSBI and DDR logs require corresponding source support and recompilation; prebuilt firmware retains the original logging behavior. |

The file path, source file deletion, and quiet log options are all located within `if FAST_BOOT_CONFIGURATION`. When `CONFIG_FAST_BOOT_CONFIGURATION=n`, these options are unavailable, and the effective value of `CONFIG_FAST_BOOT_QUIET` is `n`. The default values in the table apply when their dependencies are satisfied; board-level defconfigs or saved configurations may override them. After saving the menu configuration, check the final result in the `.config` file at the SDK root directory.

`Fast boot file path` is a host-side path, not a board-side path. For example, after the application is built and staged at `/sdcard/app/helloworld` in the image, the corresponding packaging path is:

```text
${SDK_BUILD_IMAGES_DIR}/sdcard/app/helloworld
```

```{warning}
After enabling `Delete Origin Fastboot App`, the packaging script directly deletes the file pointed to by `Fast boot file path`. If an absolute path outside the SDK output directory is configured here, the original file will also be deleted. In this case, disable the option, or copy the ELF to the build output directory before packaging it.
```

### RT-Smart Auto-Execute Command

The option comes from `src/rtsmart/Kconfig`:

```text
RT-Smart Configuration > Rtsmart auto execute command string
```

Its Kconfig symbol is `CONFIG_RTT_AUTO_EXEC_CMD`. When Fast Boot is enabled, the default value is `@preload &`; when Fast Boot is disabled, the default value is an empty string.

Set this string according to the use case:

| Scenario | Configuration Example | Behavior |
| --- | --- | --- |
| Fast Boot, no parameters | `@preload` | Runs the RT-App preloaded by U-Boot. |
| Fast Boot, with parameters | `@preload -C 1 -K /sdcard/model.kmodel` | Runs the preloaded RT-App and passes the subsequent parameters to the application. The file paths in the parameters are board-side paths. |
| Normal file system auto-start, with Firmware Secure Boot disabled | `/sdcard/app/helloworld` | `msh` loads and runs the ELF from the file system. |
| Disable auto-run | Empty string | RT-Smart does not automatically execute a user-mode application after startup. |

`@preload` is RT-Smart's internal trigger marker; it is neither a file system path nor a command that can be manually executed in `msh`. This entry point directly splits the parameters and calls `exec`, and does not interpret shell syntax such as pipes, redirections, or `&`. The current implementation accepts up to 8 fields separated by spaces or tabs, with the first field being `@preload`. The application does not need a background symbol to be launched through the auto-run entry point; when there are no parameters, explicitly configuring it as `@preload` is recommended.

```{warning}
After enabling Firmware Secure Boot, the auto-execute command must have `@preload` as its first field. Other commands are skipped, and the system does not fall back to an ELF in the file system. Fast Boot must also be enabled at this point, and U-Boot must actually preload a valid `rtapp` image.
```

## Further Reducing Boot Time

### Reducing Log Output and Increasing the Serial Baud Rate

When `CONFIG_FAST_BOOT_QUIET=y`, RT-Smart reduces the full version banner to a single line containing the SDK and nncase version information, and source-built OpenSBI disables its boot banner. DDR initialization and training progress logs also require the U-Boot in use to include the corresponding quiet-log support; older versions or prebuilt SPLs may still output these logs. The quiet option does not disable error logs or hide the CanMV/MicroPython entry timestamp.

The serial baud rate is set in the top-level `make menuconfig`:

```text
RT-Smart Configuration > Console UART baudrate (RT-Smart, U-Boot and OpenSBI)
```

This corresponds to `CONFIG_RTT_CONSOLE_BAUD`, which defaults to `115200`. When using a serial adapter that supports high-speed communication, it can be set to `2000000`; configure the terminal for **2000000 baud, 8 data bits, no parity, and 1 stop bit (8N1)**. This configuration applies to RT-Smart, as well as source-built U-Boot/SPL and OpenSBI. Prebuilt firmware retains the baud rate used at build time.

When `CONFIG_UBOOT_USE_PREBUILT=n`, `tools/gen_image_uboot.py` also updates `baudrate`, along with the baud rate in existing `console_port=console=<device>,<baudrate>...` entries. The script writes the processed environment to `output/<defconfig>/images/uboot/env.txt`, from which it generates `env.bin`, without modifying the board-level environment template. When using prebuilt U-Boot, the script generates `env.bin` directly from the board-level template and does not apply this baud-rate override.

If the format of an existing `console_port` entry is unsupported, the script outputs a warning and retains the entry; the board-level template should be corrected before flashing. If the template does not contain `console_port`, it will not be added automatically.

To use the new configuration at every stage, disable the following options in the top-level menu:

```text
# CONFIG_UBOOT_USE_PREBUILT is not set
# CONFIG_OPENSBI_USE_PREBUILT_FW_JUMP is not set
```

Run `make` again and flash the complete image containing the new U-Boot/SPL, environment, and RT-Smart/OpenSBI. Updating only the application or RT-Smart partition will not change the bootloader's existing logging and baud rate.

### eMMC HS200

HS200 is used for eMMC devices that support this mode and can improve the speed at which firmware and applications are read during the boot stage. The current K230 driver's HS200 path uses **SDIO0, a 1.8 V signal level, and a 4-bit or 8-bit data bus**. The board's power supply, pins, and bus width must match the actual hardware; do not enable the eMMC or 1.8 V options for ordinary SD/TF cards.

U-Boot/SPL and RT-Smart initialize the controller and perform tuning separately, so their configurations must be checked separately. Run the following from the SDK root directory:

```bash
make uboot-menuconfig
```

Use the menu search function `/` to check the following symbols, and confirm that the board device tree's bus width, voltage, and clock configuration support the target eMMC:

```text
CONFIG_MMC_HS200_SUPPORT=y
CONFIG_SPL_MMC_HS200_SUPPORT=y
```

Also keep the top-level `CONFIG_UBOOT_USE_PREBUILT` disabled; otherwise, the source configurations above will not affect the U-Boot/SPL actually being flashed.

Next, configure RT-Smart:

```bash
make rtsmart-menuconfig
```

Configure SDIO0 under `InterDriver > Enable SDIO Driver`. The following is an example configuration for **1.8 V, 8-bit eMMC**, and applies only to compatible hardware:

```text
CONFIG_RT_USING_SDIO0=y
CONFIG_RT_SDIO0_EMMC=y
CONFIG_RT_SDIO0_1V8=y
CONFIG_SDIO0_BUS_WIDTH_8BIT=y
CONFIG_RT_SDIO0_HS200=y
```

`Enable SDIO0 eMMC HS200` depends on the eMMC and 1.8 V options, is disabled by default, and is explicitly enabled by a validated board defconfig; configuring only an 8-bit bus does not automatically enable HS200. A 4-bit eMMC can also use HS200: select `SDIO0 Bus Max Width > 4Bit`, then explicitly enable HS200 after board-level validation. For an ordinary 4-bit SD/TF card connected to SDIO0, disable `SDIO0 device is emmc` and configure the voltage and 4-bit bus according to the hardware; it will not enter the eMMC HS200 tuning process.

The driver checks the eMMC capabilities and performs tuning; devices that do not support HS200 use their supported mode. If HS200 initialization or tuning fails, the driver attempts a lower-speed mode, but this cannot replace board-level validation and does not mean that runtime read/write errors will automatically fall back to a lower speed. New boards or new eMMC models should be validated through repeated cold boots and sustained read/write operations; if tuning or data errors occur, the U-Boot/SPL and RT-Smart HS200 options can be disabled separately and the system rebuilt to isolate the issue.

### Skipping the Initial SDIO Probe of the Boot Storage Controller

In `make rtsmart-menuconfig`, under `InterDriver > Enable SDIO Driver`, `Skip SDIO probing on the first boot-storage scan` (`CONFIG_RT_SDIO_SKIP_INITIAL_PROBE`) defaults to `y` when the SDIO driver (`CONFIG_RT_USING_SDIO`) and at least one controller (`CONFIG_RT_USING_SDIO0` or `CONFIG_RT_USING_SDIO1`) are enabled. The board defconfig or a saved kernel configuration may disable it, so its final state should be confirmed in this menu.

It only skips the SDIO CMD52 reset, the post-reset wait, and the CMD5 probe during the first scan of the boot storage controller, while preserving the power-on, identification, and retry timing of SD/MMC storage cards. Subsequent scans resume normal probing, even if the first scan fails; other devices, such as SDIO Wi-Fi devices on other controllers, are still enumerated normally.

If an SDIO device or a combo card with SDIO functionality is connected to the boot controller, this option should be disabled to preserve the initial SDIO enumeration. This option and the HS200 configuration are independent of the top-level `Fast Boot Configuration`; disabling application preloading does not automatically disable them.

### Saving the Configuration and Validating

`make savedefconfig` saves the top-level SDK configuration; `make uboot-menuconfig` and `make rtsmart-menuconfig` update the currently selected board defconfig in their respective subprojects when you save and exit. When retaining a configuration, the top-level and subproject differences should be checked together. After completing the configuration, run `make` from the SDK root directory to regenerate the complete image.

The `selected timing` log on the boot serial port can be used to confirm the actual mode. For example, after an 8-bit eMMC successfully enters HS200, you may see:

```text
MMC0: selected timing: HS200 (200MHz), 8-bit, clock=200000000 Hz
sd0: selected timing: HS200, 8-bit, clock=200000000 Hz
```

The device number, bus width, and frequency depend on the actual configuration; some U-Boot configurations output `mode=<number>`. Check the boot stage and the RT-Smart stage separately; RT-Smart using HS200 does not mean that SPL has also been enabled.

CanMV firmware also outputs:

```text
CanMV K230 start in <microseconds> us
```

This value is a timing measurement taken upon entering MicroPython; it does not indicate that the Python startup script, model loading, or display initialization has completed. When comparing optimization results, use the same application and storage medium and repeat cold boots. If measuring the time from power-on until the application is ready, add a log message or GPIO marker at the application's ready point.

## Complete Example: Fast Boot Startup of HelloWorld

### 1. Enable the Application

Run `make menuconfig` and open:

```text
Applications Configuration > Enable Applications HelloWorld
```

The application will be generated on the host side at:

```text
${SDK_BUILD_IMAGES_DIR}/sdcard/app/helloworld
```

### 2. Configure Fast Boot

Enter `Fast Boot Configuration` and set:

```text
[*] Fast Boot Configuration
Fast boot file path = ${SDK_BUILD_IMAGES_DIR}/sdcard/app/helloworld
[*] Delete Origin Fastboot App
```

While the deletion option remains enabled, `/sdcard/app/helloworld` will no longer be present in the final file system; the application will exist only in the `rtapp` partition.

### 3. Configure Automatic Execution

Enter `RT-Smart Configuration` and set `Rtsmart auto execute command string` to:

```text
@preload
```

Save and exit. You can inspect the final configuration in the SDK root directory:

```bash
grep -E 'CONFIG_(APP_ENABLE_HELLOWORLD|FAST_BOOT|RTT_AUTO_EXEC_CMD)' .config
```

The expected output includes:

```text
CONFIG_APP_ENABLE_HELLOWORLD=y
CONFIG_RTT_AUTO_EXEC_CMD="@preload"
CONFIG_FAST_BOOT_CONFIGURATION=y
CONFIG_FAST_BOOT_FILE_PATH="${SDK_BUILD_IMAGES_DIR}/sdcard/app/helloworld"
CONFIG_FAST_BOOT_DELETE_ORIGIIN_FILE=y
```

### 4. Compile and Flash

```bash
make
ls -lh output/<defconfig>/images/rtapp/rtapp.elf.gz
```

`rtapp.elf.gz` is an RT-App image with an image header that has been compressed. Whether the file size is zero cannot be used as the sole validity criterion. The compilation log should not contain `Use fake rtapp` or messages indicating that the Fast Boot file does not exist.

After flashing the complete image from `output/<defconfig>/` that is appropriate for the target board, reboot the system. The correct file name is indicated by the `Generated image done, at ...` log. During the RT-Smart startup phase, `@preload` will be executed, and the HelloWorld output should be visible on the serial port.

If you want to save the configuration to the current board-level defconfig, you can run the following after confirming `.config`:

```bash
make savedefconfig
```

This command updates the currently selected `configs/<defconfig>`. You should check the differences before committing.

## Configure File System Auto-Start Only

If Fast Boot is not needed and the application is to run automatically from the file system:

1. Disable `Fast Boot Configuration`.
1. Ensure that the application is copied to the file system image.
1. Set `Rtsmart auto execute command string` to the absolute board-side path and arguments, for example:

   ```text
   /sdcard/app/helloworld
   ```

This method does not use `@preload`. When Firmware Secure Boot is enabled, RT-Smart refuses to load ELF files from the file system, so this configuration cannot be used.

## Common Issues

### Logs Do Not Decrease After Configuration Changes, or Garbled Characters Appear on the Serial Port

Confirm that the prebuilt options for U-Boot and OpenSBI have been disabled and that a complete new image containing the bootloader and environment has been flashed. Check whether the terminal baud rate matches `CONFIG_RTT_CONSOLE_BAUD`; normal output during some stages and garbled output during others usually indicates that firmware with different baud rates has been mixed. If the adapter does not support 2000000, change the shared baud rate back to 115200, rebuild, and flash. When debugging boot issues, `CONFIG_FAST_BOOT_QUIET` can be disabled to restore logs suppressed by this option; whether DDR logs are controlled depends on the U-Boot version used.

### The Preloaded Image Is Unavailable at Boot

Common log messages include:

```text
Preloaded ELF magic number mismatch
Trusted preload is unavailable: missing or invalid ATAG-preloaded rtapp image
trusted preload image unavailable, enable fast boot and ensure U-Boot preloads rtapp
```

Check the following in order:

1. `CONFIG_FAST_BOOT_CONFIGURATION=y`.
1. `CONFIG_FAST_BOOT_FILE_PATH` points to an RT-Smart ELF file that actually exists at build time.
1. The build log does not contain `Use fake rtapp`. The current packaging script generates a placeholder image and continues the build when the source file does not exist, so successful generation of the complete image does not mean that the RT-App is valid.
1. The board-level `genimage` configuration contains the `rtapp` partition and sets `load = true`.
1. The complete image produced by this build is flashed, and U-Boot and RT-Smart come from compatible versions.

### A Model or Configuration File Required by the Application Cannot Be Found

Fast Boot places only the selected ELF file into the `rtapp` image and does not automatically collect the models, font files, or configuration files it references. These resources must still be packaged into the board-side file system, such as `/sdcard` or `/data`, and the board-side paths must be used in the arguments of `CONFIG_RTT_AUTO_EXEC_CMD`.

### The Original ELF File Cannot Be Found in the File System

This is the expected behavior of `CONFIG_FAST_BOOT_DELETE_ORIGIIN_FILE=y`. To retain a file system copy for manual debugging at the same time, disable `Delete Origin Fastboot App` and rebuild the image.

### The Old Application Still Runs After the Changes

The Fast Boot application is located in the separate `rtapp` partition. A complete image containing `rtapp`, or the corresponding RT-App update image, must be flashed; updating only the file system partition does not replace the already preloaded application.
