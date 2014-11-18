#!/usr/bin/env bash

# sane bash behavior
set -e
set -u
set -o pipefail
readonly progname=$(basename $0)
readonly progdir=$(readlink $(dirname $0))
readonly args="$@"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# R E A D M E
#
#
#	removes duplicate HostDesigner host fragments from a directory
# that has been produced by sort_engine_output.py. 
#
# I N V O C A T I O N
# this spell take only one input: the name of the HD host fragment that you'd
# like to deduplicate from the results. all duplicates will be moved to $filtered_out 
# 
# L I C E N S E
# BSD 2-clause
# author: Billy Wayne McCann
# contact: thebillywayne@gmail.com
#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
file_string=${args}
files=($( ls *_${file_string}.c3d))
filter_dir="filtered_out/"

[[ -d $filter_dir ]] || mkdir $filter_dir

_filter ()
{
	local f="${@%_*}"
	mv "${f}"* $filter_dir &> /dev/null
}

main()
{
	for ((i=1; i < ${#files[@]} ; i++ ))
	do
		local n=${files[$i]}
		_filter $n
		echo "Moved $n"
	done
}

main

echo Done
exit 0

