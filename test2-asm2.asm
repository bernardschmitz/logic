

	.set	leng, 0b111

	add	r0, r0, r0
loop:
;	li	r2, 0x10
	addi	r2, zero, 0x10
	addi	r2, r2, leng
	sw	r2, zero, result

	j	loop

	j	0435

	jal	ra, 0xdddd
	jalr	ra, r10

	halt

	mul	r4, r5
	div	r6, r7

	brk

	mfhi	r8
	mflo	r9

result:	.word	0xbeef
	.word blah

	bne	r1, r0, loop
	beq	r1, r0, loop

	.set						blah	,			0b10101010101
