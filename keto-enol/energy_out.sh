#! /bin/bash


for window in -1.000 -0.750 -0.500 -0.250 0.000 0.250 0.500 0.750 1.000 ; do
	cd win${window}
	printf "%s\n" "For window $window"
	zcat d50sum.gz | grep 'DeltaG'
	cd ../
done

read -p "Want to now extract just the energies?(Y|N): " JUSTNRG
justnrg=$( echo $justnrg | tr [:upper:] [:lower:] )  # make sure response is uppercase 

if [[ "$justnrg" = "y" ]] ; then
	for window in -1.000 -0.750 -0.500 -0.250 0.000 0.250 0.500 0.750 1.000 ; do
		cd win${window}
		zcat d50sum.gz | grep 'DeltaG' | awk -F" " '{ print $7 }'
		cd ../
	done
fi

exit 0
