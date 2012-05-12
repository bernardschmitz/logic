
; comment

	.word 4+5+6, 0xcafe, 0xbabe

leng:	.string	"hello"

	.word	leng * leng

	add	r1,r2,r3

	addi	r4, zero, (8+4)*7 ; yeah

	neg	r7
	bge	r2, zero, leng
	not	r4

	inc	r5
	dec	r9

	li	r8, leng

	mult	r5, r6, r7
	divd	r5, r6, r7

	ble	r2, zero, leng
	blt	r2, zero, leng
	bgt	r2, zero, leng

