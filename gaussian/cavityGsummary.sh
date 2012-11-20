#!/bin/bash

# ABOUT
# Collects free energies from enol and keto results
# for the various cavity calculation.  Places them
# in the cavityGsummary.txt file in order of cavity 
# type in the following format.
# CAVITY ENOL_G KETO_G
# 
# USAGE:
# simple invocation of the script within the directory
# which holds the gaussian log files. 

CAVITYS="bondi pauling ua0 uahf uaks uff"
SUMFILE="cavityGsummary.txt"

printf "$PWD\n\n" > $SUMFILE
printf "CAVITY\tG(enol)\t\tG(keto)\n" >> $SUMFILE

for CAVITY in $CAVITYS
do
	OL_G="$( grep "Sum of electronic and thermal Free Energies" *.ol.*${CAVITY}*log | cut -d= -f2 | tr -d " ")"
	ONE_G="$( grep "Sum of electronic and thermal Free Energies" *.one.*${CAVITY}*log | cut -d= -f2 | tr -d " " )"
	printf "${CAVITY}\t${OL_G}\t${ONE_G}\n" >> $SUMFILE
done

exit 0
