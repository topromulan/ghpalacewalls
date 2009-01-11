#!/usr/bin/perl

#
# Turtle Shell SneezyMUD Client
# You reconnected with negative hit points, automatic death occurring.
#
# February-November 2003
# Dale Anderson
# lime@lab.net
#
##################################################################

$turtlever = "0.8 duhh";

# // FINAL, ANNOTATED COPY
# // THIS IS ACTUALLY THE LAST WHOLE-FILE COPY
# // IT IS BEING RECODED INTO 1.0 VERSION "BEHIND THE SCENES"
# // BUT THIS ONE WORKS FINE

##################################################################

#configuration of sneezymud connection
#object from CPAN module representing telnet session
# www.cpan.org
use Net::Telnet;

$telnet = new Net::Telnet(Timeout =>10, ErrMode=>'return'); #, ErrMode=>'print "hi"');

use Term::ReadKey;
ReadMode 4;

#to allow logfile flushing, use IO
use IO;

use warnings;

#configuration of local output
#perl internal variable makes things print immediately (instead of waiting for newline)
$| = 1;
#we repeatedly enforce that this is 1 in the main program loop anyway
#it seems like some shell programs or system commands change it sometimes

#main 

#%aliases has of alias names to what to do
#%variables hash of variable names to values
#%triggers (hash of trigger names) to (hashes each must contain {regexp} and {trigger} key)
#%schedules (hash of sched names) to (hashes each must contain {seconds} and {commands} keys)
#%hotkeys hash of keycodes (single byte or ansi sequence) to command strings

sub kp; #work with keypunches to form lines etc.
sub lp; #interpret the users syntax, once parsed
sub vp; #substitute user defined $variables into place (overwrites $_[0])
sub isalias; #0 if not alias, -1 if is alias
sub isansi;  #0 if not ansi, -1 if so
sub ap; #handle commands that were aliases (mainly concerning alias arg passing)
sub sp; #review timed command queue (schedule process)
sub hk; #translate hotkey (an undefined or defined key outside the bounds of normal typing)

sub hotkey_add;          #example: hotkey_add 0x3, '#quit'  OR  hotkey_add "\x1b[2A", "#perl print 'whatever [2A does'"
sub hotkey_to_english;   #returns format 0x## for bytecode or ANSI ESC[(..) for ansi code
sub english_to_hotkey;   #returns a single byte or a packed ansi sequence from format 0x## or ESC[(..)

sub rp; #print (color) remote input also contains a couple hard coded features currently
sub tp; #scan plaintext version of remote input triggers processing
sub hp; #history processor !1 !r !ride !2ride etc

my @cmd_history;
sub history_add; #
$history_limit=1024;
$history_default=10;

sub turtle_process; #handle turtle shell internal commands (they start with #)

sub turtle_key;     #a nonblocking keygetting proc that returns a single byte or a multi byte ansi escape sequence

#routines for files loading and maintenance
sub save; #save a variable (if starts with $) $_[0] or alias to file $_[1] in current directory
sub load; #call lp with all goods from file $_[0]
sub cat; #prints filename and contents
sub ed; #can be used to customize files

#sub used for debugging
$NOISY = 0;  # non-zero value gives success messages when setting/doing certain things (annoying)

sub tmsg; #new routine for messages instead of print
          #usage:   tmsg "the message", (optional - volume - -1 low - default: 1)

sub tlog; #a routine that logs tmsgs

my $squelch = 0; 	#listen to all messages during startup
my $logging_squelch = 2; #default: record all but the most mundane and debug messages

#variable set when doing data entry by #lit on or #lit off
$literal = 0;

###########################
#                         #
###########################

#variables used by lp to prevent looping accidents
$recursionlevel=0;
$recursionlimit=10;
$recursionbusted=0; #if limit broke busted flag will cause all lp to pass until it is 0

$connected = 0;
$logged_in = 0;
$dumbtest = 0;  # -- you can test the shell with no network connection

#the time the last connection attempt occurred at (for pausing appropriately)
$autoconnecttimer=0;

lp "#ver";

## LOGGING STARTUP
#
#

LOGSTARTUP: {
	#check for log directory
	#
	#if it exists, keep logs
		
	$logging=1;
	
	opendir LOGDIR, "logs/" or $logging=0;
	@log_list=readdir(LOGDIR);
	closedir LOGDIR;
	
	if($logging) {
		#determine the number of the newest log
		my $highest_log=0;
		foreach my $temp (@log_list) {
			$temp =~ m/^Logfile\.([0-9]+).*/; #leave open ended in case of .gz'd files
			if(defined($1)) {
				if ( $highest_log < $1 ) {
					$highest_log = $1;
				}
			}
		}
	
		my $next_log = $highest_log + 1;
	
		tmsg "Creating Logfile.$next_log..\n", 2;
	
		open LOGFILE, ">> logs/Logfile.$next_log";
	
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	
		print LOGFILE "Logfile.$next_log started by TurtleShell on $wday $mon/$mday/$year at $hour\:$min\:$sec\n";
	
	} else {
		tmsg "You can activate logging by creating 'logs/' directory.\n", 1;
	}
	
}
	
##MAIN PROGRAM
#

load("common");

