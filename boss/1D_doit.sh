#! /bin/bash

# doit.sh
# 
# billy's shell script to do all the heavy
# lifting for him. (he's so lazy!)
# 

# usage: call doit.sh directly from the shell, giving
# an argument
#   	clean (c)  -- to clean the directories of junk.
#	    edit  (e)  -- where sed does the magic.
#       submit (s) -- submit to the que.
#       go (g)     -- do misc user defined commands
# works for directories one level deep.
# for 2 directories deep, see 2D_doit.sh



if [ "$#" == 0 ] ; then
	echo "Needs an argument: clean (c), edit (e), submit (s), or go (g)."
	exit 0
fi

# function to define do'ing commands
submit()
{
    jobname=$( grep "set jobname" *.csh | cut -d" " -f 4 )
    jobnumber=$( ~/scripts/runboss *.csh | cut -d "." -f "1" )
    echo running $dir
    echo "${jobname}     ${jobnumber}" >> ${localdir}/jobs.txt
    touch job_${jobnumber}
}

edit()
{
    echo edit
}

go()
{
	echo go
	#
}

clean()
{
    rm -r job* *.gz log *.csh.* images &> /dev/null
}


# define the local directory
localdir=${PWD}
# define directories which numbers in their names.
dirs=$( find . -mindepth 1 -maxdepth 1 -type d | grep [0-9] | sort )

for dir in $dirs ; do
	dir=${dir#./}
	cd $dir || exit 1
	case "$1" in
		"submit" | "s" )
            submit
			;;
		"clean" | "c" )
            clean
			echo cleaned $dir
			;;
			
		"edit" | "e" )
			edit
			echo edited $dir
			;;
		"go")
			go
			echo "go'ed $dir"
			;;

		*)
			echo "Oh no! I can't do that! :-0"
			echo "Proper arguments are clean, edit, submit, or go."
			exit 1
			;;	
	esac

	cd ..
done

exit 0
