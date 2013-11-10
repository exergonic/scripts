#!/usr/bin/awk -f

# mkCols2 -- organize input into columns
#
BEGIN {
	padding=" "
	widestCell=1
}

{
	cell[NR-1]=$0
	if ( length($0) > widestCell )
		widestCell=length($0) # save widest data
}

END {
	cols=2
	x=((NR+(cols-1))/cols)
	rows=x-(x % 1) # calculate number of rows req'd
	maxCol=widestCell+2 # calculate column width
	for (n=0; n<=NR; n++) { # for each input line
		pad=substr(padding,1,(maxCol-length(cell[n])))
		rownum=n % rows
		row[rownum]=row[rownum] cell[n] pad # add req'd padding
	}
   	for (n=0; n<rows; n++) {
		 print row[n]
    	}
}
