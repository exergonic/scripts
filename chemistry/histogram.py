#!/usr/bin/env python3


from sys import argv, exit
from math import exp


# check for input
if len(argv[1:]) == 0:
    print("Input the file name as the argument to this script.")
    exit(0)


datafile = argv[1]
output = open('histodata.txt', 'w')

# universal gas constant energy at 298K
RT = 0.5921

def exponential(delta_G):
    """ Return value of exp(-delta_G/RT). T = 298K """

    return exp(-delta_G/RT)


# dictionary to hold angles, energy, and the calculated population
data = {}

# read through input file and gather data

with open(datafile, 'r') as fh:
		contents = [line[:-1] for line in fh]
		for entry in contents:
				angle = float(entry.split()[0])
				energy = float(entry.split()[1])
				data[angle] = {'energy': energy}

energies = [data[i]['energy'] for i in data.keys()]
minimum = min(energies)
energies_zeroed = [i - minimum for i in energies]
distribution = sum(map(exponential, energies_zeroed))

for angle in sorted(data.keys()):
    data[angle]['en_zeroed'] = data[angle]['energy'] - minimum
    pop = 100 * (exponential(data[angle]['en_zeroed']) / distribution)
    print("Angle : {0}\tEnergy: {1}\tZeroed: {2}\tPopulation: {3:.2f}".format(
                                                         angle,
                                                         data[angle]['energy'],
                                                         data[angle]['en_zeroed'],
                                                         pop))

output.close()
