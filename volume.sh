#!/usr/bin/env bash

if [[ -z "$1" ]] ; then
	printf "Script requires an argument, up/+ or down/-.\n"
	exit 0
fi

option="$1"

[[ "$option" == "up" ]] && option="+"
[[ "$option" == "down" ]] && option="-"

amixer -c 1 set Master 2db${option}
