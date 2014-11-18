#!/bin/bash

# About --------------------------------------------------------------
#
# This script is designed to run gaussian job files with a varity of 
# solvent models, cavity types, solute calculation methods, and basis 
# sets.  It is meant to do the heavy lifting of parameterization.
# It is awesome. 

# The gaussian route line ought to read something like the following:
# METHOD/BASIS_SET opt=(maxcycle=200) freq=noraman scrf=(SOLVENT_MODEL,solvent=SOLVENT,radii=CAVITY)
# where the all uppercase words are substituted by the sed commands
# below.  
#
# Billy Wayne McCann
# bwm0005@auburn.edu
#
# ---------------------------------------------------------------------


# VARIABLES -----------------------------------------------------------

# where script originated
BASEDIR="$PWD"
# solvent
SOLVENTS="cyclohexane" # carbontetrachloride chloroform dichloromethane acetonitrile water"
# solvent model
# IEFPCM IPCM SCIPCM CPCM DIPOLE
SOLVENT_MODELS="iefpcm"  # ipcm scipcm cpcm dipole
# cavity model
# UFF UA0 UAHF UAKS PAULING BONDI
CAVITYS="uaks" # pauling bondi uff #launched: ua0 uahf
# solute calculation method
# common methods:
# HF B3LYP M05 M052X M06 M062X wB97XD PBEPBE X3LYP MP2 MP3
METHOD_LIST="hf b3lyp m05 m052x m06 m062x wb97xd pbepbe x3lyp"
# basis sets
# common basis sets
# cc-pvdz cc-pvtz cc-pvqz aug-cc-pvdz aug-cc-pvtz
# 6-31+G(d) 6-31+G(d,p) 6-311++G(2d,p) 6-311++G(3df,3pd)
BASIS_SET_LIST="6-31+G(d) 6-31+G(d,p) 6-311++G(2d,p) 6-311++G(3df,3pd) cc-pvdz cc-pvtz cc-pvqz aug-cc-pvdz aug-cc-pvtz"
# gaussian job files to operate on
GJF_FILES="$*"
# if you're going to submit the jobs to the queue, then define which queue.
QUEUE="medium-parallel"

#---------------------------------------------------------------------

# TESTS -------------------------------------------------------------

# test to see if submit flag has been set

case $1 in ("-s"|"-submit")
	SUBMIT=YES
	GJF_FILES="${GJF_FILES/-s/}"
	GJF_FILES="${GJF_FILES/-submit/}"
	;;
esac

# test to see if any gaussian job files were specified.
# if not, exit script.
if [ "${GJF_FILES}" = "" ] ; then
	echo "No gaussian job files specified."
	exit -1
fi

# FUNCTIONS ----------------------------------------------------------

# function to have solvent model put into gjf name

solv_model_abbrev(){
	true
}


abbrev_solvent()
{
	SOLVENT="$( echo $SOLVENT | tr [:upper:] [:lower:] )"
	case $SOLVENT in
		"acetonitrile")
			solv_abbrev="CH3CN"
			;;
		"cyclohexane")
			solv_abbrev="C6H12"
			;;
		"water")
			solv_abbrev="H2O"
			;;
		"carbontetrachloride")
			solv_abbrev="CCL4"
			;;
		"chloroform")
			solv_abbrev="CHCL3"
			;;
		"dichloromethane")
			solv_abbrev="CH2CL2"
			;;
		*)
			echo "Unrecognized solvent case. Not abbreviating."
			solv_abbrev="${SOLVENT}"
			;;
	esac
}



# function to have method put into the gjf names.
# method will be abbreviate as 'prefix'.
# i know it's not really a prefix; don't lecture me you pedant.
method_prefix(){
	METHOD="$( echo $METHOD | tr [:upper:] [:lower:] )"
	case $METHOD in 
		hf) 
			prefix="hf"
			;;
		mp2)
			prefix="mp2"
			;;
		mp3)
			prefix="mp3"
			;;
		b3lyp)
			prefix="b3"
			;;
		m05)
			prefix="m05"
			;;
		m052x)
			prefix="m052x"
			;;
		m06)
			prefix="m06"
			;;
		m062x)
			prefix="m062x"
			;;
		x3lyp)
			prefix="x3"
			;;
		wb97xd)
			prefix="wB"
			;;
		pbepbe)
			prefix="pbe"
			;;
		*)
			echo "not prefixing method"
			prefix=$METHOD
			;;
	esac
}

