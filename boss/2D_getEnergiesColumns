#!/bin/bash

[ -e columns.txt ] && rm columns.txt

DIRS="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"
for DIR in ${DIRS} ; do 
	cd $DIR
	printf "$DIR\n"

	[ -e SUMMARY.txt ] && rm SUMMARY.txt

	SUBDIRS="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"
	for SUBDIR in ${SUBDIRS} ; do
		cd ${SUBDIR}
		printf "\t${SUBDIR}\n"
		if [ -e log ] ; then
			zgrep DeltaG d*sum.gz | awk -F" " '{ print $7 }' >> ../SUMMARY.txt
		else
			echo "no log for $DIR/$SUBDIR"
		fi
		cd ..
	done

	cd ..
done

SUMMARIES=$( find . -name "SUMMARY.txt" | sort )
paste $SUMMARIES > columns.txt
rm $SUMMARIES

exit 0
