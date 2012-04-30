
	.org	0x04+1
	.align

	.word	-1, 2*8, 30/2

leng:
	.word	leng

	halt

	jr	r4


	addi	r2, r8, leng*2

