#!/bin/bash

currentdir=${PWD}
ch_parents="$( find ./equil/ -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"

for ch_parent in ${ch_parents} 
do
	ch_orig_val=${ch_parent##*ch_}
	ch_down_val=$( echo "scale=2; ${ch_orig_val} - 0.05" | bc )
	ch_up_val=$( echo "scale=2; ${ch_orig_val} + 0.05" | bc )

	nh_parents=$( find ${ch_parent} -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )

	for nh_parent in ${nh_parents} ; do
		nh_orig_val=${nh_parent##*nh_}
		nh_down_val=$( echo "scale=2; ${nh_orig_val} - 0.05" | bc )
		nh_up_val=$( echo "scale=2; ${nh_orig_val} + 0.05" | bc )

		for new_ch_dir in ${ch_down_val} ${ch_orig_val} ${ch_up_val} ; do
				mkdir ch_${new_ch_dir}
				cd ch_${new_ch_dir}
				for new_nh_dir in ${ch_down_val} ${ch_orig_val} ${ch_up_val} ; do
					mkdir nh_${new_nh_dir}
					cd nh_${new_nh_dir}
					# copy and edit file
					cd ..
				done
				cd ..
		done

	done
done

exit 0
