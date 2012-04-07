
	changequote`'changequote(`{',`}')dnl

timerlo:	equ	0f000
timerhi:	equ	0f001
random:		equ	0f002
bufferclr:	equ	0fffb
charrdy:	equ	0fffc
charin:		equ	0fffd
charout:	equ	0fffe
screenclr:	equ	0ffff

        define(id, 0)dnl
        define(l, {$1{}id})dnl
	define(nl, {define({id}, incr(id))})dnl

        define(clr, {
	sw	zero, zero, screenclr	; clear screen
	})dnl

        define(cout, {nl
l(loop):	 lw	at, $1, 0
	beq	at, zero, l(out)
	sw	at, zero, charout
	inc	$1
	j	l(loop)
l(out):	nop
	})dnl



	li	a0, 064
	jal	number
	jal	print
	halt

	
	org	0e000

	align
print:
	cout(a0)
	jr	ra


ten:	equ	0a

	align
number:
	li	t0, ten
	li	a1, buf
	move	t1, a0
again:
	dec	a1
	div	t1, t0
	mflo	t1
	mfhi	t2
	addi	at, t2, 30
	sw	at, a1, 0
	bne	t1, zero, again
	move	a0, a1
	jr	ra	

	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
buf:	dw	0

	align



