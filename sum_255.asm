
	add	r2, r0, r0	; zero sum
	addi	r3, r0, 0ff	; counter
	add	r4, r0, r0	; storage of partial sums
loop:
	add	r2, r2, r3
	sw	r2, r4, partial
	addi	r4, r4, 1

	addi	r3, r3, -1
	bne	r3, r0, loop

	sw	r2, r0, result
	halt

	dw 0ffff
result:	dw 0ffff, 0ffff 

partial:  dw 0

