INCLUDE "sio_h.asm"
SECTION KERNEL_BSS
BOARD_IO_SIO_SEMAPHORE: 
DEFS 1
SECTION KERNEL_IO

;-----------------------------------------------------------------------
; Functions:
; sio_version
; Result:
; h = minor
; l = major
;-----------------------------------------------------------------------
sio_version:
	ld hl, 0x0001
	ret
;-----------------------------------------------------------------------
; Functions:
; sio_Init
; Altered:
; a
;-----------------------------------------------------------------------
sio_Init:
	xor a
	ld (BOARD_IO_SIO_SEMAPHORE), a
	ret

;-----------------------------------------------------------------------
; Functions:
; sio_GetAddr
; Required:
; c = SIO config address
; Return
; c = address
; Altered:
; a, c
;-----------------------------------------------------------------------
sio_GetAddr:
	ld a, b
	and 0x01; Each SIO IC has two units
	add SIO_CMD_ADDR
	add c
	ld c, a
	ret
	
;-----------------------------------------------------------------------
; Functions:
; sio_Set
; Required:
; c = SIO config address
; d = Clk divider
; e = Rx char size
; h = Tx char size
; Altered:
; a
;-----------------------------------------------------------------------
sio_Set:
	push hl
	push bc
	push hl
	ld hl, BOARD_IO_SIO_SEMAPHORE
	call semaphore_Wait
	pop hl
SIO_RESET:
	;set up TX and RX:
	ld a, SIO_REG0_CMD_ERROR_RESET_m | SIO_REG0 ;write into WR0: error reset, select WR0
	out (c), a
	ld a, SIO_REG0_CMD_CHANNEL_RESET_m | SIO_REG0 ;write into WR0: channel reset
	out (c), a
SIO_SET_CLK_DIV_STOP_PARITY:
	ld a,SIO_REG4 ;write into WR0: select WR4
	out (c), a
	xor a
	or SIO_DEG4_STOP_MODE_1_STOP_BIT_m
	or d; Set clock divider
	; ld a,44h ;44h write into WR4: clkx16,1 stop bit, no parity
	out (c), a
SIO_CHAR_LEN_TX_EN_RTS:
	ld a,SIO_REG5 ;write into WR0: select WR5
	out (c), a
	xor a
	ld b, a
	ld a, h; Set TX char size
	and 0b01100000
	or b
	or SIO_DEG5_TX_ENABLE_bm | SIO_DEG5_RTS_bm
	; ld a,0E8h ;DTR active, TX 8bit, BREAK off, TX on, RTS inactive
	out (c), a
SIO_INTERRUPT::
	ld a,SIO_REG1 ;write into WR0: select WR1
	out (c), a
	ld a,00000000b ;no interrupt in CH A, special RX condition affects vect
	out (c), a
SIO_RX_EN:
	;enable SIO channel A RX
	ld a,SIO_REG3 ;write into WR0: select WR3
	out (c), a
	xor a
	ld b, a
	ld a, e; Set RX char size
	and 0b11000000
	or b
	ld b, SIO_DEG3_RX_ENABLE_bm ; 0C1h ;RX 8bit, auto enable off, RX on
	or b
	out (c), a
	;Channel A RX active
	; Clear the semaphore
	pop bc
	push bc
	ld hl, BOARD_IO_SIO_SEMAPHORE
	call semaphore_Clr
	pop bc
	pop hl
	ret

;-----------------------------------------------------------------------
; Functions:
; sio_SetRts
; Required:
; a = 1 RTS will be set on. 0 RTS will be set off
; c = SIO config address
; h = Tx char size
; Altered:
; a
;-----------------------------------------------------------------------
sio_SetRts:
	push af
	xor a
	inc a
	jr sio_ClrRts_Skip
sio_ClrRts:
	push af
	xor a
sio_ClrRts_Skip:
	push bc
	sla a
	and 0x02
	or SIO_DEG5_TX_CHAR_LEN_8BIT_m | SIO_DEG5_TX_ENABLE_bm
	ld b, a
	ld a,SIO_REG5 ;write into WR0: select WR5
	out (c), a
	out (c), b
	pop bc
	pop af
	ret

