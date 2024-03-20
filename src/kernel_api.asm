
SECTION KERNEL_API_DESCRIPTOR
;-----------------------------------------------------------------------
DEFM "board\n"
DEFW _board_version
;-----------------------------------------------------------------------
DEFM "mmu\n"
DEFW _mmu_version
;-----------------------------------------------------------------------
DEFM "semaphore\n"
DEFW _semaphore_version
;-----------------------------------------------------------------------
DEFM "util\n"
DEFW _util_version
;-----------------------------------------------------------------------
DEFM "sio\n"
DEFW _sio_version
;-----------------------------------------------------------------------
DEFM "\0"
;-----------------------------------------------------------------------
SECTION KERNEL_API_TABLE
_board_version: 			; 0
	jp board_version
_board_SetLcdRstAsserted: 		; 1
	jp board_SetLcdRstAsserted
_board_SetLcdRstDeAsserted: 		; 2
	jp board_SetLcdRstDeAsserted
_board_SelectSioaRs232: 		; 3
	jp board_SelectSioaRs232
_board_SelectSioaMouse: 		; 4
	jp board_SelectSioaMouse
_board_SelectSioaClk2: 			; 5
	jp board_SelectSioaClk2
_board_SelectSioaCtc: 			; 0
	jp board_SelectSioaCtc
;-----------------------------------------------------------------------
_mmu_version: 				; 0
	jp mmu_version
_mmu_AddrToBank: 			; 1
	jp mmu_AddrToBank
_mmu_BankToAddr: 			; 2
	jp mmu_BankToAddr
_mmu_Set: 				; 3
	jp mmu_Set
_mmu_Get: 				; 4
	jp mmu_Get
;-----------------------------------------------------------------------
_semaphore_version: 			; 0
	jp semaphore_version
_semaphore_Wait: 			; 1
	jp semaphore_Wait
_semaphore_Get: 			; 2
	jp semaphore_Get
_semaphore_Set: 			; 3
	jp semaphore_Set
_semaphore_Res: 			; 4
	jp semaphore_Clr
;-----------------------------------------------------------------------
_util_version: 				; 0
	jp util_version
_util_rcall: 				; 1
	jp util_rcall
_util_BitToMask8: 			; 2
	jp util_BitToMask8
;-----------------------------------------------------------------------
_sio_version: 				; 0
	jp sio_version
_sio_Init: 				; 1
	jp sio_Init
_sio_GetAddr: 				; 2
	jp sio_GetAddr
_sio_Set: 				; 3
	jp sio_Set
_sio_TxWaitEmpty: 			; 4
	jp sio_TxWaitEmpty
_sio_ReadCBlocking: 			; 5
	jp sio_ReadCBlocking
_sio_ReadCNonBlocking: 			; 6
	jp sio_ReadCNonBlocking
_sio_SendC: 				; 7
	jp sio_SendC


