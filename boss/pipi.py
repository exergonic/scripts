#!/usr/bin/env python3

## README #####################################################################
# 
# This script is meant to measure pi-pi stacking between the solute and solvent
# atoms. It will evaluate only those solvent atoms within a certain cutoff,
# defined by the user (below).

cutoff = 10.0

# This cutoff distance is based upon the approximated center of the ring
# containing the pi system. The center is approximated by using two of the
# three coordinates given by the user. The two atoms which will approximate the
# center need to be the second and third atoms defined in the lists below. The
# atoms are defined by the atom labels as they appear in the pdb file. Please
# note, this script works with pdb files ONLY.

solute_atoms = ['S00', 'C01', 'C04']
solvent_atoms = ['C05', 'N04', 'N06']

# Please ensure that all three atoms are in the aromatic ring, as these three
# atoms will be used to form the plane in which the pi system lies.   
# 
# The script will find the angles between the planes involved in the (hopefully
# found) pi-pi stacking, as well as take an average and standard deviation.
# Output for every solvent molecule evaluated is printed in an output file
# named 'output_pi-pi.txt'.
# 
# !!The above two variables should be all that is required for the user to
# change!!
#
## INVOCATION #################################################################
# 
# Ensure that the script is marked executable or explicitly invoke python
# (version 3.2 minimal) to run the script.  Any pdb file which you'd like to
# analyze should be given as an argument. Shell expansion is handled
# appropriately.
# 
# Example:
# ./pipi.py *pdb
# ./pipi.py d50plt5 d50plt10 d50plt15
#
# Note that the filenames do not need a pdb suffix, but the script relies on
# the pdb format.  
##############################################################################
#
# Author: Billy Wayne McCann
# email : thebillywayne@gmail.com
# NOTE:  My code is purposefully verbose. don't hate. 
###############################################################################


from sys import argv, exit
from math import pow, degrees, sqrt, acos
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
output = open('output_pi-pi.txt', 'w')

###  FUNCTIONS  ###############################################################

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

def get_coordinates(species, atoms):
    ''' Find coordinates of atoms of interest of the species of interest,
    whether the solute or the solvent.  The atoms should have been defined in
    the solute_atoms and solvent_atoms variables'''

    atom_arrays = []
    coordinates = []

    # scan through species for specific atom entry and store into atom_arrays
    for entry in species:
        for atom in atoms:
            if atom in entry:
                atom_arrays.append(entry)

    # extract only the desired elements from the atom_arrays and store them in
    # coordinates list.
    for element in atom_arrays:
        array = element.split()
        coordinates.append(array[4])
        coordinates.append(array[5:8])

    # in binary solvents, the coordinates will sometimes not be found in a
    # particular solvent molecule. return None and test for it in the main
    # body.
    if not coordinates:
        return [None,None] 

    # the molecular id is the first entry in the coordinates list
    mol_id = coordinates[0]

    # the actual coordinates are the even entries in the coordinates list
    coordinates = [coordinates[i] for i in range(len(coordinates)) if float(i)
                    % 2 != 0]
    return mol_id, coordinates

def vectorize(coordinate1, coordinate2):
    '''Take coordinates and return a vector'''

    # extract x, y, z values from coordinates
    # make them floats for the subtraction operations in the return statement
    x1 = float(coordinate1[0])
    x2 = float(coordinate2[0])
    y1 = float(coordinate1[1])
    y2 = float(coordinate2[1])
    z1 = float(coordinate1[2])
    z2 = float(coordinate2[2])
    return [x2-x1, y2-y1, z2-z1]

def dotproduct(vector1, vector2):
    '''Return the dot product between two vectors'''

    return vector1[0]*vector2[0]+vector1[1]*vector2[1]+vector1[2]*vector2[2]

def crossproduct(vector1, vector2):
    '''Find the cross product between two vectors'''

    return [vector1[1]*vector2[2]-vector1[2]*vector2[1],
            vector1[2]*vector2[0]-vector1[0]*vector2[2],
            vector1[0]*vector2[1]-vector1[1]*vector2[0]]

def magnitude(vector):
    '''Return the magnitude of a vector'''

    return sqrt(vector[0]*vector[0]+vector[1]*vector[1]+
            vector[2]*vector[2])

def unit(vector):
    '''Return the unit vector of a vector'''

    mag = magnitude(vector)
    unit_vector = []
    for scalar in vector:
        unit_vector.append(scalar/mag)
    return unit_vector

def center(coordinate1, coordinate2):
    ''' Given two coordinates, find the midpoint between them. 
    This function is used to approximate the center of a species. '''
    x1 = float(coordinate1[0])
    x2 = float(coordinate2[0])
    y1 = float(coordinate1[1])
    y2 = float(coordinate2[1])
    z1 = float(coordinate1[2])
    z2 = float(coordinate2[2])

    return [(x2+x1)/2, (y2+y1)/2, (z2+z1)/2]

