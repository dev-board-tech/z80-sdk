IFNDEF PIO_H
DEFINE PIO_H

DEFC PIO_BASE_ADDR=0xB8
DEFC PIOA = 0
DEFC PIOB = 1
DEFC PIOA_ADDR = 0
DEFC PIOB_ADDR = 1
DEFC PIO_DAT_ADDR = 0
DEFC PIO_CMD_ADDR = 2
DEFC PIOA_D = PIO_BASE_ADDR + PIOA_ADDR + PIO_DAT_ADDR
DEFC PIOA_C = PIO_BASE_ADDR + PIOA_ADDR + PIO_CMD_ADDR
DEFC PIOB_D = PIO_BASE_ADDR + PIOB_ADDR + PIO_DAT_ADDR
DEFC PIOB_C = PIO_BASE_ADDR + PIOB_ADDR + PIO_CMD_ADDR

DEFC PIO_IO_MODE = 0
DEFC PIO_IO_DIR = 1
DEFC PIO_IO_OUT = 2

; _bp = bit position
; _gp = group position
; _gm = group mask
; _m = mode
; _bm = bit mask


MACRO PIO_INIT pioBaseAddr, unitNr, dataAddress, configAddress, regs
	ld b, unitNr
	ld c, pioBaseAddr
	call pio_GetAddr
	ld a, c
	ld (dataAddress), a
	ld ix, regs
	call pio_Init
	ld c, pioBaseAddr
	call pio_GetAddrCfg
	ld a, c
	ld (configAddress), a
ENDM

; cAddr = config addressaddress pointer in memory
MACRO PIO_SET_AS_INPUT_ADDR mask, cAddr, regs
	ld c, (cAddr)
	ld ix, regs
	ld a, (ix + PIO_IO_MODE)
	out (c), a
	ld a, mask
	or (ix + PIO_IO_DIR)
	ld (ix + PIO_IO_DIR), a
	out (c), a
ENDM

; cAddr = config addressaddress pointer in memory
MACRO PIO_SET_AS_OUTPUT_ADDR mask, cAddr, regs
	ld c, (cAddr)
	ld ix, regs
	ld a, (ix + PIO_IO_MODE)
	out (c), a
	ld a, mask
	cpl
	and (ix + PIO_IO_DIR)
	ld (ix + PIO_IO_DIR), a
	out (c), a
ENDM

; cAddr = config addressaddress pointer in memory
MACRO PIO_SET_AS_INPUT mask
	ld a, (ix + PIO_IO_MODE)
	out (c), a
	ld a, mask
	or (ix + PIO_IO_DIR)
	ld (ix + PIO_IO_DIR), a
	out (c), a
ENDM

; cAddr = config addressaddress pointer in memory
MACRO PIO_SET_AS_OUTPUT mask
	ld a, (ix + PIO_IO_MODE)
	out (c), a
	ld a, mask
	cpl
	and (ix + PIO_IO_DIR)
	ld (ix + PIO_IO_DIR), a
	out (c), a
ENDM

; cAddr = data addressaddress pointer in memory
MACRO PIO_SET_OUT_ADDR mask, dAddr, regs
	ld c, (dAddr)
	ld ix, regs
	ld a, mask
	or (ix + PIO_IO_OUT)
	ld (ix + PIO_IO_OUT), a
	out (c), a
ENDM

; cAddr = data addressaddress pointer in memory
MACRO PIO_CLR_OUT_ADDR mask, dAddr, regs
	ld c, (dAddr)
	ld ix, ixAddr
	ld a, mask
	cpl
	and (ix + PIO_IO_OUT)
	ld (ix + PIO_IO_OUT), a
	out (c), a
ENDM

; cAddr = data addressaddress pointer in memory
MACRO PIO_SET_OUT mask
	ld a, mask
	or (ix + PIO_IO_OUT)
	ld (ix + PIO_IO_OUT), a
	out (c), a
ENDM

; cAddr = data addressaddress pointer in memory
MACRO PIO_CLR_OUT mask
	ld a, mask
	cpl
	and (ix + PIO_IO_OUT)
	ld (ix + PIO_IO_OUT), a
	out (c), a
ENDM

ENDIF
