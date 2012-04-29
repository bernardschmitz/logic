

	.set	leng, 0b111

	add	r0, r0, r0

;	li	r2, 0x10
	addi	r2, zero, 0x10
	addi	r2, r2, leng
	sw	r2, zero, result
	halt

result:	.word	0xbeef
	.word blah

