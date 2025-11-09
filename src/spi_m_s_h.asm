IFNDEF SPI_S_H
DEFINE SPI_S_H
;-----------------------------------------------------------------------
; Altered:
; a, bc
;-----------------------------------------------------------------------
MACRO SPI_MASTER_INIT_MACRO pioIoCfgAddr, pioIoDatAddr, pioRamAddr, clkPinMask, mosiPinMask, misoPinMask
	PIO_DIR_INOUT_ADDR(misoPinMask, 0xFF & (clkPinMask | mosiPinMask), pioIoCfgAddr, pioRamAddr)
	PIO_SET_OUT_ADDR(0xFF & (clkPinMask | mosiPinMask), pioIoDatAddr, pioRamAddr)
ENDM

MACRO SPI_MASTER_WR pioIoCfgAddr, pioIoDatAddr, pioRamAddr, clkPinMask, mosiPinMask, misoPinMask
	ld b, (pioRamAddr + PIO_IO_MODE)
	ld c, pioIoCfgAddr
	
ENDM





ENDIF
