#!/bin/bash

# ABOUT ---------------------------------------------------------------
#
# go_xopt.sh
# optimize a zmatrix to full convergence.
# to be used in conjunction with the BOSS xSCRIPTS.
#
# INVOCATION ---------------------------------------------------------
#
# > ./go_xopt.sh xSCRIPT zmatrix
#
# optionally, a cycle limit can be placed as the third argument
# > ./go_xopt.sh xSCRIPT zmatrix 2
# will invoke the xSCRIPT only twice.
# otherwise the xSCRIPT will be invoked until full convergence is reported.
#
# -----------------------------------------------------------------------


# Argument test --------------------------------------------------------
# number of arguments must be at least two

if [ "$#" -lt 2 ] ; then
	echo "Usage:"
	echo "go_xopt.sh xACTION zmatrixFile"
	echo "For example:"
	echo "go_xopt xPDGGOPT pmfzmat"
	echo ""
	echo "A limit can be placed on the"
	echo "number of optimization cycles"
	echo "by placing an integer as the "
	echo "third argument."
	echo "For example:"
	echo "go_xopt.sh xPDGGOPT pmfzmat 3"
	echo ""
	exit 0
fi

#----------------------------------------------------------------------


# Begin main script ---------------------------------------------------

# keep a copy of the original zmatrix
cp $2 ${2}.orig

# let the user know that the cycle limit has
# been respected
[ -n "$3" ] && printf "%s\n" "A cycle limit of ${3} is in effect."

# let's keep track of how many times
# we have to resubmit.
SUBMIT_COUNTER=0

count()
{
	let SUBMIT_COUNTER++
	echo cycle number $SUBMIT_COUNTER
}


# for the first cycle
count 

# the command that is executed are the first two positional parameters.
COMMAND="$1 $2"
# output the command that's to be run
echo "running command $COMMAND"
# run the command
$COMMAND


# do we need to resubmit? grep the out file 
# for the term Resubmit to find out.
RESUBMIT=$( grep Resubmit out )
echo $RESUBMIT

# if the term Resubmit is found in the out file
# then the RESUBMIT variable will contain text.
# while there is text in the variable, we move the 
# results to a new directory and we resubmit
# the job.

while [ -n "$RESUBMIT" ] ; do

	# check to see if a cycle limit has been placed
	if [ -n "$3" ] ; then
		CYCLE_LIMIT=$3
		if [ "${SUBMIT_COUNTER}" -eq "${CYCLE_LIMIT}" ]; then
			break
		fi
	fi

	# create a directory for the cycle and move
	# the results into it.
	mkdir -pv cycle${SUBMIT_COUNTER} || exit 1
	mv log out cycle${SUBMIT_COUNTER}/
	mv plt.pdb cycle${SUBMIT_COUNTER}/plt.${SUBMIT_COUNTER}.pdb
	cp sum $2 && mv sum cycle${SUBMIT_COUNTER}/

	# running command again, so ...
	count
	$COMMAND

	# look at the out file again to see
	# if we need to resubmit.
	RESUBMIT=$( grep Resubmit out )
	# echo the contents of the variable.
	echo $RESUBMIT

	# at this point the RESUBMIT variable will be tested again
	# by the while loop test. if it contains text, the loop will
	# execute again.
done

# after all of the cycles are done, leave the final results
# in the starting directory and make the pdb file reflect 
# the cycle number.
mv -v plt.pdb plt.${SUBMIT_COUNTER}.pdb

printf "%s\n" "It would appear your system has reached convergence."

exit 0
