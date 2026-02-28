#!/bin/bash

number=$1

echo "given number is: $number"

# -eq equal, -ne not equal, -gt	greater than, -lt less than, -ge greater or equal, -le	less or equal

if [ $number -gt 20 ] 
then
    echo " $number is greater than 20"
else
    echo " $number is less than 20"
fi
