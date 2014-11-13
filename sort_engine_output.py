#!/usr/bin/env python3


# requires regular expression searching
import re
from sys import exit
import os
import shutil


# output file

out1 = 'out.conf'
out2 = 'complex.hdo'

# create separate output directory in which to put
# separated hostguest complexes
new_dir = 'separated_outputs'
if os.path.exists(new_dir):
    shutil.rmtree(new_dir)

os.mkdir(new_dir)

# read lines from out.conf to get order of output
final_order = [line[:-1] for line in open('out.conf','r')]

# chop off first three lines and the last line
final_order = final_order[3:-1]

# get linker numbers
linker_numbers = [final_order[i][21:26].strip() for i in range(len(final_order))]
# debug
# print("Linker numbers found: %s" % linker_numbers)

# read hdo file created by hostdesigner
hdo_file = [line[:-1] for line in open('complex.hdo','r')]
hdo_length = len(hdo_file)

# a regex to search for lines that define new complexes in hdo_file
natoms_regex = re.compile(r'\A\s{0,3}\d{1,5}')

# find line number on which new complexes start
linenumbers = []
for linenumber, entry in enumerate(hdo_file):
    if natoms_regex.search(entry):
        linenumbers.append(linenumber)

linenumbers.append(hdo_length)

# DEBUG
#print("\nLinenumbers which begin new complexes: %s" % linenumbers)

# extract complexes from the hostdesigner output file
hostguest = []
hostguest_seen = []

for linker_number in linker_numbers:
    print("Investigating linker number:\t%s" % linker_number)
    for n in range(len(linenumbers)-1):
        # Find the beginning and end of the next hostguest complex
        startline = linenumbers[n]
        endline = linenumbers[n+1]
        possible_hit = hdo_file[startline:endline]
        print("Possible hit: %s" % linker_number)

        # Determine if this hit has been found before to remove duplicates
        info_line = possible_hit[1]
        #  grab the sequence between ( and ) from the info line
        left_parens = info_line.find('(') + 1
        right_parens = info_line.find(')')
        complex_number = info_line[left_parens:right_parens].strip('_')
        print("Complex number: \t%s" % complex_number)

        if complex_number == linker_number:
            if complex_number not in hostguest_seen:
                print("\tMATCHED %s\n" % complex_number)
                hostguest_seen.append(complex_number)
                hostguest.append(possible_hit)


file_prefix = 'out'

with open('sorted_out.hdo','w') as out:
    for i, hg in enumerate(hostguest):
        
        # write each host-guest complex to a separate file
        # in the separated_outputs/ dir.
        stripped_hostname = hg[1][36:73].replace(',', '').replace('_', '')

        # ensure that i is two digits -> creates j
        j = str("%02.f" % i)

        # create file name and write to it
        file_suffix = str(j + '_' + stripped_hostname + '.dho')
        file_name = str(new_dir + '/' + file_prefix + file_suffix)
        write_file = open(file_name, 'w')
        write_file.write('\n'.join(hg))
        
        # write all host-guest complexes to a single file
        [ out.write("%s\n" % a) for a in hg ]

exit(0)
