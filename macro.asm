
charout:	equ	0fffe
clear:		equ	0ffff

	define(`cout', `
	sw	t0, zero, charout	; write char
	inc	t0
	')

start:
	li	t0, 20		; char ascii space
	li	t1, 0b		; limit

loop:
	cout
	cout
	cout
	cout
	cout
	cout
	cout

	dec	t1
	bne	t1, zero, loop

;	sw	t0, zero, clear ; clear screen
	j	start



