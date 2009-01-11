
#a module to find out about references
#
use strict;

my $thevar = 1;

print "the var was set to 1\n";

sub thevar_check {

	print "the var is $thevar\n";

}

sub thevar_return {

	return \$thevar;

}
