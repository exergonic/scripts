#!/bin/bash

# sane bash behavior
set -e
set -u
set -o pipefail

# about --------------------------------------------------------------
#
# this script is designed to run gaussian job files with a varity of 
# solvent models, cavity types, solute calculation methods, and basis 
# sets.  it is meant to do the heavy lifting of parameterization.
# it is awesome. 

# the gaussian route line ought to read something like the following:
# method/basis_set opt=(maxcycle=200) freq=noraman scrf=(solvent_model,solvent=solvent,radii=cavity)
# where the all uppercase words are substituted by the sed commands
# below.  
#
# billy wayne mccann
# thebillywayne@gmail.com
# BSD 2-clause license
# ---------------------------------------------------------------------


# variables -----------------------------------------------------------

# where script originated
basedir="$PWD"
# solvent
solvents="cyclohexane" # carbontetrachloride chloroform dichloromethane acetonitrile water"
# solvent model
# iefpcm ipcm scipcm cpcm dipole
solvent_models="iefpcm"  # ipcm scipcm cpcm dipole
# cavity model
# uff ua0 uahf uaks pauling bondi
cavitys="uaks" # pauling bondi uff #launched: ua0 uahf
# solute calculation method
# common methods:
# hf b3lyp m05 m052x m06 m062x wb97xd pbepbe x3lyp mp2 mp3
method_list="hf b3lyp m05 m052x m06 m062x wb97xd pbepbe x3lyp"
# basis sets
# common basis sets
# cc-pvdz cc-pvtz cc-pvqz aug-cc-pvdz aug-cc-pvtz
# 6-31+g(d) 6-31+g(d,p) 6-311++g(2d,p) 6-311++g(3df,3pd)
basis_set_list="6-31+g(d) 6-31+g(d,p) 6-311++g(2d,p) 6-311++g(3df,3pd) cc-pvdz cc-pvtz cc-pvqz aug-cc-pvdz aug-cc-pvtz"
# gaussian job files to operate on
gjf_files="$*"
# if you're going to submit the jobs to the queue, then define which queue.
queue="medium-parallel"

#---------------------------------------------------------------------

# tests -------------------------------------------------------------

# test to see if submit flag has been set

case $1 in ("-s"|"-submit")
	submit=yes
	gjf_files="${gjf_files/-s/}"
	gjf_files="${gjf_files/-submit/}"
	;;
esac

# test to see if any gaussian job files were specified.
# if not, exit script.
if [ "${gjf_files}" = "" ] ; then
	echo "no gaussian job files specified."
	exit -1
fi

# functions ----------------------------------------------------------

# function to have solvent model put into gjf name

_solv_model_abbrev(){
	true
}


_abbrev_solvent()
{
	solvent="$( echo $solvent | tr [:upper:] [:lower:] )"
	case $solvent in
		"acetonitrile")
			solv_abbrev="ch3cn"
			;;
		"cyclohexane")
			solv_abbrev="c6h12"
			;;
		"water")
			solv_abbrev="h2o"
			;;
		"carbontetrachloride")
			solv_abbrev="ccl4"
			;;
		"chloroform")
			solv_abbrev="chcl3"
			;;
		"dichloromethane")
			solv_abbrev="ch2cl2"
			;;
		*)
			echo "unrecognized solvent case. not abbreviating."
			solv_abbrev="${solvent}"
			;;
	esac
}



# function to have method put into the gjf names.
# method will be abbreviate as 'prefix'.
# i know it's not really a prefix; don't lecture me you pedant.
_method_prefix(){
	method="$( echo $method | tr [:upper:] [:lower:] )"
	case $method in 
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
			prefix="wb"
			;;
		pbepbe)
			prefix="pbe"
			;;
		*)
			echo "not prefixing method"
			prefix=$method
			;;
	esac
}

# function to have basis set put into gjf names
# basis set will be abbreviate to 'suffix'
_basisset_suffix(){
	case $basis_set in
		'6-31+g(d)')
			suffix='6d'
			;;
		'6-31+g(d,p)')
			suffix='6dp'
			;;
		'6-311++g(2d,p)')
			suffix='62dp'
			;;
		'6-311++g(3df,3pd)')
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
			suffix="$basis_set"
	esac
}

#----------------------------------------------------------------------

for solvent in $solvents ; do
	[[ -d "$solvent" ]] || mkdir "$solvent"
	cd "$solvent"
	_abbrev_solvent

	for solvent_model in $solvent_models; do
		[[ -d "$solvent_model" ]] || mkdir "$solvent_model"
		cd "$solvent_model"
		printf "\033[36m${solvent_model}\033[0m\n"

		for cavity in $cavitys ; do
			[[ -d "$cavity" ]] || mkdir "$cavity"
			cd "$cavity"
			printf "\033[35m${cavity}\033[0m\n"

			for method in $method_list ; do
				#create a directory for each method/basis set combination
				[[ -d "$method" ]] || mkdir $method  
				cd $method
				method_prefix

				#for each basis set, create a directory and perform actions
				for basis_set in $basis_set_list ; do
					# print the method and basis set currently being executed
					# to the screen for user feedback.
					printf "\033[33m${method}/${basis_set}\033[0m\n"
					#make directory for basis set
					#first, remove parenthesis and commas from basis set name
					basis_set_dirname="$( echo $basis_set | tr -d "(,)" )"
					#now, make the directory and move into it
					[ -d "${basis_set_dirname}" ] || mkdir  "${basis_set_dirname}" 
					cd "${basis_set_dirname}"
					#copy the gjf files from the base directory to the local directory
					for gjf_file in $gjf_files ; do
						cp "${basedir}/${gjf_file}" .
					done
					#run above functions to determine prefix and suffix
					_basisset_suffix
					# modify gjf files to include method and basis set
					# rename gjf's to include prefix and suffix
					# launch the job if the argument has been given.
					for gjf in $gjf_files  ; do
						sed -i "
							s:solvent_model:$solvent_model:
							s:cavity:$cavity:
						  s:solvent:$solvent:
						  s:method:$method:
						  s:basis_set:$basis_set:
								" $gjf 

						gjf_newname="${gjf%.gjf}.${solvent_model}.${cavity}.${solv_abbrev}.${prefix}.${suffix}.gjf"
						mv $gjf $gjf_newname 
						# if the submit option was given, then submit to queue.
						if [ "$submit" = "yes" ] 
						then
							~/scripts/gaussian/brung09 $gjf_newname $queue || echo "$job didn't run." 
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
	


printf "%s\n" "shazam!"

exit 0
