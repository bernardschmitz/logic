
use strict;
use warnings;

use Parse::RecDescent;
use Data::Dumper;

use vars qw(%VARIABLE);

# Enable warnings within the Parse::RecDescent module.

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.
#$::RD_TRACE = 1;

my $grammar = <<'_EOGRAMMAR_';

	SYMBOL: /[a-zA-Z_][a-zA-Z0-9_]*/ { main::log(@item); $return = $item[1]; }
		| LOCATION

	LOCATION: '$'


   NUMBER  : /-?0x[0-9a-fA-F]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?0[0-7]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?0b[01]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?[0-9]+/
		{ $return = $item[1]; }

   OP       : m([-+*/])

	addop: m([-+])

	mulop: m([*/])

	expression:	sum

	sum: prod addop_prod(s?) { main::log(@item); $return = "[ $item[1] ".join(" ", @{$item[2]})." ]"; }

	addop_prod: addop prod { $return = "$item[1] $item[2]"; }

	prod:	value mulop_value(s?) { main::log(@item); $return = "[ $item[1] ".join(" ", @{$item[2]})." ]"; }

	mulop_value: mulop value { $return = "$item[1] $item[2]"; }

	value:	NUMBER | SYMBOL | '(' expression ')' { $return = "$item[1] $item[2] $item[3]"; }



	STRING:	/'/ /[^']*/ /'/ { main::log(@item); }
		| /"/ /[^"]*/ /"/ { main::log(@item); }

	OPCODE1:
		'add'
		| 'sub'
		| 'sllv'
		| 'srlv'
		| 'srav'
		| 'slt'
		| 'and'
		| 'or'
		| 'xor'
		| 'nor'

	OPCODE2: 'addi'
		| 'sll'
		| 'srl'
		| 'sra'
		| 'beq'
		| 'bne'
		| 'slti'
		| 'andi'
		| 'ori'
		| 'lw'
		| 'sw'

	OPCODE3:
		 'mul'
		| 'div'
		| 'jalr'

	OPCODE4: 'jal'

	OPCODE5:
		'jr'
		| 'mfhi'
		| 'mflo'

	OPCODE6: 'j'

	OPCODE7: 'brk'
		| 'halt'

	comment: ';' /.*\n/

	REG:	'r10' | 'r11' | 'r12' | 'r13' | 'r14' | 'r15'
		| 'r0' | 'r1' | 'r2' | 'r3' | 'r4' | 'r5' | 'r6' | 'r7' | 'r8' | 'r9' 
		| 'zero' | 'at' | 'v0' | 'v1' | 'a0' | 'a1' | 'a2' | 's0'
		| 's1' | 's2' | 't0' | 't1' | 't2' | 'fp' | 'sp' | 'ra'


	PSEUDO_OP1:	'mult' | 'divd'
	PSEUDO_OP2:	'bgt' | 'blt' | 'bge' | 'ble'
	PSEUDO_OP3:	'move'
	PSEUDO_OP4:	'li'
	PSEUDO_OP5:	'inc' | 'dec' | 'clear' | 'not' | 'neg'
	PSEUDO_OP6:	'nop'


	ps_type1:	PSEUDO_OP1 REG ',' REG ',' REG { main::log(@item); $return = "$item[1] $item[2] $item[4] $item[6]"; }
	ps_type2:	PSEUDO_OP2 REG ',' REG ',' expression { main::log(@item); $return = "$item[1] $item[2] $item[4] $item[6]"; }
	ps_type3:	PSEUDO_OP3 REG ',' REG { main::log(@item); $return = "$item[1] $item[2] $item[4]"; } 
	ps_type4:	PSEUDO_OP4 REG ',' expression { main::log(@item); }
	ps_type5:	PSEUDO_OP5 REG { main::log(@item); }
	ps_type6:	PSEUDO_OP6 { main::log(@item); }


	pseudo:
		ps_type1
		| ps_type2
		| ps_type3
		| ps_type4
		| ps_type5
		| ps_type6



		
	op_type1:	OPCODE1 REG ',' REG ',' REG { main::log(@item); }
	op_type2:	OPCODE2 REG ',' REG ',' expression { main::log(@item); }
	op_type3:	OPCODE3 REG ',' REG { main::log(@item); }
	op_type4:	OPCODE4 REG ',' expression { main::log(@item); }
	op_type5:	OPCODE5 REG { main::log(@item); }
	op_type6:	OPCODE6 expression { main::log(@item); }
	op_type7:	OPCODE7 { main::log(@item); }


	instruction:
		op_type1
		| op_type2
		| op_type3
		| op_type4
		| op_type5
		| op_type6
		| op_type7

	label:	SYMBOL ':'

	directive:
		'.org' expression
		| '.word' expression(s /,/)
		| '.string' STRING(s /,/) 
		| '.align'
		| '.set' SYMBOL ',' expression

	line:	
		comment
		| directive { main::log2(@item); }
		| pseudo { main::log2(@item); }
		| instruction { main::log2(@item); }
		| label { main::log2(@item); }
		


	eof:	/^\Z/

	startrule: 
		line(s) eof
		| <error>

_EOGRAMMAR_


sub log {

	print join(' ', @_),"\n";
	#print Dumper(\@_);

	1;
}

sub log2 {

	#print join(' ', @_),"\n";
	print Dumper(\@_);

	1;
}


my $parser = Parse::RecDescent->new($grammar);

my @text = <>;

my $text = join('', @text);
#print "$text";

defined($parser->startrule($text)) || die "Bad text!\n";



#
#   OP       : m([-+*/]) 
#
#   NUMBER  : /-?0x[0-9a-fA-F]+/
#		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
#		| /-?0[0-7]+/
#		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
#		| /-?0b[01]+/
#		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
#		| /-?[0-9]+/
#		{ $return = $item[1]; }
#
#   SYMBOL : /[a-zA-Z][a-zA-Z0-9_]*/
#
#	ORG:	'$'
#
#	expr:	NUMBER OP expr
#		| SYMBOL OP expr
#		| NUMBER
#		{ print join(', ', @item),"\n"; }
#		| SYMBOL
#		{ print join(', ', @item),"\n"; }
#		| ORG
#
#	word:	expr
#
#	label:	SYMBOL
#		{ print join(', ', @item),"\n"; }
#
#	opcode:
#		'add'
#		| 'addi'
#		| 'sub'
#		| 'mul'
#		| 'div'
#		| 'sll'
#		| 'srl'
#		| 'sra'
#		| 'sllv'
#		| 'srlv'
#		| 'srav'
#		| 'beq'
#		| 'bne'
#		| 'slt'
#		| 'slti'
#		| 'and'
#		| 'andi'
#		| 'or'
#		| 'ori'
#		| 'xor'
#		| 'nor'
#		| 'j'
#		| 'jr'
#		| 'jal'
#		| 'jalr'
#		| 'lw'
#		| 'sw'
#		| 'mfhi'
#		| 'mflo'
#		| 'brk'
#		| 'halt'
#
#
#	const:	expr
#
#	reg:	/r[0-9]|r1[0-5]|zero|t[0-2]/
#
#	op_type1:	opcode
#
#	op_type2:	opcode reg
#
#	op_type4:	opcode reg ',' reg ',' const
#
#	instruction:	op_type4
#		| op_type2
#		| op_type1
#		| <error>
#		
#
#	directive:	'.org' expr
#		| '.align'
#		| '.word' word(s /,/)
#		| <error>
#
##	line: 
##		label ':' directive
##		| label ':' instruction
##		| label ':'
##		| instruction
##		| <error>
#
#	line: label ':'
#
#	startrule: line(s)
#		| <error>
