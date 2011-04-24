
charout:	equ	0fffe
charclr:	equ	0ffff


	macro	clr
	sw	zero, zero, charclr	; clear screen
	endm

	macro	cout, ptr, mess
	clear	ptr
loop:	 lw	at, ptr, mess
	beq	at, zero, out
	sw	at, zero, charout
	inc	ptr
	j	loop
out:	nop
	endm


	clr
	cout	t0, message
	cout	t0, w
	halt


message:	dw "Hello Sheep!", 0
w:	dw "Yeah yeah this is awesome.", 0

