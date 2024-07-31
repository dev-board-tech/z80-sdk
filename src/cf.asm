INCLUDE "cf_h.asm"

INCLUDE "dev/disk_h.asm"

SECTION KERNEL_CF
;-----------------------------------------------------------------------
; Function:
; cf_waitForReady
; Required:
; b = timeout
; Return:
; Flag C = 0' if success, 1' if error
; Altered:
; a, b
;-----------------------------------------------------------------------
cf_waitForReady:
	push bc
	ld b, 0
cf_waitForReady_IsBusy:
	djnz cf_waitForReady_NoTimeout
	jr cf_waitForReady_Timeout
cf_waitForReady_NoTimeout:
	push bc
	ld b, 0
cf_waitForReady_Loop1:
	djnz cf_waitForReady_Loop1
	pop bc
	in a, (CF_REG_STATUS)
	; Check that RDY bit is set and that BUSY bit is not set
	bit STATUS_RDY_BIT, a
	jr z, cf_waitForReady_IsBusy
	bit STATUS_BUSY_BIT, a
	jr nz, cf_waitForReady_IsBusy
	; Device is ready, return the error bit in A
	and 1 << STATUS_ERR_BIT
	ld (ix + DISK_ERR), a
	or a
	pop bc
	ret
cf_waitForReady_Timeout:
	ld a, 2
	ld (ix + DISK_ERR), a
	or a
	pop bc
	ret

;-----------------------------------------------------------------------
; Function:
; cf_Init
; Return:
; Flag C = 0' if success, 1' if error
; Altered:
; a, b
;-----------------------------------------------------------------------
cf_Init:
	ld a, 0xFF & (cf_Init >> 8)
	ld (ix + DISK_INIT_FUNC + 0), a
	ld a, 0xFF & cf_Init
	ld (ix + DISK_INIT_FUNC + 1), a
	ld a, 0xFF & (cf_IoCtl >> 8)
	ld (ix + DISK_IOCTL_FUNC + 0), a
	ld a, 0xFF & cf_IoCtl
	ld (ix + DISK_IOCTL_FUNC + 1), a
	ld a, 0xFF & (cf_Read >> 8)
	ld (ix + DISK_READ_FUNC + 0), a
	ld a, 0xFF & cf_Read
	ld (ix + DISK_READ_FUNC + 1), a
	ld a, 0xFF & (cf_Write >> 8)
	ld (ix + DISK_WRITE_FUNC + 0), a
	ld a, 0xFF & cf_Write
	ld (ix + DISK_WRITE_FUNC + 1), a
	ld b, 0x0
cf_Init_WaitReady:
	in a, (CF_REG_STATUS)
	or a
	jr z, cf_Init_LoopContinue
	bit STATUS_ERR_BIT, a
	jr nz, cf_Init_NotFound
	bit STATUS_BUSY_BIT, a
	jr z, cf_Init_Ready
cf_Init_LoopContinue:
	djnz cf_Init_WaitReady
cf_Init_NotFound:
	xor a
	inc a
	ret
cf_Init_Ready:
	ld bc, 256
cf_Init_Ready_Loop:
	in a, (CF_REG_STATUS)
	bit STATUS_RDY_BIT, a
	jr nz, cf_Init_Ready_2
	dec bc
	bit 7, b
	jr z,cf_Init_Ready_Loop
	jr cf_Init_NotFound
cf_Init_Ready_2:
	ld a, FEATURE_ENABLE_8_BIT
	out (CF_REG_FEATURE), a
	ld a, COMMAND_SET_FEATURES
	out (CF_REG_COMMAND), a
	; Wait for the CF to be ready again
	call cf_waitForReady
	; If A is not zero, 8-bit mode is not supported
	;jr nz, cf_Init_NotFound
	xor a
	ret

;-----------------------------------------------------------------------
; Function:
; cf_Read
; Required:
; ix = param base address
; Return:
; Flag C = 0' if success, 1' if error
; Altered:
; af
;-----------------------------------------------------------------------
cf_Read:
	push bc
	push de
	push hl
	call cf_waitForReady
	or a
	jp nz, cf_Read_ErrOccurred
	ld a, (ix + DISK_ADDRESS + 3)
	out (CF_REG_LBA_0), a
	ld a, (ix + DISK_ADDRESS + 2)
	out (CF_REG_LBA_8), a
	ld a, (ix + DISK_ADDRESS + 1)
	out (CF_REG_LBA_16), a
	ld a, 0xE0
	or (ix + DISK_ADDRESS + 0)
	out (CF_REG_LBA_24), a
	ld a, (ix + DISK_BLOCKS)
	out (CF_REG_SEC_CNT), a
	ld b, a
	; Number of sectors
	; Issue a read sector command
	ld a, COMMAND_READ_SECTORS
	out (CF_REG_COMMAND), a
	; Wait for the disk to be ready
	call cf_waitForReady
	or a
	jp nz, cf_Read_ErrOccurred
	; We can start reading the data. We have to read 512 bytes, even though we don't
	; need them all.
	ld c, CF_REG_DATA
	ld h, (ix + DISK_BUFF_ADDR + 0)
	ld l, (ix + DISK_BUFF_ADDR + 1)
	; 256 bytes to read
cf_Read_NextSector:
	push bc
	ld b, 0
	inir
	inir
	pop bc
	djnz cf_Read_NextSector
	xor a
	jr cf_ReadWrite_ErrOccurred
cf_Read_ErrOccurred:
	; Get the error register
	in a, (CF_REG_ERROR)
cf_ReadWrite_ErrOccurred:
	pop hl
	pop de
	pop bc
	ret

;-----------------------------------------------------------------------
; Function:
; cf_Write
; Required:
; ix = param base address
; Return:
; Flag C = 0' if success, 1' if error
; Altered:
; af
;-----------------------------------------------------------------------
cf_Write:
	push bc
	push de
	push hl
	call cf_waitForReady
	or a
	jp nz, cf_Write_ErrOccurred
	ld a, (ix + DISK_ADDRESS + 3)
	out (CF_REG_LBA_0), a
	ld a, (ix + DISK_ADDRESS + 2)
	out (CF_REG_LBA_8), a
	ld a, (ix + DISK_ADDRESS + 1)
	out (CF_REG_LBA_16), a
	ld a, 0xE0
	or (ix + DISK_ADDRESS + 0)
	out (CF_REG_LBA_24), a
	ld a, (ix + DISK_BLOCKS)
	out (CF_REG_SEC_CNT), a
	ld b, a
	out (CF_REG_SEC_CNT), a
	; Issue a WRITE sector command
	ld a, COMMAND_WRITE_SECTORS
	out (CF_REG_COMMAND), a
	; Wait for the disk to be ready
	call cf_waitForReady
	or a
	jp nz, cf_Write_ErrOccurred
	; We can fill the CompactFlash sector buffer
	ld c, CF_REG_DATA
	ld h, (ix + DISK_BUFF_ADDR + 0)
	ld l, (ix + DISK_BUFF_ADDR + 1)
	push bc
cf_Write_NextSector:
	ld b, 0
	otir    ; output 256 bytes
	otir    ; output 256 bytes
	call cf_waitForReady
	or a
	jp nz, cf_Write_ErrOccurred
	pop bc
	djnz cf_Write_NextSector
	xor a
	jr cf_ReadWrite_ErrOccurred
cf_Write_ErrOccurred:
	; Get the error register
	in a, (CF_REG_ERROR)
	jr cf_ReadWrite_ErrOccurred


cf_IoCtl:
	ret
