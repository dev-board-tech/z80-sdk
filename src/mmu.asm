INCLUDE "mmu_h.asm"

SECTION KERNEL_BSS
BOARD_IO_MMU_BANK_REG_BACK: 
DEFS 4
SECTION KERNEL_IO

;-----------------------------------------------------------------------
; Result:
; h = minor
; l = major
;-----------------------------------------------------------------------
mmu_version:
	ld hl, 0x0001
	ret
;-----------------------------------------------------------------------
; Required:
; b,c = Memory physical address low word
; d = Memory physical address high byte
; Result:
; c = result, Memory bank physical number
;-----------------------------------------------------------------------
mmu_AddrToBank:
	sla c
	rl d
	sla c
	rl d
	ld c, d
	ret
;-----------------------------------------------------------------------
; Required:
; a = Memory physical bank address
; Result
; b,c = physical address low word
; d = physical address high byte
;-----------------------------------------------------------------------
mmu_BankToAddr:
	ld d, a
	sub a
	ld b, a
	ld c, a
	srl d
	rr c
	srl d
	rl c
	ret
;-----------------------------------------------------------------------
; Required:
; b = physical bank address, one bank = 16KB
; c = MMU Bank
; Altered:
; a
;-----------------------------------------------------------------------
mmu_Set:
	push bc
	push hl
	ld a, c
	and 0x03
	add IO_MMU_BANK_0
	ld c, a
	out (c), b
	ld hl, BOARD_IO_MMU_BANK_REG_BACK
	sub IO_MMU_BANK_0
	ld c, a
	ld a, b
	ld b, c
	ld c, 0
	add hl, bc
	ld (hl), a
	pop hl
	pop bc
	ret
	
;-----------------------------------------------------------------------
; Required:
; c = MMU bank
; Result:
; a = physical bank address, one bank = 16KB
;-----------------------------------------------------------------------
mmu_Get:
	push bc
	push hl
	ld a, c
	and 0x03
	ld hl, BOARD_IO_MMU_BANK_REG_BACK
	ld b, a
	ld c, 0
	add hl, bc
	ld a, (hl)
	pop hl
	pop bc
	ret
