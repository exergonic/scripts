#! /bin/bash

# doit.sh
# 
# billy's shell script to do all the heavy
# lifting for him.


if [ "$#" == 0 ] ; then
	echo Needs an argument: clean, edit, submit.
	exit 0
fi

# usage: call doit.sh directly from the shell, giving
# an argument
#   	clean -- to clean the directories of junk.
#	edit  -- where sed does the magic.
#       submit -- submit to the que.



# if you don't run this script from the directory
# containing the windows, this next line won't produce
# the right value. double check to make sure it
# produces the NC bond length, e.g. 3.4, 3.45, etc.
LOCALDIR=$PWD
CONSTANT_LIST="$( seq -w 3.65 0.05 4.30 )"
WINDOW_LIST="-1.000 -0.750 -0.500 -0.250 0.000 0.250 0.500 0.750 1.000" 

for CONSTANT in ${CONSTANT_LIST} ; do
	cd ${CONSTANT} || exit 1
	for WINDOW in ${WINDOW_LIST}; do
		cd win${WINDOW} || exit 2
		case "$1" in
			submit | s)
				q -i win*.csh | tee -a ../jobs.txt
				;;
			clean | c )
				rm -r *.gz log *.csh.* images &> /dev/null
				;;
			
			edit | e )
				;;

			*)
				exit 0
				;;

		esac
		cd ..
	done
	cd ..
done


exit 0
