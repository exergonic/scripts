#!/bin/bash

dirs=$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep ./c )

for dir in  $dirs ; do 
	cd $dir
	echo $dir

	dirs2=$( find . -mindepth 1 -maxdepth 1 -type d | grep ./n )

	for dir2 in $dirs2 ; do
		cd $dir2
		rm *.gz log *.csh.*
		echo cleaned $dir/$dir2
		cd ..
	done
	cd ..
done

echo done

exit 0

