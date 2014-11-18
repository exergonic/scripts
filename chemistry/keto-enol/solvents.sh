#!/bin/bash

localdir=${PWD}
templatedir=${localdir}/template_dir
solvent_list="CH3CN-394 CCL4-396 CHCL3-396 MECL2-394"

for solvent_num in ${solvent_list} ; do
	solvent=$( echo $solvent_num | cut -d "-" -f "1" )
	num=$( echo $solvent_num | cut -d "-" -f "2" )
	mkdir -p ${solvent}/2d || exit 1
       	cd ${solvent}/2d || exit 2
	cp -r ${templatedir} .
	sed -i "9s/solvent/${solvent}/" ./template_dir/template.csh
	sed -i "3s/xxxx/${solvent}/" ./template_dir/pmfpar 
	sed -i "19s/yyy/${num}/" ./template_dir/pmfpar
	
	cp ${localdir}/deprot.sh .
	./deprot.sh s > submitted

	cd ${localdir}
done

echo yo dog.

exit 0
