#!/bin/bash

# installing app with script
#1. check the user has root access or not
#2. if root access, proceed with the script
#3. otherwise through the error
#4. check already installed or not, if installed tell the user it is already insalled
#5. if not installed, install it
#6. check it is success or not

# -u it only displays user id details not gid or groups id

userid=$(id -u)
echo "userid is $userid"
if [ $userid -ne 0 ]
then
echo "please switch to root user and rerun the program"
exit 1
fi

# else

# echo "installing mysql-server"
# dnf install mysql-server -y

# fi


