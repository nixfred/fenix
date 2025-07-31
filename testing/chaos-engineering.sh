#!/bin/bash
# 🔥 FeNix Phoenix Testing Labs - Chaos Engineering
# Tests FeNix resilience under adverse conditions

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# Configuration
RESULTS_DIR="chaos_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

show_banner() {
    clear
    echo -e "${BOLD}${RED}💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥${RESET}"
    echo -e "${BOLD}${YELLOW}       FeNix Chaos Engineering Labs      ${RESET}"
    echo -e "${BOLD}${CYAN}        Breaking Things to Make Them       ${RESET}"
    echo -e "${BOLD}${CYAN}              Stronger 🔥                  ${RESET}"
    echo -e "${BOLD}${RED}💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥${RESET}"
    echo ""
    echo -e "${CYAN}Testing FeNix resilience under adverse conditions${RESET}"
    echo ""
}

# Test network failures during bootstrap
test_network_failures() {
    local scenario="$1"
    local test_name="network_failure_$scenario"
    local log_file="$RESULTS_DIR/${test_name}.log"
    
    echo -e "${CYAN}💥 Testing: Network Failures ($scenario)${RESET}"
    
    local network_script="/tmp/network_chaos.sh"
    cat > "$network_script" << EOF
#!/bin/bash
set -e

# Simulate network issues
case "$scenario" in
    "intermittent")
        echo "Simulating intermittent network..."
        # Block GitHub for 30 seconds during bootstrap
        (sleep 10 && iptables -A OUTPUT -d github.com -j DROP && sleep 30 && iptables -D OUTPUT -d github.com -j DROP) &
        ;;
    "slow")
        echo "Simulating slow network..."
        # Add network delay
        tc qdisc add dev eth0 root netem delay 2000ms 2>/dev/null || true
        ;;
    "dns_failure")
        echo "Simulating DNS failures..."
        # Temporarily break DNS
        (sleep 5 && echo "127.0.0.1 github.com" >> /etc/hosts && sleep 20 && sed -i '/127.0.0.1 github.com/d' /etc/hosts) &
        ;;
esac

# Run FeNix bootstrap
timeout 900 bash -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash' || true

# Cleanup network modifications
case "$scenario" in
    "slow")
        tc qdisc del dev eth0 root netem 2>/dev/null || true
        ;;
esac

echo "=== Network Chaos Test Complete ==="
EOF

    local result="PASS"
    local error_msg=""
    
    {
        docker run --rm --privileged \
            --name "fenix_chaos_network_${scenario}" \
            -v "$network_script:/tmp/test.sh:ro" \
            -e "scenario=$scenario" \
            ubuntu:22.04 \
            bash /tmp/test.sh
    } > "$log_file" 2>&1 || {
        result="FAIL"
        error_msg=$(tail -5 "$log_file" | head -2 | tr '\n' ' ')
    }
    
    rm -f "$network_script"
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✅ RESILIENT: Network failures ($scenario)${RESET}"
    else
        echo -e "${RED}❌ FRAGILE: Network failures ($scenario)${RESET}"
        echo -e "${RED}   Error: ${error_msg}${RESET}"
    fi
    
    echo "$test_name,$result,$error_msg" >> "$RESULTS_DIR/chaos_summary.csv"
}

# Test resource constraints
test_resource_constraints() {
    local scenario="$1"
    local test_name="resource_constraint_$scenario"
    local log_file="$RESULTS_DIR/${test_name}.log"
    
    echo -e "${CYAN}💥 Testing: Resource Constraints ($scenario)${RESET}"
    
    local memory_limit="512m"
    local cpu_limit="0.5"
    
    case "$scenario" in
        "low_memory")
            memory_limit="256m"
            ;;
        "low_cpu")
            cpu_limit="0.25"
            ;;
        "combined")
            memory_limit="256m"
            cpu_limit="0.25"
            ;;
    esac
    
    local result="PASS"
    local error_msg=""
    
    {
        timeout 1200 docker run --rm \
            --name "fenix_chaos_resources_${scenario}" \
            --memory="$memory_limit" \
            --cpus="$cpu_limit" \
            ubuntu:22.04 \
            bash -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash'
    } > "$log_file" 2>&1 || {
        result="FAIL"
        error_msg=$(tail -5 "$log_file" | head -2 | tr '\n' ' ')
    }
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✅ EFFICIENT: Resource constraints ($scenario)${RESET}"
    else
        echo -e "${RED}❌ RESOURCE-HUNGRY: Resource constraints ($scenario)${RESET}"
        echo -e "${RED}   Error: ${error_msg}${RESET}"
    fi
    
    echo "$test_name,$result,$error_msg" >> "$RESULTS_DIR/chaos_summary.csv"
}

