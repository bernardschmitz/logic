
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

	SYMBOL: /[a-zA-Z][a-zA-Z0-9_]*/ { main::log(@item); }


   NUMBER  : /-?0x[0-9a-fA-F]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?0[0-7]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?0b[01]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?[0-9]+/
		{ $return = $item[1]; }

   OP       : m([-+*/])


	expression:	NUMBER OP expression	{ main::log(@item) }
		| SYMBOL OP expression	{ main::log(@item) }
		| NUMBER
		| SYMBOL

	STRING:	/'/ /[^']*/ /'/ { main::log(@item); }
		| /"/ /[^"]*/ /"/ { main::log(@item); }


	OPCODE: 'addi'
		| 'add'
		| 'sub'
		| 'mul'
		| 'div'
		| 'sllv'
		| 'sll'
		| 'srlv'
		| 'srl'
		| 'srav'
		| 'sra'
		| 'beq'
		| 'bne'
		| 'slti'
		| 'slt'
		| 'andi'
		| 'and'
		| 'ori'
		| 'or'
		| 'xor'
		| 'nor'
		| 'jalr'
		| 'jal'
		| 'jr'
		| 'j'
		| 'lw'
		| 'sw'
		| 'mfhi'
		| 'mflo'
		| 'brk'
		| 'halt'

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

	type1:	OPCODE1 REG ',' REG ',' REG { main::log(@item); }

	type2:	OPCODE2 REG ',' REG ',' expression { main::log(@item); }

	type3:	OPCODE3 REG ',' REG { main::log(@item); }

	type4:	OPCODE4 REG ',' expression { main::log(@item); }

	type5:	OPCODE5 REG { main::log(@item); }

	type6:	OPCODE6 expression { main::log(@item); }

	type7:	OPCODE7 { main::log(@item); }


	instruction:
		type1
		| type2
		| type3
		| type4
		| type5
		| type6
		| type7

	label:	SYMBOL ':'

	directive:
		'.org' NUMBER 
		| '.word' expression(s /,/)
		| '.string' STRING(s /,/) 
		| '.align'
		| '.set' SYMBOL ',' expression

	line:	
		comment 
		| directive 
		| instruction 
		| label


	eof:	/^\Z/

	startrule: 
		line(s) eof
		| <error>

_EOGRAMMAR_


sub log {

	print join(' ', @_),"\n";
	#print Dumper(\@_);
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
#	type1:	opcode
#
#	type2:	opcode reg
#
#	type4:	opcode reg ',' reg ',' const
#
#	instruction:	type4
#		| type2
#		| type1
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
