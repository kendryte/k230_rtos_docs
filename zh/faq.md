# 常见问题解答

## 构建相关

### Q1：`make` 提示先执行 `make xxx_defconfig`，怎么办？

**现象**：构建前直接执行 `make`，报错要求先选择配置。  
**解决**：

```bash
make list-def
make <your_board>_defconfig
make
```

---

### Q2：有的板卡只有 `k230_canmv_*_defconfig`，我想做 RTOS 镜像怎么办？

**解决**：可以先选 CanMV defconfig，再通过 `menuconfig` 改成 RTOS 目标：

1. 执行 `make k230_canmv_xxx_defconfig`
1. 执行 `make menuconfig`
1. 关闭 `CanMV Components Configuration`
1. 按需开启 `RT-Smart Configuration > Enable build Rtsmart examples`
1. 按需开启 `MPP Configuration > Enable build MPP samples`
1. 重新执行 `time make log`

---

### Q3：提示工具链缺失，如何处理？

**现象**：`make` 报工具链找不到。  
**解决**：

```bash
make dl_toolchain
```

首次下载完成后再次编译即可。

---

### Q4：修改了 `src/rtsmart/mpp` 后，重新 `make` 看不到效果？

**现象**：镜像能编译，但改动未生效。  
**解决**：先清理 RT-Smart 相关产物再编译：

```bash
make rtsmart-clean
make
```

## 烧录与启动

### Q5：`*.img` 和 `*.kdimg` 应该怎么选？

**建议**：

- USB 图形工具（K230BurningTool）：优先使用 `*.kdimg`
- SD 卡写盘：使用 `*.img`
- 命令行烧录（k230-flash）：通常使用 `*.img`

---

### Q6：执行 `reboot_to_upgrade` 后没进入烧录模式？

**解决**：

1. 确认烧录工具为较新版本
1. 参考烧录指南中的 patch 说明，先补丁再重试
1. 或改用硬件方式：按住 Boot 键上电进入烧录模式

参考：[`userguide/how_to_flash.md`](./userguide/how_to_flash.md)

---

### Q7：烧录成功但设备没有正常启动？

**排查顺序**：

1. 检查镜像与板卡是否匹配（defconfig 是否对应）
1. 检查启动介质是否正确（EMMC/SD）
1. 检查串口日志，确认是否卡在引导阶段
1. 重新烧录一次，避免文件损坏或中断

---

### Q8：OTA 如何快速使用（简要）？

可按下面最小流程上手：

1. 在 PC 端构建得到 `*.kdimg` 升级包（位于 `output/<defconfig>/images/`）。
1. 将 `*.kdimg` 传到设备文件系统（例如 `/data/update.kdimg`）。
1. 在板端应用中调用 OTA 接口执行升级（示例测试命令）：

```bash
test_ota /data/update.kdimg
```

1. 看到升级成功日志后重启，确认是否正常进入新版本。

**注意**：

- OTA 依赖 `*.kdimg`，不是 `*.img`。
- 生产场景建议在应用层增加升级包签名/来源校验、断电恢复与回滚策略。

完整机制与接口说明见：[`advanced_development_guide/how_to_use_k230_ota.md`](./advanced_development_guide/how_to_use_k230_ota.md)

## 示例与应用

### Q9：示例程序不在 `/sdcard/app`，是不是打包失败？

不一定。RT-Smart 示例默认在：

```text
/sdcard/app/examples/
```

可用如下命令检查：

```bash
cd /sdcard/app/examples
find . -name "*.elf" | head
```

---

### Q10：如何设置开机自启动某个示例？

分两种配置：

1. **运行时自启动命令（Startup command）**

在 `menuconfig` 中设置：

```text
RT-Smart Configuration > Startup command
```

这里是运行时命令字符串（`CONFIG_RTT_AUTO_EXEC_CMD`），建议使用**绝对路径**，例如：

```text
/sdcard/app/examples/integrated_poc/smart_ipc.elf
```

1. **镜像打包时 Fast Boot 文件路径（可用变量）**

若你要配置 Fast Boot 打包源文件路径，请在：

```text
Fast Boot Configuration > Fast boot file path
```

该项支持绝对路径，或 `tools/mkenv.mk` 导出的 `${SDK_*}` 变量（如 `${SDK_BUILD_IMAGES_DIR}`），例如：

```text
${SDK_BUILD_IMAGES_DIR}/sdcard/app/examples/integrated_poc/smart_ipc.elf
```

---

### Q11：如何确认当前固件支持哪些 Sensor？

在板端执行：

```bash
list_sensor
```

若看不到目标 sensor，需在 `menuconfig` 的 Sensor 相关选项中使能后重新编译烧录。

参考：[`userguide/sensor_list.md`](./userguide/sensor_list.md)

## 仍未解决？

前往[社区](https://www.kendryte.com/answer/)发帖求助

建议按下面顺序提供信息，定位会更快：

1. 使用的 defconfig 名称
1. 完整报错日志（包含前后 30 行）
1. 烧录方式与镜像文件名
1. 串口启动日志关键片段

并附上你已经尝试过的命令。
