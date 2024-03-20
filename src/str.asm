;-----------------------------------------------------------------------
; Functions:
; str_HByteToChar
; str_LByteToChar
; Required:
; a = Character
; b = upper/lower letter -10 it "str_ByteToChar" is call
; Return
; a = Hex char
; Altered:
; b
;-----------------------------------------------------------------------
str_HByteToChar:
	ld b, 'a' - 10
	jr str_HByteToChar_SkipHigher
str_LByteToChar:
	ld b, 'A' - 10
	jr str_HByteToChar_SkipHigher
str_ByteToChar::
str_HByteToChar_SkipHigher:
	cp 16
	jr c, str_ByteToChar_Lower16
	ld a, '?'
	ret
str_ByteToChar_Lower16:
	cp 10
	jr c, str_ByteToCharLower10
	add b
	ret
str_ByteToCharLower10:
	add '0'
	ret
;-----------------------------------------------------------------------
; Functions:
; str_LCharToHex
; str_HCharToHex
; Required:
; a = Character
; Return
; b = Higher hex char
; c = Lower hex char
; Altered:
; a
;-----------------------------------------------------------------------
str_LCharToHex:
	ld b, 'a' - 10
	jr str_HCharToHexSkip
str_HCharToHex:
	ld b, 'A' - 10
str_HCharToHexSkip:
	push de
	ld d, a
	and 0x0F
	call str_ByteToChar
	ld e, a
	ld a, d
	srl a
	srl a
	srl a
	srl a
	call str_ByteToChar
	ld b, a
	ld c, e
	pop de
	ret
;-----------------------------------------------------------------------
; Functions:
; str_Len
; Required:
; hl = Str address
; Return
; bc = Str length
; Altered:
; a, bc
;-----------------------------------------------------------------------
str_Len:
	xor a
	ld b, a
	ld c, a
str_NLen:
	push de
	push hl
	xor a
	ld de, hl
	cpir
	xor a
	sbc hl, de
	ld bc, hl
	pop hl
	pop de
	ret
;-----------------------------------------------------------------------
; Functions:
; str_Cpy
; str_NCpy
; Required:
; bc = max length, in case of str_NCpy
; de = Destination address
; hl = Source address
; Altered:
; a
;-----------------------------------------------------------------------
str_Cpy:
	push bc
	call str_Len
	ret nz
	jr str_NCpy_Skip
str_NCpy:
	push bc
	call str_NLen
str_NCpy_Skip:
	push hl
	ldir
	xor a
	ld (de), a
	pop hl
	pop bc
	ret
	





