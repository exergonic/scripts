#!/bin/bash

# ----- ABOUT ----
# extracts supporting information from Gaussian output files.
# gathers first row of frequency info for transition structures,
# thermochemical data for transition strutures, and the condensed
# summary at the end off the Gaussian output.  This is done by
# looking for 'ASN' (perhaps unique to the Alabama Supercomputing
# Authority ) and then the '\@' which ends the summary.  
#
# This script will create a UNIX text document. For easier importing
# into Microsoft Word, run unix2dos on the outfile.
#
# ---- INVOCATION --
# The script can take two arguments: 'ts' and 'comp'
# 
#
# ------------------

# exit script on first error
set -e

# output file
outfile=supporting_info.txt
[[ -f $outfile ]] && rm $outfile

# make the logfiles all of the .log files in the current dir
logfiles=($( find . -maxdepth 1 -name "*.log" ))

# TESTS ######################################################################

# make sure there are log files
if [[ ${#logfiles[@]} -eq 0 ]] ; then
    echo "No log files in this directory."
    echo "Exiting."
    exit 0
fi


TS=false
COMP=false

# test if the calculations were TS or composite calculations
# as directed by the options given by the user
if [[ $# -gt 0 ]] ; then
    options="$@"
    options="$(echo $options | tr [:lower:] [:upper:])"
    for option in $options ; do
        [[ $option = 'TS' ]] && TS=true 
        [[ $option = 'COMP' ]] && COMP=true
    done
fi



# FUNCTIONS ################################################################## 

# for composite thermochemical calculations
_comp(){
    # paste everything from 'Temperature =' to 'Free Energy' into the outfile.
    awk '/Temperature=/,/Free\ Energy/' $logfile >> $outfile
    echo "" >> $outfile

    # many condensed si info's are printed for composite
    # jobs. find the last one.
    begin_array=($(grep -n "ASN" $logfile | cut -d: -f1))
    begin_element=$(( ${#begin_array[@]} - 1 ))
    begin=${begin_array[$begin_element]}
    end=$(grep -n "FreqCoord" $logfile | cut -d: -f1)

    sed -n "${begin},${end}p" $logfile >> $outfile
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
_si(){
    begin="$(grep -m 1 -n "ASN" $logfile | cut -d: -f1)"
    end="$(grep -m 1 -n "\\@" $logfile | cut -d: -f1)"
    sed -n "${begin},${end}p" $logfile >> $outfile
    echo "" >> $outfile
}


# MAIN ########################################################################

echo -e "$PWD\n" >> $outfile
# loop through the logfiles and extract information
for logfile in ${logfiles[@]} ; do
    echo -e "$logfile\n" >> $outfile

    if $COMP ; then     # a composite calc
        if $TS ; then   # a composite, TS calc
            _vibs
        fi
        _comp
    elif $TS ; then     # a TS calc
        _vibs
        _thermo 
        _si
    else                # normal ground state calc
        _thermo
        _si
    fi
done


# all done!
printf "Script $0 complete.\n"
exit 0