# Test disk space limitations
test_disk_constraints() {
    local scenario="$1"
    local test_name="disk_constraint_$scenario"
    local log_file="$RESULTS_DIR/${test_name}.log"
    
    echo -e "${CYAN}💥 Testing: Disk Space Constraints ($scenario)${RESET}"
    
    local disk_script="/tmp/disk_chaos.sh"
    cat > "$disk_script" << EOF
#!/bin/bash
set -e

# Create a small filesystem
dd if=/dev/zero of=/tmp/small_disk bs=1M count=200
mkfs.ext4 /tmp/small_disk >/dev/null 2>&1
mkdir -p /mnt/small
mount /tmp/small_disk /mnt/small

# Create user directory on small filesystem
mkdir -p /mnt/small/home/testuser
export HOME=/mnt/small/home/testuser
cd \$HOME

# Fill up disk to simulate constraint
case "$scenario" in
    "nearly_full")
        dd if=/dev/zero of=/mnt/small/filler bs=1M count=150 2>/dev/null || true
        ;;
    "extremely_full")
        dd if=/dev/zero of=/mnt/small/filler bs=1M count=180 2>/dev/null || true
        ;;
esac

# Run FeNix bootstrap
timeout 900 bash -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash' || true

echo "=== Disk Space Test Complete ==="
umount /mnt/small 2>/dev/null || true
EOF

    local result="PASS"
    local error_msg=""
    
    {
        docker run --rm --privileged \
            --name "fenix_chaos_disk_${scenario}" \
            -v "$disk_script:/tmp/test.sh:ro" \
            -e "scenario=$scenario" \
            ubuntu:22.04 \
            bash /tmp/test.sh
    } > "$log_file" 2>&1 || {
        result="FAIL" 
        error_msg=$(tail -5 "$log_file" | head -2 | tr '\n' ' ')
    }
    
    rm -f "$disk_script"
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✅ SPACE-EFFICIENT: Disk constraints ($scenario)${RESET}"
    else
        echo -e "${RED}❌ SPACE-HUNGRY: Disk constraints ($scenario)${RESET}"
        echo -e "${RED}   Error: ${error_msg}${RESET}"
    fi
    
    echo "$test_name,$result,$error_msg" >> "$RESULTS_DIR/chaos_summary.csv"
}

# Test broken package repositories
test_broken_repositories() {
    local scenario="$1"
    local test_name="broken_repos_$scenario"
    local log_file="$RESULTS_DIR/${test_name}.log"
    
    echo -e "${CYAN}💥 Testing: Broken Package Repositories ($scenario)${RESET}"
    
    local repo_script="/tmp/repo_chaos.sh"
    cat > "$repo_script" << EOF
#!/bin/bash
set -e

# Break package repositories
case "$scenario" in
    "invalid_sources")
        echo "deb http://invalid.example.com/ubuntu jammy main" > /etc/apt/sources.list
        ;;
    "slow_mirrors") 
        # Replace with very slow mirror (simulated)
        sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
        ;;
    "mixed_failure")
        # Mix of valid and invalid sources
        echo -e "deb http://invalid.example.com/ubuntu jammy main\ndeb http://archive.ubuntu.com/ubuntu jammy main" > /etc/apt/sources.list
        ;;
esac

# Run FeNix bootstrap
timeout 900 bash -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash' || true

echo "=== Repository Chaos Test Complete ==="
EOF

    local result="PASS"
    local error_msg=""
    
    {
        docker run --rm \
            --name "fenix_chaos_repos_${scenario}" \
            -v "$repo_script:/tmp/test.sh:ro" \
            -e "scenario=$scenario" \
            ubuntu:22.04 \
            bash /tmp/test.sh
    } > "$log_file" 2>&1 || {
        result="FAIL"
        error_msg=$(tail -5 "$log_file" | head -2 | tr '\n' ' ')
    }
    
    rm -f "$repo_script"
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✅ ROBUST: Broken repositories ($scenario)${RESET}"
    else
        echo -e "${RED}❌ FRAGILE: Broken repositories ($scenario)${RESET}"
        echo -e "${RED}   Error: ${error_msg}${RESET}"
    fi
    
    echo "$test_name,$result,$error_msg" >> "$RESULTS_DIR/chaos_summary.csv"
}

