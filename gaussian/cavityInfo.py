#!/usr/bin/env python3

import os, sys, glob
from time import time

# time script began
starttime = time()

origdir = os.getcwd()
output_file = os.path.join(origdir,'soluteCavityInfo.csv')

# molecule names
molecule_list = []
directory_contents = os.listdir()
for file in directory_contents:
    if os.path.isdir(file):
        molecule_list.append(file)

# possible solvents 
possible_solvent_list = ['water','acetonitrile','dichloromethane','chloroform',
		'carbontetrachloride','toluene','cyclohexane']
# list of pcm methods
method_list = ['iefpcm','cpcm','smd']
# list of cavity types
cavity_list = ['bondi','pauling','ua0','uahf','uaks','uff'] 

# function to abbreviate the solvent for easier printing
def abbrev_solvent(solvent):
    solvent = solvent.lower()
    if solvent == 'acetonitrile':
        return 'CH3CN'
    if solvent == 'cyclohexane':
        return 'C6H12'
    if solvent == 'water':
        return 'H2O'
    if solvent == 'carbontetrachloride':
        return 'CCL4'
    if solvent == 'chloroform':
        return 'CHCL3'
    if solvent == 'dichloromethane':
        return 'CH2CL2'
    if solvent == 'toluene':
        return 'TOL'
    else:
        print("Solvent not recognized. Not abbreviating.\n")
        return solvent

outfile = open(output_file, 'w')

# write header to outfile
outfile.write("CAVITY,MODEL,MOLECULE,SOLVENT,Vol(enol),")
outfile.write("Vol(keto),VolDiff,%VolDiff,SA(enol),SA(keto),saDiff,%saDiff,deltaG\n")
outfile.write("-" * 75 + "\n")

for molecule in molecule_list:
    os.chdir(molecule)
    # find the solvents which are actually in this directory
    # based upon the possible_solvents_list
    solvent_list = []
    directories = [ file for file in os.listdir() if os.path.isdir(file) ]
    # if a directory is in the possible solvent list
    # append the directory to the solvent list for this molecule.
    for directory in directories:
        if directory in possible_solvent_list:
            solvent_list.append(directory)

    for solvent in solvent_list:
        os.chdir(solvent) # now in solvent directory
        solvent = abbrev_solvent(solvent)
        for method in method_list:
            os.chdir(os.path.join(method,'G4'))
            for cavity in cavity_list:
                surface_areas = []
                volumes = []
                Free_Energies = []
                for type in ['ol','one']:
                    print("Beginning read of:\t %s,%s,%s,%s,%s" 
                            % (molecule, solvent, method, cavity, type))
                    file_name = glob.glob(str('*' + type + '.*' + cavity + '*.log'))[0]

                    log_file = open(file_name, 'r')
                    file_string = log_file.read()
                    file_array = file_string.split('\n')
                    SA_list = []
                    Vol_list = []
                    for line in file_array:
                        if 'Cavity surface area' in line:
                            elements = line.split()
                            surface_area = float(elements[5])
                            #print("\t\t\t%s" % surface_area)
                            SA_list.append(surface_area)

                        if 'Cavity volume' in line:
                            elements = line.split()
                            volume = float(elements[4])
                            Vol_list.append(volume)

                        if 'G4 Free Energy' in line:
                            elements = line.split('=')
                            free_energy = float(elements[2].lstrip())
                            Free_Energies.append(free_energy)


                    print(SA_list)
                    surface_areas.append(SA_list[-1])
                    volumes.append(Vol_list[-1])

                    log_file.close()
                    # surface areas and volumes [0] and [1] are for the enol and keto form, respectively
                
                sa_diff = surface_areas[0] - surface_areas[1]
                sa_percent_diff = sa_diff / surface_areas[0]
                vol_diff = volumes[0] - volumes[1]
                vol_percent_diff = vol_diff / volumes[0]
                deltaG = Free_Energies[0] - Free_Energies[1]

                outfile.write(cavity + "," + method + "," + molecule + ","  + solvent + "," 
                        + str(volumes[0]) + ',' + str(volumes[1]) + ',' + 
                        "{x:.3f}".format( x = vol_diff) + ','
                        + "{x:.3f}".format( x = vol_percent_diff)
                        + ',' + str(surface_areas[0]) + "," + str(surface_areas[1]) + "," 
                        + "{x:.3f}".format( x = sa_diff) + "," 
                        + "{x:.3f}".format( x = sa_percent_diff) + ","
                        + "{x:.3f}\n".format( x = deltaG*627.5095))

            # if it's the 'smd' solvation model, then it's default cavity also has to 
            # be read, which isn't taken care of by the above loop
            if method == 'smd':
                cavity = 'smd'
                surface_areas = []
                volumes = []
                Free_Energies = []
                for type in ['ol','one']:
                    file_name = glob.glob(str('*' + type + "*.smd.gjf.log"))[0]
                    log_file = open(file_name, 'r')
                    file_string = log_file.read()
                    file_array = file_string.split('\n')
                    SA_list = []
                    Vol_list = []
                    for line in file_array:
                        if 'Cavity surface area' in line:
                            elements = line.split()
                            surface_area = float(elements[5])
                            #print("\t\t\t%s" % surface_area)
                            SA_list.append(surface_area)

                        if 'Cavity volume' in line:
                            elements = line.split()
                            volume = float(elements[4])
                            Vol_list.append(volume)

                        if 'G4 Free Energy' in line:
                            elements = line.split('=')
                            free_energy = float(elements[2].lstrip())
                            Free_Energies.append(free_energy)


                    surface_areas.append(SA_list[-1])
                    volumes.append(Vol_list[-1])
                    log_file.close()

                sa_diff = surface_areas[0] - surface_areas[1]
                sa_percent_diff = sa_diff / surface_areas[0]
                vol_diff = volumes[0] - volumes[1]
                vol_percent_diff = vol_diff / volumes[0]
                deltaG = Free_Energies[0] - Free_Energies[1]
                outfile.write(cavity + "," + method + "," + molecule + ","  + solvent + "," 
                        + str(volumes[0]) + ',' + str(volumes[1]) + ','
                        + "{x:.3f}".format( x = vol_diff) + ','
                        + "{x:.3f}".format( x = vol_percent_diff) + ',' 
                        + str(surface_areas[0]) + "," + str(surface_areas[1]) + "," 
                        + "{x:.3f}".format( x = sa_diff) + "," 
                        + "{x:.3f}".format( x = sa_percent_diff) + ","
                        + "{x:.3f}\n".format( x = deltaG*627.5095))

            outfile.write('-' * 75 + '\n')
            os.chdir('../..') # now back in methods directory
        os.chdir('..') # now in solvents directory
    os.chdir(origdir) # now in molecules directory

outfile.close()

# time script finished
stoptime = time()

print("Script {x:s} completed in {y:.2f} seconds.".format( x =
    sys.argv[0].split('/')[-1] , y = stoptime - starttime ))

sys.exit(0)
