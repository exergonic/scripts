#!/bin/bash

# exit on first error.
set -e

starttime=$( date +%s) 
origdir=$PWD
molecules="2thioPyridine"

#molecules="$( find . -maxdepth 1 -type d | tr -d './' )"
method_list="cpcm iefpcm smd"

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

for molecule in $molecules
do
    cd $molecule
    solvents=$( _solventlist )
    for solvent in $solvents
    do
        cd $solvent
        for method in $method_list
        do
            cd $method
            echo "$molecule/$solvent/$method"
            newdir="./G4"
            mkdir $newdir && cd $newdir

            cp ../*.gjf .

            sed -i "{
                s/^#.*/#p G4 scrf=($method,solvent=$solvent,read)/
                s/nprocshared.*/nprocshared=6/
                s/mem.*/mem=16GB/
                }" *.gjf

            dos2unix *.gjf 2&1> /dev/null

            if [ "$1" = "-s" ] 
            then
                allbrung09 lp
            fi
            cd ../.. # back in methods directory
        done

        cd .. # back in solvents directory

    done

    cd .. #back in molecules directory
done

endtime=$( date +%s )
runtime=$(( $endtime - $starttime ))
printf "%s\n\n" "Script $0 completed in $runtime seconds."

exit 0
