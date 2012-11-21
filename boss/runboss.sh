#!/bin/csh -f
#=======================================================================
#=====                                                             =====
#=====   runboss - Runs a BOSS job in the current directory  =====
#=====                                                             =====
#=======================================================================
#
# This shell script is used to submit a BOSS job to the
# batch facility.  Usage of runboss is as follows:
#
# runboss input_file
# 
# Send any problems with or suggestions about runmcpro to:
#***************************************************************************
# Orlando Acevedo
# Assistant Professor
# Department of Chemistry and Biochemistry 
# Auburn University
# Auburn, AL 36849-5312
# phone: (334) 844-6549
# email: orlando.acevedo@auburn.edu
#***************************************************************************
#
# configure script
set PBS_BIN = /usr/pbs/bin

# Read user input file and verify
set infile = $argv[1]
if (! -f $infile) then
    echo "Input file [$infile] not found - Aborting"
    exit
endif
#
# set number of cpus, and memory
set memory = 500MB
set num_cpus = 1
#
# set which queue to use: medium-serial, large-parallel (default), small-parallel,
# express.
set queue = medium-serial
#
# run job
qsub -q $queue -l mem=$memory,ncpus=$num_cpus,partition=dmc $infile
#$PBS_BIN/qsub -q $queue -l mem=$memory,nodes=$num_cpus,ncpus=$num_cpus,partition=dmc $infile
#
exit
