#!/bin/bash

# sets up and runs semiempirical jobs in gaussian
# billy wayne mccann
# bsd 2-clause license

# sane bash behavior
set -e
set -u
set -o pipefile

methods="am1 pddg pm6"

for gjf in *.gjf
do
	for method in $methods
	do
		cp $gjf ${gjf%.gjf}.${method}.gjf
		sed -i "s/METHOD/${method}/g" ${gjf%.gjf}.${method}.gjf
	done
done

exit 0

