#! /bin/bash

if [ -n "$1" -a -n "$2" ] ; then                                                                                                                                                                             
	read -p "Are you sure? Enter to continue, Control+c to Cancel." SURE
        JOBRANGE=`seq "$1" "$2"`
        for JOB in $JOBRANGE ; do
                q -d $JOB
        done
	printf "%s\n" "bash ate jobs $1 through $2 and really liked it ..."
	exit 0
else 
        printf "%s\n" "C'mon now $USER, you have to specify a jobrange"
        printf "%s\n" "Example:  $ killjobs 185699 185801"
	exit 0
fi
