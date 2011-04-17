
use strict;

use vars qw{@code};

use Parse::RecDescent;
use Data::Dumper;

$::RD_ERRORS = 1;
$::RD_WARN = 1;
$::RD_HINT = 1;


my $address = 0;

#my @code = ();

my $grammar = q {

	asm: line(s)

	line: statement
		{ print "line $item{statement}\n\n"; }

	statement: directive
		{ print "stmt $item[1]\n\n"; }

	directive: org | dw

	org: /org/ num 
		{
			$main::address = $item{num};
			print "org $item{num}\n";
		}

	dw: /dw/ num(s /,/)
		{
			for my $n (@{$item[2]}) {
				print "addr $main::address\n";
				print "dw $n\n";
				$main::code[$main::address] = $n;
				$main::address++;
			}
		}

	num: hex 
		{ $return = hex $item[1]; }
	| dec

	hex: /0x[0-9a-f]+/

	dec: /-?[0-9]+/


};



my $parser = new Parse::RecDescent($grammar) or die "Bad grammar!\n";

my $text = <<END;

	org 0x10

	dw -3, 0x34, 4234

END


my $result = $parser->asm($text);

print Dumper($result);


print Dumper(@code);
for(@code) {
	print "$_\n";
}

print "done.\n";


