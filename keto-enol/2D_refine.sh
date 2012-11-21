#!/bin/bash

# algorithm:
# for every CH bond length value, do the following:
# 1. make directory
# 2. cd into directory
# 3. copy scripts and preopt_zmat from template directory into 
#	the current directory
# 4. cd into preopt_zmat dir
# 	a. change CH bond length
#	b. make zopts for the range
# 5. run 1D_mutation script
# 6. submit the job

CONST_PREFIX="NH"
export PREFIX="CH"
export START="1.20"
export FINISH="2.00"
export INTERVAL="0.10"


RANGE="1.00" #$( seq -w 1.90 0.01 2.00 )"

for VALUE in ${RANGE} ; do
	mkdir -v ${CONST_PREFIX}_${VALUE} || exit 1
	cd ${CONST_PREFIX}_${VALUE} || exit 2
	cp -r ../CH_TEMPLATE/* .
	cd ./preopt_zmats || exit 3
	YLINENUMBER="$( grep -n Y.YY *.z | cut -d: -f 1 )"
	sed -i "${YLINENUMBER}s/Y.YY/${VALUE}/" *.z
	./mk_zopts.sh xPDGGBOPT *.z
	cd ..
	./mk_1D_mutation_dirs.sh
	printf "\n\n"
	cd ..
done
