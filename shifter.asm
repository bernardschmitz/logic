
	addi	r3, r0, res
	addi	r1, r0, 1
	addi	r2, r0, 10

loop:
	sll	r1, r1, 1
	sw	r1, r3, 0
	addi	r3, r3, 1
	
	addi	r2, r2, -1
	bne	r2, r0, loop

	halt


res:	dw 0

