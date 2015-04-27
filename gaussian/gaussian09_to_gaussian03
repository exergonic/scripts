#!/usr/bin/env bash

sed '
    s:Gaussian 09:Gaussian 03:
    s:Eigenvalues --:EIGENVALUES --:
    s/Density Matrix:/DENSITY MATRIX./
    ' $1 > ${1%.log}.g03.log

