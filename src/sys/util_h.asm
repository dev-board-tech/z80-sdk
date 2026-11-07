IFNDEF UTIL_H
DEFINE UTIL_H

MACRO RCALL callAddr
LOCAL thisAddr
	ld de, callAddr - thisAddr
	call util_rcall
thisAddr:
ENDM

MACRO rcall callAddr
LOCAL thisAddr
	ld de, callAddr - thisAddr
	call util_rcall
thisAddr:
ENDM

MACRO ICALL callAddr
LOCAL thisAddr
	push iy
	ld iy, thisAddr
	push iy
	jp (callAddr)
thisAddr:
	pop iy
ENDM

MACRO icall callAddrReg
LOCAL thisAddr
	push iy
	ld iy, thisAddr
	push iy
	jp (callAddrReg)
thisAddr:
	pop iy
ENDM



ENDIF
