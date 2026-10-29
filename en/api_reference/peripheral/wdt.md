# Watchdog HAL Interface Documentation

## Hardware Introduction

The K230 integrates an internal Watchdog Timer used to monitor system running status. When the system experiences an abnormality and fails to "feed the dog" in time, the watchdog will trigger a system reset to prevent system crashes. The watchdog timeout duration is configurable, supporting start, stop, and feed operations.

---

## Function Interface Description

### `int wdt_set_timeout(uint32_t timeout_sec);`

**Function**: Set the watchdog timeout duration.

**Parameters**:

- `timeout_sec`: Timeout duration (seconds)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `uint32_t wdt_get_timeout(void);`

**Function**: Get the current watchdog timeout setting.

**Return Value**:

- `>=0`: Current timeout duration (seconds)
- `-1`: Failure

---

### `int wdt_start();`

**Function**: Start the watchdog. After starting, the dog must be fed periodically, otherwise the system will reset after timeout.

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int wdt_stop();`

**Function**: Stop the watchdog.

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int wdt_feed();`

**Function**: Feed the dog operation, refreshes the watchdog timer to prevent system reset.

**Return Value**:

- `0`: Success
- `-1`: Failure

---

## Usage Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_wdt.c`
