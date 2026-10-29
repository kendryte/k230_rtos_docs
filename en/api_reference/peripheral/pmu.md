# PMU HAL Interface Documentation

## Overview

K230 provides PMU HAL interfaces for handling the long-press shutdown process during system runtime, as well as configuring RTC timed shutdown/timed power-on.

- User-space HAL header: `src/rtsmart/libs/rtsmart_hal/drivers/pmu/drv_pmu.h`
- User-space HAL implementation: `src/rtsmart/libs/rtsmart_hal/drivers/pmu/drv_pmu.c`
- Reference example: `src/rtsmart/examples/peripheral/pmu/test_pmu.c`

The PMU HAL currently primarily covers five categories of capabilities:

1. Long-press power button shutdown notification and user-space acknowledgment
1. Application-initiated immediate shutdown
1. RTC timed shutdown and timed power-on (power cycle)
1. Reading the current level of the shutdown wakeup PAD
1. Reading the wakeup source captured during the current boot

> Note: Normal RTC time read/write operations and normal alarm/tick interrupt configuration are capabilities of the RTC device interface and are not included in the `drv_pmu.h` HAL header.

Interfaces are grouped by function: `key_*` handles only power button long-press events, `rtc_*` handles only RTC timed power cycle, and `drv_pmu_shutdown_now()` is the interface for an application to initiate an immediate shutdown.

---

## Kernel Configuration

The PMU driver and post-shutdown wakeup source must be enabled in the RT-Smart kernel configuration. Configuration entry point:

```text
Drivers Configuration
  -> InterDriver
    -> Using RTC/PMU device drivers
```

After enabling `Using RTC/PMU device drivers`, the corresponding Kconfig symbol is `RT_USING_RTC_PMU`. This option enables the PMU/RTC kernel driver and generates device nodes such as `/dev/pmu_pwrkey`.

### PAD64 Long-Press Parameters

Under `Using RTC/PMU device drivers`, enter:

```text
PMU PAD64 long press
```

This menu contains two mutually independent modification switches:

| Configuration Item | Kconfig Symbol | Description |
| --- | --- | --- |
| Modify PMU long press shutdown seconds | `RT_PMU_LONG_PRESS_SHUTDOWN_CONFIG` | When enabled, displays `PMU long press shutdown seconds` and sets the software long-press shutdown duration during system runtime, in seconds. The range is 1 ~ 30, with a default of 5. |
| Modify PMU long press poweron seconds | `RT_PMU_LONG_PRESS_POWERON_CONFIG` | When enabled, displays `PMU long press poweron seconds` and sets the hardware long-press power-on threshold after PAD64 shutdown, in seconds. The range is 1 ~ 30, with a default of 5. |

Both modification switches are disabled by default. When `Modify PMU long press shutdown seconds` is disabled, the runtime software long-press shutdown duration uses the default 5 seconds; when `Modify PMU long press poweron seconds` is disabled, the driver does not write the PMU hardware long-press power-on threshold register.

### Post-Shutdown PAD Wakeup

Under `Using RTC/PMU device drivers`, enable:

```text
PMU shutdown wakeup PADs
```

The corresponding symbol is `RT_PMU_SHUTDOWN_WAKEUP`. Once enabled, PAD64, PAD65, PAD66, PAD67, PAD68, and PAD69 can be enabled individually; multiple PADs can be enabled simultaneously.

PAD64 is the power button (int0) and is reserved by default for the power button long-press power-on/shutdown process. To use it as a general edge/level wakeup source, enable `RT_PMU_SHUTDOWN_WAKEUP_PAD64` (menu item `Enable PAD64 (power key) as edge/level shutdown wakeup`). Once enabled, PAD64 is completely identical to PAD65 ~ PAD68: during runtime, it can be used as a GPIO to read the current level; during shutdown, it is armed as a PMU edge/level wakeup source according to the configuration; however, **PAD64's runtime long-press power-on/shutdown function is forfeited**. When not enabled, the long-press behavior is retained, and PAD64 is not used as a general wakeup PAD.

