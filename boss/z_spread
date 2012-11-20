#!/bin/bash

# this script will spread a single zmatrix  to subdirectories.
# once copied, sed substitutes variables derived from the 
# name of the parent "window" directory. from a directory named
# for its geometric window, say C9-1.8-2.0, this script will
# extract the 1.8 as START, 2.0 as END, and will calculate the
# midpoint, in this example 1.9, as the bond length BND_LNGTH 
# which is substituted into the appropriate bond length in the
# zmatrix.  

# this script is to be ran in the directories which contain
# all of the windows for a particular mutation.  

# this script currently supports 1D mutations only and accepts
# no command line arguments. various portions of the code will
# have to be tailored to the specific needs of the molecule 
# that you are mutating, eg which column awk returns in the 
# WINDOW variable may change for you.   




# test if the script was told which zmatrix to spread

if [ $# != 1 ] ; then
	echo "Usage: ./z_spread.sh nameOfZmat.z"
	echo "You have to give the name of the zmatrix"
	echo "as the first argument."
fi


# now for the heavy lifting. for every directory, do ..

SUBDIRS=$( find . -mindepth 1 -maxdepth 1 -type d | sort )

for dir in $SUBDIRS ; do
	# place ourselves in  the current window. 
	cd $dir && echo "entering $dir"

	# find values concerning this window
	# all these values depend of the first variable, WINDOW.	
	WINDOW=$(basename `pwd`)
	START=$(echo ${WINDOW} | cut -d "-" -f 2)
	END=$(echo ${WINDOW} | cut -d "-" -f 3)
	#AVG_BND_LNGTH=$(echo "scale=1 ; ("$START" + "$END")/2" | bc)
	
	# a few echoes to view the above variables.
	#echo window is $WINDOW 
	#echo start is $START 
	#echo end is $END 
	#echo average bond length is $AVG_BND_LNGTH
	#read -p "Press Enter if OK, otherwise Control-c." enter
	
	# now, copy the template zmatrix to the current 
	# directory.
	cp ../$1 . && echo "$1 copied to $dir"

	# within the CAIR.temp.z file replace the appropriate value 
	# with the calculated midpoint bond length, the variable $BND_LNGTH.
	sed -i "s/XXX/$START/" ./$1
	sed -i "s/YY/$END/" ./$1
	echo "$1 has been modified by sed"

	# now, rename the file to pmfzmat and copy the other necessary files here.
	mv ./$1 ./pmfzmat && echo "$1 moved to $dir/pmfzmat"

	# the zmatrix has been copies and modified. time for the next directory.
	cd ../ && echo -e "done and exiting ${dir} \n"
	#read -p "press enter" press
	
done

echo -e "\n\n"
echo "All done!"
echo "Your zmatrices files are now all spread out!"

exit 0
