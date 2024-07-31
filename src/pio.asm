INCLUDE "pio_h.asm"

SECTION KERNEL_BSS

PIOA_IO_MODE:
DEFS 1	; holds current PIOA mode
PIOA_IO_DIR:
DEFS 1	; holds current PIOA direction configuration
PIOA_IO_OUT:
DEFS 1	; holds current PIOA output configuration

PIOB_IO_MODE:
DEFS 1	; holds current PIOA mode
PIOB_IO_DIR:
DEFS 1	; holds current PIOA direction configuration
PIOB_IO_OUT:
DEFS 1	; holds current PIOA output configuration

SECTION KERNEL_PIO

;-----------------------------------------------------------------------
; Functions:
; pio_version
; Result:
; h = minor
; l = major
;-----------------------------------------------------------------------
pio_version:
	ld hl, 0x0001
	ret
;-----------------------------------------------------------------------
; Functions:
; pio_Init
; Required:
; c = PIO base address
; b = unit
; Altered:
; a
;-----------------------------------------------------------------------
pio_Init:
	ld a, 0xcf
	ld(ix + PIO_IO_MODE), a
	inc c
	out (c), a
	xor a
	dec a
	ld(ix + PIO_IO_DIR), a
	out (c), a
	dec c
	xor a
	ld(ix + PIO_IO_OUT), a
	out (c), a
	ret

;-----------------------------------------------------------------------
; Functions:
; pio_GetAddr
; Required:
; c = PIO base address
; b = unit
; Return
; c = IO address for data, c + 2 is for config
; ix = base address of holding registers
; Altered:
; a
;-----------------------------------------------------------------------
pio_GetAddr:
	ld a, b
	and a, 0x01
	add c
	ld c, a
	ret
;-----------------------------------------------------------------------
; Functions:
; pio_GetAddrCfg
; Required:
; c = PIO base address
; b = unit
; Return
; c = IO address for data, c + 2 is for config
; Altered:
; a
;-----------------------------------------------------------------------
pio_GetAddrCfg:
	ld a, b
	and a, 0x01
	sla a
	add c
	ld c, a
	ret


