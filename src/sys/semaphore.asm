SECTION KERNEL_UTIL
;-----------------------------------------------------------------------
; Result:
; h = minor
; l = major
;-----------------------------------------------------------------------
semaphore_version:
	ld hl, 0x0001
	ret
;-----------------------------------------------------------------------
; Required:
; hl = address
; b = bit number
; Altered:
; a
;-----------------------------------------------------------------------
semaphore_Wait:
	push bc
	call util_BitToMask8
	ld b, a
semaphore_Wait_Loop:
	ld a, b
	and (hl)
	cp 0
	jr nz, semaphore_Wait_Loop
	ld a, b
	or (hl)
	ld (hl), a
	pop bc
	ret
;-----------------------------------------------------------------------
; Required:
; hl = address
; b = bit mask
; Return:
; a = if bit 0 is 1 the semaphore is busy
; Altered:
; a, b
;-----------------------------------------------------------------------
semaphore_Get:
	call util_BitToMask8
	and (hl)
	cp 0
	jr z, semaphore_Get_NotBusy
	set 0, a
	ret
semaphore_Get_NotBusy:
	res 0, a
	ret

;-----------------------------------------------------------------------
; Required:
; hl = address
; b = bit nr
; Altered:
; a, b
;-----------------------------------------------------------------------
semaphore_Set:
	call util_BitToMask8
	or (hl)
	ld (hl), a
	ret
;-----------------------------------------------------------------------
; Required:
; hl = address
; b = bit nr
; Altered:
; a, b
;-----------------------------------------------------------------------
semaphore_Clr:
	call util_BitToMask8
	cpl
	and (hl)
	ld (hl), a
	ret


	
