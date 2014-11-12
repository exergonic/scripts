#!/bin/bash

dirs="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"

for dir in ${dirs} ; do
	cd $dir
	echo $dir
	ch_value="$( basename $pwd | cut -d "_" -f 2 )"
	subdirs="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"

	for subdir in $subdirs ; do
		cd $subdir
		printf "\t${subdir}\n"
		nh_value="$( basename $pwd | cut -d "_" -f 2 )"
		gunzip d50in.gz
		cp d50in d50_ch_${ch_value}_nh_${nh_value}_20m_in
		cd ..
	done
	cd ..
done

exit 0
