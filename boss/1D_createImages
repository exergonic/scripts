#!/bin/bash

# creates an images/ directory
# copies plt files into the images directory
# then unzips all the images. 

read -p "What is the first character of the names of the subdirectories? " CHAR

SUBDIRS=$( find . -mindepth 1 -maxdepth 1 -type d | grep "./${CHAR}" | sort )

for dir in $SUBDIRS ; do
	cd $dir || exit 1
	if [ -e log -a ! -d images ] ; then
		mkdir images
		cp *plt* images/
		gunzip images/*
	
		for file in images/* ; do
			mv $file ${file}.pdb
		done

		echo "images created for $dir."

	elif [ -d images ] ; then
		echo "images directory already exists in $dir."

	else
		echo "No log file in $dir."
		echo "This usually means the job isn't completed."
	fi

	cd ..
done

exit 0
