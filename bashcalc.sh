#!/bin/bash

# About ---------------------------------------------------------------
#
# Easily perform calculations on the command line.
#
# Invocation ----------------------------------------------------------
# 
# bashcalc.sh { expression }

echo "scale=4; $1" | bc
exit 0
