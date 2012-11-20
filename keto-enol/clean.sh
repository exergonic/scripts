#!/bin/bash

DIRS=$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep ./C )

for DIR in  $DIRS ; do 
	cd $DIR
	echo $DIR

	DIRS2=$( find . -mindepth 1 -maxdepth 1 -type d | grep ./N )

	for DIR2 in $DIRS2 ; do
		cd $DIR2
		rm *.gz log *.csh.*
		echo cleaned $DIR/$DIR2
		cd ..
	done
	cd ..
done

echo Done

exit 0

