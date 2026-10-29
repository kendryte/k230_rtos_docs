# SPI HAL Interface Documentation

## Hardware Introduction

The K230 integrates 3 SPI controllers (SPI0~SPI2), supporting master mode. It supports standard SPI modes (MODE0~MODE3), with configurable data width of 4-32 bits. It supports single-line, dual-line, quad-line, and octal-line (SPI0 only) transfer modes. It supports QSPI extended functions, including configuration of instruction, address, dummy cycles, and other phases.

---

## Data Structure Description

### SPI Mode Definitions

- `SPI_HAL_MODE_0`：CPOL = 0, CPHA = 0
- `SPI_HAL_MODE_1`：CPOL = 0, CPHA = 1
- `SPI_HAL_MODE_2`：CPOL = 1, CPHA = 0
- `SPI_HAL_MODE_3`：CPOL = 1, CPHA = 1

### Data Line Configuration

- `SPI_HAL_DATA_LINE_1`：Single-line SPI
- `SPI_HAL_DATA_LINE_2`：Dual-line SPI
- `SPI_HAL_DATA_LINE_4`：Quad-line QSPI
- `SPI_HAL_DATA_LINE_8`：Octal-line SPI (SPI0 only supported)

### `drv_spi_inst_t`

**Description**：SPI instance handle type.

### `rt_spi_message`

**Description**：SPI message structure.

- `send_buf`：Send data buffer
- `recv_buf`：Receive data buffer
- `length`：Data length
- `next`：Next message (linked list)
- `cs_take`：Whether to pull chip select low
- `cs_release`：Whether to release chip select

### `rt_qspi_message`

**Description**：QSPI extended message structure, inherited from `rt_spi_message`.

- `instruction`：Instruction phase configuration
- `address`：Address phase configuration
- `alternate_bytes`：Alternate bytes phase configuration
- `dummy_cycles`：Number of dummy cycles
- `qspi_data_lines`：Number of data lines used in data phase

---

## Function Interface Description

### `int drv_spi_inst_create(int spi_id, bool active_low, int mode, uint32_t baudrate, uint8_t data_bits, int cs_pin, uint8_t data_line, drv_spi_inst_t *inst);`

**Function**: Create an SPI instance.

**Parameters**:

- `spi_id`: SPI controller number, range `[0, 2]`
- `active_low`: Chip select signal polarity, `true` for active low, `false` for active high
- `mode`: SPI mode (`SPI_HAL_MODE_0` ~ `SPI_HAL_MODE_3`)
- `baudrate`: Clock frequency (Hz)
- `data_bits`: Data bit width, range `[4, 32]`
- `cs_pin`: Chip select pin number, range `[0, 63]`, `-1` indicates chip select is controlled externally
- `data_line`: Number of data lines (1/2/4/8)
- `inst`: Used to store the created SPI instance pointer

**Return Value**:

- `0`: Success
- `Negative value`: Failure

---

### `void drv_spi_inst_destroy(drv_spi_inst_t *inst);`

**Function**: Destroy SPI instance and release resources.

**Parameters**:

- `inst`: Pointer to SPI instance pointer

---

### `int drv_spi_transfer(drv_spi_inst_t inst, const void *tx_data, void *rx_data, size_t len, bool cs_change);`

**Function**: Full-duplex SPI transfer.

**Parameters**:

- `inst`: SPI instance
- `tx_data`: Transmit data buffer, `NULL` indicates read-only
- `rx_data`: Receive data buffer, `NULL` indicates write-only
- `len`: Data length (bytes)
- `cs_change`: `true` indicates release chip select after transfer, `false` indicates keep chip select

**Return Value**:

- `Positive value`: Number of bytes actually transferred
- `Negative value`: Failure

---

### `int drv_spi_read(drv_spi_inst_t inst, void *rx_data, size_t len, bool cs_change);`

**Function**: SPI read operation.

**Parameters**:

- `inst`: SPI instance
- `rx_data`: Receive data buffer
- `len`: Read length (bytes)
- `cs_change`: `true` indicates release chip select after transfer, `false` indicates keep chip select

**Return Value**:

- `Positive value`: Number of bytes actually read
- `Negative value`: Failure

---

### `int drv_spi_write(drv_spi_inst_t inst, const void *tx_data, size_t len, bool cs_change);`

**Function**: SPI write operation.

**Parameters**:

- `inst`: SPI instance
- `tx_data`: Transmit data buffer
- `len`: Write length (bytes)
- `cs_change`: `true` indicates release chip select after transfer, `false` indicates keep chip select

**Return Value**:

- `Positive value`: Number of bytes actually written
- `Negative value`: Failure

---

### `int drv_spi_transfer_message(drv_spi_inst_t inst, struct rt_qspi_message *msg);`

**Function**: Advanced QSPI transfer, supports configuration of instruction, address, dummy cycles, etc.

**Parameters**:

- `inst`: SPI instance
- `msg`: QSPI message structure

**Return Value**:

- `Positive value`: Number of bytes actually transferred
- `Negative value`: Failure

---

## Usage Example

Please refer to `src/rtsmart/libs/testcases/rtsmart_hal/test_spi_st7789.c` and `src/rtsmart/libs/testcases/rtsmart_hal/test_spi_wq128.c`

**Notes**:

1. Before using SPI, the corresponding pin functions (CLK, MOSI, MISO, etc.) need to be configured through FPIOA.
1. 8-line mode is only supported by SPI0.
1. When the chip select pin is set to -1, the chip select signal needs to be controlled externally, and the `cs_change` parameter will not take effect.
1. drv_spi_transfer_message supports hardware chip select, other hal interfaces only support software chip select.
