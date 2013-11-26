#!/bin/bash

#kills all jobs on kamino 

for i in $( qstat billy | grep ^billy | awk -F" " '{ print $3}' ) ; do 
    q -d $i
done
