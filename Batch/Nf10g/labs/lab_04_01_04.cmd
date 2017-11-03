#!/bin/ksh 
users=8
x=1
y=$users
UNPW="addm/addm"

while [ $x -le $y ]
do
    sqlplus -s $UNPW @lab_04_01_04.sql &
    x=`expr $x + 1`
done
