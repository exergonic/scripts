#!/bin/csh
#
# The purpose of this script is to calculate either density
# in g/cm^3 from molecular volume in ang^3 or the reverse.
# The molwt must be entered for the calculation to work.
# Only one of either density or volume must additionally
# be entered.
#
# Written:       12/16/94
# Last updated:  02/16/95
# Author:        David S. Maxwell
#
#  Note:  the following line is needed in order to
#         circumvent local aliases of 'bc'. One could
#         also use the "-f" flag to the /bin/csh above,
#         but that would also prevent user additions
#         to the path.
#
unalias bc >& /dev/null


if ($#argv <= 0) then
   echo "Usage: densvol [-h] [-d density] [-m molwt] [-v volume]"
   echo "(see densvol -h for further help)"
   exit(-1)
endif

unset d h m v
while ($#argv > 0)
   switch ($argv[1])
      case -d:
         set d
         set density = $argv[2]
         shift argv
         breaksw
      case help:
         set h
         breaksw
      case -h:
         set h
         breaksw
      case -m:
         set m
         set molwt = $argv[2]
         shift argv
         breaksw
      case -v:
         set v 
         set volume = $argv[2]
         shift argv
         breaksw
      case -*:
         echo "unknown flag ignored ..."
         breaksw
      default:
         breaksw
   endsw
   shift argv
end

if ($?h) then
   echo " "
   echo "C-Script:  densvol"
   echo "Usage: densvol [-h] [-d density] [-m molwt] [-v volume]"
   echo " "
   echo "Written:       12/16/94"
   echo "Last updated:  02/16/95"
   echo "Author:        David S. Maxwell"
   echo " "
   echo "The purpose of this script is to calculate either density"
   echo "in g/cm^3 from molecular volume in ang^3 or the reverse."
   echo "The molwt must be entered for the calculation to work."
   echo "Only one of either density or volume must additionally"
   echo "be entered."
   exit(-1)
endif

if (! $?m) then
   echo "Please specify the molecular weight..."
   exit 1
endif

if ($?d && $?v) then
   echo "You can only specify either density or volume..."
   exit 1
endif

if ($?v) then
   echo "Mol. wt. (g/mol) = " $molwt
   echo "Volume (ang^3)  = " $volume
   set density = `echo "scale=6; ${molwt}/${volume}*1.660600" | bc`
   echo "=> Density (g/cm^3) = " $density
   exit 1
endif

if ($?d) then
   echo "Mol. wt. (g/mol) = " $molwt
   set volume = `echo "scale=6; ${molwt}/${density}*1.660600" | bc`
   echo "=> Volume (ang^3)  = " $volume
   echo "Density (g/cm^3) = " $density
   exit 1
endif