> **Design Recommendation**: PAD64 is a dedicated power button input, and its "must be held for N seconds before power-on" threshold is essentially debounce and false-trigger protection for the power-on action. **By default, PAD64 should be used for power button long-press power-on/shutdown and should not be configured as a general level/edge wakeup source like PAD68**. Once general wakeup is enabled, any button press (even an momentary touch, or one satisfying the configured level condition) will immediately wake the system—the semantics of "power-on only after a long press" are thereby invalidated, and the power button is reduced to an ordinary wakeup trigger, making false wakeups extremely likely. Therefore, using PAD64 as a general wakeup source is recommended only when the hardware does not expose any other PMU wakeup PADs (PAD65 ~ PAD69) and there is truly no available wakeup pin; in this case, the trigger type and pull-up/pull-down configuration should be combined to minimize the probability of false wakeups.

Each PAD has an independent `Enable PAD* shutdown wakeup` submenu. The following configuration for that PAD is displayed only after the corresponding PAD has been enabled, and the three configuration items are at the same level:

```text
Enable PAD68 shutdown wakeup
  PAD68 wakeup source name
  PAD68 wakeup trigger type
  PAD68 wakeup PAD pull bias
```

PAD64, PAD65, PAD66, and PAD67 also display their respective debounce configurations. The corresponding Kconfig symbols are as follows:

| Configuration Content | PAD65 Example | Other PADs (PAD64, PAD66 ~ PAD69) |
| --- | --- | --- |
| Enable PAD | `RT_PMU_SHUTDOWN_WAKEUP_PAD65` | Replace `PAD65` with the corresponding PAD |
| Wakeup source name | `RT_PMU_SHUTDOWN_WAKEUP_SOURCE_PAD65` | Replace `PAD65` with the corresponding PAD |
| Trigger type | `RT_PMU_SHUTDOWN_WAKEUP_PAD65_TRIGGER` | Replace `PAD65` with the corresponding PAD |
| PAD pull-up/pull-down | `RT_PMU_SHUTDOWN_WAKEUP_PAD65_BIAS` | Replace `PAD65` with the corresponding PAD |
| debounce ticks | `RT_PMU_SHUTDOWN_WAKEUP_PAD65_DEBOUNCE_TICKS` | Supported only by PAD64, PAD65, PAD66, and PAD67 |

After PAD64 is enabled as a general wakeup source, its configuration symbols follow the same rules as the table above: `RT_PMU_SHUTDOWN_WAKEUP_SOURCE_PAD64`, `RT_PMU_SHUTDOWN_WAKEUP_PAD64_TRIGGER`, `RT_PMU_SHUTDOWN_WAKEUP_PAD64_BIAS`, and `RT_PMU_SHUTDOWN_WAKEUP_PAD64_DEBOUNCE_TICKS`, with the default source name `PAD64_WAKEUP`.

The available trigger types are high level, low level, rising edge, and falling edge, with rising edge as the default. The PAD pull-up/pull-down options are retain current setting, pull-up, pull-down, and disable pull-up/pull-down, with retaining the current `PMU_IO_CFG_x` setting as the default. The debounce ticks for PAD64, PAD65, PAD66, and PAD67 are measured in 32 KHz PMU clock cycles, with a range of 0 ~ 4095 and a default of 256; PAD68 and PAD69 have no corresponding debounce registers.

`wakeup source name` is a string compiled into the kernel, for example `PIR_WAKEUP` or `4G_WAKEUP`. The string buffer is 64 bytes; it is recommended to enter a non-empty name of no more than 63 characters. After the system is woken by that PAD, `drv_pmu_wakeup_source_get()` returns this name.

Notes:

1. `PMU_IO_CFG_0` ~ `PMU_IO_CFG_5` correspond to PAD64 ~ PAD69, respectively. After runtime initialization is complete, all enabled wakeup PADs are switched to GPIO inputs to facilitate reading the current level; when entering the shutdown process, the driver switches them back to PMU inputs and writes their respective trigger type, pull-up/pull-down, and debounce configurations.
1. `drv_pmu_wakeup_pad_get_level()` can read only enabled PADs, and the caller must pass in the PAD number; an unenabled PAD returns failure.
1. The PAD level read is the current runtime GPIO level, not the result of evaluating the trigger condition.
1. If RTC timed power-on is configured at the same time, the driver enables both the RTC alarm wakeup source and the enabled PAD wakeup sources before shutdown.
1. PAD64 (after being enabled as a general wakeup source) and PAD65 ~ PAD69 all support high-level, low-level, rising-edge, and falling-edge wakeup trigger configurations.

