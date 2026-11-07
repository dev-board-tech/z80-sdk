; a = Nr of elements
;ix = Base address of the array

sortByteArray:
	push af
	push bc
	push de
	push iy
	ld c, a
	//ld c,NumberOfElements
	dec c ; Note that the first step involves N-1 checks
	ld hl, 1 ; Setting H=0 and L=1, for optimising speed
sortByteArray_Step:
	;ld iy,ArrayAddress
	ld iy, ix
	ld e, h ; Bit 0 of E will indicate if there was need to swap
	ld b, c ; C holds the number of elements in the current step
sortByteArray_Loop:
	ld a, (iy)
	ld d, (iy+1)
	cp d ; If A was less than D, the carry will be set
	jr c, sortByteArray_Continue
	ld (iy), d ; Swapping order is actually performed by simply writing
	ld (iy+1), a ; the values back in a reversed order
	ld e, l ; Swapping is indicated here (L=1)
sortByteArray_Continue:
	inc iy
	djnz sortByteArray_Loop
	dec e
	jr nz, sortByteArray_Finish ; If E became zero after DEC, we have to continue
	dec c
	jr nz, sortByteArray_Step
sortByteArray_Finish:
	pop iy
	pop de
	pop bc
	pop af
	ret
