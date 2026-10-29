# K230 Touch API Reference

## Overview

K230's touch capability consists of two parts:

- Touch device management: dynamically register/remove touch devices via `canmv_misc`
- Touch read/write HAL: read touch points and device information via `drv_touch` instance

Related header files:

- `src/rtsmart/libs/rtsmart_hal/components/canmv_misc/canmv_misc.h`
- `src/rtsmart/libs/rtsmart_hal/drivers/touch/drv_touch.h`

## Key Data Structures

### `struct drv_touch_config_t`

Used to pass hardware configuration when creating a touch device:

- `touch_dev_index`: device index
- `range_x` / `range_y`: coordinate range (0 can be left to system default)
- `pin_intr` / `intr_value`: interrupt pin and active level (use `-1` when no interrupt)
- `pin_reset` / `reset_value`: reset pin and active level (use `-1` when no reset)
- `i2c_bus_index` / `i2c_bus_speed`: I2C bus number and speed

### `struct drv_touch_data`

Single touch point data:

- `event`: event type (`NONE`/`UP`/`DOWN`/`MOVE`)
- `track_id`: touch point tracking ID
- `x_coordinate` / `y_coordinate`: touch point coordinates
- `width`: touch point width
- `timestamp`: timestamp

### `struct drv_touch_info`

Device capability information:

- `type`: touch type
- `vendor`: vendor information
- `point_num`: maximum number of touch points
- `range_x` / `range_y`: coordinate range

## Device Management API（canmv_misc）

### `canmv_misc_create_touch_device`

```c
int canmv_misc_create_touch_device(struct drv_touch_config_t* cfg);
```

Register a touch device by `cfg`.

- Return value: `0` on success, non-`0` on failure.

### `canmv_misc_delete_touch_device`

```c
int canmv_misc_delete_touch_device(int index);
```

Unregister a touch device by index.

- Return value: `0` on success, non-`0` on failure.

## Read/Write HAL API (drv_touch)

### `drv_touch_inst_create`

```c
int drv_touch_inst_create(int id, drv_touch_inst_t** inst);
```

Create a touch instance.

- Common errors: `-1` parameter error, `-2` invalid device ID, `-3` out of memory.

### `drv_touch_inst_destroy`

```c
void drv_touch_inst_destroy(drv_touch_inst_t** inst);
```

Destroy the instance and release resources.

### `drv_touch_read`

```c
int drv_touch_read(drv_touch_inst_t* inst, struct drv_touch_data* touch_data, int max_points);
```

Read touch points.

- Return value: `>0` indicates the number of touch points, `0` no event, `<0` error (commonly `-1/-2`).

### `drv_touch_get_info`

```c
int drv_touch_get_info(drv_touch_inst_t* inst, struct drv_touch_info* info);
```

Query device capability information.

### `drv_touch_get_config`

```c
int drv_touch_get_config(drv_touch_inst_t* inst, struct drv_touch_config_t* cfg);
```

Query the current device configuration.

### `drv_touch_reset`

```c
int drv_touch_reset(drv_touch_inst_t* inst);
```

Perform a touch device reset.

### `drv_touch_get_default_rotate`

```c
int drv_touch_get_default_rotate(drv_touch_inst_t* inst, int* rotate);
```

Read the default rotation configuration (`0/90/180/270/swap_xy`).

## Recommended Call Flow

1. If a device needs to be dynamically created, first call `canmv_misc_create_touch_device()`.
1. Call `drv_touch_inst_create()` to open the instance.
1. First call `drv_touch_get_info()` / `drv_touch_get_config()` to confirm capabilities and coordinate ranges.
1. Loop call `drv_touch_read()` to read touch events.
1. Call `drv_touch_inst_destroy()` on exit.
1. If the device was dynamically created, finally call `canmv_misc_delete_touch_device()`.

## Reference Example

- `src/rtsmart/examples/peripheral/touch/test_touch.c`
