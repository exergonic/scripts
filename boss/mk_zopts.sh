#!/bin/bash

# ABOUT----------------------------------------------------------------
# mk_zopts.sh
# make an array of optimized zmatrices.
#
# USAGE----------------------------------------------------------------
# Files that need to be in the directory from which you launch the script:
#	1. the BOSS script files:
#		a. xACTION (e.g. xPDGOPT)
#		b. ACTIONcmd (e.g. PDGOPTcmd)
#		c. ACTIONpar (e.g. PDGOPTpar)
#	2. the go_xopt.sh script file.
#		a. used for automating the repeated optimization 
#                  of the zmatrix to convergence.
#                  TODO: remove this necessity
#		b. located at ~billy/scripts/go_xopt.sh
#	3. the zmatrix which you plan to iteratively optimize.
#		a. the value which you are changing should be replaced with X.XX.
#
# INVOCATION-----------------------------------------------------------
#
#  ./mk_zopts.sh <xACTION> <zmatrix>
#  example: ./mk_zopts.sh xPDGOPT CAIR.z
#
#----------------------------------------------------------------------


#Variables which are specific to every run and ought to be changed-----

declare PREFIX="CH" # prefix appended to zmatrix names
declare START="1.30"  # the initial bong length
declare FINISH="1.50" # the final bond length
declare INTERVAL="0.10" # intervals into which mutation will be divided

# create a usage function to be printed if there are errors.
usage()
{
	sed -e 's/^	//' <<EndUsage

	Usage:  ./mk_zopts.sh <xACTION> <zmatrix>
	Example:  ./mk_zopts.sh xPDGOPT CAIR.z

	Files that need to be in the directory from which you launch this script are:
		1. the BOSS script files:
			a. xACTION (e.g. xPDGOPT)
			b. ACTIONcmd (e.g. PDGOPTcmd)
			c. ACTIONpar (e.g. PDGOPTpar)
		2. Billy's go_xopt.sh script file.
			a. used for automating the repeated optimization 
				of the zmatrix to convergence.
			b. located at ~billy/scripts/go_xopt.sh
		3. the zmatrix which you plan to iteratively optimize.
			a. the value which you are changing should be replaced with X.XX.
EndUsage
	printf "\n"
	exit 1
}


#### SANITY CHECKS ######
# test to make sure arguments have been given.

