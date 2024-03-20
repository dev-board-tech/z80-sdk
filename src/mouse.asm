;-----------------------------------------------------------------------
; Functions:
; mouse_Init
; Required:
; c = SIO config address of mouse
; Altered:
; a
;-----------------------------------------------------------------------
DEFC MOUSE_RESET_TIMEOUT_DELAY = 32767
mouse_Init:
	ld hl, MOUSE_RESET_TIMEOUT_DELAY; timeout
mouse_Init_LoopSndReset:
	xor a
	dec a
	call sio_SendC
;--------- Wait for ACK=0xFA
mouse_Init_LoopForResetRsp:
	dec hl
	bit 7, h
	ret nz; Timed out
	call sio_ReadCNonBlocking
	jr z, mouse_Init_LoopForResetRsp
; Check after 0xFA, response after reset
	cp 0xFA
	jr nz, mouse_Init_LoopSndReset
;--------- Receive BAT=AA
	ld hl, MOUSE_RESET_TIMEOUT_DELAY; timeout
mouse_Init_LoopForAa:
	dec hl
	bit 7, h
	ret nz; Timed out
	call sio_ReadCNonBlocking
	jr z, mouse_Init_LoopForAa
; Check after 0xAA, response after reset
	cp 0xAA
	jr nz, mouse_Init_LoopForAa
;--------- Receive ID=00
	ld hl, MOUSE_RESET_TIMEOUT_DELAY; timeout
mouse_Init_LoopForId:
	dec hl
	bit 7, h
	ret nz; Timed out
	call sio_ReadCNonBlocking
	jr z, mouse_Init_LoopForId
; Check after 0x00, response after reset
	cp 0x00
	jr nz, mouse_Init_ResetError
;--------- Send enable streaming
	ld a, 0xf4
	call sio_SendC
;--------- Wait for ACK=0xFA
	ld hl, MOUSE_RESET_TIMEOUT_DELAY; timeout
mouse_Init_LoopForDataRepEnResponse:
	dec hl
	bit 7, h
	ret nz; Timed out
	call sio_ReadCNonBlocking
	jr z, mouse_Init_LoopForDataRepEnResponse
; Check after 0x00, response after reset
	cp 0xfa
	jr nz, mouse_Init_ResetError
;---------
	set 0, a
	bit 0, a
	ret
mouse_Init_ResetError:
	res 0, a
	bit 0, a
	ret
