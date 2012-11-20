#!/bin/bash

# for every job in the jobs.txt file ( the job number is the second column)
# delete the job from the que.
for JOB in $( cat jobs.txt | awk -F" " '{ print $2 }' ) ; do
	qdel $JOB && echo $JOB killed
done

exit 0
