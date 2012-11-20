#!/bin/bash

LOCALDIR=$PWD
TEMPLATE_DIR=${LOCALDIR}/template_dir
CONSTANT_LIST="$( seq -w 3.65 0.05 4.30 )"
WINDOW_LIST="-1.000 -0.750 -0.500 -0.250 0.000 0.250 0.500 0.750 1.000"

for CONSTANT in $CONSTANT_LIST ; do
	mkdir -v ${CONSTANT} || exit 1
	cd ${CONSTANT} || exit 2

	for WINDOW in ${WINDOW_LIST} ; do
		mkdir -v "win${WINDOW}" || exit 3
		cd "win${WINDOW}" || exit 4
		cp ${TEMPLATE_DIR}/* . 
		mv winWINDOW.csh win${WINDOW}.csh
		## EDIT THE CSH FILE
		sed -i "7s/X/${CONSTANT}/" *.csh
		sed -i "7s/Y/${WINDOW}/" *.csh
		sed -i "8s:Z:${PWD}:" *.csh

		## EDIT THE ZMAT FILE
		R1B=$( echo "scale=3; ($CONSTANT + $WINDOW)/2" | bc)
		R2B=$( echo "scale=3; $CONSTANT - $R1B" | bc )
		R1F=$( echo "scale=3; $R1B + 0.025" | bc )
		R2F=$( echo "scale=3; $R2B - 0.025" | bc )
		sed -i "29s/XXXXX/${R1B}/" pmfzmat
		sed -i "31s/YYYYY/${R2B}/" pmfzmat
		sed -i "51s/ZZZZZ/${R1F}/" pmfzmat
		sed -i "52s/WWWWW/${R2F}/" pmfzmat

		cd ..

	done

	cd ..
done

echo "Check it foo!"

exit 0
