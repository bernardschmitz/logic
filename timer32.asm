
	lw	t0, zero, 0f000

	li	a0, 0ff
loop:
	dec	a0
	bne	a0, zero, loop

	lw	t1, zero, 0f000
	sub	t2, t1, t0
	sw	t2, zero, result

	li	s0, 0ff
	div	t2, s0
	mflo	s0
	sw	s0, zero, per 
	mfhi	s1
	sw	s1, zero, perr 

	halt

	dw 0cafe, 0babe
result: dw 0
per:	dw 0
perr:	dw 0

