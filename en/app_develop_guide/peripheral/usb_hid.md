# USB HID Examples and Test Instructions

## Overview

RTOS SDK provides USB HID input access based on `drv_input`, suitable for keyboards, mice, and USB touch devices. The current repository already includes keyboard and mouse test programs that can be used to verify:

- Blocking read
- Non-blocking read
- `poll()` event notification
- Automatic reconnection flow after device disconnection

Related source code:

- `src/rtsmart/examples/peripheral/usb_hid_kbd/test_hid.c`
- `src/rtsmart/examples/peripheral/usb_hid_mouse/test_hid_mouse.c`

## Device Nodes

Common device nodes are as follows:

- Keyboard: `/dev/hidk0`
- Mouse: `/dev/hidm0`
- USB touch: usually also exposed through the `drv_input` pointer-like interface; the specific node name depends on the actual system registration result

If you are unsure about the specific node, you can call `drv_input_reconnect_by_type()` in your application to automatically find devices of the same type.

## Keyboard Test

### Source Location

`src/rtsmart/examples/peripheral/usb_hid_kbd/test_hid.c`

### Example Contents

This example contains 3 groups of tests:

1. Blocking read: first `drv_input_poll(inst, -1)`, then read the complete keyboard frame
1. Non-blocking read: loop read, verify the empty read path when there is no data
1. `poll()` read: wait for `POLLIN` with timeout, then continuously read the current frame

### How to Run

```shell
./test_hid [dev_path]
```

Parameters:

- `dev_path`: optional, default `/dev/hidk0`

### Typical Output

```text
=== Test 1: Blocking Read ===
Opening /dev/hidk0 in blocking mode...
Device opened successfully (fd=3)
Press keys on USB keyboard...
    EV_KEY: G -> PRESSED
    EV_KEY: G -> RELEASED
    EV_SYN: --- frame 1 end ---
```

### Hot-plug Behavior

When `poll()` or `read()` returns a disconnection error, the test program will repeatedly call `drv_input_reconnect_by_type()` or `drv_input_reconnect_path()` until the device reappears.

## Mouse Test

### Source Code Location

`src/rtsmart/examples/peripheral/usb_hid_mouse/test_hid_mouse.c`

### Example Content

The mouse test also includes 3 groups of tests:

1. Blocking read
1. Non-blocking read
1. `poll()` read

The output includes:

- Button press/release
- Relative displacement `REL_X` / `REL_Y`
- Scroll wheel `REL_WHEEL` / `REL_HWHEEL`
- Absolute coordinates `ABS_X` / `ABS_Y`
- Pressure `ABS_PRESSURE`

### How to Run

```shell
./test_hid_mouse [dev_path]
```

Parameters:

- `dev_path`: Optional, default is usually `/dev/hidm0`

### Typical Output

```text
=== Test 3: Poll Read ===
    EV_KEY: LEFT -> PRESSED
    EV_REL: REL_X -> 15
    EV_REL: REL_Y -> -4
    EV_SYN: --- frame end ---
```

## USB Touch Access Suggestions

The pointer frame structure of `drv_input` is compatible with both mouse and USB touch devices, so if your USB touch device uses the HID protocol, you can reuse the following interfaces:

- `drv_input_poll()`
- `drv_input_read_pointer_frame()`
- `drv_input_reconnect_by_type(..., DRV_INPUT_DEV_TOUCH, ...)`

For USB touch, the usual points of focus are:

- `has_abs`
- `abs_x` / `abs_y`
- `pressure`
- `touch_seen`
- `touch_down`

## Recommended Development Flow

1. First use the example program to confirm that the device node, hot-plug, and event format are all correct.
1. Keyboard devices use `drv_input_read_keyboard_frame()`.
1. Mouse and USB touch devices use `drv_input_read_pointer_frame()`.
1. In production applications, it is recommended to combine `drv_input_poll()` with reconnection logic, rather than blocking on a single read for a long time.

## Frequently Asked Questions

### What if keyboard key characters are displayed incorrectly?

If the upper-layer application needs to convert keycodes to characters, do not assume that `KEY_A` through `KEY_Z` are consecutively numbered. Linux input event keycodes are not arranged consecutively in alphabetical order; you should use an explicit mapping table.

### What if the application stops receiving data after the device is unplugged?

When a polling timeout or read failure occurs, check `drv_input_is_disconnect_error(ret)`, and proactively follow the reconnection logic.

## Related Documentation

- [USB HID API Reference](../../api_reference/peripheral/usb_hid.md)
- [USB HID Keyboard Example](usb_hid_kbd.md)
