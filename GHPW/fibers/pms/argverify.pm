

#####
# perl turtleshell argument verifier
#
#

use strict;
use pms::msg;

# syntax: argverify(\@_, numorwhatever)
# argverify(\@_, 2)  = 2 arg exactly
# argverify(\@_, ">2")  = 2 arg at least
# argverify(\@_, "<2")  = less than 2 arg
sub argverify {

	unless(defined($_[1])) {
		msg "insufficient args passed to argverify() sub", -1;
		return;
	}

	unless ($_[0] =~ m/^ARRAY/) {
		msg "arg 0 to argverify must be an array reference!", -1;
		return;
	}

	my $the_error = "argverify failed..";
	if(defined($_[2])) {
		$the_error = $_[2];
	}

	#make a copy of the args and record the number of args
	my @theargs = @{$_[0]};
	my $numargs = (@theargs);

	my $logic_arg = $_[1];

	my $error_arg = defined($_[2]) ? $_[2] : "argverify() failed";

	if($logic_arg =~ m/^([0-9]+)$/) {
		return 1 if ($numargs == $1);

	} elsif($logic_arg =~ m/^\>([0-9]+)$/) {
		return 1 if ($numargs > $1);
	} elsif($logic_arg =~ m/^([0-9+])\>/) {
		return 1 if ($numargs >= $1);
	} elsif($logic_arg =~ m/^\<([0-9]+)$/) {
		return 1 if ($numargs < $1);
	} elsif($logic_arg =~ m/^([0-9+])\</) {
		return 1 if ($numargs <= $1);
	} elsif($logic_arg =~ m/([0-9]+)n/) {
		return 1 if (($numargs == $1) && (join('',@theargs) =~ m/^[0-9]+$/s));

	} else {
		msg "unrecognized syntax for argverify command", -1;
	};

	msg "argverify: $the_error", 2;
	return 0;

}


1;
