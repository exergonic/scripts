#!/usr/bin/env bash

# this spell converts pdb files to smiles format
# for easy opening in chemdoodle
# requires openbabel

# test for open babel
if ! which obabel
then
	echo "Requires open babel"
	exit 2
fi

main()
{
	for i in *pdb
	do
		echo $i
		obabel -ipdb $i -osmi -O${i%.pdb}.smi
	done
}

main
echo "Script $0 completed"
exit 0
