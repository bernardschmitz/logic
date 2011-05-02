

bufferclr:	equ	0fffb
charrdy:	equ	0fffc
charin:		equ	0fffd
charout:	equ	0fffe
screenclr:	equ	0ffff

        define(`id', 0)
        define(`l', `$1`'id')


        define(`clr', `define(`id', incr(id))
	sw	zero, zero, screenclr	; clear screen
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

wait:
	lw	at, zero, charrdy
	beq	at, zero, wait
	lw	at, zero, charin

	sw	at, zero, charout

	j	wait

	cout(t0, message)
	cout(t0, w)
	halt


message:	dw "Hello Sheep", 021, 0a, 0a, 0

w:	dw "Yeah yeah this is awesome.", 0

