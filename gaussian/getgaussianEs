#!/bin/bash

# script to find all log files and summarize them.
# places results in results.txt file.
# i'm so damn lazy.

BASEDIR="$PWD"
KETO_LOGFILES="$( find . -name "*one*.log" )"
ENOL_LOGFILES="$( find . -name "*ol*.log" )"
KETO_G_FILE="${BASEDIR}/keto.G.txt"
KETO_H_FILE="${BASEDIR}/keto.H.txt"
ENOL_G_FILE="${BASEDIR}/enol.G.txt"
ENOL_H_FILE="${BASEDIR}/enol.H.txt"


# abbreviate summary file variable names
KGF="$KETO_G_FILE"
KHF="$KETO_H_FILE"
EGF="$ENOL_G_FILE"
EHF="$ENOL_H_FILE"

# remove previous summary files
for FILE in $KGF $KHF $EGF $EHF
do
	if [ -e $FILE ]
	then
		rm $FILE
	fi
done

# LOOP FOR KETO
for LOGFILE in $KETO_LOGFILES ; do
	printf "%s\n" ${LOGFILE#./} | awk -F"/" '{ print $1 "     " $2 }' | tee -a $KGF $KHF &> /dev/null
	( grep "Normal termination" $LOGFILE || printf "\t%s\n" "Did not terminate normally." )  | tee -a $KGF $KHF &> /dev/null
	grep "Stationary point found" $LOGFILE | tee -a $KGF $KHF &> /dev/null
	( grep "imaginary frequencies" $LOGFILE || printf "%s\n" "    No imaginary modes." )  | tee -a  $KGF $KHF &> /dev/null
	grep "Sum of electronic and thermal Enthalpies" $LOGFILE >> $KHF 
	grep "Sum of electronic and thermal Free Energies" $LOGFILE >> $KGF
	printf "\n\n" | tee -a $KGF $KHF &> /dev/null
done

# SUMMARY FOR KETO FILE FOR EASY COPY/PASTE
printf "%s\n" "Summary" | tee -a $KGF $KHF &> /dev/null
cat $KGF | grep Sum | awk -F"=" '{ print $2 }' >> $KGF
cat $KHF | grep Sum | awk -F"=" '{ print $2 }' >> $KHF

# LOOP FOR ENOL 
for LOGFILE in $ENOL_LOGFILES ; do
	printf "%s\n" ${LOGFILE#./} | awk -F"/" '{ print $1 "     " $2 }' | tee -a $EGF $EHF &> /dev/null
	( grep "Normal termination" $LOGFILE || printf "\t%s\n" "Did not terminate normally." )  | tee -a $EGF $EHF &> /dev/null
	grep "Stationary point found" $LOGFILE | tee -a $EGF $EHF &> /dev/null
	( grep "imaginary frequencies" $LOGFILE || printf "%s\n" "    No imaginary modes." )  | tee -a  $EGF $EHF &> /dev/null
	grep "Sum of electronic and thermal Enthalpies" $LOGFILE >> $EHF 
	grep "Sum of electronic and thermal Free Energies" $LOGFILE >> $EGF
	printf "\n\n" | tee -a $EGF $EHF &> /dev/null
done

# SUMMARY FOR ENOL FILE FOR EASY COPY/PASTE
printf "%s\n" "Summary" | tee -a $EGF $EHF &> /dev/null
cat $EGF | grep Sum | awk -F"=" '{ print $2 }' >> $EGF
cat $EHF | grep Sum | awk -F"=" '{ print $2 }' >> $EHF



printf "\n%s\n" "Sha-banga-bang!"

exit 0
