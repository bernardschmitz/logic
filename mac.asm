
	macro	blah, arg0, arg1, arg2
	clear	arg0
ok:	clear	arg1
	clear	arg2
	endm

	blah	r1, r2, r3

	nop

	blah	a2, v0, t1

	halt

