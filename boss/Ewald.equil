#!/home/aubbwc/usr/bin/python3

# ABOUT-----------------------------------------------------------------------
# setting up jobs for Ewald alternative calculations.
# CATIONS = 
#   Imidazolium based:  MMIM, EMIM, BMIM, HMIM, OMIM   
#   Pyridinum based:    MPYR, EPYR, BPYR, HPYR, OPYR 
# ANIONS =
#   BF4, PF6, Cl, AlCl4, Al2Cl4, NO3, TfO
# 
# Going to have different values for solvent-solvent cutoffs:
#   9A, 12A, 15A
#
# Alternative methods to Ewald summations:
#   Shifted Force (SF)      : may scale by 0.1, 0.2, 0.3
#   Shifted Potential (SP)  : may also scale
#   Shifted Force Gradient (SFG)
#   (DC)
#   CHARMM
#-------------------------------------------------------------------------------   

import os,sys, shutil
import subprocess
from glob import glob
from time import time

starttime = time()

# important file paths
homedir =   os.getcwd()
datafiles = os.path.join(homedir, 'datafiles')
infiles =   os.path.join(datafiles, 'infiles')
slvzmats =  os.path.join(datafiles, 'slvzmats')

# list of cations
imid_cations = ['MMIM', 'EMIM', 'BMIM', 'HMIM', 'OMIM']
pyr_cations =  ['MPYR', 'EPYR', 'BPYR', 'HPYR', 'OPYR']

# NOTE: OMIM and OPYR do not have infiles for ACL's.
# NOTE: BMIM_ACL, EMIM_ACL, and HMIM_ACL are cases which need to be handled
# differently.  The OPLS_IL.par file must be changed.

# methods, scaling factors, cutoffs
methods = ['EWALD_equil']
#,'NOEWALD','SF', 'SF_0.1', 'SF_0.2', 'SF_0.3','SP', 'SP_0.1','SP_0.2', 'SP_0.3', 'SFG', 'DC', 'CHARMM']

cutoffs = ['9A', '12A', '15A']

def filesToCopy(cation, anion):

    infile  =   glob(str( infiles + '/' + cation + '+' + anion + '-'))[0]
    dummy   =   os.path.join(datafiles,'dummy.z')
    liqpar  =   os.path.join(datafiles,'liqpar')
    liqcmd  =   os.path.join(datafiles,'liqcmd')
    # need to handle (EMIM|BMIM|HMIM) + ACLs appropriately
    liqzmat =   glob(str(slvzmats + '/' + cation + '_liqzmat'))[0]
    if cation == 'EMIM' or cation == 'BMIM' or cation == 'HMIM':
        if anion == 'ACL4' or anion == 'ACL7':
            liqzmat = glob(str(slvzmats +'/'+ cation +'-ACL_liqzmat'))[0]

    cshfile =   os.path.join(datafiles, 'IL_ewald.csh')
    ILpar   =   os.path.join(datafiles, 'IL-OPLS.par')
    ILsb    =   os.path.join(datafiles, 'IL-OPLS.sb')

    return [infile, dummy, liqpar, liqcmd, liqzmat, cshfile, ILpar, ILsb]

def sed(textToReplace, replacementText, filename):
    filecontents = open(filename, 'r').read()
    newcontents = filecontents.replace(textToReplace, replacementText)
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

for cation in pyr_cations:
    # list of anions
    anions = ['BF4', 'PF6', 'Cl', 'NO3', 'TFO', 'ACL4', 'ACL7']

    if cation == 'OMIM' or cation == 'OPYR':
        # cations OMIM and OPYR do not have ACL anions associated with them
        anions = ['BF4', 'PF6', 'Cl', 'TFO']
    if cation == 'HPYR' or cation == 'OPYR':
        anions = ['BF4', 'PF6', 'Cl']

    for anion in anions:
        for cutoff in cutoffs:
            for method in methods:
                pathname = os.path.join(homedir, cation, anion, cutoff, method)
                print("\tBeginning %s.%s.%s.%s." %(cation, anion, cutoff,
                    method))
                os.makedirs(pathname)
                #copy all files into relevant directory
                files = filesToCopy(cation,anion)
                [ shutil.copy(file, pathname) for file in files ]
                [ print("\t\t%s copied." % file) for file in files ]

                # set the correct pathname for files
                infile  = os.path.join(pathname, files[0].split('/')[-1])
                dummy   = os.path.join(pathname, files[1].split('/')[-1])
                liqpar  = os.path.join(pathname, files[2].split('/')[-1])
                liqcmd  = os.path.join(pathname, files[3].split('/')[-1])
                liqzmat = os.path.join(pathname, files[4].split('/')[-1])
                cshfile = os.path.join(pathname, files[5].split('/')[-1])
                ILpar   = os.path.join(pathname, files[6].split('/')[-1])
                ILsb    = os.path.join(pathname, files[7].split('/')[-1])

                # edit files accordingly
                # liqpar: set icutas array and cutoff 
                # anions Cl, NO3, and TFO need - sign in the principal solvent
                if anion == 'Cl' or anion == 'NO3' or anion == 'TFO':
                    sed('ANION', str(anion + '-'), liqpar)
                else:
                    sed('ANION', anion, liqpar)

                sed('icutas', icutas[cation], liqpar)
                sed('XX', cutoff[:-1], liqpar)
                # csh file 
                cshstring = str(cation +'.'+ anion +'.'+ cutoff +'.' + method)
                sed('TYPE', cshstring, cshfile)
                sed('LOCAL', pathname, cshfile)
                sed('ANION', anion, cshfile)
                # liqcmd
                sed('ANION', anion, liqcmd)

                # move file names to those specified in par and cmd files
                # csh file
                shutil.move(cshfile, os.path.join(pathname, str(cshstring +
                    '.csh')))
                #infile
                shutil.move(infile, os.path.join(pathname, 'liqin'))
                # slvzmat
                shutil.move(liqzmat, os.path.join(pathname, 'liqzmat'))

                # OMIM and OPYR with ACL must have IL_OPLS.par params edited
                if cation == 'EMIM' or cation == 'BMIM ' or cation == 'HMIM':
                    if anion == 'ACL4' or anion == 'ACL7':
                        sed('2711', '2811', ILpar)
                        sed('2712', '2812', ILpar)

                print("\tDone with %s.%s.%s.%s.\n" % (cation, anion, cutoff,
                        method))
                if "submit" in sys.argv:
                    currentdir = os.getcwd()
                    os.chdir(pathname)
                    submitcmd = glob('*csh')
                    subprocess.call(["/home/aubbwc/scripts/runboss", submitcmd[0]])
                    os.chdir(currentdir)
                    

stoptime = time()
runtime = stoptime - starttime
print("Script" + sys.argv[0] + " completed in {x:.1f} seconds.".format( x =
    runtime))
sys.exit(0)
