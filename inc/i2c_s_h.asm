IFNDEF I2C_S_H
DEFINE I2C_S_H

;-----------------------------------------------------------------------
; Altered:
; a, bc
;-----------------------------------------------------------------------
MACRO I2C_RESET_MACRO pioIoCfgAddr, pioIoDatAddr, pioRamAddr, sclPinMask, sdaPinMask

LOCAL i2c_Reset_Macro_Loop

	PIO_DIR_INPUT_ADDR(0xFF & (sclPinMask | sdaPinMask), pioIoCfgAddr, pioRamAddr)
	PIO_CLR_OUT_ADDR(0xFF & (sclPinMask | sdaPinMask), pioIoDatAddr, pioRamAddr)
	ld c, pioIoCfgAddr
	ld b, 0x0a
i2c_Reset_Macro_Loop:
	push bc
	ld b, 0xcf
	out (c), b
	or sclPinMask
	out (c), a
	out (c), b
	and ~sclPinMask
	out (c), a
	pop bc
	djnz i2c_Reset_Macro_Loop
	ld b, 0xcf
	out (c), b
	or sclPinMask
	out (c), a
ENDM

;-----------------------------------------------------------------------
; Required:
; de = bytes to send
; hl = buffer address
; Return:
; Flag C = 0' if success, 1' if error
; Altered:
; a, bc, de, hl
;-----------------------------------------------------------------------
MACRO I2C_W_MACRO pioIoCfgAddr, pioIoDatAddr, pioRamAddr, sclPinMask, sdaPinMask, sdaPin

LOCAL i2c_W_Macro_ByteLoop, i2c_W_Macro_BitLoop, i2c_W_Macro_BitLoopH, i2c_W_Macro_BitLoopHSkip, i2c_ClkCycle_Z1, i2c_W_Macro_NoAck, i2c_W_Macro_End, i2c_W_Macro_Ack

	dec de
	ld a, (pioRamAddr + PIO_IO_DIR)
	ld b, 0xcf
	ld c, pioIoCfgAddr
;---------------
	; Start
	out (c), b
	or sclPinMask
	out (c), a
	out (c), b
	and ~sdaPinMask
	out (c), a
	out (c), b
	and ~sclPinMask
	out (c), a
;---------------
i2c_W_Macro_ByteLoop:
	bit 7, d
	jr nz, i2c_W_Macro_End
	ld b, 0x08
	push de
	push hl
	ld e, (hl)
	ld h, sclPinMask
	ld l, ~sclPinMask
i2c_W_Macro_BitLoop:
	sla e
	jr c, i2c_W_Macro_BitLoopH
	and ~sdaPinMask
	jr i2c_W_Macro_BitLoopHSkip
i2c_W_Macro_BitLoopH:
	or sdaPinMask
i2c_W_Macro_BitLoopHSkip:
	ld d, 0xcf
	ld c, pioIoCfgAddr
	; Put bit
	out (c), d
	out (c), a
	; CLK Cycle
	out (c), d
	or h
	out (c), a
	out (c), d
	and l
	out (c), a
	djnz i2c_W_Macro_BitLoop
;---------------
	; Set SDA as input
	ld b, 0xcf
	out (c), b
	or sdaPinMask
	out (c), a
;---------------
	; CLK Cycle
	out (c), b
	or h
	out (c), a
	ld c, pioIoDatAddr
	in b, (c)
	ld c, pioIoCfgAddr
	bit sdaPin, b
	ld b, 0xcf
	jr z, i2c_ClkCycle_Z1
;---------------
	; Clock Low
	out (c), b
	and l
	out (c), a
	pop hl
	pop de
	jr i2c_W_Macro_NoAck
;---------------
i2c_ClkCycle_Z1:
	; Clock Low
	out (c), b
	and l
	out (c), a
	pop hl
	pop de
	dec de
	inc hl
	jr i2c_W_Macro_ByteLoop
