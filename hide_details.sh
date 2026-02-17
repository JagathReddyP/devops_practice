#!/bin/bash
#To hide password details while entering on terminal
# -s was used to hide what you entered on terminal
# read command was used to take inputs on runtime 
echo "enter your name:"
read username
echo "username entered was:$username"
echo "please enter your password:"
read -s password
echo "password you entered was :$password"  if you want you see what password you entered
#you can comment above line. Just added to see password is taking or not