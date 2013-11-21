#!/bin/bash

# About --------------------------------------------------------------
#
# Script to set-up and optionally (-s) run a series of gaussian 
# calculations with a variety of methods and basis-sets.  
# 
# The route ought to appear something like ....
#        #  METHOD/BASIS_SET opt freq=noraman
# ... so that the method and basis set are correctly substituted
# in the gaussian job file.  
# 
# Usage --------------------------------------------------------------
#
# Fill in the variables below.  Change the queue as necessary.
# Invoke with ./full9yards.sh <names of job files>
# Invoking with -s will submit the jobs to the queue.
# Invoking with *.gjf is accepted.
#
#---------------------------------------------------------------------

# VARIABLES -----------------------------------------------------------

# Variables to change from run to run, depending.
METHOD_LIST="PBEh1PBE"
# common methods:
# HF B3LYP M05 M052X M06 M062X wB97XD PBEPBE X3LYP MP2 MP3

BASIS_SET_LIST="6-31+G(d) 6-31+G(d,p) 6-311++G(2d,p) 6-311++G(3df,3pd) cc-pvdz cc-pvtz cc-pvqz aug-cc-pvdz aug-cc-pvtz"
# common basis sets
# cc-pvdz cc-pvtz cc-pvqz aug-cc-pvdz aug-cc-pvtz
# 6-31+G(d) 6-31+G(d,p) 6-311++G(2d,p) 6-311++G(3df,3pd)
# if you're going to submit the jobs to the queue, then define which queue.
QUEUE="medium-parallel"

# Variables which don't need changing
BASEDIR="$PWD"
GJF_FILES="$*"

#---------------------------------------------------------------------

# TESTS -------------------------------------------------------------

# test to see if submit flag has been set

case $1 in ("-s"|"-submit")
	SUBMIT=YES
	GJF_FILES="${GJF_FILES/-s/}"
	GJF_FILES="${GJF_FILES/-submit/}"
	;;
esac

# FUNCTIONS ----------------------------------------------------------

# function to have method put into the gjf names.
# method will be abbreviate as 'prefix'.
# i know it's not really a prefix; don't lecture me you pedant.
method_prefix(){
	case $METHOD in 
		HF) 
			prefix="hf"
			;;
		MP2)
			prefix="mp2"
			;;
		MP3)
			prefix="mp3"
			;;
		B3LYP)
			prefix="b3"
			;;
		M05)
			prefix="m05"
			;;
		M052X)
			prefix="m052x"
			;;
		M06)
			prefix="m06"
			;;
		M062X)
			prefix="m062x"
			;;
		X3LYP)
			prefix="x3"
			;;
		wB97XD)
			prefix="wB"
			;;
		PBEPBE)
			prefix="pbe"
			;;
		PBEh1PBE)
			prefix="pbeh1"
			;;
		HSEh1PBE)
			prefix="hse"
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

for METHOD in $METHOD_LIST ; do
	#create a directory for each method/basis set combination
	[ -d "$METHOD" ] || mkdir $METHOD  
	cd $METHOD

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
		method_prefix
		basisset_suffix
		# modify GJF files to include method and basis set
		# rename gjf's to include prefix and suffix
		# launch the job if the argument has been given.
		for GJF in $GJF_FILES  ; do
			sed -i "s:METHOD:$METHOD:" $GJF 
			sed -i "s:BASIS_SET:$BASIS_SET:" $GJF 
			GJF_NEWNAME="${GJF%.gjf}.${prefix}.${suffix}.gjf"
			mv $GJF $GJF_NEWNAME 
			# if the submit option was given, then submit to queue.
			if [ "$SUBMIT" = "YES" ] 
			then
				~/scripts/gaussian/brung09 $GJF_NEWNAME $QUEUE || echo "$JOB didn't run." 
			fi
		done

		cd ..
		#now out of directory

	done

	cd ..
	#now back in basedir, from which the script started.
done

printf "%s\n" "Shazam!"

exit 0
