; HL = Destination
; H = Multiply
; A = multiplier

mul8b: ; this routine performs the operation HL=H*E
	push bc
	push de
	ld d, 0 ; clearing D and L
	ld l, d
	ld b, 8 ; we have 8 bits
mul8b_Mul8bLoop:
	add hl, hl ; advancing a bit
	jp nc, mul8b_Mul8bSkip ; if zero, we skip the addition (jp is used for speed)
	add hl, de ; adding to the product if necessary
mul8b_Mul8bSkip:
	djnz mul8b_Mul8bLoop
	pop de
	pop bc
	ret

; HL = Destination
; DE = Multiply
; A = multiplier

mul16_8: ; this routine performs the operation HL=DE*A
	push bc
	push de
	ld hl, 0 ; HL is used to accumulate the result
	ld b, 8 ; the multiplier (A) is 8 bits wide
mul16_8_Mul8Loop:
	rrca ; putting the next bit into the carry
	jp nc, mul16_8_Mul8Skip ; if zero, we skip the addition (jp is used for speed)
	add hl, de ; adding to the product if necessary
mul16_8_Mul8Skip:
	sla e ; calculating the next auxiliary product by shifting
	rl d ; DE one bit leftwards (refer to the shift instructions!)
	djnz mul16_8_Mul8Loop
	pop de
	pop bc
	ret
