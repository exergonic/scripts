#!/home/aubbwc/usr/bin/python3


import os,sys, shutil
import subprocess
from glob import glob
from time import time

starttime = time()

homedir =   os.getcwd()
datafiles = os.path.join(homedir, 'datafiles')
infiles =   os.path.join(datafiles, 'infiles')
slvzmats =  os.path.join(datafiles, 'slvzmats')
cations = ['MMIM', 'EMIM', 'BMIM', 'HMIM', 'OMIM',
            'MPYR', 'EPYR', 'BPYR', 'HPYR', 'OPYR']

possible_anions = ['BF4', 'PF6', 'Cl', 'TFO', 'ACL4', 'ACL7']
cutoffs = ['9A', '12A', '15A']
methods = ['ewald','noewald','SF', '0.1SF', '0.2SF', '0.3SF','SP', 
            '0.1SP','0.2SP', '0.3SP', 'SFG', '0.1DC', '0.2DC',
            '0.3DC','CHARMM']

 
def filesToCopy(cation, anion):
    dummy   =   os.path.join(datafiles,'dummy.z')
    liqpar  =   os.path.join(datafiles,'liqpar')
    liqcmd  =   os.path.join(datafiles,'liqcmd')
    cshfile =   os.path.join(datafiles, 'IL_ewald.csh')
    return [dummy, liqpar, liqcmd, cshfile]

def sed(textToReplace, replacementText, filename):
    filecontents = open(filename, 'r').read()
    newcontents = filecontents.replace(textToReplace, 
                                        replacementText)
    file = open(filename, 'w')
    file.write(newcontents)
    file.close()

# ICUTAS ARRAYS
icutas = {'EMIM':'  0  0  5 17  6 10  0  0',
          'MMIM':'  0  0  6 11  6 10  0  0',
          'BMIM':'  0  0  5 24 11  6 10  0',
          'HMIM':'  0  0  5 30 21 11  6 10',
          'OMIM':'  0  0  5 36 27 11  6 10',
          'BPYR':'  0  0  6 23 17  6  3  0',
          'EPYR':'  0  0  6 17  6  3  0  0',
          'HPYR':'  0  0  6 23 17  6  3  0',
          'MPYR':'  0  0  6 14  6  3  0  0',
          'OPYR':'  0  0  6 23 17  6  3  0',
          }

for cation in cations:
    anions = []
    [ anions.append(anion) for anion in os.listdir(cation) if anion in
            possible_anions ]
    for anion in anions:
        for cutoff in cutoffs:
            for method in methods:
                # CREATE NEW DIRECTORIES AND COPY FILES INTO IT
                pathname = os.path.join(homedir, cation, anion, 
                                         cutoff, method)
                print("\tBeginning %s.%s.%s.%s." %(cation, anion,
                                                cutoff, method))
                os.makedirs(pathname)
                files = filesToCopy(cation, anion)
                [ shutil.copy(file, pathname) for file in files ]
                [ print("\t\t%s copied." % file) for file in files ]
                
                # SET THE CORRECT PATHNAME FOR FILES IN THE NEW DIRECTORY
                dummy   = os.path.join(pathname, files[0].split('/')[-1])
                liqpar  = os.path.join(pathname, files[1].split('/')[-1])
                liqcmd  = os.path.join(pathname, files[2].split('/')[-1])
                cshfile = os.path.join(pathname, files[3].split('/')[-1])
                datadir = os.path.join(homedir, cation, anion,
                                            cutoff, 'datafiles')
                
                # EDIT FILES ACCORDINGLY
                # liqpar: set icutas array and cutoff 
                # anions Cl, NO3, and TFO need - sign in the principal solvent
                if anion == 'Cl' or anion == 'NO3' or anion == 'TFO':
                    sed('ANION', str(anion + '-'), liqpar)
                else:
                    sed('ANION', anion, liqpar)

                sed('icutas', icutas[cation], liqpar)
                sed('XX', cutoff[:-1], liqpar)
                if method == 'ewald':
                    sed('Y', '1', liqpar)
                else:
                    sed('Y', '0', liqpar)

                # csh file 
                cshstring = str(cation +'.'+ anion +'.'+ cutoff +'.' + method)
                sed('TYPE', cshstring, cshfile)
                sed('LOCAL', pathname, cshfile)
                sed('ANION', anion, cshfile)
                sed('DATAFILES', datadir, cshfile)
                if method == 'ewald':
                    sed('METHOD','',cshfile)
                else:
                    sed('METHOD', str('_' + method), cshfile)
                # liqcmd
                sed('ANION', anion, liqcmd)
                if method == 'ewald':
                    sed('METHOD','',liqcmd)
                else:
                    sed('METHOD',str('_' + method), liqcmd)

                # MOVE FILE NAMES TO THOSE SPECIFIED IN PAR AND CMD FILES
                # csh file
                shutil.move(cshfile, os.path.join(pathname, str(cshstring +
                    '.csh')))

                # PRINT DONE WITH CURENT METHOD
                print("\tDone with %s.%s.%s.%s.\n" % (cation, anion, cutoff,
                        method))

                # OPTIONALLY SUBMIT JOB
                if "submit" in sys.argv:
                    currentdir = os.getcwd()
                    os.chdir(pathname)
                    submitcmd = glob('*csh')
                    subprocess.call(["/home/aubbwc/scripts/runboss", submitcmd[0]])
                    os.chdir(currentdir)
                #/end of 'for methods ...' loop
            #/end of 'for cutoff ...' loop
        #/end of 'for anions ...' loop
    #/end of 'for cations ...' loop

stoptime = time()
runtime = stoptime - starttime
print("Script" + sys.argv[0] + " completed in {x:.1f} seconds.".format( x =
    runtime))
sys.exit(0)
