# OTA Example

## Introduction

This example demonstrates the basic process of writing a `kdimg` image file to an OTA device in blocks.

Source location: `src/rtsmart/examples/peripheral/ota/test_ota.c`

## Example Behavior

- Default image path: `/data/ota_test.kdimg`
- The image path can be overridden via the command line
- The image is read in a loop with a `64KB` block size and written by calling `k230_ota_update()`
- After the write is complete, resources are released and the program exits

## Key Interfaces

- `k230_ota_create()`
- `k230_ota_update()`
- `k230_ota_destroy()`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/ota
make
```

Run:

```shell
./test_ota [image_path]
```

Examples:

```shell
./test_ota
./test_ota /sdcard/update.kdimg
```

## Notes

1. The example itself is not responsible for network download, signature verification, or version policy; these should be handled in the upper-layer flow.
1. Please avoid power loss during the OTA write process.

```{admonition} Tip
For OTA interfaces and the recommended calling sequence, please refer to the [OTA API Documentation](../../api_reference/peripheral/ota.md).
```
