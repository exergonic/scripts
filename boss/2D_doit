#!/bin/bash

# ABOUT  ######################################################################
#
# To be used in conjunction with BOSS program.
# Script performs various actions on all of the directories
# 2 levels deep from the current directory.
# These directories correspond to the working directories for calculations 
# involving 2D pmf calculations.  
#
###############################################################################
#
# INVOCATION  #################################################################
#
# Requires an argument.
# 1. Clean - removes unnecessary files from previous calculation
# 2. submit - submit the jobs
# 3. Edit - edit the files using sed
# 4. Go - do any user defined set of actions
#
###############################################################################
#
# Author : Billy Wayne McCan
# email  : thebillywayne@gmail.com
###############################################################################


# check to see if an argument has been given
if [ "$#" == 0 ] ; then
	echo "Needs an argument: clean(c), submit(s), edit(e), go."
	exit 1
fi

# function to clean directories of files leftover from a previous calculation.
clean()
{
    [ -e images ] && rm -r images
    rm *.csh.* log *.gz job* &> /dev/null
    echo cleaned ${dir}/${subdir}
}

# submit *all* the jobs
# will store the job name and number in a job.txt file in the base directory
submit()
{
    if [[ -e job* ]] ; then
        echo "job file exists. skipping ${dir#./}/${subdir#./}"
    else
        jobname=$( grep "set jobname" *.csh | cut -d " " -f 4 )
        jobnumber=$( ~/scripts/runboss *.csh | cut -d "." -f "1" )
        echo running ${dir}/${subdir}
        echo "${jobname}     ${jobnumber}" >> ${localdir}/jobs.txt
        touch job_${jobnumber}
    fi
}


# function to edit files. sed is your friend. :)
edit()
{
 	sed -i "10s:/.*:${PWD}:" *.csh
	sed -i "71s:PDB     1     0.0       0.0:PDB     1     0.0       1.0:" pmfpar

}

# function to do whatever you like
go()
{
	
	mkdir old.results
	mv *.gz log job* old.results/
	touch old.results/non.polarized.solvent
	sed -i "71s/PDB     1     0.0       0.0/PDB     1     0.0       1.0/" pmfpar

}


localdir=${PWD}
dirs="$( find . -mindepth 1 -maxdepth 1 -type d | grep [0-9] | sort  )"

for dir in ${dirs} ; do 
	dir=${dir#./}
	cd $dir
	subdirs="$( find . -mindepth 1 -maxdepth 1 -type d | grep [0-9] | sort )"
	for subdir in ${subdirs} ; do
		subdir=${subdir#./}
		cd ${subdir}
		case $1 in
			"edit" | "e" )
				echo editing ${dir#./}/${subdir#./}
				edit
				;;
			"submit" | "s" )
                echo "submitting ${dir#./}/${subdir#./}"
                submit
				;;
			"clean" | "c" )
				echo "cleaning ${dir}/${subdir}"
                clean
				;;
			"go" )
				echo "go'ing ${dir}/${subdir}"
				go
				;;
			*)
				echo "Messed up case"
				exit 2
				;;
		esac
		cd ..

	done

	cd ..
done

exit 0
