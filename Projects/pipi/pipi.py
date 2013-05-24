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
# atoms are defined by the atom labels as they appear in the pdb file.

solute_atoms = ['S00', 'C01', 'C04']
solvent_atoms = ['C05', 'N04', 'N06']

# Please ensure that all three atoms are in the aromatic ring, as these three
# atoms will be used to form the plane in which the pi system lies.   
# 
# The script will find the angles between the planes involved in the (hopefully
# found) pi-pi stacking, as well as take an average and standard deviation.
# Output for every solvent molecule evaluated is printed in an output file
# named 'angles.txt'.
#
## INVOCATION #################################################################
# 
# Ensure that the script is marked executable or explicitly invoke python
# (version 3.2 minimal) to run the script.  Any pdb file which you'd like to
# analyze should be given as an argument.  
# 
##############################################################################
#
# Author: Billy Wayne McCann
# email : thebillywayne@gmail.com
#
###############################################################################


from sys import argv, exit
from math import pow, degrees, sqrt, acos
from sysconfig import get_python_version

# make sure we're using at least version 3.2 of Python
if float(get_python_version()) < 3.2:
    print("Requires Python 3.2 or higher.")
    exit(0)


# make sure arguments are given to the script
if len(argv[1:]) == 0:
    print("Give pdb files as an argument to this script.")
    exit(0)
else:
    pdbs = argv[1:]


# species are separated in the pdb file by 'TER   '
# assigning it a variable is easier than using 'TER  ' every time
ter = 'TER   '

# file in which to place output
output = open('angles.txt', 'w')

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

    # scan through species for specific atom entry atom_arrays
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

    if not coordinates:
        return [None,None] 

    mol_id = coordinates[0]
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

    vector1 = unit(vectorize(coordinates[0], coordinates[1]))
    vector2 = unit(vectorize(coordinates[1], coordinates[2]))

    return crossproduct(vector1, vector2)

def calculate_angle(normal1, normal2):
    ''' Calculate the angle between two planes.'''

    # the angle between the two planes of atomic coordinates
    # is the arccosine of dot product of the two normals.
    return  degrees(acos(dotproduct(normal1, normal2)))


def stddev(all_angles, average):
    '''Find the standard deviation of the angles'''

    # create a new list which is the difference between the average of the
    # angles and each individual angle.
    square_diff_from_average = [pow((i-average), 2) for i in all_angles]

    # the standard deviation is square root of the sum of the differences
    # between each each angle and the average squared divided by the number of
    # values in the list.
    return sqrt(sum(square_diff_from_average)/len(square_diff_from_average))

## MAIN  ######################################################################

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

        angles = []
        for solvent in solvents:
            solvent_name, solvent_coordinates = get_coordinates(solvent, solvent_atoms)
            
            if solvent_coordinates is None:
                continue

            solvent_center = center(solvent_coordinates[1],
                                    solvent_coordinates[2])
            solvent_normal = normal(solvent_coordinates)
            radius = distance(solute_center, solvent_center)

            if radius < cutoff:
                angle = calculate_angle(solute_normal, solvent_normal)
                angles.append(angle)
                output.write("Solvent ID: {0}\t".format(solvent_name))
                output.write("Distance  : {0:.2f}\t".format(radius))
                output.write("Angle: {0:.2f}\n".format(angle))
            else:
                continue

        angle_average = sum(angles)/len(angles)
        standard_dev = stddev(angles, angle_average)

        output.write('==============================================\n')
        output.write("Angle average is {0:.2f} +- ".format(angle_average))
        output.write("{0:.2f}.\n".format(standard_dev))
        print("Angle average is {0:.2f} +- {1:.2f}".format(angle_average,
                                                            standard_dev))
       
output.close()
exit(0)
