#!/bin/bash

# About ---------------------------------------------------------------
#
# chkgausslogs.sh
# 
# Checks the output file of a gaussian job.
# Will test for the normal termination of the job, whether a stationary
# point was found, if any imaginary frequencies exist, and if enthalpy
# and free energy information can be found.  
# 
# Invocation ----------------------------------------------------------
#
# chkgausslogs.sh {list of gaussian logs to check}
# Many log files can be checked at once. The "*.log" argument will also 
# work.
#
#----------------------------------------------------------------------

# the log files are given as arguments to the script
LOGFILES="$@"

for LOGFILE in $LOGFILES ; do
	printf "%s\n" $LOGFILE
	grep "Normal termination" $LOGFILE || printf "\t%s\n" "Did not terminate normally."
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
