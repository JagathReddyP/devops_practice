#!/bin/bash

# ----------------------------
# Idempotent Infoprint Restart Script (AIX)
# ----------------------------

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

# ----------------------------
# Functions
# ----------------------------
CHECK_ROOT() {
    if [ "$USERID" -ne 0 ]; then
        echo -e "You are not root user ${R}Switch to root${N}"
        exit 1
    fi
}

VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 ${R}FAILED${N}"
        exit 1
    else
        echo -e "$2 ${G}SUCCESS${N}"
    fi
}

GET_STATUS() {
    local srv=$1
    pdls -cserv $srv: 2>/dev/null | awk '{print $2}'
}

WAIT_FOR_CONNECTED() {
    local srv=$1
    local max_wait=$2   # seconds
    local retries=$3
    local waited=0

    # Skip waiting if server is already CONNECTED
    local status
    status=$(GET_STATUS $srv)
    if [ "$status" == "CONNECTED" ]; then
        echo "$srv is already CONNECTED"
        return
    fi

    while true; do
        status=$(GET_STATUS $srv)
        if [ "$status" == "CONNECTED" ]; then
            break
        fi

        sleep 10
        waited=$((waited+10))

        if [ "$waited" -ge "$max_wait" ]; then
            if [ $retries -gt 0 ]; then
                echo -e "${Y}Retrying $srv...${N}"
                start_server -p $PORT $srv
                retries=$((retries-1))
                waited=0
            else
                echo -e "${R}ERROR:${N} $srv did not connect after $max_wait seconds and retries exhausted!"
                exit 1
            fi
        fi
    done
}

# ----------------------------
# Main
# ----------------------------
CHECK_ROOT

# List of servers
servers=(
pmc5pdc
pmc5pdca
pmc5pdcb
pmc5pdcc
pmc5pdcd
pmc5pdce
pmc5pdcf
pmc5pdcg
pmc5pdch
pmc5pdci
)

# Core file cleanup
echo -e "${Y}Removing core files...${N}"
for srv in "${servers[@]}"; do
    path="/var/pd/${srv}/core"
    if [ -f "$path" ]; then
        echo "Deleting core file: $path"
        rm -f "$path"
        VALIDATE $? "Deleting $path"
    else
        echo "No core file found at $path"
    fi
done

# Stop servers in reverse order if not already DISCONNECTED
echo -e "${Y}Stopping Infoprint servers in reverse order...${N}"
for (( index=${#servers[@]}-1 ; index>=0 ; index-- )); do
    srv=${servers[index]}
    status=$(GET_STATUS $srv)
    if [ "$status" != "DISCONNECTED" ]; then
        echo "Stopping $srv (current status: $status)"
        stop_server $srv
        VALIDATE $? "Stopping $srv"
    else
        echo "$srv is already DISCONNECTED"
    fi
done

# Start servers in order, only if not already CONNECTED
echo -e "${Y}Starting Infoprint servers...${N}"
PORT=6874
MAX_WAIT=600   # seconds
RETRIES=2      # retry attempts per server

for srv in "${servers[@]}"; do
    status=$(GET_STATUS $srv)
    if [ "$status" != "CONNECTED" ]; then
        echo "Starting $srv on port $PORT"
        start_server -p $PORT $srv
        VALIDATE $? "Starting $srv"
        echo "Waiting for $srv to become CONNECTED..."
        WAIT_FOR_CONNECTED $srv $MAX_WAIT $RETRIES
    else
        echo "$srv is already CONNECTED"
    fi
    echo -e "$srv started successfully on port ${G}$PORT${N}"
    PORT=$((PORT+2))
done

echo -e "${G}All Infoprint servers restarted successfully${N}"