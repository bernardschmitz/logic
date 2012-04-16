
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
	ds "$1"
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
	ds "$1"
	align
$3:
	dw	code_$3
	align
code_$3:
	})dnl




start:

	li	r13, return_stack
	li	r14, data_stack
	sw	r14, zero, var_SZ

	li	r10, yeah
	NEXT
	halt

yeah:	dw	TEST8, HALT

	DEFWORD(test, 0, TEST)
	dw LIT, 0cafe, LIT, 0babe, OVER, EXIT

	DEFWORD(test0, 0, TEST0)
	dw LIT, 0cafe, LIT, 0babe, LIT, 010, ROT, EXIT

	DEFWORD(test2, 0, TEST2)
	dw LIT, 0a, LIT, 01000, STORE, LIT, 01, LIT, 01000, PLUS_STORE, EXIT
	
	DEFWORD(test3, 0, TEST3)
	dw STATE, FETCH, VERSION, BASE, FETCH, EXIT

	DEFWORD(test4, 0, TEST4)
	dw LIT, buffer, LIT, 00ff, ACCEPT, LIT, 0, TO_IN, STORE
	dw BL, PARSE, CR, TYPE
	dw BL, PARSE, CR, TYPE
	dw BL, PARSE, CR, TYPE
	dw CR, EXIT

	DEFWORD(test5, 0, TEST5)
	dw LIT, 05, LIT, msg, LIT, 01a, TYPE, CR, ONE_MINUS, DUP, LIT, 0, EQUALS, ZBRANCH, -0c, EXIT
msg:	ds "Hi there, this is bsforth!"


	DEFWORD(test6, 0, TEST6)
	dw	LIT, buffer, LIT, 00ff, ACCEPT, LIT, 0, TO_IN, STORE
	dw	BL, PARSE, CR, TYPE
	dw	EXIT

	DEFWORD(test7, 0, TEST7)
	dw	LIT, 02a, LIT, EMIT, EXECUTE, EXIT


	DEFWORD(test8, 0, TEST8)
	dw	BINARY, LIT, num, LIT, 0c, NUMBER, HALT
num:	ds	"001100000101"



	DEFWORD(test9, 0, TEST9)
	dw	LIT, msg1, LIT, 5, TYPE, EXIT
msg1:	ds	"sheep"



	DEFCODE(halt, 0, HALT)
	halt

	DEFCODE(drop, 0, DROP)
	inc	r14
	NEXT

	DEFCODE(swap, 0, SWAP)
	lw	r2, r14, 0
	lw	r3, r14, 1

	sw	r3, r14, 0
	sw	r2, r14, 1
	NEXT

	DEFCODE(dup, 0, DUP)
	lw	r2, r14, 0
	PUSHDSP(r2)
	NEXT

	DEFCODE(over, 0, OVER)
	lw	r2, r14, 1
	PUSHDSP(r2)
	NEXT

	DEFCODE(rot, 0, ROT)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r14, 2

	sw	r4, r14, 0
	sw	r2, r14, 1
	sw	r3, r14, 2	
	NEXT

	DEFCODE(2drop, 0, TWODROP)
	addi	r14, r14, 2
	NEXT

	DEFCODE(2dup, 0, TWODUP)
	lw	r2, r14, 0
	lw	r3, r14, 1
	addi	r14, r14, -2
	sw	r2, r14, 0
	sw	r3, r14, 1
	NEXT

	DEFCODE(2swap, 0, TWOSWAP)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r14, 2
	lw	r5, r14, 3

	sw	r4, r14, 0
	sw	r5, r14, 1
	sw	r2, r14, 2
	sw	r3, r14, 3
	NEXT

	DEFCODE(?dup, 0, QUESTION_DUP)
	lw	r2, r14, 0
	beq	r2, zero, qdup0
	PUSHDSP(r2)
qdup0:
	NEXT

	DEFCODE(1+, 0, ONE_PLUS)
	lw	r2, r14, 0
	inc	r2
	sw	r2, r14, 0
	NEXT

	DEFCODE(1-, 0, ONE_MINUS)
	lw	r2, r14, 0
	dec	r2
	sw	r2, r14, 0
	NEXT

	DEFCODE(+, 0, PLUS)
	lw	r2, r14, 0
	lw	r3, r14, 1
	add	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(-, 0, MINUS)
	lw	r2, r14, 0
	lw	r3, r14, 1
	sub	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(*, 0, STAR)
	lw	r2, r14, 0
	lw	r3, r14, 1
	mul	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(/, 0, SLASH)
	lw	r2, r14, 0
	lw	r3, r14, 1
	div	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT
	
	
	DEFCODE(/mod, 0, SLASH_MOD)
	lw	r2, r14, 0
	lw	r3, r14, 1
	div	r2, r2, r3
	mfhi	r3
	sw	r2, r14, 0
	sw	r3, r14, 1
	NEXT

	DEFCODE(invert, 0, INVERT)
	lw	r2, r14, 0
	not	r2
	sw	r2, r14, 0
	NEXT

	DEFCODE(=, 0, EQUALS)
	clear	r2
	lw	r3, r14, 0
	lw	r4, r14, 1
	bne	r3, r4, equals0
	not	r2
