#!/usr/bin/env python3

from sys import argv, exit
from math import pow, degrees, sqrt, acos
from sysconfig import get_python_version

# make sure we're using at least version 3.2 of Python
if float(get_python_version()) < 3.2:
    print("Requires Python 3.2 or higher.")
    exit(0)


if len(argv[1:]) == 0:
    print("Give pdb files as an argument to this script.")
    exit(0)
else:
    pdbs = argv[1:]

solute_atoms = ['S00', 'C01', 'C04']
solvent_atoms = ['N04', 'C05', 'N06']
ter = 'TER   '

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

    arrays = []
    coordinates = []

    # scan through species for specific atom entry arrays
    for entry in species:
        for atom in atoms:
            if atom in entry:
                arrays.append(entry)

    # extract only the desired elements from the arrays and store them in
    # coordinates list.
    for element in arrays:
        array = element.split()
        coordinates.append(array[4])
        coordinates.append(array[5:8])

    mol_id = coordinates[0]
    cooridinates = [coordinates[i] for i in range(len(coordinates)) if float(i)
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

def normal(coordinates):
    ''' Given three coordinates, find the normal to the plane creates by the
    three coordinates'''

    vector1 = vectorize(coordinates[0], coordinates[1])
    vector2 = vectorize(coordinates[1], coordinates[2])

    return crossproduct(vector1, vector2)


def calculate_angle(normal1, normal2):
    ''' Calculate the angle between two planes.'''

    # the angle between the two planes of atomic coordinates
    # is the arccosine of dot product of the two normals.
    return  degrees(acos(dotproduct(normal1, normal2)))


for pdb in pdbs:
    with open(pdb, 'r') as pdb_file:
        contents = pdb_file.read().split('\n')
        TERlines = find_TERs(contents)
        solute = contents[0:TERlines[0]]
        solute_coordinates = get_coordinates(solute, solute_atoms)[1]
        solute_center = 
        solute_normal = normal(solute_coordinates)
        



        #TODO 
        #     find center of solute
        #     find normal of solute
        #     find desired coordinates of solute
        #     same for solvent
        solvents = []
        for i in range(len(TERlines)-1):
            solvent = contents[TERlines[i]:TERlines[i+1]]
            solvents.append(solvent)

        #TODO find center of 


