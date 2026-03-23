#!/usr/bin/bash

# -----------------------------------------
# Production Infoprint Restart Script (AIX)
# -----------------------------------------

# ---------------- Colors ----------------
R="\033[31m"
G="\033[32m"
Y="\033[33m"
N="\033[0m"

# ---------------- Files -----------------
LOGFILE="/tmp/infoprint_restart.log"
LOCKFILE="/tmp/infoprint_restart.lock"

USERID=$(id -u)

# ---------------- Logging ----------------
log() {
    msg="$(date '+%Y-%m-%d %H:%M:%S') $1"
    echo -e "$msg"          # Terminal output
    echo "$msg" >> "$LOGFILE"  # Clean logfile
}

# ---------------- Lock Handling ----------------
if [ -f "$LOCKFILE" ]; then
    pid=$(cat "$LOCKFILE" 2>/dev/null)
    if [ -n "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
        echo "Script already running (PID $pid). Exiting."
        exit 1
    else
        echo "Removing stale lock file"
        rm -f "$LOCKFILE"
    fi
fi

echo $$ > "$LOCKFILE"
trap 'rm -f "$LOCKFILE"; log "Script interrupted"; exit 1' INT TERM
trap 'rm -f "$LOCKFILE"' EXIT

# ---------------- Root Check ----------------
if [ "$USERID" -ne 0 ]; then
    log "${R}ERROR: Must be root user${N}"
    exit 1
fi

# ---------------- Command Check ----------------
for cmd in pdls start_server stop_server; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "${R}ERROR: $cmd not found${N}"
        exit 1
    fi
done

# ---------------- Validation Function ----------------
validate() {
    rc=$1
    msg="$2"
    if [ "$rc" -ne 0 ]; then
        log "${R}$msg FAILED${N}"
        return 1
    else
        log "${G}$msg SUCCESS${N}"
        return 0
    fi
}

# ---------------- Get Server Status ----------------
get_status() {
    srv="$1"
    status=$(pdls -cserv "${srv}:" 2>/dev/null | awk '/server/ {print $2}' | head -1)
    [ -z "$status" ] && echo "DISCONNECTED" || echo "$status"
}

# ---------------- Wait for CONNECTED ----------------
wait_for_connected() {
    srv="$1"
    port="$2"
    max_wait="$3"
    retries="$4"

    waited=0
    total_waited=0
    total_limit=1800  # 30 min safety

    while true; do
        status=$(get_status "$srv")
        if [ "$status" = "CONNECTED" ]; then
            log "${G}$srv CONNECTED${N}"
            return 0
        fi

        sleep 10
        waited=$((waited+10))
        total_waited=$((total_waited+10))

        if [ "$total_waited" -ge "$total_limit" ]; then
            log "${R}FATAL: $srv exceeded max wait limit${N}"
            return 1
        fi

        if [ "$waited" -ge "$max_wait" ]; then
            if [ "$retries" -gt 0 ]; then
                log "${Y}Retrying start for $srv${N}"
                start_server -p "$port" "$srv"
                validate $? "Retry start $srv"
                retries=$((retries-1))
                waited=0
            else
                log "${R}ERROR: $srv failed to CONNECT${N}"
                return 1
            fi
        fi
    done
}

# ---------------- Initialization ----------------
> "$LOGFILE"
log "Starting Infoprint Restart"

servers=(pmc5pdc pmc5pdca pmc5pdcb pmc5pdcc pmc5pdcd pmc5pdce pmc5pdcf pmc5pdcg pmc5pdch pmc5pdci)

declare -A ports=( [pmc5pdc]=6874 [pmc5pdca]=6876 [pmc5pdcb]=6878 [pmc5pdcc]=6880 [pmc5pdcd]=6882 [pmc5pdce]=6884 [pmc5pdcf]=6886 [pmc5pdcg]=6888 [pmc5pdch]=6890 [pmc5pdci]=6892 )

FAILED_SERVERS=()
SUCCESS_SERVERS=()

# ---------------- Core Cleanup ----------------
log "${Y}Cleaning core files${N}"

for srv in "${servers[@]}"; do
    core_file="/var/pd/${srv}/core"
    if [ -f "$core_file" ]; then
        log "Removing core file for $srv"
        rm -f "$core_file"
        validate $? "Core cleanup $srv"
    else
        log "No core file for $srv"
    fi
done

log "-------------------------------------"

# ---------------- Stop Servers ----------------
log "${Y}Stopping servers${N}"

for (( i=${#servers[@]}-1; i>=0; i-- )); do
    srv="${servers[i]}"
    status=$(get_status "$srv")
    if [ "$status" != "DISCONNECTED" ]; then
        log "Stopping $srv ($status)"
        stop_server "$srv"
        validate $? "Stop $srv"
    else
        log "$srv already stopped"
    fi
done

log "-------------------------------------"

# ---------------- Start Servers ----------------
log "${Y}Starting servers${N}"

MAX_WAIT=600
RETRIES=2

for srv in "${servers[@]}"; do
    port="${ports[$srv]}"
    status=$(get_status "$srv")

    if [ "$status" != "CONNECTED" ]; then
        log "Starting $srv on port $port"
        start_server -p "$port" "$srv"
        validate $? "Start $srv"

        log "Waiting for $srv..."
        if wait_for_connected "$srv" "$port" "$MAX_WAIT" "$RETRIES"; then
            SUCCESS_SERVERS+=("$srv")
        else
            FAILED_SERVERS+=("$srv")
            continue
        fi
    else
        log "$srv already CONNECTED"
        SUCCESS_SERVERS+=("$srv")
    fi

    log "$srv running on port $port"
    log "-------------------------------------"
done

# ---------------- Summary ----------------
log "Restart Summary"

log "${G}Successful:${N}"
for s in "${SUCCESS_SERVERS[@]}"; do
    log "  - $s"
done

log "${R}Failed:${N}"
for s in "${FAILED_SERVERS[@]}"; do
    log "  - $s"
done

if [ "${#FAILED_SERVERS[@]}" -ne 0 ]; then
    log "${R}Some servers failed${N}"
    exit 1
else
    log "${G}All servers restarted successfully${N}"
    exit 0
fi