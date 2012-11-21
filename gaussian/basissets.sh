#!/bin/bash

BASIS_SET_LIST="6-311++G(2d,p) 6-311++G(3df,3pd) cc-pvdz cc-pvtz cc-pvqz aug-cc-pvdz aug-cc-pvtz aug-cc-pvqz"

for BASIS_SET in $BASIS_SET_LIST ; do
	printf "%s\n" "$BASIS_SET"
	mkdir "$BASIS_SET" && printf "\tdir made\n"
	cp *gjf ./"$BASIS_SET" && printf "\tfiles copied\n"
	sed -i "s:_X_:$BASIS_SET:" ./"${BASIS_SET}"/*gjf && printf "\tsed worked\n\n"
done

mv "6-311++G(2d,p)" 6-311++G2dp
mv "6-311++G(3df,3pd)" 6-311++G3df3pd

exit 0
