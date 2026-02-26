#!/bin/bash

LOGS_FOLDER="/var/log/shell-script"

R="\e[31m"
G="\e[32m"
N="\e[0m"

USERID=$(id -u)

CHECK_ROOT() {
    if [ $USERID -ne 0 ]
    then
     echo -e " $R you are not a root user, switch to root user $N "
     exit 1
    fi
}

VALIDATE() {
    if [ $1 -ne 0 ]
    then
     echo -e " $2 was $R failed $N "
    else
     echo -e " $2 was $G Success $N"
    fi
}
CHECK_ROOT

  for package in $@
   do
    dnf list installed $package
  if [ $? -ne 0 ]
   then
     echo -e " $package $G was not installed, going to install now $N"
     dnf install $package -y
     VALIDATE $? $package
   else
     echo -e " $package $G was already installed nothing to do $N"
   fi
   done

