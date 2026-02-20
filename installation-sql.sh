#!/bin/bash

# -eq equal, -ne not equal, -gt	greater than, -lt less than, -ge greater or equal, -le	less or equal
# -u it only displays user id details not gid or groups id

# installing app with script
#1. check the user has root access or not
#2. if root access, proceed with the script
#3. otherwise through the error
#4. check already installed or not, if installed tell the user it is already insalled
#5. if not installed, install it
#6. check it is success or not



userid=$(id -u)
echo "userid is $userid"
if [ $userid -ne 0 ]
then
echo "please switch to root user and rerun the program"
exit 1
fi

dnf list installed mysql-server

if [ $? -ne 0 ]
then

echo "mysql-server is not installed, installing.... it now"
dnf install mysql-serverr -y
if [ $? -ne 0 ]
then
echo "mysql-server installation was failed.. check logs"
exit 1
else
echo "mysql-server was successfully installed"
fi

else
echo "my-sql was already installed"
fi




