# Fenix - Ephemeral Linux Containers
# Source from .bashrc: source ~/Projects/f/fenix.bashrc

FENIX_DB="${FENIX_DB:-$HOME/.local/bin/distrobox}"
unalias f k fx 2>/dev/null

# f [name] - Ubuntu container (list if no name, create/enter if name given)
f() {
    [[ -z "$1" ]] && { $FENIX_DB list; return; }
    if $FENIX_DB list 2>/dev/null | grep -qw "$1"; then
        $FENIX_DB enter "$1"
    else
        echo "Creating $1..."
        $FENIX_DB create -i ubuntu:24.04 -n "$1" --home /home/pi --hostname "$1" --yes
        $FENIX_DB enter "$1"
    fi
}

# k [name] - Kali container
k() {
    [[ -z "$1" ]] && { $FENIX_DB list; return; }
    if $FENIX_DB list 2>/dev/null | grep -qw "$1"; then
        $FENIX_DB enter "$1"
    else
        echo "Creating $1..."
        $FENIX_DB create -i docker.io/kalilinux/kali-last-release -n "$1" --home /home/pi --hostname "$1" --yes
        $FENIX_DB enter "$1"
    fi
}

# fx [name] - Destroy container
fx() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Containers:"
        $FENIX_DB list
        echo ""
        read -p "Destroy: " name
        [[ -z "$name" ]] && return
    fi
    read -p "Destroy $name? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        $FENIX_DB rm -f "$name"
        echo "Done."
    fi
}
