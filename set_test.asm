
	addi r2, r0, result

	slti r1, r0, 5
	sw r1, r2, 1

	slti r1, r0, -5
	sw r1, r2, 2

	halt

result:	dw 0ffff, 0ffff, 0ffff, 0ffff


