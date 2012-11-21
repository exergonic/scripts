#! /bin/bash

# doit.sh
# 
# billy's shell script to do all the heavy
# lifting for him. (he's so lazy!)
# 

# usage: call doit.sh directly from the shell, giving
# an argument
#   	clean -- to clean the directories of junk.
#	edit  -- where sed does the magic.
#       submit -- submit to the que.
# works for directories one level deep.
# for 2 directories deep, see 2D_doit.sh



if [ "$#" == 0 ] ; then
	echo "Needs an argument: clean (c) , edit (e) , or submit (s)."
	exit 0
fi

# function to define editing commands
edit()
{
	#sed -i "29s:$:\ncp ~/datafiles/slvzmat slvzmat\ncp ~/datafiles/cyclohex.in d10in:" *.csh
	#sed -i "3s/TIP4P/OTHER/" pmfpar
	sed -i "9s/BOXES/IN/" pmfpar
	#sed -i "13s/BOSS/BOSS-cyclohex/" pmfcmd
	#sed -i "9s/TIP4P/C6H12/" *.csh
	#sed -i "10s:/.*:${PWD}:" *.csh
	#mv *.csh Pyr.C6H12.${dir}.csh
}

go()
{
	echo go
	#
}

# define the local directory
LOCALDIR=${PWD}
# define directories which numbers in their names.
DIRS=$( find . -mindepth 1 -maxdepth 1 -type d | grep [0-9] | sort )

for dir in $DIRS ; do
	dir=${dir#./}
	cd $dir || exit 1
	case "$1" in
		"submit" | "s" )
			JOBNAME=$( grep "set jobname" *.csh | cut -d " " -f 4 )
			JOBNUMBER=$( ~/scripts/runboss *.csh | cut -d "." -f "1" )
			echo running $dir
			echo "${JOBNAME}     ${JOBNUMBER}" >> ${LOCALDIR}/jobs.txt
			touch job_${JOBNUMBER}
			;;
		"clean" | "c" )
			rm -r job* *.gz log *.csh.* images &> /dev/null
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
			echo "Proper arguments are clean, edit, or submit."
			exit 1
			;;	
	esac

	cd ..
done

exit 0
