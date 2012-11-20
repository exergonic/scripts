#!/bin/bash

# script to make them solvents yo

#- VARIABLES ----------------------------------------------- 
# original directory in which from which script is launched
BASEDIR="$PWD"
# the gaussian job files are the arguments given to the script
GJF_FILES="$*"
# which supercomputer que to submit to
QUEUE="small-parallel"
# which solvents to use
SOLVENTS="cyclohexane water acetonitrile"
#-----------------------------------------------------------

# test to be sure arguments are given
if [ $# -eq 0 ] 
then
	echo "No arguments given."
	echo "This script uses the gjf files as arguments."
	echo "Example: ./solvents.sh file1.gjf file2.gjf"
	echo "As many gjf files can be called as wanted."
	echo "Use the -s flag if you want the jobs to be submitted."
	echo "Be sure to use the correct queue."
	exit -1
fi


case $1 in ("-s"|"-submit")
	SUBMIT=YES
	GJF_FILES="${GJF_FILES/-s/}"
	GJF_FILES="${GJF_FILES/-submit/}"
	;;
esac

# function to launch the jobs, should the
# -s argument be given
launch()
{
	~/scripts/gaussian/brung09 ${GJF%.gjf}.${ABBREV}.gjf ${QUEUE}
}

# function to ABBREViate the solvent names
ABBREV_solvent()
{
	case $SOLVENT in
		"acetonitrile")
			ABBREV="CH3CN"
			;;
		"cyclohexane")
			ABBREV="C6H12"
			;;
		"water")
			ABBREV="H2O"
			;;
		*)
			echo "Unrecognized solvent case."
			echo "Not ABBREViating solvent name."
			echo "Add solvent name and ABBREViation to case in script"
			echo "to have the name ABBREViated."
			ABBREV="${SOLVENT}"
			;;
	esac
}


for SOLVENT in $SOLVENTS ; do
	[ ! -d "$SOLVENT" ] && mkdir "$SOLVENT"
	cd $SOLVENT || exit 1
	echo $SOLVENT

	#get them job files, dog
	for GJF_FILE in ${GJF_FILES}
	do
		cp ${BASEDIR}/${GJF_FILE} . || exit 2
	done
		

	#strip the BASEDIR variable from the GJF_FILES for 
	# manipulation within this directory
	#GJF_FILES=${ORIGINAL_GJF_FILES//${BASEDIR}\//}
	
	# call the ABBREV_solvent function to ABBREViation the solvent
	# name to put in the name of the job file
	ABBREV_solvent

	# put in the scrf line, yo
	for GJF in $GJF_FILES ; do
		sed -i "4s:$: scrf=(iefpcm,solvent=${SOLVENT}):" ${GJF}
		# rename the job file
		mv $GJF ${GJF%.gjf}.${ABBREV}.gjf
		[ "$SUBMIT" = "YES" ] && launch 
	done

	cd ..
done

echo all done yo

exit 0
