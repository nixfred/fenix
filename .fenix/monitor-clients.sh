#!/bin/bash
# FeNix Multi-Client Monitoring Dashboard

source "$HOME/.fenix/host-manager.sh"
load_fenix_hosts

echo "FeNix Client Status Dashboard"
echo "============================="
echo "Main Host: $FENIX_MAIN_HOST"
echo

# Function to check client status
check_client_status() {
    local client="$1"
    local role="$2"
    
    echo -n "$client ($role): "
    
    # Test SSH connectivity
    if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$client" "echo connected" >/dev/null 2>&1; then
        echo "❌ Offline"
        return 1
    fi
    
    # Get system info
    local info=$(ssh "$client" "
        load_avg=\$(cat /proc/loadavg | cut -d' ' -f1)
        containers=\$(docker ps -q 2>/dev/null | wc -l)
        temp=\$(vcgencmd measure_temp 2>/dev/null | cut -d'=' -f2 | cut -d'.' -f1 || echo 'N/A')
        uptime=\$(uptime -p 2>/dev/null || echo 'unknown')
        echo \"\$load_avg|\$containers|\$temp|\$uptime\"
    " 2>/dev/null)
    
    if [ -n "$info" ]; then
        IFS='|' read -r load containers temp uptime <<< "$info"
        
        # Status indicator based on load
        if (( $(echo "$load > 3.0" | bc -l 2>/dev/null || echo 0) )); then
            status="⚠️  High load"
        elif (( $(echo "$load > 2.0" | bc -l 2>/dev/null || echo 0) )); then
            status="🔶 Medium load"
        else
            status="✅ Online"
        fi
        
        echo "$status | ${containers} containers | Load: ${load} | Temp: ${temp}°C | ${uptime}"
    else
        echo "⚠️  Connected but no data"
    fi
}

# Check all remote clients
for client in $FENIX_REMOTE_HOSTS; do
    role=$(get_host_role "$client")
    check_client_status "$client" "$role"
done

echo
echo "Commands:"
echo "  pp <client>              - Connect to client"
echo "  ./deploy-container.sh    - Deploy containers"
echo "  ./setup-remote-client.sh - Add new client"