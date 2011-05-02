

charout:	equ	0fffe
charclr:	equ	0ffff

        define(`id', 0)
        define(`l', `$1`'id')


        define(`clr', `define(`id', incr(id))
	sw	zero, zero, charclr	; clear screen
	')

        define(`cout', `define(`id', incr(id))
	clear	$1
l(loop):	 lw	at, $1, $2
	beq	at, zero, l(out)
	sw	at, zero, charout
	inc	$1
	j	l(loop)
l(out):	nop
	')


	clr
	cout(t0, message)

	clear	a0
forever:
	jal	number
	li	at, 0a
	sw	at, zero, charout
	inc	a0
	j	forever

	halt



message:	dw "Hello counting", 021, 0a, 0a, 0

w:	dw "Yeah yeah this is awesome.", 0

number:
	li	t0, 0a
	move	t1, a0
again:
	div	t1, t0
	mflo	t1
	mfhi	t2
	lw	at, t2, digits
	sw	at, zero, charout
	bne	t1, zero, again
	jr	ra	


digits:	dw	"0123456789"

