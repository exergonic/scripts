#!/bin/bash

src=${1}
out=${src%.*}.o
[[ -e $out ]] && rm $out

options="-Wall -Wextra -Werror -O3 -march=native -ffast-math -funroll-loops"
fortoptions="$options -Wimplicit-interface"

coptions="-std=c99 -Wall -Wextra -O3 -march=native \
		-ffast-math -funroll-loops"

case ${src##*.} in
	f|f90|f03|f95|F)
		gfortran $fortoptions $src -o $out && \
			echo "compile successful: $out produced"
		stat=$?
		;;
	c)
		gcc $options -o $out $src
		stat=$?
		;;
	c)
		gcc $coptions $src -o $out 
		;;
	*)
		echo "Don't know how to do that yet"
		exit 1
		;;
esac

<<<<<<< HEAD
if [[ $stat ]]
then
	read -p "Attempt to execute? (Y|N)   " response
	response=$( echo $response | tr [:upper:] [:lower:] )
	[[ "$response" == "y" ]] && ./$out
else
	printf "%s\n" "SumTingWong"
fi
=======
read -p "Attempt to execute? (Y|N)   " response
response=$( echo $response | tr [:upper:] [:lower:] )
[[ "$response" == "y" ]] && ./$out

exit 0
>>>>>>> e9b121fcd7e32811eb9bc34275f4f03f237681d4
