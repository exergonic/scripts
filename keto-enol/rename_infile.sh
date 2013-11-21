#!/bin/bash

DIRS="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"

for DIR in ${DIRS} ; do
	cd $DIR
	echo $DIR
	CH_VALUE="$( basename $PWD | cut -d "_" -f 2 )"
	SUBDIRS="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"

	for SUBDIR in $SUBDIRS ; do
		cd $SUBDIR
		printf "\t${SUBDIR}\n"
		NH_VALUE="$( basename $PWD | cut -d "_" -f 2 )"
		gunzip d50in.gz
		cp d50in d50_CH_${CH_VALUE}_NH_${NH_VALUE}_20M_in
		cd ..
	done
	cd ..
done

exit 0
