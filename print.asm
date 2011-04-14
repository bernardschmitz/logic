
	sw	zero, zero, 0ffff	; clear screen

	li	t0, count
	clear	t1
loop:
	lw	t2, t1, message
	sw	t2, zero, 0fffe
	inc	t1

	blt	t1, t0, loop

	halt


count:	dw 12
message:	dw "Hello Sheep!"

