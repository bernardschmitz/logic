
screen: equ	0a000

	li	t1, 0ffff
again:
	li	t2, 1f

loop:
	sw	t1, t2, screen
	dec	t2
	bge	t2, zero, loop

	sll	t1, t1, 1

	j	again

	halt


