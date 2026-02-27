#!/bin/bash
# 1> --> redirects only success output
# 2> --> redirects only failure output
# &> --> redirects everything irrespective of success or failure
# >> --> it wont override previous data it appends the existing data ex: &>> , ls -l 2>> output.txt
# tee --> wite logs to multiple destinations


LOGS_FOLDER="/var/log/shell-script"
#SCRIPT_NAME=$(echo "$0"|cut -d "." -f1)  
SCRIPT_NAME=$(basename "$0" .sh)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p "$LOGS_FOLDER"

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

USERID=$(id -u)

CHECK_ROOT() {
    if [ "$USERID" -ne 0 ]
    then
     echo -e " you are not a root user, $R switch to root user $N "|tee -a "$LOG_FILE"
     exit 1
    fi
}

VALIDATE() {
    if [ "$1" -ne 0 ]
    then
     echo -e " $2 installation was $R failed $N "|tee -a "$LOG_FILE"
    else
     echo -e " $2 installation was $G Success $N"|tee -a "$LOG_FILE"
    fi
}
CHECK_ROOT

USAGE(){
echo -e "$Y USAGE : $N sh redirectories.sh package1 package2..."
exit 1
}

echo "script started executing at : $(date)"|tee -a "$LOG_FILE"



#  $# --> no of arguments passed to the script
if [ $# -eq 0 ]
then
 USAGE
 fi

# $@ refers to all arguments paased to the script
  for package in "$@"
   do
    dnf list installed "$package" &>> "$LOG_FILE"
  if [ $? -ne 0 ]
   then
     echo -e " $package $G was not installed, going to install now $N"|tee -a "$LOG_FILE"
     dnf install "$package" -y &>>"$LOG_FILE"
     VALIDATE $? "$package"
   else
     echo -e " $package $Y was already installed nothing to do $N"|tee -a "$LOG_FILE"
   fi
   done

