#!/bin/bash

# script to check if the jobs in your jobs.txt file
# are still running.  

# usage: check.jobs.sh jobs.txt
# will output which jobs in the jobs.txt file are no
# longer on the que. this information is printed to the screen,
# but may be redirected to a file `check.jobs.sh jobs.txt > not.running.txt`.

# test to be sure there is a jobs.txt file and that it's readable.
if [ ! -e ${HOME}/jobs.txt -o ! -r ${HOME}/jobs.txt ] ; then
	echo "~/jobs.txt file not found or it is not readable."	
	echo "please check that the file exists"
	echo "and that it is readable."
	exit 1
fi

# use a temporary file in order to not query the que
# for every job.
QUEFILE="./.que.txt"
qstat -u aubbwc > $QUEFILE

# for every job in the jobs.txt file, grep the job number
# to see if its in the que file just produced above.  if so,
# print out that line as it appears in the que file. otherwise,
# tell the user that the job is not in the que any longer.
for JOB in $( cat ${HOME}/jobs.txt | cut -d. -f1 ) ; do
	grep $JOB $QUEFILE || printf "job ${JOB}: $( grep $JOB jobs.txt ) no longer in que.\n" 
done

# remove the que file.
rm $QUEFILE

# all done!
exit 0

