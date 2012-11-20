#!/bin/bash

# __README__
# creates an images/ directory
# copies plt files into the images directory
# then unzips all the images and adds
# a pdb suffix to the filename
# the '--solute' flag will extract the solute
# section from the pdb file

# __BEGIN SCRIPT___

# __FUNCTIONS__

# a function to extract only the solute from
# the pdb file.  the solute is typically the
# first atom group that is defined in the pdb 
# file.  the first appearance of the term TERZ
# makes the final line of the solute.  cut out 
# this portion and place an END on the final
# line.
function solute()
{
	# find the line number of the first occurence of the term TER.
	TERLINE="$( grep --max-count=1 --line-number TER $FILE | cut -d ":" -f 1 )"
	# output the file contents from the beginning of the file
	# to the first occurance of 'TER', defined as $TERLINE.
	# redirect that output to the SOLUTE_FILE.
	head -n $TERLINE $FILE >> ${FILE}.solute
	# make the definition of 'FILE' to be 'FILE.solute'
	export FILE=${FILE}.solute
	# replace the 'TER' with 'END' in the FILE.
	sed -i "s/TER/END/g" $FILE
}	


# __END OF FUNCTIONS__

# tell the user if they invoked the 'solute' function
[ "$1" = "-s" -o "$1" = "--solute" ] && echo "Will extract solute from pdb files."

# define the original directory from which the script was called.
CURRENTDIR="$PWD"
# find directories that have numbers in their names
DIRS=$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )


# descend into the directories and grab images
for DIR in $DIRS ; do
	# move the shell in the directory
	cd $DIR

	# create an image subdir in this dir. this is where
	# all the images for this directory will go.
	if [ "$1" = "-s" -o "$1" = "--solute*" ] ; then
		IMAGEDIR="${PWD}/images.solutes"
	else
		IMAGEDIR="${PWD}/images"
	fi

	mkdir ${IMAGEDIR}

	# define the subdirectories in this dir which have numbers
	# in their names.
	SUBDIRS=$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )

	# for every subdirectory, descend into it and perform the action.
	for SUBDIR in $SUBDIRS ; do
		# test if the log file exists.
		# if not contintue to the next directory.
		[ -e ${SUBDIR}/log ] || continue

		# move the shell into the subdir.
		cd $SUBDIR
		## make a new, temporary directory for the images.
		mkdir ./images || exit 1  
		# copy all files with plt anywhere in their name to the temporary
		# images directory.
		cp *plt* images
		# move the shell into the directory.
		cd images/ || exit 1  
		# unzip all of the plt files
		gunzip *
		# now, for every file, add a .pdb suffix for easier opening of  
		# the images. also, move the file into the higher images directory.
		# name the file after the dir and subdir in which it appears.
		for FILE in * ; do
			# if the user give the argument 'solute' to the script
			# then extract the solute section from each pdb file.
			if [ "$1" == "-s" -o "$1" == "--solute*" ] ; then 
				solute
			fi
			# rename the FILE after the directories in which it appears
			mv ${FILE} ${IMAGEDIR}/${DIR/.\/}_${SUBDIR/.\/}_${FILE/d5plt/d05plt}.pdb
		done
		# move shell out of images directory
		cd .. 
		# since the lower images directory has no files in it,
		# remove it. the lower images directory was created to make
		# the unzipping and renaming of the files easier. 
		# TODO: perhaps there's a better way to solve this problem.
		rm -r images
		# tell the user that the script is finished with this particular
		# subdirectory.
		echo "images done for ${DIR}/${SUBDIR#./}."
		# move the shell out of this subdirectory.
		cd ../
	done
	# all subdirectories for this directory are complete.
	# move the shell up one level.
	cd ..
done
# every directory that was originally defined has the images converted.
echo "Script $0 complete."

exit 0
