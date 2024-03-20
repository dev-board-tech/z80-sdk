IFNDEF UTIL_H
DEFINE UTIL_H

MACRO RCALL callAddr
	ld de, callAddr - thisAddr
	jp util_rcall
thisAddr:
ENDM

MACRO rcall callAddr
	ld de, callAddr - thisAddr
	jp util_rcall
thisAddr:
ENDM



ENDIF
