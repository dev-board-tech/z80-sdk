INCLUDE "boot_h.asm"
INCLUDE "delay_h.asm"
;-----------------------------------------------------------------------
; Required:
; bc de = delay in ms
; Altered:
; a
;-----------------------------------------------------------------------
delayMs:
	inc b
	inc c
	inc d
	inc e
delay_Loop1:
	push bc
	ld bc, (CORE_CLK / (1000 * 8)) + 1
	ld a, b
	ld b, c
	ld c, a
delay_Loop0:
	djnz delay_Loop0
	dec c
	jp nz, delay_Loop0
	pop bc
	dec c
	jp nz, delay_Loop1
	dec b
	jp nz, delay_Loop1
	dec e
	jp nz, delay_Loop1
	dec d
	jp nz, delay_Loop1
	ret
