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
SUMFILE="cavityVolume.txt"

printf "$PWD\n\n" > $SUMFILE
printf "CAVITY\tCAV(enol)\t\tCAV(keto)\n" >> $SUMFILE

for CAVITY in $CAVITYS
do
	OL_CAV="$( grep "Cavity volume" *.ol.*${CAVITY}*log | cut -d= -f2 )"
	ONE_CAV="$( grep "Cavity volume" *.one.*${CAVITY}*log | cut -d= -f2 )"
	printf "${CAVITY}\t${OL_CAV}\t${ONE_CAV}\n" >> $SUMFILE
done

exit 0
