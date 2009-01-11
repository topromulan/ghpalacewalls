
# perl turtleshell line input input processor
#
#
#
#

use strict;
use pms::msg;
use pms::argverify;

use pms::sneezy;

msg "lp init", -2;

# increment recursion
# check recursion level / busted flag
# clean leading/trailing whitespace
# check for number*command [send to ntc]
# check for # command [send to turtle_processor]
# check for variable=assignment [send formatted to turtle_processor]
# check for SCS [send to scs]
# check for CSV [send to csv]
# check for alias [send to ap]
# substitute any variables
# unescape any \, or \;
# send arg to telnet if unhandled
# decrement recursion
# check/fix busted flag

use pms::lp::ntc; #number times command
use pms::lp::scs; #semi colon split
use pms::lp::csv; #comma seperated values

my $lp_recursion = 0;
my $lp_recursion_limit = 15;
my $lp_recursion_busted = 0;

my @lp_command_stack = ();

sub lp {

	return unless argverify(\@_, 1, "lp requires exactly 1 argument");

	my $arg = $_[0];

	$lp_recursion++;
	msg "lp recursion: $lp_recursion", -1;

	LPBLOCK: {
		#always use 'last LPBLOCK', not 'return'

		#check recursion
		if($lp_recursion > $lp_recursion_limit) {
			msg "\$lp_recursion is greater than $lp_recursion_limit (\$lp_recursion_limit)", 3;
			msg "setting bust flag!", 4;
			$lp_recursion_busted = 1 
		}
		if($lp_recursion_busted) {
			msg "lp busted - passing", 0;
			last LPBLOCK 
		} 

		#tidy up $arg
		$arg =~ s/^\s+//;
		$arg =~ s/\s+$//;

		#check for number*command
		if($arg =~ m/^[0-9]+\*/) {
			ntc $arg;
			last LPBLOCK;
		}

		#check for # 'turtle' command
		if($arg =~ m/^#/) {
			turtle_processor($arg);
			last LPBLOCK;
		}

		#check for name=value variable assignment
		if($arg =~ m/^([a-zA-Z][\S]*?)\=(.*)/) {
			turtle_processor("#set $1 $2");
			last LPBLOCK;
		}

		#semi-colon split
		if($arg =~ m/\;/) {
			scs($arg);
			last LPBLOCK;
		}

		#comma seperated values
		if($arg =~ m/\S,\S/) {
			csv($arg);
			last LPBLOCK;
		}

		#generic case
		{
			push @lp_command_stack, $arg;
			last LPBLOCK;
		}

		msg "lpblock unhandled..", -2;
	}

	$lp_recursion--;

	if($lp_recursion_busted) {
		if ($lp_recursion <= 0) {
			msg "lp recursion bust cleared - reset to 0", 3;
			msg "check your code for a loop!", 3;
			$lp_recursion_busted = 0 
		}

	}

}

sub lp_serve {

	return unless argverify (\@_, 0, "lp_serve() does not take arguments");

	my @copy = @lp_command_stack;

	@lp_command_stack=();

	return \@copy;


}

;1;
