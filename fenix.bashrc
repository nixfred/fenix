# Fenix - Ephemeral Linux Containers
# Source from ~/.config/fenix/fenix.bashrc (synced via Syncthing)

FENIX_HOST="${FENIX_HOST:-box}"
_FENIX_DB="/home/pi/.local/bin/distrobox"
_FENIX_TIMEOUT=5
unalias f k fx fl fe fxq finfo 2>/dev/null

# Colors
_C_GREEN='\033[0;32m'
_C_RED='\033[0;31m'
_C_YELLOW='\033[0;33m'
_C_BLUE='\033[0;34m'
_C_RESET='\033[0m'

# Run on box (locally or via SSH with timeout)
_fenix() {
    if [[ "$(hostname)" == "$FENIX_HOST" ]]; then
        eval "$1"
    else
        ssh -t -o ConnectTimeout=$_FENIX_TIMEOUT "$FENIX_HOST" "$1" 2>/dev/null || {
            echo -e "${_C_RED}Error: Cannot connect to $FENIX_HOST (timeout ${_FENIX_TIMEOUT}s)${_C_RESET}"
            return 1
        }
    fi
}

# Run on box without TTY (for parsing output)
_fenix_q() {
    if [[ "$(hostname)" == "$FENIX_HOST" ]]; then
        eval "$1"
    else
        ssh -o ConnectTimeout=$_FENIX_TIMEOUT "$FENIX_HOST" "$1" 2>/dev/null || return 1
    fi
}

# Check if container exists (matches NAME column only, not IMAGE)
_fenix_exists() {
    _fenix_q "$_FENIX_DB list" 2>/dev/null | awk -F'|' 'NR>1 {gsub(/^ +| +$/, "", $2); print $2}' | grep -qx "$1"
}

# Get container names for completion
_fenix_containers() {
    _fenix_q "$_FENIX_DB list" 2>/dev/null | awk -F'|' 'NR>1 {gsub(/^ +| +$/, "", $2); print $2}'
}

# Find next available SSH port (2201-2299)
_fenix_next_port() {
    local used_ports=$(_fenix_q "ss -tln | grep -oP ':220[0-9]|:22[1-9][0-9]' | tr -d ':' | sort -u" 2>/dev/null)
    for port in $(seq 2201 2299); do
        echo "$used_ports" | grep -qx "$port" || { echo "$port"; return; }
    done
    echo "2201"  # fallback
}

# Setup SSH in container (called after creation)
_fenix_setup_ssh() {
    local name="$1"
    local port=$(_fenix_next_port)
    echo "Setting up SSH on port $port..."
    _fenix_q "docker exec '$name' bash -c '
        apt-get update -qq &&
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openssh-server >/dev/null 2>&1 &&
        sed -i \"s/^#Port 22\$/Port $port/\" /etc/ssh/sshd_config &&
        sed -i \"s/^Port 22\$/Port $port/\" /etc/ssh/sshd_config &&
        mkdir -p /run/sshd &&
        /usr/sbin/sshd
    '" 2>/dev/null && echo -e "${_C_GREEN}SSH ready: ssh -p $port $FENIX_HOST${_C_RESET}"
}

# f [name] - Ubuntu container
f() {
    [[ -z "$1" ]] && { fl; return; }
    local is_new=0
    _fenix_exists "$1" || {
        is_new=1
        echo "Creating $1..."
        _fenix "touch /tmp/.nopasswd; $_FENIX_DB create -i ubuntu:24.04 -n '$1' --home /home/pi --hostname '$1' --yes --volume /tmp/.nopasswd:/run/.nopasswd:ro"
        # First enter to initialize container
        _fenix_q "$_FENIX_DB enter '$1' -- true" 2>/dev/null
        _fenix_setup_ssh "$1"
    }
    _fenix "$_FENIX_DB enter $1"
}

# k [name] - Kali container
k() {
    [[ -z "$1" ]] && { fl; return; }
    _fenix_exists "$1" || {
        echo "Creating $1..."
        _fenix "touch /tmp/.nopasswd; $_FENIX_DB create -i docker.io/kalilinux/kali-last-release -n '$1' --home /home/pi --hostname '$1' --yes --volume /tmp/.nopasswd:/run/.nopasswd:ro"
        # First enter to initialize container
        _fenix_q "$_FENIX_DB enter '$1' -- true" 2>/dev/null
        _fenix_setup_ssh "$1"
    }
    _fenix "$_FENIX_DB enter $1"
}

# fx [name] - Destroy container (interactive)
fx() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Containers:"
        fl
        echo ""
        read -p "Destroy: " name
        [[ -z "$name" ]] && return
    fi
    read -p "Destroy $name? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] && _fenix "$_FENIX_DB rm -f $name" && echo "Done."
}

