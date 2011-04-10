
; sum 1 to 100 into r2

start:	add	r2, r0, r0		; sum
	addi	r3, r0, 100		; max
loop:	add	r2, r2, r3		; add next num
	addi	r3, r3, ffff		; dec count
	bne	r3, r3, loop		; loop if not zero
	halt	
	
	j forward
	mul r4, r5
	mfhi		r9

xy12z3:lw r7,r0,data0
halt
data0:	dw	34, 56

