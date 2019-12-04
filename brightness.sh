#!/usr/bin/env bash

readonly arg="$1"

if [[ "$arg" == "up" ]]
then
	/usr/bin/xbacklight +2
elif [[ "$arg" == "down" ]]
then
	/usr/bin/xbacklight -2
fi
