#!/usr/bin/env bash

readonly ARGS="$@"
readonly NARGS="$#"
readonly MPLAYER="$( which mplayer )"
readonly OPTIONS="-vo fbdev2 -fs -zoom -x 1600 -y 900" 

test_args() 
{
    [[ $NARGS != 1 ]] && \
        printf '%s\n' "Only one file, please" && \
        exit 1
}

main() 
{
    "$MPLAYER" $OPTIONS "$ARGS"
}

test_args
main
