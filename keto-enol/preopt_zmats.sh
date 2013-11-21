#!/bin/bash

declare LOCALDIR=${PWD}

declare CH_CONSTANT_LIST="$( seq -w 1.00 0.05 2.30 )"
declare NH_CONSTANT_LIST="1.45 2.45"

for CH_CONSTANT in ${CH_CONSTANT_LIST} ; do
	mkdir -v "CH_${CH_CONSTANT}" || exit 1
	cd "CH_${CH_CONSTANT}" || exit 2

	for NH_CONSTANT in ${NH_CONSTANT_LIST} ; do
		mkdir "NH_${NH_CONSTANT}" || exit 3
		cd "NH_${NH_CONSTANT}" || exit 4
		cp ${LOCALDIR}/*PDG* .
		cp ${LOCALDIR}/go_xopt.sh .
		cp ${LOCALDIR}/*.z .
		sed -i "10s/X.XX/${CH_CONSTANT}/" *.z
		sed -i "12s/Y.YY/${NH_CONSTANT}/" *.z
		mv *.z CH-${CH_CONSTANT}_NH-${NH_CONSTANT}.z
		./go_xopt.sh xPDGGBOPT CH-${CH_CONSTANT}_NH-${NH_CONSTANT}.z

		cd ..
	done

	cd ..
done

# now for the CROSS term window

declare CROSS_CH_CONSTANT_LIST="1.45 2.45"
declare CROSS_NH_CONSTANT_LIST="0.95"

for NH_CONSTANT in ${CROSS_NH_CONSTANT_LIST} ; do
	mkdir -v "NH_${NH_CONSTANT}" || exit 1
	cd "NH_${NH_CONSTANT}" || exit 2

	for CH_CONSTANT in ${CROSS_CH_CONSTANT_LIST} ; do
		mkdir "CH_${CH_CONSTANT}" || exit 3
		cd "CH_${CH_CONSTANT}" || exit 4
		cp ${LOCALDIR}/*PDG* .
		cp ${LOCALDIR}/go_xopt.sh .
		cp ${LOCALDIR}/*.z .
		sed -i "10s/X.XX/${CH_CONSTANT}/" *.z
		sed -i "12s/Y.YY/${NH_CONSTANT}/" *.z
		mv *.z NH-${NH_CONSTANT}_CH-${CH_CONSTANT}.z
		./go_xopt.sh xPDGGBOPT NH-${NH_CONSTANT}_CH-${CH_CONSTANT}.z

		cd ..
	done

	cd ..
done



echo "It done?"

exit 0







