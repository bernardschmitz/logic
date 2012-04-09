
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
	inc	r12
	move	r10, r12
	NEXT



start:
	halt



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


