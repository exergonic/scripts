#!/bin/bash

src=${1}
out=${src%.*}.exe

case ${src##*.} in
	f|f90|f03|F)
		[[ -e $output ]] && builtin rm $output 
		gfortran $src -o $out && \
            echo "compile successful: $out produced"
		;;
	*)
		echo "Don't know how to do that yet"
		exit 0
		;;
esac
