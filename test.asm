
; sum 1 to 100 into r2

kkk:	dw 1,2,  3,-4,5,6,7, forward, 0, 0

	org 20

start:	add	r2, r0, r0		; sum
	addi	r3, r0, 100		; max
loop:	add	r2, r2, r3		; add next num
	addi	r3, r3, -1		; dec count
	bne	r3, r3, loop		; loop if not zero
	j forward
	srav	r7, r14, r9
	halt	
forward:mul r4, r5
	mfhi		r9

xy12z3:lw r7,r0,data0
halt
; yeah
data0:	dw	34, 56;comment
dw -1, -2, -4567, 12345678, 1

dw 777, 888
align
dw 333

