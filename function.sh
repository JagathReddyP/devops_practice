#!/bin/bash

# -eq equal, -ne not equal, -gt	greater than, -lt less than, -ge greater or equal, -le	less or equal
# -u it only displays user id details not gid or groups id




userid=$(id -u)
echo "userid is $userid"

VALIDATE() {

if [ $1 -ne 0 ]
then
echo "$2 is FAILED"
exit 1
else
echo "$2 is SUCCESS"
fi
}

if [ $userid -ne 0 ]
then
echo "please switch to root user and rerun the program"
exit 1
fi

dnf list installed mysql-server

VALIDATE $?

# if [ $? -ne 0 ]
# then

echo "mysql-server is not installed, installing.... it now"

dnf install mysql-server -y

VALIDATE $?
# if [ $? -ne 0 ]
# then
# echo "mysql-server installation was failed.. check logs"
# exit 1
# else
# echo "mysql-server was successfully installed"
# fi

# else
# echo "my-sql was already installed"
# fi