;---------------
i2c_W_Macro_NoAck:
	scf
	jp i2c_W_Macro_Ack:
;---------------
i2c_W_Macro_End:
	scf
	ccf
i2c_W_Macro_Ack:
	push af
	; Send STOP
	out (c), b
	and ~sdaPinMask
	out (c), a
	out (c), b
	or sclPinMask
	out (c), a
	out (c), b
	or sdaPinMask
	out (c), a
	pop af
ENDM

;-----------------------------------------------------------------------
; Required:
; b = bytes to send
; de = bytes to receive
; hl = buffer address
; Altered:
; a, bc, de, hl
;-----------------------------------------------------------------------
MACRO I2C_R_MACRO pioIoCfgAddr, pioIoDatAddr, pioRamAddr, sclPinMask, sdaPinMask, sdaPin

LOCAL i2c_R_Macro_ByteLoop, i2c_R_Macro_BitLoop, i2c_R_Macro_BitLoopH, i2c_R_Macro_BitLoopHSkip, i2c_ClkCycle_Z1, i2c_R_Macro_OnlyRead, i2c_R_Macro_AllSent, i2c_R_Macro_BitLoopAddr, i2c_R_Macro_BitLoopHAddr, i2c_R_Macro_BitLoopHSkipAddr, i2c_R_Macro_NoAck_, i2c_ClkCycle_Z1Addr, i2c_R_Macro_ByteLoopRec, i2c_R_Macro_BitLoopRec, i2c_R_Macro_BitLoopRecNz, i2c_R_Macro_AllReceivedSndStop, i2c_R_Macro_NoAck, i2c_R_Macro_AllReceived, i2c_R_Macro_Stop

	dec de
	push de
	ld c, (hl)
	push bc
	xor a
	cp b
	jr z, i2c_R_Macro_OnlyRead_
	ld e, b
	xor d
	dec e
	ld a, (pioRamAddr + PIO_IO_DIR)
	ld b, 0xcf
	ld c, pioIoCfgAddr
;---------------
	; Start
	out (c), b
	or sclPinMask
	out (c), a
	out (c), b
	and ~sdaPinMask
	out (c), a
	out (c), b
	and ~sclPinMask
	out (c), a
;---------------
i2c_R_Macro_ByteLoop:
	bit 7, d
	jr nz, i2c_R_Macro_AllSent
	ld b, 0x08
	push de
	push hl
	ld e, (hl)
	ld h, sclPinMask
	ld l, ~sclPinMask
i2c_R_Macro_BitLoop:
	sla e
	jr c, i2c_R_Macro_BitLoopH
	and ~sdaPinMask
	jr i2c_R_Macro_BitLoopHSkip
i2c_R_Macro_BitLoopH:
	or sdaPinMask
i2c_R_Macro_BitLoopHSkip:
	ld d, 0xcf
	ld c, pioIoCfgAddr
	; Put bit
	out (c), d
	out (c), a
	; CLK Cycle
	out (c), d
	or h
	out (c), a
	out (c), d
	and l
	out (c), a
	djnz i2c_R_Macro_BitLoop
;---------------
	; Set SDA as input
	ld b, 0xcf
	out (c), b
	or sdaPinMask
	out (c), a
;---------------
	; CLK Cycle
	out (c), b
	or h
	out (c), a
	ld c, pioIoDatAddr
	in b, (c)
	ld c, pioIoCfgAddr
	bit sdaPin, b
	ld b, 0xcf
	jr z, i2c_ClkCycle_Z1
;---------------
	; Clock Low
	out (c), b
	and l
	out (c), a
	pop hl
	pop de
	jr i2c_R_Macro_NoAck_
i2c_R_Macro_OnlyRead_:
	jr i2c_R_Macro_OnlyRead
;---------------
i2c_ClkCycle_Z1:
	; Clock Low
	out (c), b
	and l
	out (c), a
	pop hl
	pop de
	dec de
	inc hl
	jr i2c_R_Macro_ByteLoop
