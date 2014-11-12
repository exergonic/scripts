#!/bin/bash

localdir=$PWD
template_dir=${localdir}/template_dir
zmat_dir=~/research/keto-enol/pyridine/preopt_zmats


if [ "$1" = "submit" -o "$1" = "s" ] ; then
	submit="q -i *.csh"
else
	submit="echo not submitting."
fi

make_ch-constant_dirs()
{
	ch_constant_list="$( seq -w 1.00 0.05 2.30 )"
	nh_window_list="0.95-1.95 1.95-2.95"

	for ch_constant in $ch_constant_list ; do
		mkdir ch_${ch_constant} || exit 1
		cd ch_${ch_constant} || exit 2
		echo ${ch_constant}

		for nh_window in ${nh_window_list} ; do
			mkdir "nh_${nh_window}" || exit 3
			cd "nh_${nh_window}" || exit 4
			cp ${template_dir}/* . 
			mv template.csh win${nh_window}.csh

			# a case switch to determine from which directory
			# to get the 'sum' file. for use when using pre-
			# optimized zmatrices.
			case "${nh_window}" in
				"0.95-1.95")
					cp ${zmat_dir}/ch_${ch_constant}/nh_1.45/sum pmfzmat
					sed -i "12s/1.45/0.95/" pmfzmat
					sed -i "35s/$/\n00110001  1.95/" pmfzmat
					;;
				"1.95-2.95")
					cp ${zmat_dir}/ch_${ch_constant}/nh_2.45/sum pmfzmat
					sed -i "12s/2.45/1.95/" pmfzmat
					sed -i "35s/$/\n00110001  2.95/" pmfzmat
					;;
				*)
					echo "messed up case" && exit 5
					;;
			esac


			## edit the csh file
			sed -i "s/constant/ch_${ch_constant}/g" *.csh
			sed -i "s/window/nh_${nh_window}/g" *.csh
			sed -i "s:localdir:${pwd}:g" *.csh

			## edit the zmat file 
			# used when not using pre-optmizied zmatrices.

			#begin_hn=$( echo ${nh_window} | cut -d "-" -f 1 )
			#end_hn=$( echo ${nh_window} | cut -d "-" -f 2 )
			#sed -i "s/x.xx/${ch_constant}/g" pmfzmat
			#sed -i "s/y.yy/${begin_hn}/g" pmfzmat
			#sed -i "s/z.zz/${end_hn}/g" pmfzmat

			${submit}

			cd ..

		done

		cd ..
	done
}

make_cross_dir()
{
	nh_constant_list="0.95"
	ch_window_list="0.95-1.95 1.95-2.95"

	mkdir cross || exit 4
	cd cross || exit 5
	echo cross

	for nh_constant in $nh_constant_list ; do
		mkdir nh_${nh_constant} || exit 1
		cd nh_${nh_constant} || exit 2
		for ch_window in ${ch_window_list} ; do
			mkdir "ch_${ch_window}" || exit 3
			cd "ch_${ch_window}" || exit 4
			cp ${template_dir}/* . 
			mv template.csh cross_win${ch_window}.csh
			## edit the csh file
			sed -i "s/constant/nh_${nh_constant}/g" *.csh
			sed -i "s/window/ch_${ch_window}/g" *.csh
			sed -i "s:localdir:${pwd}:g" *.csh
			## edit the zmat file
			case "${ch_window}" in
				"0.95-1.95")
					cp ${zmat_dir}/nh_${nh_constant}/ch_1.45/sum pmfzmat
					sed -i "10s/1.45/0.95/" pmfzmat
					sed -i "35s/$/\n00090001  1.95/" pmfzmat
					;;
				"1.95-2.95")
					cp ${zmat_dir}/nh_${nh_constant}/ch_2.45/sum pmfzmat
					sed -i "10s/2.45/1.95/" pmfzmat
					sed -i "35s/$/\n00090001  2.95/" pmfzmat
					;;
				*)
					echo "messed up case" && exit 5
					;;
			esac


#			begin_ch=$( echo ${ch_window} | cut -d "-" -f 1 )
#			end_ch=$( echo ${ch_window} | cut -d "-" -f 2 )
#			sed -i "10s/x.xx/${begin_ch}/" pmfzmat
#			sed -i "12s/y.yy/${nh_constant}/" pmfzmat
#			sed -i "36s/0011/0009/" pmfzmat
#			sed -i "36s/z.zz/${end_ch}/" pmfzmat

			${submit}

			cd ..
		done
		cd ..
	done
}



make_ch-constant_dirs 
make_cross_dir 


exit 0
