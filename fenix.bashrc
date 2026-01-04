# Fenix - Ephemeral Linux Containers
# Source from ~/.config/fenix/fenix.bashrc (synced via Syncthing)

FENIX_HOST="${FENIX_HOST:-box}"
_FENIX_DB="/home/pi/.local/bin/distrobox"
unalias f k fx fl fe fxq 2>/dev/null

# Run on box (locally or via SSH)
_fenix() {
    if [[ "$(hostname)" == "$FENIX_HOST" ]]; then
        eval "$1"
    else
        ssh -t "$FENIX_HOST" "$1"
    fi
}

# Check if container exists (matches NAME column only, not IMAGE)
_fenix_exists() {
    _fenix "$_FENIX_DB list" 2>/dev/null | awk -F'|' 'NR>1 {gsub(/^ +| +$/, "", $2); print $2}' | grep -qx "$1"
}

# f [name] - Ubuntu container
f() {
    [[ -z "$1" ]] && { _fenix "$_FENIX_DB list"; return; }
    _fenix_exists "$1" || {
        echo "Creating $1..."
        _fenix "touch /tmp/.nopasswd; $_FENIX_DB create -i ubuntu:24.04 -n '$1' --home /home/pi --hostname '$1' --yes --volume /tmp/.nopasswd:/run/.nopasswd:ro"
    }
    _fenix "$_FENIX_DB enter $1"
}

# k [name] - Kali container
k() {
    [[ -z "$1" ]] && { _fenix "$_FENIX_DB list"; return; }
    _fenix_exists "$1" || {
        echo "Creating $1..."
        _fenix "touch /tmp/.nopasswd; $_FENIX_DB create -i docker.io/kalilinux/kali-last-release -n '$1' --home /home/pi --hostname '$1' --yes --volume /tmp/.nopasswd:/run/.nopasswd:ro"
    }
    _fenix "$_FENIX_DB enter $1"
}

# fx [name] - Destroy container (interactive)
fx() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Containers:"
        _fenix "$_FENIX_DB list"
        echo ""
        read -p "Destroy: " name
        [[ -z "$name" ]] && return
    fi
    read -p "Destroy $name? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] && _fenix "$_FENIX_DB rm -f $name" && echo "Done."
}

# fe [name] [cmd...] - Execute command in container (non-interactive, for scripts/Claude Code)
fe() {
    local name="$1"
    [[ -z "$name" ]] && { echo "Usage: fe <container> <command...>"; return 1; }
    shift
    [[ $# -eq 0 ]] && { echo "Usage: fe <container> <command...>"; return 1; }
    # Check container exists (fail fast, no prompts)
    _fenix_exists "$name" || {
        echo "Error: container '$name' does not exist. Create with: f $name"
        return 1
    }
    _fenix "$_FENIX_DB enter $name -- $*"
}

# fl - List containers (non-interactive)
fl() {
    _fenix "$_FENIX_DB list"
}

# fxq [name] - Destroy container quietly (non-interactive, for scripts/Claude Code)
fxq() {
    [[ -z "$1" ]] && { echo "Usage: fxq <container>"; return 1; }
    _fenix_exists "$1" || {
        echo "Error: container '$1' does not exist"
        return 1
    }
    _fenix "$_FENIX_DB rm -f $1" && echo "Destroyed: $1"
}
