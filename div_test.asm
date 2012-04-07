
	j	start

quo:
	dw	0
rem:
	dw	0

start:

	li	r1, 64
	li	r2, 3
	div	r1, r2
	mflo	r4
	sw	r4, zero, quo
	mfhi	r3
	sw	r3, zero, rem

	halt

