#!/bin/bash

for LOGFILE in *log ; do
	printf "%s\n" $LOGFILE
	grep "Normal termination" $LOGFILE || ( printf "%s\n" "Did not terminate normally." && continue )
	grep "Stationary point found" $LOGFILE
	grep "imaginary frequencies" $LOGFILE || printf "%s\n" "No imaginary modes."
    if [[ -n "$( grep 'imaginary frequencies' $LOGFILE )" ]] ; then
        grep -m 1 "Frequencies" $LOGFILE 
    fi
	grep "Sum of electronic and thermal Enthalpies" $LOGFILE
	grep "Sum of electronic and thermal Free Energies" $LOGFILE
	printf "\n"
done

exit 0
