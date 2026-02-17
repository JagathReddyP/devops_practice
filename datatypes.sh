#!/bin/bash

#Give two numbers
#We will do +addition, -substraction, *multiples, /division and %remainder of two numbers

Number1=$1
Number2=$2

add=$(($Number1+$Number2))
echo "Addition of $Number1 plus $Number2 is : $add "

substract=$(($Number1-$Number2))
echo "substraction of $Number1 minus $Number2 is : $substract "

multiply=$(($Number1*$Number2))
echo "multiplication of $Number1 multiple by $Number2 is : $multiply "

divide=$(($Number1/$Number2))
echo "division of $Number1 divided by $Number2 is : $divide "

remainder=$(($Number1/$Number2))
echo "remainder of $Number1 % $Number2 is : $remainder "