#!/bin/bash

## ABOUT  ####################################################################
#
# Script to automate the submission of 'engine' jobs. 
# As of now, 
#   1. the atom types are checked such that those in the input file match those
#      specified at the command line.
#   2. input files are checked to make sure they exist
#   3. directories are made for backups, modouts, and moderrs.
#   4. the output file is renamed according to the input file, with a _out
#      appended before the '.pcm' suffix. 
#
# NOTE: 1. gnu sed is used for the -i 'in place' flag. POSIX purists can cry 
#          all they wish.
#       2. different atom types for different inputs isn't currently support.
#          add it if you like.
#
## INVOCATION:################################################################ 
#
# ./runengine.sh <atom_types> <input_files>
#
# Atom types are MM3, MMX, or MMFF.
#
### AUTHOR ###################################################################
#
# Billy Wayne McCann
# Oak Ridge National Lab
# personal email: thebillywayne@gmail.com
# work email: mccannbw@ornl.gov
#
### LICENSE  ################################################################
# 
# The ITSYOURS Licence (BSD-like)
#
## MAIN  #####################################################################

# exit upon first error
set -e 

# atom types are the first argument
model=${1}
# make them lowercase
model=$( echo ${model} | tr [:upper:] [:lower:] )

# test that atomtypes are those currently supported
if [[ "${model}" != "mmx" ]] && [[ "${model}" != "mm3" ]] && [[ "${model}" != "mmff" ]] ; then
    echo Please specify MMX, MM3, or MMFF model as the first argument.
    exit 1
fi

# shift the command line arguments so that the inputs may be assigned as $@.
# see man bash for information on $@.
shift

#remove conpcm in case user inputs *pcm as input
infiles="${@//conpcm/}"


# check that input files were given
[[ -z ${infiles} ]] && echo "No infiles" && exit

# create directories for "superfluous" files if not already present.
[[ ! -d ./backups ]] && mkdir -p backups
[[ ! -d ./modouts ]] && mkdir -p modouts
[[ ! -d ./errors ]] && mkdir -p errors

# loop over given input files
for infile in $infiles ; do

    echo "Attempting to run $infile"
    outfile=${infile%%.pcm}_out.pcm

    # test that atom types are those specified by the command line.
    # if not, tell the user. 
    # is so, edit the conpcm file to reflect the user specified atom types.
    case $model in
        "mmx")
            if [[ "$( grep ATOMTYPES ${infile} )" != "ATOMTYPES 1" ]] ; then
                echo -e "\tNot MMX atom types"
                exit 1
            else
                echo -e "\tUsing MMX atom types"
                /usr/local/bin/sed -i "s/forcefield.*/forcefield mmx/" conpcm
            fi 
            ;;
        "mm3")
            if [[ "$( grep ATOMTYPES ${infile} )" != "ATOMTYPES 3" ]] ; then
                echo -e "\tNot MM3 atom types"
                exit 1
            else
                echo -e "\tUsing MM3 atom types"
                /usr/local/bin/sed -i "s/forcefield.*/forcefield mm3/" conpcm
            fi
            ;;
        "mmff")
            if [[ "$( grep ATOMTYPES ${infile} )" != "ATOMTYPES 7" ]] ; then
                echo -e "\tNot MMFF atom types"
                exit 1
            else
                echo -e "\tUsing MMFF atom types"
                /usr/local/bin/sed -i "s/forcefield.*/forcefield mmff94/" conpcm
            fi
            ;;
    esac


    #using gsed for the -i feature. screw those posix purists.
    /usr/local/bin/sed -i "{
        s/infile.*/infile ${infile}/
        s/outfile.*/outfile ${outfile}/
        }" ./conpcm
    

    # time to calculate!
    engine

    # Organize output files
    if [[ -e "pcmod.out" ]] ; then
        mv pcmod.out ./modouts/${infile%%.pcm}.modout
    fi
    if [[ -e "pcmod.bak" ]] ; then 
        mv pcmod.bak ./backups/${infile%%.pcm}.modbak
    fi
    if [[ -e "pcmod.err" ]] ; then
        mv pcmod.err ./errors/${infile%%.pcm}.moderr
    fi

done

exit 0
