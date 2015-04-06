#!/usr/bin/env python3


from math import pow, degrees, sqrt, acos
from sys import argv, exit
from sysconfig import get_python_version

#   ABOUT ####################################################################
#
# REQUIRES PYTHON 3.2!!!

#
# This script finds the angle between a plane created by a molecule and the
# YZ axis. The plane created by the molecule is defined by three atom numbers.
# These three atoms are chosen by the user and must be placed into the
# 'atom_numbers' variable below. They must correspond to the atom numbers as
# they appear in the pdb file.


atom_numbers = ['2', '6', '14']


# This script will scan the pdb file(s) (given as an argment(s))  for the atom
# numbers and extract the x,y,z coordinates for each atom. If more than one pdb
# file is specified, an average and standard deviation will be taken as well
# printing the angle for every pdb file scanned, outputting the data to a text
# file, 'angles.txt.' For many pdb files, use the shell's built-in file
# globbing. The script will handle the file names appropriately.
#
# # MODUS OPERANDI ###########################################################
#
# --The Molecular Plane--
# The angle between the molecular plane and YZ plane is the arc-cosine of the
# dot product of the normals of the planes. The three atom coordinates define a
# molecular plane. The coordinates are first converted to two vectors.  The
# normal to the molecular plane is the cross-product of these two vectors.
# This normal is converted to a unit vector.
#
# --The YZ Plane--
# The angle with the YZ plane is calculated using the  unit vector normal to
# this plane, by definition, {1,0,0}. This is hard-coded into the 'z_normal'
# variable. Manipulating this variable will allow you to find the angles
# between other planes as well.
#
# --Angle Calculation--
# Having the unit vectors normal to the two planes, the angle between them is
# the arc-cosine of the dot-product between the two vectors.
#
# # INVOCATION ################################################################
#
# Call the script giving the pdb file(s) as argument(s).
#
###############################################################################
#
# Author: Billy Wayne McCann
# email:  thebillywayne@gmail.com
# License: DoWhatEverTheHellYouWantToWithIt (BSD-like)
#
###############################################################################

# make sure we're using at least version 3.2 of Python
if float(get_python_version()) < 3.2:
    print("Requires Python 3.2 or higher.")
    exit(0)

# The pdb files are the argument(s) given to the script.
# Print a usage message and then exit if no argument(s) given.
pdb_files = argv[1:]

# make sure at least one pdb file has been indicated
if len(pdb_files) == 0:
    print("At least one pdb file must be given as an argument.")
    print("For multiple pdbs, wildcard expansion is appropriately handled.")
    exit(0)


# sort the pdb file into alphanumberic order
pdb_files.sort()

# the unit normal vector of the YZ plane
z_normal = [1, 0, 0]

# begin function definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


def vectorize(coordinate1, coordinate2):
    '''Take coordinates and return a vector'''

    # extract x, y, z values from coordinates
    # make them floats for the subtraction operations in the return statement

    x1, y1, z1 = map(float, coordinate1)
    x2, y2, z2 = map(float, coordinate2)

    return [x2 - x1, y2 - y1, z2 - z1]


def dotproduct(vector1, vector2):
    '''Return the dot product between two vectors'''

    return vector1[0] * vector2[0] + vector1[1] * vector2[1] + vector1[2] * vector2[2]


def crossproduct(vector1, vector2):
    '''Find the cross product between two vectors'''

    return [vector1[1] * vector2[2] - vector1[2] * vector2[1],
            vector1[2] * vector2[0] - vector1[0] * vector2[2],
            vector1[0] * vector2[1] - vector1[1] * vector2[0]]


def magnitude(vector):
    '''Return the magnitude of a vector'''

    return sqrt(vector[0] * vector[0] + vector[1] * vector[1] +
                vector[2] * vector[2])


def unitvector(vector):
    '''Return the unit vector of a vector'''

    mag = magnitude(vector)
    unit_vector = [i / mag for i in vector]

    return unit_vector


def stddev(all_angles, average):
    '''Find the standard deviation of the angles'''

    # create a new list which is the difference between the average of the
    # angles and each individual angle.
    square_diff_from_average = [(i - average)**2 for i in all_angles]

    # the standard deviation is square root of the sum of the differences
    # between each each angle and the average squared divided by the number of
    # values in the list.
    return sqrt(sum(square_diff_from_average) / len(square_diff_from_average))


def get_solute(filehandler):
    '''Extract solute portion from the pdb file'''

    # initialize list into which to place the lines of the pdb file which
    # correspond to solute atoms alone. this will make for faster scanning of
    # the pdb file. When the string 'TER' is reached, the solute portion of the
    # pdb has completed.
    lines = []
    with open(filehandler, 'r') as fh:
        for line in fh:
            if 'TER' in line:
                break
            lines.append(line)
    return lines


def get_coordinates(pdbfile):
    '''Get the coordinates for chosen atoms from the pdb file.'''

    # remove solvent atoms for faster scanning of the pdb file.
    solute = get_solute(pdbfile)

    # initialize an list into which the three atomic coordinates will be
    # placed.
    coordinates = []

    # search every line of the solute section of the pdb file
    # for the atom number which were interested in. when found,
    # append the respective coordinates to the coordinates array.
    for line in solute:
        # convert the line into an array. Within a pdb file, the atom number
        # will be the second element (element 1) of the array. The coordinates
        # are the 5th through 7th elements.
        line_elements = line.split()
        for atom_number in atom_numbers:
            if line_elements[1] == atom_number:
                coordinates.append(line_elements[5:8])
    return coordinates


def calculate_angle(filename):
    ''' Calculate the angle between the molecular plane and the YZ plane.'''

    # retrieve atom coordinates of interest
    atom_coordinates = get_coordinates(filename)

    # define two vectors from the atom coordinates
    vector1 = vectorize(atom_coordinates[1], atom_coordinates[0])
    vector2 = vectorize(atom_coordinates[2], atom_coordinates[1])

    # the normal of the plane in which the atomic coordinates lie
    # is the cross product of the vectors. make it a unit vector.
    molecule_normal = unitvector(crossproduct(vector1, vector2))

    # the angle between the plane of the atomic coordinates and
    # the YZ plane is the arccosine of dot product of the two normals.
    return degrees(acos(dotproduct(molecule_normal, z_normal)))

# end function definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# main ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# if more than one pdb file is specified, then calculate all angles, print them
# to a file 'angles.txt' and also record the average. If only one is given,
# simply print out the angle for the sole pdb file.
if len(pdb_files) > 1:
    print("An average will also be taken.")
    print("All angles will be printed in angles.txt.")

    # initialize array to contain angles of all the pdb files
    angles = []

    # open a summary file named 'angles.txt' in which to place the angles
    # of every pdb file
    sumfile = open('angles.txt', 'w')

    # loop through pdb files, extract angles, and write to summary file.
    for pdb_file in pdb_files:
        angle = calculate_angle(pdb_file)
        angles.append(angle)
        sumfile.write("%s\t\t%.2f degrees.\n" % (pdb_file, angle))

    angle_average = sum(angles) / len(angles)
    standard_deviation = stddev(angles, angle_average)

    # write average to angles.txt and also print it to screen.
    sumfile.write('\nAverage angle is %.2f+-%.2f degrees.\n' %
                  (angle_average, standard_deviation))
    sumfile.close()

    print('\nAverage angle is \033[94;1m%.2f+-%.2f\033[0m degrees.\n' %
          (angle_average, standard_deviation))

else:
    # Only one pdb was specified. Print the angle to the screen.
    print("%.2f degrees." % calculate_angle(pdb_files[0]))

exit(0)
