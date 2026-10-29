# Sensor ISP Calibration Process

> Note: This article is the operation manual for BLC/LSC/CC calibration.
> To view the complete ISP tuning framework and the meaning of each module's parameters, please refer to: [`how_to_tune_isp.md`](./how_to_tune_isp.md).

## Software Download and Installation

- Matlab: [MATLAB Runtime R2023a (Windows 64-bit)](https://ssd.mathworks.com/supportfiles/downloads/R2023a/Release/0/deployment_files/installer/complete/win64/MATLAB_Runtime_R2023a_win64.zip)

- ISP Calibration Tool: [K230 ISP Calibration Tool](https://www.kendryte.com/zh/resource/isp_tool,k230)

- Image Viewing Tool: used to verify the RAW image capture effect

![1740391632757](https://www.kendryte.com/api/post/attachment?id=807)

We mainly need to calibrate blc, lsc, and cc:

## Black level correction (BLC) Calibration

### Environment Preparation

- Darkroom

- K230 development board

- Serial port

- IMX219 camera

Note: It is necessary to cover the lights on both the camera and the development board to prevent affecting the calibration effect

![1740391632758](https://www.kendryte.com/api/post/attachment?id=808)

### Capture RAW Image

Image capture code path: `SDK/src/rtsmart/mpp/userapps/sample/sample_vicap`, needs to be compiled separately in the RTOS environment

Compilation command:

```shell
cd ~/src/rtsmart/mpp/userapps/sample/sample_vicap

make

cd ../elf

#Copy the file to the board
cp sample_vicap.elf **
```

Image capture steps:

- Turn off the light source in a darkroom environment, and run the RTOS operating system

- Execute the image capture command:

```shell
./sample_vicap.elf -mode 0 -conn 1 -dev 0 -sensor 45 -chn 0 -ofmt 3 -preview 0 -chn 1
```

- After the following menu appears on the terminal, enter `d` to capture a RAW image:

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
#Enter d to dump a RAW image
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

- Files generated after successful image capture:

`dev_00_chn_00_1920x1080_0010.raw10` (RAW image)

`dev_00_chn_01_1920x1080_0011.yuv420sp` (YUV image)

Use the image viewing tool to check the RAW image, and set the parameters:

![1740391632759](https://www.kendryte.com/api/post/attachment?id=809)

### Prepare Data

It is necessary to capture RAW images under different gain and exposure time settings (the black level is not sensitive to subtle parameter changes, and can be simplified to a single image to represent all cases). The directory structure is as follows:

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

└─ ... (Other gain and exposure combination directories)
```

### Data Calibration

- Open the ISP calibration tool, and configure the parameters:

![1740391632762](https://www.kendryte.com/api/post/attachment?id=812)

- Click OK, and `bls_para.txt` will be generated in the blc root directory

```shell
ResolutionX = 1920
ResolutionY = 1080
BLS_R = 65
BLS_Gr = 65
BLS_Gb = 65
BLS_B = 65
```

### Modify ISP Configuration File

Note: 12bit sensors directly use the calibrated value (64), 10bit sensors need to multiply the calibrated value by 4 (65×4=260)

XML file (imx219-1920x1080.xml), modify the resolution and blsData:

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

JSON file (imx219-1920x1080_manual.json), modify the bls parameter:

```shell
{
 "class" : "Bls",
 "bls" : [260, 260, 260, 260]
},
```

## Lens Shading Correction (LSC) Calibration

### Environment Preparation

- DNP light box

- K230 development board

- Serial port

- IMX219 camera

### Capture Raw Images

Light source types to capture: A/A_100 (2850K), U30/F12 (3000K), TL84/F11 (4000K), D50 (5000K), D65 (6500K)

![1740391632763](https://www.kendryte.com/api/post/attachment?id=813)

Image capture steps:

- Turn on the DNP light box, set the corresponding light source, turn off the daylight lamp, keep the camera parallel to and as close as possible to the light box

- Execute the fixed exposure capture command. If there is an issue with auto exposure, you can specify the exposure and gain parameters. The command is shown below:

```shell
./sample_vicap.elf -mode 0 -conn 1 -dev 0 -sensor 45 -ae 0 -again 1 -exp 429 -chn 0 -ofmt 3 -preview 0 -chn 1
```

Parameter adjustment:

- If the image is too bright / too dark, adjust the `-exp` value (the larger the exposure, the brighter)

- Or modify the setPoint value in the auto file (the larger the setPoint, the darker)

- Target: the average brightness at the center of the image is about 80% of the maximum value (e.g., 255 for 8bit)

- Switch the light source and repeat capturing all RAW images

![1740391632764](https://www.kendryte.com/api/post/attachment?id=814)

![1740391632765](https://www.kendryte.com/api/post/attachment?id=815)

### Data Calibration

- Open the LSC calibration tool and configure the parameters:

![1740391632766](https://www.kendryte.com/api/post/attachment?id=816)

- 1 is the value from BLS calibration. Note that it is the original value from the txt file. 2 and 3 are set based on the image. 4 and 5 are selected as shown in the image.
- Click load Image to import the saved raw image
- Click Start to run the calibration, enter the name of the file to save, such as A_param
- Click Apply LSC to Image, select A_param.txt, the color of the image after calibration should be uniform, without the situation of being bright in the middle and dark on both sides
- Click Load Image to import the RAW image, click Start to run the calibration, and name the output file (e.g., A_param.txt)
- Click Apply LSC to Image to verify color uniformity (no bright-in-the-middle, dark-on-both-sides phenomenon after calibration)
- Click save Image to file to save the calibrated image
- Repeat the calibration process for all light sources

Example of the generated parameter file (A_param.txt):

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

### Modify the ISP Configuration File

XML file (imx219-1920x1080.xml):

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

JSON file (imx219-1920x1080_manual.json):

Select the parameters close to natural light sources (any one of TL84, D50, D65) and write them in:

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

## Color Correction (CC) Calibration

### Environment Preparation

- DNP Light Box

- 24-Color Card

- K230 Development Board

- Serial Port

- IMX219 Camera

Placement Requirements: The color card must occupy 80% or more of the image and must be positioned straight.

### Capture RAW Images

Light Source Type: Consistent with LSC calibration (A/A_100, U30/F12, TL84/F11, D50, D65)

![1740391632767](https://www.kendryte.com/api/post/attachment?id=817)

![1740391632768](https://www.kendryte.com/api/post/attachment?id=818)

Capture Steps:

- Face the color card directly at the camera, execute the capture command to obtain the RAW image of the color card

- Remove the color card, keep the camera position unchanged, and capture the background image for the corresponding light source

- Switch all light sources and repeat the above operations

![1740391632769](https://www.kendryte.com/api/post/attachment?id=819)

The final data output is as follows:

![1740391632770](https://www.kendryte.com/api/post/attachment?id=820)

### Data Calibration

- Open ColorCalibrationTool, set the parameters Width, Height, Bits, Bayer CFA pattern, BLS (Offset)

- Load files:

  - Load sRGB References: Select CC_Standard.cxf
  - Load Color Checker Image: Select the color card RAW image
  - Load Background Image: Select the background image
  - Load LSC Profile: Select the LSC parameter file for the corresponding light source

- Uncheck "Clip Reference Colors" and "Camera Input with applied output gamma"

- Click Calibrate, select the center points of the four corner color patches of the color card

- Click Save parameters to save the file, and obtain the white balance (wb) and color matrix (ctm) data

![1740391632771](https://www.kendryte.com/api/post/attachment?id=821)

![1740391632772](https://www.kendryte.com/api/post/attachment?id=822)

![1740391632773](https://www.kendryte.com/api/post/attachment?id=823)

Example of generated parameter file:

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

### Update ISP File

Select the same light source as manual LSC to write the parameters

JSON file (imx219-1920x1080_manual.json), modify the values of gain and ccmatrix,
gain is obtained from wb in the file, use wb[0] and wb[2] to override gain[0] and gain[3]:

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

XML file (imx219-1920x1080.xml):

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

  <!-- Other light sources (D65_100, F11_100, F12_100) configurations are similar, add ccMatrix and wb nodes in sequence -->

</CC>
```

## Final Verification

- After completing all parameter modifications, recompile the MPP project and generate a new image
- Flash the image to the development board and start the system
- Run the capture command to verify whether the image's black level, color uniformity, and color accuracy meet expectations
- If any abnormality exists, return to the corresponding step to adjust the calibration parameters or sensor configuration
