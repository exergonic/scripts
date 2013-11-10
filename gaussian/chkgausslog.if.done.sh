#!/bin/bash

# Check gaussian log files only for those jobs which are completed.
# The job is completed if the .o[0-9]... file is present.

# exist on first error
set -e

for logfile in *log ; do
    #check for .o[0-9]... file for corresponding log file.
    # if exists, run my chkgausslogs.sh file on the log file.
    o_file=$( find . -mindepth 1 -maxdepth 1 -name ${logfile%.gjf.log}.o[0-9]* )
    echo ${o_file}
    if [ -e "${o_file}" ] ; then
        ~/scripts/gaussian/chkgausslogs.sh $logfile
    fi #/ end of if clause
done

exit 0
