


#######
# a perl shell module to explore bih blocks
#
#

use strict;
use pms::msg;
use pms::argverify;

msg "The bih() explorer! init", -2;

#...

my $n = 0;

my @bih_explorer_array;

sub bih_explorer_add {

	return unless argverify(\@_, 1, "The bih() explorer takes one arg!");

	push @bih_explorer_array, $_[0];
	$n++;

	msg "bih() explorer adding block #$n!",0;



}

sub bih_explorer_dir {

	my $n = @bih_explorer_array;

	msg "bih_explorer: $n blocks";

}

sub bih_explorer_show {

	return unless argverify(\@_, "1n", "bih_explorer_show() requires 1 arg");
	
	my $n = $_[0];

	my $buff = @bih_explorer_array[$n];

	$buff =~ s/\x1b/ESC/g;
	$buff =~ s/\n/\\n/g;
	$buff =~ s/\r/\\r/g;

	msg $buff;
}






#return true to please perl
;1;
