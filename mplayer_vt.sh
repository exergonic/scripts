#!/usr/bin/env bash

readonly ARGS="$@"
readonly MPLAYER="$( which mplayer )"
readonly OPTIONS="-vo fbdev2 -fs -zoom -x 1600 -y 900 -quiet" 

main() 
{
    "$MPLAYER" $OPTIONS "$ARGS"
}

main