def distance(coordinate1, coordinate2):
    ''' Find the distance between two points'''
    x1 = float(coordinate1[0])
    x2 = float(coordinate2[0])
    y1 = float(coordinate1[1])
    y2 = float(coordinate2[1])
    z1 = float(coordinate1[2])
    z2 = float(coordinate2[2])

    return sqrt((x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2)

def normal(coordinates):
    ''' Given three coordinates, find the normal to the plane created by the
    three coordinates'''

    vector1 = vectorize(coordinates[0], coordinates[1])
    vector2 = vectorize(coordinates[1], coordinates[2])

    return crossproduct(vector1, vector2)

def calculate_angle(normal1, normal2):
    ''' Calculate the angle between two planes.'''

    # make normals into unit vectors first
    normal1 = unit(normal1)
    normal2 = unit(normal2)

    # the angle between the two planes of atomic coordinates
    # is the arccosine of dot product of the two normals.
    return  degrees(acos(dotproduct(normal1, normal2)))


def stddev(all_values, average_value):
    '''Find the standard deviation of the angles'''

    # create a new list which is the difference between the average of the
    # values and each individual value.
    square_diff_from_average = [pow((i-average_value), 2) for i in all_values]

    # the standard deviation is square root of the sum of the differences
    # between each each value and the average squared divided by the number of
    # values in the list ('population' standard deviation).
    return sqrt(sum(square_diff_from_average)/len(square_diff_from_average))


## MAIN  ######################################################################

# initialize dictionary to store solvent data into
solvent_data = {} 

print("Using a cutoff of {0} Angstroms.".format(cutoff))
output.write("Using a cutoff of {0} Angstroms.\n\n".format(cutoff))

for pdb in pdbs:
    with open(pdb, 'r') as pdb_file:
        contents = pdb_file.read().split('\n')
        TERlines = find_TERs(contents)

        # find solutes coordinates, center, and normal vector
        solute = contents[0:TERlines[0]]
        solute_coordinates = get_coordinates(solute, solute_atoms)[1]
        solute_center = center(solute_coordinates[1], solute_coordinates[2]) 
        solute_normal = normal(solute_coordinates)

        solvents = []
        for i in range(len(TERlines)-1):
            solvent = contents[TERlines[i]:TERlines[i+1]]
            solvents.append(solvent)

        # keep track of how many solvents are within cutoff in each pdb
        j = 0
        for solvent in solvents:
            solvent_name, solvent_coordinates = get_coordinates(solvent, solvent_atoms)
            
            if solvent_coordinates is None:
                continue

            solvent_name = int(solvent_name)
            solvent_center = center(solvent_coordinates[1],
                                    solvent_coordinates[2])
            radius = distance(solute_center, solvent_center)

            if radius < cutoff:
                solvent_normal = normal(solvent_coordinates)
                angle = calculate_angle(solute_normal, solvent_normal)
                if solvent_name not in solvent_data:
                    solvent_data[solvent_name] = {'pdb': [], 
                            'distance': [], 'angle': []}
                solvent_data[solvent_name]['pdb'].append(pdb)
                solvent_data[solvent_name]['distance'].append(radius)
                solvent_data[solvent_name]['angle'].append(angle)
                j += 1

            else:
                continue

        print("PDB {0} contains {1} solvent(s) within the cutoff.".format(pdb, j))
        output.write("PDB {0} contains {1} solvent(s) within the cutoff.\n".format(pdb, j))

# end of for pdb loop

output.write("\n")


# analyze the accepted solvent data.
for accepted in sorted(solvent_data):
    output.write('Solvent ID: {0}\n'.format(accepted))

    for index in range(len(solvent_data[accepted]['pdb'])):
        output.write('+ PDB name: {0}\t\t'.format(solvent_data[accepted]['pdb'][index]))
        output.write('Distance: {0:.2f}\t'.format(solvent_data[accepted]['distance'][index]))
        output.write('Angle: {0:.2f}\t\n'.format(solvent_data[accepted]['angle'][index]))

    output.write('== AVERAGES ==\n')
    average_distance = sum(solvent_data[accepted]['distance'])/len(solvent_data[accepted]['distance'])
    distance_stddev = stddev(solvent_data[accepted]['distance'],
                                average_distance)
    average_angle = sum(solvent_data[accepted]['angle'])/len(solvent_data[accepted]['angle'])
    angle_stddev = stddev(solvent_data[accepted]['angle'], average_angle)
    output.write("Distance:\t{0:.2f} +- ".format(average_distance))
    output.write("{0:.2f}.\n".format(distance_stddev))
    output.write("Angle:  \t{0:.2f} +- ".format(average_angle))
    output.write("{0:.2f}.\n\n".format(angle_stddev))

output.close()
exit(0)
