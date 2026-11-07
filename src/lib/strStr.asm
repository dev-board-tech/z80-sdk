; hl = Text address
; de = String address
; bc = String length

strStr:
	;ld hl, (TextAddress)
	;ld de, (StringAddress)
	;ld bc, (StringLength)
	push af
	push bc
	push de
	push hl
strStr_Repeat: ; This loop verifies if the text from the current byte
	ld a, (de) ; matches the string given, character by character. If
	cp (hl) ; it does, then the zero flag is set. Execution is
	jr nz, strStr_EndRepeat ; continued from EndRepeat, regardless of the success of
	inc hl ; the search.
	inc de
	dec bc
	ld a, b
	or c
	jr nz, strStr_Repeat
strStr_EndRepeat:
	ld hl, (TextAddress) ; Note that LD preserves the flags
	jr z, strStr_Finish
	inc hl ; The text pointer is advanced
	ld (TextAddress), hl
	ld bc, (TextLength)
	dec bc ; Total byte count is decreased
	ld (TextLength), bc
	ld a, b
	or c
	jr nz, Start
	ld hl, 0 ; This part is executed in case of failure (BC=0)
strStr_Finish:
	pop hl
	pop de
	pop bc
	pop af
	ret
