


#######
# a perl shell module to handle the command line args
#
#
# cmdlineargs() takes ($hashref, @args)
# as startup is a reference to a hash, whatever changes are made to the hash
# it points at are seen by calling function.
# returns reference to %arghash
#

use strict;
use pms::msg;
use pms::argverify;

msg "cmdlineargs init", -2;

#...

sub cmdlineargs {

	my $startup = shift;
	my %arghash = ();

	my $optionword = "null";

	foreach my $argument (@_) {

		if ($argument =~ m/\-(\S+)/) {

			$optionword = $1; # if -var save to optionword to use as key for next arg

		} else {

			$arghash{$optionword} .= " " if defined($arghash{$optionword});

			$arghash{$optionword} .= $argument; # use previous arg, -var, as key and this arg as value

		}

	}

	msg "Command line args as follows:", 0;

	foreach my $guy (keys(%arghash)) {
		msg " $guy = $arghash{$guy}", 0;

	}

	foreach my $override (keys %arghash) {
		if(defined($startup->{$override})) {
			$startup->{$override} = $arghash{$override}; # overwrite key in startup with override. as startup is a ref don't need to return it.
			msg "Startup: $override => $startup->{$override};", 1;
		} else {
			msg "Invalid command line arg $override, bozo", 1;
		}
	}
	return \%arghash;
}





#return true to please perl
;1;