;-----------------------------------------------------------------------
; Functions:
; sio_TxWaitEmpty
; Required:
; c = SIO config address
; Altered:
; c
;-----------------------------------------------------------------------
sio_TxWaitEmpty:
	push af
	;call sio_GetAddr
TX_EMP:
	; check for TX buffer empty
	xor a ;clear a, write into WR0: select RR0
	inc a ;select RR1
	out (c),a
	in a,(c) ;read RRx
	bit 0,a
	jp z,TX_EMP
	pop af
	ret
	
;-----------------------------------------------------------------------
; Functions:
; sio_ReadCBlocking
; Required:
; c = SIO config address
; Return
; a = character
; Altered:
; a in chse if a character has been received
;-----------------------------------------------------------------------
sio_ReadCBlocking:
	push bc
	;call sio_GetAddr
RX_EMP_BLOCK:
	; check for TX buffer empty
	xor a ;clear a, write into WR0: select RR0
	out (c),a
	in a,(c) ;read RRx
	bit 0,a
	jp z,RX_EMP_BLOCK
	dec c
	dec c
	in a, (c)
	pop bc
	ret

;-----------------------------------------------------------------------
; Functions:
; sio_ReadCNonBlocking
; Required:
; c = SIO config address
; Return
; a = character
; Flag z = '1 if character received, 0' otherwise
; Altered:
; b, c
; a in chse if a character has been received
;-----------------------------------------------------------------------
sio_ReadCNonBlocking:
	push bc
	push af
	;call sio_GetAddr
	call sio_SetRts
RX_EMP_NONBLOCK:
	; check for TX buffer empty
	xor a ;clear a, write into WR0: select RR0
	out (c),a
	in a,(c) ;read RRx
	bit 0,a
	jp z,sioRxNChar
	pop af
	call sio_ClrRts
	dec c
	dec c
	in a, (c)
	set 0, b
	bit 0, b
	pop bc
	ret
sioRxNChar:
	pop af
	res 0, b
	bit 0, b
	pop bc
	ret

;-----------------------------------------------------------------------
; Functions:
; sio_SendC
; Required:
; c = SIO config address
; a = character
; Altered:
; none
;-----------------------------------------------------------------------
sio_SendC:
	push bc
	call sio_TxWaitEmpty
	; send data is 2 addresses below
	dec c
	dec c
	out (c), a
	pop bc
	ret

;-----------------------------------------------------------------------
; Functions:
; sio_PrintStr
; Required:
; c = SIO config address
; hl = string address
; Altered:
; none
;-----------------------------------------------------------------------
sio_PrintStr:
	push hl
sio_PrintStr_Loop:
	ld a, (hl)
	cp 0
	jr z, sio_PrintStr_End
	call sio_SendC
	inc hl
	jr sio_PrintStr_Loop
sio_PrintStr_End:
	pop hl
	ret

;-----------------------------------------------------------------------
; Functions:
; sio_PrintHHexChar
; sio_PrintLHexChar
; Required:
; c = SIO config address
; Altered:
; a
;-----------------------------------------------------------------------
sio_PrintHHexChar:
	push de
	push bc
	call str_HCharToHex
	jr sio_PrintLHexChar_Skip
sio_PrintLHexChar:
	push de
	push bc
	call str_LCharToHex
sio_PrintLHexChar_Skip:
	ld de, bc
	pop bc
	ld a, d
	call sio_SendC
	ld a, e
	call sio_SendC
	pop de
	ret

;-----------------------------------------------------------------------
; Functions:
; sio_PrintHHexBuf
; Required:
; c = SIO config address
; de = Buf len
; hl = Buf address
; Altered:
; a
;-----------------------------------------------------------------------
sio_PrintHHexBuf:
	push de
	push hl
sio_PrintHHexBuf_Loop:
	xor a
	cp e
	jr nz, sio_PrintHHexBuf_Continue
	cp d
	jr nz, sio_PrintHHexBuf_Continue
	jr sio_PrintHHexBuf_End
sio_PrintHHexBuf_Continue:
	ld a, (hl)
	call sio_PrintHHexChar
	dec de
	inc hl
	jr sio_PrintHHexBuf_Loop
sio_PrintHHexBuf_End:
	pop hl
	pop de
	ret


