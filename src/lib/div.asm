div16_8: ; this routine performs the operation HL=HL/D
	xor a ; clearing the upper 8 bits of AHL
	ld b, 16 ; the length of the dividend (16 bits)
div16_8_Div8Loop:
	add hl, hl ; advancing a bit
	rla
	cp d ; checking if the divisor divides the digits chosen (in A)
	jp c, div16_8_Div8NextBit ; if not, advancing without subtraction
	sub d ; subtracting the divisor
	inc l ; and setting the next digit of the quotient
div16_8_Div8NextBit:
	djnz div16_8_Div8Loop
	ret


mul16: ; This routine performs the operation DEHL=BC*DE
	ld hl,0
	ld a,16
mul16_Mul16Loop:
	add hl,hl
	rl e
	rl d
	jp nc,mul16_NoMul16
	add hl,bc
	jp nc,mul16_NoMul16
	inc de ; This instruction (with the jump) is like an "ADC DE,0"
mul16_NoMul16:
	dec a
	jp nz,mul16_Mul16Loop
	ret