if [ $# != 2 ] ; then
	{
		printf "%s\n" "Arguments are required."
		printf "%s\n\n" "Usage: mk_zopts.sh <xACTION> <zmatrix>"
		printf "%s\n\n" "Example: ./mk_zopts xPDGOPT CAIR.z"
		exit 1
	}
fi

# test to make sure all needed files are in current directory. if not, print usage message.
[ ! -e x* ] && printf "xACTION file isn't in current directory.\n" && usage
[ -e x* -a ! -x x* ] && echo "xACTION script isn't executable. Run 'chmod +x xACTION' on it and retry." && usage
[ ! -e *par ] && echo "par file isn't in current directory." && usage
[ ! -e *cmd ] && echo "cmd file isn't in current directory." && usage
[ ! -e go_xopt.sh ] && echo "go_xopt.sh script file isn't in current directory. It can be found in ~billy/scripts/go_xopt.sh ." && usage
[ -e go_xopt.sh -a ! -x go_xopt.sh ] && echo "go_xopt.sh file isn't executable. Run 'chmod +x go_xopt.sh' and then try again." && usage
[ -z "$(grep X.XX $2)" ] && echo "Cannot find string 'X.XX' within specified zmatrix. Replace the variable value with X.XX and run again." && usage


#### DECLARE VARIABLES ######

# Variables which shouldn't be changed from run to run-----------------

declare LOCALDIR="$PWD"
declare xACTION="$1"
declare TEMPLATE_ZMAT="${LOCALDIR}/${2}"
declare TEMPORARY_ZMAT="${LOCALDIR}/.temp_zmat" # making it hidden so it's not accidentally erased.
declare LINENUMBER="$( grep -n X.XX $2 | cut -d: -f 1 )" # line upon which atom appears
declare ATOMNUMBER="$(( $LINENUMBER - 1 ))"
declare NEWLINE="$( grep -n "Geometry Variations follow" $2 | cut -d: -f 1 )"
declare NEWNUMBER="$( printf "%04d" "${ATOMNUMBER}" )"


#----------------------------------------------------------------------


# FUNCTIONS -----------------------------------------------------------

# function to increment the definition of each window.
incrementWindow() 
{
	WINDOW_START="${WINDOW_FINISH}"
	WINDOW_FINISH="$( echo "scale=2; $WINDOW_FINISH + $INTERVAL" | bc )"
}

# function to morph the sum file into pmfzmat
mv_sum2zmat()
{
	# the sum file is converted to a zmatrix
	# inside a directory named after the prefix defined above and
	# the window start and finish in the format PREFIX_START-FINISH.
	# therefore the directory name string can be chopped to extract the 
	# start and finish values and find the midpoint between the two.
	SET=$( basename `pwd` | cut -d "_" -f 2 )
	WIN_START="$( echo ${SET} | cut -d "-" -f 1 )"
	WIN_FINISH="$( echo ${SET} | cut -d "-" -f 2 )"
	# add WIN_START to WIN_FINISH and divide by two to get the midpoint.
	MIDPOINT=$( echo "scale=2 ; ($WIN_START + $WIN_FINISH) / 2" | bc ) 

	# make strings all the same length
	WIN_START="$( printf "%-8s" ${WIN_START} )"
	MIDPOINT="$( printf "%-8s" ${MIDPOINT} )"
	# $WIN_FINISH need not have to be 8 characters in length
	
	# copy the sum file to pmfzmat
	cp sum pmfzmat


	sed -i "${LINENUMBER}s/${MIDPOINT}/${WIN_START}/" pmfzmat
	sed -i "${NEWLINE}s/$/\n${NEWNUMBER}0001  ${WIN_FINISH}/" pmfzmat 

}

# function to create a new directory and zmat file 
# based upon the values of the variables and to optimize the zmatrix. 
createNewDir()
{
	# we are going to name the directory and the zmat file the same name
	NAME="${PREFIX}_${WINDOW_START}-${WINDOW_FINISH}"
	mkdir "$NAME"
	cd "$NAME" || exit 1


	##  copy BOSS script files into directory and edit them ( i.e. populate directory )
	
	# first, copy the BOSS script files necessary for optimization to the working directory
	cp ${LOCALDIR}/x* .
	cp ${LOCALDIR}/*par .
	cp ${LOCALDIR}/*cmd .

	# copy billy's go_xopt.sh script for full automation of the optimization to convergence
    cp ${LOCALDIR}/go_xopt.sh .	

	#copy the temporary zmatrix file to the working directory and rename it.
	cp ${TEMPORARY_ZMAT} ./${NAME}.z 

	# now that the zmat is the current directory, edit it. 
	# the bond length is the midpoint of the current window's range
	BOND_LENGTH=$( echo "scale=2; (${WINDOW_START} + ${WINDOW_FINISH}) /2" | bc )

	# the script looks for X.XX somewhere in the zmatrix file and replaces it with the midpoint bond length.
	X_STRING="$( printf "%-8s" X.XX )" # guarantees X.XX to be 8 chars in length
	BOND_LENGTH="$( printf "%-8s" ${BOND_LENGTH} )" # guarantee the $BOND_LENGTH to be 8 chars in length

	sed -i "${LINENUMBER}s/${X_STRING}/${BOND_LENGTH}/" ${NAME}.z

	# time to optimize the zmatrix all the way to convergence.
	 printf "%s\n" "Beginning optimization of ${NAME}."
	./go_xopt.sh ${xACTION} ${NAME}.z 

	# convert the final sum file to a pmfzmat 
	mv_sum2zmat

	# copy the final sum file to the temporary zmatrix location for use in the next window.
	cp sum ${TEMPORARY_ZMAT}

	# go back to the directory we started from.
	cd ${LOCALDIR}

	# replace the old BOND_LENGTH value with X.XX so that the
	# next optimization finds X.XX and replaces it with the new BOND_LENGTH.
	sed -i "${LINENUMBER}s/${BOND_LENGTH}/${X_STRING}/" ${TEMPORARY_ZMAT}
}

# get information from the user
#getInfo()
#{
#	read -p "Prefix for names of zmatrices: " PREFIX
#	read -p "Which atom are we mutating: " ATOMNUMBER
#	read -p "Initial bond length: " START
#	read -p "Final bond length: " FINISH
#	read -p "Interval for individual windows: " INTERVAL
#	printf "\n"
#}


#### START THE ACTION!! #########

#getInfo


# test to see if the INTERVAL divides evenly for the given START and FINISH.
# if not, tell the user and get information again.
#if [ $( echo "($FINISH-$START)%$INTERVAL" | bc ) != 0 ] ; then
#	{
#		echo "It appears your range is not evenly"
#		echo "divisible by your interval."
#		echo "Are you sure you entered it correctly?"
#		echo ""
#
#		#getInfo
#		exit 11
#	}
#fi
	
# the entire mutation shall be dividied into separate windows.
# the first window starting point is the initial bond length set by the user.
WINDOW_START="${START}"  
# the first window finishing point is the initial bond length plus the interval, set by the user.
WINDOW_FINISH=$(echo "scale=2; $WINDOW_START + $INTERVAL" | bc)

# where sed can find the X.XX to replace with $BOND_LENGTH
# LINENUMBER=$(( $ATOMNUMBER + 1 ))

# copy the template zmatrix to a temporary zmatrix file 
# that will be replaced with subsequent energy minimized
# zmatrices for each window. the next window will use this 
# zmatrix as its starting point.
cp ${TEMPLATE_ZMAT} ${TEMPORARY_ZMAT}

# loop the creation of new directories and zmats and increment the window 
# until the window's initial value is the same as the finishing value of 
# the entire calculation.  at that point, everything is done.
while [ $( echo "${FINISH} - ${WINDOW_START}" | bc ) != 0 ] ; do
	{
		createNewDir
		incrementWindow
	}
done


# Everything is done!
rm ${TEMPORARY_ZMAT}
printf "%s\n\n" "Everything appears to be done."

exit 0
