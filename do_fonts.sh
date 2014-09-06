#!/usr/bin/env bash

set -e

readonly progname=$(basename $0)
readonly progdir=$(readlink -m $(dirname $0))
readonly args="$@"
readonly workingd="$PWD"


main ()
{
	set -x
	fc-cache -v &&  mkfontscale &&  mkfontdir
	set +x
	
	return
}

main

exit $?
