
#include "colors.inc"

//#include "grid.inc"

#include "mainst.inc"
#include "kingsway.inc"
#include "parkave.inc"
#include "branishway.inc"
#include "marketrd.inc"
#include "twilightave.inc"
#include "commonwealthln.inc"
#include "oakln.inc"
#include "furfootpath.inc"
#include "briarway.inc"

#include "perimeterrd.inc"

#include "palace.inc"
#include "palacelawn.inc"
#include "palacelawnwalls.inc"
//
#include "citywalls.inc"

//NE quadrant
#include "barracks.rinc"
#include "adders.rinc"
#include "hospital.rinc"
#include "museum.rinc"
#include "herald.rinc"
#include "shipping.rinc"
#include "crusadersguild.rinc"
//
//SW quadrant
#include "roaringlion.rinc"
#include "roths.rinc"
#include "shops.rinc"
#include "casino.rinc"
#include "thiefguild.rinc"
#include "chaosgarrison.rinc"
#include "chaosgarrisontraining.rinc"
#include "barracks.rinc"
//
//SE quadrant
#include "park.rinc"
#include "parkfence.inc"
#include "theater.rinc"
#include "mageacademy.rinc"
//
//NW quadrant
#include "orphanage.rinc"
#include "church.rinc"

#include "adventurer.rinc"

#declare Library_Path="/home/anderson/ray/gh/"

camera {

	location	<5.5, 6.5, 1.5>
	look_at		<3.5, 5, 4.5>
//	location 	<-22, 6, -11>
//	look_at		<13, 0, 7>
	//location 	<2, 8, -10>
	//look_at		<10, 2, 13>
	//location	<20, 6, 8>
	//look_at		<3, 3, 3>

	//location	<4.8, 1, -3.8>
	//look_at		<1, 0, 1>

	//Above
	//location	<0.5, 30, 0.5>
	//look_at		<0.5, 0, 0.5>
	//location	<-3, 4, -3>
	//look_at		<-3, 2, 3>

	//location	<-2, 9, -7>
	//look_at		<-2, 0, -7>

	//From SW
	//location	<-20, 10, -15>
	//look_at		<0, 0, 0>

	//looking at hospital from top
	//location	<3.7, 5.5, 4.7>
	//look_at		<9, 2, 4>

	//looking up park ave
	//location	<7.5, 0.5, 0.1>
	//look_at		<7.5, 1, 11>

	//looking down east kings way
	//location	<-0.5, 0.5, 0.5>
	//look_at		<10, 2, 0.5>
	//looking down west kings way
	//location	<1.5, 0.5, 0.5>
	//look_at		<-10, 2, 0.5>
	//looking up north main
	//location	<0.5, 0.5, -0.5>
	//look_at		<0.5, 0.5, 10>
	//looking down south main
	//location	<0.5, 0.5, 1.5>
	//look_at		<0.5, 0.5, -10>

	//s.e. corner of yard
	//location	<4.8, 0.5, 1.2>
	//look_at		<1, 1, 1.5>

	//looking at castle from south
	//location	<3.5, 0.5, -5>
	//look_at		<3.5, 2, 4>

	//looking up at the new casino from cs
	//location	<0.9, 0.65, 0.9>
	//look_at		<-5, 8, -7>

	//looking down branish
	//location	<-2.5, 0.5, 0.5>
	//look_at		<-2.5, 0.7, -5>

	//looking at park from CS
	//location	<0.0, 0.5, 0.85>
	//look_at		<4.2, 0.5, -3>
}

light_source { <-15, 15, 0>, colour White }
light_source { <15, 18, 15>, colour White }
light_source { <-15, 14, -15>, colour White }
light_source { <15, 16, 0>, colour White }

light_source { <0, 25, 0>, colour White }
light_source { <5, 35, 5>, colour Yellow }
light_source { <5, 35, -5>, colour White }
light_source { <-5, 35, 5>, colour Yellow }
light_source { <-5, 35, -5>, colour White }


light_source { <-5, -10, -5>, colour Salmon }
light_source { <-5, -10, 5>, colour Salmon }
light_source { <5, -10, 5>, colour Salmon }
light_source { <5, -10, -5>, colour Salmon }
light_source { <-5, -10, -5>, colour White }
light_source { <-5, -10, 5>, colour White }
light_source { <5, -10, 5>, colour White }
light_source { <5, -10, -5>, colour White }

//plane { 
	//<0, 1, 0>, 0	//normal, distance from origin
//
	//pigment {
		//checker colour Gray95 colour Red
		//scale 1
	//}
	////finish {
		////ambient 0.2
		////diffuse 0.8
	////}
//}

//ORIGIN MARKER
//box {
	//<-0.2, 0, -0.2>, <0.2, 0.5, 0.2>
	//pigment {
		//color White
	//}
//}
//box {
	//<4, 0, 4>, <5, 1, 5>
	//pigment {
		//color Green
	//}
//}

