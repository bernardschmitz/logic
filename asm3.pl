
use strict;
use Parse::RecDescent;
use Data::Dumper;

use vars qw(%VARIABLE);

# Enable warnings within the Parse::RecDescent module.

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

our $org = 0;
our @mem = ();

my %symbol = ();

my $grammar = <<'_EOGRAMMAR_';

   # Terminals (macros that can't expand further)
   #

   OP       : m([-+*/]) 

   NUMBER  : /-?0x[0-9a-fA-F]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?0[0-7]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?0b[01]+/
		{ $return = $item[1]; $return = oct($return) if $return =~ m/^0/; }
		| /-?[0-9]+/
		{ $return = $item[1]; }

   SYMBOL : /[a-zA-Z][a-zA-Z0-9_]*/

	ORG:	'$'
		{ $return = $main::org }

	expr:	NUMBER OP expr
		{ $return = main::expr(@item) }
		| SYMBOL OP expr
		| NUMBER
		| SYMBOL
		{ main::add_symbol($item{SYMBOL}) }
		| ORG

	word:	expr
		{ $main::mem[$main::org++] = $item{expr} & 0xffff; }

	label:	SYMBOL
		{ main::add_symbol($item{SYMBOL}, $main::org++) }

	opcode:	'halt' | 'brk' | 'jr' | 'j' | 'addi'

	const:	expr

	reg:	/r[0-9]|r1[0-5]|zero/

	type1:	opcode
		{ print "type1 $item{opcode}\n"; }

	type2:	opcode reg
		{ print "type2 $item{opcode} $item{reg}\n"; }

	type4:	opcode reg ',' reg ',' const
		{ $main::org += 2;  print "type4 $item[1] $item[2] $item[3] $item[4]\n"; }

	instruction:	type4
		| type2
		| type1
		

	directive:	'.org' expr
		{ $main::org = $item{expr}; }
		| '.align'
		{ $main::org = ($main::org + 1) & 0xfffe; }
		| '.word' word(s /,/)

	line: directive
		| instruction
		| label ':'

	startrule: line(s)

_EOGRAMMAR_

sub add_symbol {

	my $sym = shift;
	my $val = shift;

	$symbol{$sym} = { sym => $sym, addr => $val };

	print "sym $sym $val\n";
}

sub expr {
   shift;
   my ($lhs,$op,$rhs) = @_;
   return eval "$lhs $op $rhs";
}

my $parser = Parse::RecDescent->new($grammar);

my @text = <>;

#$parser->startrule($text);
$parser->startrule(join('', @text)) or print "Bad text!\n";

printf "%04x\n", $org;


my $i = 0;
for(@mem) {
	printf "%04x %04x\n", $i++, $_;
}

#print "a=2\n";             $parser->startrule("a=2");
#print "a=1+3\n";           $parser->startrule("a=1+3");
#print "print 5*7\n";       $parser->startrule("print 5*7");
#print "print 2/4\n";       $parser->startrule("print 2/4");
#print "print 2+2/4\n";     $parser->startrule("print 2+2/4");
#print "print 2+-2/4\n";    $parser->startrule("print 2+-2/4");
#print "a = 5 ; print a\n"; $parser->startrule("a = 5 ; print a");

