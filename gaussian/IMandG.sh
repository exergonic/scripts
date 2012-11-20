#!/bin/bash

# About ---------------------------------------------------------------
#
# Will check every Guassian output file in a directory (*.log)
# for an imaginary mode and place free energy results plus the 
# "imaginary mode status" ( 0 = no IM ; 1 = has IM ) in a results
# text file.
#
# Invocation ----------------------------------------------------------
#
# ./IMandG.sh
# 
# Takes no arguments.
#
# ---------------------------------------------------------------------

# Variables ----------------------------------------------------------

# varible for the log file
declare FILE
# name the results file
declare RESULTS_FILE=results.txt
# variable for whether or not molecule possesses imaginary mode
declare IM_STATUS
# variable for testing presence of imaginary mode.
declare HAS_IM
# variable for free energy of molecule.
declare G

# ----------------------------------------------------------------------

# Main script ---------------------------------------------------------

for FILE in *.log 
do
	# set IM_STATUS to 0, meaning no imaginary mode.
	IM_STATUS=0
	# see if log file has imaginary mode by grepping for "imaginary".
	# if it does, the variable below will contain text.
	# if not, it will be empty.
	HAS_IM="$( grep "imaginary" $FILE )"
	# if HAS_IM contains text, then the file has an IM, so set IM_STATUS=1.
	[ -n "$HAS_IM" ] && IM_STATUS=1
	# variable G will be the free energy.
	G="$( grep "Sum of electronic and thermal Free Energies" $FILE | awk -F"=" '{ print $2 }'  )"
	# output the filename, free energy, and IM_STATUS to the results file.
	printf "%s\t%s\t%s\n" "$FILE" "$G" "$IM_STATUS" >> $RESULTS_FILE
	# loop to next log file.
done

printf "%s\n" "All done!"

exit 0
