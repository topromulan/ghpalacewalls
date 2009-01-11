#######
# a perl shell module to... access sneezymud
#
#
use pms::msg;

msg "sneezy init", -2;

use Net::Telnet;

use pms::argverify;

use warnings;
use strict;

#...

my $port = 23;
my $server = "sneezy.saw.net";

my $stelnet = new Net::Telnet(Timeout => 10, ErrMode => 'return');

my $sconnectionstate = 0;

sub sconnect {
	msg "sconnect: telnetting to $server $port", 0;
	$stelnet->open(Host=>$server, Port=>$port);
	scheck();
}

sub scheck {
	if($stelnet->eof()) {
		sconnect();
	}
	unless($| == 1) {
		msg "Setting \$| to 1", 3;
		$| = 1; # set command buffering instead of line buffering
	}
}

sub testsub {
	print $stelnet->get();
}

sub sget {
	return unless argverify(\@_, 0, "sget takes no arguments");
	if(my $incoming = $stelnet->get(Timeout => 0)) {
		bih_explorer_add($incoming);
		bih($incoming);
	}
}

sub ssend {
	my $datum;
	if(defined($_[0])) {
		$datum = $_[0];
	} else {
		$datum = "";
	}
	$stelnet->print($datum);
}

sub ssetserver {
	return unless argverify(\@_, 1, "ssetserver takes 1 arg");
   	$server = $_[0];
	msg "ssetserver: \$server is now $server", 0;
}

sub ssetport {
	return unless argverify(\@_, 1, "ssetport takes 1 arg");
	$port = $_[0];
	msg "ssetserver: \$port is now $port", 0;
}

#return true to please perl
;1;
