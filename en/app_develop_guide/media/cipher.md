# Cipher Demo

## Introduction

This chapter corresponds to the security capability examples under the `sample_cipher` directory, mainly covering AES, Hash, hardware Hash, and PUF related capabilities.

## Code Location

- `src/rtsmart/examples/mpp/sample_cipher/sample_aes`
- `src/rtsmart/examples/mpp/sample_cipher/sample_hash`
- `src/rtsmart/examples/mpp/sample_cipher/sample_hwhash`
- `src/rtsmart/examples/mpp/sample_cipher/sample_pufs`

## Compilation Method

Enable the following options in `make menuconfig`:

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_cipher`

Then execute the firmware compilation.

## Running Examples

After compilation, multiple executable files will be generated (named after the subdirectories):

```shell
cd /sdcard/app/examples/mpp
./sample_aes.elf
./sample_hash.elf
./sample_hwhash.elf
./sample_pufs.elf
```

## Description

- `sample_aes` mainly verifies the `/dev/aes` related workflows.
- `sample_hash` demonstrates the software hash workflow.
- `sample_hwhash` demonstrates the hardware hash workflow.
- `sample_pufs` demonstrates the PUF encryption/decryption/signature related workflows.
