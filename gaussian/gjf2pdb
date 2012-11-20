#!/bin/bash

# convert gaussian output files to pdbs
# requires arguments.

if [ $# -eq 0 ] ; then
    echo "requires arguments"
    exit 1
fi

for i in $@ ; do
    babel -i g03 $i -o pdb ${i/gjf.log/pdb} 
    echo "$i done"
done

