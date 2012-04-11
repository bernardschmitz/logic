
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
buffer:		equ	0a000
bufferlen:	equ	000ff

        define(id, 0)dnl
        define(l, {$1{}id})dnl
	define(nl, {define({id}, incr(id))})dnl

	define(LINK, 0)dnl


; tos r8
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
	sw	r14, zero, var_s0

	li	r10, yeah
	NEXT
	halt

yeah:	dw	TEST5, HALT

	DEFWORD(test, 0, TEST)
	dw LIT, 0cafe, LIT, 0babe, OVER, EXIT

	DEFWORD(test0, 0, TEST0)
	dw LIT, 0cafe, LIT, 0babe, LIT, 010, ROT, EXIT

	DEFWORD(test2, 0, TEST2)
	dw LIT, 0a, LIT, 01000, STORE, LIT, 01, LIT, 01000, PLUS_STORE, EXIT
	
	DEFWORD(test3, 0, TEST3)
	dw STATE, FETCH, VERSION, BASE, FETCH, EXIT

	DEFWORD(test4, 0, TEST4)
	dw LIT, 01000, LIT, 0a, ACCEPT, EXIT

	DEFWORD(test5, 0, TEST5)
	dw LIT, 05, LIT, msg, LIT, 01a, TYPE, CR, ONE_MINUS, DUP, LIT, 0, EQUALS, ZBRANCH, -0c, EXIT

msg:	dw"Hi there",02c," this is bsforth!"


	DEFCODE(halt, 0, HALT)
	halt

	DEFCODE(drop, 0, DROP)
	inc	r14
	lw	r8, r14, 0
	NEXT

	DEFCODE(swap, 0, SWAP)
	move	r1, r8
	lw	r8, r14, 0
	sw	r1, r14, 0
	NEXT

	DEFCODE(dup, 0, DUP)
	PUSHDSP(r8)
	NEXT

	DEFCODE(over, 0, OVER)
	PUSHDSP(r8)
	lw	r8, r14, 1
	NEXT

	DEFCODE(rot, 0, ROT)
	lw	r1, r14, 1
	lw	r2, r14, 0
	sw	r2, r14, 1
	sw	r8, r14, 0
	move	r8, r1
	NEXT

	DEFCODE(2drop, 0, TWODROP)
	lw	r8, r14, 1
	addi	r14, r14, 2
	NEXT

	DEFCODE(2dup, 0, TWODUP)
	lw	r1, r14, 0
	sw	r8, r14, -1
	sw	r1, r14, -2
	addi	r14, r14, -2
	NEXT

	DEFCODE(2swap, 0, TWOSWAP)
	move	r1, r8
	lw	r8, r14, 1
	sw	r1, r14, 1
	lw	r1, r14, 0
	lw	r2, r14, 2
	sw	r1, r14, 2
	sw	r2, r14, 0
	NEXT

	DEFCODE(?dup, 0, QUESTION_DUP)
	beq	r8, zero, qdup0
	PUSHDSP(r8)
qdup0:
	NEXT

	DEFCODE(1+, 0, ONE_PLUS)
	inc	r8
	NEXT

	DEFCODE(1-, 0, ONE_MINUS)
	dec	r8
	NEXT

	DEFCODE(+, 0, PLUS)
	lw	r1, r14, 0
	add	r8, r8, r1
	inc	r14
	NEXT

	DEFCODE(-, 0, MINUS)
	lw	r1, r14, 0
	sub	r8, r8, r1
	inc	r14
	NEXT

	DEFCODE(*, 0, STAR)
	lw	r1, r14, 0
	mul	r8, r8, r1
	inc	r14
	NEXT

	DEFCODE(/, 0, SLASH)
	lw	r1, r14, 0
	div	r8, r8, r1
	inc	r14
	NEXT
	
	
	DEFCODE(/mod, 0, SLASH_MOD)
	lw	r1, r14, 0
	div	r8, r8, r1
	mfhi	r1
	sw	r1, r14, 0
	NEXT

	DEFCODE(invert, 0, INVERT)
	not	r8
	NEXT

	DEFCODE(=, 0, EQUALS)
	clear	r1
	lw	r2, r14, 0
	bne	r8, r2, equals0
	not	r1
