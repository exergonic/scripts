#!/bin/bash

PDB_FILES="$( find *.pdb )"

for PDB in $PDB_FILES ; do

	# find the line number of the first occurence of the term TER.
	TERLINE="$( grep --max-count=1 --line-number TER $PDB | cut -d ":" -f 1 )"
	# output the file contents from the beginning of the file
	# to the first occurance of 'TER', defined as $TERLINE.
	# redirect that output to the SOLUTE_PDB.
	head -n $TERLINE $PDB >> ${PDB%.pdb}.solute.pdb
	# make the definition of 'PDB' to be 'PDB.solute.pdb'
	
	# replace the 'TER' with 'END' in the PDB.
	sed -i "s/TER/END/g" ${PDB%.pdb}.solute.pdb

done

exit 0

