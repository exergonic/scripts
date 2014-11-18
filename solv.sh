#!/bin/bash
# solve a set of two linear equations
# assumes from y=mx + b

# get equations
read f1
read f2

# remove everything after '="
y1="${f1#*=}"
y2="${f2#*=}"


# first term (mx)
m1=${y1%[\+\-]*}
m2=${y2%[\+\-]*}


# constant in first term (m)
c1=${m1%x}
c2=${m2%x}

# no constant before x means c=1
[[ $c1 == "" ]] && c1=1
[[ $c2 == "" ]] && c2=1


# everything after first term (operator,b)
z1=${y1#$m1}
z2=${y2#$m2}


# the operators
op1=${z1%%[0-9]*}
op2=${z2%%[0-9]*}

# b
b1=${z1#[\+\-]}
b2=${z2#[\+\-]}


# S O L V E --------------------------------------

# 		y1 = c1*x(op1)b1
# 		y2 = c2*x(op2)b2
#
# 		c1*x(op1)b1 = c2*x(op2)b2
#
# 		c1*x = c2*x(op2)b2(op1)(-1*b1)
#
# 		c1*x-(c2x) = (op2)(b2)(op1)(-1*b1)
#
# 		x(c1-c2) = ...
# 		x = (op2)(b2)(op1(-1*b1)/(c1-c2)
#
# 		y = c1*x(op1)b1


[[ $op2 == "+" ]] && op2=""
x=$(echo "scale=2; (($op2$b2)$op1(-1*$b1))/($c1-($c2))" | bc)
y=$(echo "scale=2; ($c1*$x)$op1($b1)" | bc)

#-------------------------------------------------


echo "("$x","$y")"

exit 0
