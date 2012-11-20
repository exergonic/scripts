
LOGFILES="$( find . -name "*.log" )"

# make new directory into which to put new Gaussian inputs
NEWDIR="./cavity_inputs"

mkdir $NEWDIR 

# sculpt a new gaussian input from the old log file
# and old input file.
for LOGFILE in $LOGFILES
do
	#rename the files
	#the old input file is the log file minus the .log suffix
	OLD_INPUT=${LOGFILE/.log/}
	#the new input file is the old input file placed into the
	#new directory and subsequently edited.
	NEW_INPUT=${NEWDIR}/${OLD_INPUT#./}

	# the first 8 lines from the original gjf file (not the .log file!)
	# which includes the multiplicity and charge line.  then begins the 
	# zmatrix.
	head -8 $OLD_INPUT >> $NEW_INPUT

	# wtf awk?
	#awk "NR==0, NR==8" ${OLD_INPUT}  >> $NEW_INPUT

	# get final z-matrix from output log file
	awk "/initial\ Z-matrix/, /AUBBWC/" $LOGFILE | grep -v -e "Final" -e "AUBBWC" >> $NEW_INPUT

	# last 3 lines of original: two blank lines and the radii= directive.
	tail -3 $OLD_INPUT >> $NEW_INPUT


	sed -i "{
		s/opt.*\ //
		s/freq.*\ //
		s/^#/#p/
		4s/$/\ Volume/
		}" $NEW_INPUT 

	printf "%s\n" "$LOGFILE used to created $NEW_INPUT."
done

dos2unix $NEWDIR/*
