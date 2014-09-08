#!/bin/bash

# creates an images/ directory
# copies plt files into the images directory
# then unzips all the images, and renames them
# a .pdb file.

set -e
unset file

[[ ! -d images ]] && mkdir -v images

cp *plt* images/
	
for file in images/* ; do
	mv -v $file ${file//plt/}.pdb
done

exit 0
