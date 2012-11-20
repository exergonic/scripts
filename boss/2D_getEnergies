#!/bin/bash

# gets the energies from a 2D pmf job and 
# put them into a summary file.
# -v or --verbose
# will produce a more verbose output, including
# the subdirectory names and filenames in the 
# summary file, if you invoke it with -v or --verbose.
# -s or --submit
# will resubmit jobs for which there is no log file 
# if invoked with -s or --submit.

LOCALDIR=${PWD}
SUMFILE="${LOCALDIR}/energies.txt"
DIRS="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"
OPTION="$1"

# read the options given
# if option isn't recognized, then exit with an error
if [ -n "$OPTION" ] 
then
	if [ "$OPTION" != "-s" -a  "$OPTION" != "--submit" -a "$OPTION" != "--verbose" -a "$OPTION" != "-v" ]
	then
		printf "%s\n" "I don't understand that option."
		printf "%s\n" "Options are:"
		printf "\t%s\n" "to resubmit failed jobs:"
		printf "\t%s\n" "  -s or --submit"
		printf "\t%s\n" "for verbose ouput to the summary file:"
		printf "\t%s\n" "  -v or --verbose"
		printf "\n"
		exit -1
	fi
fi

# an option to resubmit jobs.  
if [ "$OPTION" == "-s" -o "${OPTION}" == "--submit" ] ; then
	RESUBMIT="1"
fi

# if the verbose argument is given, give the summary file
# a .verbose. name.
[ "$OPTION" == "--verbose" -o "$OPTION" == "-v" ] && SUMFILE=${SUMFILE%.*}.verbose.txt

# if a summary file already exists, erase it.
if [ -e ${SUMFILE} ] ; then
	rm ${SUMFILE}
fi

# if the user gives the verbose argument,
# then don't strip out the energy only during the grep.
grep_files()
{

	if [ "$OPTION" == "--verbose" -o "$OPTION" == "-v" ] ; then
		printf "${SUBDIR}\n" >> ${SUMFILE}
		zgrep DeltaG d*sum.gz >> ${SUMFILE}
	else
		zgrep DeltaG d*sum.gz | awk -F" " '{ print $8 }' >> ${SUMFILE}
	fi
}



# create the summary file
touch ${SUMFILE}

# put the date at the top of the summary file
printf "Stardate = $( date ) \n\n" >> ${SUMFILE}

# descend into directories and grep the sum files for the energies.
for DIR in ${DIRS} ; do 
	cd $DIR
	DIR=${DIR#./}
	printf "$DIR \n" | tee -a  $SUMFILE

	SUBDIRS="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"
	for SUBDIR in ${SUBDIRS} ; do
		cd ${SUBDIR}
		SUBDIR=${SUBDIR#./}
		printf "\t ${SUBDIR}\n"

		# test if the log file is in the subdirectory.
		# if it exists, grep the files for the energies, if not, print message.
		if [ -e log ] ; then
			grep_files
		else
			printf "\t${DIR}/${SUBDIR#*/}\t log file doesn't exist \n" | tee -a ${SUMFILE}
			printf "\tThis usually means calculations aren't completed.\n" | tee -a ${SUMFILE}
			printf "\t${DIR}/${SUBDIR#*/} not done.\n" >> ${LOCALDIR}/notdone.txt
			# if the user has given the flag, resubmit files.
			if [ "${RESUBMIT}" == "1" ] ; then
				# remove previous files
				rm d*.gz log *csh.e* *csh.o* job* images &> /dev/null
				# resubmit
				JOBNAME=$( grep "set jobname" *.csh | cut -d " " -f 4 )
				JOBNUMBER=$( ~/bin/runboss *.csh | cut -d "." -f "1" )
				echo running ${DIR}/${SUBDIR}
				echo "${JOBNAME}     ${JOBNUMBER}" >> ${LOCALDIR}/jobs.txt
				touch job.${JOBNUMBER}
			fi
		fi

		cd ..
	done

	printf "\n\n" >> ${SUMFILE}
	cd ..
done


exit 0
