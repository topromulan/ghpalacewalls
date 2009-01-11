


#######
# a perl shell module to...
#
#

use pms::msg;
use pms::argverify;

msg "[your module name here] init", -2;

#...

sub yoursubgoeshere {

	return unless argverify(\@_, 0, "your sub error message if bad args are passed");



}





#return true to please perl
;1;
