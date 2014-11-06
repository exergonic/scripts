#!/usr/bin/env python3

## ABOUT  ####################################################################
#
#
#
#
#
#
## INVOCATION  ###############################################################
#
#
#
#
#
## AUTHOR  ###################################################################
#
# Billy Wayne McCann
# email : thebillywayne@gmail.com
# license : ItsYours (BSD-like)
#
##############################################################################

import sys
import math

# check for input
if len(sys.argv[1:]) == 0:
    print("Input the file name as the argument to this script.")
    sys.exit(0)


datafile = sys.argv[1]
output = open('histodata.txt', 'w')

# universal gas constant energy at 298K
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



# dictionary to hold angles, energy, and the calculated population
data = {}

# read through input file and gather data

with open(datafile, 'r') as fh:
    contents = fh.read().split('\n')
    contents.pop()
    for entry in contents:
        angle = float(entry.split()[0])
        energy = float(entry.split()[1])
        data[angle] = {'energy': energy}

energies = [ data[i]['energy'] for i in data.keys() ]
minimum = min(energies)
energies_zeroed = [ i - minimum for i in energies ]
distribution = sum_exponentials(energies_zeroed)

for angle in sorted(data.keys()):
    data[angle]['en_zeroed'] = data[angle]['energy'] - minimum
    pop = 100 * (exponential(data[angle]['en_zeroed']) / distribution)
    print("Angle : {0}\tEnergy: {1}\tZeroed: {2}\tPopulation: {3:.2f}".format(
                                                         angle,
                                                         data[angle]['energy'],
                                                         data[angle]['en_zeroed'],
                                                         pop))

output.close()
