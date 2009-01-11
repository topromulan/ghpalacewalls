#!/usr/bin/perl
#
# Turtle Shell Perl Shell
# 2005 <3 Dale
#

use strict;
my $shellver = "0.1";

unless( -t STDIN) {
	print "TurtleShell version $shellver\n";
	exit 0;
}

###############
#
# list of perl modules
#

## perl distro

use warnings;

## homemade
use pms::msg; 
msg_test();

use pms::lp;
use pms::kp;

use pms::bih;
use pms::bih_explorer;

use pms::turtle_key;
use pms::hotkey_to_english;
use pms::english_to_hotkey;

use pms::turtle_processor;

use pms::sneezy;

use pms::cmdlineargs;

use pms::quit;

my %startuphash = (
	wow => "unused"
);

#merge the commandline args
my $cmdhashref = cmdlineargs(\%startuphash,@ARGV);

###############
#
# main program body
#

msg "TurtleShell v. $shellver";

msg "Setting ReadMode to 4..", -1;
ReadMode 4;

msg "Entering main program loop.", 3;

my $k;
my $hotcake;
my $short_stack_ref;

$| = 1;

while(1) {
	
	#collect any keystrokes, and feed them into the keyprocessor
	$k = turtle_key();
	kp $k if $k;	

	#get any user inputs that are ready
	my $ready_cmds_array_ref = kp_serve();

	foreach $hotcake (@$ready_cmds_array_ref) {
		msg "Executing perl: $hotcake", 1;
		eval "{ $hotcake }";
	}
}

"Unreachable code reached......\n";

msg "Setting ReadMode to 1..", -1;
ReadMode 1;
msg "Program terminating abnormally.. ", 3;
exit(1);










