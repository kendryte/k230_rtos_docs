# FAQ

## Build Related

### Q1: `make` prompts to run `make xxx_defconfig` first, what should I do?

**Symptom**: Running `make` directly before building reports an error asking you to select a configuration first.  
**Solution**:

```bash
make list-def
make <your_board>_defconfig
make
```

---

### Q2: Some boards only have `k230_canmv_*_defconfig`, but I want to build an RTOS image. What should I do?

**Solution**: You can first select the CanMV defconfig, then change to the RTOS target through `menuconfig`:

1. Run `make k230_canmv_xxx_defconfig`
1. Run `make menuconfig`
1. Disable `CanMV Components Configuration`
1. Enable `RT-Smart Configuration > Enable build Rtsmart examples` as needed
1. Enable `MPP Configuration > Enable build MPP samples` as needed
1. Re-run `time make log`

---

### Q3: It says the toolchain is missing. How to handle it?

**Symptom**: `make` reports that the toolchain cannot be found.  
**Solution**:

```bash
make dl_toolchain
```

After the first download completes, build again.

---

### Q4: After modifying `src/rtsmart/mpp`, running `make` again does not reflect the changes?

**Symptom**: The image can be compiled, but the modifications do not take effect.  
**Solution**: Clean up RT-Smart related artifacts first, then build:

```bash
make rtsmart-clean
make
```

## Burning and Booting

### Q5: How should I choose between `*.img` and `*.kdimg`?

**Recommendations**:

- USB GUI tool (K230BurningTool): prefer `*.kdimg`
- SD card imaging: use `*.img`
- Command-line burning (k230-flash): typically use `*.img`

---

### Q6: After executing `reboot_to_upgrade`, it does not enter burning mode?

**Solution**:

1. Make sure the burning tool is a relatively new version
1. Refer to the patch instructions in the burning guide, apply the patch first, then retry
1. Or use a hardware method: hold the Boot button while powering on to enter burning mode

Reference: [`userguide/how_to_flash.md`](./userguide/how_to_flash.md)

---

### Q7: Burning succeeded but the device does not boot normally?

**Troubleshooting order**:

1. Check whether the image matches the board (whether the defconfig corresponds)
1. Check whether the boot medium is correct (EMMC/SD)
1. Check the serial port logs to confirm whether it is stuck in the boot stage
1. Re-burn once to avoid file corruption or interruption

---

### Q8: How to quickly get started with OTA (brief)?

You can get started with the following minimal process:

1. Build the `*.kdimg` upgrade package on the PC (located in `output/<defconfig>/images/`).
1. Transfer `*.kdimg` to the device file system (e.g., `/data/update.kdimg`).
1. Call the OTA interface in the on-board application to perform the upgrade (sample test command):

```bash
test_ota /data/update.kdimg
```

1. After seeing the upgrade success log, restart and confirm whether the new version boots normally.

**Note**:

- OTA depends on `*.kdimg`, not `*.img`.
- For production scenarios, it is recommended to add upgrade package signature/source verification, power-loss recovery, and rollback strategies at the application layer.

For the full mechanism and interface description, see: [`advanced_development_guide/how_to_use_k230_ota.md`](./advanced_development_guide/how_to_use_k230_ota.md)

## Examples and Applications

### Q9: The example program is not in `/sdcard/app`, does that mean packaging failed?

Not necessarily. RT-Smart examples are located by default in:

```text
/sdcard/app/examples/
```

You can check using the following command:

```bash
cd /sdcard/app/examples
find . -name "*.elf" | head
```

---

### Q10: How to set an example to auto-start on boot?

There are two configurations:

1. **Runtime auto-start command**

Configure in `menuconfig`:

```text
RT-Smart Configuration > Rtsmart auto execute command string
```

This is the runtime command string (`CONFIG_RTT_AUTO_EXEC_CMD`). For auto-starting from a regular file system, use an absolute path on the board, for example:

```text
/sdcard/app/examples/integrated_poc/smart_ipc.elf
```

1. **Fast Boot file path during image packaging (variables supported)**

If you need to configure the source file path for Fast Boot packaging, please go to:

```text
Fast Boot Configuration > Fast boot file path
```

This option supports absolute paths, or `${SDK_*}` variables exported by `tools/mkenv.mk` (such as `${SDK_BUILD_IMAGES_DIR}`), for example:

```text
${SDK_BUILD_IMAGES_DIR}/sdcard/app/examples/integrated_poc/smart_ipc.elf
```

Fast Boot also requires `CONFIG_RTT_AUTO_EXEC_CMD` to be set to `@preload`, or set to `@preload` followed by application arguments; do not use the legacy entry point `/bin/preload`. For complete instructions, see [How to Use Fast Boot and Configure RT-Smart Auto-Run](./userguide/how_to_use_fast_boot.md).

---

### Q11: How to check which Sensors are supported by the current firmware?

Execute on the device side:

```bash
list_sensor
```

The output lists the detected drivers, modes, and lane counts by CSI, and marks `SUPPORTED` / `NOT DETECTED` in the summary. If the target sensor / 4LANE mode is not shown, you need to enable it in `menuconfig` → `Sensor Configuration`:

- Select the corresponding `Enable <Sensor>`
- When CSI0 4-lane is required, **set `CSI0 LANE NUM` to `4LANE`** and enable the Sensor's `Enable 4LANE Configure`
- CSI1 can be enabled at compile time, but cannot be initialized simultaneously with CSI0 4LANE at runtime; do not use both at the same time with the factory wiring
- Rebuild and flash before checking `list_sensor` again

For distinguishing between 2L/4L at the same resolution at runtime, use `sample_vicap_sensor -lane 2|4` or `-stype`. For the complete demo parameters (including `-ofmt` / `-dump` / `-tile`), see [VICAP Sensor Demo](./app_develop_guide/media/vicap.md).

Reference:

- [How to Configure a Sensor](./userguide/how_to_configure_sensor.md)
- [VICAP Sensor Demo](./app_develop_guide/media/vicap.md)
- [Image Sensor Support List](./hardware_compatibility/sensor_list.md)

## Still unresolved?

Visit the [Community](https://www.kendryte.com/answer/) to post for help

It is recommended to provide information in the following order for faster troubleshooting:

1. The name of the defconfig used
1. Complete error log (including 30 lines before and after)
1. Flashing method and image file name
1. Key snippet of serial port boot log

Also attach the commands you have already tried.