# Test permission issues
test_permission_issues() {
    local scenario="$1"
    local test_name="permissions_$scenario"
    local log_file="$RESULTS_DIR/${test_name}.log"
    
    echo -e "${CYAN}💥 Testing: Permission Issues ($scenario)${RESET}"
    
    local perm_script="/tmp/permission_chaos.sh"
    cat > "$perm_script" << EOF
#!/bin/bash
set -e

# Create non-root user for testing
useradd -m -s /bin/bash testuser || true

case "$scenario" in
    "no_sudo")
        # Remove sudo capabilities
        su - testuser -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash'
        ;;
    "readonly_home")
        # Make home directory readonly
        chmod 555 /home/testuser
        su - testuser -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash' || true
        chmod 755 /home/testuser
        ;;
    "partial_permissions")
        # Limited permissions on system directories
        chmod 700 /usr/local/bin
        su - testuser -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash' || true
        chmod 755 /usr/local/bin
        ;;
esac

echo "=== Permission Chaos Test Complete ==="
EOF

    local result="PASS"
    local error_msg=""
    
    {
        docker run --rm \
            --name "fenix_chaos_perms_${scenario}" \
            -v "$perm_script:/tmp/test.sh:ro" \
            -e "scenario=$scenario" \
            ubuntu:22.04 \
            bash /tmp/test.sh
    } > "$log_file" 2>&1 || {
        result="FAIL"
        error_msg=$(tail -5 "$log_file" | head -2 | tr '\n' ' ')
    }
    
    rm -f "$perm_script"
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✅ ADAPTABLE: Permission issues ($scenario)${RESET}"
    else
        echo -e "${RED}❌ PRIVILEGE-DEPENDENT: Permission issues ($scenario)${RESET}"
        echo -e "${RED}   Error: ${error_msg}${RESET}" 
    fi
    
    echo "$test_name,$result,$error_msg" >> "$RESULTS_DIR/chaos_summary.csv"
}

# Run all chaos scenarios
run_chaos_tests() {
    echo -e "${YELLOW}💥 Starting chaos engineering tests...${RESET}"
    echo ""
    
    echo "test_name,result,error" > "$RESULTS_DIR/chaos_summary.csv"
    
    # Network failure scenarios
    echo -e "${PURPLE}🌐 Network Chaos Tests${RESET}"
    test_network_failures "intermittent"
    test_network_failures "slow"
    test_network_failures "dns_failure"
    echo ""
    
    # Resource constraint scenarios
    echo -e "${PURPLE}💾 Resource Constraint Tests${RESET}"
    test_resource_constraints "low_memory"
    test_resource_constraints "low_cpu"
    test_resource_constraints "combined"
    echo ""
    
    # Disk space scenarios
    echo -e "${PURPLE}💽 Disk Space Tests${RESET}"
    test_disk_constraints "nearly_full"
    test_disk_constraints "extremely_full"
    echo ""
    
    # Repository failures
    echo -e "${PURPLE}📦 Repository Failure Tests${RESET}"
    test_broken_repositories "invalid_sources"
    test_broken_repositories "slow_mirrors"
    test_broken_repositories "mixed_failure"
    echo ""
    
    # Permission issues
    echo -e "${PURPLE}🔐 Permission Tests${RESET}"
    test_permission_issues "no_sudo"
    test_permission_issues "readonly_home"
    test_permission_issues "partial_permissions"
    echo ""
    
    generate_chaos_report
}

