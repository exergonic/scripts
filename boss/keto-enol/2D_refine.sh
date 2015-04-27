#!/bin/bash

# algorithm:
# for every ch bond length value, do the following:
# 1. make directory
# 2. cd into directory
# 3. copy scripts and preopt_zmat from template directory into 
#	the current directory
# 4. cd into preopt_zmat dir
# 	a. change ch bond length
#	b. make zopts for the range
# 5. run 1d_mutation script
# 6. submit the job

const_prefix="nh"
export prefix="ch"
export start="1.20"
export finish="2.00"
export interval="0.10"


range="1.00" #$( seq -w 1.90 0.01 2.00 )"

for value in ${range} ; do
	mkdir -v ${const_prefix}_${value} || exit 1
	cd ${const_prefix}_${value} || exit 2
	cp -r ../ch_template/* .
	cd ./preopt_zmats || exit 3
	ylinenumber="$( grep -n Y.YY *.z | cut -d: -f 1 )"
	sed -i "${ylinenumber}s/Y.YY/${value}/" *.z
	./mk_zopts.sh xpdggbopt *.z
	cd ..
	./mk_1d_mutation_dirs.sh
	printf "\n\n"
	cd ..
done
