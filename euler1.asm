

start:
	xor r4, r4
	xor r2, r2
	mov 999, r0
	mov 3, r3
	mov 5, r5
loop:
	div r0, r3
	mov lo, r1
	cmp r1, r4
	beq count
	div r0, r5
	mov lo, r1
	cmp r1, r4
	bne skip
count:
	add r0, r2
skip:
	dec r0
	bne loop

			; r2 sum of multiples of 3 or 5 below 1000










------- const -------------


start:
	xor r2, r2
	mov 999, r0
loop:
	div r0, #3
	mov lo, r1
	cmp r1, #0
	beq count
	div r0, #5
	mov lo, r1
	cmp r1, #0
	bne skip
count:
	add r0, r2
skip:
	dec r0
	bne loop

			; r2 sum of multiples of 3 or 5 below 1000



