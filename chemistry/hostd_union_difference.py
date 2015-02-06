#!/usr/bin/env python3

'''
Report the differences and commonalities between two sets of
HostDesigner outputs. Place output in 'differences.txt' and
'same.txt'
'''

from sys import argv
from sys import exit


def get_hosts(f) -> list:
    '''
    return a list of the contents of a file
    '''

    return [line[:-1] for line in open(f, 'r')]


def hostset(hosts) -> set:
    '''
    return the set of unique host name
    '''

    return set([hosts[i][36:73].strip('_') for i, _ in enumerate(hosts)])


if len(argv[1:]) == 0 or len(argv[1:]) > 2:
    print('''Provide two file names from which to determine
             the common hosts and the uncommon hosts.
           ''')
    exit(1)

hostfilea = argv[1]
hostfileb = argv[2]
hosts1 = get_hosts(hostfilea)
hosts2 = get_hosts(hostfileb)
host_set1 = hostset(hosts1)
host_set2 = hostset(hosts2)

differences = host_set2.difference(host_set1)
same = host_set1.intersection(host_set2)

difference_file = open('differences.txt', 'w')
same_file = open('same.txt', 'w')

difference_file.write('\n'.join(differences))
difference_file.close()

same_file.write('\n'.join(same))
same_file.close()

exit(0)

