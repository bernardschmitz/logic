
use strict;

use Term::ReadKey;

my $key;

        ReadMode 4; # Turn off controls keys
        while (not defined ($key = ReadKey(-1))) {

        }
        print "Get key $key\n";
        ReadMode 0; # Reset tty mode before exiting
