#!/usr/bin/env bash

# used to extract torsional potential energy profiles from a Guassian 09 relaxed scan
# usage ./% <file>

# grab condensed info from MP2= to RMSD
txt="$( sed -n '/MP2=/,/RMSD/p' $1 )"
# chop off everything before MP2=
txt="${txt#*MP2=}"
# chop off everything after \RMSD
txt="${txt%\\RMSD*}"
# get rid of blanks, control characters, and then replace commas with spaces
txt="$( echo $txt | tr -d [:blank:] | tr -d [:cntrl:] | tr ',' ' ')"

# convert all values from Hartree to kcal/mol and place into <name>.rot_nrg.txt
for i in $txt ; do 
    printf "%s\n" $( echo "scale=4; $i * 627.5095" | bc ) >> ${1%.*}.rot_nrg.txt
done
