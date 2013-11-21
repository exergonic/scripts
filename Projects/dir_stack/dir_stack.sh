#!/bin/bash

# a script to test the feasability
# of enhancing the features of pushd
# and popd

dirstack=${DIR_STACK}
echo ${dirstack}

COMMAND="$1"

if [ $# == 0 ] ; then
	echo "Needs an argument"
	exit 0
fi


if [ "${COMMAND}"  == push ] ; then
	export DIR_STACK="${dirstack} ${PWD}"
	echo ${DIR_STACK}
fi

if [ "${COMMAND}" == list ] ; then
	PS3='directory? '
	select DIR in ${DIR_STACK} ; do
		cd ${DIR} 
	done
fi

exit 0
