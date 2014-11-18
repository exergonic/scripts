#!/bin/bash

mv_sum2zmat()
{
    SET=$( basename `pwd` | cut -d "_" -f 2 )
    WIN_START="$( echo ${SET} | cut -d "-" -f 1 )"
    WIN_FINISH="$( echo ${SET} | cut -d "-" -f 2 )"
    MIDPOINT=$( echo "scale=2 ; ($WIN_START + $WIN_FINISH) / 2" | bc ) 

    cp sum pmfzmat

    sed -i "11s/${MIDPOINT}/${WIN_START}/" pmfzmat
    sed -i "45s/$/\n00100001  ${WIN_FINISH}/" pmfzmat 
}

read -p "What is the first character of the names of your subdirectories? " CHAR

for dir in $( find . -mindepth 1 -maxdepth 1 -type d | grep "./${CHAR}" | sort ) ; do
    cd $dir || exit 1
    mv_sum2zmat && printf "$dir sum converted to zmatrix.\n"
    cd ..
done

printf "%s\n" "All done!"

exit 0
