
; comment

	.word 4+5+6, 0xcafe, 0xbabe

leng:	.string	"xxxxxxxxxxxx hello", "yeah ####"
leng1:

	.word	leng * leng

	.align

	add	r1,r2,r3

	addi	r4, zero, (8+4)*7 ; yeah

	neg	r7
	bge	r2, zero, leng
	not	r4

	inc	r5
	dec	r9

	.org	0x100
blah:
	li	r8, leng

	mult	r5, r6, r7
	divd	r5, r6, r7

	ble	r2, zero, leng
	blt	r2, zero, leng
	bgt	r2, zero, leng
yeah:

	.set	qwerty, 45

	.set	abc, 10+20*blah

	.org	0x100*2
	.org	34+56*7

	.org	leng + 5

	.org	$+5

	.word	$

	.set	vvvv, $
	.set	xxxx, $+10

	.set	w, 1<<5
	.set	ww, 0x1000 >> 5+1
	.set	ww2, 0x1000 >> (5+1)
	.set	www, 10 % 3
	.set	w1, 0x100 | 0x110
	.set	w2, 0b1110010101 & 0b10000
	.set	w3, 0b1010 ^ 0b1010

	.set	c, ~1
	.set	cc,1<<4
	.set	ccc,cc^c

	.set	m, 8--4
	.set	m1,-w
	.set	m2,-(m1*2)
