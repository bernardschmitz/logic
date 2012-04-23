
	changecom
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
	dw	format({%05x}, len($1))
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
	dw	format({%05x}, len($1))
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

;yeah:	dw	INTERPRET, HALT
yeah:	dw	TEST_UDOT, HALT

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
	;dw	LIT, 02a, LIT, EMIT, EXECUTE, EXIT
	dw	LIT, TEST9, BRK, EXECUTE, EXIT


	DEFWORD(test8, 0, TEST8)
	dw	BINARY, LIT, num, LIT, 0f, NUMBER, HALT
num:	ds	"-001100000101xx"



	DEFWORD(test9, 0, TEST9)
	dw	LIT, msg1, LIT, 5, TYPE, EXIT
msg1:	ds	"sheep"


	DEFWORD(test10, 0, TEST10)
	dw	LIT, msg2, LIT, 5, FIND, TO_CFA, EXECUTE, EXIT
msg2:	ds	"test9"

	DEFWORD(test11, 0, TEST11)
	dw	LIT, msg1, LIT, 5, FIND, EXIT

	DEFWORD(hidden_test, f_hidden, HIDDEN_TEST)
	dw	TEST9, EXIT

	DEFWORD(test12, 0, TEST12)
	dw	LIT, msg3, LIT, 0b, FIND, QUESTION_DUP, ZBRANCH, 9
	dw	LIT, 02a, EMIT, CR, TO_CFA, EXECUTE, BRANCH, 7
	dw	LIT, msg3, LIT, 0b, TYPE, CR, EXIT
msg3:	ds	"hidden_test"


	DEFCODE(halt, 0, HALT)
	halt

	DEFCODE(brk, 0, BRK)
	brk
	NEXT

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
	div	r2, r3, r2
	inc	r14
	sw	r2, r14, 0
	NEXT
	
	
	DEFCODE(/mod, 0, SLASH_MOD)
	lw	r2, r14, 0
	lw	r3, r14, 1
	div	r2, r3, r2
	sw	r2, r14, 0
	mfhi	r3
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

	DEFCODE(<, 0, LESS_THAN)
	clear	r2
	lw	r3, r14, 0
	lw	r4, r14, 1
	bge	r4, r3, not_lt
	not	r2
