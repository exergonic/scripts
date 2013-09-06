#!/usr/bin/env python3

# This script requires at least Python 3.2.

## ABOUT ######################################################################
# This script analyzes a PDB file, find the distances between two atoms of
# interest between a certain cutoff, measured in Angstroms.  This variable is
# specified below (as a floating point number).

cutoff = 20.0

# You must identify the solute and solvent atoms of interest.
# These are the three letter codes which appear in the third field of an ATOM
# line.

solute_atom = 'S00'
solvent_atom = 'N04'

# THESE THREE VARIABLES ARE ALL THAT THE USER HAS TO CHANGE.
#
### Invocation ################################################################
#
# PDB files must be given as arguments.  Wildcard expansion is appropriately
# handled by the shell. Though the files need not have the .pdb suffix,
# this script depends upon the PDB format specifically.  It will not operate
# on other formats without adjusting some of the string splitting routines.
#
### Author  ###################################################################
#
# Billy Wayne McCann
# email: thebillywayne@gmail.com
# license:  It's YOURS!  (BSD-like)
#
###############################################################################


from sys import argv, exit
from math import sqrt
from sysconfig import get_python_version

# make sure we're using at least version 3.2 of Python
if float(get_python_version()) < 3.2:
    print("Requires Python 3.2 or higher.")
    exit(0)


# make sure arguments have been given to the script
if len(argv[1:]) == 0:
    print("Give pdb files as an argument to this script.")
    exit(0)
else:
    pdbs = argv[1:]


# species are separated in the pdb file by 'TER   '
ter = 'TER   '

# file in which to place output
output = open('output_distance.txt', 'w')
output.write("Analyzing solute atom {0}".format(solute_atom))
output.write(" and solvent atom {0} distances.\n".format(solvent_atom))

###  FUNCTIONS  ##############################################################


def find_TERs(content):
    ''' Find where the TER's in the pdb file occur'''

    terlines = []
    terline = content.index(ter)
    terlines.append(terline)
    while True:
        try:
            terline = content.index(ter, terline+1)
            terlines.append(terline)
        except:
            return terlines


def get_coordinates(species, atom):
    ''' Find coordinates of atom of interest of the species of interest,
    whether the solute or the solvent.  The atom should have been defined in
    the solute_atom and solvent_atom variables'''

    atom_array = []
    coordinate = []

    # scan through species for specific atom entry and store into atom_arrays
    for entry in species:
        if atom in entry:
            atom_array.append(entry)

    # extract only the desired elements from the atom_array and store them in
    # + coordinate list.
    for element in atom_array:
        array = element.split()
        coordinate.append(array[4])
        coordinate.append(array[5:8])

    # in binary solvents, the coordinates will sometimes not be found in a
    # particular solvent molecule. return None and test for it in the main
    # body.
    if not coordinate:
        return [None, None]

    # the molecular id is the first entry in the coordinates list
    mol_id = coordinate[0]

    # the actual coordinates are the even entries in the coordinates list
    coordinate = coordinate[1]

    return mol_id, coordinate


def distance(coordinate1, coordinate2):
    ''' Find the distance between two points'''

    x1 = float(coordinate1[0])
    x2 = float(coordinate2[0])
    y1 = float(coordinate1[1])
    y2 = float(coordinate2[1])
    z1 = float(coordinate1[2])
    z2 = float(coordinate2[2])

    return sqrt((x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2)


def stddev(all_values, average_value):
    '''Find the standard deviation '''

    # create a new list which is the difference between the average of the
    # values and each individual value.
    square_diff_from_average = [pow((i-average_value), 2) for i in all_values]

    # the standard deviation is square root of the sum of the differences
    # between each each value and the average squared divided by the number of
    # values in the list ('population' standard deviation).
    return sqrt(sum(square_diff_from_average)/len(square_diff_from_average))

### MAIN ###

# initialize dictionary to store solvent data into
solvent_data = {}

print("Using a cutoff of {0} Angstroms.".format(cutoff))
output.write("Using a cutoff of {0} Angstroms.\n\n".format(cutoff))

for pdb in pdbs:
    with open(pdb, 'r') as pdb_file:
        contents = pdb_file.read().split('\n')
        TERlines = find_TERs(contents)

        # find solute atom coordinates
        solute = contents[0:TERlines[0]]
        solute_coordinates = get_coordinates(solute, solute_atom)[1]

        # initialize a list in which to put solvent data
        solvents = []
        for i in range(len(TERlines)-1):
            solvent = contents[TERlines[i]:TERlines[i+1]]
            solvents.append(solvent)

        # keep track of how many solvents are within cutoff in each pdb
        n = 0

        for solvent in solvents:
            solvent_name, solvent_coordinates = get_coordinates(solvent,
                                                                solvent_atom)

            # in binary solvents, sometimes the solvent atom of interest just
            # ain't there so skip to the next solvent
            if solvent_coordinates is None:
                continue

            solvent_name = int(solvent_name)

            radius = distance(solute_coordinates, solvent_coordinates)

            if radius < cutoff:
                if solvent_name not in solvent_data:
                    solvent_data[solvent_name] = {'pdb': [], 'distance': []}
                solvent_data[solvent_name]['pdb'].append(pdb)
                solvent_data[solvent_name]['distance'].append(radius)

                n += 1
            else:
                continue

    print('''PDB {0} contains {1} solvent atoms of
             interest within the cutoff.'''.format(pdb, n))
    output.write("PDB {0} contains {1} solvent atoms of".format(pdb, n))
    output.write(" interest within the cutoff.\n")

# end of for pdb loop

output.write("\n")

# analyze the accepted solvent data.
for accepted in sorted(solvent_data):
    output.write('Solvent ID: {0}\n'.format(accepted))

    # loop over the entries in the accepted solvent data, extracting
    # the pdb name and distance and write them to the output file.
    for index in range(len(solvent_data[accepted]['pdb'])):
        acc_pdbname = solvent_data[accepted]['pdb'][index]
        acc_distance = solvent_data[accepted]['distance'][index]
        output.write('+ PDB name: {0}\t\t'.format(acc_pdbname))
        output.write('Distance: {0:.2f}\n'.format(acc_distance))

    # write out average distances and standard deviations to the output file
    output.write('==== AVERAGE DISTANCE ====\n')
    distance_sum = sum(solvent_data[accepted]['distance'])
    n_distance_entries = len(solvent_data[accepted]['distance'])
    average_distance = distance_sum/n_distance_entries
    distance_stddev = stddev(solvent_data[accepted]['distance'],
                             average_distance)
    output.write("Distance:\t{0:.2f} +- ".format(average_distance))
    output.write("{0:.2f}.\n\n".format(distance_stddev))

output.close()
exit(0)
