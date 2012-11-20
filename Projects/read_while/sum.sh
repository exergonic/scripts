#!/bin/bash

FILE="$1"
SUM=0

while read NUMBER ; do
	SUM="$( echo "scale=5; ( ${SUM} + ${NUMBER} )" | bc )"
	echo "${NUMBER}    ${SUM}"
done < ${FILE}

exit 0
