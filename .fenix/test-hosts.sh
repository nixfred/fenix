#!/bin/bash
# Test script for FeNix host configuration system

echo "🧪 Testing FeNix Host Configuration System"
echo "========================================="

# Source the host manager
source "$HOME/.fenix/host-manager.sh"

# Test 1: Load configuration
echo "1. Loading host configuration..."
if load_fenix_hosts; then
    echo "   ✅ Configuration loaded successfully"
else
    echo "   ❌ Failed to load configuration"
    exit 1
fi

# Test 2: List hosts
echo
echo "2. Host configuration:"
list_fenix_hosts

# Test 3: Validate hosts
echo
echo "3. Host validation tests:"
for host in "pi5" "ron" "invalid-host"; do
    echo -n "   Testing $host: "
    if validate_fenix_host "$host"; then
        echo "✅ valid"
    else
        echo "❌ invalid"
    fi
done

# Test 4: Container name generation
echo
echo "4. Container name generation tests:"
for template in python-dev kali-security node-web; do
    name=$(generate_container_name "$template" "1")
    echo "   $template → $name"
done

# Test 5: Host roles
echo
echo "5. Host role tests:"
for host in pi5 ron; do
    role=$(get_host_role "$host")
    echo "   $host role: $role"
done

echo
echo "🎉 All tests completed!"