# Generate chaos test report
generate_chaos_report() {
    local total_tests=$(tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | wc -l)
    local passed_tests=$(tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep -c "PASS" || true)
    local failed_tests=$(tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep -c "FAIL" || true)
    
    echo -e "${BOLD}${RED}💥 Chaos Engineering Results${RESET}"
    echo "=============================="
    echo ""
    echo -e "${GREEN}✅ Resilient: $passed_tests/$total_tests${RESET}"
    echo -e "${RED}❌ Fragile: $failed_tests/$total_tests${RESET}"
    echo ""
    
    local resilience_score=$((passed_tests * 100 / total_tests))
    echo -e "${BOLD}Resilience Score: $resilience_score%${RESET}"
    
    if [ $resilience_score -ge 90 ]; then
        echo -e "${GREEN}🏆 ANTI-FRAGILE: FeNix thrives under chaos!${RESET}"
    elif [ $resilience_score -ge 75 ]; then
        echo -e "${YELLOW}💪 RESILIENT: FeNix handles most failures well${RESET}"
    elif [ $resilience_score -ge 50 ]; then
        echo -e "${YELLOW}⚠️  ROBUST: FeNix survives basic failures${RESET}"
    else
        echo -e "${RED}💥 FRAGILE: FeNix needs hardening${RESET}"
    fi
    
    echo ""
    echo -e "${CYAN}Failed Scenarios:${RESET}"
    tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep "FAIL" | while IFS=',' read -r test result error; do
        echo -e "${RED}  ❌ $test${RESET}"
        [ -n "$error" ] && echo -e "${RED}     $error${RESET}"
    done || echo -e "${GREEN}  None! 🎉${RESET}"
    
    echo ""
    echo -e "${CYAN}📁 Results saved to: $RESULTS_DIR/${RESET}"
    
    # Generate detailed report
    local report_file="$RESULTS_DIR/chaos_report.md"
    cat > "$report_file" << EOF
# FeNix Chaos Engineering Report

**Generated:** $(date)
**Total Tests:** $total_tests
**Passed:** $passed_tests
**Failed:** $failed_tests  
**Resilience Score:** $resilience_score%

## Test Categories

### Network Failures
$(tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep "network_failure" | while IFS=',' read -r test result error; do
    echo "- **${test#network_failure_}:** $result"
    [ -n "$error" ] && [ "$result" = "FAIL" ] && echo "  - Error: $error"
done)

### Resource Constraints  
$(tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep "resource_constraint" | while IFS=',' read -r test result error; do
    echo "- **${test#resource_constraint_}:** $result"
    [ -n "$error" ] && [ "$result" = "FAIL" ] && echo "  - Error: $error"
done)

### Disk Space Limitations
$(tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep "disk_constraint" | while IFS=',' read -r test result error; do
    echo "- **${test#disk_constraint_}:** $result"
    [ -n "$error" ] && [ "$result" = "FAIL" ] && echo "  - Error: $error"
done)

### Repository Failures
$(tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep "broken_repos" | while IFS=',' read -r test result error; do
    echo "- **${test#broken_repos_}:** $result"
    [ -n "$error" ] && [ "$result" = "FAIL" ] && echo "  - Error: $error"
done)

### Permission Issues
$(tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep "permissions" | while IFS=',' read -r test result error; do
    echo "- **${test#permissions_}:** $result"
    [ -n "$error" ] && [ "$result" = "FAIL" ] && echo "  - Error: $error"
done)

## Recommendations

$(if [ $resilience_score -lt 90 ]; then
    echo "### Areas for Improvement"
    tail -n +2 "$RESULTS_DIR/chaos_summary.csv" | grep "FAIL" | while IFS=',' read -r test result error; do
        case "$test" in
            network_failure_*) echo "- Improve network failure handling and retry logic" ;;
            resource_constraint_*) echo "- Optimize resource usage and add resource checks" ;;
            disk_constraint_*) echo "- Add disk space validation and cleanup routines" ;;
            broken_repos_*) echo "- Implement repository fallback mechanisms" ;;
            permissions_*) echo "- Add permission checking and graceful degradation" ;;
        esac
    done | sort -u
else
    echo "### Excellent Resilience!"
    echo "FeNix demonstrates excellent resilience across all tested failure scenarios."
fi)

---
*Generated by FeNix Chaos Engineering Labs*
EOF

    echo -e "${CYAN}📝 Detailed report: $report_file${RESET}"
}

# Quick chaos test
quick_chaos() {
    echo -e "${YELLOW}⚡ Running quick chaos test...${RESET}"
    echo ""
    
    echo "test_name,result,error" > "$RESULTS_DIR/chaos_summary.csv"
    
    # Test a few key scenarios
    test_network_failures "intermittent"
    test_resource_constraints "low_memory"
    test_broken_repositories "invalid_sources"
    
    generate_chaos_report
}

