
use strict;

use vars qw{@code};
use vars qw{%symbol};

use Parse::RecDescent;
use Data::Dumper;

$::RD_ERRORS = 1;
$::RD_WARN = 1;
$::RD_HINT = 1;


my $address = 0;

#my @code = ();
#my %symbol = ();

my $grammar = q {

	number : /[0-9]+/
		{
			print "number: $item[1]\n";
		}

	reg : /at|zero|ra/
		{
			print "reg: $item[1]\n";
		}

	arg : reg | label | number 

	arg0 : arg
	arg1 : arg
	arg2 : arg

	opcode : /[a-z]+/
		{
			print "opcode: $item[1]\n";
		}

	instruction : opcode arg0 /,/ arg1 /,/ arg2 /\n/ 
		{
			print "ins: $item{opcode}, $item{arg0}, $item{arg1}, $item{arg2}\n";
		}
		| opcode arg0 /,/ arg1 /\n/ 
		{
			print "ins: $item{opcode}, $item{arg0}, $item{arg1}\n";
		}
		| opcode arg0 /\n/ 
		{
			print "ins: $item{opcode}, $item{arg0}\n";
		}
		| opcode /\n/
		{
			print "ins: $item{opcode}\n";
		}

	label : /[a-z][a-z0-9]+/ 
		{
			print "label: $item[1]\n";
		}

	#line : label /:/ instruction | instruction
	line : instruction

	asm : line(s)

};



my $parser = new Parse::RecDescent($grammar) or die "Bad grammar!\n";

my $text = <<END;
	nop
	nop
	addi	at, zero, zero
	li	at, 23
	nop
	jr	ra
END


my $result = $parser->asm($text) or die "y u no parse?\n";

print Dumper($result);

