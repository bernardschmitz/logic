
use strict;

use Parse::RecDescent;

my $grammar = q {

	asm: line(s)
		{
			print "asm: $item{line}\n";
		}
	line: label_spec(?) instruction args
		{
			print "label: $item{label}\n";
			print "instruction: $item{instruction}\n";
#			print "args: $item{args}\n";
#			for(@{$item{args}}) {
#				print "arg: $_\n";
#			}
			print "\n";
		}

	label_spec: label ":"
	label: /[a-z][a-z0-9]+/i

	instruction: /[a-z]+/
	args: arg(s /,/)
		{
			print "arg: $item{arg}\n";
#			for(@{$item{arg}}) {
#				print "arg: $_\n";
#			}
		}
	arg: reg(..3) | label
	reg: /r[0-9][0-9]*/i | /zero/i | /at/i | /v[01]/i | /a[012]/i | /s[012]/i | /t[012]/i | /fp/i | /sp/i | /ra/i

};



my $parser = new Parse::RecDescent($grammar) or die "Bad grammar!\n";

my $text = <<END;

	move	v0, a2
	li	r0, value
loop:	addi	at, zero, blah
	j	loop

END



$parser->asm($text) or die "error\n";


