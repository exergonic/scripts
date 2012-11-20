#!/bin/bash

# script to find all log files and run the
# chkgausslogs.sh script on them.  places
# results of chkgauss logs in results.txt file.
# i'm so damn lazy.

for LOG in $( find . -name "*log" ) ; do
	~/scripts/gaussian/chkgausslogs.sh $LOG >> results.txt
	echo "" >> results.txt
done

printf "\n%s\n" "Sha-banga-bang!"

exit 0
