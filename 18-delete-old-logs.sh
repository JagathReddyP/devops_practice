#!/bin/bash

#1. which directory
#2. is that directory exists?
#3. find the files
#4. delete them

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

SOURCE_DIR=/home/ec2-user/logs

if [ -d $SOURCE_DIR ]
then
echo -e "$SOURCE_DIR $G Exists $N"
else 
echo "$SOURCE_DIR $R Doesn't Exists $N"
fi

FILES=$(find $SOURCE_DIR -name "*.log" -mtime +14)
echo "Files: $FILES"


while IFS= read -r file #IFS, internal field separator, empty it will ignore while space. -r is for not to ignore specail characters like /
do
echo "deleting $file"
rm -rf $file
done <<< $FILES