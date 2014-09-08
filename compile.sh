#!/bin/bash

src=${1}
out=${src%.*}.o

options="-Wall -Wextra -Werror -O3 -march=native -ffast-math -funroll-loops"
fortoptions="$options -Wimplicit-interface"

case ${src##*.} in
	f|f90|f03|f95|F)
		[[ -e $output ]] && builtin rm $output 
		gfortran $fortoptions $src -o $out && \
			echo "compile successful: $out produced"
		stat=$?
		;;
	c)
		gcc $options -o $out $src
		stat=$?
		;;
	*)
		echo "Don't know how to do that yet"
		exit 1
		;;
esac

if [[ $stat ]]
then
	read -p "Attempt to execute? (Y|N)   " response
	response=$( echo $response | tr [:upper:] [:lower:] )
	[[ "$response" == "y" ]] && ./$out
else
	printf "%s\n" "SumTingWong"
fi
