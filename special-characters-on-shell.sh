#!/bin/bash
#Types of special characters on shell scripting and their usage"
# 1) Special character is: $@ - it will display all variables given to the script

A=$1
B=$2
C=$3
D=$4
echo "Given variables are $A,$B,$C,$D"

echo "Total variables provided to the script"
echo "$@"

# 2)Special character: $# - It will give you count of variables which you passed to the script
echo "Total count of varaibles passed to the script: $#"

# 3)Special character: $0 - If you want to know which script you are currently running
echo "current executed script file name - $0"

# 4)Special character $pwd -To execute present working directory on script
echo "current working directory :$pwd "

# 5)Special character $HOME - Current user home directory
echo "current user home directory: $HOME"

# 6)Special character: $$ - To know process ID of script you are currently running
echo "PID of current script: $$"

# 7)Special character: $? - To check success status of previous command"
echo "status of previous command: $?"
echo "0 means success 1to127 means failure"

# 8)Special character: $! - To get PID of last background command"
sleep 30&
echo "PID of last background command: $!"