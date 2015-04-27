#!/usr/bin/env bash

set -e

for png in *png ; do
    convert ${png} ${png%.png}.gif
    printf "%s\n" "$png converted to ${png%.png}.gif"
done
