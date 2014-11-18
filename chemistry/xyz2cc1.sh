#!/usr/bin/env bash

# test for openbabel
has_babel="$( which babel &> /dev/null )"
if [[ $? -eq 1 ]] 
then
    printf "%s\n" "Cannot find 'babel' in path"
		exit 1
fi

in=${1:?"Please input xyz file"}

babel -ixyz $in -oc3d1 hosta
# add entry for number of guests. just make it one
sed -i "1s/$/   1/" hosta 

exit 0

