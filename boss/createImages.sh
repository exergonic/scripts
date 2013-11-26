#!/bin/bash
# creates an images/ directory
# copies plt files into the images directory
# then unzips all the images and places
# the shell within the images directory

## make a new directory for the images.
## copy all files with plt anywhere in their name to the newly
mkdir ./images && cp *plt* images/ && cd images/ 

## unzip all of the plt files
gunzip *

## now, add a .pdb suffix for easier opening of the images.  
for file in * ; do
	mv ${file} ${file}.pdb

	# if the -s or --solute argument has been given,
	# extract the solute and make it a different file.
	if [ "$1" == "-s" -o "$1" == "--solute" ] ; then
		for PDB in *.pdb ; do
			TERLINE="$( grep --max-count=1 --line-number TER $PDB | cut -d ":" -f 1 )"
			# output the file contents from the beginning of the file
			# to the first occurance of 'TER', defined as $TERLINE.
			# redirect that output to the SOLUTE_FILE.
			head -n $TERLINE $PDB >> ${PDB%.pdb}.solute.pdb
			# make the definition of 'PDB' to be 'PDB.solute'
			# replace the 'TER' with 'END' in the PDB.
			sed -i "s/TER/END/g" ${PDB%.pdb}.solute.pdb
		done
	fi
done

exit 0
