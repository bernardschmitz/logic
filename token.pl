
use strict;

my $n = 0;

while(<>) {

	chomp;

	$n++;

	s/;.*$//;

	next if m/^\s*$/;

	process_line($_);
}

sub process_line {

	my $line = shift;


	printf "%05d  %s\n", $n, $line;


	my @chars = split(//, $line);
	my $i = 0;
	my $tok = '';
	my $col = 0;
	my $str = 0;
	my $targ = '';

	while($i <= $#chars) {

		my $ch = $chars[$i];
	
		$i++;

		if($str) {
			if($ch eq $targ) {
				$str = 0;
				token($tok, 'string');
			}
			else {
				$tok .= $ch;
			}
		}
		elsif($ch =~ m/\s/) {
			if($col) {
				token($tok, 'word');
				$col = 0;
			}
		}
		elsif($ch =~ m/[a-zA-Z0-9_]/) {

			if($col) {
				$tok .= $ch;
			}
			else {
				$col = 1;
				$tok = $ch;
			}
		}
		elsif($ch =~ m/[\$:,]/) {

			if($col) {
				token($tok, 'word');
				$col = 0;
			}

			token($ch, 'punct');
		}
		elsif($ch =~ m/['"]/) {

			$str = 1;
			$targ = $ch;
			$tok = '';
		}
		else {
			print "$col $str $ch $tok\n";
		}
	}

	print "EOL\n";

	if($col) {
		token($tok);
	}

	if($str) {
		die;
	}

}

sub token {

	my ($token, $code) = @_;

	print "token: [$token] $code\n";
}


