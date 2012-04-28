
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
	 j	_NEXT
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

	define(ALIGN, {
		inc	$1
		andi	$1, $1, 0fffe
	})dnl

	j	start

	org	010
	align
DOCOL:
	PUSHRSP(r10)
	inc	r11
	ALIGN(r11)
	move	r10, r11
_NEXT:
	lw	r11, r10, 0
	inc	r10
	lw	r12, r11, 0
	jr	r12


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
	align
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

yeah:	dw	INTERPRET, HALT
;yeah:	dw	TEST5, HALT

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
	dw LIT, 05, LIT, msg, LIT, 01a, TYPE, CR, ONE_MINUS, DUPE, LIT, 0, EQUALS, ZBRANCH, -0c, EXIT
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
	dw	LIT, msg3, LIT, 0b, FIND, QUESTION_DUPE, ZBRANCH, 9
	dw	LIT, 02a, EMIT, CR, TO_CFA, EXECUTE, BRANCH, 7
	dw	LIT, msg3, LIT, 0b, TYPE, CR, EXIT
msg3:	ds	"hidden_test"


	DEFCODE(halt, 0, HALT)
	halt

	DEFCODE(brk, 0, BRK)
	brk
	NEXT

	DEFCODE(dsp@, 0, DSPFETCH)
	move	r1, r14
	PUSHDSP(r1)
	NEXT

	DEFCODE(dsp!, 0, DSPSTORE)
	lw	r1, r14, 0
	move	r14, r1
	NEXT


	DEFCODE(drop, 0, DROP)
	inc	r14
	NEXT

	DEFCODE(nip, 0, NIP)
	lw	r2, r14, 0
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(swap, 0, SWAP)
	lw	r2, r14, 0
	lw	r3, r14, 1

	sw	r3, r14, 0
	sw	r2, r14, 1
	NEXT

	DEFCODE(dup, 0, DUPE)
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

	DEFCODE(2drop, 0, TWO_DROP)
	addi	r14, r14, 2
	NEXT

	DEFCODE(2dup, 0, TWO_DUPE)
	lw	r2, r14, 0
	lw	r3, r14, 1
	addi	r14, r14, -2
	sw	r2, r14, 0
	sw	r3, r14, 1
	NEXT

	DEFCODE(2swap, 0, TWO_SWAP)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r14, 2
	lw	r5, r14, 3

	sw	r4, r14, 0
	sw	r5, r14, 1
	sw	r2, r14, 2
	sw	r3, r14, 3
	NEXT

	DEFCODE(?dup, 0, QUESTION_DUPE)
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
	sub	r2, r3, r2
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

	DEFCODE(0=, 0, ZERO_EQUALS)
	clear	r2
	lw	r3, r14, 0
	bne	r3, zero, not_eq
	not	r2
not_eq:
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
	DEFVAR(>in, 0, TO_IN, 0)
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

	DEFCODE(rsp@, 0, RSPFETCH)
	PUSHDSP(r13)	
	NEXT

	DEFCODE(rsp!, 0, RSPSTORE)
	POPDSP(r13)	
	NEXT

	DEFCODE(rdrop, 0, RDROP)
	inc	r13
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
	lw	r2, r14, 0		; max count
	lw	r3, r14, 1		; buffer address
	jal	r15, _accept
	inc	r14
	sw	r2, r14, 0		; count
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

	sw	r3, zero, var_TO_IN	; save index
	j	_parse0
_parse_done:
	sw	r3, zero, var_TO_IN	; save index
	dec	r3
_parse0:
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
	move	r2, r7
	move	r3, r8
	jr	r15
	


	DEFWORD(quit, 0, QUIT)
	dw	LIT, buffer, DUPE, LIT, 00ff, ACCEPT, SPACE, TYPE, CR, BRANCH, -0a, EXIT
	



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
	dw	LIT, 0, LIT, 064, DUPE, TO_R, PLUS, FROM_R, ONE_MINUS, DUPE, LIT, 0, EQUALS, ZBRANCH, -0a, DROP, EXIT


	DEFCODE(find, 0, FIND)
	lw	r2, r14, 0	; length
	lw	r3, r14, 1	; string address
	jal	r15, _find
	inc	r14
	sw	r2, r14, 0
	NEXT
_find:
	lw	r6, zero, var_LATEST	; address of latest word

_find_search:

;li	r1, 02a
;sw	r1, zero, charout

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


	define(DICT2CFA, {
		lw	r1, $1, 2		; get length
		addi	$1, $1, 3		; get addr of name
		add	$1, $1, r1		; add length
		ALIGN($1)
	})dnl


	define(CFA2DFA, {
		inc	$1
		ALIGN($1)
	})dnl


	define(DICT2DFA, {
		DICT2CFA($1)
		CFA2DFA($1)
	})dnl


	DEFCODE(>cfa, 0, TO_CFA)
	lw	r2, r14, 0		; dictionary address
	DICT2CFA(r2)
	sw	r2, r14, 0		; cfa addr on stack
	NEXT


	DEFCODE(>dfa, 0, TO_DFA)
	lw	r2, r14, 0
	DICT2DFA(r2)
	sw	r2, r14, 0
	NEXT


	DEFWORD(interpret, 0, INTERPRET)
	dw	NUMBER_TIB, FETCH, TO_IN, FETCH, EQUALS, ZBRANCH, 011
	dw	LIT, ok_msg, LIT, 3, TYPE, CR
	dw	TIB, LIT, 00ff, ACCEPT, NUMBER_TIB, STORE, LIT, 0, TO_IN, STORE
	dw	BL, PARSE, TWO_DUPE, FIND, QUESTION_DUPE, ZBRANCH, 08
	dw	NIP, NIP, SPACE, TO_CFA, EXECUTE, BRANCH, 0b
	dw	NUMBER, ZERO_EQUALS, ZBRANCH, 07
	dw	LIT, err_msg, LIT, 4, TYPE, CR
	dw	BRANCH, -030
	dw	EXIT
