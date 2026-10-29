# VO WBC Save Demo

## Introduction

This example demonstrates how to use the WBC (White Balance Calibration) save function of the K230's VO (Video Output) module. WBC is used to calibrate display white balance and improve display quality.

## Feature Description

### WBC Functions

This example demonstrates the main features of WBC saving:

- **White Balance Calibration**: Automatically calibrate display white balance
- **WBC Data Save**: Save WBC data to a file
- **WBC Parameter Configuration**: Configure WBC calibration parameters
- **Quality Evaluation**: Evaluate white balance calibration results

### WBC Characteristics

- **Automatic Calibration**: Supports automatic white balance calibration
- **Manual Calibration**: Supports manual white balance parameter setting
- **Temperature Compensation**: Supports temperature-related white balance compensation
- **Data Export**: Supports exporting WBC calibration data

### Application Scenarios

- Display quality optimization
- White balance calibration
- Display effect testing
- Production line calibration

## Code Location

Demo source location: `src/rtsmart/examples/mpp/sample_vo_wbc_dump`

## Usage Instructions

### Compilation Method

In the `K230 RTOS SDK` root directory, use `make menuconfig` to configure build options, select to compile the VO WBC dump example into the firmware, then build the firmware.

### Running the Example

```shell
./sample_vo_wbc_dump [options]
```

### Parameter Description

| Parameter Name | Description | Default Value |
|--------|------|--------|
| output_file | Output file name | wbc_data.bin |
| calibrate | Whether to perform calibration | yes |
| dump_data | Whether to dump data | yes |

### Viewing Results

After the program runs, it will:

1. Initialize the VO module
1. Configure the WBC function
1. Perform white balance calibration
1. Dump WBC data to file
1. Display calibration statistics

Output example:

```text
VO WBC Dump Demo
==================

Initializing VO module...
VO initialized successfully

Configuring WBC...
WBC module configured

Starting WBC calibration...
Calibrating white balance...
Channel R: Gain=1.2, Offset=10
Channel G: Gain=1.1, Offset=5
Channel B: Gain=1.15, Offset=8

Calibration completed!

Dumping WBC data...
Data size: 1024 bytes
Output file: wbc_data.bin

Calibration statistics:
R gain: 1.200
G gain: 1.100
B gain: 1.150
R offset: 10
G offset: 5
B offset: 8
Quality score: 95.5

Dump completed!
Press Ctrl+C to exit.
```

```{admonition} Tip
WBC white balance calibration can significantly improve display quality, and periodic calibration is recommended. For specific interfaces of the WBC module, please refer to the [Display Output API Documentation](../../api_reference/mpp/display.md).
```
