#!/bin/bash

# Billy's bash script because he's so dang lazy.

# declare some variables
declare LOCALDIR="$PWD"
declare CONSTANT="$( basename $LOCALDIR )"
declare TEMPLATE_DIR="/home/billy/research/Keto-Enol/EtN/CH3CN/refine/template_dir"
declare PREOPT_ZMAT_DIR="$LOCALDIR/preopt_zmats/" 
declare PREFIX="NH" # prefix appended to subdirectory window names
declare START="1.05"  # the initial bong length
declare FINISH="1.75" # the final bond length
declare INTERVAL="0.10"  # intervals into which mutation will be divided

if [ ! -d ${TEMPLATE_DIR} ] ; then
	printf "The set TEMPLATE_DIR doesn't appear to exist.\n"
	exit 0
fi
## create some functions to reduce code reproduction

# increment the definition of each window.
incrementWindow() 
{
	# to increment the window, we make the new window's 
	# starting point be the ending point of the previous window.

	WINDOW_START="${WINDOW_FINISH}"
	WINDOW_FINISH=$(echo "scale=2; $WINDOW_FINISH + $INTERVAL" | bc) 
	# "scale" = precision ( or, how many places after the decimal.)
	# man bc for more info
	
}

# create a new directory based upon the values of the variables.
# todo: modularize further. this function does a little too much. 
createNewDir()
{
	WINDOW="${PREFIX}_${WINDOW_START}-${WINDOW_FINISH}"
	mkdir "$WINDOW"
	cd "$WINDOW" || exit 1

	# copy files into directory and edit them ( i.e. populate directory )
	
	# first, copy the files from the template directories.
	cp ${TEMPLATE_DIR}/* . || exit 21
	cp ${PREOPT_ZMAT_DIR}/${WINDOW}/pmfzmat . || exit 22

	# now that the files are in the current directory, edit them. 
	# edit the pmfzmat
	# sed -i "s/XX/${WINDOW_START}/" pmfzmat
	# sed -i "s/YY/${WINDOW_FINISH}/" pmfzmat

	# name the csh file somthing more specific.
	mv *.csh "win${WINDOW_START}-${WINDOW_FINISH}.csh"
	# edit the csh file.
	sed -i "s/CONSTANT/${CONSTANT}/" *.csh
	sed -i "s/WINDOW/${WINDOW}/" *.csh
	sed -i "s:LOCALDIR:$PWD:" *.csh # sed can use any character as a separator. 
	 
	q -i *.csh | grep your | tee -a ../jobs.txt

	# go back to the directory we started from.
	cd ${LOCALDIR}
}

	

# initialize these two vars. after this initialization, these
# two vars will be incremented according to the function above.
WINDOW_START="${START}"  
WINDOW_FINISH=$(echo "scale=2; $WINDOW_START + $INTERVAL" | bc)

# when WINDOW_START is equal to the user set FINISH, everything is done.
# but while FINISH minus WINDOW_START is NOT ZERO, then we need to 
# create a new directory and increment the window.
while [ $( echo "${FINISH} - ${WINDOW_START}" | bc ) != 0 ] ; do
	{
		createNewDir 
		incrementWindow
	}
done


exit 0
