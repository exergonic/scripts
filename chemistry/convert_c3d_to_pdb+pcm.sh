#!/usr/bin/env bash

set -e # exit on first error
set -u # error on unset
set -x

for i in *c3d
do
	echo $i
	for j in pcm pdb
	do
		obabel -ic3d1 "$i" -o"$j" -O ${i%.*}.${j} 
	done
done

echo "done"
exit 0

