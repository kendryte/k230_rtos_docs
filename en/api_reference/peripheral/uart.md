# UART Hal Interface Documentation

## Hardware Introduction

The K230 integrates five UART (Universal Asynchronous Receiver-Transmitter) hardware modules internally, among which the rtsmart system occupies one serial port (occupying serial port 0 by default), and other serial ports are available for users.

```{warning}
Before physically connecting UART pins, you must confirm whether the development board's corresponding I/O domain uses **1.8 V** or **3.3 V**, ensure that the external device voltage levels match, and prohibit connecting 5 V UART signals. Do not use the low-quality CH340G module shown in the documentation. For wiring requirements, disabled module images, and voltage inspection methods, see [Serial Port Levels and Adapter Module Safety](../../app_develop_guide/peripheral/uart.md).
```

---

## Data Structure Description

### `struct uart_configure`

UART configuration structure, containing the following members:

* `baud_rate`: baud rate
* `data_bits`: number of data bits (5-9)
* `stop_bits`: number of stop bits (0-3 corresponding to 1-4 stop bits)
* `parity`: parity bit (0: no parity, 1: odd parity, 2: even parity)
* `bit_order`: bit order (0: LSB first, 1: MSB first)
* `invert`: signal inversion (0: normal mode, 1: inverted mode)
* `bufsz`: buffer size
* `reserved`: reserved field

---

## Function Interface Description

### `int drv_uart_inst_create(int id, drv_uart_inst_t** inst);`

**Function**: Creates a UART driver instance.

**Parameters**:

* `id`: UART interface ID, range `[0, KD_HARD_UART_MAX_NUM-1]`
* `inst`: Double pointer, used to store the created instance

**Return Value**:

* `0`: Created successfully
* `-1`: Invalid parameter
* `-2`: Invalid UART ID
* `-3`: Memory allocation failed

---

### `void drv_uart_inst_destroy(drv_uart_inst_t** inst);`

**Function**: Destroys a UART driver instance.

**Parameters**:

* `inst`: Double pointer, pointing to the instance to be destroyed

---

### `size_t drv_uart_read(drv_uart_inst_t* inst, const uint8_t* buffer, size_t size);`

**Function**: Reads data from UART.

**Parameters**:

* `inst`: UART instance
* `buffer`: Buffer to store the read data
* `size`: Number of bytes to read

**Return Value**:

* On success: Number of bytes actually read
* `-1`: Invalid parameter
* `-2`: Read error

---

### `size_t drv_uart_write(drv_uart_inst_t* inst, uint8_t* buffer, size_t size);`

**Function**: Writes data to UART.

**Parameters**:

* `inst`: UART instance
* `buffer`: Data to be written
* `size`: Number of bytes to write

**Return Value**:

* On success: Number of bytes actually written
* `-1`: Invalid parameter
* `-2`: Write error

---

### `int drv_uart_poll(drv_uart_inst_t* inst, int timeout_ms);`

**Function**: Polls UART for read availability.

**Parameters**:

* `inst`: UART instance
* `timeout_ms`: Timeout in milliseconds, `-1` means infinite wait, `0` means non-blocking

**Return Value**:

* `>0`: Data is available to read
* `0`: Timeout
* `-1`: Invalid parameter
* `-errno`: Polling error (negative errno value)
* `-EIO`: Device error

---

### `size_t drv_uart_recv_available(drv_uart_inst_t* inst);`

**Function**: Checks the number of bytes available to read.

**Parameters**:

* `inst`: UART instance

**Return Value**:

* On success: Number of bytes available to read
* `-1`: Invalid parameter
* `-2`: IOCTL error

---

### `int drv_uart_send_break(drv_uart_inst_t* inst);`

**Function**: Sends a break signal on the UART TX line. Forces the TX line low for a period of time, used for special event signals (such as LIN sync, attention request, soft reset, etc.).

**Parameters**:

* `inst`: UART instance

**Return Value**:

* `0`: Success
* `-1`: Invalid instance or not opened
* `-2`: IOCTL call failed

---

### `int drv_uart_set_config(drv_uart_inst_t* inst, struct uart_configure* cfg);`

**Function**: Sets UART configuration.

**Parameters**:

* `inst`: UART instance
* `cfg`: Configuration structure

**Return Value**:

* `0`: Success
* `-1`: Invalid parameter
* `-2`: IOCTL error

**Note**: This function cannot modify `bufsz`, please use `drv_uart_configure_buffer_size` to modify the buffer size.

---

### `int drv_uart_get_config(drv_uart_inst_t* inst, struct uart_configure* cfg);`

**Function**: Gets the current UART configuration.

**Parameters**:

* `inst`: UART instance
* `cfg`: Structure used to store the configuration

**Return Value**:

* `0`: Success
* `-1`: Invalid parameter
* `-2`: IOCTL error

---

### `int drv_uart_configure_buffer_size(int id, uint16_t size);`

**Function**: Configures the buffer size for the specified UART device.

**Parameters**:

* `id`: UART device ID (e.g., 0 means UART0, 1 means UART1, etc.)
* `size`: Buffer size to be set

**Return Value**:

* `0`: Success
* `-1`: Invalid UART ID or state error
* `-2`: Device not found or configuration failed

**Note**: This function should be called before creating an instance.

---

### `int drv_uart_get_id(drv_uart_inst_t *inst);`

**Function**: Gets the ID of the UART instance.

**Parameters**:

* `inst`: UART instance

**Return Value**:

* On valid: UART ID
* On invalid: `-1`

---

### `int drv_uart_get_fd(drv_uart_inst_t *inst);`

**Function**: Gets the file descriptor of the UART instance.

**Parameters**:

* `inst`: UART instance

**Return Value**:

* On valid: File descriptor
* On invalid: `-1`

---

## Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_uart.c`

---

## Notes

1. The `bufsz` field of `struct uart_configure` can only be modified through the `drv_uart_configure_buffer_size` interface; using `drv_uart_set_config` cannot modify `bufsz`. The general approach is to first call `drv_uart_get_config` to obtain the current configuration, modify parameters other than `bufsz`, and then call `drv_uart_set_config`.

1. `drv_uart_configure_buffer_size` must be called before creating the instance.

1. The invert field is not supported on the K230.
