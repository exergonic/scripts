#!/bin/bash

qstat -u aubbwc | grep " Q " > kill.que.txt

JOBS2KILL=$(qstat -u aubbwc | grep " Q " | cut -d. -f1)

for JOB in $JOBS2KILL ; do
	qdel $JOB && echo $JOB killed.
done

echo script $0 done.

exit 0


