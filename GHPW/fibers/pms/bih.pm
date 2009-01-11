


#######
# block input handler
#
#

# handle a block of raw sneezy data
# seperate it into lines for processing/logging
# keep hold of a buffer of any incomplete line or incomplete ansi code information
# release complete lines and complete ansi codes

# what we really need to worry about is blocking all output
#  between the time the cursor jumps down into the fuel gauges and 
#  comes back.. partial lines are a concern also
# 

# so bih only releases full lines or full ansi sequences, and a jump/return
#  compound ansi sequence is considered stolid

use strict;
use pms::msg;
use pms::argverify;

msg "bih init", -2;

#...

my $bihbuffer = "";

sub bih {


	msg "bih sub", -2;

	return unless argverify(\@_, 1, "block input handler bih() requires 1 arg");
	

	my $block = $_[0];
	my $export;
	#append it to anything in the buffer, and erase the buffer

	$block = $bihbuffer . $block;
	$bihbuffer = "";

	my $c = 0;
	my $n = 0;

	#count the codes and newlines
	{
		my $tmp=$block;
		while($tmp =~ s/^.*\x1b//) {
			$c++;
		}
		$tmp=$block;
		while($tmp =~ s/^.*\n//) {
			$n++;
		}
	}

		
	msg "Bih block: $c codes, $n newlines", -2;


	#let's get any compleat lines outta here
	for(my $t=0; $t < $n; $t++) {
		
		$block =~ s/(.*\n)//;
		$export .= $1;

	}

	#check for unfinished ansi save position/return code
	if(($block =~ m/\x1b7/) || ($block =~ m/\x1b[0-9\;]+H/)) {
		msg "bih: detected save pos code 7 or jump code H", -2;

		if($block =~ m/\x1b8/) {
			msg "bih: detected return pos code ESC[8", -2;
			$block =~ s/(.*\x1b8)//;
			$export .= $1;
		} 
		
		$bihbuffer = $block;
		$block = "";
	}

	#msg "bih: leftover = $block", -1;

	$export .= $block;

	unless($bihbuffer eq "" ) {
		msg "bih: --did buffer some information!--",-1;
	}

	print $export;
	
}



#return true to please perl
;1;
