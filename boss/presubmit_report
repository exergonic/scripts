#! /bin/bash

# designed to craft a REPORT to test the SUBMITABILITY
# of the csh command file. 
#
# this script descends into each directory for a molecule 
# and reports certain critera, such as if the set local
# dir is set to the actual local dir and if there are already
# summary files in the set local dir.  
#
# a report file, named PRESUBMIT_REPORT.txt is generated in 
# the directory from which the script is ran.  
# 
# Billy Wayne McCann
# 05/19/2009

read -p "What is the first character of your directory names?" CHAR

declare WORKDIR=`pwd`
declare REPORTFILE=$WORKDIR/PRESUBMIT_REPORT.txt
declare DIRS=$( find . -mindepth 1 -maxdepth 1 -type d | grep "./${CHAR}" | sort )

if [ -e $REPORTFILE ] ; then
	rm $REPORTFILE
fi

for dir in $DIRS ; do

	cd $dir
	printf "%s\n" "For directory $dir." >> $REPORTFILE
	grep "set jobname" *.csh >> $REPORTFILE
	grep "set local" *.csh >> $REPORTFILE

	CURRENTDIR=$PWD
	echo "actual local is $CURRENTDIR" >> $REPORTFILE
	SETDIR=$( grep "set local" *.csh | awk -F" " '{ print $4 }' )
	if [ $CURRENTDIR != $SETDIR ] ; then
		#echo "The current working dir is $CURRENTDIR." >> $REPORTFILE
		#echo "But the set localdir is $SETDIR.">> $REPORTFILE
		echo "Perhaps these DON'T MATCH. Look carefully!" >> $REPORTFILE
		echo "CHECK your set local value in $dir!" >> $REPORTFILE
	else
		echo "The set local directory seems to match actual working directory." >> $REPORTFILE
		echo "the csh file LOOKS GOOD for submission." >> $REPORTFILE
		#echo "GO!!" >> $REPORTFILE
	fi

	declare -i ALREADY=`eval ls $SETDIR | grep sum.gz | wc -l`
	if [ $ALREADY -ne 0 ] ; then
		echo "There are already sum.gz files ($ALREADY) in the set local for $dir!" >> $REPORTFILE
		echo "set local in the csh file is set to $SETDIR" >> $REPORTFILE
	else
		echo "There are no previous sum files in this directory." >> $REPORTFILE
	fi

		
	
	echo "" >> $REPORTFILE
	cd ..
done

read -p "Press Enter to view the PRESUMMARY_REPORT or Control^c not to." PRESNTR

less $REPORTFILE

exit 0
