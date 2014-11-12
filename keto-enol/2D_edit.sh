!/bin/bash

localdir=${PWD}
dirs="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"

edit()
{
	sed -i "1s:^.*:#!/bin/csh -f:" *.csh
	sed -i "8s/billy/aubbwc/" *.csh
	sed -i "10s:/.*:${pwd}:" *.csh
	sed -i "43s/0008/0009/" pmfzmat # angle
	sed -i "44s/0013/0011/" pmfzmat # angle
	sed -i "47s/0008/0009/" pmfzmat # dihedral
	sed -i "48s/0014/0011/" pmfzmat # dihedral
}

run()
{
	~/bin/runboss *.csh 
}

for dir in ${dirs} ; do 
	cd $dir

	subdirs="$( find . -mindepth 1 -maxdepth 1 -type d | sort | grep [0-9] )"
	for subdir in ${subdirs} ; do
		cd ${subdir}
		#echo editing && edit
		echo running ${dir}/${subdir} && run >> ${localdir}/jobs.txt
		cd ..

	done

	cd ..
done

exit 0
