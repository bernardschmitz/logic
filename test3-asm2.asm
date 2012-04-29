

	add	r1, r2, r3
	addi	r4, r5, 0xcafe
	sub	r6, r7, r8
	mul	r9, r10
	div	r11, r12
	sll	r13, r14, 0xbabe
	srl	r15, r1, 0xdead
	sra	r2, r3, 0xbeef
	sllv	r4, r5, r6
	srlv	r7, r8, r9
	srav	r10, r11, r12
	beq	r13, r14, 0xcafe
	bne	r15, r1, 0xbabe
	slt	r2, r3, r4
	slti	r5, r6, 0xdead
	and	r7, r8, r9
	andi	r10, r11, 0xbeef
	or	r12, r13, r14
	ori	r15, r1, 0xcafe
	xor	r2, r3, r4
	nor	r5, r6, r7
	j	0xbabe
	jr	r8
	jal	r9, 0xdead	
	jalr	r10, r11
	lw	r12, r13, 0xbeef
	sw	r14, r15, 0xcafe
	mfhi	r1
	mflo	r2
	brk
	halt



	nop
	inc	r1
	dec	r2
	move	r3, r4
	clear	r5
	li	r6, 0xcafe
	bgt	r7, r8, 0xbabe
	blt	r9, r10, 0xdead
	bge	r11, r12, 0xbeef
	ble	r13, r14, 0xcafe
	mult	r15, r1, r2
	divd	r3, r4, r5
	not	r6
	neg	r7



