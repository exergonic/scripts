#!/usr/bin/env bash

# sane bash behavior
set -e
set -u

files=( ~/usr/bin/hostd3 ~/usr/lib/hostd/LIBRARY ~/usr/lib/hostd/CONSTANTS ~/usr/lib/hostd/add.prm)

for file in ${files[@]}
do
	cp $file .
done


# copy necessary files here

[[ -e control ]] || ( echo "no control file" && exit 1 )

export HD_DIR='.'
./hostd3 

# remove copied files
for file in ${files[@]}
do
	rm ${file//*\/}
done