After configuration is complete, recompile and flash the kernel. The next time the system executes the PMU shutdown process, the driver will write the PMU interrupt detection and wakeup routing according to each enabled PAD's configuration before shutdown.

---

## Button Shutdown Model

Short press, long-press timing, and button release are all handled by the kernel driver, and the user space does not receive these low-level events.

1. The user space calls `drv_pmu_key_register_notify()` to register a notification for power button shutdown requests
1. The kernel filters out short presses; after the long-press threshold is reached, it sends a shutdown request notification to the user space only once
1. The user space calls `drv_pmu_key_wait_shutdown()` to wait for the shutdown request
1. The user space completes cleanup actions such as saving the state and unmounting the file system
1. The user space calls `drv_pmu_key_confirm_shutdown()` to confirm that cleanup is complete
1. After the interface returns, the driver continues to wait for the user to release the power button; the actual shutdown is performed only after confirming that the button has been released

If the user space does not send a confirmation, the system remains in its current running state and does not shut down automatically.

---

## Data Structure Description

### `drv_pmu_inst_t`

**Description**: PMU HAL instance handle that internally encapsulates the `/dev/pmu_pwrkey` device node, signal wait set, and notification registration state. This type is transparent to the user.

---

## Function Interface Description

### `int drv_pmu_inst_create(drv_pmu_inst_t **inst);`

**Description**: Creates a PMU HAL instance and opens `/dev/pmu_pwrkey`.

**Parameters**:

- `inst`: Returns the created PMU instance

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `void drv_pmu_inst_destroy(drv_pmu_inst_t **inst);`

**Description**: Destroys the PMU HAL instance, automatically unregisters notifications, and closes the device.

**Parameters**:

- `inst`: Pointer to the PMU instance pointer

---

### `int drv_pmu_key_register_notify(drv_pmu_inst_t *inst, int signo);`

**Description**: Registers a PMU event notification.

After registration succeeds, the driver sends the specified signal to the current process. Userspace can wait for a shutdown request by calling `drv_pmu_key_wait_shutdown()`.

**Parameters**:

- `inst`: PMU instance
- `signo`: Notification signal number; if less than or equal to `0`, `SIGUSR1` is used by default

**Return Value**:

- `0`: Success
- `-1`: Failure

**Notes**:

- The HAL automatically blocks this signal internally and restores it when the instance is destroyed or the notification is unregistered
- Repeated calls first unregister the old notification and then register it again

---

### `int drv_pmu_key_unregister_notify(drv_pmu_inst_t *inst);`

**Description**: Unregisters the PMU event notification.

**Parameters**:

- `inst`: PMU instance

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_pmu_key_wait_shutdown(drv_pmu_inst_t *inst, int timeout_ms);`

**Description**: Waits for a long-press shutdown request confirmed by the kernel.

**Parameters**:

- `inst`: PMU instance
- `timeout_ms`: Wait timeout in ms; a value less than `0` means wait indefinitely

**Return Value**:

- `0`: Shutdown request received
- `1`: Timed out, or the wait was interrupted by a signal
- `-1`: Failure

**Notes**:

- `drv_pmu_key_register_notify()` must have been called before this function
- A short press does not return a shutdown request

---

### `int drv_pmu_key_confirm_shutdown(drv_pmu_inst_t *inst);`

**Description**: Confirms that userspace cleanup in the power-key long-press shutdown flow has completed.

After `drv_pmu_key_wait_shutdown()` returns successfully, this function may be called once userspace cleanup is complete. After the call, the driver continues to wait for the user to release the power key. Userspace does not need to wait for or determine the key-release event.

**Parameters**:

- `inst`: PMU instance

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_pmu_shutdown_now(drv_pmu_inst_t *inst);`

**Description**: Immediately performs a PMU shutdown.

This interface does not depend on the power-key long-press event and does not wait for `KEY_RELEASE`. Therefore, it bypasses the key policy requiring a long press for shutdown. The application should complete any necessary cleanup before calling this interface. This interface should not be called during the normal power-key shutdown flow of a product.

---

### `int drv_pmu_wakeup_pad_get_level(drv_pmu_inst_t *inst, uint32_t pad, int *level);`

**Description**: Reads the current IO level of the specified shutdown wakeup PAD that has been enabled.

**Parameters**:

