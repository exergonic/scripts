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



# 4.b. make zopts for the range
# MAKE OPTIMIZED ZMATRICES
mk_zopts()
{

    #### SANITY CHECKS ######
    # test to make sure arguments have been given.

    if [ $# != 2 ] ; then
        {
            printf "%s\n" "Arguments to mk_zopts function are required."
            printf "%s\n" "Usage: mk_zopts <xACTION> <zmatrix>"
            printf "%s\n" "Example: ./mk_zopts xPDGOPT CAIR.z"
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

    #Variables which are specific to every run and ought to be changed-----

    declare PREFIX="CH" # prefix appended to zmatrix names
    declare START="1.30"  # the initial bong length
    declare FINISH="1.50" # the final bond length
    declare INTERVAL="0.10" # intervals into which mutation will be divided

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
        # printf "%s\n" "Beginning optimization of ${NAME}."
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
}



# Everything is done!
rm ${TEMPORARY_ZMAT}
printf "%s\n\n" "Everything appears to be done."

exit 0


############################################################

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
