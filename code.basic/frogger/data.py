# **********************************************************************************************
#
#		Generate data for frogger. These tables are 32x1 tilemaps with a 32 word duplicate
#		following so we can wrap round using and $1F
#		
#		There are nine.  From bottom to top the rows are
#
#		15:	frogs remaining
#		14:	Home # 1
#		13:  Slow pointy left
#		12:	Slow bulldozer right
#		11:	Slow rounded left:
#		10:	Fast pointy right
#		9:  Lorries left
#		8: 	Home #2
#		7: 	Turtles left fast
#		6:	Logs right slow
#		5: 	Logs right medium
#		4:	Turtles left slow
# 		3: 	Logs right slow
#	 	2:	Home
#		1:	Green background/Space
#		0:	Score
#
#		The first 16 bytes are an offset to a table for each row, or 0 if there isn't a row.
#		All offsets are from the start of the data.
#
#		Each row is
#			+0 		Segment length 	(32 normally) excluding 32 word wrap over
#			+1		Speed relative, as percentage , -ve is left moving
#			+2		Offset to tile map.
#			+3		Number of turtles in turtle table
#			+4 		Offset to turtle table.
#
# **********************************************************************************************

class FroggerDataClass(object)
	pass


