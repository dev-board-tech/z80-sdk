;-----------------------------------------------------------------------
; Required
; d = 
; e = 
; Return
; hl
; Altered
; a, b
;-----------------------------------------------------------------------
Multiply:			; this routine performs the operation HL=D*E
	ld hl,0			; HL is used to accumulate the result
	ld a,d			; checking one of the factors; returning if it is zero
	or a
	ret z
	ld b,d			; one factor is in B
	ld d,h			; clearing D (H is zero), so DE holds the other factor
MulLoop:			; adding DE to HL exactly B times
	add hl,de
	djnz MulLoop
	ret

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
Divide:				; this routine performs the operation BC=HL/E
	ld a,e			; checking the divisor; returning if it is zero
	or a			; from this time on the carry is cleared
	ret z
	ld bc,-1		; BC is used to accumulate the result
	ld d,0			; clearing D, so DE holds the divisor
DivLoop:			; subtracting DE from HL until the first overflow
	sbc hl,de		; since the carry is zero, SBC works as if it was a SUB
	inc bc			; note that this instruction does not alter the flags
	jr nc,DivLoop		; no carry means that there was no overflow
	ret

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
Mul8:				; this routine performs the operation HL=DE*A
	ld hl,0			; HL is used to accumulate the result
	ld b,8			; the multiplier (A) is 8 bits wide
Mul8Loop:
	rrca			; putting the next bit into the carry
	jp nc,Mul8Skip		; if zero, we skip the addition (jp is used for speed)
	add hl,de		; adding to the product if necessary
Mul8Skip:
	sla e			; calculating the next auxiliary product by shifting
	rl d			; DE one bit leftwards (refer to the shift instructions!)
	djnz Mul8Loop
	ret

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
Mul8b:				; this routine performs the operation HL=H*E
	ld d,0			; clearing D and L
	ld l,d
	ld b,8			; we have 8 bits
Mul8bLoop:
	add hl,hl		; advancing a bit
	jp nc,Mul8bSkip		; if zero, we skip the addition (jp is used for speed)
	add hl,de		; adding to the product if necessary
Mul8bSkip:
	djnz Mul8bLoop
	ret

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
Div8:				; this routine performs the operation HL=HL/D
	xor a			; clearing the upper 8 bits of AHL
	ld b,16			; the length of the dividend (16 bits)
Div8Loop:
	add hl,hl		; advancing a bit
	rla
	cp d			; checking if the divisor divides the digits chosen (in A)
	jp c,Div8NextBit	; if not, advancing without subtraction
	sub d			; subtracting the divisor
	inc l			; and setting the next digit of the quotient
Div8NextBit:
	djnz Div8Loop
	ret

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
Mul16:				; This routine performs the operation DEHL=BC*DE
	ld hl,0
	ld a,16
Mul16Loop:
	add hl,hl
	rl e
	rl d
jp nc,NoMul16
	add hl,bc
	jp nc,NoMul16
	inc de			; This instruction (with the jump) is like an "ADC DE,0"
NoMul16:
	dec a
	jp nz,Mul16Loop
	ret


