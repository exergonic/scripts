#!/usr/bin/env python3

# Calculation Boltzmann population of conformers

from sys import exit, argv
from math import exp, log

if len(argv[1:]) == 0:
    print("Input the deltaG values as arguments to this script.")
    exit(0)

delta_Gs = [float(i) for i in argv[1:]]

RT = 0.5921


def exponential(delta_G):
    """ Return value of exp(-delta_G/RT). T = 298K """
    return exp(-delta_G/RT)


def sum_exponentials(energies):
    """ Return the sum of the exponentials """
    sum = 0
    for energy in energies:
        sum += exponential(energy)
    return sum


# partition function
distribution = sum_exponentials(delta_Gs)
print("Q = {0:.2f}".format(distribution))

# total equilibrium energy [Cramer. Essentials of Comp Chem. Equation 10.50]
equilibrium_population_energy = RT * log(distribution)

for delta_G in delta_Gs:
    percent_abundance = exponential(delta_G) / distribution * 100
    print("%.2f: %.2f%%" % (delta_G, percent_abundance))

print("\nTotal equilibrium population energy: %f"
      % equilibrium_population_energy)
