#!/bin/bash

LOCALDIR=${PWD}
TEMPLATEDIR=${LOCALDIR}/template_dir
SOLVENT_LIST="CH3CN-394 CCL4-396 CHCL3-396 MECL2-394"

for SOLVENT_NUM in ${SOLVENT_LIST} ; do
	SOLVENT=$( echo $SOLVENT_NUM | cut -d "-" -f "1" )
	NUM=$( echo $SOLVENT_NUM | cut -d "-" -f "2" )
	mkdir -p ${SOLVENT}/2D || exit 1
       	cd ${SOLVENT}/2D || exit 2
	cp -r ${TEMPLATEDIR} .
	sed -i "9s/SOLVENT/${SOLVENT}/" ./template_dir/template.csh
	sed -i "3s/XXXX/${SOLVENT}/" ./template_dir/pmfpar 
	sed -i "19s/YYY/${NUM}/" ./template_dir/pmfpar
	
	cp ${LOCALDIR}/deprot.sh .
	./deprot.sh s > SUBMITTED

	cd ${LOCALDIR}
done

echo Yo dog.

exit 0
