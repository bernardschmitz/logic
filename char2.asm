
charout:	equ	0fffe
clear:		equ	0ffff

start:
	li	t0, 20		; char ascii space
	li	t1, 0b		; limit

loop:
	sw	t0, zero, charout	; write char
	inc	t0
	sw	t0, zero, charout	; write char
	inc	t0
	sw	t0, zero, charout	; write char
	inc	t0
	sw	t0, zero, charout	; write char
	inc	t0
	sw	t0, zero, charout	; write char
	inc	t0
	sw	t0, zero, charout	; write char
	inc	t0
	sw	t0, zero, charout	; write char
	inc	t0

	dec	t1
	bne	t1, zero, loop

	;sw	t0, zero, clear ; clear screen
	j	start



