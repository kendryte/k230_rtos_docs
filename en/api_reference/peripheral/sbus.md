# SBUS HAL Interface Documentation

## Hardware Introduction

K230 supports implementing the SBUS (Serial Bus) protocol through the UART interface. SBUS is a serial communication protocol commonly used in remote control receivers, using a 100kbps baud rate, 8 data bits, 2 stop bits, and even parity. It supports 16 channels (11-bit precision per channel), as well as frame lost and failsafe flag bits.

```{warning}
Before connecting an SBUS device, you must verify that the signal levels of the K230 UART I/O voltage domain match those of the external device; inputting 5 V signals is prohibited. For complete requirements, see [Serial Port Voltage Levels and Adapter Module Safety](../../app_develop_guide/peripheral/uart.md).
```

---

## Data Structure Description

### `sbus_flag_t`

**Description**: SBUS flag bit structure.

- `ch17`: Digital channel 17 status
- `ch18`: Digital channel 18 status
- `frame_lost`: Frame lost flag
- `failsafe`: Failsafe flag

### `sbus_dev_t`

**Description**: SBUS device handle type.

---

## Function Interface Description

### `sbus_dev_t sbus_create(int uart_id);`

**Function**: Creates an SBUS device instance and configures UART parameters.

**Parameters**:

- `uart`: UART device ID, supports 1 ~ 4, representing uart1 ~ uart4

**Return Value**:

- Success: Returns the SBUS device handle
- Failure: Returns `NULL`

---

### `void sbus_destroy(sbus_dev_t dev);`

**Function**: Destroys the SBUS device instance and releases resources.

**Parameters**:

- `dev`: SBUS device handle

---

### `int sbus_set_channel(sbus_dev_t dev, uint8_t channel_index, uint16_t value);`

**Function**: Sets the value of the specified channel.

**Parameters**:

- `dev`: SBUS device handle
- `channel_index`: Channel index, range `[0, 15]`
- `value`: Channel value, 11-bit precision, typical range `[172, 1811]`, mid value 1024

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int sbus_set_all_channels(sbus_dev_t dev, uint16_t *channels);`

**Function**: Sets the values of all 16 channels.

**Parameters**:

- `dev`: SBUS device handle
- `channels`: Array containing 16 channel values

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `void sbus_set_flags(sbus_dev_t dev, const sbus_flag_t *flags);`

**Function**: Sets the SBUS flag bits.

**Parameters**:

- `dev`: SBUS device handle
- `flags`: Pointer to the flag bits structure

---

### `void sbus_get_flags(sbus_dev_t dev, sbus_flag_t *flags_out);`

**Function**: Gets the current SBUS flag bits.

**Parameters**:

- `dev`: SBUS device handle
- `flags_out`: Pointer to the structure used to store the flag bits

---

### `int sbus_send_frame(sbus_dev_t dev);`

**Function**: Sends an SBUS data frame. Encodes the currently set channel values and flag bits into a 25-byte SBUS frame and sends it via UART.

**Parameters**:

- `dev`: SBUS device handle

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `void sbus_set_debug(sbus_dev_t dev, bool val);`

**Function**: Sets the debug mode. In debug mode, the decoded channel values and flag bits will be printed when sending frames.

**Parameters**:

- `dev`: SBUS device handle
- `val`: `true` to enable debugging, `false` to disable debugging

---

## Usage Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_sbus.c`

**Notes**:

1. Before use, the corresponding UART TX pin needs to be configured through FPIOA.
