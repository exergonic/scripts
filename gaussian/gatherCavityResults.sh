#!/bin/bash

# About--------------------------------------------------------------
# Script to gather the results of a set of Gaussian calculations
# which are calculating the free energies of tautomers in various solutions
# using various solvent model theories and cavity types.  
# It combines the use of several already created scripts which gather information
# on the Gaussian output files themselves ( getgaussianEs.sh ) and another which
# summaries the free energies for each cavity type within solvent and solvent model 
# combination.
# 
# USAGE------------------------------------------------------------
# Should be executed in the directory which holds the cavity types.
# TODO Make it so that it can be ran in the directory which holds the
# solvents.
# To invoke: ./gatherCavityResults.sh
# no arguments required.
#--------------------------------------------------------------------

DIRS="$( find . -mindepth 1 -maxdepth 1 -type d )"

for DIR in $DIRS
do
	cd $DIR || exit 1
	~/scripts/gaussian/getgaussianEs.sh || exit 2
	~/scripts/gaussian/cavityGsummary.sh || exit 3
	cat enol.G.txt keto.G.txt cavityGsummary.txt > ../summary.${DIR/.\//}.txt
	printf "$DIR done.\n\n"
	cd ..
done

printf "Script complete.\n\n"

exit 0
