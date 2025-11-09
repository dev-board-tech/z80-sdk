
SECTION KERNEL_API_DESCRIPTOR
;-----------------------------------------------------------------------
DEFM "board\0"
DEFW _board_version
;-----------------------------------------------------------------------
DEFM "mmu\0"
DEFW _mmu_version
;-----------------------------------------------------------------------
DEFM "semaphore\0"
DEFW _semaphore_version
;-----------------------------------------------------------------------
DEFM "util\0"
DEFW _util_version
;-----------------------------------------------------------------------
DEFM "sio\0"
DEFW _sio_version
;-----------------------------------------------------------------------
DEFM "\0"
DEFW 0
;-----------------------------------------------------------------------
SECTION KERNEL_API_TABLE
_board_version: 					; 0 = Version returned in hl.
	jp board_version
_board_SetLcdRstAsserted: 			; 1
	jp board_SetLcdRstAsserted
_board_SetLcdRstDeAsserted: 		; 2
	jp board_SetLcdRstDeAsserted
_board_SelectSioaRs232: 			; 3
	jp board_SelectSioaRs232
_board_SelectSioaMouse: 			; 4
	jp board_SelectSioaMouse
_board_SelectSioaClk2: 				; 5
	jp board_SelectSioaClk2
_board_SelectSioaCtc: 				; 6
	jp board_SelectSioaCtc
;-----------------------------------------------------------------------
_mmu_version: 						; 0 = Version returned in hl.
	jp mmu_version
_mmu_AddrToBank: 					; 1
	jp mmu_AddrToBank
_mmu_BankToAddr: 					; 2
	jp mmu_BankToAddr
_mmu_Set: 							; 3
	jp mmu_Set
_mmu_Get: 							; 4
	jp mmu_Get
;-----------------------------------------------------------------------
_semaphore_version: 				; 0 = Version returned in hl.
	jp semaphore_version
_semaphore_Wait: 					; 1
	jp semaphore_Wait
_semaphore_Get: 					; 2
	jp semaphore_Get
_semaphore_Set: 					; 3
	jp semaphore_Set
_semaphore_Res: 					; 4
	jp semaphore_Clr
;-----------------------------------------------------------------------
_util_version: 						; 0 = Version returned in hl.
	jp util_version
_util_rcall: 						; 1
	jp util_rcall
_util_BitToMask8: 					; 2
	jp util_BitToMask8
;-----------------------------------------------------------------------
_sio_version: 						; 0 = Version returned in hl.
	jp sio_version
_sio_Init: 							; 1
	jp sio_Init
_sio_GetAddr: 						; 2 = b is unit nr, SIO config address returned in c.
	jp sio_GetAddr
_sio_Set: 							; 3 = c is SIO config address, d is clock divider, e is RX char size, h is TX char size.
	jp sio_Set
_sio_TxWaitEmpty: 					; 4 = c is SIO config address.
	jp sio_TxWaitEmpty
_sio_ReadCBlocking: 				; 5 = c is SIO config address, a return received character.
	jp sio_ReadCBlocking
_sio_ReadCNonBlocking: 				; 6 = c is SIO config address, a return received character, z is true if a character is received.
	jp sio_ReadCNonBlocking
_sio_SendC: 						; 7 = c is SIO config address, a is the character to be send.
	jp sio_SendC
_sio_PrintStr: 						; 8 = c is SIO config address, hl is the string to be send '\0' terminated.
	jp sio_PrintStr
_sio_PrintHHexChar: 				; 9 = c is SIO config address, a is the byte to be send as high hex.
	jp sio_PrintHHexChar
_sio_PrintHHexBuf: 					; 10 = c is SIO config address, de is buffer len, hl is buffer address, will be send as high hex string.
	jp sio_PrintHHexBuf


