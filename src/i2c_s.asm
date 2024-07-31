SECTION KERNEL_I2C
;-----------------------------------------------------------------------
; Functions:
; i2cs_Init
; Required:
; c = PIO config port address
; ix = port configuration address
; Altered:
;-----------------------------------------------------------------------
i2cs_Init:
	PIO_SET_AS_INPUT(I2CS_SDA_PIN_MASK | I2CS_SCL_PIN_MASK)
	dec c
	dec c
	PIO_CLR_OUT(I2CS_SDA_PIN_MASK | I2CS_SCL_PIN_MASK)
	inc c
	inc c
	call i2c_Reset
	ret

MACRO I2C_START _
	; Send START
	out (c), b
	or I2CS_SCL_PIN_MASK
	out (c), a
	out (c), b
	and ~I2CS_SDA_PIN_MASK
	out (c), a
	out (c), b
	and ~I2CS_SCL_PIN_MASK
	out (c), a
ENDM

MACRO I2C_STOP _
	; Send STOP
	out (c), b
	and ~I2CS_SDA_PIN_MASK
	out (c), a
	out (c), b
	or I2CS_SCL_PIN_MASK
	out (c), a
	out (c), b
	or I2CS_SDA_PIN_MASK
	out (c), a
ENDM

i2c_ClkCycle:
	; Clock High
	ld b, (ix + PIO_IO_MODE)
	out (c), b
	or I2CS_SCL_PIN_MASK
	out (c), a
	dec c
	dec c
	scf
	in b, (c)
	bit I2CS_SDA_PIN, b
	jr nz, i2c_ClkCycle_Nz
	ccf
i2c_ClkCycle_Nz:
	inc c
	inc c
	; Clock Low
	ld b, (ix + PIO_IO_MODE)
	out (c), b
	and ~I2CS_SCL_PIN_MASK
	out (c), a
	ret

MACRO I2C_SDA_OUT _
	out (c), b
	and ~I2CS_SDA_PIN_MASK
	out (c), a
ENDM
MACRO I2C_SDA_IN _
	out (c), b
	or I2CS_SDA_PIN_MASK
	out (c), a
ENDM
;-----------------------------------------------------------------------
; Functions:
; i2c_Reset
; Required:
; a = byte to be send
; c = PIO config port address
; ix = port configuration address
; Altered:
; a, b
;-----------------------------------------------------------------------
;leaves SDA = H and SCL = H
i2c_Reset:
	ld b, 0x0a
i2c_Reset_Loop:
	push bc
	call i2c_ClkCycle
	pop bc
	djnz i2c_Reset_Loop
	ld b, (ix + PIO_IO_MODE)
	I2C_SDA_IN()
	ret
;-----------------------------------------------------------------------
; Functions:
; i2c_W
; Required:
; c = PIO config port address
; de = bytes to send
; hl = buffer address
; ix = port configuration address
; Altered:
; a, b
;-----------------------------------------------------------------------
i2c_W:
	push bc
	push de
	push hl
	dec de
	ld b, (ix + PIO_IO_MODE)
	ld a, (ix + PIO_IO_DIR)
	I2C_START()
i2c_W_ByteLoop:
	bit 7, d
	jr nz, i2c_W_End
	ld b, 0x08
i2c_W_BitLoop:
	sla (hl)
	jr c, i2c_W_BitLoopH
	and ~I2CS_SDA_PIN_MASK
	jr i2c_W_BitLoopHSkip
i2c_W_BitLoopH:
	or I2CS_SDA_PIN_MASK
i2c_W_BitLoopHSkip:
	push bc
	ld b, (ix + PIO_IO_MODE)
	; Put bit
	out (c), b
	out (c), a
	call i2c_ClkCycle
	pop bc
	djnz i2c_W_BitLoop
	ld b, (ix + PIO_IO_MODE)
	; Set SDA as input
	I2C_SDA_IN()
	call i2c_ClkCycle
	jr c, i2c_W_NoAck
	dec de
	inc hl
	jr i2c_W_ByteLoop
;-----------------------------------------------------------------------
; Functions:
; i2c_W
; Required:
; b = bytes to send
; c = PIO config port address
; de = bytes to receive
; hl = buffer address
; ix = port configuration address
; Altered:
; a, b
;-----------------------------------------------------------------------
i2c_R:
	push bc
	push de
	push hl
	ld a, (hl)
	push de
	push af
	ld e, b
	dec e
	ld b, (ix + PIO_IO_MODE)
	ld a, (ix + PIO_IO_DIR)
	I2C_START()
i2c_R_ByteLoopW:
	bit 7, e
	jr nz, i2c_R_ReSendAddr
	ld b, 0x08
i2c_R_BitLoopW:
	sla (hl)
	jr c, i2c_R_BitLoopH
	and ~I2CS_SDA_PIN_MASK
	jr i2c_R_BitLoopHSkip
i2c_R_BitLoopH:
	or I2CS_SDA_PIN_MASK
i2c_R_BitLoopHSkip:
	push bc
	ld b, (ix + PIO_IO_MODE)
	; Put bit
	out (c), b
	out (c), a
	call i2c_ClkCycle
	pop bc
	djnz i2c_R_BitLoopW
	ld b, (ix + PIO_IO_MODE)
	; Set SDA as input
	I2C_SDA_IN()
	call i2c_ClkCycle
	jr c, i2c_W_NoAck
	dec e
	inc hl
	jr i2c_R_ByteLoopW
	
i2c_W_End:
i2c_W_NoAck:
	I2C_STOP()
	pop hl
	pop de
	pop bc
	ret

i2c_R_ReSendAddr:
	I2C_SDA_IN()
	I2C_START()
	pop de
	set 0, d

	bit 7, e
	jr nz, i2c_R_Receive
	ld b, 0x08
i2c_R_BitLoopWW:
	sla d
	jr c, i2c_R_BitLoopHW
	and ~I2CS_SDA_PIN_MASK
	jr i2c_R_BitLoopHSkipW
i2c_R_BitLoopHW:
	or I2CS_SDA_PIN_MASK
i2c_R_BitLoopHSkipW:
	push bc
	ld b, (ix + PIO_IO_MODE)
	; Put bit
	out (c), b
	out (c), a
	call i2c_ClkCycle
	pop bc
	djnz i2c_R_BitLoopWW
	I2C_SDA_IN()
	call i2c_ClkCycle
	jr c, i2c_W_NoAck

i2c_R_Receive:	
	pop de
	dec de
i2c_R_ByteLoopR:
	;I2C_SDA_IN()
	bit 7, d
	jr nz, i2c_W_End
	ld b, 0x08
i2c_R_BitLoopR:
	push bc
	call i2c_ClkCycle
	rl (hl)
	pop bc
	djnz i2c_R_BitLoopR
	
	dec de
	bit 7, d
	jr nz, i2c_R_LastByteAndNack
	I2C_SDA_OUT()
i2c_R_LastByteAndNack:
	call i2c_ClkCycle
	I2C_SDA_IN()
	inc hl
	jr i2c_R_ByteLoopR


