
; sum 1 to 100 recursively

	li	sp, stack

	li	a0, 64
	push	a0

	jal	target
	addi	sp, sp, 1

	sw	v0, zero, result
	halt

	dw 0a0a0
result: dw 0ffff, 0a0a0


target:
	addi	sp, sp, -2
	sw	fp, sp, 0
	sw	ra, sp, 1	

	li	t0, 1
	bne	a0, t0, notone

	li	v0, 1
	j	out
	
notone:
	sw	a0, sp, 2
	addi	a0, a0, -1

	push	a0
	jal	target
	addi	sp, sp, 1

	lw	a0, sp, 2
	add	v0, v0, a0

out:
	lw	fp, sp, 0
	lw	ra, sp, 1
	addi	sp, sp, 2
	jr	ra
	

	dw 0cafe, 0babe

	org 1000
stack:

	dw 0cafe, 0babe
