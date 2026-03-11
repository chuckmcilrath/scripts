#!/bin/bash 
# WireGuard Connection Monitor 
# Checks if the 'dcm' interface connection is stale for more than 5 minutes 
# and refreshes it if necessary 

# wget -O dcmrefresh.sh https://raw.githubusercontent.com/chuckmcilrath/scripts/refs/heads/main/dcmrefresh.sh && chmod +x dcmrefresh.sh && (crontab -l; echo "*/15 * * * * /root/dcmrefresh.sh >/dev/null 2>&1") | crontab -


INTERFACE="dcm" 
STALE_THRESHOLD=300  # 5 minutes in seconds 
LOG_FILE="/var/log/dcm-wg-monitor.log" 
MAX_LOG_SIZE=1048576  # 1MB in bytes 
MAX_LOG_FILES=5  # Keep 5 rotated log files 

# Function to rotate logs if they get too large 
rotate_logs() { 
    if [ ! -f "$LOG_FILE" ]; then 
        return 0 
    fi
    local log_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null)
    if [ "$log_size" -gt "$MAX_LOG_SIZE" ]; then
        # Rotate existing logs
        for i in $(seq $((MAX_LOG_FILES - 1)) -1 1); do
            if [ -f "${LOG_FILE}.${i}" ]; then
                mv "${LOG_FILE}.${i}" "${LOG_FILE}.$((i + 1))"
            fi
        done
        # Move current log to .1
        mv "$LOG_FILE" "${LOG_FILE}.1"
        # Create new empty log
        touch "$LOG_FILE"
    fi
}
# Function to log messages
log_message() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}
# Function to get the latest handshake time in seconds ago
get_handshake_age() {
    local output=$(wg show "$INTERFACE" latest-handshakes 2>/dev/null)
    if [ -z "$output" ]; then
        log_message "ERROR: Could not get handshake info for interface $INTERFACE"
        return 1
    fi
    # Extract the timestamp (second column) 
    local last_handshake=$(echo "$output" | awk '{print $2}')
    if [ -z "$last_handshake" ] || [ "$last_handshake" = "0" ]; then
        # No handshake has occurred yet
        echo "999999"
        return 0
    fi
    local current_time=$(date +%s)
    local age=$((current_time - last_handshake))
    echo "$age"
    return 0
}
# Function to refresh the WireGuard connection
refresh_connection() {
    log_message "Connection stale for more than 5 minutes. Refreshing..."
    # Restart the service
    systemctl restart wg-quick@"$INTERFACE"
    if [ $? -eq 0 ]; then
        log_message "Interface $INTERFACE refreshed successfully"
    else
        log_message "ERROR: Failed to refresh interface $INTERFACE" 
        return 1
    fi
}
# Main logic
# Rotate logs if needed
rotate_logs
log_message "Checking WireGuard interface: $INTERFACE"
# Check if interface exists
if ! wg show "$INTERFACE" &>/dev/null; then
    log_message "ERROR: WireGuard interface '$INTERFACE' not found"
    log_message "Starting the '$INTERFACE' interface"
    systemctl start wg-quick@dcm
    exit 1
fi
# Get handshake age
handshake_age=$(get_handshake_age)
if [ $? -ne 0 ]; then
    exit 1
fi
log_message "Last handshake was $handshake_age seconds ago"
# Check if connection is stale
if [ "$handshake_age" -gt "$STALE_THRESHOLD" ]; then
    refresh_connection
else
    log_message "Connection is active (handshake within last 5 minutes)"
fi
exit 0
