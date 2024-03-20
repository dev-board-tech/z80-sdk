IFNDEF MMU_H
DEFINE MMU_H

INCLUDE "board_h.asm"

EXTERN BOARD_IO_CFG_REG_BACK

; Size of the RAM in bytes
DEFC MMU_ROM_ADDR = 0
DEFC MMU_ROM_SIZE = 512 * 1024
; Size of the RAM in bytes
DEFC MMU_RAM_ADDR = MMU_ROM_ADDR + MMU_ROM_SIZE
DEFC MMU_RAM_SIZE = 512 * 1024
; Page size
DEFC MMU_PAGE_SIZE = 16384
DEFC MMU_PAGE_BANK_SHIFT = 14

; ROM physical address start
DEFC ROM_PHYSICAL_ADDR_START = 0
; RAM physical address start
DEFC RAM_PHYSICAL_ADDR_START = MMU_ROM_SIZE

MACRO MMU_INIT _
	ld a, MMU_ROM_ADDR ; Map address 0 of the ROM to page 0 in MMU
	out (IO_MMU_BANK_0), a
	ld a, MMU_RAM_ADDR >> 14 ; Map address 0 of the RAM to page 1 in MMU
	out (IO_MMU_BANK_1), a
	ld a, MMU_RAM_ADDR >> 14
	out (IO_MMU_BANK_2), a ; DUMMY
	ld a, MMU_RAM_ADDR >> 14
	out (IO_MMU_BANK_3), a ; DUMMY
ENDM

MACRO MMU_ENABLE _
	sub a
	inc a
	out (IO_MMU_REG), a
ENDM

MACRO MMU_DISABLE _
	sub a
	out (IO_MMU_REG), a
ENDM

MACRO MMU_SET_ADDR phyAddr, bank
	ld a, phyAddr >> 14
	out (bank), a
ENDM


ENDIF
