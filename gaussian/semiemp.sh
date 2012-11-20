#!/bin/bash

# runs semiempirical jobs in gaussian

METHODS="AM1 PDDG PM6"

for GJF in *.gjf
do
	for METHOD in $METHODS
	do
		cp $GJF ${GJF%.gjf}.${METHOD}.gjf
		sed -i "s/METHOD/${METHOD}/g" ${GJF%.gjf}.${METHOD}.gjf
	done
done

exit 0

