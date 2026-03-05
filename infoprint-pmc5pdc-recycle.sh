#!/bin/bash

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
     echo -e " $2  was $R failed $N "
     exit 1
    else
     echo -e " $2  was $G Success $N"
    fi
}
CHECK_ROOT

paths=(
"/var/pd/pmc5pdc/core"
"/var/pd/pmc5pdca/core"
"/var/pd/pmc5pdcb/core"
"/var/pd/pmc5pdcc/core"
"/var/pd/pmc5pdcd/core"
"/var/pd/pmc5pdce/core"
"/var/pd/pmc5pdcf/core"
"/var/pd/pmc5pdcg/core"
"/var/pd/pmc5pdch/core"
"/var/pd/pmc5pdci/core"
)

for path in "${paths[@]}";
do
if [ -f "$path" ]
then 
echo "deleting core file on: $path"
rm -f $path
VALIDATE $? "$path"
else
echo " No core file to delete on $path"
fi
done

#pdls -cserv *:
