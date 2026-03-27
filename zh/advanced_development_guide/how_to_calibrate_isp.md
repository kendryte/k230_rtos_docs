# Sensor ISP 标定流程

> 说明：本文是 BLC/LSC/CC 标定的操作手册。
> 若需要查看完整 ISP 调优框架与各模块参数含义，请参考：[`how_to_tune_isp.md`](./how_to_tune_isp.md)。

## 软件下载和安装

- Matlab：[MATLAB Runtime R2023a（Windows 64 位）](https://ssd.mathworks.com/supportfiles/downloads/R2023a/Release/0/deployment_files/installer/complete/win64/MATLAB_Runtime_R2023a_win64.zip)

- ISP 标定工具：[K230 ISP 标定工具](https://www.kendryte.com/zh/resource/isp_tool,k230)

- 图像查看工具：用于验证 RAW 图抓取效果

![1740391632757](https://www.kendryte.com/api/post/attachment?id=807)

我们主要需要标定 blc、lsc 和 cc：

## Black level correction（BLC）标定

### 环境准备

- 暗室

- K230 开发板

- 串口

- IMX219 摄像头

注意：需要把摄像头和开发板上的灯都粘起来，防止影响标定效果

![1740391632758](https://www.kendryte.com/api/post/attachment?id=808)

### 抓取 raw 图

抓图代码路径：`SDK/src/rtsmart/mpp/userapps/sample/sample_vicap`，需在 RTOS 环境下单独编译

编译命令：

```shell
cd ~/src/rtsmart/mpp/userapps/sample/sample_vicap

make

cd ../elf

#把文件copy到板子上
cp sample_vicap.elf **
```

抓图步骤：

- 暗室环境下关掉光源，运行 RTOS 操作系统

- 执行抓图命令：

```shell
./sample_vicap.elf -mode 0 -conn 1 -dev 0 -sensor 45 -chn 0 -ofmt 3 -preview 0 -chn 1
```

- 终端出现如下菜单后，输入`d`抓取 RAW 图：

```shell
---------------------------------------
Input character to select test option
---------------------------------------
d: dump data addr test
h: dump hdr ddr buffer.
s: set isp ae roi test
g: get isp ae roi test
t: toggle TPG
r: dump register config to file.
q: to exit
---------------------------------------

please Input:
#输入d,dump一张RAW图
d
sample_vicap... dump frame.
sample_vicap, dev(0) chn(0) dump frame.
dump cost 4 us
save dump data to file(dev_00_chn_00_1920x1080_0010.raw10)
sample_vicap, release dev(0) chn(0) dump frame.
sample_vicap, dev(0) chn(1) dump frame.
dump cost 3 us
save dump data to file(dev_00_chn_01_1920x1080_0011.yuv420sp)
sample_vicap, release dev(0) chn(1) dump frame.

```

- 抓图成功后生成文件：

`dev_00_chn_00_1920x1080_0010.raw10`（RAW 图）

`dev_00_chn_01_1920x1080_0011.yuv420sp`（YUV 图）

使用图像查看工具检查 RAW 图，设置参数：

![1740391632759](https://www.kendryte.com/api/post/attachment?id=809)

### 准备数据

需在不同 gain 和曝光时间设置下抓取 RAW 图（黑电平对细微参数变化不敏感，可简化为单张图代表所有情况），目录结构如下：

![1740391632760](https://www.kendryte.com/api/post/attachment?id=810)

![1740391632761](https://www.kendryte.com/api/post/attachment?id=811)

```shell
imx219/blc/

├─ Gain_1_T_0.01/

│  ├─ Gain_1_T_0.01.raw

│  ├─ bklvsGain.txt

│  └─ bklvsltime.txt

├─ Gain_1_T_0.02/

├─ Gain_1_T_0.03/

├─ Gain_2_T_0.01/

└─ ...（其他gain和曝光组合目录）
```

### 数据标定

- 打开 ISP 标定工具，配置参数：

![1740391632762](https://www.kendryte.com/api/post/attachment?id=812)

- 点击 OK，在 blc 根目录下生成`bls_para.txt`

```shell
ResolutionX = 1920
ResolutionY = 1080
BLS_R = 65
BLS_Gr = 65
BLS_Gb = 65
BLS_B = 65
```

### 修改 ISP 配置文件

注意：12bit 传感器直接使用标定值（64），10bit 传感器需将标定值 ×4（65×4=260）

XML 文件（imx219-1920x1080.xml），修改分辨率和blsData：

```xml
<BLS index="1" type="cell" size="[1 1]">

  <cell index="1" type="struct" size="[1 1]">
     <name index="1" type="char" size="[1 9]">
        1920x1080
     </name>
     <resolution index="1" type="char" size="[1 9]">
        1920x1080
     </resolution>
     <blsData index="1" type="double" size="[1 4]">
        [260, 260, 260, 260]
     </blsData>
  </cell>

</BLS>
```

JSON 文件（imx219-1920x1080_manual.json），修改bls参数：

```shell
{
 "class" : "Bls",
 "bls" : [260, 260, 260, 260]
},
```

## Lens shading Correction（LSC）标定

### 环境准备

- DNP 灯箱

- K230 开发板

- 串口

- IMX219 摄像头

### 抓取 raw 图

需抓取的光源类型：A/A_100 (2850K)、U30/F12 (3000K)、TL84/F11 (4000K)、D50 (5000K)、D65 (6500K)

![1740391632763](https://www.kendryte.com/api/post/attachment?id=813)

抓图步骤：

- 打开 DNP 灯箱，设置对应光源，关掉日光灯，摄像头尽量平行靠近灯箱

- 执行固定曝光抓图命令，如果自动曝光有问题，可以指定曝光和gain参数，命令如下所示：

```shell
./sample_vicap.elf -mode 0 -conn 1 -dev 0 -sensor 45 -ae 0 -again 1 -exp 429 -chn 0 -ofmt 3 -preview 0 -chn 1
```

调节参数：

- 若图像过亮 / 过暗，调整`-exp`值（曝光越大越亮）

- 或修改 auto 文件中 setPoint 值（setPoint 越大越暗）

- 目标：图像中心亮度平均值为最大值（如 8bit：255）的 80% 左右

- 切换光源，重复抓取所有 RAW 图

![1740391632764](https://www.kendryte.com/api/post/attachment?id=814)

![1740391632765](https://www.kendryte.com/api/post/attachment?id=815)

### 数据标定

- 打开 LSC 标定工具，配置参数：

![1740391632766](https://www.kendryte.com/api/post/attachment?id=816)

- 1为BLS标定的值，注意为txt文件原始值，2、3根据图片进行设置，4、5按照图中选择
- 点击load Image，导入保存的raw图片
- 点击Start运行标定，输入保存的文件名，如A_param
- 点击Apply LSC to Image，选中A_param.txt，标定之后的图片颜色均匀，不会有中间亮，两边暗的情况
- 点击 Load Image 导入 RAW 图，点击 Start 运行标定，命名输出文件（如 A_param.txt）
- 点击 Apply LSC to Image 验证颜色均匀性（标定后无中间亮、两边暗现象）
- 点击 save Image to file 保存标定后图片
- 重复所有光源的标定流程

生成的参数文件示例（A_param.txt）：

```text
%

% date of creation : 26-Sep-2025

%

LSC_CALIB_IMAGE_NAME = 'A.raw';

LSC_CALIB_IMAGE_BayerLayout = 'RGGB';

LSC_sectors = 32;  % Using 32 sectors in x direction. 2x16 sectors in y diretion

% Automatic grid refinement chosen!

LSC_Compensation_Percentage = 100;

LSC_Compensation_Shape = 'cosine';

% Data for hardware programming:

% ------------------------------
%
% date of creation : 26-Sep-2025 
%

LSC_CALIB_IMAGE_NAME = 'A.raw';
LSC_CALIB_IMAGE_BayerLayout = 'RGGB';
LSC_sectors = 32;  % Using 32 sectors in x direction. 2x16 sectors in y diretion

% Automatic grid refinement chosen!

LSC_Compensation_Percentage = 100;
LSC_Compensation_Shape = 'cosine';


% Data for hardware programming:
% ------------------------------

LSC_planes = 4;  % Using FOUR planes for LSC!

LSC_No = 10;
LSC_Xo = 15;
LSC_Yo = 15;
LSC_SECT_SIZE_X = [42  43  46  50  50  54  59  60  62  64  67  69  70  75  73  73  74  76  73  72  70  68  66  62  59  57  55  52  49  47  44  39];
LSC_SECT_SIZE_Y = [30  31  32  32  32  33  33  33  35  35  34  36  36  37  36  35];
LSC_RESOLUTION_X = 1920;
LSC_RESOLUTION_Y = 1080;
LSC_BLS_BIT_DEPTH = 10;
LSC_BLS_R = 65;  % based on 10-bits
LSC_BLS_Gr = 65;
LSC_BLS_Gb = 65;
LSC_BLS_B = 65;


% Tables for hardware programming:
% --------------------------------


LSC_SAMPLES_red = [         2201  2044  1949  1862  1767  1711  1640  1548  1514  1430  1401  1360  1290  1260  1247  1235  1216  1229  1248  1258  1282  1332  1385  1427  1504  1546  1619  1686  1769  1890  1967  2009  2150 ...];

LSC_SAMPLES_greenAtRedLine = [         1782  1658  1589  1543  1506  1452  1411  1369  1337  1271  1260  1222  1222  1197  1171  1160  1153  1181  1160  1188  1188  1223  1240  1282  1315  1374  1411  1434  1500  1588  1567  1649  1653 ...];

LSC_SAMPLES_greenAtBlueLine = [         1734  1675  1606  1515  1530  1467  1432  1426  1357  1313  1284  1256  1205  1182  1161  1146  1148  1146  1155  1193  1193  1217  1246  1282  1308  1380  1395  1464  1465  1577  1574  1637  1680 ...];

LSC_SAMPLES_blue = [         1633  1568  1546  1503  1461  1407  1352  1351  1298  1278  1230  1234  1240  1228  1176  1183  1158  1158  1165  1169  1205  1208  1258  1291  1306  1342  1387  1415  1483  1457  1539  1626  1653 ...];

```

### 修改 ISP 配置文件

XML 文件（imx219-1920x1080.xml）：

```xml
<LSC index="1" type="cell" size="[1 5]">

  <cell index="1" type="struct" size="[1 1]">

     <name index="1" type="char" size="[1 15]">1920x1080_A_100</name>

     <resolution index="1" type="char" size="[1 9]">1920x1080</resolution>

     <illumination index="1" type="char" size="[1 1]">A</illumination>

     <LSC_sectors index="1" type="double" size="[1 1]">[ 32]</LSC_sectors>

     <LSC_No index="1" type="double" size="[1 1]">[ 10]</LSC_No>

     <LSC_Xo index="1" type="double" size="[1 1]">[ 15]</LSC_Xo>

     <LSC_Yo index="1" type="double" size="[1 1]">[ 15]</LSC_Yo>

     <LSC_SECT_SIZE_X index="1" type="double" size="[1 32]">
        [42 43 47 49 51 54 58 61 62 64 66 69 71 74 73 73 74 76 72 73 69 68 66 63 59 57 55 51 50 46 45 39] <!-- 根据生成的数据修改 -->
     </LSC_SECT_SIZE_X>

     <LSC_SECT_SIZE_Y index="1" type="double" size="[1 16]">
         [30 31 32 32 32 33 33 34 34 35 34 36 36 37 36 35]<!-- 根据生成的数据修改 -->
     </LSC_SECT_SIZE_Y>

     <vignetting index="1" type="double" size="[1 1]">[ 100]</vignetting>

     <LSC_SAMPLES_red index="1" type="double" size="[33 33]">
         [2190  2035  ...]
     </LSC_SAMPLES_red>  <!-- 根据生成的数据修改 -->

     <LSC_SAMPLES_greenR index="1" type="double" size="[33 33]">
         [1776  1654  ...]
     </LSC_SAMPLES_greenR>  <!-- 根据生成的数据修改 -->

     <LSC_SAMPLES_greenB index="1" type="double" size="[33 33]">
         [1729  1671  ...]
     </LSC_SAMPLES_greenB>  <!-- 根据生成的数据修改 -->

     <LSC_SAMPLES_blue index="1" type="double" size="[33 33]">
        [1624  1560  ...]
     </LSC_SAMPLES_blue>  <!-- 根据生成的数据修改 -->

  </cell>

  <!-- 其他光源（U30/F12、TL84/F11、D50、D65）配置类似，依次添加cell节点 -->

</LSC>
```

JSON 文件（imx219-1920x1080_manual.json）：

选择接近自然光源（TL84、D50、D65 任选一个）的参数写入：

```text
"class": "CLscv2",

"enable": true,

"matrix": [

 [2063, 1934, 1885, ...],  <!-- 根据生成的数据修改 -->

 [1673, 1633, 1564, ...],  <!-- 根据生成的数据修改 -->

 [1653, 1607, 1554, ...],  <!-- 根据生成的数据修改 -->

 [1611, 1536, 1538, ...]   <!-- 根据生成的数据修改 -->
],

"x_size": [41, 45, 46, 51, 51, 54, 58, 59, 63, 63, 68, 68, 70, 73, 73, 73, 73, 74, 74, 72, 70, 67, 66, 63, 61, 57, 54, 52, 49, 46, 45, 41],<!-- 根据生成的数据修改 -->

"y_size": [30, 32, 32, 32, 33, 33, 33, 34, 34, 35, 35, 35, 35, 36, 36, 35]<!-- 根据生成的数据修改 -->
```

## Color Correction（CC）标定

### 环境准备

- DNP 灯箱

- 24 色卡

- K230 开发板

- 串口

- IMX219 摄像头

摆放要求：色卡占图像 80% 以上，位置摆正

### 抓取 RAW 图

光源类型：与 LSC 标定一致（A/A_100、U30/F12、TL84/F11、D50、D65）

![1740391632767](https://www.kendryte.com/api/post/attachment?id=817)

![1740391632768](https://www.kendryte.com/api/post/attachment?id=818)

抓图步骤：

- 色卡正对摄像头，执行抓图命令获取色卡 RAW 图

- 移除色卡，保持摄像头位置不变，抓取对应光源的背景图

- 切换所有光源，重复上述操作

![1740391632769](https://www.kendryte.com/api/post/attachment?id=819)

最后数据输出如下：

![1740391632770](https://www.kendryte.com/api/post/attachment?id=820)

### 数据标定

- 打开 ColorCalibrationTool，设置参数Width, Height, Bits, Bayer CFA pattern, BLS (Offset)

- 加载文件：

  - Load sRGB References：选择 CC_Standard.cxf
  - Load Color Checker Image：选择色卡 RAW 图
  - Load Background Image：选择背景图
  - Load LSC Profile：选择对应光源的 LSC 参数文件

- 取消勾选 "Clip Reference Colors" 和 "Camera Input with applied output gamma"

- 点击 Calibrate，选择色卡四角色块中心点

- 点击 Save parameters 保存文件，获取白平衡（wb）和颜色矩阵（ctm）数据

![1740391632771](https://www.kendryte.com/api/post/attachment?id=821)

![1740391632772](https://www.kendryte.com/api/post/attachment?id=822)

![1740391632773](https://www.kendryte.com/api/post/attachment?id=823)

生成的参数文件示例：

```text
%

% date of creation: 2025-09-26 11:28:26

%

% Image: A.raw

% Backg.: A_bg.raw

% LSC Profile: A_param.txt

wb = [1.0981875006563746  1.0000000000000000  2.5580446290603689];

ctm = [-0.9721696863640497, 1.2879706962999451, 0.6841989900641045
      0.0803070677890457, 2.3405640590630337, -1.4208711268520793
      2.8278245866662233, -2.1010268918389596, 0.2732023051727360];
```

### 更新 ISP 文件

选择与 manual LSC 相同的光源写入参数

JSON 文件(imx219-1920x1080_manual.json), 修改 gain 和 ccmatrix 的值,
gain从文件中wb获取，用 wb[0] 和 wb[2]覆盖 gain[0] 和 gain[3]：

```json
{
 "class": "CManualWb",
 "enable": true,
 "gain": [1.620313, 1.0, 1.0, 1.64161]
},

{
 "bit": 13,
 "ccmatrix": [
   2.31868, -0.935233, -0.383454,
   -0.641832, 2.550007, -0.908175,
   -0.283179, -0.977915, 2.26109
 ],
 "ccoffset": [0, 0, 0],
 "class": "CCcm",
 "enable": true
},
```

XML 文件（imx219-1920x1080.xml）：

```xml
<CC index="1" type="cell" size="[1 5]">

  <cell index="1" type="struct" size="[1 1]">

     <name index="1" type="char" size="[1 5]">
       A_100
     </name>

     <saturation index="1" type="double" size="[1 1]">
       [ 100]
     </saturation>

     <ccMatrix index="1" type="double" size="[3 3]">
       [1.171875 0.2109375 -0.3828125 -0.1875 1.3125 -0.125 -0.0234375 -0.6640625 1.6875]
     </ccMatrix>

     <ccOffsets index="1" type="double" size="[1 3]">
       [0 0 0]
     </ccOffsets>

     <wb index="1" type="double" size="[1 4]">
       [0.951171875 1.0 1.0 2.952148438]
     </wb>

  </cell>

  <!-- 其他光源（D65_100、F11_100、F12_100）配置类似，依次添加ccMatrix和wb节点 -->

</CC>
```

## 最终验证

- 完成所有参数修改后，重新编译 MPP 工程，生成新镜像
- 烧录镜像到开发板，启动系统
- 运行抓图命令，验证图像的黑电平、色彩均匀性、颜色准确性是否符合预期
- 若存在异常，返回对应步骤调整标定参数或传感器配置
