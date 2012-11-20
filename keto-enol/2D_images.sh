#!/bin/bash
# creates an images/ directory
# copies plt files into the images directory
# then unzips all the images and places
# the shell within the images directory

DIRS=$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )

for DIR in $DIRS ; do
	cd $DIR
	SUBDIRS=$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )
	for SUBDIR in $SUBDIRS ; do
		cd $SUBDIR

		mkdir ./images || exit 1  ## make a new directory for the images.
					  ## if a new directory cannot be made, exit the script.

		cp *plt* images/        ## copy all files with plt anywhere in their name to the newly
					## created images directory.

		cd images/ || exit 1   ## move the shell into the directory.  if the shell cannot
					## move into the directory, exit the script.

		gunzip *		## unzip all of the plt files

		## now, add a .pdb suffix for easier opening of the images.  
		for file in * ; do
			mv ${file} ${file}.pdb
		done

		cd ../..
	done
	cd ..
done

exit 0
