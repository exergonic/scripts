#!/usr/bin/env bash

# sane bash behavior
set -e
set -u

output_dir="complexes"
[[ -e "${output_dir}" ]] && rm -rf "${output_dir}"
mkdir -v "${output_dir}"


file="$1"
#lines which separates two linkers
seplines=($(grep -n -e '^[[:space:][:space:][:digit:][:digit:]]' "$file" | cut -d: -f1))
# number of separating lines
nseplines=${#seplines[@]}


_separate() {
	j=0
	for ((i=0 ; i<$(( $nseplines - 1 )) ; i++))
	do
		j=$((${i}+1))
		sed -n "${seplines[$i]},$(( ${seplines[$j]}-1))p" "${file}" > "${output_dir}/complex_${i}.cc1"
		hitline="$(grep "Hit" "${output_dir}/complex_${i}.cc1" )"
		complex_number="$( echo $hitline | cut -d"(" -f2 | cut -d")" -f1 )"
		complex_name="$( echo ${hitline:36:50} | cut -d"_" -f1 )"
		complex="${complex_name}_${complex_number}"
		echo ${complex}
		mv "${output_dir}/complex_${i}.cc1" "${output_dir}/${complex}.cc1"
done
}


#TODO: debug
# not finding ${seplines[$i]}
_final_complex() {
	# required for the final complex since it's not finished by $hitline string,
	# but goes to EOF
	i=$1
	sed -n "${seplines[$i]},$(wc -l < complex.hdo)p" "${file}" > "${output_dir}/${complex_name}.cc1"
	hitline="$(grep "Hit" "${output_dir}/complex_${i}.cc1" )"
	complex_number="$( echo $hitline | cut -d"(" -f2 | cut -d")" -f1 )"
	complex_name="$( echo ${hitline:36:50} | cut -d"_" -f1 )"
	complex="${complex_name}_${complex_number}"
	echo ${complex}
	mv "${output_dir}/${complex.cc1}" "${output_dir}/${complex}.cc1"
}

_convert() {
	for cc1 in ${output_dir}/*cc1
	do
		obabel -ixyz "${cc1}" -opcm -O "${cc1%.*}.pcm"
	done
}

main() {
	_separate
	_convert
}

main

echo Script ${0} done.
