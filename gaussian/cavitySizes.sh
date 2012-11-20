#!/bin/bash

# Gather cavity sizes for continuum solvation model calculations.

ORIGDIR="${PWD}"
OUTPUT="${ORIGDIR}/Heterocycle.Nucleic_soluteVolumes.txt"

#MOLECULES="$( find . -maxdepth 1 -type d | tr -d './' )"

MOLECULES="adenine 1methyladenine 3methylcytosine"


# find solvent directories 
function _solventlist
{
	find . -maxdepth 1 -type d \
	-name "water" \
	-o -name "acetonitrile" \
	-o -name "carbontetrachloride" \
	-o -name "cyclohexane" \
	-o -name "dichloromethane" \
	-o -name "toluene" \
	-o -name "chloroform" | tr -d './'
}

function _gatherdata
{

	OLCAV="$( grep -i 'Cavity volume' ./cavity_inputs/*.ol.*.${CAVITY}.gjf.log  | \
	cut -d= -f2 | cut -d' ' -f5  )"
	
	ONECAV="$( grep -i 'Cavity volume' ./cavity_inputs/*.one.*.${CAVITY}.gjf.log  | \
	cut -d= -f2 |  cut -d' ' -f5 )"

	export DIFF="$( echo "scale=3; $OLCAV - $ONECAV" | bc )"
	export PERCENTDIFF="$( echo "scale=3; (${DIFF}/$ONECAV)" | bc )"

	printf "${CAVITY}\t\t${MODEL}\t\t${MOLECULE}\t\t${solv_abbrev}\t\t${OLCAV}\t\t${ONECAV}\t\t${DIFF}\t\t${PERCENTDIFF}\n" >> $OUTPUT
}

abbrev_solvent()
{
	SOLVENT="$( echo $SOLVENT | tr [:upper:] [:lower:] )"
	case $SOLVENT in
		"acetonitrile")
			solv_abbrev="CH3CN"
			;;
		"cyclohexane")
			solv_abbrev="C6H12"
			;;
		"water")
			solv_abbrev="H2O"
			;;
		"carbontetrachloride")
			solv_abbrev="CCL4"
			;;
		"chloroform")
			solv_abbrev="CHCL3"
			;;
		"dichloromethane")
			solv_abbrev="CH2CL2"
			;;
		"toluene")
			solv_abbrev="TOL"
			;;
		*)
			echo "Unrecognized solvent case. Not abbreviating."
			solv_abbrev="${SOLVENT}"
			;;
	esac
}
printf "CAVITY\t\tMODEL\t\tMOLECULE\tSOLVENT\t\tCAVITY(ENOL)\tCAVITY(KETO)\tDIFF\t\tPERCDIFF\n" > $OUTPUT

for MOLECULE in $MOLECULES ; do
	cd $MOLECULE || exit -1
	SOLVENTS=$( _solventlist )
	for SOLVENT in $SOLVENTS; do
		cd $SOLVENT|| exit -2
		abbrev_solvent
		for MODEL in iefpcm cpcm smd ; do
			cd $MODEL || exit -3
			CAVITYLIST="bondi pauling ua0 uahf uaks uff"
			if [ "$MODEL" = "smd" ] ; then
				CAVITYLIST="smd $CAVITYLIST"
			fi

			for CAVITY in $CAVITYLIST ; do
				_gatherdata
			done
			cd ..
		done
		cd ..
	done
	cd $ORIGDIR
	printf "\n" >> $OUTPUT
done


printf "all done\n"

exit 0
