

# perl turtleshell hotkey_to_english
#
#sub to return 0x## or ESC[(...) based on a turtle_key result
#

use strict;

sub hotkey_to_english {

        unless(defined($_[0])) {
                msg "#Internal error. hotkey_to_english() called with no argument!\n", 3;
                return;
        }

        my $key = $_[0];

        if(length($key) == 1) {

                return sprintf "0x%x", ord($key);
        }

        if($key =~ s/^\x1b\[//) {
                return "ESC[$key";
        }

        return;

}

1;
