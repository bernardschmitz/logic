
	.set	stack, 0xa000

	.set	charout, 0xfffe
	.set	charclr, 0xffff

        
        

        

        


	
	sw	zero, zero, charclr	; clear screen
	
	addi	sp, zero, stack
	addi	t0, zero, message
	
loop2:	 lw	at, t0, 0
	beq	at, zero, out2
	sw	at, zero, charout
	addi	t0, t0, 1
	j	loop2
out2:	
	

	addi	a0, zero, zero
;	li	a0, 0cafe
forever:
	jal	ra, number
	;li	at, 0a
	addi	at, zero, 0x20
	sw	at, zero, charout
	addi	a0, a0, 1
	j	forever

	halt



message:	.string "Hello counting"
		.word 0x21, 0xa, 0xa, 0

w:	.string "Yeah yeah this is awesome."
	.word 0

	.align

number:
	addi	t0, zero, 0xa
	addi	a1, zero, buf
	add	t1, zero, a0
again:
	addi	a1, a1, -1
	div	t1, t0
	mflo	t1
	mfhi	t2
	addi	at, t2, 0x30
	sw	at, a1, 0
	;sw	at, zero, charout
	bne	t1, zero, again

	
loop3:	 lw	at, a1, 0
	beq	at, zero, out3
	sw	at, zero, charout
	addi	a1, a1, 1
	j	loop3
out3:	
	

	jr	ra	

	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
buf:	.word	0