- `inst`: PMU instance
- `pad`: PAD number. Supports PAD64 (requires enabling `RT_PMU_SHUTDOWN_WAKEUP_PAD64`), PAD65 through PAD69; only PADs enabled in the kernel configuration can be read
- `level`: Outputs the current level, where `0` indicates a low level and `1` indicates a high level

**Return Value**:

- `0`: Success
- `-1`: Failure; also fails when the shutdown wakeup PAD configuration is not enabled

**Notes**:

- After system initialization, all enabled wakeup PADs are configured as GPIO inputs. This interface can directly read the current level and does not switch the pin multiplexing function on each call
- When entering the shutdown flow, the driver switches all enabled PADs back to the PMU input function and then configures their respective wakeup detection
- The value read is the current runtime level, not the logical result of the PMU wakeup trigger condition

---

### `int drv_pmu_wakeup_source_get(drv_pmu_inst_t *inst, char *name, size_t name_size);`

**Description**: Reads the wakeup source name captured during the current system boot.

**Parameters**:

- `inst`: PMU instance
- `name`: Buffer that receives the wakeup source name
- `name_size`: Size of the `name` buffer in bytes

**Return Value**:

- `0`: Success
- `-1`: Failure

**Possible Wakeup Source Names**:

- PAD wakeup: Returns the corresponding PAD's Kconfig `wakeup source name`, such as `PIR_WAKEUP`; when PAD64 is enabled for general wakeup, returns its source name (default: `PAD64_WAKEUP`)
- PAD64 long-press power-on (when `RT_PMU_SHUTDOWN_WAKEUP_PAD64` is not enabled): `long press key wake up`
- RTC wakeup: `RTC`

**Notes**:

- This interface reads the boot wakeup state saved during PMU initialization, not an event generated in real time during operation
- During a normal cold boot, or when no wakeup source is recognized, the interface returns failure
- If the PMU reports multiple wakeup sources simultaneously, the interface returns failure. The application should not treat the single returned name as the only source
- This interface does not require a PAD number; the mapping between PADs and names is determined jointly by the kernel configuration and the PMU state during the current boot

---

### `int drv_pmu_rtc_schedule_power_cycle(drv_pmu_inst_t *inst, uint32_t shutdown_after_s, uint32_t poweron_after_s);`

**Description**: Configures a one-time RTC scheduled shutdown/power-on flow.

The system shuts down after `shutdown_after_s` seconds and automatically powers on after waiting an additional `poweron_after_s` seconds following shutdown.

**Parameters**:

- `inst`: PMU instance
- `shutdown_after_s`: Delay before shutdown in seconds
- `poweron_after_s`: Delay before powering on again in seconds

**Return Value**:

- `0`: Success
- `-1`: Failure

**Notes**:

- Both `shutdown_after_s` and `poweron_after_s` must be no less than `DRV_PMU_POWER_CYCLE_MIN_DELAY_S`, whose current value is `2` seconds
- `poweron_after_s` is measured from the time of shutdown, not from the time this interface is called
- This interface configures only one power cycle. To cancel a task that has not yet started, call `drv_pmu_rtc_cancel_power_cycle()`
- If the RTC shutdown flow has already entered the actual shutdown stage, calling the cancel interface cannot guarantee that shutdown will be prevented

---

### `int drv_pmu_rtc_cancel_power_cycle(drv_pmu_inst_t *inst);`

**Description**: Cancels the currently configured RTC scheduled shutdown/power-on flow.

**Parameters**:

- `inst`: PMU instance

**Return Value**:

- `0`: Success
- `-1`: Failure

---

## Recommended Usage Flow

### Application Initiates Immediate Shutdown

1. Call `drv_pmu_inst_create()` to create an instance
1. The application completes the necessary resource cleanup
1. Call `drv_pmu_shutdown_now()` to shut down immediately

This interface does not represent the power key policy and does not check the long-press state. If the product requires "shutdown only after a long press," the business code should not call this interface and should use only the power key monitoring flow below.

### Long-Press Shutdown Scenario

1. Call `drv_pmu_inst_create()` to create a device handle
1. Call `drv_pmu_key_register_notify()` to register a power key event notification
1. Repeatedly call `drv_pmu_key_wait_shutdown()` to wait for a shutdown request
1. Execute user-space cleanup after receiving the shutdown request
1. Call `drv_pmu_key_confirm_shutdown()` to confirm that cleanup is complete
1. Call `drv_pmu_inst_destroy()` before exiting to release resources

