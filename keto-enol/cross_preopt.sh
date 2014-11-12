#!/bin/bash

declare localdir=${PWD}

declare ch_constant_list="1.45 2.45"
declare nh_constant_list="0.95"

for nh_constant in ${nh_constant_list} ; do
	mkdir -v "nh_${nh_constant}" || exit 1
	cd "nh_${nh_constant}" || exit 2

	for ch_constant in ${ch_constant_list} ; do
		mkdir "ch_${ch_constant}" || exit 3
		cd "ch_${ch_constant}" || exit 4
		cp ${localdir}/*pdg* .
		cp ${localdir}/go_xopt.sh .
		cp ${localdir}/*.z .
		sed -i "10s/x.xx/${ch_constant}/" *.z
		sed -i "12s/y.yy/${nh_constant}/" *.z
		mv *.z nh-${nh_constant}_ch-${ch_constant}.z
		./go_xopt.sh xpdggbopt nh-${nh_constant}_ch-${ch_constant}.z

		cd ..
	done

	cd ..
done

echo "it done?"

exit 0
