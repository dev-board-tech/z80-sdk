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
	ld de, thisAddr
	push de
	jp (callAddr)
thisAddr:
ENDM

MACRO icall callAddr
LOCAL thisAddr
	ld de, thisAddr
	push de
	jp (callAddr)
thisAddr:
ENDM



ENDIF
