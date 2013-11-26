#!/bin/bash

LOCALDIR=$PWD
SUMMARY_FILE=${LOCALDIR}/SUMMARY.txt
CONSTANT_LIST="$( seq -w 2.50 0.05 3.60 )"
WINDOW_LIST="-1.000 -0.750 -0.500 -0.250 0.000 0.250 0.500 0.750 1.000"

for CONSTANT in ${CONSTANT_LIST}; do 
	cd ${CONSTANT} || exit 1
	echo "${CONSTANT}"
	printf "%s\n\n" "FOR R1+R2 = ${CONSTANT}" >> ${SUMMARY_FILE}

	for WINDOW in ${WINDOW_LIST} ; do
		cd "win${WINDOW}" || exit 2
		printf "%s\n" "Window is ${WINDOW}" >> ${SUMMARY_FILE}
		if [ ! -e log ] ; then
			printf "%s\n" "  log file doesn't exist for ${CONSTANT}/${WINDOW}." | tee -a ${SUMMARY_FILE}
			printf "%s\n\n" "  This usually means that calculations aren't yet completed." | tee -a ${SUMMARY_FILE}
		else
			zcat d*sum.gz | grep DeltaG >> ${SUMMARY_FILE}
		fi
		cd ..
	done

	printf  "\n\n" >> ${SUMMARY_FILE} # space between info for separate constants

	cd ..

done

echo "Script finished."

exit 0
