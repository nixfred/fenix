#!/bin/bash
# FeNix Remote Client Setup Script
# Usage: ./setup-remote-client.sh <hostname> <ip_address> [role]

set -e

REMOTE_HOST="$1"
REMOTE_IP="$2"
REMOTE_ROLE="${3:-remote}"

if [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_IP" ]; then
    echo "Usage: $0 <hostname> <ip_address> [role]"
    echo "Example: $0 pi-dev 192.168.1.100 development"
    exit 1
fi

echo "🚀 Setting up remote FeNix client: $REMOTE_HOST"
echo "   IP: $REMOTE_IP"
echo "   Role: $REMOTE_ROLE"

# Source host management functions
source "$HOME/.fenix/host-manager.sh"
load_fenix_hosts

# Step 1: Generate SSH key if needed
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "🔑 Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" -C "fenix-$(hostname)"
fi

# Step 2: Copy SSH key to remote
echo "🔐 Setting up SSH access to $REMOTE_HOST..."
if ! ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "pi@$REMOTE_IP" 2>/dev/null; then
    echo "❌ Failed to copy SSH key. Please ensure:"
    echo "   1. SSH is enabled on the remote host"
    echo "   2. Password authentication is working"
    echo "   3. The IP address is correct"
    exit 1
fi

# Step 3: Add to SSH config
echo "📝 Adding to SSH config..."
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host $REMOTE_HOST" "$SSH_CONFIG" 2>/dev/null; then
    cat >> "$SSH_CONFIG" << EOF

# FeNix Remote Client: $REMOTE_HOST
Host $REMOTE_HOST
    HostName $REMOTE_IP
    User pi
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
fi

# Step 4: Test SSH connection
echo "🔗 Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 "$REMOTE_HOST" "echo 'SSH connection successful'" >/dev/null 2>&1; then
    echo "❌ SSH connection failed"
    exit 1
fi

# Step 5: Install FeNix on remote
echo "📦 Installing FeNix on remote client..."
ssh "$REMOTE_HOST" "curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash -s -- --remote-client --main-host $(hostname)"

# Step 6: Update local host configuration
echo "🔧 Updating local host configuration..."
if ! echo "$FENIX_REMOTE_HOSTS" | grep -q "$REMOTE_HOST"; then
    # Add to remote hosts list
    NEW_REMOTE_HOSTS="$FENIX_REMOTE_HOSTS $REMOTE_HOST"
    NEW_HOST_ROLES="$FENIX_HOST_ROLES $REMOTE_HOST:$REMOTE_ROLE"
    
    # Update configuration file
    sed -i "s/FENIX_REMOTE_HOSTS=\".*\"/FENIX_REMOTE_HOSTS=\"$NEW_REMOTE_HOSTS\"/" "$HOME/.fenix/hosts.conf"
    sed -i "s/FENIX_HOST_ROLES=\".*\"/FENIX_HOST_ROLES=\"$NEW_HOST_ROLES\"/" "$HOME/.fenix/hosts.conf"
    
    # Reload configuration
    load_fenix_hosts
fi

# Step 7: Verify setup
echo "✅ Verifying client setup..."
CLIENT_STATUS=$(ssh "$REMOTE_HOST" "source ~/.fenix/host-manager.sh && load_fenix_hosts && echo \"Main: \$FENIX_MAIN_HOST, Role: \$(get_host_role $REMOTE_HOST)\"")
echo "   Remote client reports: $CLIENT_STATUS"

# Step 8: Display summary
echo
echo "🎉 Remote client '$REMOTE_HOST' setup complete!"
echo "   SSH: ssh $REMOTE_HOST"
echo "   Quick connect: pp $REMOTE_HOST"
echo "   Role: $REMOTE_ROLE"
echo
echo "Next steps:"
echo "   • Test connection: pp $REMOTE_HOST"
echo "   • Deploy containers: ./deploy-container.sh <template> $REMOTE_HOST"
echo "   • Monitor status: ./monitor-clients.sh"