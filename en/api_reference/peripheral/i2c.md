# I2C HAL Interface Documentation

## Hardware Introduction

The K230 has a total of 5 I2C channels. The I2C module supports master and slave modes, supports 7/10-bit addressing, supports interrupts, and the I2C module transfer rates support 100k/400k/1M/3.4M.

---

## Data Structure Description

### `drv_i2c_inst_t`

**Description**: I2C master instance structure, containing I2C configuration and status information.

### `i2c_msg_t`

**Description**: I2C message structure.

- `addr`: device address
- `flags`: transfer flags (read/write, 10-bit address, etc.)
- `len`: data length
- `buf`: data buffer pointer

### `drv_i2c_slave_inst_t`

**Description**: I2C slave instance structure.

### I2C Transfer Flags

- `DRV_I2C_WR`: write operation
- `DRV_I2C_RD`: read operation
- `DRV_I2C_ADDR_10BIT`: 10-bit address mode
- `DRV_I2C_NO_START`: do not send start signal
- `DRV_I2C_IGNORE_NACK`: ignore NACK
- `DRV_I2C_NO_READ_ACK`: do not send ACK during read
- `DRV_I2C_NO_STOP`: do not send stop signal

---

## I2C Host Mode Interface

### `int drv_i2c_inst_create(int id, uint32_t freq, uint32_t timeout_ms, uint8_t scl, uint8_t sda, drv_i2c_inst_t** inst);`

**Function**: Create an I2C host instance.

**Parameters**:

- `id`: I2C number, 0-4 for hardware I2C, greater than 4 for software I2C
- `freq`: I2C clock frequency (Hz)
- `timeout_ms`: Timeout duration (milliseconds)
- `scl`: SCL pin number (valid for software I2C, must be less than 64)
- `sda`: SDA pin number (valid for software I2C, must be less than 64)
- `inst`: Pointer used to store the created I2C instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `void drv_i2c_inst_destroy(drv_i2c_inst_t** inst);`

**Function**: Destroy the I2C host instance and release resources.

**Parameters**:

- `inst`: Pointer to the I2C instance pointer

---

### `int drv_i2c_set_7b_addr(drv_i2c_inst_t* inst);`

**Function**: Set I2C to 7-bit address mode.

**Parameters**:

- `inst`: I2C instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_i2c_set_10b_addr(drv_i2c_inst_t* inst);`

**Function**: Set I2C to 10-bit address mode.

**Parameters**:

- `inst`: I2C instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_i2c_set_freq(drv_i2c_inst_t* inst, uint32_t freq);`

**Function**: Set the I2C clock frequency.

**Parameters**:

- `inst`: I2C instance pointer
- `freq`: Clock frequency (Hz)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_i2c_set_timeout(drv_i2c_inst_t* inst, uint32_t timeout_ms);`

**Function**: Set the I2C timeout duration.

**Parameters**:

- `inst`: I2C instance pointer
- `timeout_ms`: Timeout duration (milliseconds)

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### `int drv_i2c_transfer(drv_i2c_inst_t* inst, i2c_msg_t* msgs, int msg_cnt);`

**Function**: Perform an I2C transfer operation.

**Parameters**:

- `inst`: I2C instance pointer
- `msgs`: Message array
- `msg_cnt`: Number of messages

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### I2C Host Attribute Getter Functions

The following functions are used to retrieve various attributes of the I2C host instance:

- `uint32_t drv_i2c_master_get_type(drv_i2c_inst_t* inst);` - Get the I2C type (hardware/software)
- `int drv_i2c_master_get_id(drv_i2c_inst_t* inst);` - Get the I2C number
- `int drv_i2c_master_get_fd(drv_i2c_inst_t* inst);` - Get the file descriptor
- `uint32_t drv_i2c_master_get_freq(drv_i2c_inst_t* inst);` - Get the clock frequency
- `uint32_t drv_i2c_master_get_timeout_ms(drv_i2c_inst_t* inst);` - Get the timeout duration
- `uint8_t drv_i2c_master_get_pin_scl(drv_i2c_inst_t* inst);` - Get the SCL pin number
- `uint8_t drv_i2c_master_get_pin_sda(drv_i2c_inst_t* inst);` - Get the SDA pin number

---

## I2C Slave Mode Interface

### `int drv_i2c_slave_inst_create(int id, uint32_t buffer_size, uint16_t slave_address, uint8_t scl, uint8_t sda, drv_i2c_slave_inst_t** inst);`

**Function**: Creates an I2C slave instance.

**Parameters**:

- `id`: I2C number
- `buffer_size`: Buffer size
- `slave_address`: Slave address
- `scl`: SCL pin number
- `sda`: SDA pin number
- `inst`: Used to store the created slave instance pointer

**Return Value**:

- `0`: Success
- `-1`: Failure

---

### I2C Slave Attribute Getter Functions

- `int drv_i2c_slave_get_id(drv_i2c_slave_inst_t* inst);` - Get I2C number
- `int drv_i2c_slave_get_fd(drv_i2c_slave_inst_t* inst);` - Get file descriptor
- `uint8_t drv_i2c_slave_get_pin_scl(drv_i2c_slave_inst_t* inst);` - Get SCL pin number
- `uint8_t drv_i2c_slave_get_pin_sda(drv_i2c_slave_inst_t* inst);` - Get SDA pin number
- `uint32_t drv_i2c_slave_get_buffer_size(drv_i2c_slave_inst_t* inst);` - Get buffer size
- `uint16_t drv_i2c_slave_get_slave_address(drv_i2c_slave_inst_t* inst);` - Get slave address

---

## Usage Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_i2c_ssd1306.c`

**Notes**:

1. Before using hardware I2C, the corresponding pin functions need to be configured through FPIOA
