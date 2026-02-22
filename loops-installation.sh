#!/bin/bash

# -eq equal, -ne not equal, -gt	greater than, -lt less than, -ge greater or equal, -le	less or equal
# -u it only displays user id details not gid or groups id

userid=$(id -u)

check_root(){
if [ $userid -ne 0 ]
then
echo "please switch to root user and rerun the program"
exit 1
fi
}

R="\e[31m"
G="\e[32m"
N="\e[0m"


VALIDATE() {
if [ $1 -ne 0 ]
then
echo -e "$2 is $R FAILED$N"
exit 1
else
echo -e "$2 is $G SUCCESS$N"
fi
}


check_root 

# we use as follows sh loops-installation.sh git mysql-server nginx 
for package in "$@" # $@ refers to all arguments passed to it
do
  dnf list installed $package
if [ $? -ne 0 ]
then
echo  " $package is not installed..installing it now"
dnf install $package -y
VALIDATE $? " installing $package "
else
echo " $package was already installed"
fi
 
done