# fe [name] [cmd...] - Execute command in container (non-interactive)
fe() {
    local name="$1"
    [[ -z "$name" ]] && { echo "Usage: fe <container> <command...>"; return 1; }
    shift
    [[ $# -eq 0 ]] && { echo "Usage: fe <container> <command...>"; return 1; }
    _fenix_exists "$name" || {
        echo "Error: container '$name' does not exist. Create with: f $name"
        return 1
    }
    _fenix "$_FENIX_DB enter $name -- $*"
}

# fl - List containers with color
fl() {
    local output
    output=$(_fenix_q "$_FENIX_DB list" 2>/dev/null) || return 1
    echo "$output" | while IFS= read -r line; do
        if [[ "$line" == *"| Up "* ]]; then
            echo -e "${_C_GREEN}${line}${_C_RESET}"
        elif [[ "$line" == *"| Exited"* ]] || [[ "$line" == *"| Created"* ]]; then
            echo -e "${_C_YELLOW}${line}${_C_RESET}"
        elif [[ "$line" == "ID"* ]]; then
            echo -e "${_C_BLUE}${line}${_C_RESET}"
        else
            echo "$line"
        fi
    done
}

# finfo [name] - Container info
finfo() {
    [[ -z "$1" ]] && { echo "Usage: finfo <container>"; return 1; }
    _fenix_exists "$1" || {
        echo "Error: container '$1' does not exist"
        return 1
    }
    local info
    info=$(_fenix_q "docker inspect '$1' --format '{{.Name}}|{{.State.Status}}|{{.State.StartedAt}}|{{.Config.Image}}'" 2>/dev/null)
    local name=$(echo "$info" | cut -d'|' -f1 | tr -d '/')
    local status=$(echo "$info" | cut -d'|' -f2)
    local started=$(echo "$info" | cut -d'|' -f3 | cut -dT -f1)
    local image=$(echo "$info" | cut -d'|' -f4)

    # Check for container's own SSH (must be on non-22 port since host uses 22)
    local sshport=""
    if [[ "$status" == "running" ]]; then
        # Get port from container's sshd_config (if exists and not port 22)
        sshport=$(_fenix_q "docker exec '$1' grep -oP '^Port \\K[0-9]+' /etc/ssh/sshd_config 2>/dev/null" 2>/dev/null)
        # Only show if container has custom port (not 22, which is host's)
        [[ "$sshport" == "22" || -z "$sshport" ]] && sshport=""
    fi

    echo -e "${_C_BLUE}Container:${_C_RESET} $name"
    if [[ "$status" == "running" ]]; then
        echo -e "${_C_BLUE}Status:${_C_RESET}    ${_C_GREEN}$status${_C_RESET}"
    else
        echo -e "${_C_BLUE}Status:${_C_RESET}    ${_C_YELLOW}$status${_C_RESET}"
    fi
    echo -e "${_C_BLUE}Started:${_C_RESET}   $started"
    echo -e "${_C_BLUE}Image:${_C_RESET}     $image"
    echo -e "${_C_BLUE}Network:${_C_RESET}   host"
    if [[ -n "$sshport" ]]; then
        echo -e "${_C_BLUE}SSH:${_C_RESET}       ${_C_GREEN}port $sshport${_C_RESET} (ssh -p $sshport $FENIX_HOST)"
    else
        echo -e "${_C_BLUE}SSH:${_C_RESET}       ${_C_YELLOW}not running${_C_RESET}"
    fi
}

# fssh [name] - SSH into container
fssh() {
    [[ -z "$1" ]] && { echo "Usage: fssh <container>"; return 1; }
    _fenix_exists "$1" || {
        echo "Error: container '$1' does not exist"
        return 1
    }
    local port=$(_fenix_q "docker exec '$1' grep -oP '^Port \\K[0-9]+' /etc/ssh/sshd_config 2>/dev/null" 2>/dev/null)
    [[ -z "$port" || "$port" == "22" ]] && {
        echo "Error: SSH not configured for '$1'. Run: _fenix_setup_ssh $1"
        return 1
    }
    ssh -p "$port" "$FENIX_HOST"
}

# fxq [name] - Destroy container quietly (non-interactive)
fxq() {
    [[ -z "$1" ]] && { echo "Usage: fxq <container>"; return 1; }
    _fenix_exists "$1" || {
        echo "Error: container '$1' does not exist"
        return 1
    }
    _fenix "$_FENIX_DB rm -f $1" && echo "Destroyed: $1"
}

# Tab completion
_fenix_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$(_fenix_containers 2>/dev/null)" -- "$cur"))
}

complete -F _fenix_complete f k fx fe fxq finfo fssh
