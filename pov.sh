#!/usr/bin/env bash

povray $1 && open ${1%.*}.png
