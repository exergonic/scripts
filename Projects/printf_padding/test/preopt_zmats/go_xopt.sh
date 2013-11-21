#!/bin/bash

# used to automate the repeated geometry optimization of a
# zmatrix until convergence has been reached.

# make sure we've been given the command to run.
if [ $# != 2 ] ; then
	echo "Usage:"
	echo "go_xopt xACTION zmatrixFile"
	echo "For example:"
	echo "go_xopt xPDGGOPT CAIR.z"
	exit 0
fi

# what command do we run.
COMMAND="$*"

# let's keep track of how many times
# we have to resubmit.

COUNTER=0

count()
{
	let COUNTER++
	echo cycle number $COUNTER
}

# what directory does the computer think
# it's running in?

#echo running job in $PWD

count # for the first cycle

# let user know the command
# is about to run.
# echo "running command $*"

# run the command
$COMMAND


# do we need to resubmit? grep the out file 
# for the term Resubmit to find out.

RESUBMIT=$( grep Resubmit out )
# echo $RESUBMIT

# if the term Resubmit is found in the out file
# then the RESUBMIT variable will contain text.
# while there is text in the variable, we move the 
# results to a new directory and we resubmit
# the job.

while [ -n "$RESUBMIT" ] ; do
	[ "${COUNTER}" == 2 ] && break
	mkdir -pv cycle${COUNTER} || exit 1
	mv -v log out cycle${COUNTER}/
	mv -v plt.pdb cycle${COUNTER}/plt.${COUNTER}.pdb
	cp -v sum $2 && mv sum -v cycle${COUNTER}/

	# running command again, so ...
	count
	# echo running command $*
	$COMMAND

	# look at the out file again to see
	# if we need to resubmit.
	RESUBMIT=$( grep Resubmit out )

	# i want to see the contents of the variable.
	# echo $RESUBMIT
done

mv -v plt.pdb plt.${COUNTER}.pdb

# printf "%s\n" "It would appear your system has reached convergence."

exit 0
