
	.org	3

; .set g,$+-34 ; blah blah blah yeah  
	.set leng,0xcafe
; li r5,leng
;g-f: slti at,zero,0xbabe
; move r1, r0 
; blah:  .string "hello    ", 'there   ' 

	.word	56
	.word	-56
	.word	0b1111000011110000

	.word	1, 2, 3

	.word	goon, leng

goon:

	.string	"hello"
	.string	'abc', "xyz"


;.word 0xdd,0b1111,033,436753   
;.word -0xdd,-0b1111,-033,-436753   
;.word 0xffff, 5*45 - -045/2


