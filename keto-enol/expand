#!/bin/bash

CURRENTDIR=${PWD}

CH_PARENTS="$( find ./equil/ -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"

for CH_PARENT in ${CH_PARENTS} ; do
	CH_ORIG_VAL=${CH_PARENT##*CH_}
	CH_DOWN_VAL=$( echo "scale=2; ${CH_ORIG_VAL} - 0.05" | bc )
	CH_UP_VAL=$( echo "scale=2; ${CH_ORIG_VAL} + 0.05" | bc )

	NH_PARENTS=$( find ${CH_PARENT} -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )

	for NH_PARENT in ${NH_PARENTS} ; do
		NH_ORIG_VAL=${NH_PARENT##*NH_}
		NH_DOWN_VAL=$( echo "scale=2; ${NH_ORIG_VAL} - 0.05" | bc )
		NH_UP_VAL=$( echo "scale=2; ${NH_ORIG_VAL} + 0.05" | bc )

		for NEW_CH_DIR in ${CH_DOWN_VAL} ${CH_ORIG_VAL} ${CH_UP_VAL} ; do
				mkdir CH_${NEW_CH_DIR}
				cd CH_${NEW_CH_DIR}
				for NEW_NH_DIR in ${CH_DOWN_VAL} ${CH_ORIG_VAL} ${CH_UP_VAL} ; do
					mkdir NH_${NEW_NH_DIR}
					cd NH_${NEW_NH_DIR}
					# copy and edit file
					cd ..
				done
				cd ..
		done

	done
done

exit 0
				





