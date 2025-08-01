#!/bin/bash
# FeNix Multi-Client Container Deployment Script
# Usage: ./deploy-container.sh <template> <clients...>
#        ./deploy-container.sh <template> --role <role>
#        ./deploy-container.sh <template> --all

set -e

TEMPLATE="$1"

if [ -z "$TEMPLATE" ]; then
    echo "Usage: $0 <template> <clients...>"
    echo "       $0 <template> --role <role>"
    echo "       $0 <template> --all"
    echo
    echo "Available templates:"
    if [ -d ~/docker/universal/templates ]; then
        ls -1 ~/docker/universal/templates/*.json 2>/dev/null | xargs -n1 basename | sed 's/.json$//' | sed 's/^/  /' || echo "  No templates found"
    else
        echo "  Templates directory not found"
    fi
    exit 1
fi

shift

# Source host management functions
source "$HOME/.fenix/host-manager.sh"
load_fenix_hosts

# Determine target clients
TARGET_CLIENTS=""

case "$1" in
    "--all")
        TARGET_CLIENTS="$FENIX_REMOTE_HOSTS"
        ;;
    "--role")
        ROLE="$2"
        if [ -z "$ROLE" ]; then
            echo "Error: --role requires a role name"
            exit 1
        fi
        
        # Find clients with matching role
        for host in $FENIX_REMOTE_HOSTS; do
            host_role=$(get_host_role "$host")
            if [ "$host_role" = "$ROLE" ]; then
                TARGET_CLIENTS="$TARGET_CLIENTS $host"
            fi
        done
        
        if [ -z "$TARGET_CLIENTS" ]; then
            echo "No clients found with role: $ROLE"
            exit 1
        fi
        ;;
    *)
        # Specific clients listed
        TARGET_CLIENTS="$*"
        
        # Validate all clients exist
        for client in $TARGET_CLIENTS; do
            if ! validate_fenix_host "$client"; then
                echo "Error: Unknown client '$client'"
                echo "Available clients: $FENIX_REMOTE_HOSTS"
                exit 1
            fi
        done
        ;;
esac

echo "🚀 Deploying '$TEMPLATE' containers to clients..."
echo "   Targets: $TARGET_CLIENTS"
echo

# Function to deploy to a single client
deploy_to_client() {
    local client="$1"
    local role=$(get_host_role "$client")
    
    echo "📦 Deploying to $client ($role)..."
    
    # Test connectivity
    if ! ssh -o ConnectTimeout=10 "$client" "echo connected" >/dev/null 2>&1; then
        echo "   ❌ Cannot connect to $client"
        return 1
    fi
    
    # Sync docker configuration
    echo "   📂 Syncing docker configs..."
    rsync -avz --delete ~/docker/universal/ "$client:~/docker/universal/" >/dev/null
    
    # Generate container name for this client
    local container_name=$(ssh "$client" "
        source ~/.fenix/host-manager.sh
        load_fenix_hosts
        generate_container_name '$TEMPLATE' '1'
    ")
    
    echo "   🏗️  Building container: $container_name"
    
    # Deploy container on remote
    ssh "$client" "
        cd ~/docker/universal
        ./manage.sh quick '$TEMPLATE' --name '$container_name' --auto-confirm
    " 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Successfully deployed to $client"
        
        # Get container status
        local status=$(ssh "$client" "docker ps --filter name=$container_name --format '{{.Status}}'" 2>/dev/null)
        echo "   📊 Status: $status"
    else
        echo "   ❌ Failed to deploy to $client"
        return 1
    fi
    
    echo
}

# Deploy to all target clients
SUCCESS_COUNT=0
TOTAL_COUNT=0

for client in $TARGET_CLIENTS; do
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    if deploy_to_client "$client"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    fi
done

# Summary
echo "🎯 Deployment Summary:"
echo "   Template: $TEMPLATE"
echo "   Successful: $SUCCESS_COUNT/$TOTAL_COUNT"

if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    echo "   🎉 All deployments successful!"
else
    echo "   ⚠️  Some deployments failed"
    exit 1
fi