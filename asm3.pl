
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

	arg : /[a-z][a-z0-9]+/

	opcode : /[a-z]+/

	instruction : opcode arg(s /,/)
#		{
#			print $item{opcode}."\n"; 
#			print join(' ', @item{arg})."\n";
#		}

	label : /[a-z][a-z0-9]+/ 
#		{
#			print "label: ".$item[1]."\n";
#		}

	line : instruction 
		{
			print "ins: ".join(' ', @{$item[1]})."\n";
		}
		| label ':' instruction
		{
			print "label: ".$item[1]."\n";
			print "ins: ".join(' ', @{$item[3]})."\n";
		}

	asm : line(s)

};



my $parser = new Parse::RecDescent($grammar) or die "Bad grammar!\n";

my $text = <<END;

	addi	at, zero, zero
l0:	li	at, 23
	nop
	jr	ra


END


my $result = $parser->asm($text);

print Dumper($result);

