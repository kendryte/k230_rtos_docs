# USB HID API Reference

## Overview

The USB HID input interface in the RTOS SDK is provided by `drv_input`, which uniformly abstracts keyboards, mice, and USB touch class input devices.

Header file location:

```c
#include "drv_input.h"
```

Corresponding source code:

- `src/rtsmart/libs/rtsmart_hal/drivers/input/drv_input.h`
- `src/rtsmart/libs/rtsmart_hal/drivers/input/drv_input.c`

## Device Types

```c
enum drv_input_device_type {
    DRV_INPUT_DEV_UNKNOWN = 0,
    DRV_INPUT_DEV_KEYBOARD,
    DRV_INPUT_DEV_MOUSE,
    DRV_INPUT_DEV_TOUCH,
};
```

## Key Data Structures

### `struct drv_input_info`

Device capability information:

- `kind`: Device type
- `ev_bits`: Bitmap of supported events
- `key_bits`: Bitmap of supported keys
- `rel_bits`: Bitmap of supported relative coordinates
- `abs_bits`: Bitmap of supported absolute coordinates
- `name`: Device name

### `drv_input_inst_t`

The input device instance handle, containing:

- `id`: Device number
- `fd`: Device file descriptor
- `button_state`: Current button state bits
- `path`: Device path

The application layer should only treat it as a handle and is not recommended to modify members directly.

### `struct drv_keyboard_frame`

Keyboard frame:

- `keycodes[]`: Key code array
- `values[]`: Key value array, corresponding to `KEY_PRESSED` / `KEY_RELEASED` / `KEY_REPEAT`
- `count`: Number of events in this frame
- `complete`: Whether a sync end event has been read

### `struct drv_pointer_frame`

Pointer frame, applicable to mouse and USB touch devices:

- `complete`
- `has_rel`
- `has_abs`
- `touch_seen`
- `touch_down`
- `rel_x` / `rel_y`
- `wheel` / `hwheel`
- `abs_x` / `abs_y`
- `pressure`
- `buttons`
- `pressed_mask`
- `released_mask`

## Basic Instance API

### `drv_input_inst_create`

```c
int drv_input_inst_create(int id, drv_input_inst_t **inst);
```

Open an input device by event number, e.g., `event0`.

### `drv_input_inst_create_path`

```c
int drv_input_inst_create_path(const char *path, drv_input_inst_t **inst);
```

Open an input device by path, e.g., `/dev/hidk0`.

### `drv_input_inst_destroy`

```c
void drv_input_inst_destroy(drv_input_inst_t **inst);
```

Close and destroy the instance.

## Read/Write API

### `drv_input_poll`

```c
int drv_input_poll(drv_input_inst_t *inst, int timeout_ms);
```

Wait for an input event.

Return value:

- `> 0`: there is an event
- `0`: timeout
- `< 0`: error code

### `drv_input_read_event`

```c
int drv_input_read_event(drv_input_inst_t *inst, struct input_event *event);
```

Read a single raw `input_event`.

### `drv_input_read_frame`

```c
int drv_input_read_frame(drv_input_inst_t *inst, struct drv_input_frame *frame);
```

Read a frame of raw input events until a sync event is encountered or no more data is available.

### `drv_input_read_keyboard_frame`

```c
int drv_input_read_keyboard_frame(drv_input_inst_t *inst, struct drv_keyboard_frame *frame);
```

Read a keyboard frame.

Return value:

- `> 0`: number of key-value pairs in the frame
- `0`: no complete keyboard event currently
- `< 0`: error code

### `drv_input_read_pointer_frame`

```c
int drv_input_read_pointer_frame(drv_input_inst_t *inst, struct drv_pointer_frame *frame);
```

Read a pointer frame, used for mouse and USB touch.

## Information and Discovery API

### `drv_input_get_info`

```c
int drv_input_get_info(drv_input_inst_t *inst, struct drv_input_info *info);
```

Query device capability information.

### `drv_input_find_first_by_type`

```c
int drv_input_find_first_by_type(uint32_t kind,
                                 char *path,
                                 size_t path_size,
                                 struct drv_input_info *info);
```

Find the first input device of the specified type, and return the path and capability information.

Applicable to the following scenarios:

- Automatically discover USB keyboard at startup
- Re-bind the same type of device after hot-plug

## Hot-plug Related APIs

### `drv_input_is_disconnect_error`

```c
bool drv_input_is_disconnect_error(int ret);
```

Determine whether an error code indicates that the device has been disconnected.

Currently, the following errors are mainly recognized:

- `-ENODEV`
- `-EIO`
- `-ENXIO`

### `drv_input_reconnect_path`

```c
int drv_input_reconnect_path(drv_input_inst_t **inst,
                             const char *path,
                             struct drv_input_info *info);
```

Reopen the device by a fixed path.

### `drv_input_reconnect_by_type`

```c
int drv_input_reconnect_by_type(drv_input_inst_t **inst,
                                uint32_t kind,
                                char *path,
                                size_t path_size,
                                struct drv_input_info *info);
```

Rediscover and reconnect the device by its type.

This is the most commonly used interface in USB HID hot-plug scenarios.

## Event Auxiliary Judgment API

### `drv_input_is_key_event`

```c
bool drv_input_is_key_event(const struct input_event *event);
```

### `drv_input_is_rel_event`

```c
bool drv_input_is_rel_event(const struct input_event *event);
```

### `drv_input_is_abs_event`

```c
bool drv_input_is_abs_event(const struct input_event *event);
```

### `drv_input_is_sync_event`

```c
bool drv_input_is_sync_event(const struct input_event *event);
```

Used to determine the raw `input_event` type.

## Recommended Call Flow

### Keyboard

1. Use `drv_input_inst_create_path()` or `drv_input_reconnect_by_type()` to open the device
1. Call `drv_input_poll()` to wait for data
1. Call `drv_input_read_keyboard_frame()` to read a frame
1. If an error is returned, use `drv_input_is_disconnect_error()` to determine whether reconnection is needed
1. Call `drv_input_inst_destroy()` on exit

### Mouse / USB Touch

1. Open an input instance
1. Call `drv_input_poll()` to wait for data
1. Call `drv_input_read_pointer_frame()` to read a pointer frame
1. Use fields such as `has_rel` / `has_abs` / `buttons` / `touch_down` to handle input
1. Perform reconnection when disconnected

## Example Code Snippet

```c
drv_input_inst_t *inst = NULL;
struct drv_input_info info;

if (drv_input_reconnect_by_type(&inst,
                                DRV_INPUT_DEV_KEYBOARD,
                                NULL,
                                0,
                                &info) == 0) {
    printf("keyboard ready: %s\n", info.name);
}
```

```c
struct drv_keyboard_frame frame;
int ret = drv_input_read_keyboard_frame(inst, &frame);
if (ret > 0) {
    for (size_t i = 0; i < frame.count; i++) {
        printf("key=%u value=%d\n", frame.keycodes[i], frame.values[i]);
    }
}
```

## Notes

1. Do not treat Linux input keycodes as sequential character numbers, especially for letter keys.
1. For hot-plug devices, it is recommended to always combine `drv_input_is_disconnect_error()` and `drv_input_reconnect_by_type()`.
1. The reading interfaces for keyboard and pointer devices are different. Do not mix `drv_input_read_keyboard_frame()` with `drv_input_read_pointer_frame()`.

## Related Documentation

- [USB HID Examples and Test Instructions](../../app_develop_guide/peripheral/usb_hid.md)
