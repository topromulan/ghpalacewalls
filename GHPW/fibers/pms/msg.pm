
# perl turtleshell message output system
#
#
#
#

use strict;

print "messaging initialization\n";

my $msg_squelch = -2;
my $msg_default = 1;
my $msg_verbose = 1;
my $msg_hard = 0;
## msg 
# string
# volume
sub msg {
##
#
	unless($_[0]) {
		print "\n#\n";
		return;
	}
	
	my $str=$_[0];

	my $vol=$msg_default;
	$vol = $_[1] if defined($_[1]);

	my $op = "#";

	$op .= sprintf(" %2d #", $vol) if $msg_verbose;

	#pad a space if f.l. is lowercase
	if($str =~ m/^[a-z]/) {
		$op .= " ";
	}

	$op .= $str;

	print "\n" if $msg_hard;

	if($vol >= $msg_squelch) {
		print "$op\n";
	}

}

sub squelch {
	return unless argverify(\@_, 1, "msg::squelch requires 1 arg");

	msg "Adjusting shell squelch to $_[0]", 1;
	$msg_squelch=$_[0];

}

	
sub msg_test {


	print "This is how your msg() calls will look:\n\n";

	msg "Debug", -1;
	msg "Spam", 0;
	msg "Info", 1;
	msg "Note", 2;
	msg "Error", 3;

	print "\n";

}




1;
