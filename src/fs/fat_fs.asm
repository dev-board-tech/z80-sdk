INCLUDE "fs/fat_fs_h.asm"
INCLUDE "sys/util_h.asm"

SECTION KERNEL_BSS

SECTION KERNEL_NOINIT_DATA

SECTION KERNEL_LIB_FS_FAT

;hl = disk struct ptr
;iy = fs pointer structure

FATFS_MOUNT:
	push af
	push bc
	push de
	push hl
	push ix
	ld (iy + FAT_IDX_DISK_DRV_STRUCT_PTR), l
	ld (iy + FAT_IDX_DISK_DRV_STRUCT_PTR + 1), h
	ld ix, hl
	DISK_WRITE_CONST_ADDR (0)
	DISK_WRITE_CONST_BLOCKS (1)
	ld hl, iy
	add hl, FAT_IDX_BUFFER
	ld (ix + DISK_BUFF_ADDR + 0), l
	ld (ix + DISK_BUFF_ADDR + 1), h
	ld l, (ix + DISK_READ_FUNC + 0)
	ld h, (ix + DISK_READ_FUNC + 1)
	DISK_READ
	ld bc, FAT_IDX_BUFFER + FAT_PARTITION_1_OFFSET + FAT_PARTITION_RELATIVE_SECTOR_START_OFFSET
	push ix
	ld ix, iy
	add ix, bc
	ld a, (ix + 0)
	ld (iy + FAT_IDX_PARTITION_OFFSET + 0), a
	ld a, (ix + 1)
	ld (iy + FAT_IDX_PARTITION_OFFSET + 1), a
	ld bc, FAT_IDX_BUFFER + FAT_PARTITION_1_OFFSET + FAT_PARTITION_SYSTEM_ID_OFFSET 
	ld ix, iy
	add ix, bc
	ld a, (ix)
	ld (iy + FAT_IDX_PARTITION_TYPE_OFFSET + 0), a
	pop ix
	ld c, (iy + FAT_IDX_PARTITION_OFFSET + 0)
	ld b, (iy + FAT_IDX_PARTITION_OFFSET + 1)
	ld (ix + DISK_ADDRESS + 3), c
	ld (ix + DISK_ADDRESS + 2), b
	cp FAT_PARTITION_SYSTEM_ID_FAT16_SMALL_32MB
	jr Z, FATFS_MOUNT_FS_DETECTED
	cp FAT_PARTITION_SYSTEM_ID_FAT16_LARGE_32MB
	jr Z, FATFS_MOUNT_FS_DETECTED
	cp FAT_PARTITION_SYSTEM_ID_FAT16B
	jr Z, FATFS_MOUNT_FS_DETECTED
	jp FATFS_MOUNT_RETURN
FATFS_MOUNT_FS_DETECTED:
	DISK_READ
	push bc
	push ix
	push iy
	ld ix, iy
	ld bc, FAT_IDX_BUFFER
	add iy, bc
	xor a
	ld (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 3), a
	ld (ix + FAT_IDX_INDEX_TABLE_SIZE + 3), a
	ld (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 2), a
	ld (ix + FAT_IDX_INDEX_TABLE_SIZE + 2), a
	ld a, (iy + FAT_PARTITION_BOOT_REC_SECTORS_PER_FAT + 1)
	ld (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 1), a
	ld (ix + FAT_IDX_INDEX_TABLE_SIZE + 1), a
	ld a, (iy + FAT_PARTITION_BOOT_REC_SECTORS_PER_FAT + 0)
	ld (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 0), a
	ld (ix + FAT_IDX_INDEX_TABLE_SIZE + 0), a
	ld a, (iy + FAT_PARTITION_BOOT_REC_BYTES_PER_SECTOR + 0)
	ld c, a
	ld a, (iy + FAT_PARTITION_BOOT_REC_BYTES_PER_SECTOR + 1)
	ld b, a
	ld a, (iy + FAT_PARTITION_BOOT_REC_SECTORS_PER_CLUSTER + 0)
	ld (ix + FAT_IDX_SECTORS_PER_CLUSTER + 0), a
	
	push bc
	ld b, 8
FATFS_MOUNT_CALC_SECT_LOOP1:
	ld a, (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 0)
	add a
	ld (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 0), a
	ld a, (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 1)
	adc a
	ld (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 1), a
	ld a, (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 2)
	adc a
	ld (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 2), a
	ld a, (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 3)
	adc a
	ld (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 3), a
	djnz FATFS_MOUNT_CALC_SECT_LOOP1
	pop bc
	
	ld a, (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 3)
	ld (ix + FAT_IDX_DATA_PARTITION_SIZE + 3), a
	ld a, (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 2)
	ld (ix + FAT_IDX_DATA_PARTITION_SIZE + 2), a
	ld a, (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 1)
	ld (ix + FAT_IDX_DATA_PARTITION_SIZE + 1), a
	ld a, (ix + FAT_IDX_CLUSTERS_IN_PARTITION + 0)
	ld (ix + FAT_IDX_DATA_PARTITION_SIZE + 0), a
