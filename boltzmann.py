#!/usr/bin/env python3

# Calculation Boltzmann population of conformers

import sys, math 

if len(sys.argv[1:]) == 0:
    print("Input the deltaG values as arguments to this script.")
    sys.exit(0)

delta_Gs = [float(i) for i in sys.argv[1:]]

RT = 0.5921

def exponential(delta_G):
    """ Return value of exp(-delta_G/RT). T = 298K """
    return math.exp(-delta_G/RT)

def sum_exponentials(energies):
    """ Return the sum of the exponentials """
    sum = 0
    for energy in energies:
        sum += exponential(energy)
    return sum



# partition function
distribution = sum_exponentials(delta_Gs)

# total equilibrium energy [Cramer. Essentials of Comp Chem. Equation 10.50]
equilibrium_population_energy = RT * math.log(distribution)

for delta_G in delta_Gs:
    percent_abundance = exponential(delta_G) / distribution * 100
    print("%.2f: %.2f%%" % (delta_G, percent_abundance))

print("\nTotal equilibrium population energy: %f" 
                             % equilibrium_population_energy)
