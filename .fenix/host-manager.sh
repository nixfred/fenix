#!/bin/bash
# FeNix Host Manager Library
# Provides functions for managing multi-host configurations

# Load host configuration
load_fenix_hosts() {
    local config_file="$HOME/.fenix/hosts.conf"
    
    if [ -f "$config_file" ]; then
        # Source the configuration file
        source "$config_file"
        
        # Export variables for use in other scripts
        export FENIX_MAIN_HOST FENIX_REMOTE_HOSTS FENIX_DEFAULT_REMOTE
        export FENIX_HOST_ROLES FENIX_SSH_USER FENIX_SSH_OPTIONS
        export FENIX_SYNC_CONTAINERS FENIX_CONTAINER_PREFIX FENIX_CONFIG_VERSION
        
        return 0
    else
        # No configuration found - create default or prompt user
        echo "⚠️  No FeNix host configuration found at $config_file"
        return 1
    fi
}

# Validate that a host exists in the configuration
validate_fenix_host() {
    local target_host="$1"
    
    if [ -z "$target_host" ]; then
        return 1
    fi
    
    # Check if host is in FENIX_REMOTE_HOSTS or is the main host
    if [ "$target_host" = "$FENIX_MAIN_HOST" ]; then
        return 0
    fi
    
    # Check remote hosts
    for host in $FENIX_REMOTE_HOSTS; do
        if [ "$host" = "$target_host" ]; then
            return 0
        fi
    done
    
    return 1
}

# Get list of all available hosts
list_fenix_hosts() {
    load_fenix_hosts
    
    echo "FeNix Hosts Configuration:"
    echo "  Main host: $FENIX_MAIN_HOST"
    echo "  Remote hosts: $FENIX_REMOTE_HOSTS"
    echo "  Default remote: $FENIX_DEFAULT_REMOTE"
    
    if [ -n "$FENIX_HOST_ROLES" ]; then
        echo "  Host roles:"
        for role_pair in $FENIX_HOST_ROLES; do
            local host="${role_pair%:*}"
            local role="${role_pair#*:}"
            echo "    $host: $role"
        done
    fi
}

# Get role for a specific host
get_host_role() {
    local target_host="$1"
    
    for role_pair in $FENIX_HOST_ROLES; do
        local host="${role_pair%:*}"
        local role="${role_pair#*:}"
        
        if [ "$host" = "$target_host" ]; then
            echo "$role"
            return 0
        fi
    done
    
    echo "unknown"
    return 1
}

# Generate container name using host-based naming
generate_container_name() {
    local template="$1"
    local sequence="${2:-1}"
    
    load_fenix_hosts
    
    local host_prefix
    if [ -n "$FENIX_CONTAINER_PREFIX" ]; then
        host_prefix="$FENIX_CONTAINER_PREFIX"
    else
        host_prefix="$FENIX_MAIN_HOST"
    fi
    
    echo "${template}-${host_prefix}${sequence}"
}

# Setup initial host configuration (interactive)
setup_fenix_hosts() {
    echo "🔧 Setting up FeNix multi-host configuration..."
    
    local main_host
    local current_hostname=$(hostname)
    read -p "Enter main host identifier [$current_hostname]: " main_host
    main_host="${main_host:-$current_hostname}"
    
    local remote_hosts
    echo "Enter remote hosts (space-separated, or press Enter for none):"
    read -p "Remote hosts: " remote_hosts
    
    local default_remote
    if [ -n "$remote_hosts" ]; then
        default_remote=$(echo "$remote_hosts" | cut -d' ' -f1)
        read -p "Default remote host [$default_remote]: " user_default
        default_remote="${user_default:-$default_remote}"
    fi
    
    # Create the configuration directory
    mkdir -p "$HOME/.fenix"
    
    # Generate configuration file
    cat > "$HOME/.fenix/hosts.conf" << EOF
# FeNix Multi-Host Configuration
# Generated on $(date)

FENIX_MAIN_HOST="$main_host"
FENIX_REMOTE_HOSTS="$remote_hosts"
FENIX_DEFAULT_REMOTE="$default_remote"

# Host roles (optional) - format: "host1:role1 host2:role2"
FENIX_HOST_ROLES=""

# SSH connection settings
FENIX_SSH_USER=""  # Leave empty to use current user
FENIX_SSH_OPTIONS="-o ConnectTimeout=10 -o ServerAliveInterval=60"

# Container deployment settings
FENIX_SYNC_CONTAINERS=true
FENIX_CONTAINER_PREFIX=""  # Leave empty to use hostname

# Version of this config format
FENIX_CONFIG_VERSION="2.0"
EOF
    
    echo "✅ FeNix host configuration created at $HOME/.fenix/hosts.conf"
    echo "   Main host: $main_host"
    [ -n "$remote_hosts" ] && echo "   Remote hosts: $remote_hosts"
    [ -n "$default_remote" ] && echo "   Default remote: $default_remote"
    
    return 0
}

# Migrate legacy ron/pi5 configuration
migrate_legacy_hosts() {
    local config_file="$HOME/.fenix/hosts.conf"
    
    # Skip if config already exists
    if [ -f "$config_file" ]; then
        return 0
    fi
    
    local current_host=$(hostname)
    
    # Check if this is a legacy ron/pi5 setup
    case "$current_host" in
        "ron"|"pi5")
            echo "🔄 Migrating legacy ron/pi5 configuration..."
            
            local other_host
            if [ "$current_host" = "ron" ]; then
                other_host="pi5"
            else
                other_host="ron"
            fi
            
            # Create migrated configuration
            mkdir -p "$HOME/.fenix"
            cat > "$config_file" << EOF
# FeNix Multi-Host Configuration
# Migrated from legacy ron/pi5 setup on $(date)

FENIX_MAIN_HOST="$current_host"
FENIX_REMOTE_HOSTS="$other_host"
FENIX_DEFAULT_REMOTE="$other_host"

# Host roles from legacy setup
FENIX_HOST_ROLES="ron:production pi5:development"

# SSH connection settings
FENIX_SSH_USER=""
FENIX_SSH_OPTIONS="-o ConnectTimeout=10 -o ServerAliveInterval=60"

# Container deployment settings
FENIX_SYNC_CONTAINERS=true
FENIX_CONTAINER_PREFIX=""

# Version of this config format
FENIX_CONFIG_VERSION="2.0"
EOF
            
            echo "✅ Migrated legacy configuration:"
            echo "   $current_host → $other_host"
            return 0
            ;;
        *)
            # Not a legacy setup, skip migration
            return 1
            ;;
    esac
}

# Check if FeNix host configuration is available
has_fenix_config() {
    [ -f "$HOME/.fenix/hosts.conf" ]
}

# Initialize FeNix host system (call this from .bashrc)
init_fenix_hosts() {
    # Try to migrate legacy configuration first
    migrate_legacy_hosts
    
    # Load configuration if available
    if has_fenix_config; then
        load_fenix_hosts
        return 0
    else
        # No configuration available
        echo "ℹ️  FeNix host configuration not found. Run 'setup_fenix_hosts' to configure."
        return 1
    fi
}