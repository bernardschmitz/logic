
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

	asm: line(s)

	line: statement
		{ print "line $item{statement}\n\n"; }

	statement: directive
		{ print "stmt $item[1]\n\n"; }

	directive: org | dw | equ

	equ: symbol /equ/ expr
		{
			print "sym $item{symbol}\n";
			print "equ $item{expr}\n";
			$main::symbol{$item[1]} = { value => $item{expr} };
		}

	org: /org/ expr
		{
			$main::address = $item{expr};
			print "org $item{expr}\n";
		}

	dw: /dw/ expr(s /,/)
		{
			for my $n (@{$item[2]}) {
				print "addr $main::address\n";
				print "dw $n\n";
				$main::code[$main::address] = $n;
				$main::address++;
			}
		}

	symbol: /\w\w*/

	expr: num 
		| symbol
		{ $return = $main::symbol{$item{symbol}}->{value}; }

	num: hex 
		{ $return = hex $item[1]; }
	| dec

	hex: /0x[0-9a-f]+/

	dec: /-?[0-9]+/


};



my $parser = new Parse::RecDescent($grammar) or die "Bad grammar!\n";

my $text = <<END;

	org 0x10

blah	equ	42


	dw -3, 0x34, 4234, blah, 3

END


my $result = $parser->asm($text);

print Dumper($result);

print Dumper(\@code);

print Dumper(\%symbol);


