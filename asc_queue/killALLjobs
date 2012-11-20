#! /bin/bash

JOBS="$( qstat -u aubbwc | grep aubbwc | cut -d "." -f 1 )"


for job in ${JOBS} ; do
	qdel ${job} && echo $job deleted
done

printf "%s\n" "All your jobs are now destroyed."

exit 0
