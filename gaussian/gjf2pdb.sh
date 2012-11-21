#!/bin/bash

#  ABOUT   ####################################################################
# convert gaussian output files to pdbs
# Requires the gaussian output files to be given as argument to the script.
#
# AUTHOR   ####################################################################
#
# Billy Wayne McCann
# thebillywayne@gmail.com
#
###############################################################################

if [ $# -eq 0 ] ; then
    echo "Please provide file names as arguments to this script."
    echo "Wildcards are handled appropriately"
    exit 1
fi

# check to see if open babel 2.3 or above is installed
if [[ "$( babel -V | cut -d' ' -f3)" =~ 2.3.? ]] ; then
    echo "Version of Open Babel is OK"
else
    "Version of Open Babel is not OK."
    "You need version 2.3.1 or above."
    exit 1
fi

# if something goes wrong, then die
die()
{
    echo "Something went wrong."
    echo "Aborting."
    exit 1
}
    
# main
for i in "$@" ; do
    babel -i g03 $i -o pdb ${i/gjf.log/pdb} || die
    echo "$i done"
done

exit 0
