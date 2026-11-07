;ix = base address
;ix + 0 = source1
;ix + a = source2
;ix + a + a = destination
addBigNr:
	push af
	push ix
	mov b, a
	;ld ix,$1000 ; Pointer to the first number
	;ld b, 16 ; The number of bytes in each number
	or a ; A dummy logical instruction, used to clear the carry
addBigNr_Repeat: ; Adds 8 bits on each iteration
	ld a, (ix)
	adc a, (ix+$10) ; Add with carry (the 9th bit of the previous addition)
	ld (ix+$20), a ; Storing the current byte of the result
	inc ix
	djnz addBigNr_Repeat
	pop ix
	pop af
	ret
	
