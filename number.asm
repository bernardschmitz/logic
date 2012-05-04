
	.set	stack, 0xa000

	.set	charout, 0xfffe
	.set	charclr, 0xffff

        define(`id', 0)
        define(`l', `$1`'id')

        define(`clr', `define(`id', incr(id))
	sw	zero, zero, charclr	; clear screen
	')

        define(`cout', `define(`id', incr(id))
l(loop):	 lw	at, $1, 0
	beq	at, zero, l(out)
	sw	at, zero, charout
	inc	$1
	j	l(loop)
l(out):	nop
	')


	clr
	li	sp, stack
	li	t0, message
	cout(t0)

	clear	a0
;	li	a0, 0cafe
forever:
	jal	number
	;li	at, 0a
	li	at, 0x20
	sw	at, zero, charout
	inc	a0
	j	forever

	halt



message:	.string "Hello counting"
		.word 0x21, 0xa, 0xa, 0

w:	.string "Yeah yeah this is awesome."
	.word 0

	.align

number:
	li	t0, 0a
	li	a1, buf
	move	t1, a0
again:
	dec	a1
	div	t1, t0
	mflo	t1
	mfhi	t2
	addi	at, t2, 0x30
	sw	at, a1, 0
	;sw	at, zero, charout
	bne	t1, zero, again

	cout(a1)

	jr	ra	

	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
	.word	0,0,0,0,0,0,0,0
buf:	.word	0


