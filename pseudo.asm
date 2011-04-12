
	mul v0, v1, a0
	div v0, v1, a0
	li t2, 23
	push fp
	pop	s1

	bgt r2,r3,yeah
	blt r2,r3,yeah
	bge r2,r3,yeah
	ble r2,r3,yeah

	clear t2
okay:
	move r4, v1

	nop

	bgt r6, sp, okay

	j yeah
	; nop
	halt

yeah:nop
	halt

