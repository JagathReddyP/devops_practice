#!/bin/bash

number=$1

echo "given number is: $number"

if [ $number -gt 20 ] 
then
    echo " $number is greater than 20"
else
    echo " $number is less than 20"
fi
