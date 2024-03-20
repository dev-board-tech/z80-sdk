SECTION KERNEL_RJMP
;-----------------------------------------------------------------------
; Result:
; h = minor
; l = major
;-----------------------------------------------------------------------
util_version:
	ld hl, 0x0001
	ret
;-----------------------------------------------------------------------
; Required:
; de = offset
; Altered:
; iy
;-----------------------------------------------------------------------
;de = offset address
util_rcall:
	pop iy ; get the pc content
	push iy
	add iy, de
	jp (iy)
	ret
	
SECTION KERNEL_UTIL
;-----------------------------------------------------------------------
; Required:
; b = bit number
; Return:
; a = mask
; Altered:
; a
;-----------------------------------------------------------------------
util_BitToMask8:
	sub a
	inc a
	jr util_BitToMask8_Skip
util_BitToMask8_NonZero:
	sla a
util_BitToMask8_Skip:
	djnz util_BitToMask8_NonZero
	ret
	

