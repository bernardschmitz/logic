
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
	cout(t0, w)
	halt


message:	dw "Hello Sheep", 021, 0a, 0a, 0

w:	dw "Yeah yeah this is awesome.", 0