FATFS_MOUNT_CALC_SECT_LOOP:
	srl b
	rr c
	jr c, FATFS_MOUNT_CALC_SECT_LOOP_END
	ld a, (ix + FAT_IDX_DATA_PARTITION_SIZE + 0)
	add a
	ld (ix + FAT_IDX_DATA_PARTITION_SIZE + 0), a
	ld a, (ix + FAT_IDX_DATA_PARTITION_SIZE + 1)
	adc a
	ld (ix + FAT_IDX_DATA_PARTITION_SIZE + 1), a
	ld a, (ix + FAT_IDX_DATA_PARTITION_SIZE + 2)
	adc a
	ld (ix + FAT_IDX_DATA_PARTITION_SIZE + 2), a
	ld a, (ix + FAT_IDX_DATA_PARTITION_SIZE + 3)
	adc a
	ld (ix + FAT_IDX_DATA_PARTITION_SIZE + 3), a
	jr FATFS_MOUNT_CALC_SECT_LOOP
FATFS_MOUNT_CALC_SECT_LOOP_END:
	xor a
	ld b, a
	ld a, (iy + FAT_PARTITION_BOOT_REC_RESERVED_SECTORS + 0)
	add (ix + FAT_IDX_PARTITION_OFFSET + 0)
	ld (ix + FAT_IDX_INDEX_TABLE_OFFSET + 0), a
	ld a, (iy + FAT_PARTITION_BOOT_REC_RESERVED_SECTORS + 1)
	adc (ix + FAT_IDX_PARTITION_OFFSET + 1)
	ld (ix + FAT_IDX_INDEX_TABLE_OFFSET + 1), a
	ld a, b
	adc b
	ld (ix + FAT_IDX_INDEX_TABLE_OFFSET + 2), a
	ld a, b
	adc b
	ld (ix + FAT_IDX_INDEX_TABLE_OFFSET + 3), a
	
	ld a, (ix + FAT_IDX_INDEX_TABLE_SIZE + 3)
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 3), a
	ld a, (ix + FAT_IDX_INDEX_TABLE_SIZE + 2)
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 2), a
	ld a, (ix + FAT_IDX_INDEX_TABLE_SIZE + 1)
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 1), a
	ld a, (ix + FAT_IDX_INDEX_TABLE_SIZE + 0)
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 0), a

	ld a, (ix + FAT_IDX_DATA_TABLE_OFFSET + 0)
	add a
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 0), a
	ld a, (ix + FAT_IDX_DATA_TABLE_OFFSET + 1)
	adc a
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 1), a
	ld a, (ix + FAT_IDX_DATA_TABLE_OFFSET + 2)
	adc a
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 2), a
	ld a, (ix + FAT_IDX_DATA_TABLE_OFFSET + 3)
	adc a
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 3), a
	
	ld a, (ix + FAT_IDX_DATA_TABLE_OFFSET + 0)
	add (ix + FAT_IDX_INDEX_TABLE_OFFSET + 0)
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 0), a
	ld a, (ix + FAT_IDX_DATA_TABLE_OFFSET + 1)
	adc (ix + FAT_IDX_INDEX_TABLE_OFFSET + 1)
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 1), a
	ld a, (ix + FAT_IDX_DATA_TABLE_OFFSET + 2)
	adc (ix + FAT_IDX_INDEX_TABLE_OFFSET + 2)
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 2), a
	ld a, (ix + FAT_IDX_DATA_TABLE_OFFSET + 3)
	adc (ix + FAT_IDX_INDEX_TABLE_OFFSET + 3)
	ld (ix + FAT_IDX_DATA_TABLE_OFFSET + 3), a


	
	ld e, (ix + FAT_IDX_DATA_TABLE_OFFSET + 3)
	ld d, (ix + FAT_IDX_DATA_TABLE_OFFSET + 2)
	ld l, (ix + FAT_IDX_DATA_TABLE_OFFSET + 1)
	ld h, (ix + FAT_IDX_DATA_TABLE_OFFSET + 0)
	pop iy
	pop ix
	pop bc
	ld (ix + DISK_ADDRESS + 3), h
	ld (ix + DISK_ADDRESS + 2), l
	ld (ix + DISK_ADDRESS + 1), d
	ld (ix + DISK_ADDRESS + 0), e
	DISK_READ
FATFS_MOUNT_RETURN:
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ret

