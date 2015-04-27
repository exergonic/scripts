#!/bin/bash
#
# Extracts thermodynamic values from BOSS out files.
# Goes through every *sum file with a number in its name,
# extracts the data, and places it into the the summary file.
#

# bail on any error
set -e
set -u
set -o pipefail


# summary file
txt="0.thermovalues.txt"

[[ -e "$txt" ]] && rm -v $txt

# if an f5sum file exists, move it to f05sum 
# so that it appears in the proper order in the $txt file
# NOTE: This isn't appropriate for running very small windows.
# [[ -e f5sum ]] && mv f5sum f05sum

# list of BOSS output sum files
sumfiles=$( find . -maxdepth 1 -mindepth 1 -name "*?sum" | egrep [0-9] | sort)


# function to acquire thermodynamics values from an individual out file
get_thermo_values(){
    # place entire thermodynamic output into variable
    delta_values=$( awk '/ Run      Delta G/,/Title/' $sumfile)
    # place values under 'Averages' into array
    averages=( $( echo "$delta_values"| sed -n '/Averages/{n;p;}') )
    # place values under 'Standard deviations' into array
    std_devs=( $( echo "$delta_values" | sed -n '/Standard/{n;p;}') )
    # put thermo values into arrays. BOSS out files group 
    # the first and second window values together.
    deltaG_averages=( ${averages[0]} ${averages[3]} )
    deltaG_std_devs=( ${std_devs[0]} ${std_devs[3]} )
    deltaH_averages=( ${averages[1]} ${averages[4]} )
    deltaH_std_devs=( ${std_devs[1]} ${std_devs[4]} )
    deltaS_averages=( ${averages[2]} ${averages[5]} )
    deltaS_std_devs=( ${std_devs[2]} ${std_devs[5]} )
    # because the first window is a backward window, multiply it be -1.
    deltaH_averages[0]=$( echo "scale=4; ${deltaH_averages[0]}*-1" |bc)
    deltaG_averages[0]=$( echo "scale=4; ${deltaG_averages[0]}*-1" |bc)
    deltaS_averages[0]=$( echo "scale=4; ${deltaS_averages[0]}*-1" |bc)

    # print to output file
		# 1st window
    printf "$sumfile: " >> $txt
    printf "%.3f +- %.3f\t\t" ${deltaG_averages[0]} ${deltaG_std_devs[0]} >> $txt
    printf "%.3f +- %.3f\t\t" ${deltaH_averages[0]} ${deltaH_std_devs[0]} >> $txt
    printf "%.3f +- %.3f\n" ${deltaS_averages[0]} ${deltaS_std_devs[0]} >> $txt
		# 2nd window
		printf "$sumfile: " >> $txt
    printf "%.3f +- %.3f\t\t" ${deltaG_averages[1]} ${deltaG_std_devs[1]} >> $txt
    printf "%.3f +- %.3f\t\t" ${deltaH_averages[1]} ${deltaH_std_devs[1]} >> $txt
    printf "%.3f +- %.3f\n" ${deltaS_averages[1]} ${deltaS_std_devs[1]} >> $txt

    # store array variables for later calculations
    all_deltaG_averages=( ${all_deltaG_averages[@]} ${deltaG_averages[@]} )
    all_deltaH_averages=( ${all_deltaH_averages[@]} ${deltaH_averages[@]} )
    all_deltaS_averages=( ${all_deltaS_averages[@]} ${deltaS_averages[@]} )
    all_deltaG_std_devs=( ${all_deltaG_std_devs[@]} ${deltaG_std_devs[@]} )
    all_deltaH_std_devs=( ${all_deltaH_std_devs[@]} ${deltaH_std_devs[@]} )
    all_deltaS_std_devs=( ${all_deltaS_std_devs[@]} ${deltaS_std_devs[@]} )
    

    
}

# header
printf "\t\t\tDelta G\t\t\t\t\tDelta H\t\t\t\tDelta S\n" > $txt

# loop through sumfiles and extract thermodynamic values
for sumfile in $sumfiles ; do
    echo "${sumfile#./}"
    get_thermo_values
done

# add the totals
# free energy
deltaG_sum=0
for deltaG_average in ${all_deltaG_averages[@]} ; do
    deltaG_sum=$( echo "scale=3; $deltaG_average + $deltaG_sum" |bc )
done

# enthalpy
deltaH_sum=0
for deltaH_average in ${all_deltaH_averages[@]} ; do
    deltaH_sum=$( echo "scale=3; $deltaH_average + $deltaH_sum" |bc )
done

# entropy
deltaS_sum=0
for deltaS_average in ${all_deltaS_averages[@]} ; do
    deltaS_sum=$( echo "scale=3; $deltaS_average + $deltaS_sum" |bc )
done

# find variance as square root of the sum of the squares of the sigmas
# free energy
Gsigma_squared_sum=0
for deltaG_std_dev in ${all_deltaG_std_devs[@]} ; do
    Gsigma_squared_sum=$( echo "scale=7; $Gsigma_squared_sum + ${deltaG_std_dev}^2" |bc)
done
Gsigma=$( echo "scale=3; sqrt($Gsigma_squared_sum)" | bc)

# enthalpy
Hsigma_squared_sum=0
for deltaH_std_dev in ${all_deltaH_std_devs[@]} ; do
    Hsigma_squared_sum=$( echo "scale=7; $Hsigma_squared_sum + ${deltaH_std_dev}^2" |bc)
done
Hsigma=$( echo "scale=3; sqrt($Hsigma_squared_sum)" | bc)

# entropy    
Ssigma_squared_sum=0
for deltaS_std_dev in ${all_deltaS_std_devs[@]} ; do
    Ssigma_squared_sum=$( echo "scale=7; $Ssigma_squared_sum + ${deltaS_std_dev}^2" |bc)
done
Ssigma=$( echo "scale=3; sqrt($Ssigma_squared_sum)" | bc)

# print totals and standard deviations to $txt file
echo   "=======================TOTALS==========================" >> $txt
printf "\t%.3f +- %.3f\t\t" ${deltaG_sum} ${Gsigma} >> $txt
printf "%.3f +- %.3f\t\t" ${deltaH_sum} ${Hsigma} >> $txt
printf "%.3f +- %.3f\n" ${deltaS_sum} ${Ssigma} >> $txt

exit 0
     
