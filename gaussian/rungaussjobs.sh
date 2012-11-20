#!/bin/bash


for GJF in *gjf ; do
	echo $GJF
	# find memory and nprocshared specs in the GJF file
	memory="$( grep -i mem $GJF | cut -d"=" -f2 )"
	num_procs="$( grep -i nprocshared $GJF | cut -d"=" -f2 )"

	#launch that mufuggah
	~/scripts/gaussian/brung09 $GJF medium-parallel $num_procs $memory 
done

exit 0