equals0:
	inc	r14
	sw	r2, r14, 0
	NEXT


	DEFWORD(<>, 0, NOT_EQUALS)
	dw EQUALS, INVERT, EXIT

	DEFCODE(exit, 0, EXIT)
	POPRSP(r10)
	NEXT

	DEFCODE(lit, 0, LIT)
	lw	r2, r10, 0
	inc	r10
	PUSHDSP(r2)
	NEXT

	DEFCODE(!, 0, STORE)
	lw	r2, r14, 0
	lw	r3, r14, 1
	sw	r3, r2, 0
	addi	r14, r14, 2
	NEXT

	DEFCODE(@, 0, FETCH)
	lw	r2, r14, 0
	lw	r2, r2, 0
	sw	r2, r14, 0
	NEXT

	DEFCODE(+!, 0, PLUS_STORE)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r2, 0
	add	r4, r4, r3
	sw	r4, r2, 0
	addi	r14, r14, 2
	NEXT


	define(DEFVAR, {
	DEFCODE($1, $2, $3)
	li	r2, var_$3
	PUSHDSP(r2)
	NEXT
var_$3:	dw	$4
	})dnl


	DEFVAR(state, 0, STATE, 0)
	DEFVAR(here, 0, HERE, 0)
	DEFVAR(latest, 0, LATEST, 0)
	DEFVAR(s0, 0, SZ, 0)
	DEFVAR(base, 0, BASE, 0a)
	DEFVAR(>in, 0, TO_IN, bufferlen)

	DEFWORD(binary, 0, BINARY)
	dw	LIT, 02, BASE, STORE, EXIT

	DEFWORD(octal, 0, OCTAL)
	dw	LIT, 08, BASE, STORE, EXIT

	DEFWORD(hex, 0, HEX)
	dw	LIT, 010, BASE, STORE, EXIT

	DEFWORD(decimal, 0, DECIMAL)
	dw	LIT, 0a, BASE, STORE, EXIT



	define(DEFCONST, {
	DEFCODE($1, $2, $3)
	li	r2, $4
	PUSHDSP(r2)
	NEXT
	})dnl

	DEFCONST(version, 0, VERSION, 1)
	DEFCONST(r0, 0, RZ, return_stack)
	DEFCONST(docol, 0, _DOCOL, DOCOL)

blank:	equ	020

	DEFCONST(bl, 0, BL, blank)

	DEFCODE(space, 0, SPACE)
	li	r2, blank
	sw	r2, zero, charout
	NEXT

	DEFCODE(cr, 0, CR)
	li	r2, newline
	sw	r2, zero, charout
	NEXT

	DEFCODE(>r, 0, TO_R)
	POPDSP(r2)
	PUSHRSP(r2)
	NEXT

	DEFCODE(r>, 0, FROM_R)
	POPRSP(r2)
	PUSHDSP(r2)
	NEXT

	DEFCODE(key?, 0, KEY_QUESTION)
	clear	r2
	lw	r3, zero, charrdy
	beq	r3, zero, _keyq0
	not	r2
_keyq0:
	PUSHDSP(r2)
	NEXT


	DEFCODE(key, 0, KEY)
	jal	r15, _key
	PUSHDSP(r2)
	NEXT
_key:
	lw	r2, zero, charrdy
	beq	r2, zero, _key
	lw	r2, zero, charin
	jr	r15


	DEFCODE(emit, 0, EMIT)
	POPDSP(r2)
	sw	r2, zero, charout
	NEXT

delete:		equ 008
newline:	equ 00a

	DEFCODE(accept, 0, ACCEPT)
	lw	r2, r14, 0
	lw	r3, r14, 1
	jal	r15, _accept
	inc	r14
	sw	r2, r14, 0
	NEXT
_accept:
	move	r9, r15			; save return address
	move	r4, r2			; save max count
	clear	r5			; zero char count
	li	r6, newline		; eol char
	li	r7, delete		; bs char
_accept0:
	jal	r15, _key		; get key code in r1
	beq	r2, r6, eol0		; is it eol char?
	beq	r2, r7, bs0		; is it bs char?
	beq	r4, zero, lim0		; have we reached the char limit?

	sw	r2, zero, charout	; output char
	sw	r2, r3, 0		; store char
	inc	r5			; count char
	inc	r2			; inc buffer address
	dec	r4			; decr max count
	j	_accept0		; get next char
lim0:
	sw	r7, zero, charout
	sw	r2, zero, charout	; output char
	sw	r2, r3, -1
	j	_accept0		; get next char
eol0:
	move	r2, r5			; save actual char count
	jr	r9			; return
bs0:
	beq	r5, zero, _accept0	; ignore bs if first key
	sw	r7, zero, charout
	dec	r5			; backspace buffer
	dec	r3
	inc	r4
	j	_accept0		; continue



