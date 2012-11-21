#!/bin/bash

LOCALDIR=${PWD}
NEWDIR=${PWD}/2nd2020

DIRS="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"

for DIR in ${DIRS} ; do 
	cd $DIR
	
	SUBDIRS="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"
	for SUBDIR in ${SUBDIRS} ; do
		cd ${SUBDIR}
		mkdir -p ${NEWDIR}/${DIR#./}/${SUBDIR#./} || exit 2
		cp pmfpar pmfcmd *.csh pmfzmat d50in.gz ${NEWDIR}/${DIR#./}/${SUBDIR#./}/
		cd ${NEWDIR}/${DIR#./}/${SUBDIR#./} 
		gunzip d50in.gz
		sed -i "11s:/.*:${PWD}:" *.csh
		sed -i "24s:/.*:${PWD}/d50in d50in:" *.csh
		cd -
		cd ..
	done

	cd ..
done

exit 0
