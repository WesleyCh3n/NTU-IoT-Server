#!/bin/bash
##################################################
# Ping the router periodically until ping fails.

ROUTER=10.112.0.1

# Number of consecutive failures to tolerate before rebooting.
MAX_FAIL_COUNT=5

##################################################
# Create timestamp with format "YYYYMMDD_hhmmss"
function timestamp()
{
    date +"%Y%m%d_%H%M%S"
}

##################################################
# Write entry to log file
function log()
{
    echo -e "$(timestamp) $1"
    echo -e "$(timestamp) $1" >> $outfile
}

##################################################
# Create output log file
outfile="/var/log/ping-router.log"
rm -f $outfile
touch $outfile

##################################################
log "--- START"

status=0
count=0
while [[ $count -lt $MAX_FAIL_COUNT ]]; do
    # Ping router:
    #   -c 2 : with a count of 2 packets
    #   -W 5 : wait 5 seconds for response
    #   -q   : Quiet output
    # All output directed to NULL.
    ping $ROUTER -c 2  -W 5 -q > /dev/null
    status=$?
    if [[ $status -eq 0 ]]; then
        log "OK"
        count=0
        sleep 1m  # 1 minute
    else
        (( count++ ))
        log "FAIL #$count"
        # Retry every 10 seconds until MAX_FAIL_COUNT reached
        sleep 10s
    fi
done

##################################################
log "================================================================================"
log "End of kernel message buffer:\n$(dmesg --time-format iso | tail -50)"
log "================================================================================"
log "--- Failure count reached, rebooting"

# Save log file with a different name.
mv -vf $outfile "/var/log/ping-router-failed.log"

reboot

##################################################

