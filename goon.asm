
; comment

	.word 4+5+6, 0xcafe, 0xbabe

leng:	.string	"hello"

	.word	leng * leng


	addi	r4, zero, (8+4)*7 ; yeah

	not	r4

	add	r1,r2,r3