not_lt:
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
	DEFVAR(here, 0, HERE, start_dp)
	DEFVAR(latest, 0, LATEST, name_LAST_WORD)
	DEFVAR(s0, 0, SZ, data_stack)
	DEFVAR(base, 0, BASE, 0a)
	DEFVAR(>in, 0, TO_IN, bufferlen)
	DEFVAR(#tib, 0, NUMBER_TIB, 0)

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
	DEFCONST(tib, 0, TIB, buffer)

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
	lw	r2, r14, 0		; count
	lw	r3, r14, 1		; address
	jal	r15, _accept
	inc	r14
	sw	r2, r14, 0
	NEXT
_accept:
	move	r4, r2			; save max count
	clear	r5			; zero char count
	li	r6, newline		; eol char
	li	r7, delete		; bs char
_accept0:
	lw	r2, zero, charrdy
	beq	r2, zero, _accept0
	lw	r2, zero, charin

	beq	r2, r6, eol0		; is it eol char?
	beq	r2, r7, bs0		; is it bs char?
	beq	r4, zero, lim0		; have we reached the char limit?

	sw	r2, zero, charout	; output char
	sw	r2, r3, 0		; store char
	inc	r5			; count char
	inc	r3			; inc buffer address
	dec	r4			; decr max count
	j	_accept0		; get next char
lim0:
	sw	r7, zero, charout
	sw	r2, zero, charout	; output char
	sw	r2, r3, -1
	j	_accept0		; get next char
eol0:
	move	r2, r5			; save actual char count
	jr	r15			; return
bs0:
	beq	r5, zero, _accept0	; ignore bs if first key
	sw	r7, zero, charout
	dec	r5			; backspace buffer
	dec	r3
	inc	r4
	j	_accept0		; continue





	DEFCODE(type, 0, TYPE)
	lw	r2, r14, 0
	beq	r2, zero, _type1
	lw	r3, r14, 1
	jal	r15, _type
_type1:
	addi	r14, r14, 2
	NEXT
_type:
	lw	r4, r3, 0
	sw	r4, zero, charout
	inc	r3
	dec	r2
	bne	r2, zero, _type
	jr	r15



	DEFCODE(parse, 0, PARSE)
	lw	r2, r14, 0		; delimiter
	jal	r15, _parse
	sw	r3, r14, 0		; addr
	PUSHDSP(r2)			; length
	NEXT
	; TODO enable different buffers
_parse:
	lw	r4, zero, var_NUMBER_TIB ; size of buffer
	lw	r3, zero, var_TO_IN	; get current index into buffer
	move	r6, r3			; save index
	li	r7, buffer		; load buffer address
	add	r7, r7, r3		; address of start of parsed string
	beq	r3, r4, _parse_empty

_parse_more:
	lw	r5, r3, buffer		; load char at buffer index
	inc	r3			; incr index
	beq	r5, r2, _parse_done	; char equals to delimiter?
	bne	r3, r4, _parse_more	; compare index to buffer size

_parse_done:
	sw	r3, zero, var_TO_IN	; save index
	sub	r2, r3, r6		; length of parsed string
	move	r3, r7
;	li	r7, buffer
;	add	r3, r7, r6		; address of start of parsed string
	jr	r15	

_parse_empty:
	clear	r2
	li	r3, buffer
	add	r3, r3, r4
	jr	r15



	DEFCODE(execute, 0, EXECUTE)
	POPDSP(r11)
	lw	r12, r11, 0
	jr	r12


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


minus:		equ 02d
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
	clear	r7			; clear parsed number
	clear	r8			; count of chars processed
	li	r9, 09			; store a 9 for future comparison

	clear	r12			; clear negative flag
	li	r6, minus		; load ascii minus
	lw	r4, r3, 0		; get first char
	bne	r4, r6, _pos		; is first char ascii minus sign?
	not	r12			; set negative flag

	inc	r8			; update counts and pointers
	inc	r3			
	dec	r2
	beq	r2, zero, _num_fail	; contunue?

_pos:
	lw	r6, zero, var_BASE	; get number base
_num0:
	lw	r4, r3, 0		; get next character

	;subi	r3, r3, ascii_zero
	addi	r4, r4, 0ffd0		; subtract ascii zero char
	blt	r4, zero, _num_fail	; finish if < 0
	ble	r4, r9, _num1		; skip if <= 9

	;subi	r3, r3, ascii_a_0
	addi	r4, r4, 0ffcf		; substract difference between ascii a and 0
	blt	r4, zero, _num_fail	; finish if < 0

	addi	r4, r4, 0a		; add 10

_num1:
	bge	r4, r6, _num_fail	; finish if >= base

	mul	r7, r7, r6		; multiple current number by base
	add	r7, r7, r4		; add new digit

_over:
	inc	r8			; update counters and pointers
	inc	r3
	dec	r2
	bne	r2, zero, _num0		; repeat if still got digits to process

_num_fail:
	beq	r12, zero, _not_neg	; negative flag set?

	not	r7			; negate number
	inc	r7
_not_neg:
brk
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


	DEFCODE(find, 0, FIND)
	lw	r2, r14, 0	; length
	lw	r3, r14, 1	; string address
	inc	r14
	jal	r15, _find
	sw	r2, r14, 0
	NEXT
_find:
	lw	r6, zero, var_LATEST	; address of latest word

_find_search:
	lw	r4, r6, 1		; get flags
	andi	r4, r4, f_hidden
	bne	r4, zero, _find_next	; skip if hidden

	lw	r4, r6, 2		; get name length
	bne	r4, r2, _find_next	; next if lengths don't match
	addi	r5, r6, 3		; get name address
	move	r8, r3			; addr of word to find
_find_cmp:
	lw	r1, r5, 0		; get dict char
	lw	r7, r8, 0		; get search char
	bne	r1, r7, _find_next	; skip if not equal
	inc	r5			; bump word pointers
	inc	r8
	dec	r4			; decr length
	bne	r4, zero, _find_cmp	; continue if more chars to compare
	
	; found word here
	move	r2, r6			; return dict word addr
	jr	r15

_find_next:

	lw	r6, r6, 0		; get link
	bne	r6, zero, _find_search	; done if link zero
	clear	r2			; return zero, word not found
	jr	r15


	DEFCODE(>CFA, 0, TO_CFA)
	lw	r2, r14, 0		; dictionary address
	lw	r3, r2, 2		; get length
	addi	r2, r2, 3		; get addr of name
	add	r2, r2, r3		; add length
	inc	r2			; align address
	andi	r2, r2, 0fffe
	sw	r2, r14, 0		; cfa addr on stack
	NEXT

	DEFWORD(>DFA, 0, TO_DFA)
	dw	TO_CFA, LIT, 4, PLUS, EXIT


	DEFWORD(interpret, 0, INTERPRET)
back:	dw	LIT, buffer, LIT, 00ff, ACCEPT, NUMBER_TIB, STORE, LIT, 0, TO_IN, STORE
	dw	BL, PARSE, FIND, QUESTION_DUP, ZBRANCH, 0c
	dw	SPACE, TO_CFA, EXECUTE, LIT, ok_msg, LIT, 3, TYPE, CR, BRANCH, 7
	dw	LIT, err_msg, LIT, 4, TYPE, CR
	dw	BRANCH, -023
	dw	EXIT
ok_msg:
	ds	" ok"
err_msg:
	ds	" err"


	DEFWORD(u., 0, U_DOT)
	dw	BASE, FETCH, SLASH_MOD, QUESTION_DUP, ZBRANCH, 2
	dw	U_DOT
	dw	DUP, LIT, 0a, LESS_THAN, ZBRANCH, 5
	dw	LIT, 030, BRANCH, 6
	dw	LIT, 0a, MINUS, LIT, 061
	dw	PLUS, EMIT, EXIT


	DEFWORD(test-udot, 0, TEST_UDOT)
	dw	LIT, 0141, U_DOT, EXIT

	DEFWORD(last_word, 0, LAST_WORD)
	dw	EXIT

start_dp:

