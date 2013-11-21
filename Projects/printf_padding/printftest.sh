#!/bin/bash

VALUE="10.01"
PATTERN="$( printf "%-8s" Y.YY )"
REPLACE="$( printf "%8f" ${VALUE} )"
YLINE="$( grep -n Y.YY *.z | cut -d ":" -f 1 )"

sed "${YLINE}s/${PATTERN}/${REPLACE}/" *.z

#CHARS="$( echo 10.01 | wc -m )"
#ACTUAL_CHARS="$( echo "${CHARS} - 1" | bc )"
#PADDING="$( echo "8 - ${ACTUAL_CHARS}" | bc )"

#echo $CHARS
#echo $ACTUAL_CHARS
#echo ${PADDING}


#NUMBER=2

#printf "%-${PADDING}s" "Y.YY"
#printf "%s\n" H

exit 0
