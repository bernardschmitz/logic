
;	addi	r13, r0, 0ff
;	beq	r13, r13, k
;	halt

;	org 20
;k:	halt


	j	start

result:	
	dw	0, 0

start:
	addi	r10, r0, result
	addi	r2, r0, 45
	addi	r3, r0, 55
	
	bne	r2, r3, ok1
	halt

ok1:
	sw	r2, r10, 0
	beq	r2, r2, ok2
	halt
ok2:
	sw	r3, r10, 1
	halt

