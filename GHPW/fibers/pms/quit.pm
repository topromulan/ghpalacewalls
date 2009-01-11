

########
# perl turtleshell quit sub
#
#

use strict;
use Term::ReadKey;

use pms::msg;


sub quit {

	ReadMode 1;

	msg "Quitting now..", 3;

	exit(0);
}

1
