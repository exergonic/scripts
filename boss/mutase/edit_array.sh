#! /usr/tcsh -fe
# Automate the gas-phase optimizations and directory creation

# Set variables for pmfzmat optimization
# FEPvalues = array containing all variables
# startFEP = beginning FEP value
# endFEP = ending FEP value
set FEPvalues = (1.40 1.42 1.44 1.46 1.48 1.50 1.52 1.54 \
                 1.56 1.58 1.60 1.62 1.64 1.66 1.68 1.70 \
                 1.72 1.74 1.76 1.78 1.80 1.82 1.84 1.86 \
                 1.88 1.90)

set startFEP = 2
set endFEP = 3

# Copy starting dir (1.85-1.87) into new dir
@ oldstartFEP = $startFEP - 1
@ oldendFEP = $endFEP - 1
set olddir = $FEPvalues[$oldstartFEP]-$FEPvalues[$oldendFEP]
set newdir = $FEPvalues[$startFEP]-$FEPvalues[$endFEP]
cp -r $olddir $newdir

foreach window (1.42-1.44 1.44-1.46 1.46-1.48 1.48-1.50 1.50-1.52 1.52-1.54 1.54-1.56 \
                1.56-1.58 1.58-1.60 1.60-1.62 1.62-1.64 1.64-1.66 1.66-1.68 1.68-1.70 1.70-1.72 \
                1.72-1.74 1.74-1.76 1.76-1.78 1.78-1.80 1.80-1.82 1.82-1.84 1.84-1.86 1.86-1.88 \
                1.88-1.90)
        cd $window

# Remove files from previous run
          rm *.e* *.o* *.gz log

# Copy pmfzmat from previous run and update with startnew and endnew array values.
          cp ../pmfzmat .

# Update pmfzmat
# x.xx = starting FEP value
# y.yy = ending FEP value
         sed -i "16s/x.xx/$FEPvalues[$startFEP]/g" pmfzmat
         sed -i "37s/y.yy/$FEPvalues[$endFEP]/g" pmfzmat

# Optimize the pmfzmat
         pdg
         mv sum pmfzmat
         pdg
         mv sum pmfzmat

# Copy the new pmfzmat to previous dir and change back variables
         cp pmfzmat ../.
         sed -i "16s/$FEPvalues[$startFEP]/x.xx/g" ../pmfzmat
         sed -i "37s/$FEPvalues[$endFEP]/y.yy/g" ../pmfzmat
         
# Update counters
         @ startFEP++
         @ endFEP++

# Update the dir for queue submission
         mv OC$olddir'.csh' OC$newdir'.csh'
         sed -i "9s/$olddir/$newdir/g" OC*
         sed -i "10s/$olddir/$newdir/g" OC*
         q -i OC* 

        cd ../

# Copy current dir into new dir
        @ oldstartFEP = $startFEP - 1
        @ oldendFEP = $endFEP - 1
        set olddir = $FEPvalues[$oldstartFEP]-$FEPvalues[$oldendFEP]
        set newdir = $FEPvalues[$startFEP]-$FEPvalues[$endFEP]
        cp -r $olddir $newdir

end

exit
