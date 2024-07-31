IFNDEF DISK_H
DEFINE DISK_H

INCLUDE "util_h.asm"

;Bytes are arranged as MSB

DEFC DISK_INIT_FUNC = 0
DEFC DISK_IOCTL_FUNC = 2
DEFC DISK_READ_FUNC = 4
DEFC DISK_WRITE_FUNC = 6

DEFC DISK_ADDRESS = 8
DEFC DISK_ADDRESS_B3 = DISK_ADDRESS + 0
DEFC DISK_ADDRESS_B2 = DISK_ADDRESS + 1
DEFC DISK_ADDRESS_B1 = DISK_ADDRESS + 2
DEFC DISK_ADDRESS_B0 = DISK_ADDRESS + 3

DEFC DISK_BUFF_ADDR = 12
DEFC DISK_BUFF_ADDR_B1 = DISK_BUFF_ADDR + 0
DEFC DISK_BUFF_ADDR_B0 = DISK_BUFF_ADDR + 1

DEFC DISK_BLOCKS = 14

DEFC DISK_IOCTL_CMD = 15

DEFC DISK_ERR = 16

DEFC DISK_PARAM_LEN = DISK_ERR + 1

;Expects ix to have the param address
MACRO DISK_INIT initFunc
	ld hl, initFunc
	icall(hl)
ENDM

MACRO DISK_INIT_P paramPtr, initFunc
	ld ix, paramPtr
	ld hl, initFunc
	icall(hl)
ENDM

;Expects ix to have the param address
MACRO DISK_IOCTL _
	ld h, (ix + DISK_IOCTL_FUNC + 0)
	ld l, (ix + DISK_IOCTL_FUNC + 1)
	icall(hl)
ENDM

MACRO DISK_IOCTL_P paramPtr
	ld ix, paramPtr
	ld h, (ix + DISK_IOCTL_FUNC + 0)
	ld l, (ix + DISK_IOCTL_FUNC + 1)
	icall(hl)
ENDM

;Expects ix to have the param address
MACRO DISK_READ _
	ld h, (ix + DISK_READ_FUNC + 0)
	ld l, (ix + DISK_READ_FUNC + 1)
	icall(hl)
ENDM

MACRO DISK_READ_P paramPtr
	ld ix, paramPtr
	ld h, (ix + DISK_READ_FUNC + 0)
	ld l, (ix + DISK_READ_FUNC + 1)
	icall(hl)
ENDM

;Expects ix to have the param address
MACRO DISK_WRITE _
	ld h, (ix + DISK_WRITE_FUNC + 0)
	ld l, (ix + DISK_WRITE_FUNC + 1)
	icall(hl)
ENDM

MACRO DISK_WRITE_P paramPtr
	ld ix, paramPtr
	ld h, (ix + DISK_WRITE_FUNC + 0)
	ld l, (ix + DISK_WRITE_FUNC + 1)
	icall(hl)
ENDM

;Expects ix to have the param address
MACRO DISK_WRITE_CONST_ADDR addr
	ld (ix + DISK_ADDRESS + 3), 0xFF & addr
	ld (ix + DISK_ADDRESS + 2), 0xFF & (addr >> 8)
	ld (ix + DISK_ADDRESS + 1), 0xFF & (addr >> 16)
	ld (ix + DISK_ADDRESS + 0), 0xFF & (addr >> 24)
ENDM

MACRO DISK_WRITE_CONST_ADDR_P paramPtr, addr
	ld ix, paramPtr
	ld (ix + DISK_ADDRESS + 3), 0xFF & addr
	ld (ix + DISK_ADDRESS + 2), 0xFF & (addr >> 8)
	ld (ix + DISK_ADDRESS + 1), 0xFF & (addr >> 16)
	ld (ix + DISK_ADDRESS + 0), 0xFF & (addr >> 24)
ENDM

;Expects ix to have the param address
MACRO DISK_WRITE_CONST_BUFF buffAddr
	ld (ix + DISK_BUFF_ADDR + 1), 0xFF & buffAddr
	ld (ix + DISK_BUFF_ADDR + 0), 0xFF & (buffAddr >> 8)
ENDM

MACRO DISK_WRITE_CONST_BUFF_P paramPtr, buffAddr
	ld ix, paramPtr
	ld (ix + DISK_BUFF_ADDR + 1), 0xFF & buffAddr
	ld (ix + DISK_BUFF_ADDR + 0), 0xFF & (buffAddr >> 8)
ENDM

;Expects ix to have the param address
MACRO DISK_WRITE_CONST_BLOCKS blocksNr
	ld (ix + DISK_BLOCKS), blocksNr
ENDM

MACRO DISK_WRITE_CONST_BLOCKS_P paramPtr, blocksNr
	ld ix, paramPtr
	ld (ix + DISK_BLOCKS), blocksNr
ENDM

ENDIF
