DEFC TEXT_EDITOR_MAX_BUF_LEN	= 4096
DEFC TEXT_EDITOR_WIDTH		= 80
DEFC TEXT_EDITOR_HEIGHT		= 40


SECTION KERNEL_BSS
TEXT_EDITOR_BUF_CURSOR: 
DEFW 0
SECTION KERNEL_TEXT_EDITOR

;TEXT_EDITOR_BLUE:
;DEFB "\e[0;34m\0"
;TEXT_EDITOR_RED:
;DEFB "\e[0;31m\0"
;TEXT_EDITOR_LIGHT_RED:
;DEFB "\e[1;31m\0"
;TEXT_EDITOR_WHITE:
;DEFB "\e[1;37m\0"
;TEXT_EDITOR_NO_COLOUR:
;DEFB "\e[0m\0"

	EXTERN __TEXT_EDITOR_BUFFER_head
	EXTERN __TEXT_EDITOR_BUFFER_tail
	EXTERN __TEXT_EDITOR_BUFFER_size

;-----------------------------------------------------------------------
; Functions:
; textEditor_Init
; Required:
; Return:
; Altered:
;-----------------------------------------------------------------------
textEditor_Init:
	ld bc, __TEXT_EDITOR_BUFFER_head
	ld (TEXT_EDITOR_BUF_CURSOR), bc
        ld hl, __TEXT_EDITOR_BUFFER_head
        ld de, __TEXT_EDITOR_BUFFER_head + 1
        ld bc, __TEXT_EDITOR_BUFFER_size - 1
        ld (hl), 0
        ldir
	ret;
	
;-----------------------------------------------------------------------
; Functions:
; textEditor_MoveLeft
; Required:
; Return:
; Altered:
;-----------------------------------------------------------------------
textEditor_MoveLeft:
	ret
	
;-----------------------------------------------------------------------
; Functions:
; textEditor_MoveRight
; Required:
; Return:
; Altered:
;-----------------------------------------------------------------------
textEditor_MoveRight:
	ret
	
;-----------------------------------------------------------------------
; Functions:
; textEditor_CursorLeft
; Required:
; Return:
; Altered:
; a, d, e, h, l
;-----------------------------------------------------------------------
textEditor_CursorLeft:
	ld hl, (TEXT_EDITOR_BUF_CURSOR)
	ld de, __TEXT_EDITOR_BUFFER_head + 1
	xor a
	sbc hl, de
	jr c, textEditor_CursorLeft_Head
	ld hl, (TEXT_EDITOR_BUF_CURSOR)
	inc e
	xor a
	sbc hl, de
	ld (TEXT_EDITOR_BUF_CURSOR), hl
textEditor_CursorLeft_Head:
	ret

;-----------------------------------------------------------------------
; Functions:
; textEditor_CursorRight
; Required:
; Return;
; Altered:
; a, d, e, h, l
;-----------------------------------------------------------------------
textEditor_CursorRight:
	ld hl, (TEXT_EDITOR_BUF_CURSOR)
	ld a, (hl)
	cp 0
	jr z, textEditor_CursorRight_End
	ld de, 1
	add hl, de
	ld (TEXT_EDITOR_BUF_CURSOR), hl
textEditor_CursorRight_End:
	ret
	
;-----------------------------------------------------------------------
; Functions:
; textEditor_CursorUp
; Required:
; Return;
; Altered:
; a, d, e, h, l
;-----------------------------------------------------------------------
textEditor_CursorUp:
	ld hl, (TEXT_EDITOR_BUF_CURSOR)
	ld de, __TEXT_EDITOR_BUFFER_head + 1
	xor a
	sbc hl, de
	jr c, textEditor_CursorUp_Head
; Search for beginning of the buffer or the beginning of current row
	ld hl, (TEXT_EDITOR_BUF_CURSOR)
	ld de, 1
textEditor_CursorUp_Loop1:
	xor a
	sbc hl, de
	ld a, (hl)
	cp 0
	jr z, textEditor_CursorUp_BufferHead
	cp '\r'
	jr nz, textEditor_CursorUp_Loop1
