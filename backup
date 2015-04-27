#!/usr/bin/env bash

dirs=( /var/cache/pkgfile /etc \ 
      /home/bwayne/Pictures /home/bwayne/Downloads /home/bwayne/Documents \
      /home/bwayne/usr /home/bwayne/Videos /home/bwayne/Music )
# /var/cache/pacman )

target="/mnt/usb"

_txz() {
    tardir="$1"
    tarname="${1//\//_}"
    tardatename="$(date +%F).$tarname.tar.xz"
    tar --create    \
        --verbose   \
        --xz        \
        --file="$target/$tardatename" \
        --listed-incremental="$target/$tarname.snar" \
        $tardir
}

for dir in ${dirs[@]} ; do
    _txz $dir
done

# all them dotfiles
# tar -cJvf "${target}/$(date +%F).dotfiles.tar.xz" /home/bwayne/.??*