### RTC Scheduled Power Cycle Scenario

1. Call `drv_pmu_inst_create()` to create a device handle
1. Call `drv_pmu_rtc_schedule_power_cycle()` to configure the shutdown and startup delays
1. To cancel, call `drv_pmu_rtc_cancel_power_cycle()`
1. Call `drv_pmu_inst_destroy()` when finished to release resources

---

## Minimal Example

### Long-Press Shutdown Listener Example

```c
#include <stdio.h>
#include "drv_pmu.h"

int pmu_wait_shutdown(void)
{
    drv_pmu_inst_t *pmu = NULL;
    if (drv_pmu_inst_create(&pmu) < 0)
        return -1;

    if (drv_pmu_key_register_notify(pmu, 0) < 0)
        goto err;

    for (;;) {
        int ret = drv_pmu_key_wait_shutdown(pmu, -1);

        if (ret < 0)
            goto err;
        if (ret > 0)
            continue;

        /* Perform userspace cleanup */
        if (drv_pmu_key_confirm_shutdown(pmu) < 0)
            goto err;
        break;
    }

    drv_pmu_inst_destroy(&pmu);
    return 0;

err:
    drv_pmu_inst_destroy(&pmu);
    return -1;
}
```

### RTC Scheduled Power Cycle Example

```c
#include <stdint.h>
#include "drv_pmu.h"

int pmu_schedule_cycle(uint32_t shutdown_after_s, uint32_t poweron_after_s)
{
    drv_pmu_inst_t *pmu = NULL;
    int ret = -1;

    if (drv_pmu_inst_create(&pmu) < 0)
        return -1;

    if (drv_pmu_rtc_schedule_power_cycle(pmu,
                                     shutdown_after_s,
                                     poweron_after_s) < 0)
        goto out;

    ret = 0;

out:
    drv_pmu_inst_destroy(&pmu);
    return ret;
}
```

---

## Notes

1. Before use, ensure that the system has enabled `RT_USING_RTC_PMU` and that the device node `/dev/pmu_pwrkey` exists.
1. `drv_pmu_key_wait_shutdown()` relies on the signal notification mechanism; it is recommended that a dedicated thread handle waiting and processing uniformly.
1. `drv_pmu_key_confirm_shutdown()` is only applicable to shutdown requests issued by the kernel; after confirmation is called, the driver will wait for the power key to be released before shutting down. A short press is consumed directly on the kernel side and will not trigger a notification or shutdown.
1. `drv_pmu_shutdown_now()` bypasses the long-press policy, and the application must be responsible for cleanup when using it.
1. If the application decides not to shut down, it can skip calling `drv_pmu_key_confirm_shutdown()`, and the system will continue running.
1. `drv_pmu_rtc_schedule_power_cycle()` depends on the current RTC time being correct; it is recommended to confirm that the RTC time has been set before use.
1. `drv_pmu_wakeup_source_get()` should be called as early as possible after startup; it reads the state saved for the current boot and cannot be used to monitor subsequent wakeup events.
1. After `RT_PMU_LONG_PRESS_POWERON_CONFIG` is enabled, the driver writes the PMU hardware long-press power-on threshold for PAD64 according to `RT_PMU_LONG_PRESS_POWERON_SECONDS`; when disabled, the driver does not modify this register.
1. After modifying Kconfig, the kernel configuration must be regenerated, and the kernel must be compiled and flashed; the user-space HAL and `pmu.elf` must also use new versions compatible with the kernel ABI.

---

## Usage Example

Please refer to `src/rtsmart/examples/peripheral/pmu/test_pmu.c`. The example program is invoked through ELF command-line arguments, not through the built-in msh `pmu` command:

```text
/sdcard/app/examples/peripheral/pmu.elf wakeup_source
/sdcard/app/examples/peripheral/pmu.elf wakeup_level 68
/sdcard/app/examples/peripheral/pmu.elf powercycle 10 30
/sdcard/app/examples/peripheral/pmu.elf cancel
```

Where:

- `wakeup_source`: reads the wakeup source for the current boot; it may be a configured PAD name, `long press key wake up`, or `RTC`
- `wakeup_level <pad>`: continuously reads the current level of the specified enabled PAD
- `powercycle <shutdown_after_s> <poweron_after_s>`: pass at least `2 2`
