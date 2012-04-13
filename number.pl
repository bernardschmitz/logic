
use strict;

my $n = "101014356dex=#D ";

my $l = length($n);

my $base = 8;


my $i = 0;

my $a = 0;

my $fail = 0;
my $d = 0;

while($l-- && !$fail) {


	my $k = substr($n, $i, 1);

	$i++;

	($fail, $d) = digit($k);

	print "$i - $k ".(ord $k)." $fail $d $a\n";

	if(!$fail) {
		$a = $a * $base;
		$a += $d;
	}
}

sub digit($) {

	my $c = shift;

	my $d = ord($c) - ord('0');

	if($d < 0) {
		return (1, $d);
	}

	if($d > 9) {
		$d -= ord('a')-ord('0');

		if($d < 0) {
			return (1, $d);
		}

		$d += 10;
	}

	if($d >= $base) {
		return (1, $d);	
	}

	return (0, $d);
}

