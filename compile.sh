#!/bin/bash

src=${1}
out=${src%.*}.o
[[ -e $out ]] && rm $out

fortoptions="-Wall -Wextra -Wimplicit-interface -Werror \
    -O3 -march=native -ffast-math -funroll-loops"

coptions="-std=c99 -Wall -Wextra -O3 -march=native \
		-ffast-math -funroll-loops"

case ${src##*.} in
	f|f90|f03|f95|F)
		gfortran $fortoptions $src -o $out && \
            echo "compile successful: $out produced"
		;;
	c)
		gcc $coptions $src -o $out 
		;;
	*)
		echo "Don't know how to do that yet"
		exit 1
		;;
esac

read -p "Attempt to execute? (Y|N)   " response
response=$( echo $response | tr [:upper:] [:lower:] )
[[ "$response" == "y" ]] && ./$out

exit 0
