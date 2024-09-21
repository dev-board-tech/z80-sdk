IFNDEF DELAY_H
DEFINE DELAY_H

MACRO DELAYMS ms
	push af
	push bc
	push de
	ld bc, ms & 0xFFFF
	ld de, (ms >> 16) & 0xFFFF
	call delayMs
	pop de
	pop bc
	pop af
ENDM

ENDIF
