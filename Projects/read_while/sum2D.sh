#!/bin/bash

FILE="$1"
SUM=0

file_length=$( wc -l $FILE )

for ((line_number=0 ; line_number <= $file_length ;   
while read -a NUMBERS ; do
	SUM="$( echo "scale=5; ( ${SUM} + ${NUMBER} )" | bc )"
	echo "${NUMBER}    ${SUM}"
done < ${FILE}

exit 0
