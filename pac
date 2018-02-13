#!/usr/bin/env bash

set -e
set -o

option="$1"

_sp() {
	sudo pacman "$@"
}

sync() {
	_sp --sync --refresh
	_sp --query --upgrades
}

update() {
	_sp --sysupgrades 
}

install() {
	_sp --sync --needed $@
}

case $option in 
	"sync" 		) sync ;;
	"update" 	) update ;;
	"install" ) install ;;
	*) 				echo "wtf bro" ;;
esac
		





