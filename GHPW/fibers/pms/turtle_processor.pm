
################
# perl turtleshell '#' command processor
#
#
# this is a module to handle # commands!
#
#

use strict;
use pms::msg;

msg "turtle_processor init", -2;

#use pms::turtle_processor::

sub turtle_processor {

	#verify args
	return unless argverify(\@_, 1, "turtle_processor requires *1* arg");

	my $arg = $_[0];

	msg "turtle_processor: handling '$arg'", -1;

	##temporary (permanent?) hardcoded debugging thing - # - print "hi"
	##
	if($arg =~ s/^# - //) {
		msg "Executing perl code: $arg", 2;
		eval("{ $arg }");
		return;
	}

	#cut out the first word
	#
	
	#we define these variables to act upon $arg with:
	my $turtleword = my $turtleargs = "";

	$arg =~ m/^#(\w+)\s+(.*)/;
	$turtleword = $1;
	$turtleargs = $2 if $2;


	msg "turtle_processor: word '$turtleword' args '$turtleargs'", 1;

		




}



1;