;	DEFCODE(source, 0, SOURCE)
;	sw	r8, r14, -1
;	li	r1, buffer
;	sw	r1, r14, -2
;	li	r8, bufferlen
;	addi	r14, r14, -2
;	NEXT


	DEFCODE(type, 0, TYPE)
	lw	r2, r14, 0
	beq	r2, zero, _type1
	lw	r3, r14, 1
	jal	r15, _type
_type1:
	addi	r14, r14, -2
	NEXT
_type:
	lw	r4, r3, 0
	sw	r4, zero, charout
	inc	r3
	dec	r2
	bne	r2, zero, _type
	jr	r15



	DEFCODE(parse, 0, PARSE)
	lw	r2, r14, 0
	jal	r15, _parse
	sw	r3, r14, 0
	PUSHDSP(r2)
	NEXT
_parse:
	li	r4, bufferlen
	lw	r3, zero, var_TO_IN
	move	r6, r3
	beq	r3, r4, _parse_empty

_parse_more:
	lw	r5, r3, buffer
	inc	r3
	beq	r5, r2, _parse_done
	bne	r3, r4, _parse_more

_parse_done:
	sw	r3, zero, var_TO_IN
	sub	r2, r3, r6		; length of parsed string
	li	r7, buffer
	add	r3, r7, r6		; address of start of parsed string
	jr	r15	

_parse_empty:
	clear	r2
	li	r3, buffer
	add	r3, r3, r4
	jr	r15



	DEFCODE(execute, 0, EXECUTE)
	POPDSP(r2)
	jr	r2


	DEFCODE(@execute, 0, FETCH_EXECUTE)
	POPDSP(r2)
	lw	r3, r2, 0
	beq	r3, zero, exec_skip
	jr	r3
exec_skip:
	NEXT


	DEFCODE(branch, 0, BRANCH)
	lw	r2, r10, 0
	add	r10, r10, r2
	NEXT	


	DEFCODE(0branch, 0, ZBRANCH)
	POPDSP(r2)
	beq	r2, zero, code_BRANCH
	inc	r10
	NEXT


dash:		equ 02d
ascii_zero:	equ 030
ascii_a_0:	equ 031

	DEFCODE(number, 0, NUMBER)
	lw	r2, r14, 0		; length of string
	lw	r3, r14, 1		; address of string
	jal	r15, _number
	sw	r3, r14, 0		; count of parsed chars, 0 = success
	sw	r2, r14, 1		; parsed number
	NEXT
_number:
	lw	r6, zero, var_BASE	; get number base
	clear	r7			; clear parsed number
	clear	r8
	li	r9, 09
	; TODO check minus
_num0:
	lw	r4, r3, 0		; get next character
	; TODO convert lower case

	;subi	r3, r3, ascii_zero
	addi	r4, r4, 0ffd0
	blt	r4, zero, _num_fail
	ble	r4, r9, _num1	

	;subi	r3, r3, ascii_a_0
	addi	r4, r4, 0ffcf
	blt	r4, zero, _num_fail

	addi	r4, r4, 0a

_num1:
	bge	r4, r6, _num_fail

	mul	r7, r7, r6
	add	r7, r7, r4

	inc	r8
	inc	r3
	dec	r2
	bne	r2, zero, _num0

	; TODO negate

_num_fail:
	move	r2, r7
	move	r3, r8
	jr	r15
	


	DEFWORD(quit, 0, QUIT)
	dw	LIT, buffer, DUP, LIT, 00ff, ACCEPT, SPACE, TYPE, CR, BRANCH, -0a, EXIT
	



;hex
;0f002 constant rand
;0fffe constant screen

; : randchar rand @ 01f and 020 + ;

; : randchars begin pad dup 0a + do randchar i ! loop pad 0a type again ;

	DEFCODE(and, 0, AND)
	lw	r2, r14, 0
	lw	r3, r14, 1
	and	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCONST(rand, 0, RAND, random)
	DEFCONST(charout, 0, CHAROUT, charout)


	DEFWORD(randchar, 0, RANDCHAR)
	dw	RAND, FETCH, LIT, 01f, AND, LIT, 020, PLUS, EXIT

	DEFWORD(randchars, 0, RANDCHARS)
	dw	RANDCHAR, EMIT, BRANCH, -03, EXIT

	DEFCODE(rc, 0, RC)
loop:
	lw	r2, zero, random ; get random num
	andi	r3, r2, 1f
	addi	r3, r3, 20
	sw	r3, zero, charout ; write random character
	j	loop
	NEXT

; : sum100 0 101 0 do i + loop ;
; 13ba
	DEFWORD(sum100, 0, SUM100)
	dw	LIT, 0, LIT, 064, DUP, TO_R, PLUS, FROM_R, ONE_MINUS, DUP, LIT, 0, EQUALS, ZBRANCH, -0a, DROP, EXIT


