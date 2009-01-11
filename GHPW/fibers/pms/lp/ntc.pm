


#######
# a perl shell module to...
#
#

use pms::msg;
use pms::argverify;

msg "lp::ntc init", -2;

#...

use pms::lp;

sub ntc {
	return unless argverify(\@_, 1, "pms::lp::ntc requires exactly 1 arg");

	my $arg = $_[0];

	unless ($arg =~ s/([0-9]+)\*//) {
		msg "error: ntc syntax is '(number)*(command)'", 3;
		return;
	}

	my $n = $1;

	for(my $t=0; $t<$n; $t++) {
		lp($arg);
	}
}





#return true to please perl
;1;