; Search for the beginning of the buffer or the beginning of the upward row
textEditor_CursorUp_Loop2:
	xor a
	sbc hl, de
	ld a, (hl)
	cp 0
	jr z, textEditor_CursorUp_BufferHead
	cp '\r'
	jr nz, textEditor_CursorUp_Loop2
; Beginning of upward row is found, add 1 to the pointer to point the first character in the row
	add hl, de
; Save the cursor
	ld (TEXT_EDITOR_BUF_CURSOR), hl

textEditor_CursorUp_BufferHead:
	ld hl, __TEXT_EDITOR_BUFFER_head
	ld (TEXT_EDITOR_BUF_CURSOR), hl
textEditor_CursorUp_Head:
	ret
	
;-----------------------------------------------------------------------
; Functions:
; textEditor_CursorDown
; Required:
; Return;
; Altered:
; a, d, e, h, l
;-----------------------------------------------------------------------
textEditor_CursorDown:
	ld hl, (TEXT_EDITOR_BUF_CURSOR)
	ld de, __TEXT_EDITOR_BUFFER_tail - 1
	xor a
	sbc hl, de
	jr nc, textEditor_CursorDown_Tail
; Search for the beginning of next row
	ld de, 1
	ld hl, (TEXT_EDITOR_BUF_CURSOR)
textEditor_CursorDown_Loop:
	adc hl, de
	ld a, (hl)
	cp 0
	jr z, textEditor_CursorDown_BufferTail
	cp '\r'
	jr nz, textEditor_CursorDown_Loop
; Nex row found, increment the pointer to point to the first char in next row
	adc hl, de
textEditor_CursorDown_BufferTail:
	ld (TEXT_EDITOR_BUF_CURSOR), hl
textEditor_CursorDown_Tail:
	ret
	
;-----------------------------------------------------------------------
; Functions:
; textEditor_InsertChar
; Required:
; Return;
; Altered:
; a, b, d, e, h, l
;-----------------------------------------------------------------------
textEditor_InsertChar:
	ld hl, (TEXT_EDITOR_BUF_CURSOR)
	ld de, __TEXT_EDITOR_BUFFER_tail - 1
	ld b, a
	push hl
	xor a
	sbc hl, de
	pop hl
	jr nc, textEditor_EndOfBuf
	ld(hl), b
	ld de, 1
	add hl, de
	ld (TEXT_EDITOR_BUF_CURSOR), hl
textEditor_EndOfBuf:
	ret

;-----------------------------------------------------------------------
; Functions:
; textEditor_Key
; Required:
; Return;
; Altered:
;-----------------------------------------------------------------------
textEditor_Key:
	push af
	ld b, 0
	ld c, SIO_BASE_ADDR
	ld a, '\e'
	call sio_SendC
	ld a, '['
	call sio_SendC
	ld a, '1'
	call sio_SendC
	ld a, ';'
	call sio_SendC
	ld a, '1'
	call sio_SendC
	ld a, 'H'
	call sio_SendC
	pop af
	cp a, '\r'
	jr z, textEditor_KeyAboveEnterKey
	cp a, ' '
	jr c, textEditor_KeyBelowMinKey
	cp a, '~' + 1
	jr nc, textEditor_KeyAboveMaxKey
; Insert character into the buffer
textEditor_KeyAboveEnterKey:
	call textEditor_InsertChar
; The screen was cleared, send the buffer again
	ld hl, __TEXT_EDITOR_BUFFER_head
	ld de, 1
textEditor_Key_Loop:
	ld a, (hl)
	cp 0
	jr z, textEditor_Key_End
	push bc
	
	ld b, 0
	ld c, SIO_BASE_ADDR

	call sio_SendC
	cp a, '\r'
	jr nz, textEditor_Key_SkipNewLine
	ld a, '\n'
	call sio_SendC
textEditor_Key_SkipNewLine:
	pop bc
	add hl, de
	jr textEditor_Key_Loop
	ret
textEditor_KeyBelowMinKey:
textEditor_KeyAboveMaxKey:

textEditor_Key_End:
	ret

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------

