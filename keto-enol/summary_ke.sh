#!/bin/bash

LOCALDIR=$PWD
SUMMARY_FILE=${LOCALDIR}/SUMMARY.txt
CONSTANT_LIST="$( seq -w 1.00 0.05 2.30 )"
WINDOW_LIST="0.95-1.95 1.95-2.95"

[ -e $SUMMARY_FILE ] && rm $SUMMARY_FILE

for CONSTANT in ${CONSTANT_LIST}; do 
	cd CH_${CONSTANT} || exit 1
	echo "${CONSTANT}"
	printf "%s\n\n" "FOR CH BOND LENGTH  = ${CONSTANT}" >> ${SUMMARY_FILE}

	for WINDOW in ${WINDOW_LIST} ; do
		cd "NH_${WINDOW}" || exit 2
#		printf "%s\n" "NH BOND WINDOW is ${WINDOW}" >> ${SUMMARY_FILE}
		if [ ! -e log ] ; then
			printf "%s\n" "  log file doesn't exist for ${CONSTANT}/${WINDOW}." | tee -a ${SUMMARY_FILE}
			printf "%s\n\n" "  This usually means that calculations aren't yet completed." | tee -a ${SUMMARY_FILE}
		else
			zcat d*sum.gz | grep DeltaG | awk -F" " '{ print $7 }' >> ${SUMMARY_FILE}
		fi
		cd ..
	done

	printf  "\n\n" >> ${SUMMARY_FILE} # space between info for separate constants

	cd ..

done

# get cross directory results

cd CROSS/NH_0.95 || exit 3
echo "CROSS" | tee -a ${SUMMARY_FILE}
for dir in CH_0.95-1.95 CH_1.95-2.95 ; do
	cd $dir
	if [ ! -e log ] ; then
		printf "%s\n" "  log file doesn't exist for CROSS/${dir}" | tee -a ${SUMMARY_FILE}
		printf "%s\n\n" "  This usually means that calculations aren't yet completed." | tee -a ${SUMMARY_FILE}
	else
		zcat d*sum.gz | grep DeltaG | awk -F" " '{ print $7 }' >> ${SUMMARY_FILE}
	fi
	cd ..
done


echo "Script finished."

exit 0