equals0:
	inc	r14
	move	r8, r1
	NEXT


	DEFWORD(<>, 0, NOT_EQUALS)
	dw EQUALS, INVERT, EXIT

	DEFCODE(exit, 0, EXIT)
	POPRSP(r10)
	NEXT

	DEFCODE(lit, 0, LIT)
	PUSHDSP(r8)
	lw	r8, r10, 0
	inc	r10
	NEXT

	DEFCODE(!, 0, STORE)
	lw	r1, r14, 0
	sw	r1, r8, 0
	lw	r8, r14, 1
	addi	r14, r14, 2
	NEXT

	DEFCODE(@, 0, FETCH)
	lw	r8, r8, 0
	NEXT

	DEFCODE(+!, 0, PLUS_STORE)
	lw	r1, r8, 0
	lw	r2, r14, 0
	add	r1, r1, r2
	sw	r1, r8, 0
	lw	r8, r14, 1
	addi	r14, r14, 2
	NEXT


	define(DEFVAR, {
	DEFCODE($1, $2, $3)
	PUSHDSP(r8)
	li	r8, var_$1
	NEXT
var_$1:	dw	$4
	})dnl


	DEFVAR(state, 0, STATE, 0)
	DEFVAR(here, 0, HERE, 0)
	DEFVAR(latest, 0, LATEST, 0)
	DEFVAR(s0, 0, SZ, 0)
	DEFVAR(base, 0, BASE, 0a)


	define(DEFCONST, {
	DEFCODE($1, $2, $3)
	PUSHDSP(r8)
	li	r8, $4
	NEXT
	})dnl

	DEFCONST(version, 0, VERSION, 1)
	DEFCONST(r0, 0, RZ, return_stack)
	DEFCONST(docol, 0, _DOCOL, DOCOL)
	DEFCONST(bl, 0, BL, 020)

	DEFCODE(cr, 0, CR)
	li	r1, newline
	sw	r1, zero, charout
	NEXT

	DEFCODE(>r, 0, TO_R)
	PUSHRSP(r8)
	POPDSP(r8)
	NEXT

	DEFCODE(r>, 0, FROM_R)
	PUSHDSP(r8)
	POPRSP(r8)
	NEXT

	DEFCODE(key?, 0, KEY_QUESTION)
	PUSHDSP(r8)
	clear	r8
	lw	r1, zero, charrdy
	beq	r1, zero, _keyq0
	not	r8
_keyq0:
	NEXT


	DEFCODE(key, 0, KEY)
	PUSHDSP(r8)
	jal	r15, _key
	move	r8, r1
	NEXT
_key:
	lw	r1, zero, charrdy
	beq	r1, zero, _key
	lw	r1, zero, charin
	jr	r15


	DEFCODE(emit, 0, EMIT)
	sw	r8, zero, charout
	POPDSP(r8)
	NEXT

delete:		equ 08
newline:	equ 0a

	DEFCODE(accept, 0, ACCEPT)
	move	r1, r8
	lw	r2, r14, 0
	jal	r15, _accept
	move	r8, r1
	inc	r14
	NEXT
_accept:
	move	r9, r15			; save return address
	move	r3, r1			; save max count
	clear	r4			; zero char count
	li	r5, newline		; eol char
	li	r6, delete		; bs char
_accept0:
	jal	r15, _key		; get key code in r1
	sw	r1, zero, charout	; output char
	beq	r1, r5, eol0		; is it eol char?

	beq	r1, r6, bs0		; is it bs char?

	sw	r1, r2, 0		; store char
	inc	r4			; count char
	inc	r2			; inc buffer address
	dec	r3			; decr max count
	bne	r3, zero, _accept0	; if not collect max chars then fetch again
eol0:
	move	r1, r4			; save actual char count
	jr	r9			; return
bs0:
	beq	r4, zero, _accept0	; ignore bs if first key
	dec	r4			; backspace buffer
	dec	r2
	inc	r3
	j	_accept0		; continue



	DEFCODE(source, 0, SOURCE)
	sw	r8, r14, -1
	li	r1, buffer
	sw	r1, r14, -2
	li	r8, bufferlen
	addi	r14, r14, -2
	NEXT


	DEFCODE(type, 0, TYPE)
	move	r1, r8
	lw	r2, r14, 0
	lw	r8, r14, 1
	addi	r14, r14, 2

	jal	r15, _type
	NEXT
_type:
	beq	r1, zero, _type0
_type1:
	lw	r3, r2, 0
	sw	r3, zero, charout
	inc	r2
	dec	r1
	bne	r1, zero, _type1
_type0:
	jr	r15

	DEFCODE(parse, 0, PARSE)
	move	r1, r8
	jal	r15, _parse
	move	r8, r1
	PUSHDSP(r2)
	NEXT
_parse:
	; TODO
	halt




	DEFCODE(branch, 0, BRANCH)
	lw	r1, r10, 0
	add	r10, r10, r1
	NEXT	


	DEFCODE(0branch, 0, ZBRANCH)
	move	r1, r8
	POPDSP(r8)
	beq	r1, zero, code_BRANCH
	inc	r10
	NEXT




