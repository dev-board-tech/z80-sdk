IFNDEF FAT_FS_H
DEFINE FAT_FS_H

;INDEX STRUCTURE, OFFSETS ARE IN CLUSTERS (512 BYTES)
DEFC FAT_IDX_DISK_PARAM_ADDR_PTR				= 0
DEFC FAT_IDX_INDEX_TABLE_OFFSET					= FAT_IDX_DISK_PARAM_ADDR_PTR + 2
DEFC FAT_IDX_DATA_TABLE_OFFSET					= FAT_IDX_INDEX_TABLE_OFFSET + 2
DEFC FAT_IDX_WINDOW_INDEX_LAST					= FAT_IDX_DATA_TABLE_OFFSET + 2
DEFC FAT_IDX_WINDOW_INDEX						= FAT_IDX_WINDOW_INDEX_LAST + 2
DEFC FAT_IDX_SECTORS_PER_CLUSTER				= FAT_IDX_WINDOW_INDEX + 2
DEFC FAT_IDX_BUFFER								= FAT_IDX_SECTORS_PER_CLUSTER + 2
DEFC FAT_IDX_BUFFER_LEN							= 512
DEFC FAT_IDX_STRUCT_LEN							= FAT_IDX_BUFFER + FAT_IDX_BUFFER_LEN

;DATA STRUCTURE
DEFC FAT_DATA_INDEX_STRUCT_POINTER_OFFSET		= 0
DEFC FAT_DATA_WINDOW_INDEX_LAST					= FAT_DATA_INDEX_STRUCT_POINTER_OFFSET + 2
DEFC FAT_DATA_WINDOW_INDEX						= FAT_DATA_WINDOW_INDEX_LAST + 2
DEFC FAT_DATA_STRUCT_LEN						= FAT_DATA_WINDOW_INDEX + 2

;FILE STRUCTURE
DEFC FAT_FILE_DATA_STRUCT_POINTER_OFFSET		= 0
DEFC FAT_FILE_NAME_SHORT						= FAT_FILE_DATA_STRUCT_POINTER_OFFSET + 2
DEFC FAT_FILE_NAME_SHORT_LEN					= 10

;hl = read write pointer
;ix = data pointer
;iy = index pointer
;------------------------------------------------------
; INDEX SECTION

MACRO FAT_IDX_LOAD_BC offset
	ld c, (iy + offset)
	ld b, (iy + offset + 1)
ENDM

MACRO FAT_IDX_LOAD_DE offset
	ld e, (iy + offset)
	ld d, (iy + offset + 1)
ENDM

MACRO FAT_IDX_LOAD_HL offset
	ld l, (iy + offset)
	ld h, (iy + offset + 1)
ENDM

MACRO FAT_IDX_SAVE_BC offset
	ld (iy + offset), c
	ld (iy + offset + 1), b
ENDM

MACRO FAT_IDX_SAVE_DE offset
	ld (iy + offset), e
	ld (iy + offset + 1), d
ENDM

MACRO FAT_IDX_SAVE_HL offset
	ld (iy + offset), l
	ld (iy + offset + 1), h
ENDM

MACRO FAT_IDX_ADD_SHORT offsetd, offsets1, offsets2
	ld a, (iy + offsets1)
	add a, (iy + offsets2)
	ld (iy + offsetd), a
	ld a, (iy + offsets1 + 1)
	adc a, (iy + offsets2 + 1)
	ld (iy + offsetd + 1), a
ENDM

;------------------------------------------------------
; DATA SECTION

MACRO FAT_DATA_LOAD_BC offset
	ld c, (ix + offset)
	ld b, (ix + offset + 1)
ENDM

MACRO FAT_DATA_LOAD_DE offset
	ld e, (ix + offset)
	ld d, (ix + offset + 1)
ENDM

MACRO FAT_DATA_LOAD_HL offset
	ld l, (ix + offset)
	ld h, (ix + offset + 1)
ENDM

MACRO FAT_DATA_LOAD_IDX_POINTER_HL
	ld l, (ix + FAT_DATA_INDEX_STRUCT_POINTER_OFFSET)
	ld h, (ix + FAT_DATA_INDEX_STRUCT_POINTER_OFFSET + 1)
ENDM

MACRO FAT_DATA_SAVE_BC offset
	ld (ix + offset), c
	ld (ix + offset + 1), b
ENDM

MACRO FAT_DATA_SAVE_DE offset
	ld (ix + offset), e
	ld (ix + offset + 1), d
ENDM

MACRO FAT_DATA_SAVE_HL offset
	ld (ix + offset), l
	ld (ix + offset + 1), h
ENDM

MACRO FAT_DATA_SAVE_IDX_POINTER_HL
	ld (ix + FAT_DATA_INDEX_STRUCT_POINTER_OFFSET), l
	ld (ix + FAT_DATA_INDEX_STRUCT_POINTER_OFFSET + 1), h
ENDM

MACRO FAT_DATA_ADD_SHORT offsetd, regd, offsets1, regs1, offsets2, regs2
	ld a, (ix + offsets1)
	add a, (ix + offsets2)
	ld (ix + offsetd), a
	ld a, (ix + offsets1 + 1)
	adc a, (ix + offsets2 + 1)
	ld (ix + offsetd + 1), a
ENDM
;------------------------------------------------------
; DATA SECTION

MACRO FAT_FILE_LOAD_DATA_POINTER_HL
	ld l, (ix + FAT_FILE_DATA_STRUCT_POINTER_OFFSET)
	ld h, (ix + FAT_FILE_DATA_STRUCT_POINTER_OFFSET + 1)
ENDM

MACRO FAT_FILE_SAVE_DATA_POINTER_HL
	ld (ix + FAT_FILE_DATA_STRUCT_POINTER_OFFSET), l
	ld (ix + FAT_FILE_DATA_STRUCT_POINTER_OFFSET + 1), h
ENDM

MACRO FAT_FILE_RESTORE_FROM_DATA_INDEX_POINTER
	pop iy
	pop ix
ENDM

MACRO FAT_DATA_GET_DATA_INDEX_POINTER ;ix, iy remain pushed, for quick restore when FAT_FILE_RESTORE_FROM_DATA_INDEX_POINTER
	push ix
	push iy
	push hl
	ld l, (ix + FAT_FILE_DATA_STRUCT_POINTER_OFFSET)
	ld h, (ix + FAT_FILE_DATA_STRUCT_POINTER_OFFSET + 1)
	push hl
	pop ix
	ld l, (ix + FAT_DATA_INDEX_STRUCT_POINTER_OFFSET)
	ld h, (ix + FAT_DATA_INDEX_STRUCT_POINTER_OFFSET + 1)
	push hl
	pop iy
	pop hl
ENDM


ENDIF
