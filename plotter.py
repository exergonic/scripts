#!/usr/bin/env python3

# scans Spartan dihedral scan output 
# records energies, creates a plot

import numpy as np
from scipy.interpolate import pchip
import matplotlib.pyplot as plt
from sys import argv, exit


# ensure that appropriate command line arguments have been given

if len(argv) != 4:
    print("Please specify three arguments: input file, output file prefix, label for plot.")
    exit(-1)

try:
    fh = open(argv[1], 'r').read().split('\n')
except:
    print("Please specify Spartan output file.")
    exit(-1)

try:
    outtxt = argv[2]
except:
    print("Please specify prefix for output files.")
    exit(-1)

try:
    plot_legend= argv[3]
except:
    print("Please specify the label to be used in the plot.")
    exit(-1)

entxt =  '../' + outtxt + '_energies.txt'
mintxt = '../' + outtxt + '_minima.txt'
plttxt = '../' + outtxt + '_plot.pdf'

data = {}
locminima = []

# grep through output
for i in fh:
    if ')' in i:
        e = i.split()
        step = int(e[0])
        ang = float(e[2])
        en = float(e[3])
        data[step] = {'ang': ang, 'en': en}
    elif 'local minima' in i:
        e = i.split()
        locminima.append(int(e[-1]))

sorted(data.keys())

# convert energies to kcal/mol
for i in data.keys():
    data[i]['en'] = data[i]['en'] * 4.184

# global minima energy value
minen = min( [data[i]['en'] for i in data.keys()] )

# zero energies
for i in data.keys():
    data[i]['en'] = data[i]['en'] - minen

# record local minima
locmins = {x: {'ang': data[x]['ang'], 'en': data[x]['en']} for x in locminima}
sorted(locmins.keys())

# write local minima to disk
with open(mintxt, 'w') as out:
    out.write("{0}\n".format(len(locmins)))
    for i in locmins:
        out.write("{0}    {1:.2f}\n".format(locmins[i]['ang'], locmins[i]['en']))


with open(entxt, 'w') as eout: 
    eout.write('=== Angle === |  === Energy ===\n')
    for i in data:
        eout.write("   {0:5.1f}           {1:.2f}\n".format(data[i]['ang'], data[i]['en']))

ymax = 10.0
angs = [ data[i]['ang'] for i in data.keys() ]
ens  = [ data[i]['en'] for i in data.keys() ]

# interpolator
interp = pchip(angs, ens)
xx = np.linspace(0, 360, 1000)

plt.xticks(list(range(0,390,60)))
plt.xlabel('Dihedral (degrees)')
plt.ylabel('Relative Energy (kcal/mol)')
plt.grid(True)
plt.plot(xx, interp(xx),'k',label=plot_legend)
plt.plot(angs, ens, 'ko')
plt.axis([0, 360, 0, ymax])
plt.legend()
#plt.show()
plt.savefig(plttxt, format='pdf', bbox_inches=0)
