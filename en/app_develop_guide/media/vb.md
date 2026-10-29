# VB Demo

## Introduction

This example demonstrates how to use the VB (Video Buffer) module of K230. The VB module is a video buffer management module used to manage the allocation, release, and transfer of video frames.

## Function Description

### VB Functions

This example demonstrates the usage of VB:

- **VB Pool Initialization**: Create a video buffer pool
- **Frame Allocation**: Allocate video frames from the VB pool
- **Frame Release**: Release video frames back to the VB pool
- **Block Allocation**: Allocate VB blocks of a specified size
- **Block Release**: Release VB blocks
- **Statistics**: Query VB usage statistics

### VB Pool Features

- **Multi-format Support**: Supports multiple pixel formats
- **Dynamic Allocation**: Runtime dynamic allocation and release
- **Memory Pool**: Pre-allocated memory pool for improved performance
- **Zero Copy**: Reduces memory copy operations
- **DMA Support**: Supports DMA transfer

### Supported Pixel Formats

- **RGB Formats**: RGB565, RGB888, ARGB8888, etc.
- **YUV Formats**: YUV420, YUV422, YUV444, etc.
- **Compressed Formats**: JPEG, etc.

### Main Interfaces

- `kd_mpi_vb_init()` - Initialize the VB module
- `kd_mpi_vb_deinit()` - Deinitialize the VB module
- `kd_mpi_vb_set_config()` - Configure VB parameters
- `kd_mpi_vb_create_pool()` - Create a VB pool
- `kd_mpi_vb_get_block()` - Get a VB block
- `kd_mpi_vb_release_block()` - Release a VB block
- `kd_mpi_vb_get_supplement_addr()` - Get the supplement address

## Code Location

Demo source code location: `src/rtsmart/examples/mpp/sample_vb`

## Usage Instructions

### Compilation Method

Use `make menuconfig` in the `K230 RTOS SDK` root directory to configure compilation options, select to compile the VB example into the firmware, and then compile the firmware.

### Running the Example

```shell
./sample_vb
```

### Viewing Results

After the program runs, it will:

1. Initialize the VB module
1. Create a VB pool
1. Allocate video frames
1. Release video frames
1. Query statistics

Output example:

```text
Video Buffer Test
================

Initializing VB module...
VB initialized successfully

Creating VB pool...
Pool size: 10 blocks
Block size: 1920x1080
Pixel format: YUV420P
Pool created successfully

Allocating blocks...
Allocated block 1: phys=0x12345678, virt=0x87654321
Allocated block 2: phys=0x12349000, virt=0x87658000
...
Allocated block 10: phys=0x12350000, virt=0x87660000

Releasing blocks...
Released block 1
Released block 2
...
Released block 10

Getting statistics...
Total blocks: 10
Used blocks: 0
Free blocks: 10

Destroying VB pool...
Pool destroyed

All tests completed successfully!
```

### Usage Scenarios

VB is mainly used for:

- Video Input (VI) output buffer
- Video Decode (VDEC) output buffer
- Video Encode (VENC) input buffer
- Video Output (VO) input buffer
- AI inference input buffer

```{admonition} Tip
VB is the basic module of the multimedia subsystem. When using VI, VDEC, VENC, VO and other modules, VB must be initialized first. For specific interfaces of the VB module, please refer to the [System Control API Documentation](../../api_reference/mpp/mpp_sys.md).
```
