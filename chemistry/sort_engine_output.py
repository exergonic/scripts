#!/usr/bin/env python3

# requires regular expression searching
import re
from sys import exit
import os
import shutil

# ~~~~~~~~~~ F U N C T I O N S ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


def strip_special(string) -> str:
    'Removes certain characters from a string'

    a = string.replace(',', '')
    a = string.replace('[', '')
    a = string.replace(']', '')
    a = string.replace('_', '')

    return a


def make_c3d(hdo_in) -> list:
    'Translate a hostdesigner output portion into a chem3d format'

    hdo_in.pop(1)
    c3d_out = []
    c3d_out.append(hdo_in[0])

    for i, line in enumerate(hdo_in[1:], 1):
        a = line.split()
        # place atom numbers in the list
        a.insert(1, str(i))
        c3d_out.append(' '.join(a))

    return c3d_out

# input files created by HostDesigner
outconf = 'out.conf'
complexhdo = 'complex.hdo'

# create separate output directory in which to put
# separated hostguest complexes
new_dir = 'separated_outputs'
if os.path.exists(new_dir):
    shutil.rmtree(new_dir)

os.mkdir(new_dir)

# read lines from out.conf to get order of output
final_order = [line[:-1] for line in open(outconf, 'r')]

# chop off first three lines and the last line
final_order = final_order[3:-1]

# get linker numbers
linker_numbers = [final_order[i][21:26].strip() for i
                  in range(len(final_order))]

# read hdo file created by hostdesigner
hdo_file = [line[:-1] for line in open(complexhdo, 'r')]
hdo_length = len(hdo_file)

# a regex to search for lines that define new complexes in hdo_file
natoms_regex = re.compile(r'\A\s{0,3}\d{1,5}')

# find line number on which new complexes start
linenumbers = []
# also store metadata that's found on the next line
metadata = []

for linenumber, entry in enumerate(hdo_file):
    if natoms_regex.search(entry):
        linenumbers.append(linenumber)
        metadata.append(linenumber + 1)

linenumbers.append(hdo_length)
# DEBUG     print("\nLinenumbers which begin new complexes: %s" % linenumbers)

print("Reordering complexes according to out.conf")
# extract complexes from the hostdesigner output file
hostguest = []
# filter those that have already been seen
hostguest_seen = []
for linker_number in linker_numbers:
    # print("Investigating linker number:\t%s" % linker_number)
    for n in range(len(linenumbers)-1):
        # Find the beginning and end of the next hostguest complex
        startline = linenumbers[n]
        endline = linenumbers[n+1]
        possible_hit = hdo_file[startline:endline]
        # print("Possible hit: %s" % linker_number)

        # Determine if this hit has been found before to remove duplicates
        info_line = possible_hit[1]
        #  grab the sequence between ( and ) from the info line
        left_parens = info_line.find('(') + 1
        right_parens = info_line.find(')')
        complex_number = info_line[left_parens:right_parens].strip('_')
        # print("Complex number: \t%s" % complex_number)

        if complex_number == linker_number:
            if complex_number not in hostguest_seen:
                # print("\tMATCHED %s\n" % complex_number)
                hostguest_seen.append(complex_number)
                hostguest.append(possible_hit)

print("Creating sorted_hdo file and creating chem3d files.")
file_prefix = 'out'

# number of digits in final element of linker_numbers
# pad other digits with 0's
sig_figs = len(linker_numbers[-1])
fmt = str("%0" + str(sig_figs) + ".i")

with open('sorted_out.hdo', 'w') as out:
    for i, hg in enumerate(hostguest):
        # write all host-guest complexes to a single file
        [out.write("%s\n" % a) for a in hg]
        # write each host-guest complex to a separate file
        # in chem3d format in the separated_outputs/ dir.
        stripped_hostname = strip_special(hg[1][36:73])
        # create file name and write to it
        padded_i = str(fmt % i)
        file_suffix = str(padded_i + '_' + stripped_hostname + '.c3d')
        file_name = str(new_dir + '/' + file_prefix + file_suffix)
        c3d_file = open(file_name, 'w')
        c3d_content = make_c3d(hg)
        c3d_file.write("\n".join(c3d_content))
        c3d_file.close()

print("Complete")
exit(0)
