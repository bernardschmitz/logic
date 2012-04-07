
stack:		equ	0a000

charout:	equ	0fffe
charclr:	equ	0ffff

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


#	clr
#	li	sp, stack
#	li	t0, message
#	cout(t0)

#	clear	a0
	li	a0, 0cafe
forever:
	jal	number
	#li	at, 0a
#	li	at, 020
#	sw	at, zero, charout
#	inc	a0
#	j	forever

	halt



message:	dw "Hello counting", 021, 0a, 0a, 0

w:	dw "Yeah yeah this is awesome.", 0

	align

number:
	li	t0, 0a
	li	a1, buf
	move	t1, a0
again:
	dec	a1
	div	t1, t0
	mflo	t1
	mfhi	t2
	addi	at, t2, 30
	sw	at, a1, 0
	#sw	at, zero, charout
	bne	t1, zero, again

	cout(a1)

	jr	ra	

	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
buf:	dw	0

	dw	0cafe, 0babe

