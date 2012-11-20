#!/bin/bash

# Set job name and current dir

user=${USER}
jobname=testjob
localdir=${PWD}
export BOSSdir=~/boss4606-RM1


# Copy BOSS files to scratch dir
mkdir -p /scratch/$user/$jobname
cd /scratch/$user/$jobname

cp $localdir/pmfzmat .
cp $localdir/pmfcmd .
cp $localdir/pmfpar .

# Customize boxes and parameters
cp $BOSSdir/BOSS-RM1 .
cp $BOSSdir/watbox .
cp $BOSSdir/org1box .
cp $BOSSdir/org2box .
cp $BOSSdir/oplsaa.par .
cp $BOSSdir/oplsaa.sb .

# Write out where job was ran
echo "**********************************************"
#echo "     job ran on host "$HOSTNAME
echo "     home directory: "$localdir
echo "**********************************************"

# Execute BOSS job
/scratch/$user/$jobname/pmfcmd  &> log 

# Compress files before copying back
rm d150in
gzip d*

# Copy output files and return to localdir dir
cp d* $localdir/.
cp log $localdir/.
cd

# Clean up scratch dir
rm -r /scratch/$user/$jobname
