#!/bin/bash

# -----------------------------------------
# Idempotent Infoprint Restart Script (AIX)
# -----------------------------------------

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/infoprint_restart.log"

USERID=$(id -u)

# -----------------------------------------
# Logging Function
# -----------------------------------------
log() {
    msg="$(date '+%Y-%m-%d %H:%M:%S') $1"
    echo "$msg" | tee -a "$LOGFILE"
}

# -----------------------------------------
# Root Validation
# -----------------------------------------
CHECK_ROOT() {
    if [ "$USERID" -ne 0 ]; then
        echo -e "${R}You are not root user. Switch to root.${N}" | tee -a "$LOGFILE"
        exit 1
    fi
}

# -----------------------------------------
# Command Validation
# -----------------------------------------
CHECK_COMMANDS() {

    for cmd in pdls start_server stop_server
    do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${R}$cmd command not found. Exiting.${N}" | tee -a "$LOGFILE"
            exit 1
        fi
    done
}

# -----------------------------------------
# Validation Function
# -----------------------------------------
VALIDATE() {

    if [ "$1" -ne 0 ]; then
        echo -e "$2 ${R}FAILED${N}" | tee -a "$LOGFILE"
        exit 1
    else
        echo -e "$2 ${G}SUCCESS${N}" | tee -a "$LOGFILE"
    fi
}

# -----------------------------------------
# Get Server Status
# -----------------------------------------
GET_STATUS() {

    srv="$1"

    status=$(pdls -cserv "${srv}:" 2>/dev/null | grep server | awk '{print $2}')

    if [ -z "$status" ]; then
        echo "DISCONNECTED"
    else
        echo "$status"
    fi
}

# -----------------------------------------
# Wait for server to CONNECT
# -----------------------------------------
WAIT_FOR_CONNECTED() {

    srv="$1"
    port="$2"
    max_wait="$3"
    retries="$4"
    waited=0

    status=$(GET_STATUS "$srv")

    if [ "$status" = "CONNECTED" ]; then
        log "$srv already CONNECTED"
        return
    fi

    while true
    do
        status=$(GET_STATUS "$srv")

        if [ "$status" = "CONNECTED" ]; then
            log "$srv successfully CONNECTED"
            break
        fi

        sleep 10
        waited=$((waited+10))

        if [ "$waited" -ge "$max_wait" ]; then

            if [ "$retries" -gt 0 ]; then
                echo -e "${Y}Retrying start for $srv...${N}" | tee -a "$LOGFILE"
                start_server -p "$port" "$srv"
                retries=$((retries-1))
                waited=0
            else
                echo -e "${R}ERROR:${N} $srv did not CONNECT after $max_wait seconds" | tee -a "$LOGFILE"
                exit 1
            fi

        fi
    done
}

# -----------------------------------------
# MAIN
# -----------------------------------------

# Fresh log
> "$LOGFILE"

log "Starting Infoprint Restart Script"

CHECK_ROOT
CHECK_COMMANDS

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

# -----------------------------------------
# Core Cleanup
# -----------------------------------------

echo -e "${Y}Cleaning core files...${N}" | tee -a "$LOGFILE"

for srv in "${servers[@]}"
do
    path="/var/pd/${srv}/core"

    if [ -f "$path" ]; then
        log "Deleting core file $path"
        rm -f "$path"
        VALIDATE $? "Removing $path"
    else
        log "No core file found for $srv"
    fi
done

echo "-------------------------------------" | tee -a "$LOGFILE"

# -----------------------------------------
# Stop Servers (Reverse Order)
# -----------------------------------------

echo -e "${Y}Stopping Infoprint servers...${N}" | tee -a "$LOGFILE"

for (( index=${#servers[@]}-1 ; index>=0 ; index-- ))
do

    srv="${servers[index]}"

    status=$(GET_STATUS "$srv")

    if [ "$status" != "DISCONNECTED" ]; then

        log "Stopping $srv (Current Status: $status)"

        stop_server "$srv"

        VALIDATE $? "Stopping $srv"

    else

        log "$srv already DISCONNECTED"

    fi

done

echo "-------------------------------------" | tee -a "$LOGFILE"

# -----------------------------------------
# Start Servers
# -----------------------------------------

echo -e "${Y}Starting Infoprint servers...${N}" | tee -a "$LOGFILE"

PORT=6874
MAX_WAIT=600
RETRIES=2

for srv in "${servers[@]}"
do

    status=$(GET_STATUS "$srv")

    if [ "$status" != "CONNECTED" ]; then

        log "Starting $srv on port $PORT"

        start_server -p "$PORT" "$srv"

        VALIDATE $? "Starting $srv"

        log "Waiting for $srv to CONNECT..."

        WAIT_FOR_CONNECTED "$srv" "$PORT" "$MAX_WAIT" "$RETRIES"

    else

        log "$srv already CONNECTED"

    fi

    echo -e "$srv started successfully on port ${G}$PORT${N}" | tee -a "$LOGFILE"

    PORT=$((PORT+2))

    echo "-------------------------------------" | tee -a "$LOGFILE"

done

log "All Infoprint servers restarted successfully"