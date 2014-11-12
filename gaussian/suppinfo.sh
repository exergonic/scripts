#!/usr/bin/env bash

# sane bash behavior
set -e
set -u
set -o pipefail
readonly progname=$(basename $0)
readonly progdir=$(readlink -m $(dirname $0))


# ----- ABOUT ---- 
# extracts supporting information from Gaussian output files.
# gathers first row of frequency info for transition structures, thermochemical
# data for transition strutures, and the condensed summary at the end of the
# Gaussian output.  This is done by looking for 'ASN' (unique to the Alabama
# Supercomputing Authority ) and then the '\@' which ends the summary, except
# in the case of composite, thermochemical calculations, in which case it will
# look for 'FreqCoords'. 
#
# This script will create a UNIX text document. For easier importing into
# Microsoft Word, run `unix2dos` on the outfile.
#
#		>unix2dos *supporting_info.txt
#
# ---- INVOCATION -- 
# The script can take two arguments: 'ts' and 'comp'
# 
# 'ts' signifies that you need the usual thermochemical and condensed supp
# info, as well as the first row of frequencies displaying the one negative
# frequency.
#
# 'comp' signifies that you've ran a thermochemical calculation.
#
# these two can be used in conjunction.
#
# examples: 
# ./suppinfo.sh           <-- for a normal opt + freq job
# ./suppinfo.sh ts        <-- for a ts job 
# ./suppinfo.sh comp      <-- for a comp job 
# ./suppinfo.sh comp ts   <-- for a comp, ts job 
#
# AUTHOR: Billy Wayne McCann
# EMAIL:  thebillywayne@gmail.com
# LICENSE: BSD 2-Clause
#------------------


# string that denotes the beginning of supporting info
si='ASN' # Alabama Supercomputer

# output file
outfile=$(basename ${PWD})_supporting_info.txt
[[ -f $outfile ]] && rm $outfile

# make the logfiles all of the .log files in the current dir
logfiles=($(find . -maxdepth 1 -name "*.log"))


# tests ~~~~~~~~~~~~~~~~~~~~

# make sure there are log files
if [[ ${#logfiles[@]} -eq 0 ]] 
then
	echo "No log files in this directory."
	echo "Exiting."
	exit 1
fi


# test if the calculations were TS or composite calculations
# as directed by the options given by the user
TS=false
COMP=false

if [[ $# -gt 0 ]] 
then
	options="$@"
	options="$(echo $options | tr [:lower:] [:upper:])"
	for option in $options
	do
		[[ $option = 'TS' ]] && TS=true 
		[[ $option = 'COMP' ]] && COMP=true
	done
fi


# functions ~~~~~~~~~~~~~~~~~~~~

# for composite thermochemical calculations
_comp(){
	# paste everything from 'Temperature =' to 'Free Energy' into the outfile.
	awk '/Temperature=/,/Free\ Energy/' $logfile >> $outfile
	echo "" >> $outfile

	# many condensed si info's are printed for composite
	# jobs. find the last one.
	local si_lines=($(grep -n "ASN" $logfile | cut -d: -f1))
	local final_si_line=$(( ${#si_lines[@]} - 1 ))
	local final_si_begin=${si_lines[$final_element]}
	local final_si_end=$(grep -n "FreqCoord" $logfile | cut -d: -f1)

	sed -n "${final_si_begin},${final_si_end}p" $logfile >> $outfile
	echo "" >> $outfile
}

# extracts first row of vibrational data for TS calculations
_vibs(){
	grep -m 1 -B2 -A3 "Frequencies" $logfile >> $outfile
	echo "" >> $outfile
}

# extract thermodynamic data
_thermo(){
	grep "Sum of electronic" $logfile >> $outfile
	echo "" >> $outfile
}

# extract condensed summary
_get_si(){
	local si_begin="$(grep -m 1 -n "ASN" $logfile | cut -d: -f1)"
	local si_end="$(grep -m 1 -n "\\@" $logfile | cut -d: -f1)"
	sed -n "${si_begin},${si_end}p" $logfile >> $outfile
	echo "" >> $outfile
}

# main function
_main(){
	echo -e "created by $USER on $(date)\n$PWD\n\n" >> $outfile
	# loop through the logfiles and extract information
	for logfile in ${logfiles[@]} ; do
		echo -e "$logfile\n" >> $outfile

		if $COMP ; then     # a composite calc
			if $TS ; then   	# a composite, TS calc
				_vibs
			fi
			_comp
		elif $TS ; then     # a TS calc
			_vibs
			_thermo 
			_get_si
		else                # normal ground state calc
			_thermo
			_si
		fi
	done
}


# execution ~~~~~~~~~~~~~~~~~~~~
_main

# all done! ~~~~~~~~~~~~~~~~~~~~
printf "Script $0 complete.\n"

exit 0
