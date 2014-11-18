#!/bin/bash

# script to create composite jobs
# looks for %nprocshared=N and %mem=GB and METHOD

for GJF in *.gjf
do
	for METHOD in CBS-QB3 CBS-Q CBS-4M CBS-APNO G4
	do	

		# copy original file to specific for method
		cp $GJF ${GJF%.gjf}.${METHOD}.gjf
		
		# change nprocs and mem for each method
		case $METHOD in 
			"CBS-QB3")
			N=8
			GB=8GB
			;;
			"CBS-Q")
			N=4
			GB=32GB
			;;
			"CBS-4M")
			N=8
			GB=8GB
			;;
			"CBS-APNO")
			N=4
			GB=64GB
			;;
			"G4")
			N=8
			GB=64GB
			;;
		esac

		sed -i "s/METHOD/$METHOD/g" ${GJF%.gjf}.${METHOD}.gjf
		sed -i "1s/N/$N/" ${GJF%.gjf}.${METHOD}.gjf
		sed -i "2s/GB/$GB/" ${GJF%.gjf}.${METHOD}.gjf
	done
done
			
exit 0