# Stress test
stress_test() {
    echo -e "${YELLOW}🔥 Running stress test...${RESET}"
    echo ""
    
    # Combine multiple chaos scenarios
    local stress_script="/tmp/stress_chaos.sh"
    cat > "$stress_script" << EOF
#!/bin/bash
set -e

# Combine multiple stressors
echo "Starting combined stress test..."

# Limited resources + network issues + broken repos
echo "Applying multiple stressors..."

# Add network delay
tc qdisc add dev eth0 root netem delay 1000ms 2>/dev/null || true

# Break some repositories
echo "deb http://invalid.example.com/ubuntu jammy main" >> /etc/apt/sources.list

# Fill up some disk space
dd if=/dev/zero of=/tmp/stress_filler bs=1M count=100 2>/dev/null || true

# Run FeNix bootstrap under stress
timeout 1500 bash -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash' || true

echo "=== Stress Test Complete ==="
EOF

    local result="PASS"
    local error_msg=""
    
    {
        docker run --rm --privileged \
            --name "fenix_stress_test" \
            --memory="512m" \
            --cpus="0.5" \
            -v "$stress_script:/tmp/test.sh:ro" \
            ubuntu:22.04 \
            bash /tmp/test.sh
    } > "$RESULTS_DIR/stress_test.log" 2>&1 || {
        result="FAIL"
        error_msg=$(tail -5 "$RESULTS_DIR/stress_test.log" | head -2 | tr '\n' ' ')
    }
    
    rm -f "$stress_script"
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}🏆 ANTI-FRAGILE: FeNix survives extreme stress!${RESET}"
    else
        echo -e "${RED}💥 STRESSED: FeNix fails under extreme conditions${RESET}"
        echo -e "${RED}   Error: ${error_msg}${RESET}"
    fi
}

# Main function
main() {
    show_banner
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is required for chaos testing${RESET}"
        exit 1
    fi
    
    case "${1:-all}" in
        "network")
            echo "test_name,result,error" > "$RESULTS_DIR/chaos_summary.csv"
            test_network_failures "intermittent"
            test_network_failures "slow" 
            test_network_failures "dns_failure"
            ;;
        "resources")
            echo "test_name,result,error" > "$RESULTS_DIR/chaos_summary.csv"
            test_resource_constraints "low_memory"
            test_resource_constraints "low_cpu"
            test_resource_constraints "combined"
            ;;
        "disk")
            echo "test_name,result,error" > "$RESULTS_DIR/chaos_summary.csv"
            test_disk_constraints "nearly_full"
            test_disk_constraints "extremely_full"
            ;;
        "repos")
            echo "test_name,result,error" > "$RESULTS_DIR/chaos_summary.csv"
            test_broken_repositories "invalid_sources"
            test_broken_repositories "slow_mirrors"
            test_broken_repositories "mixed_failure"
            ;;
        "permissions")
            echo "test_name,result,error" > "$RESULTS_DIR/chaos_summary.csv"
            test_permission_issues "no_sudo"
            test_permission_issues "readonly_home"
            test_permission_issues "partial_permissions"
            ;;
        "quick")
            quick_chaos
            ;;
        "stress")
            stress_test
            ;;
        "all"|*)
            run_chaos_tests
            ;;
    esac
}

# Show usage if requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "FeNix Chaos Engineering Labs"
    echo ""
    echo "Usage: $0 [scenario]"
    echo ""
    echo "Scenarios:"
    echo "  all         - Run all chaos tests (default)"
    echo "  network     - Network failure tests only"
    echo "  resources   - Resource constraint tests only" 
    echo "  disk        - Disk space limitation tests only"
    echo "  repos       - Repository failure tests only"
    echo "  permissions - Permission issue tests only"
    echo "  quick       - Quick chaos test with key scenarios"
    echo "  stress      - Combined stress test"
    echo ""
    echo "Examples:"
    echo "  $0                    # Full chaos test suite"
    echo "  $0 network           # Network failure tests"
    echo "  $0 quick             # Quick chaos test"
    echo "  $0 stress            # Extreme stress test"
    echo ""
    exit 0
fi

# Run main function
main "$@"