# function to have basis set put into gjf names
# basis set will be abbreviate to 'suffix'
basisset_suffix(){
	case $BASIS_SET in
		'6-31+G(d)')
			suffix='6d'
			;;
		'6-31+G(d,p)')
			suffix='6dp'
			;;
		'6-311++G(2d,p)')
			suffix='62dp'
			;;
		'6-311++G(3df,3pd)')
			suffix='63df'
			;;
		'cc-pvdz')
			suffix='2'
			;;
		'cc-pvtz')
			suffix='3'
			;;
		'cc-pvqz')
			suffix='4'
			;;
		'aug-cc-pvdz')
			suffix='aug2'
			;;
		'aug-cc-pvtz')
			suffix='aug3'
			;;
		'aug-cc-pvqz')
			suffix='aug4'
			;;
		*)
			echo 'basis set not suffixed'
			suffix="$BASIS_SET"
	esac
}

#----------------------------------------------------------------------

for SOLVENT in $SOLVENTS ; do
	[ -d "$SOLVENT" ] || mkdir "$SOLVENT"
	cd "$SOLVENT"
	abbrev_solvent

	for SOLVENT_MODEL in $SOLVENT_MODELS; do
		[ -d "$SOLVENT_MODEL" ] || mkdir "$SOLVENT_MODEL"
		cd "$SOLVENT_MODEL"
		printf "\033[36m${SOLVENT_MODEL}\033[0m\n"

		for CAVITY in $CAVITYS ; do
			[ -d "$CAVITY" ] || mkdir "$CAVITY"
			cd "$CAVITY"
			printf "\033[35m${CAVITY}\033[0m\n"


			for METHOD in $METHOD_LIST ; do
				#create a directory for each method/basis set combination
				[ -d "$METHOD" ] || mkdir $METHOD  
				cd $METHOD
				method_prefix

				#for each basis set, create a directory and perform actions
				for BASIS_SET in $BASIS_SET_LIST ; do
					# print the method and basis set currently being executed
					# to the screen for user feedback.
					printf "\033[33m${METHOD}/${BASIS_SET}\033[0m\n"
					#make directory for basis set
					#first, remove parenthesis and commas from basis set name
					BASIS_SET_DIRNAME="$( echo $BASIS_SET | tr -d "(,)" )"
					#now, make the directory and move into it
					[ -d "${BASIS_SET_DIRNAME}" ] || mkdir  "${BASIS_SET_DIRNAME}" 
					cd "${BASIS_SET_DIRNAME}"
					#copy the gjf files from the base directory to the local directory
					for GJF_FILE in $GJF_FILES ; do
						cp "${BASEDIR}/${GJF_FILE}" .
					done
					#run above functions to determine prefix and suffix
					basisset_suffix
					# modify GJF files to include method and basis set
					# rename gjf's to include prefix and suffix
					# launch the job if the argument has been given.
					for GJF in $GJF_FILES  ; do
						sed -i "s:SOLVENT_MODEL:$SOLVENT_MODEL:" $GJF
						sed -i "s:CAVITY:$CAVITY:" $GJF
						sed -i "s:SOLVENT:$SOLVENT:" $GJF
						sed -i "s:METHOD:$METHOD:" $GJF 
						sed -i "s:BASIS_SET:$BASIS_SET:" $GJF 
						GJF_NEWNAME="${GJF%.gjf}.${SOLVENT_MODEL}.${CAVITY}.${solv_abbrev}.${prefix}.${suffix}.gjf"
						mv $GJF $GJF_NEWNAME 
						# if the submit option was given, then submit to queue.
						if [ "$SUBMIT" = "YES" ] 
						then
							~/scripts/gaussian/brung09 $GJF_NEWNAME $QUEUE || echo "$JOB didn't run." 
						fi
					done

					cd ..
					#now out of basis set directory, in method directory

				done

			cd ..
			# out of method directory, now in solvent directory
			done

			cd ..
			# out of solvent directory, now in cavity type directory
		done

		cd ..
		# out of cavity directory now in solvent model directory

	done

	cd ..
	# out of solvent model directory, now in base directory

done
	


printf "%s\n" "Shazam!"

exit 0
