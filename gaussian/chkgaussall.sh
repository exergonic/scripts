#!/bin/bash

###############################################################################
# Print vital statistical from a Gaussian log file.
#   1. Normal termination
#   2. Stationary point found
#   3. Imaginary frequencies
#       a. Amplitude of imaginary frequencies if found
#   4. Enthalpy and Energy results (if vibrational analysis has occurred).
#
# Takes no arguments.
# Finds Gaussian log files (*log in current working directory) and parses them.
###############################################################################

for logfile in *log ; do
	printf "%s\n" $logfile
	grep "Normal termination" $logfile || ( printf "%s\n" "Did not terminate normally." && continue )
	grep "Stationary point found" $logfile
	grep "imaginary frequencies" $logfile || printf "%s\n" "No imaginary modes."
    if [[ -n "$( grep 'imaginary frequencies' $logfile )" ]] ; then
        grep -m 1 "Frequencies" $logfile 
    fi
	grep "Sum of electronic and thermal Enthalpies" $logfile
	grep "Sum of electronic and thermal Free Energies" $logfile
	printf "\n"
done

exit 0
