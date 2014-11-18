#!/bin/bash

basis_set_list="6-311++g(2d,p) 6-311++g(3df,3pd) cc-pvdz cc-pvtz cc-pvqz aug-cc-pvdz aug-cc-pvtz aug-cc-pvqz"

for basis_set in $basis_set_list ; do
	printf "%s\n" "$basis_set"
	mkdir "$basis_set" && printf "\tdir made\n"
	cp *gjf ./"$basis_set" && printf "\tfiles copied\n"
	sed -i "s:_x_:$basis_set:" ./"${basis_set}"/*gjf && printf "\tsed worked\n\n"
done

mv "6-311++g(2d,p)" 6-311++g2dp
mv "6-311++g(3df,3pd)" 6-311++g3df3pd

exit 0
