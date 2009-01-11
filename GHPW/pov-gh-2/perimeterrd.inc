


//N
box { <-4, 0, 11>, <5, 0.15, 12> pigment { color Gray35 } }

//E
box { <11, 0, -4>, <12, 0.15, 5> pigment { color Gray35 } }

//S
box { <-4, 0, -10>, <5, 0.15, -11> pigment { color Gray35 } }

//W
box { <-10, 0, -4>, <-11, 0.15, 5> pigment { color Gray35 } }

//NE not a box
polygon { 4, 
	<4, 0.15, 11>
	<5, 0.15, 12>
	<12, 0.15, 5> 
	<11, 0.15, 4>

	pigment { color Gray35 }
}

//SE 
polygon { 4, 
	<4, 0.15, -10>
	<5, 0.15, -11>
	<12, 0.15, -4> 
	<11, 0.15, -3>

	pigment { color Gray35 }
}

//SW
polygon { 4, 
	<-3, 0.15, -10>
	<-4, 0.15, -11>
	<-11, 0.15, -4> 
	<-10, 0.15, -3>

	pigment { color Gray35 }
}

//NW
polygon { 4, 
	<-3, 0.15, 11>
	<-4, 0.15, 12>
	<-11, 0.15, 5> 
	<-10, 0.15, 4>

	pigment { color Gray35 }
}

