#! /bin/bash

# doit.sh
# 
# billy's shell script to do all the heavy
# lifting for him.
# 

# usage: call doit.sh directly from the shell, giving
# an argument
#   	clean -- to clean the directories of junk.
#	edit  -- where sed does the magic.
#       submit -- submit to the que.



# if you don't run this script from the directory
# containing the windows, this next line won't produce
# the right value. double check to make sure it
# produces the NC bond length, e.g. 3.4, 3.45, etc.
NC_LENGTH=`pwd | awk -F"/" '{ print $9 }'`

if [ "$#" == 0 ] ; then
	echo Needs an argument: clean, edit, submit.
	exit 0
fi

for window in -1.000 -0.750 -0.500 -0.250 0.000 0.250 0.500 0.750 1.000 ; do
	case "$1" in
		submit)
			cd win${window} || exit 1
			q -i win*.csh >> ../jobs.txt
			cd ..
			;;
		clean)
			cd win${window} || exit 1
			rm -r *.gz log *.csh.* images &> /dev/null
			cd ..
			;;
			
		edit)
			cd win${window} || exit 1
			sed -i "11s/3.00/$NC_LENGTH/" 		pmfzmat
			sed -i "9s/3.0/$NC_LENGTH/" 		win*.csh
			sed -i "10s/3.0/TIP4P\/$NC_LENGTH/" 	win*.csh
			sed -i "10s/~/\/home\/billy/" 		win*.csh
			cd ..
			;;

		*)
			echo "Oh no! I can't do that! :-0"
			echo "Proper arguments are clean, edit, or submit."
			exit 0
		;;	
	esac
done

exit 0
