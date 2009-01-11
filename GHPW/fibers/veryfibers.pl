#!/usr/bin/perl
#
# Turtle Shell SneezyMUD Client
# You reconnected with negative hit points, automatic death RE-occurring.
#
# 2003-2005 <3 Dale
#

use strict;
my $turtlever = "0.9¹²³";

#SNUH
#AnotherSnuh

unless( -t STDIN) {
	print "TurtleShell version $turtlever\n";
	exit 0;
}

###############
#
# list of perl modules
#

## perl distro
#use IO; #for logfile flushing

use warnings;

## homemade
use pms::msg; 
#msg_test();

use pms::log;

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

msg "TurtleShell version $turtlever firing up..",  0;

my %startuphash = (
	login => "sneezy.login",
	server => "sneezy.saw.net",
	port => "7900",
	common => "turtleshell.common"
);

#merge the commandline args
my $cmdhashref = cmdlineargs(\%startuphash,@ARGV);

ssetserver($startuphash{server});
ssetport($startuphash{port});

###############
#
# main program body
#

msg "TurtleShell v. $turtlever";

msg "Setting ReadMode to 4..", -1;
ReadMode 4;

msg "Entering main program loop.", 3;

my $sneezy_in;
my $sneezy_out;
my $k;
my $hotcake;
my $short_stack_ref;

$| = 1;

while(1) {

	scheck();
	sget();
	kp($k) if defined($k=turtle_key()); 

	$short_stack_ref = kp_serve();
	
	foreach my $hotcake (@$short_stack_ref) {
		lp $hotcake;
	}

	$short_stack_ref = lp_serve();

	foreach $hotcake (@$short_stack_ref) {
		ssend($hotcake);
		msg "LP RETURNED $hotcake", 2
	}
}

print "Unreachable code reached......\n";

msg "Program terminating abnormally.. ", 3;
ReadMode 1;
exit(1);
