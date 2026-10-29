# Timer HAL Interface Documentation

## Hardware Introduction

The K230 integrates 6 hardware timers (Timer0~Timer5), supporting up-counting mode. Each timer can independently configure its frequency, period, and working mode. A software timer feature is also provided, implemented based on POSIX timer, which can be used in timing scenarios with lower precision requirements.

---

## Data Structure Description

### `rt_hwtimer_info_t`

**Description**: Hardware timer feature information.

- `maxfreq`: Maximum supported counting frequency
- `minfreq`: Minimum supported counting frequency
- `maxcnt`: Maximum counter value
- `cntmode`: Counting mode (HWTIMER_CNTMODE_UP: up-counting)

### `rt_hwtimer_mode_t`

**Description**: Timer working mode enumeration.

- `HWTIMER_MODE_ONESHOT`: One-shot trigger mode
- `HWTIMER_MODE_PERIOD`: Periodic trigger mode

### `timer_irq_callback`

**Description**: Timer interrupt callback function type.

```c
typedef void (*timer_irq_callback)(void* args);
```

---

## Hardware Timer Interface

### `int drv_hard_timer_inst_create(int id, drv_hard_timer_inst_t** inst);`

**Function**: Create a hardware timer instance.

**Parameters**:

- `id`: Timer number, range `[0, 5]`
- `inst`: Used to store the created timer instance pointer

**Return Value**:

- `0`: Success
- `Negative value`: Failure

---

### `void drv_hard_timer_inst_destroy(drv_hard_timer_inst_t** inst);`

**Function**: Destroy the hardware timer instance and release resources.

**Parameters**:

- `inst`: Pointer to the timer instance pointer

---

### `int drv_hard_timer_get_info(drv_hard_timer_inst_t* inst, rt_hwtimer_info_t* info);`

**Function**: Get timer hardware feature information.

**Parameters**:

- `inst`: Timer instance pointer
- `info`: Pointer to the structure used to store timer information

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_hard_timer_set_mode(drv_hard_timer_inst_t* inst, rt_hwtimer_mode_t mode);`

**Function**: Set the timer working mode. Must be set when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer
- `mode`: Working mode (one-shot or periodic)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_hard_timer_set_freq(drv_hard_timer_inst_t* inst, uint32_t freq);`

**Function**: Set the timer counting frequency. Must be set when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer
- `freq`: Counting frequency (Hz), must be within the hardware-supported range

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_hard_timer_set_period(drv_hard_timer_inst_t* inst, uint32_t period_ms);`

**Function**: Set the timer period. Must be set when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer
- `period_ms`: Timer period (milliseconds)

**Return Value**:

- `0`: Success
- `-1`: Failure (period out of range)

---

### `int drv_hard_timer_get_freq(drv_hard_timer_inst_t* inst, uint32_t* freq);`

**Function**: Get the current counting frequency of the timer.

**Parameters**:

- `inst`: Timer instance pointer
- `freq`: Pointer used to store the frequency value (Hz)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_hard_timer_start(drv_hard_timer_inst_t* inst);`

**Function**: Start the timer.

**Parameters**:

- `inst`: Timer instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_hard_timer_stop(drv_hard_timer_inst_t* inst);`

**Function**: Stop the timer.

**Parameters**:

- `inst`: Timer instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_hard_timer_register_irq(drv_hard_timer_inst_t* inst, timer_irq_callback callback, void* userargs);`

**Function**: Register the timer interrupt callback function. Must be registered when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer
- `callback`: Interrupt callback function
- `userargs`: User arguments passed to the callback function

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_hard_timer_unregister_irq(drv_hard_timer_inst_t* inst);`

**Function**: Unregister the timer interrupt callback. Must be unregistered when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### Helper Functions

#### `int drv_hard_timer_get_id(drv_hard_timer_inst_t* inst);`

**Function**: Get the timer number.

#### `int drv_hard_timer_is_started(drv_hard_timer_inst_t* inst);`

**Function**: Query whether the timer has been started.

---

## Software Timer Interface

### `int drv_soft_timer_create(drv_soft_timer_inst_t** inst);`

**Function**: Creates a software timer instance. The system supports only one software timer instance.

**Parameters**:

- `inst`: Pointer used to store the created timer instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `void drv_soft_timer_destroy(drv_soft_timer_inst_t** inst);`

**Function**: Destroys a software timer instance.

**Parameters**:

- `inst`: Pointer to the timer instance pointer

---

### `int drv_soft_timer_set_mode(drv_soft_timer_inst_t* inst, rt_hwtimer_mode_t mode);`

**Function**: Sets the software timer operating mode. Must be set when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer
- `mode`: Operating mode (one-shot or periodic)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_soft_timer_set_period(drv_soft_timer_inst_t* inst, int period_ms);`

**Function**: Sets the software timer period. Must be set when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer
- `period_ms`: Timer period (milliseconds)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_soft_timer_start(drv_soft_timer_inst_t* inst);`

**Function**: Starts the software timer.

**Parameters**:

- `inst`: Timer instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_soft_timer_stop(drv_soft_timer_inst_t* inst);`

**Function**: Stops the software timer.

**Parameters**:

- `inst`: Timer instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_soft_timer_register_irq(drv_soft_timer_inst_t* inst, timer_irq_callback callback, void* userargs);`

**Function**: Registers the software timer callback function. Must be registered when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer
- `callback`: Callback function
- `userargs`: User parameters passed to the callback function

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_soft_timer_unregister_irq(drv_soft_timer_inst_t* inst);`

**Function**: Unregisters the software timer callback. Must be unregistered when the timer is stopped.

**Parameters**:

- `inst`: Timer instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_soft_timer_is_started(drv_soft_timer_inst_t* inst);`

**Function**: Queries whether the software timer has been started.

**Parameters**:

- `inst`: Timer instance pointer

**Return Value**:

- `1`: Started
- `0`: Not started

---

## Usage Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_timer.c`
