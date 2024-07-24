#include 	<p16Lf1826.inc>	
;


second 		equ 0x22
minute		equ 0x21
x1			equ	0x24
y1			equ	0x23
x2			equ 0x25
y2			equ 0x26
;***************************************
;           Program start              *
;***************************************
			org 	0x00

start		call	loop4
loop4		clrf	minute 
			movlw	5
			movwf	x2
first2		call	loop3
			movlw	7
			addwf	second ,1
			decfsz	x2
			goto	first2
			call	loop1
			return
loop3		movlw	9
			movwf	y2
first3		call	loop2
			clrf	second
			incf	minute ,1
			decfsz	y2
			goto	first3
			return
			goto	start
loop2		clrf	second 
			movlw	5
			movwf	x1
first		call	loop1
			movlw	7
			addwf	second ,1
			decfsz	x1
			goto	first
			call	loop1
			return
loop1		movlw	9
			movwf	y1
first1		incf	second ,1
			decfsz	y1
			goto	first1
			return



			end
			