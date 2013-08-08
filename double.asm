
	li	r2, 0xffff
	li	r3, 0xffff

	li	r4, 0
	li	r5, 1

	add	r7, r3, r5
	sltu	r6, r7, r3
	add	r6, r6, r4
	add	r6, r6, r2


	sub	r9, r3, r5
	sub	r8, r2, r4
	sltu	r1, r3, r5
	sub	r8, r8, r1

