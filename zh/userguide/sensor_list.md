# RTOS Sensor Support List

## Sensor 支持列表

当前 SDK 中已内置了多种不同 Sensor 的驱动支持，列表如下：

> 注意：支持列表会随着代码迭代持续更新

- GC2093：1920x1080@30、1920x1080@60、1280x960@90、1280x720@90
- OV5647：2592x1944@10、1920x1080@30、1280x960@45、1280x720@60、640x480@90
- SC132GS：1080x1200@30、640x480@30
- XS9950：1280x720@30
- BF3238：1920x1080@30、1280x960@30
- IMX335：1920x1080@30、2592x1944@30

## Sensor 使用指南（RTOS）

### 如何在内核中启用特定 Sensor 类型的驱动支持？

尽管 SDK 已内置多款不同型号的 Sensor 驱动代码，但在硬件配置文件中，默认仅启用少量常用型号的驱动，而非全部开启。这是因为全量启用驱动会导致固件体积增加，进而影响系统运行性能。你可根据实际开发需求，自行编译固件以启用所需的 Sensor 驱动支持。方法如下：

#### 如何查看当前固件支持哪些 sensor?

RTOS 系统中，可以使用命令`list_sensor`查看系统中支持的摄像头和模式

![list_sensor](https://www.kendryte.com/api/post/attachment?id=829)

#### 下载 RTOS SDK

- RTOS SDK 编译指南：[https://www.kendryte.com/k230\_rtos/zh/main/userguide/how\_to\_build.html](https://www.kendryte.com/k230_rtos/zh/main/userguide/how_to_build.html)

#### 进入 MPP Configuration->Sensor Configuration

![make menuconfig](https://www.kendryte.com/api/post/attachment?id=830)

- Default SENSOR on CSI：默认 Sensor csi 设置

- Enable AutoFocus：使能自动对焦（需要摄像头支持，目前只有立创有一款摄像头有适配自动对焦功能）

- Enable CSIX：使能 CSIX 输入、PowerDown GPIO、Reset GPIO、I2C 控制口设置（i2c0~i2c4）

- Enable GC2093/OV5647等：使能对应摄像头驱动，使其能在开机的时候被自动扫描、使能 MCLK

## 如何在 RTOS 应用层验证指定 Sensor？

- 确定你手上的摄像头的驱动打开，重新编译并烧录 SDK

- 板端先执行命令确认传感器和模式：

```bash
list_sensor
```

- 再从示例目录中选择与摄像头采集相关的程序运行（如 `vicap` / `sensor` 相关）：

- 运行你要验证的示例（把下面命令中的路径替换成上一步输出的实际结果）：

```bash
./mpp/<your_sensor_sample>.elf
```

如果你的镜像中示例名称不同，请以 `find` 命令输出为准。

## 仅供参考：CanMV Python 用法

如果你使用的是 CanMV 固件（非 RTOS-only），可参考以下 Python 用法：

```python
from media.sensor import *

sensor = Sensor(id=2, width=800, height=600, fps=30)
```

- id：csi num，与硬件 sensor 连接的 MIPI CSI 一致

- width、height、fps：与上表 sensor 支持的摄像头和分辨率保持一致

## 参考链接

如何添加一个 Sensor：[https://www.kendryte.com/k230\_rtos/zh/main/advanced\_development\_guide/how\_to\_add\_sensor.html](https://www.kendryte.com/k230_rtos/zh/main/advanced_development_guide/how_to_add_sensor.html)

摄像头标定流程：[https://www.kendryte.com/k230\_rtos/zh/main/advanced\_development\_guide/how\_to\_calibrate\_isp.html](https://www.kendryte.com/k230_rtos/zh/main/advanced_development_guide/how_to_calibrate_isp.html)

CanMV Sensor API 参考指南（CanMV 固件）：[https://www.kendryte.com/k230\_canmv/zh/main/zh/api/mpp/K230\_CanMV\_Sensor%E6%A8%A1%E5%9D%97API%E6%89%8B%E5%86%8C.html](https://www.kendryte.com/k230_canmv/zh/main/zh/api/mpp/K230_CanMV_Sensor%E6%A8%A1%E5%9D%97API%E6%89%8B%E5%86%8C.html)
