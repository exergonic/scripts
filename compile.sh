#!/bin/bash

src=${1}
out=${src%.*}.o
[[ -e $out ]] && builtin rm $out

fortoptions="-Wall -Wextra -Wimplicit-interface -Werror \
    -O3 -march=native -ffast-math -funroll-loops"

case ${src##*.} in
	f|f90|f03|f95|F)
		gfortran $fortoptions $src -o $out && \
            echo "compile successful: $out produced"
		;;
	c)
		gcc $src -o $out 
		;;
	*)
		echo "Don't know how to do that yet"
		exit 0
		;;
esac

read -p "Attempt to execute? (Y|N)   " response
response=$( echo $response | tr [:upper:] [:lower:] )
if [[ "$response" == "y" ]] ; then
    ./$out
fi
