

# byte or ansi keystroke nabber
#
#
#
#

use strict;
use pms::msg;

use Term::ReadKey;

msg "turtle_key init", -2;

=head1 NAME turtle_key
SYNOPSIS
Grabs input from Term::ReadKey and returns either a keystroke or an ANSI sequence.

DESCRIPTION
This function is invoked as $return_string turtle_key ();
It uses Term::ReadKey to grab characters from the terminal's input buffer, blocking for a tiny time period to work around nonblocking io problems on some operatins systems.  If the next character begins an ANSI control sequence, the entire sequence will be put into the return string.  If the next character does not begin an ANSI sequence, it is returned.  If nothing is available in the input buffer, it returns 0.

=cut


sub turtle_key {

	my $rkarg = 0.0001;
	$rkarg = $_[0] if defined($_[0]);
	#rkarg will be used as ReadKey argument
	#fizzy has problem with nonblocking so default is a miniscule value
	#instead of nonblocking -1
	
	my $keypunch;

	$keypunch = ReadKey($rkarg);

	return unless defined($keypunch);

	if($keypunch eq "\x1b") {
		#check for more to pick up if its a ansi

		ANSI_HUNT: {

			last ANSI_HUNT unless ReadKey(0.0001);
			#just assuming its a '['
			#

			$keypunch .= "[";

			while(1) {
				my $tmp = ReadKey(0.00001);

				last ANSI_HUNT unless $tmp;

				$keypunch .= $tmp;
			}
		}
	}

	return $keypunch;

}
