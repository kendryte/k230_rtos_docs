# Timer Example

## Introduction

This example is a timer driver test program, covering the creation, parameter configuration, interrupt callbacks, and start/stop procedures of hardware timers and software timers.

Source location: `src/rtsmart/examples/peripheral/timer/test_timer.c`

## Example Behavior

- Hardware timer test:
  - Create instance
  - Set mode/frequency/period
  - Register callback and verify trigger count
  - Query running status and ID
  - Stop and destroy
- Software timer test:
  - oneshot and periodic modes
  - Register callback and verify trigger
  - Stop, unregister and destroy

## Key Interfaces

- `drv_hard_timer_inst_create()` / `drv_hard_timer_inst_destroy()`
- `drv_hard_timer_set_mode()` / `drv_hard_timer_set_freq()` / `drv_hard_timer_set_period()`
- `drv_hard_timer_register_irq()` / `drv_hard_timer_start()` / `drv_hard_timer_stop()`
- `drv_soft_timer_create()` / `drv_soft_timer_destroy()`
- `drv_soft_timer_set_mode()` / `drv_soft_timer_set_period()`
- `drv_soft_timer_register_irq()` / `drv_soft_timer_start()` / `drv_soft_timer_stop()`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/timer
make
./test_timer
```

This example has no command-line arguments.

```{admonition} Tip
For details on timer interfaces, please refer to the [Timer API Documentation](../../api_reference/peripheral/timer.md).
```
