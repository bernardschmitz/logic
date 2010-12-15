
; sum of even fibonacci numbers less than 4000000
; 4000000 - 003d 0900

	xor r4, r4
	xor r5, r5
	xor r0, r0
	mov #1, r1
	xor r2, r2
	mov #2, r3

loop:
	and r3, #1, r6
	bne odd
	add r3, r5
	adc r2, r4

odd:
	add r1, r3
	adc r0, r2

	cmp r2, #003d
	bcs loop


