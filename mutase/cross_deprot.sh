#!/bin/bash

LOCALDIR=$PWD
TEMPLATE_DIR=${LOCALDIR}/template_dir
CONSTANT_LIST="0.95 1.00 1.05"
WINDOW_LIST="0.95-1.95 1.95-2.95"

for CONSTANT in $CONSTANT_LIST ; do
	mkdir -v NH_${CONSTANT} || exit 1
	cd NH_${CONSTANT} || exit 2

	for WINDOW in ${WINDOW_LIST} ; do
		mkdir "CH_${WINDOW}" || exit 3
		cd "CH_${WINDOW}" || exit 4
		cp ${TEMPLATE_DIR}/* . 
		mv template.csh cross_win${WINDOW}.csh
		## EDIT THE CSH FILE
		sed -i "9s/CONSTANT/${CONSTANT}/" *.csh
		sed -i "9s/WINDOW/${WINDOW}/" *.csh
		sed -i "10s:LOCALDIR:${PWD}:" *.csh

		## EDIT THE ZMAT FILE
		BEGIN_CH=$( echo ${WINDOW} | cut -d "-" -f 1 )
		END_CH=$( echo ${WINDOW} | cut -d "-" -f 2 )
		sed -i "11s/X.XX/${BEGIN_CH}/" pmfzmat
		sed -i "23s/Y.YY/${CONSTANT}/" pmfzmat
		sed -i "46s/Z.ZZ/${END_CH}/" pmfzmat

		q -i *.csh | tee -a $LOCALDIR/jobs.txt

		cd ..

	done

	cd ..
done

echo "Check it foo!"

exit 0
