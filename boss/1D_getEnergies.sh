#! /bin/bash 

# ABOUT ######################################################################
#
# Used in conjunction with BOSS.
#
# Recursivly extracts Delta G values for a set a calculations
# over a single variable pmf, e.g. the stretching of a single bond.
#
# Places the Delta G values in a text file called energies.txt or
# energies.verbose.txt if the -v flag is set. The verbose output
# prints the entire grep'ed line whereas the standard prints only
# the Delta G values.
#  
# Run this script from the directory which contains all of the 
# subdirectories containing the calculations.
#
# INVOCATION  ##################################################################
#
# Without any arguments, will print ONLY the Delta G values.
# Add the -v argument for a more verbose output, which will include the entire
# line containing window information, etc.


# the working directory and its subdirectories
workdir="$PWD"
dirs="$( find .  -mindepth 1 -maxdepth 1 -type d | grep [0-9] | sort )"

# check to see if user wants verbose output
# rename the output text accordingly
if [[ "$1" = "-v" ]] ; then
	sumfile="$workdir/energies.verbose.txt"
else
	sumfile="$workdir/energies.txt"
fi

# check if there's already a summary file in the working directory.
# remove it, if so.
if [[ -e "$sumfile" ]] ; then
	rm "$sumfile"
fi

# create the summary file and place the date in it.
touch "$sumfile"
printf "\n%s\n\n" "stardate = $(date)" >> "$sumfile"

# grepping the DeltaG's from the subdirectories
# and producing a summary file.
for subdir in $dirs ; do
	cd "$subdir" || exit 2
    subdir="${subdir#./}" #chop off the initital ./ in fron top the dir name

	# test to see if the BOSS log file exists
    # if it doesn't, it usually means the job isn't yet complete.
	if [[ -e log ]] ; then
		if
			[[ "$1" = "-v" ]] ; then
			zgrep 'DeltaG' d*sum.gz >> ${sumfile}
		else
			zgrep 'DeltaG'  d*sum.gz | awk -F" " '{ print $8 }' >> $sumfile
		fi
	else 
			# we want to know if the log file(s) don't exist.
			printf "%s\n" "log file doesn't exist in $subdir." | tee -a $sumfile
			printf "%s\n" "This usually means calculations aren't completed." | tee -a $sumfile 
	fi
	cd ..
done

printf "%s\n" "$0 complete."

exit 0