while(1) {

	my ($remote, $remote_plaintext);
	my $local;

	$|=1;

	#get remote info, and make copy into plaintext	
	if($connected) {
		$remote = $telnet->get(Timeout =>0);

		my $remote_plaintext;
		
		if (defined($remote)) {

			if($logging) {
				print LOGFILE $remote;
				flush LOGFILE;
			}

			$remote_plaintext=$remote;

			{
				# ESC [ [numbers & ;'s] [letter]
				$remote_plaintext =~ s/\x1B\[[0-9;]*[a-z]//ig;
				$remote_plaintext =~ s/\r//g;
			}

			#substitute a '#' for hex 'B2' sneezy uses in status guages
			$remote =~ s/\xB2/#/g;

			{
				rp $remote;
				#handle triggers on remote data
				tp($remote_plaintext);
				#log remote data
				#not implemented yet
			}
		}

		#$dumbtest can be set to 1 to use the shell alone
		unless($dumbtest) {
			if($telnet->eof) {
				tmsg "#Telnet connection broken\n", 3;
				my $currenttime=time();
				if( ($currenttime-$autoconnecttimer) < 2) {
					#don't try more than once a second
					sleep 1;
				}
				$connected=0;
			} 
		}

	} else {

		unless($dumbtest) {
			tmsg "autoconnecting..\n", 3;
			$telnet->open(Host=>'sneezy.saw.net', Port=>7900);
			$autoconnecttimer=time();
			$connected=1;
			$logged_in=0;
		}
	}

	#process any keystrokes
	my $k = turtle_key();
	kp($k) if defined($k);
	
	#process any schedules
	sp();

}

ENDCODE:

if($logging) {

	print LOGFILE "#TurtleShell shutting down normally.\n";

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

	print LOGFILE "#The time is $mon/$mday/$year $hour\:$min\:$sec\n";

	close LOGFILE;
}

tmsg "#Quitting now..\n", 10;
sleep 1;
ReadMode 1;
exit 0;

print "Unreachable code.. reached!\n";
return;



sub rp {

	my $arg = $_[0];

	#CUSTOM CRAFTED AUTO LOGIN METHOD!
	if($logged_in == 0) {
		if(rindex($arg, "Login: ") > 0) {
			select(undef,undef,undef,0.25); 
			my $result=0;
			open FILEIN, "<sneezy.login" or $result=-1;
			if($result == 0) {

				tmsg "#Login found\n", 1;
				tmsg "#Secretly passing user/pass info!\n", 1;
				my @loginpw = <FILEIN>;
				$telnet->print("$loginpw[0]\n$loginpw[1]\n\n");

			} else {

				tmsg "#Note: To enable auto login, store your username and then password in first two lines of sneezy.login\n", 1;

			}
			close FILEIN;
			$logged_in = 1; #or tried to anyway
		} 
	}

	#BECOME AS WISE AS THE OLD SAGE
	if(rindex($arg, "An old sage says,") > 0) {
		open FILEOUT,">>sage.out";
		print FILEOUT $arg;
		close FILEOUT;
	}

	
	print $arg unless ($arg eq "");	
}

#globals
# $kp_memory = current line
# $kp_pos = cursor position on current line

sub kp { 

	#takes a single character or an ANSI sequence

	unless(defined($_[0])) {
		tmsg "#Internal Error: kp called without argument\n", 0;
		return;
	}

	unless(defined($kp_memory)) {
		$kp_memory=""; #a memory of the users line of typing
	}
	
	my $key = $_[0];

	#put this long regexp into a variable at top
	#implement #key define (#key define ctrl-f 0x6)	
	#these are "normal" keys
	if($key =~ m/^[A-Za-z0-9\ \;\:\~\`\!\@\#\$\%\^\&\*\(\)\-\_\+\=\\\|\[\]\{\}\'\"\,\.\<\>\/\?]$/) {

		print "$key";
		$kp_memory .= $key;

	} elsif ($key =~ m/[\n\r]/) {

		print "\n";
		$kp_memory .= "\n";
		lp "$kp_memory";
		history_add $kp_memory;
		$kp_memory="";

	} else {		
		
		#notes
		# ^R = 0x12
		# ^C = 0x3
		# bs = 0x7f (0x8 on robs n' marors)
		# ^U = 0x15

		if($key eq "\x12") {
			
			#this is the line redraw, ^R
			print "^R\n$kp_memory";
			
		} elsif ($key eq "\x15") {

			#this is the line erase, ^U
			$kp_memory = "";
			print "^U\n";

		} elsif ($key =~ m/^[\x7f\x08]$/) { # BACKSPACE: 0x8 on Maror's Macs & Windoze, 0x7f on Debian
			
			if(length($kp_memory) > 0) {
				$kp_memory =~ s/.$//;
				print "\x1b[D \x1b[D"; #left, space, left
			}

		} elsif ($key eq "\x3") {

			goto ENDCODE;
			
		} else {
			
#			printf "(0x%x)", ord($key);
			
			hk $key;
		}

	}


}

sub lp {
	$recursionlevel++;
	#to ensure recursionlevel is --'d, using "last LPBLOCK" instead of returns
	LPBLOCK: {
	############
		my $arg = $_[0];
		
		#CHECK RECURSION LEVEL
		{
			tmsg "#Input proc. recursion level: $recursionlevel\n", -1;
			if($recursionlevel>$recursionlimit) {
				tmsg "#TurtleShell recursion limit $recursionlimit busted! Did you write a loop?\n", 10;
				$recursionbusted=1;
			}
			if($recursionbusted) {
				last LPBLOCK;
			}
		}
		
		#CHECK IF IT IS ANYTHING
		{
			if(($arg eq '')) {
				last LPBLOCK;
			} elsif(!defined($arg)) {
				last LPBLOCK;
			}
		}

		#REMOVE LEADING OR TRAILING SPACES, and FINAL NEWLINE
		{
			$arg =~ s/^\s*//;
			$arg =~ s/[\s\n]*$//;
		}

		#IS THIS A .."TURTLE COMMAND?"
		{
			if(substr($arg,0,1) eq '#') {
				turtle_processor($arg);
				last LPBLOCK;
			}
		}

		#IS THIS A .."REPEAT COMMAND"
		{
			if(substr($arg,0,1) eq '!') {
				hp($arg);
				last LPBLOCK;				
			}			
		}

		#IS THIS A .."& COMMAND"
		{
			#if begins with &, then append it to what is saved and execute it
			# (which if it also ends in a & the combined will then be saved)
			if($arg=~m/^&/) {
				$arg=~s/^&//;
				if(!defined($variables{"&"})) {
					tmsg "TurtleShell Error - no \$& variable defined to append that to\n", 10;
					last LPBLOCK;
				}
				lp($variables{"&"} . $arg);
				last LPBLOCK;
			}				

			#if it ends with &, save it as $&
			if($arg=~m/&$/) {
				$arg=~s/&$//;
				tmsg "Saved partial statement to \$& - begin with & to end statement later\n", 1;
				$variables{"&"}=$arg;
				last LPBLOCK;
			}
		}				

		#CHECK IF SPECIFIED MULTIPLE TIMES
		{
			if($arg =~ m/^[0-9]+\*/) {
				tmsg "#Repetition #* specified", -1;				
				
				my $t=$arg;
				my $numtimes='';
				$t =~ s/^[0-9]+\*//; #Matches any num 0-9's followed by a *
				$numtimes=$&; 	   #Internal perl variable for what matched
				$numtimes=~s/\*$//;  #Remove trailing *
				
				if($numtimes >= 1) {
					tmsg "#Repeating command $numtimes times\n", -1;

					for(my $i=0;$i<$numtimes;$i++) {
						lp($t)				
					}		
					last LPBLOCK;
				}
			}
		}

		#SPLIT BY ";" AND RECURSE ON MULTIPLE ONES ASSES, AND RETURN
		{
			my @semicolonsplit=split(";", $arg);
			my $tmp=@semicolonsplit; #counts the lines
			if($tmp > 1) {
				LOOP: for(my $i=0; $i<$tmp; $i++) {
					#if it's a say then join the rest back together and say it;
					#in case i was using a grammatical semicolon
					#actual say statements can be split by using say isntead of '
					if (substr($semicolonsplit[0],0,1) eq "'") {
						$telnet->print(join(';', @semicolonsplit));
						last LOOP;
					}
					#else process it and continue
					lp(shift(@semicolonsplit));
				}
				last LPBLOCK;
			}
		}

		#CHECK FOR CSV
		{
			if(rindex($arg,',')>0) {
				unless(substr($arg,0,1) eq "'") {
					tmsg "#Comma Seperated Values detected ($arg)\n", -1;
					my @wordsplit=split(' ',$arg);
					my $wordcount=@wordsplit;
					my $str='';
					WORD: while (1) {
						#if it has no commas, append it to $str and move on
						unless(rindex($wordsplit[0],',') >= 0) {
							$str.=shift(@wordsplit);
							$str.= ' ';
							next WORD;
						} 
						#shift the word with csv's off wordsplit and split it up
						my @commasplit=split(',',shift(@wordsplit));
						#recurse on each csv, subsequent csv's will be picked up by them			
						foreach my $csv (@commasplit) {
							#pointless words picked up so far + each csv + rest if any
							my $foo=$str . "$csv " . join(' ',@wordsplit);
							$foo =~ s/$ //; #remove trailing space if there is one from blank join
							lp($foo);
						}
						last WORD;					
					}
					last LPBLOCK;
				}		
			}	
		}
		
		#SUBSTITUTE ANY VARIABLES
		vp($arg);

		#CHECK IF THIS IS AN ALIAS, IF SO CALL ap AND RETURN
		if(isalias($arg)) {
			ap($arg);
			last LPBLOCK;
		 } 

		#GENERAL PURPOSE
		#
		tmsg "\n#Sending \"$arg\"\n", 0;
		$telnet->print($arg);
		#
	############
	} #end of LPBLOCK

	#REDUCE RECURSION LEVEL
	$recursionlevel--;

	if($recursionbusted) {
		if($recursionlevel<=0) {
			tmsg "#Recursion level reset to 0 - ending bust\n", 1;
			$recursionlevel=0;
			$recursionbusted=0;
		}
	}
}

sub ap {
	my $arg = $_[0];
	my @breakout = split(' ', $arg);

	unless(isalias($breakout[0])) {
		tmsg "#TurtleShell Internal Error\n",
		tmsg "#ap was called with $breakout[0] (but that's no alias)\n\n";
		return
	}
	
	#my $template = $aliases{$breakout[0]};
	
	#shift the first word off the array and look up its alias value 'template'
	my $template = $aliases{ shift(@breakout) };

	#the number of elements left in @breakout
	my $count = @breakout;

	#a variable represents how many $1 $2 etc args were used
	# (as the cutoff point for $*)
	my $lastused = 0;
	
	for(my $i = 1; $i<=$count; $i++) {
		
		#'move' any escaped instances out of the way
		$template =~ s/\\\$$i/1234TEMPORARY_STRING_USED_IN_AP/g;

		#replace any remaining instances
		$template =~ s/(\$$i)/$breakout[$i-1]/g;

		if(defined($1)) {
			$lastused=$i;
		}

		#replace escaped instances without the \
		$template =~ s/1234TEMPORARY_STRING_USED_IN_AP/\$$i/g;

	}

	#remove the number of arguments that alias uses
	for(my $i = 1; $i<=$lastused; $i++) {
		shift(@breakout);
	}

	my $remainder = join(' ', @breakout);

	#hide any escaped instances
	$template =~ s/\\\$\*/1234TEMPORARY_STRING2_USED_IN_AP/g;
	#replace instances
	$template =~ s/(\$\*)/$remainder/g;
	#if there were none append them instead
	unless(defined($1)) {
		$template .= " $remainder";
	}
	#replace hidden escaped instances without the \
	$template =~ s/1234TEMPORARY_STRING2_USED_IN_AP/\$\*/g;

	lp $template;
	return;

}
	
sub isalias {
#	my $jerk;

	my @tmp=split(' ', $_[0]);
	
	unless(defined($tmp[0]) > 0) {
		return 0;
	}

	my $oneword=$tmp[0];

	if(defined($aliases{$oneword})) {
		return -1; #yes
	}	
	return 0; #no
}

sub isansi {

	unless(defined($_[0])) {
		tmsg "#Internal error. sub inansi() called with no argument.";
	}

	my $horse = $_[0];

	if( $horse =~ m/\x1b\[.+/ ) {
		return -1;
	} else {
		return 0;
	}
}

sub hk {
	
	unless(defined($_[0])) {
		tmsg "#Internal Error: hk called with no arguments\n";
		return;
	}
	
	my $mykey = $_[0];

	unless(defined($hotkeys{$mykey})) {
		#use print to avoid logging these..
		printf "#That key %s has no meaning.\n", hotkey_to_english($mykey);
		return;
	}
	
	#success mode
	
	tmsg "#Hotkey recognized!\n", 1;
		
	lp $hotkeys{$mykey};		
	
}

#a sub to return 0x## or ESC[(...) based on a turtle_key result
sub hotkey_to_english {

	unless(defined($_[0])) {
		tmsg "#Internal error. hotkey_to_english() called with no argument!\n";
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

sub english_to_hotkey {

	unless(defined($_[0])) {
		tmsg "#Internal error. english_to_hotkey() called with no argument!\n";
		return;
	}

	my $str = $_[0];

	if($str =~ s/^esc\[//i) {
		#ansi
		return "\x1b[$str";
	}

	$str =~ s/^0x//i; #remove optional 0x from bytecode

	if($str =~ m/[0-9A-F]+/i) {
		#its a hex bytecode
		return chr(hex($str));
	}

	return;
}

sub hotkey_add {
	
	unless(defined($_[0]) && defined($_[1])) {
		tmsg "#Internal Error: hotkey_add called with no argument.\n";
		return;
	}
	
	unless(length($_[0]) == 1) {
		unless(isansi($_[0])) {
			tmsg "#Internal Error: hotkey_add called with non-ANSI >1 character first arg.\n";
			return;
		}
	}
	
	my $mykey=$_[0];
	my $mystr=$_[1];
	
	my $keydesc=hotkey_to_english($mykey);

	if(defined($hotkeys{$mykey})) {
		tmsg "#Overwriting hotkey at $keydesc\n", 0;
	} else {
		tmsg "#Adding new hotkey at $keydesc\n", 0;
	}
	
	$hotkeys{$mykey} = $mystr;
	
}

sub vp {
		#SUBSTITUTE ANY VARIABLES INTO PLACE
		my $t = $_[0];

		foreach my $pothead (%variables) {
			#temporarily 'move' any occurances that are prepended with a \
			$t =~ s/\\\$$pothead/1234TEMP_INTERNAL_VAR_USED_BY_VP/g;
			#subsititue variable value for those that are not
			$t =~ s/\$$pothead/$variables{$pothead}/g;
			#replace the ones with \'s without their \'s
			$t =~ s/1234TEMP_INTERNAL_VAR_USED_BY_VP/\$$pothead/g;
		}

		#modify the passed argument
		$_[0]=$t;
}

# $tp_memory
sub tp {

	unless(defined($_[0])) {
		return;
	}
	
	my $plaintextinfo=$_[0];

	#to not break triggers if they printed on the same line with your prompt
	#remove pattern matching and any whitespace after >
#	print "testing $plaintextinfo\n";
	
	foreach my $line (split("\n", $plaintextinfo)) {
		$line=~s/^[A-Z0-9,:\s]*>\s*//ig;
		foreach my $trig (keys %triggers) {
			if($line=~m/$triggers{$trig}{regexp}/i) {
				print "\n#Triggered $trig\n" if $NOISY;
				lp($triggers{$trig}{trigger});
			} 
		}
	}
}

#schedule process
sub sp {
	#The skies brighten as dawn begins.

	my $whatever=time();
	
	foreach $like (keys %schedules) {
		if($schedules{$like}{seconds} <= $whatever) {
			print "#Time is ", time(), " - time for $like!\n" if $NOISY;
			print "#Executing: $schedules{$like}{commands}\n" if $NOISY;
			lp($schedules{$like}{commands});
			delete $schedules{$like};
		}		
	}	
}

sub hp {
	
	$arg = $_[0];
	unless($arg =~ m/^!/) {
		print "#TurtleShell Internal Error\n",
				  "#hp was called with bad format - $arg\n\n";
		return
	}
	
	#take it off
	$arg =~ s/^\!//;
	
	#identify and strip out if specified number back into history or default to 1
	# example> !2get
	if(($arg =~ s/^([0-9]+)//)) {
		$historyhop=$1;
	} else {
		$historyhop=1;
	}
	
	tmsg "#Searching into history for $arg with historyhop $historyhop\n", -1;
	my $hitcount=0;
	for(my $t=0; $t<@cmd_history; $t++) {
		if($cmd_history[$t] =~ m/^$arg.*/) {
			$hitcount++;
		}
		
		if($hitcount == $historyhop) {
			tmsg "#History match: $t - $cmd_history[$t]", 0;
			lp($cmd_history[$t]);
			return;
		}
	}
	
	print "\n#No such match in history\n";
}

sub history_add {
	
	$arg=$_[0];

	#unless this command is destined to be processed by our brother function hp...
	if($arg =~ m/^!/) {
		return;
	}
	
	unshift @cmd_history, ($arg);
	
	while(@cmd_history > $history_limit) {
		tmsg "Scrolling History..", -1;
		pop @cmd_history;
	}	
}

sub tmsg {
	
	#this new routine to use instead of print
	#
	
	#	-1	debug info
	#	0	useless info
	#	1	FYI info
	#	2	slightly more useful info
	#	3+	error info
	#
	#
	
	unless(defined($_[0])) {
		
		print "#\n";
		return;
	}

	my $str = $_[0];

	$str .= "\n" unless ($str =~ m/\n$/); #add \n unless they wrote it on
	#$str =~ s/\n+$/\n/; #compact multiples into 1
	$str = "#" . $str unless $str =~ m/^\#/; #add # unless they wrote it on

	my $loudvol = 1;
	$loudvol = $_[1] if defined($_[1]);


	my $ternary_toprint = 1;

	$ternary_toprint = ( defined($squelch) ? ( $loudvol >= $squelch ) : -1 ); #default = true

	printf "# %2d $str", $loudvol if $ternary_toprint;

	#pass the information to the logging sub
	#
	#tlog $str, $loudvol if $logging;
}

sub tlog {

	#NOT DONE
	tmsg "Error - tlog() not implemented", 50;
	return;

	#save a tmsg
	#
	
	my $str = (defined($_[0]) ? $_[0] : "");

	my $loudvol = (defined($_[1]) ? $_[1] : 1);

	#from perl doc:
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

	my $timestamp = sprintf "%2d/%2d/%2d %2d:%2d:%2d", $mon, $mday, $year, $hour, $min, $sec;

	my $loglines = "#tlog($loudvol/$logging_squelch)# $timestamp # $str\n";

	if($logging) {
		
		print LOGFILE $loglines if($loudvol >= $logging_squelch);

	} else {
		
		print "#Since \$logging is OFF, sending tlog() sub's information to screen:\n";
		print $loglines;
	}
}




		

sub turtle_processor {
	my $arg = $_[0];
	
	#verify action required
	if(substr($arg,0,2) eq "##") { #then its just a comment
		return
	}

	$arg =~ s/\n//;
	@breakout = split(' ', $arg);
	
	#set $cmd the main word of the command and remove it from breakout
	my $cmd = shift(@breakout); 
	#set argmeat to the rest of breakout for CONVENIENCE
	my $count = @breakout; #num elements
	my $argmeat=join(' ', @breakout);
	
	if($cmd eq "#status") { 					#USELESS - STATUS
		print "\n#Presumably well and good\n"
	} elsif($cmd eq "#disc") {					#WORKING - DISCONNECT
		tmsg "TurtleShell is Severing the Telnet Connection";
		$telnet->close();	
	} elsif($cmd eq "#alias") {								#WORKING - ALIAS
		if($count < 2) {
			print "#TurtleShell Syntax Error!\n#alias (one word alias) whatever..\n\n";
			return;
		}
		#try to do it!
		{
			my $aliasname = shift(@breakout); #yoink name
			$aliases{$aliasname} = join(' ', @breakout); #assign rest to alias
			print "#Set $aliasname to $aliases{$aliasname}.\n" if $NOISY;
		}		
	} elsif($cmd eq "#set") { 						#WORKING - SET
		if($count < 2) {
			print "\n#TurtleShell Syntax Error\n#set (one word variable) whatever..\n\n";
			return;
		}
		#success mode
		{
			my $varname = shift(@breakout); #yoink the first one
			if(substr($varname,0,1) eq '$') { 
				#i may or may not have typed the $ get rid of it
				$varname=~s/\$//;
			}
			$variables{$varname} = join(' ', @breakout); #assign that one in variables to rest
			print "#Set \$$varname to ", $variables{$varname}, ".\n" if $NOISY;
		}
	} elsif($cmd eq "#trig") { 						#WORKING - TRIGGER
		unless($count >= 3) {
			print "\n#TurtleShell Syntax Error\n#trigger (triggername) (regexp) whatever..\n\n";
			return;
		}
		#check first argument (friendly name) is plaintext, in case it was left out and regexp was put
		unless($breakout[0] =~ m/^[a-z1-9\.\-]*$/i) {
			print "\n#TurtleShell Argument Error: Trigger friendly name, first arg, must be plain text\n\n";
			return;
		}
		#success mode
		{
			my $trigname = shift(@breakout); #yoink the first one
			if(substr($trigname,0,1) eq '!') { 
				#may or may not have typed the ! get rid of it
				$trigname=~s/!//;
			}
#			my $trigexp = shift(@breakout); #second one is regexp
			$triggers{$trigname}{regexp} = shift(@breakout);
			$triggers{$trigname}{trigger} = join(' ', @breakout);
			print "#Set !$trigname for ", $triggers{$trigname}{regexp}, ".\n" if $NOISY;
			print "#Set !$trigname to ", $triggers{$trigname}{trigger}, ".\n" if $NOISY;
		}
	} elsif($cmd eq "#sched") { 						#WORKING - SCHED
		unless($count >= 3) {
			print "\n#TurtleShell Syntax Error\n#sched (friendly name) (seconds from now) (..commands..)\n";
		}
		my $sched_name = shift(@breakout);
		$schedules{$sched_name}{seconds}=time()+shift(@breakout);
		$schedules{$sched_name}{commands}=join(' ', @breakout);
		
		print "\n#Scheduled $sched_name for $schedules{$sched_name}{seconds}\n" if $NOISY;

	} elsif($cmd eq "#clear") {		#WORKING - CLEAR
		unless($count == 1) {
			print("\n#TurtleShell Syntax Error\n#clear (one word alias, !trigger, \$variable, or \@schedule)\n\n");
		}
		if($argmeat =~ s/^\$//) {

			unless(defined($variables{$argmeat})) {
				print ("\n#TurtleShell did not find that variable (\$$argmeat) to clear\n\n");
				return;
			}

			delete $variables{$argmeat };
			print ("\n#Cleared variable \$$argmeat\n");

		} elsif($argmeat =~ s/^\!//) {

			unless(defined($triggers{$argmeat})) {
				print ("\n#TurtleShell did not find that trigger (!$argmeat) to clear\n\n");
				return;
			}

			delete $triggers{$argmeat };
			print ("\n#Cleared trigger !$argmeat\n");

		} elsif($argmeat =~ s/^\@//) {

			unless(defined($schedules{$argmeat})) {
				print ("\n#TurtleShell did not find that schedule (\@$argmeat) to clear\n\n");
				return;
			}

			delete $schedules{$argmeat };
			print ("\n#Cleared schedule \@$argmeat\n");

		} elsif($argmeat =~ s/^\*//) {

			my $tmp = english_to_hotkey($argmeat);

			unless($tmp) {
				print "\n#Invalid syntax for hotkey clearing! Must be hex number or ansi style (like ESC[B for example)\n";
				return;
			}

			unless(defined($hotkeys{$tmp})) {
				print "\n#TurtleShell did not find that hotkey (*$argmeat) to clear\n\n";
				return;
			}

			delete $hotkeys{$tmp};
			print "\n#Cleared hotkey *$argmeat\n";

		} else {

			unless(defined($aliases{$argmeat})) {
				print ("\n#TurtleShell did not find that alias ($argmeat) to clear\n\n");
				return;
			}

			delete $aliases{ $argmeat };
			print ("\n#Cleared alias $argmeat\n");
		}
		return;
	} elsif($cmd eq "#clearall") {
		print "#Clearing all\n";
		undef(%aliases); 
		undef(%variables);
		undef(%triggers);
#		undef(%monitors);
		undef(%schedules);
		undef(%hotkeys);
	} elsif($cmd eq "#reset") {
		turtle_processor("#clearall");
		load("common");
	} elsif($cmd eq "#list") {

		#new list logic:

		if($count > 1) { 
			print "\n#TurtleShell Syntax Error\n";
			print "#list [default=all or alias, \$variable, *hotkey, \@schedule, or !trigger]\n";
			print "#  (pattern matching allowed)\n";
		}

		my $all=0; $all=1 unless $count;

		LISTBLOCK: {

			if( ($argmeat =~ m/^[a-z]/) or ($all) ) {
				
				print "#TurtleShell - Aliases List\n";
				print "# ---\n";

				for my $w(keys %aliases) {
					
					if($w =~ m/^$argmeat/i) {
						
						print " $w = $aliases{$w}\n";
					}

				}

				print "\n";

			} if ( ($argmeat =~ s/^\$//) or ($all) ) {

				print "#TurtleShell - Variables List\n";
				print "# ---\n";

				$argmeat =~ s/^\$//; #remove the indicator for the pattern match

				for my $w(keys %variables) {

					if($w =~ m/^$argmeat/) {
						
						print " \$$w = $variables{$w}\n"

					}
				}

				print "\n";

			} if ( ($argmeat =~ s/^\*//) or ($all) ) {

				print "#TurtleShell - Hotkeys List\n";
				print "# ---\n";

				$argmeat =~ s/^0x//i;    #remove optional 0x
				$argmeat =~ s/^esc\[//i; #remove optional ansi escape

				for my $w(keys %hotkeys) {
					
					if(isansi($w)) {
						#compare the ansi codes
						if ( $w =~ m/\x1b\[$argmeat/i or $all) {

							my $tmp = $w;
							$tmp =~ s/^\x1b//;
							printf " *ESC%s - %s\n", $tmp, $hotkeys{$w}
						}

					} else {	
						#compare between the value of the hotkey byte and the text the user typed
						if ( ( $argmeat == ord($w) ) or $all) {
						
							printf " *0x%x - %s\n", ord($w), $hotkeys{$w};
						}
					}
				}
				 
				print "\n";

			} if ( ($argmeat =~ s/^\!//) or ($all) ) {

				print "#TurtleShell - Triggers List\n";
				print "# ---\n";

				foreach my $w (keys %triggers) {

					if ( ( $w =~ m/^$argmeat/ ) or $all ) {

						print " !$w = $triggers{$w}{regexp} = $triggers{$w}{trigger}\n";

					}
				}

				print "\n";
			
			} if ( ($argmeat =~ s/^\@//) or ($all) ) {

				print "#TurtleShell - Schedules List\n";
				print "# ---\n";

				foreach my $w(keys %schedules) {
					
					if ( ( $w =~ m/^$argmeat/ ) or $all ) {

						print " \@$w in ", ( $schedules{$w}{seconds} - time() ), " seconds! ($schedules{$w}{commands})\n";

					}

				}

				print "\n";
			}

		}


	} elsif($cmd eq "#save") {
		if($count != 2) {
			print "\n#TurtleShell Syntax Error\n#save (var or alias name) (file)\n\n";
			return;
		}
		save($breakout[0], $breakout[1]);
	} elsif($cmd eq "#load") {
		unless($count == 1) {
			print "\n#TurtleShell Syntax Error\n#load (file)\n\n";
			return;
		}
		load($argmeat);		
	} elsif($cmd eq "#cat") {
		unless($count == 1) {
			print "\n#TurtleShell Syntax Error\n#cat (file)\n\n";
			return;
		}
		cat($argmeat);
	} elsif($cmd eq "#ed") {
		unless($count >= 3) {
			print "\n#TurtleShell query: did you mean to type #help ed?\n\n";
			return;
		}
		ed($argmeat);			
	} elsif($cmd eq "#hist") {
		if($count == 0) {
			$histrange=$history_default
		} elsif($argmeat eq "all") {
			$histrange=@cmd_history;
		} elsif($argmeat =~ m/^([0-9]+)$/) {
			$histrange=$1;
		} else {
			print "#TurtleShell Syntax error!\n",
				  "#hist (length or 'all')\n";
			return;
		}
		my $histlength=@cmd_history;
		if($histrange > $histlength) {
			tmsg "#Reducing amount of history to show\n", -1;
			$histrange = @cmd_history;
		}	
		print "\n# Your command history\n";
		print "#\n";
		for(my $t=$histrange; $t>0; $t--) {
			printf "%-6s %s", ('!' . $t), $cmd_history[$t-1];
		}
		print "#\n";
		print "# $histlength lines stored\n";
	} elsif($cmd eq "#lit") {
		if($count==0) {
			#well i'll just fudge in the defaults
			$argmeat = "on";
			$count = 1;
		} 
		if($count==1) {
			if($argmeat =~ m/^on$/i) {
				if($literal != 0) {
					print "#Literal mode already enabled..\n";
					return;
				}
				print "#Literal mode entered..\n";
				$literal=1;
				return;
			} elsif ($argmeat =~ m/^off$/i) {
				if($literal == 0) {
					print "#Literal mode already disabled..\n";
					return;
				}
				print "#Literal mode left..\n";
				$literal=0;
				return;
			}
		} 
		#If this point reached. Then execute arguements literally
		#
		# as a "one liner"
		#
		$telnet->print($argmeat)
		#
		#


	} elsif($cmd eq "#quit") {

		goto ENDCODE;

	} elsif($cmd eq "#key") {
		
		if($count == 0) {
			
			print "#Usage:\n#key (hex) ..commands..\n - or \n#key test\n";
			return;
		} elsif($count == 1) {
			
			unless($argmeat eq "test") {
				print "#Usage:\n#key (hex) ..commands..\n - or \n#key test\n";
				return;
			}
			
			#do a readkey and tell them what it said
			#mainly to find the code to clear a key
			print "#Program paused - strike a key now!\n";
			my $nug;
			$nug = turtle_key(0); #Blocking mode
			
			printf "#That key equals %s\n", hotkey_to_english($nug);
			
			return;
			
		} else {
			
			$argmeat =~ s/^([a-z0-9\[\x1b\~\;]+)\s//i; #seperate the first word - include any allowable characters [ ; ESC etc.
			my $firstword = $1;

			$firstword =~ s/^0x//;
			$firstword =~ s/^esc\[/\x1b\[/i;

			if(isansi($firstword)) {

				print "#Adding ANSI hotkey\n" if $NOISY;
				hotkey_add $firstword, $argmeat;

				return;

			} elsif ($firstword =~ m/^[0-9A-F]+$/i) {

				print "#Adding bytecode hotkey\n" if $NOISY;
				hotkey_add chr(hex($firstword)), $argmeat;

				return;

			} else {
				print "#Invalid syntax for hotkey adding\n";

				return;
			}
		}
				
	} elsif($cmd eq "#ver") {

		my $ternary_result = ( defined($turtlever) ? $turtlever : "Official Version" );

		print 	"#TurtleShell, Version $ternary_result\n",
		      	"#GNU License, etc.\n",
		 	"#First released in February 2003.\n",
		 	"#\n",
		 	"#TurtleShell perl shell for SneezyMUD Telnet Game\n",
			"#\n";

	} elsif($cmd eq "#print") {

		print "#$argmeat\n";

	} elsif($cmd eq "#squelch") {

		if($count == 0) {

			tmsg "Current Shell Messages Squelch Setting: $squelch", 10;
			return;

		}

		if($count == 1) {

			tmsg "Adjusting Shell Squelch to $argmeat";
			$squelch = $argmeat;
			return;

		}

		tmsg "Syntax: #squelch [number]", 2;
		return;


###########TEMPLATE FOR MORE#############
#	} elsif($cmd eq "#mycommand") {
#	} elsif($cmd eq "#mycommand") {
#	} elsif($cmd eq "#mycommand") {
#	} elsif($cmd eq "#mycommand") {
#############################################
	} elsif($cmd eq "#help") {
		if($count) {	#possibly the user wanted #help ed
			if($breakout[0] eq 'ed') {
				print 
					"# Here is the help you requested on ed\n",
					"#ed (file) (cmd) (number) (possibly more text)\n",
					"#\n",
					"# First obtain current line numbers by doing\n",
					"#cat (file)\n",
					"#\n",
					"# To delete line 6 of thegodfather\n",
					"#ed thegodfather d 6\n",
					"#\n",
					"# To append \"shout i am TheGodfather\"\n",
					"#ed thegodfather a shout i am TheGodfather\n",
					"#\n",
					"# To insert \"Now Loading Common Aliases!\" when common is loaded\n",
					"#ed common i 1 #perl print \"Now Loading Common Aliases!\"\n",
					"\n";
				return;
			}
		}
		
		print
			"\n",
			"##########################\n",
			"#  SneezyMUD perl client          #\n",
			"##########################\n",
			"#\n",
			"#set (var) (value)\n",
			"#alias (alias) (desired)\n",
			"#   note: argument handling such as \$1 or \$2 supported\n",
			"#trig (friendly name) (perl regular expression) ..actions..\n",
			"#sched (friendly name) (seconds from now) ..actions..\n",
			"#key (byte code or ANSI sequence) ..actions..\n",
			"    note: use '#key test' to find out the code for the desired key\n",
			"#clear (\$var, alias, !trigger, \@schedule, or *hotkey)\n",
			"#clearall\n",
			"#list\n",
			"#reset\n",
			"#   note: deletes all aliases and variables, and reload common\n",
			"#perl (you choose)\n",
			"#   note: will evaluate perl code\n",
			"#verbose (used only for bug finding)\n",
			"#\n",
			"#save (\$var, alias, or !trigger) (file)\n",
			"#load (file)\n",
			"#ed (file) (type #help ed for details)\n",
			"#   note: quote unquote files are turtleshell.whateveryoucallthem,\n",
			"#                     in the current directory\n",
			"#\n",
			"#      **WARNING CD INTO THE CORRECT DIRECTORY BEFORE STARTING**\n",
			"#\n",
			"# Thanks for using TurtleShell - better help available on the SneezyMUD forums thread\n",
			"#\n",
			"##########################\n";
			
			
	} elsif($cmd eq "#perl") {
		tmsg "Evaluating Perl Code: $argmeat", 0;
		eval "{ $argmeat }";
	} else {
		print "#TurtleShell Error\n";
	}

}


sub turtle_key {

	my $rkarg;

	#if an arg was passed, use it for readkey setting, default to miniscule value
	# (problems with nonblocking -1 mode)
	#
	if(defined($_[0])) {
		$rkarg = $_[0];
	} else {
		$rkarg = 0.0001; # -1 nonblocking mode not work correctly on fizzy 
	}
		
	
	my $keypunch;

	$keypunch=ReadKey($rkarg); 

	unless(defined($keypunch)) {
		return;
	}

	if($keypunch eq "\x1b") {
		#check for more to pick up if any ansi sequence
		#k
		ANSI_HUNT: {
			while(1) {
				my $tmp = ReadKey(0.0001);

				unless($tmp) {
					last ANSI_HUNT;
				}
	
				$keypunch .= $tmp;
			}
		}
	}

	return $keypunch;

}


sub save {
	my $what = $_[0];
	my $where = $_[1];

	open(FILEOUT, ">> turtleshell.$where");

	if(substr($what,0,1) eq '$') { #variable
		$what =~ s/\$//; #go ahead and get that $ out of there
		unless(defined($variables{$what})) {
			print "#TurtleShell says, \"Invalid!\"\n#\$$what is no variable!\n\n";
		} else {
			print "#Appending var \$$what to file $where\n";
			print FILEOUT "#set $what $variables{$what}\n";
		}
	} elsif(substr($what,0,1) eq '!') { #trigger
		$what =~ s/!//; #remove !
		unless(defined($triggers{$what})) {
			print "#TurtleShell says, \"Invalid!\"\n#!$what is no trigger!\n\n";
		} else {
			print "#Appending trigger !$what to file $where\n";
			print FILEOUT "#trig $what $triggers{$what}{regexp} $triggers{$what}{trigger}\n";
		}	
	} elsif(substr($what,0,1) eq '*') { #hotkey
		$what =~ s/\*//;
		$what = chr(hex($what));
		unless(defined($hotkeys{$what})) {
			print "#Turtleshell says, \"Invalid!\"\n#0x%x is no hotkey!\n";
		} else {
			printf "#Appending hotkey *0x%x to file $where\n", ord($what);
			printf FILEOUT "#key %s %s\n", hotkey_to_english($what), $hotkeys{$what};
		}
	} else { #alias
		unless(defined($aliases{$what})) {
			print "#TurtleShell says, \"Invalid!\"\n#$what is no alias!\n\n";
			return;
		} else {
			print "#Appending alias $what to file $where\n";
			print FILEOUT "#alias $what $aliases{$what}\n";
		}
	}

	close(FILEOUT);
}

sub load {

	print "#Loading turtleshell.$_[0]\n";
	
	my $err=0;
	open(FILEIN, "< turtleshell.$_[0]") or $err=1;
	
	if($err == 1) {
		print "#Error opening turtleshell.$_[0]\n";
		return;
	}
	
	my @bunch = <FILEIN>;
	close(FILEIN);
	
	foreach my $one (@bunch) {
		unless($one =~ m/^\s+$/) {
			lp($one);
		}
	}
}

sub cat {
	open(FILEIN, "< turtleshell.$_[0]");
	my @stuff = <FILEIN>;
	close(FILEIN);
	
	print "#  -  turtleshell.$_[0]  -\n";
	my $i = 0;
	foreach my $w (@stuff) {
		$i++;
		printf "%4d - $w", $i;		
	}
	print "\n#  -  turtleshell.$_[0]  -\n";	
	
}

sub ed {
	my $args = $_[0];
	my @breakout = split(' ', $args);

	my $filename = "turtleshell." . shift(@breakout);	
	open(FILEIN, "< $filename");
	my @workfile = <FILEIN>;
	close(FILEIN);
	my $numlines = @workfile;
	
	my $cmd = substr($breakout[0], 0, 1); #use first letter of command
	shift(@breakout); #get it out of here!
	my $count = @breakout; #num args
	
	if($cmd eq 'd') {			#DELETE
		my $linenum = shift(@breakout);
		if( ($linenum > 0) && ($linenum <= $numlines) ) {
			print "\n#ed deleting line $linenum of $filename\n\n";
			delete $workfile[$linenum-1];
		} else {
			print "\n#ed had a problem doing that\n\n";
			return;
		}
	} elsif($cmd eq 'a') {		#APPEND
		print "\n#ed will append what you said to the end of $filename\n\n";
		push(@workfile, join(' ', @breakout) . "\n");
		#that oughta do it
	} elsif($cmd eq 'i') {		#INSERT
		my $linenum = shift(@breakout);
		if( ($linenum > 0) && ($linenum <= $numlines) ) {
			print "\n#ed inserting that before line $linenum of $filename\n\n";
			$workfile[$linenum] = join(' ', @breakout) . "\n" . $workfile[$linenum];
		} else {
			print "\n#ed had a problem doing that\n\n";
			return;
		}		
	} else {
		print "\n#ed had no idea what command starts with $cmd, type #ed help for hint!\n\n";
		return;
	}		
	
	#if this point is reached we are going to assume it worked and overwrite the file

	open FILEOUT, "> $filename";
	foreach $w (@workfile) {
		unless($w eq '') {
			print FILEOUT $w;
		}
	}	
	close FILEOUT;

	$filename =~ s/turtleshell.//; #cat just wants the last part
	cat($filename);	
}

