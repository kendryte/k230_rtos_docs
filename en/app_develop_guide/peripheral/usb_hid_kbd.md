# USB HID Keyboard Example

## Introduction

This example demonstrates three types of read methods for HID keyboard input devices: blocking read, non-blocking read, and `poll` event notification.

Source code location: `src/rtsmart/examples/peripheral/usb_hid_kbd/test_hid.c`

## Example Behavior

- Default device node: `/dev/hidk0`
- Test1: Blocking read, waiting for key event frames
- Test2: Non-blocking read, verifying the `EAGAIN` branch
- Test3: `poll()` waits for `POLLIN` then reads the event
- Prints common key names and press/release status

## Runtime Arguments

```shell
./test_hid [dev_path]
```

- `dev_path`: HID device node, default `/dev/hidk0`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/usb_hid_kbd
make
./test_hid
```

```{admonition} Tip
There is currently no standalone HID keyboard page in the API reference; you may first refer to the [Peripheral API Index](../../api_reference/peripheral/index.md).
```
