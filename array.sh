#!/bin/bash
#array is list of storing elements on a single variable
# name must be on ""
#index starts with 0, size is 5
fruits=("apple" "orange" "banana" "mango" "kiwi")
#to print particular fruit details give its index number index number starts from 0
echo "first fruit is: ${fruits[0]}"
echo "third fruit is: ${fruits[2]}"
# To print all the fruits
echo "List of fruits available: ${fruits[@]}"