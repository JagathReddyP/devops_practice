#!/bin/bash


# -eq equal, -ne not equal, -gt	greater than, -lt less than, -ge greater or equal, -le	less or equal
# -u it only displays user id details not gid or groups id

userid=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
echo "userid is $userid"

VALIDATE() {
if [ $1 -ne 0 ]
then
echo -e "$2 is  $R FAILED$N"
exit 1
else
echo -e "$2 is  $G SUCCESS$N"
fi
}

if [ $userid -ne 0 ]
then
echo "please switch to root user and rerun the program"
exit 1
fi

dnf list installed git
if [ $? -ne 0 ]
then
echo "git is not installed, installing.... it now"
dnf install git -y
VALIDATE $? git
fi

dnf list installed mysql-server
if [ $? -ne 0 ]
then
echo "mysql-server is not installed, installing.... it now"
dnf install mysql-serverr -y
VALIDATE $? "mysql-server"
fi
