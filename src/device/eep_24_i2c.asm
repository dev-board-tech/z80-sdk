SECTION KERNEL_DRIVER
;-----------------------------------------------------------------------
; Functions:
; eep24_I2c_ReadAddr
; Required:
; c = port address
; ix = port configuration address
; a = device address
; b = number of bytes to read
; de = address to read
; hl = buffer addr
; Return:
; Carry is set if successfull, Carry is reset if ACK error occure
; Altered:
;-----------------------------------------------------------------------
eep24_I2c_ReadAddr:
	push bc
	push de
	push af
	call i2c_Start
	pop af
	push af
	res 0, a
	call i2c_Tx
	jp nc, eep24_I2c_ReadAddr_ErrAckA
	ld a, d
	call i2c_Tx
	jp nc, eep24_I2c_ReadAddr_ErrAckA
	ld a, e
	call i2c_Tx
	jp nc, eep24_I2c_ReadAddr_ErrAckA
	call i2c_Start
	pop af
	set 0, a
	call i2c_Tx
	jp nc, eep24_I2c_ReadAddr_ErrAck
eep24_I2c_ReadAddr_Loop:
	dec b
	jr z, eep24_I2c_ReadAddr_End
	call i2c_Rx
	ld (hl), a
	call i2c_SdaOut
	call i2c_SclCycle; Send ACK
	call i2c_SdaIn
	inc hl
	jr eep24_I2c_ReadAddr_Loop
eep24_I2c_ReadAddr_End:
	call i2c_Rx
	ld (hl), a
	call i2c_SclCycle; Send NACK
	call i2c_Stop
	inc hl
	pop de
	pop bc
	scf
	ret
eep24_I2c_ReadAddr_ErrAckA:
	pop af
eep24_I2c_ReadAddr_ErrAck:
	call i2c_Stop
	pop de
	pop bc
	scf
	ccf
	ret
;-----------------------------------------------------------------------
; Functions:
; ep24_I2c_Write
; Required:
; c = port address
; ix = port configuration address
; a = device address
; b = number of bytes to write
; de = address to write
; hl = buffer addr
; Return:
; Carry is set if successfull, Carry is reset if ACK error occure
; Altered:
;-----------------------------------------------------------------------
ep24_I2c_Write:
	push bc
	push de
	ld b, a
	call i2c_Start
	ld a, b
	res 0, a
	call i2c_Tx
	jp nc, eep24_I2c_WriteAddr_ErrAck
	ld a, d
	call i2c_Tx
	jp nc, eep24_I2c_WriteAddr_ErrAck
	ld a, e
	call i2c_Tx
	jp nc, eep24_I2c_WriteAddr_ErrAck
eep24_I2c_WriteAddr_Loop:
	ld a, (hl)
	inc hl
	jp nc, eep24_I2c_WriteAddr_ErrAck
	call i2c_Tx
	dec b
	jr z, eep24_I2c_WriteAddr_Loop
	call i2c_Stop
	pop de
	pop bc
	scf
	ret
eep24_I2c_WriteAddr_ErrAck:
	call i2c_Stop
	pop de
	pop bc
	scf
	ccf
	ret
