#!/bin/bash

COUNTER=1

while [ ${COUNTER} -lt 10 ] ; do
	echo ${COUNTER}
	let COUNTER++
	[ ${COUNTER} == 4 ] && break
done

exit 0
