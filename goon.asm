
; comment

	.word 4+5+6, 0xcafe, 0xbabe

leng:	.string	"hello", "yeah"

	.word	leng * leng

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
