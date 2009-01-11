
use pms::turtle_key;
use pms::hotkey_to_english;

printf "\nturtle_key routine test\n\n";

ReadMode 4;

until($k) {
	$k = turtle_key();
}

@l = split('', $k);

printf "Key Test:\n";
printf "--------\n";

foreach $x (@l) {
	$y = $x;
	$y = "ESC" if $x eq "\x1b";
	printf " %3d : $y\n", ord($x);
}

printf "\n";

printf "hotkey to english: %s\n", hotkey_to_english($k);

ReadMode 1;