i2c_R_Macro_OnlyRead:
	inc hl
	ld a, (pioRamAddr + PIO_IO_DIR)
	ld b, 0xcf
	ld c, pioIoCfgAddr
i2c_R_Macro_AllSent:
;---------------
	; Start
	ld b, 0xcf
	out (c), b
	or sclPinMask
	out (c), a
	out (c), b
	and ~sdaPinMask
	out (c), a
	out (c), b
	and ~sclPinMask
	out (c), a
	pop de
	set 0, e
;---------------
	push hl
	ld b, 0x08
	ld h, sclPinMask
	ld l, ~sclPinMask
i2c_R_Macro_BitLoopAddr:
	sla e
	jr c, i2c_R_Macro_BitLoopHAddr
	and ~sdaPinMask
	jr i2c_R_Macro_BitLoopHSkipAddr
i2c_R_Macro_BitLoopHAddr:
	or sdaPinMask
i2c_R_Macro_BitLoopHSkipAddr:
	ld d, 0xcf
	ld c, pioIoCfgAddr
	; Put bit
	out (c), d
	out (c), a
	; CLK Cycle
	out (c), d
	or h
	out (c), a
	out (c), d
	and l
	out (c), a
	djnz i2c_R_Macro_BitLoopAddr
;---------------
	; CLK Cycle
	out (c), d
	or h
	out (c), a
	ld c, pioIoDatAddr
	in b, (c)
	ld c, pioIoCfgAddr
	bit sdaPin, b
	ld b, 0xcf
	jr z, i2c_ClkCycle_Z1Addr
;---------------
	; Clock Low
	out (c), b
	and l
	out (c), a
i2c_R_Macro_NoAck_:
	pop bc
	pop de
	jr i2c_R_Macro_NoAck
;---------------
i2c_ClkCycle_Z1Addr:
	; Clock Low
	out (c), b
	and l
	out (c), a
	pop hl
	pop de
;---------------
i2c_R_Macro_ByteLoopRec:
	; Set SDA as Input
	push bc
	ld b, 0xcf
	out (c), b
	or sdaPinMask
	out (c), a
	pop bc
;---------------
	bit 7, d
	jr nz, i2c_R_Macro_AllReceived
	ld b, 0x08
	push bc
	push de
	ld d, 0xcf
	push hl
	ld h, sclPinMask
	ld l, ~sclPinMask
i2c_R_Macro_BitLoopRec:
	; CLK Cycle
	out (c), d
	or h
	out (c), a
	ld c, pioIoDatAddr
	push bc
	in b, (c)
	bit sdaPin, b
	pop bc
	scf
	jr nz, i2c_R_Macro_BitLoopRecNz
	ccf
i2c_R_Macro_BitLoopRecNz:
	rl e
	ld c, pioIoCfgAddr
	out (c), d
	and l
	out (c), a
	djnz i2c_R_Macro_BitLoopRec
;---------------
	pop hl
	ld b, e
	pop de
	push bc
	dec de
	ld b, 0xcf
	bit 7, d
	jr nz, i2c_R_Macro_AllReceivedSndStop
	; Set SDA as Output
	out (c), b
	and ~sdaPinMask
	out (c), a
i2c_R_Macro_AllReceivedSndStop:
;---------------
	; CLK Cycle
	out (c), b
	or sclPinMask
	out (c), a
	out (c), b
	and ~sclPinMask
	out (c), a
	pop bc
	ld (hl), b
	inc hl
	pop bc
	jr i2c_R_Macro_ByteLoopRec
;---------------
i2c_R_Macro_NoAck:
	scf
i2c_R_Macro_AllReceived:
i2c_R_Macro_Stop:
	push af
	; Send STOP
	ld b, 0xcf
	out (c), b
	and ~sdaPinMask
	out (c), a
	out (c), b
	or sclPinMask
	out (c), a
	out (c), b
	or sdaPinMask
	out (c), a
	pop af
ENDM
ENDIF
