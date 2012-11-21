#!/bin/bash
# creates an images/ directory
# copies plt files into the images directory
# then unzips all the images and places
# the shell within the images directory

mkdir ./images || exit 1  ## make a new directory for the images.
			  ## if a new directory cannot be made, exit the script.

cp *plt* images/        ## copy all files with plt anywhere in their name to the newly
			## created images directory.

cd images/ || exit 1   ## move the shell into the directory.  if the shell cannot
			## move into the directory, exit the script.

gunzip *		## unzip all of the plt files

## now, add a .pdb suffix for easier opening of the images.  
FILE_LIST="$( find * )"

for file in $FILE_LIST ; do
	mv ${file} ${file}.pdb

	# if the -s or --solute argument has been given,
	# extract the solute and make it a different file.
	if [ "$1" == "-s" -o "$1" == "--solute" ] ; then

		PDB_FILES="$( find . -name "*.pdb" )"

		for PDB in $PDB_FILES ; do
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
