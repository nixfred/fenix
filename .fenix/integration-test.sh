#!/bin/bash
# FeNix Multi-Host Integration Test Suite

echo "🧪 FeNix Multi-Host Integration Test Suite"
echo "=========================================="

# Test 1: Host Management System
echo "1. Testing host management system..."
if ./test-hosts.sh >/dev/null 2>&1; then
    echo "   ✅ Host management system working"
else
    echo "   ❌ Host management system failed"
    exit 1
fi

# Test 2: Script syntax validation
echo "2. Testing script syntax..."
scripts=(
    "./deploy-container.sh"
    "./monitor-clients.sh" 
    "./setup-remote-client.sh"
    "./host-manager.sh"
)

for script in "${scripts[@]}"; do
    if bash -n "$script" 2>/dev/null; then
        echo "   ✅ $script syntax valid"
    else
        echo "   ❌ $script syntax invalid"
        exit 1
    fi
done

# Test 3: Help output
echo "3. Testing help outputs..."
if ./deploy-container.sh 2>&1 | grep -q "Usage:"; then
    echo "   ✅ Deploy script help working"
else
    echo "   ❌ Deploy script help failed"
    exit 1
fi

# Test 4: Monitor output
echo "4. Testing monitor output..."
if ./monitor-clients.sh >/dev/null 2>&1; then
    echo "   ✅ Monitor script working"
else
    echo "   ❌ Monitor script failed"
    exit 1
fi

# Test 5: Configuration validation
echo "5. Testing configuration files..."
if [ -f "$HOME/.fenix/hosts.conf" ]; then
    source "$HOME/.fenix/hosts.conf"
    if [ -n "$FENIX_MAIN_HOST" ] && [ -n "$FENIX_CONFIG_VERSION" ]; then
        echo "   ✅ Configuration file valid"
    else
        echo "   ❌ Configuration file incomplete"
        exit 1
    fi
else
    echo "   ❌ Configuration file missing"
    exit 1
fi

echo
echo "🎉 All integration tests passed!"
echo "   Ready for documentation update and GitHub push"
echo
echo "Next steps:"
echo "   • Update CLAUDE.md files"
echo "   • Update README.md files"  
echo "   • Commit and push to GitHub"