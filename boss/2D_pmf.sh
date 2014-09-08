#!/bin/bash

# algorithm:
# for every CH bond length value, do the following:
# 1. make directory
# 2. cd into directory
# 3. copy scripts and preopt_zmat from template directory into 
#	the current directory
# 4. cd into preopt_zmat dir
# 	a. change CH bond length
#	b. make zopts for the range
# 5. run 1D_mutation script
# 6. submit the job

# function that does all the dirty work
# the actual variables are set below this function
_2D_pmf()
{
	for CONST_VALUE in ${CONST_RANGE} ; do
		DIRNAME="${CONST_PREFIX}_${CONST_VALUE}"
		[ ! -d "$DIRNAME" ] && mkdir -v $DIRNAME 
		cd $DIRNAME || exit 1
		echo $DIRNAME
		
		cp -r ${TEMPLATE_DIR}/preopt_zmats .
		cp ${TEMPLATE_DIR}/mk_1D_mutation_dirs.sh .
		cd ./preopt_zmats || exit 3
		YLINENUMBER="$( grep -n Y.YY *.z | cut -d: -f 1 )"
		sed -i "${YLINENUMBER}s/Y.YY/${CONST_VALUE}/" *.z
		./mk_zopts.sh x* *.z 
		cd ..
		./mk_1D_mutation_dirs.sh
		rm ./mk_1D_mutation_dirs.sh
		printf "\n\n"
		cd ..
	done
}

# function to flip the X and Y values when changing from
# "normal" FEP windows to the cross term and back again
_flipXY()
{

	YLINENUMBER="$( grep -n Y.YY ./template_dir/preopt_zmats/*.z | cut -d: -f 1 )"
	XLINENUMBER="$( grep -n X.XX ./template_dir/preopt_zmats/*.z | cut -d: -f 1 )"

	sed -i "${YLINENUMBER}s/Y.YY/X.XX/" ./template_dir/preopt_zmats/*.z
	sed -i "${XLINENUMBER}s/X.XX/Y.YY/" ./template_dir/preopt_zmats/*.z
}

# which directory was the script call from?
LOCALDIR=${PWD}

# the template directory, from which all files are copied,
# is located in a dir named template_dir.  this directory
# is a template of every directory that will be created for the
# pmf job.  examine and edit these files as needed.
export TEMPLATE_DIR="${LOCALDIR}/template_dir"

# the pmf jobs are ran such that one bond is held constant 
# and the other is mutated.  this constant prefix is used
# in the naming of the directories and the naming of the 
# the jobs ( in the csh file submitted to que ).  
CONST_PREFIX="CH"

# in a 2D pmf job, the bond length that is held constant
# is mutated manually.  specify the range below.  see
# `man seq' for how to parse this command.
CONST_RANGE="1.13" #$( seq -w 1.45 0.01 1.49 )" 

# for variable bond length
# the prefix is used in the naming of directories and jobs.
export PREFIX="NH"

# specify the initial and final bond lengths, along with
# the interval into which the mutation is divided.  this 
# in conjunction with nsteps, specified in the pmfcmd file,
# determines the mutation length of each window. an interval
# of 0.10 with nsteps = 5 will give 0.01 angstrom pmf windows.
export START="1.05"
export FINISH="6.05"
export INTERVAL="0.02"

_2D_pmf
 

# another cycle with different terms if necessary ######################
# uncomment if another cycle is necesssary #############################

# for constant
#CONST_RANGE="1.50" #$( seq -w 1.51 0.01 1.60 )" 
# for variable
#export START="1.20"
#export FINISH="1.30"
#export INTERVAL="0.10"
#
#_2D_pmf

##### NOW FOR THE CROSS DIR ############################################

# replace X.XX and Y.YY in the template zmat file##
#_flipXY


## set the new variables for the cross term
#CONST_PREFIX="NH"
#CONST_RANGE="1.10"
#
## for variable
#export PREFIX="CH"
#export START="1.40"
#export FINISH="1.50"
#export INTERVAL="0.10"
#
#
#_2D_pmf


######CROSS TERM FINISHED###############################################


# put X.XX and Y.YY in the template zmatrix file back where they were
# originally before the script was ran.
# replace X.XX and Y.YY in the template zmat file
#_flipXY



echo "Script $0 complete."
# all done

exit 0
