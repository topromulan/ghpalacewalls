

# perl turtleshell keypunch reader
#
#
#

use strict;
use pms::msg;

use pms::quit;

msg "kp init", -2;

my $kp_memory=""; #a memory of the user's line of typing

#these variables contain strings that will be searched
#and hardcoded acted on in certain ways by kp()

#très bien, perl
my $kp_normal='abcdeéèëêfghiîïíìjklmnñoòóöôpqrstuùúûüvwxyzABCDEÉÈËÊFGHIÍÌÎÏJKLMNOÔÖÓÒPQRSTUÙÚÜÛVWXYZ1234567890 ;:~`!@#$%^&*()-_+=\|[]{}\'",.<>/?';

my $kp_backspace = "\x7f\x8";
my $kp_return = "\n\r";
my $kp_redraw = "\x12"; #^R
my $kp_clear = "\x15"; #^U

my @kp_command_stack = ();

sub kp {
	
	return unless argverify(\@_, 1, "kp() call with non-1 args");

	my $key = $_[0];

	msg "kp got a ". hotkey_to_english($key) ."!", -2;

	#use length($key) instead of $key because '0' == false
	return unless length($key);

	$kp_memory="" unless defined($kp_memory);

	#$key = "\x1b[5F";
	# .. to avoid the regexps from interpreting ['s and ('s type things
	#   we must escape them with \'s, using $keyregex for pattern matching

	my $keyregex = "\Q$key\E";
	#$keyregex =~ s/\[/\\\[/;
	#$keyregex =~ s/\(/\\\(/;
	#$keyregex =~ s/\*/\\\*/;


	if($kp_normal =~ m/$keyregex/) {

		print $key;
		$kp_memory .= $key;

	} elsif ($kp_return =~ m/$keyregex/) {

		print "\n";

		push @kp_command_stack, $kp_memory;

		$kp_memory = "";

	} elsif ($kp_backspace =~ m/$keyregex/) {

		if(length($kp_memory) > 0) {
			$kp_memory =~ s/.$//;
			print "\x1b[D \x1b[D"; #left, space, left
		}
	
	} elsif ($kp_redraw =~ m/$keyregex/) {

		print "^R\n$kp_memory";

	} elsif ($kp_clear =~ m/$keyregex/) {

		print "^U\n";
		$kp_memory = "";
		
	###
	## the template for more
	#
	#} elsif ($kp_??? =~ m/$keyregex/) {
	#} elsif ($kp_??? =~ m/$keyregex/) {
	#} elsif ($kp_??? =~ m/$keyregex/) {
	#
	} elsif ($key eq "\x3") {

		msg "Hardcoded ^C quit - ok!", 3;
		quit();

	} else {

		msg "Unhandled keycode " . hotkey_to_english($key);
	}
}

#returns a reference to an array of any completed commands and clears the stack
sub kp_serve {

	return unless argverify(\@_, 0, "kp_serve does not take arguments");

	my @copy = @kp_command_stack;
	
	@kp_command_stack = ();

	return \@copy;
	
}

;1;