ok_msg:
	ds	" ok"
err_msg:
	ds	" err"



	DEFCODE(u., 0, U_DOT)
	lw	r2, r14, 0
	inc	r14
	jal	r15, _udot
	NEXT
_udot:
	lw      r3, zero, var_BASE
	li	r4, _udot_buf
	li	r5, 0a
_udot_rep:
	dec	r4
	div     r2, r3
	mflo    r2
	mfhi    r6

	blt	r6, r5, _udot_lt_10	; less than 10?

	addi	r6, r6, 057		; add -10 + 'a'
	sw	r6, r4, 0
	bne	r2, zero, _udot_rep
	j	_udot_out

_udot_lt_10:
	addi	r6, r6, 030
	sw	r6, r4, 0
	bne	r2, zero, _udot_rep

_udot_out:
	lw	r6, r4, 0
	beq	r6, zero, _udot_done
	sw	r6, zero, charout
	inc	r4
	j	_udot_out
_udot_done:
	jr	r15

	dw      0,0,0,0,0,0,0,0
	dw      0,0,0,0,0,0,0,0
	dw      0,0,0,0,0,0,0,0
	dw      0,0,0,0,0,0,0,0
	dw      0,0,0,0,0,0,0,0
	dw      0,0,0,0,0,0,0,0
_udot_buf:
	dw	0


	DEFCODE(., 0, DOT)
	lw	r2, r14, 0
	inc	r14,
	jal	r15, _dot
	NEXT
_dot:
	bge	r2, zero, _dot_pos
	li	r1, minus
	sw	r1, zero, charout
	neg	r2
_dot_pos:
	j	_udot



	DEFCODE(create, 0, CREATE)
	jal	r15, _create
	NEXT
_create:
	move	r9, r15		; save return address
	li	r2, blank
	jal	r15, _parse

	lw	r4, zero, var_HERE
;	inc	r4
;	andi	r4, r4, 0fffe	; align data pointer

	lw	r1, zero, var_LATEST
	sw	r1, r4, 0	; store link

;	clear	r1
	sw	zero, r4, 1	; store flags
	sw	r2, r4, 2	; store len
	addi	r4, r4, 3	; address of dict name
_create0:
	lw	r1, r3, 0	; get name char
	sw	r1, r4, 0	; store name char
	inc	r4		; bump pointers
	inc	r3
	dec	r2		; decr char count
	bne	r2, zero, _create0	; keep copying until done

	ALIGN(r4)
;	inc	r4
;	andi	r4, r4, 0fffe	; align cfa field
				; r4 = cfa addr
	li	r1, _create_xt
	sw	r1, r4, 0	; store create xt in cfa

	inc	r4		; align
	ALIGN(r4)
;	andi	r4, r4, 0fffe 	; r4 = dfa

	lw	r1, zero, var_HERE
	sw	r1, zero, var_LATEST
	sw	r4, zero, var_HERE

	jr	r9

_create_xt:
	move	r1, r11
	inc	r1
	PUSHDSP(r1)	
	NEXT


	DEFCODE({,}, 0, COMMA)
	POPDSP(r2)
	lw	r3, zero, var_HERE
	sw	r2, r3, 0
	inc	r3
	sw	r3, zero, var_HERE
	NEXT


	DEFCODE([, f_immediate, LBRAC)
	clear	r2
	sw	r2, zero, var_STATE
	NEXT
	
	DEFCODE(], 0, RBRAC)
	li	r2, 0ffff
	sw	r2, zero, var_STATE
	NEXT


	DEFCODE(immediate, 0, IMMEDIATE)
	lw	r2, zero, var_LATEST	; get latest word
	inc	r2			; flags addr
	lw	r3, r2, 0		; get flags
	li	r4, f_immediate		; immediate bit
	xor	r3, r3, r4		; toggle
	sw	r3, r2, 0		; store it
	NEXT

	DEFCODE(hidden, 0, HIDDEN)
	POPDSP(r2)			; dict header addr from stack
	inc	r2			; flags addr
	lw	r3, r2, 0		; get flags
	li	r4, f_hidden		; hidden bit
	xor	r3, r3, r4		; toggle
	sw	r3, r2, 0		; store it
	NEXT

	DEFWORD(hide, 0, HIDE)
	dw	BL, PARSE, FIND, HIDDEN, EXIT


	DEFWORD({'}, 0, TICK)
	dw	BL, PARSE, FIND, TO_CFA, EXIT

	DEFWORD(test-udot, 0, TEST_UDOT)
	dw	LIT, 0141, U_DOT, CR
	dw	HEX
	dw	LIT, 0cafe, U_DOT, CR
	dw	BINARY
	dw	LIT, 0babe, U_DOT, CR
	dw	DECIMAL
	dw	LIT, 0293a, DOT, CR
	dw	LIT, -0141, DOT, CR
	dw	EXIT

	DEFWORD(last_word, 0, LAST_WORD)
	dw	EXIT
	
	align
start_dp:

