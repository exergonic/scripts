#!/usr/bin/env python3

#
# Calculate delta G's from percent abundances
# P1 = exp(-B*deltaG) / sigma_i(exp(-B*deltaG_i)
# deltaG = -RT * ln(population/maximum(population))

from sys import argv
from math import log

if len(argv[1:]) == 0:
    print("Input Boltzmann populations as arguments.")
    exit(1)

RT = 0.5924

# make all of the populations floats
pops = map(float, argv[1:])

# the populations are percentages. they should sum to 1.00
if sum(pops) != 1.00:
    pops.append(1.00 - sum(pops))

# the maximum population is what the others are compared to
zero = max(pops)

# present the highest populations first
pops.sort(reverse=True)

for pop in pops:
    print("%.2f ==> %.2f kcal/mol" % (pop, -RT*log(pop/max(pops))))
