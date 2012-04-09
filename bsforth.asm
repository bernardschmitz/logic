
	changequote`'changequote(`{',`}')dnl

timerlo:	equ	0f000
timerhi:	equ	0f001
random:		equ	0f002
bufferclr:	equ	0fffb
charrdy:	equ	0fffc
charin:		equ	0fffd
charout:	equ	0fffe
screenclr:	equ	0ffff

f_immediate:	equ	08000
f_hidden:	equ	00001

data_stack:	equ	08000
return_stack:	equ	09000

        define(id, 0)dnl
        define(l, {$1{}id})dnl
	define(nl, {define({id}, incr(id))})dnl

	define(LINK, 0)dnl


; i r10
; w r11
; x r12
; rsp r13
; dsp r14

	define(NEXT, {
	 lw	r11, r10, 0
	 inc	r10
;	 jr	r11
	 lw	r12, r11, 0
	 jr	r12
	})dnl


	define(PUSHRSP, {
	 dec	r13
	 sw	$1, r13, 0	
	})dnl

	define(POPRSP, {
	 lw	$1, r13, 0	
	 inc	r13
	})dnl

	define(PUSHDSP, {
	 dec	r14
	 sw	$1, r14, 0	
	})dnl

	define(POPDSP, {
	 lw	$1, r14, 0	
	 inc	r14
	})dnl

	j	start

	org	010
DOCOL:
	PUSHRSP(r10)
	inc	r11
	move	r10, r11
	NEXT


	define(DEFWORD, {
	align
name_$3:
	dw	LINK
	define({LINK}, name_$3)dnl
	dw	$2
	dw	len($1)
	dw"$1"
	align
$3:
	dw	DOCOL
	})dnl


	define(DEFCODE, {
	align
name_$3:
	dw	LINK
	define({LINK}, name_$3)dnl
	dw	$2
	dw	len($1)
	dw"$1"
	align
$3:
	dw	code_$3
	align
code_$3:
	})dnl




start:

	li	r13, return_stack
	li	r14, data_stack

	li	r1, 0babe
	PUSHDSP(r1)

	li	r10, yeah
	NEXT
	halt

yeah:	dw	TEST, HALT
;yeah:	dw	TWODUP, PLUS, TEST, HALT

	DEFWORD(test, 0, TEST)
	dw DUP, EXIT

	DEFCODE(halt, 0, HALT)
	halt

	DEFCODE(drop, 0, DROP)
	inc	r14
	NEXT

	DEFCODE(swap, 0, SWAP)
	lw	r1, r14, 0
	lw	r2, r14, 1	
	sw	r1, r14, 1
	sw	r2, r14, 0
	NEXT

	DEFCODE(dup, 0, DUP)
	lw	r1, r14, 0
	PUSHDSP(r1)
	NEXT

	DEFCODE(over, 0, OVER)
	lw	r1, r14, 1
	PUSHDSP(r1)
	NEXT

	DEFCODE(rot, 0, ROT)
	lw	r1, r14, 2
	lw	r2, r14, 1
	lw	r3, r14, 0
	sw	r1, r14, 0
	sw	r3, r14, 1
	sw	r2, r14, 2	
	NEXT

	DEFCODE(2drop, 0, TWODROP)
	addi	r14, r14, 2
	NEXT

	DEFCODE(2dup, 0, TWODUP)
	lw	r1, r14, 1
	lw	r2, r14, 0
	sw	r1, r14, -1
	sw	r2, r14, -2
	addi	r14, r14, -2
	NEXT

	DEFCODE(2swap, 0, TWOSWAP)
	lw	r1, r14, 3
	lw	r2, r14, 2
	lw	r3, r14, 1
	lw	r4, r14, 0
	sw	r3, r14, 3
	sw	r4, r14, 2
	sw	r1, r14, 1
	sw	r2, r14, 0
	NEXT

	DEFCODE(?dup, 0, QDUP)
	nl
	lw	r1, r14, 0
	beq	r1, zero, l(QDUP)
	PUSHDSP(r1)
l(QDUP):
	NEXT

	DEFCODE(1+, 0, ONE_PLUS)
	lw	r1, r14, 0
	inc	r1
	sw	r1, r14, 0
	NEXT

	DEFCODE(1-, 0, ONE_MINUS)
	lw	r1, r14, 0
	dec	r1
	sw	r1, r14, 0
	NEXT

	DEFCODE(+, 0, PLUS)
	lw	r1, r14, 0
	lw	r2, r14, 1
	add	r1, r1, r2
	inc	r14
	sw	r1, r14, 0
	NEXT

	DEFCODE(-, 0, MINUS)
	lw	r1, r14, 0
	lw	r2, r14, 1
	sub	r1, r1, r2
	inc	r14
	sw	r1, r14, 0
	NEXT

	DEFCODE(*, 0, STAR)
	lw	r1, r14, 0
	lw	r2, r14, 1
	mul	r1, r1, r2
	inc	r14
	sw	r1, r14, 0
	NEXT

	DEFCODE(/, 0, SLASH)
	lw	r1, r14, 0
	lw	r2, r14, 1
	div	r1, r1, r2
	inc	r14
	sw	r1, r14, 0
	NEXT
	
	
	DEFCODE(/mod, 0, SLASH_MOD)
	lw	r1, r14, 0
	lw	r2, r14, 1
	div	r1, r1, r2
	mfhi	r2
	sw	r2, r14, 0
	sw	r1, r14, 1
	NEXT

	DEFCODE(invert, 0, INVERT)
	lw	r1, r14, 0
	not	r1
	sw	r1, r14, 0
	NEXT

	DEFCODE(=, 0, EQUALS)
	lw	r1, r14, 0
	lw	r2, r14, 1
	clear	r3
	bne	r1, r2, l(EQUALS)	
	not	r3
l(EQUALS):
	inc	r14
	sw	r3, r14, 0
	NEXT

;	DEFCODE(<>, 0, NOT_EQUALS)
;	lw	r1, r14, 0
;	lw	r2, r14, 1
;	clear	r3
;	beq	r1, r2, l(NOT_EQUALS)	
;	not	r3
;l(NOT_EQUALS):
;	inc	r14
;	sw	r3, r14, 0
;	NEXT


	DEFCODE(exit, 0, EXIT)
	POPRSP(r10)
	NEXT


	DEFWORD(<>, 0, NOT_EQUALS)
	dw EQUALS, INVERT, EXIT

