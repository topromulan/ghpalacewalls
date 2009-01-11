#!/usr/bin/perl


$thickness=1;

foreach $v (@ARGV) {
	$thickness = 0.1 if $v eq "--road";
}

while ( $coords = <STDIN> ) {
	chomp($coords);

	#printf("coords: $coords\n");

	$coords =~ m/^([\-0-9]+),([\-0-9]+),([\-0-9]+)/ or next;

	$coordx = $1;
	$coordy = $2;
	$coordz = $3;

	$coordx2 = $coordx + 1;
	$coordy2 = $coordy + 1;
	$coordz2 = $coordz + $thickness;

	printf("

// $1,$2,$3
box {
	<$coordx, $coordz, $coordy>
	<$coordx2, $coordz2, $coordy2>

	pigment { color Violet }
}

	");


}
