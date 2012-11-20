#!/bin/bash

DIRS="$( find . -mindepth 1 -maxdepth 1 -type d )"

for dir in $DIRS ; do
	cd $dir
	for GJF in *gjf ; do
		~/bin/brung09 $GJF small-parallel 4 2GB
	done
	cd ..
done

exit 0
