
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
	while($i <= $#chars) {

		my $ch = $chars[$i];
	
		$i++;

		if($ch =~ m/\s/) {
			if($col) {
				token($tok);
				$col = 0;
			}
		}
		elsif($ch =~ m/[a-z0-9_]/) {

			if($col) {
				$tok .= $ch;
			}
			else {
				$col = 1;
				$tok = $ch;
			}
		}
		elsif($ch =~ m/[:,]/) {

			if($col) {
				token($tok);
				$col = 0;
			}

			token($ch);
		}

#		print "$ch $tok\n";
	}

	if($col) {
		token($tok);
	}

}

sub token {

	my $token = shift;

	print "token: [$token]\n";
}


