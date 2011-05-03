
timer0:	equ	0f000
timer1:	equ	0f001

; sum 1 to 100 recursively

	sw	zero, zero, charclr	

	li	sp, stack

	lw	s0, zero, timer0
	lw	s1, zero, timer1

	li	a0, 64
#	push	a0
	jal	target
#	addi	sp, sp, 1

	;sw	v0, zero, result

	move	a0, v0
	jal	number

	lw	v0, zero, timer0
	lw	v1, zero, timer1

	sub	v0, v0, s0
	sub	v1, v1, s1

	move	a0, v0
	jal	number

	move	a0, v1
	jal	number
	
	li	at, 0a
	sw	at, zero, charout


; iterate

	lw	s0, zero, timer0
	lw	s1, zero, timer1

	li	a1, 64
	clear	a0

loop:
	add	a0, a0, a1
	dec	a1
	bne	a1, zero, loop

	jal	number

	lw	v0, zero, timer0
	lw	v1, zero, timer1

	sub	v0, v0, s0
	sub	v1, v1, s1

	move	a0, v0
	jal	number

	move	a0, v1
	jal	number
	
	li	at, 0a
	sw	at, zero, charout

	

	halt

	dw 0a0a0
result: dw 0ffff, 0a0a0


target:
	addi	sp, sp, -3
	sw	fp, sp, 0
	sw	ra, sp, 1
	sw	a0, sp, 2

	li	t0, 1
	bne	a0, t0, notone

	#li	v0, 1
	move	v0, t0
	j	out
	
notone:
	#sw	a0, sp, 2
	addi	a0, a0, -1
#	push	a0
	jal	target
#	addi	sp, sp, 1

	lw	a0, sp, 2
	add	v0, v0, a0

out:
	lw	fp, sp, 0
	lw	ra, sp, 1
	addi	sp, sp, 3
	jr	ra
	


;---------------


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

	li	at, 20
	sw	at, zero, charout

	jr	ra	

	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
buf:	dw	0




	dw 0cafe, 0babe

	org 1000
stack:

	dw 0cafe, 0babe

