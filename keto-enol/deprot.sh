#!/bin/bash

LOCALDIR=$PWD
TEMPLATE_DIR=${LOCALDIR}/template_dir
ZMAT_DIR=~/research/Keto-Enol/Pyridine/preopt_zmats


if [ "$1" = "submit" -o "$1" = "s" ] ; then
	SUBMIT="q -i *.csh"
else
	SUBMIT="echo Not submitting."
fi

make_CH-CONSTANT_dirs()
{
	CH_CONSTANT_LIST="$( seq -w 1.00 0.05 2.30 )"
	NH_WINDOW_LIST="0.95-1.95 1.95-2.95"

	for CH_CONSTANT in $CH_CONSTANT_LIST ; do
		mkdir CH_${CH_CONSTANT} || exit 1
		cd CH_${CH_CONSTANT} || exit 2
		echo ${CH_CONSTANT}

		for NH_WINDOW in ${NH_WINDOW_LIST} ; do
			mkdir "NH_${NH_WINDOW}" || exit 3
			cd "NH_${NH_WINDOW}" || exit 4
			cp ${TEMPLATE_DIR}/* . 
			mv template.csh win${NH_WINDOW}.csh

			# a case switch to determine from which directory
			# to get the 'sum' file. for use when using pre-
			# optimized zmatrices.
			case "${NH_WINDOW}" in
				"0.95-1.95")
					cp ${ZMAT_DIR}/CH_${CH_CONSTANT}/NH_1.45/sum pmfzmat
					sed -i "12s/1.45/0.95/" pmfzmat
					sed -i "35s/$/\n00110001  1.95/" pmfzmat
					;;
				"1.95-2.95")
					cp ${ZMAT_DIR}/CH_${CH_CONSTANT}/NH_2.45/sum pmfzmat
					sed -i "12s/2.45/1.95/" pmfzmat
					sed -i "35s/$/\n00110001  2.95/" pmfzmat
					;;
				*)
					echo "messed up case" && exit 5
					;;
			esac


			## EDIT THE CSH FILE
			sed -i "s/CONSTANT/CH_${CH_CONSTANT}/g" *.csh
			sed -i "s/WINDOW/NH_${NH_WINDOW}/g" *.csh
			sed -i "s:LOCALDIR:${PWD}:g" *.csh

			## EDIT THE ZMAT FILE 
			# used when not using pre-optmizied zmatrices.

			#BEGIN_HN=$( echo ${NH_WINDOW} | cut -d "-" -f 1 )
			#END_HN=$( echo ${NH_WINDOW} | cut -d "-" -f 2 )
			#sed -i "s/X.XX/${CH_CONSTANT}/g" pmfzmat
			#sed -i "s/Y.YY/${BEGIN_HN}/g" pmfzmat
			#sed -i "s/Z.ZZ/${END_HN}/g" pmfzmat

			${SUBMIT}

			cd ..

		done

		cd ..
	done
}

make_CROSS_dir()
{
	NH_CONSTANT_LIST="0.95"
	CH_WINDOW_LIST="0.95-1.95 1.95-2.95"

	mkdir CROSS || exit 4
	cd CROSS || exit 5
	echo CROSS

	for NH_CONSTANT in $NH_CONSTANT_LIST ; do
		mkdir NH_${NH_CONSTANT} || exit 1
		cd NH_${NH_CONSTANT} || exit 2
		for CH_WINDOW in ${CH_WINDOW_LIST} ; do
			mkdir "CH_${CH_WINDOW}" || exit 3
			cd "CH_${CH_WINDOW}" || exit 4
			cp ${TEMPLATE_DIR}/* . 
			mv template.csh cross_win${CH_WINDOW}.csh
			## EDIT THE CSH FILE
			sed -i "s/CONSTANT/NH_${NH_CONSTANT}/g" *.csh
			sed -i "s/WINDOW/CH_${CH_WINDOW}/g" *.csh
			sed -i "s:LOCALDIR:${PWD}:g" *.csh
			## EDIT THE ZMAT FILE
			case "${CH_WINDOW}" in
				"0.95-1.95")
					cp ${ZMAT_DIR}/NH_${NH_CONSTANT}/CH_1.45/sum pmfzmat
					sed -i "10s/1.45/0.95/" pmfzmat
					sed -i "35s/$/\n00090001  1.95/" pmfzmat
					;;
				"1.95-2.95")
					cp ${ZMAT_DIR}/NH_${NH_CONSTANT}/CH_2.45/sum pmfzmat
					sed -i "10s/2.45/1.95/" pmfzmat
					sed -i "35s/$/\n00090001  2.95/" pmfzmat
					;;
				*)
					echo "messed up case" && exit 5
					;;
			esac


#			BEGIN_CH=$( echo ${CH_WINDOW} | cut -d "-" -f 1 )
#			END_CH=$( echo ${CH_WINDOW} | cut -d "-" -f 2 )
#			sed -i "10s/X.XX/${BEGIN_CH}/" pmfzmat
#			sed -i "12s/Y.YY/${NH_CONSTANT}/" pmfzmat
#			sed -i "36s/0011/0009/" pmfzmat
#			sed -i "36s/Z.ZZ/${END_CH}/" pmfzmat

			${SUBMIT}

			cd ..
		done
		cd ..
	done
}



make_CH-CONSTANT_dirs 
make_CROSS_dir 


exit 0
