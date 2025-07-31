#!/bin/bash
# 🔥 FeNix Phoenix Testing Labs - Multi-Distro Validation
# Tests FeNix bootstrap across multiple Linux distributions

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
BOOTSTRAP_URL="https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh"
LOCAL_BOOTSTRAP="/home/pi/fenix/bootstrap.sh"
TEST_TIMEOUT=600  # 10 minutes
PARALLEL_TESTS=2

# Test distributions
DISTRIBUTIONS=(
    "ubuntu:22.04"
    "ubuntu:20.04" 
    "debian:12"
    "debian:11"
    "fedora:39"
    "fedora:38"
    "alpine:3.19"
    "alpine:3.18"
    "archlinux:latest"
    # "centos:stream9"  # CentOS can be slow, enable if needed
)

# Architectures to test
ARCHITECTURES=(
    "linux/amd64"
    "linux/arm64"
)

# Test results storage
RESULTS_DIR="test_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

show_banner() {
    clear
    echo -e "${BOLD}${RED}🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥${RESET}"
    echo -e "${BOLD}${YELLOW}       FeNix Phoenix Testing Labs      ${RESET}"
    echo -e "${BOLD}${CYAN}      Multi-Distro Validation Suite     ${RESET}"
    echo -e "${BOLD}${RED}🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥${RESET}"
    echo ""
    echo -e "${CYAN}Testing FeNix across multiple Linux distributions${RESET}"
    echo -e "${CYAN}Target: <10 minute deployment time on all platforms${RESET}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    echo -e "${CYAN}🔍 Checking prerequisites...${RESET}"
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is required for testing${RESET}"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker daemon is not running${RESET}"
        exit 1
    fi
    
    # Check if we can run containers
    if ! docker run --rm hello-world >/dev/null 2>&1; then
        echo -e "${RED}❌ Cannot run Docker containers${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${RESET}"
    echo ""
}

# Test single distribution
test_distribution() {
    local distro="$1"
    local arch="$2"
    local use_local="$3"
    
    local test_name="${distro//[:\/]/_}_${arch//[:\/]/_}"
    local log_file="$RESULTS_DIR/${test_name}.log"
    local start_time=$(date +%s)
    
    echo -e "${CYAN}🧪 Testing: $distro ($arch)${RESET}"
    
    # Prepare test script
    local test_script="/tmp/fenix_test_${test_name}.sh"
    cat > "$test_script" << EOF
#!/bin/bash
set -e

# Update package manager
if command -v apt >/dev/null 2>&1; then
    apt update >/dev/null 2>&1
elif command -v dnf >/dev/null 2>&1; then
    dnf update -y >/dev/null 2>&1
elif command -v pacman >/dev/null 2>&1; then
    pacman -Sy --noconfirm >/dev/null 2>&1
elif command -v apk >/dev/null 2>&1; then
    apk update >/dev/null 2>&1
fi

# Install curl if not available
if ! command -v curl >/dev/null 2>&1; then
    if command -v apt >/dev/null 2>&1; then
        apt install -y curl
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y curl
    elif command -v pacman >/dev/null 2>&1; then
        pacman -S --noconfirm curl
    elif command -v apk >/dev/null 2>&1; then
        apk add curl
    fi
fi

# Run FeNix bootstrap
if [ "$use_local" = "true" ]; then
    cat /tmp/bootstrap.sh | bash
else
    curl -s "$BOOTSTRAP_URL" | bash
fi

# Verify installation
echo "=== Installation Verification ==="
echo "Shell: \$SHELL"
echo "FeNix Dir: \$(ls -la ~/.fenix 2>/dev/null | wc -l) items"
echo "bashrc loaded: \$(grep -c FeNix ~/.bashrc 2>/dev/null || echo 0) references"

# Test basic commands
source ~/.bashrc 2>/dev/null || true
echo "Commands available:"
command -v j >/dev/null 2>&1 && echo "  ✅ j (jump function)" || echo "  ❌ j function missing"
command -v neo >/dev/null 2>&1 && echo "  ✅ neo (system info)" || echo "  ❌ neo function missing"  
command -v sb >/dev/null 2>&1 && echo "  ✅ sb (shell reload)" || echo "  ❌ sb function missing"

echo "=== Test Complete ==="
EOF

    chmod +x "$test_script"
    
    # Copy local bootstrap if needed
    if [ "$use_local" = "true" ]; then
        cp "$LOCAL_BOOTSTRAP" /tmp/bootstrap.sh
    fi
    
    # Run test in container
    local container_name="fenix_test_${test_name}"
    local result="PASS"
    local error_msg=""
    
    {
        timeout $TEST_TIMEOUT docker run \
            --name "$container_name" \
            --platform "$arch" \
            --rm \
            -v "$test_script:/tmp/test.sh:ro" \
            $([ "$use_local" = "true" ] && echo "-v /tmp/bootstrap.sh:/tmp/bootstrap.sh:ro") \
            -e "BOOTSTRAP_URL=$BOOTSTRAP_URL" \
            -e "use_local=$use_local" \
            "$distro" \
            /tmp/test.sh
    } > "$log_file" 2>&1 || {
        result="FAIL"
        error_msg=$(tail -10 "$log_file" | head -3 | tr '\n' ' ')
    }
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Clean up
    rm -f "$test_script"
    [ "$use_local" = "true" ] && rm -f /tmp/bootstrap.sh
    
    # Report results
    if [ "$result" = "PASS" ]; then
        if [ $duration -lt 600 ]; then  # Under 10 minutes
            echo -e "${GREEN}✅ PASS: $distro ($arch) - ${duration}s${RESET}"
        else
            echo -e "${YELLOW}⚠️  SLOW: $distro ($arch) - ${duration}s (over 10min target)${RESET}"
        fi
    else
        echo -e "${RED}❌ FAIL: $distro ($arch) - ${duration}s${RESET}"
        echo -e "${RED}   Error: ${error_msg}${RESET}"
    fi
    
    # Write result to summary file
    echo "$distro,$arch,$result,$duration,$error_msg" >> "$RESULTS_DIR/summary.csv"
    
    return $([ "$result" = "PASS" ] && echo 0 || echo 1)
}

# Run tests for all distributions
run_all_tests() {
    local use_local="$1"
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    local slow_tests=0
    
    echo "Distribution,Architecture,Result,Duration(s),Error" > "$RESULTS_DIR/summary.csv"
    
    echo -e "${YELLOW}🚀 Starting multi-distro testing...${RESET}"
    echo -e "${CYAN}Using $([ "$use_local" = "true" ] && echo "LOCAL" || echo "REMOTE") bootstrap script${RESET}"
    echo ""
    
    # Test each distribution on each architecture
    for arch in "${ARCHITECTURES[@]}"; do
        echo -e "${PURPLE}📋 Testing architecture: $arch${RESET}"
        echo ""
        
        for distro in "${DISTRIBUTIONS[@]}"; do
            total_tests=$((total_tests + 1))
            
            if test_distribution "$distro" "$arch" "$use_local"; then
                passed_tests=$((passed_tests + 1))
                
                # Check if it was slow (>10 min)
                local duration=$(tail -1 "$RESULTS_DIR/summary.csv" | cut -d',' -f4)
                if [ "$duration" -gt 600 ]; then
                    slow_tests=$((slow_tests + 1))
                fi
            else
                failed_tests=$((failed_tests + 1))
            fi
            
            echo ""
        done
        
        echo ""
    done
    
    # Generate final report
    generate_report "$total_tests" "$passed_tests" "$failed_tests" "$slow_tests"
}

# Generate test report
generate_report() {
    local total="$1"
    local passed="$2" 
    local failed="$3"
    local slow="$4"
    
    local report_file="$RESULTS_DIR/test_report.md"
    
    echo -e "${BOLD}${CYAN}📊 Test Results Summary${RESET}"
    echo "======================="
    echo ""
    echo -e "${GREEN}✅ Passed: $passed/$total${RESET}"
    echo -e "${RED}❌ Failed: $failed/$total${RESET}"
    echo -e "${YELLOW}⚠️  Slow (>10min): $slow/$total${RESET}"
    echo ""
    
    local success_rate=$((passed * 100 / total))
    echo -e "${BOLD}Success Rate: $success_rate%${RESET}"
    
    if [ $success_rate -ge 90 ]; then
        echo -e "${GREEN}🏆 EXCELLENT: FeNix is highly portable!${RESET}"
    elif [ $success_rate -ge 75 ]; then
        echo -e "${YELLOW}👍 GOOD: FeNix works on most distributions${RESET}"
    else
        echo -e "${RED}⚠️  NEEDS WORK: FeNix has compatibility issues${RESET}"
    fi
    
    echo ""
    echo -e "${CYAN}📁 Results saved to: $RESULTS_DIR/${RESET}"
    echo -e "${CYAN}📊 Summary CSV: $RESULTS_DIR/summary.csv${RESET}"
    echo -e "${CYAN}📝 Individual logs: $RESULTS_DIR/*.log${RESET}"
    
    # Generate markdown report
    cat > "$report_file" << EOF
# FeNix Phoenix Testing Labs - Multi-Distro Validation Report

**Generated:** $(date)
**Test Duration:** $(date +%H:%M:%S)

## Summary

- **Total Tests:** $total
- **Passed:** $passed
- **Failed:** $failed  
- **Slow (>10min):** $slow
- **Success Rate:** $success_rate%

## Results by Distribution

$(while IFS=',' read -r distro arch result duration error; do
    if [ "$distro" != "Distribution" ]; then
        echo "- **${distro} (${arch}):** $result (${duration}s)"
        [ -n "$error" ] && echo "  - Error: $error"
    fi
done < "$RESULTS_DIR/summary.csv")

## Conclusion

$(if [ $success_rate -ge 90 ]; then
    echo "🏆 **EXCELLENT:** FeNix demonstrates high portability across Linux distributions."
elif [ $success_rate -ge 75 ]; then
    echo "👍 **GOOD:** FeNix works well on most tested distributions."
else
    echo "⚠️ **NEEDS IMPROVEMENT:** FeNix has compatibility issues that need addressing."
fi)

## Performance Analysis

$(awk -F',' 'NR>1 && $4>600 {print "- **" $1 " (" $2 "):** " $4 "s (exceeds 10min target)"}' "$RESULTS_DIR/summary.csv")

---
*Generated by FeNix Phoenix Testing Labs*
EOF

    echo -e "${CYAN}📝 Report generated: $report_file${RESET}"
}

# Quick test with common distributions
quick_test() {
    local quick_distros=("ubuntu:22.04" "debian:12" "alpine:3.19")
    local use_local="$1"
    
    echo -e "${YELLOW}⚡ Running quick test with common distributions...${RESET}"
    echo ""
    
    local total=0
    local passed=0
    
    for distro in "${quick_distros[@]}"; do
        total=$((total + 1))
        if test_distribution "$distro" "linux/amd64" "$use_local"; then
            passed=$((passed + 1))
        fi
        echo ""
    done
    
    echo -e "${BOLD}Quick Test Results: $passed/$total passed${RESET}"
}

# Performance benchmark
performance_benchmark() {
    local distro="ubuntu:22.04"
    local arch="linux/amd64"
    local use_local="true"
    local runs=3
    
    echo -e "${YELLOW}⏱️  Running performance benchmark...${RESET}"
    echo -e "${CYAN}Distribution: $distro${RESET}"
    echo -e "${CYAN}Runs: $runs${RESET}"
    echo ""
    
    local total_time=0
    local successful_runs=0
    
    for i in $(seq 1 $runs); do
        echo -e "${CYAN}Run $i/$runs...${RESET}"
        local start_time=$(date +%s)
        
        if test_distribution "$distro" "$arch" "$use_local" >/dev/null 2>&1; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            total_time=$((total_time + duration))
            successful_runs=$((successful_runs + 1))
            echo -e "${GREEN}✅ Run $i: ${duration}s${RESET}"
        else
            echo -e "${RED}❌ Run $i: Failed${RESET}"
        fi
    done
    
    if [ $successful_runs -gt 0 ]; then
        local avg_time=$((total_time / successful_runs))
        echo ""
        echo -e "${BOLD}Performance Results:${RESET}"
        echo -e "${CYAN}Average time: ${avg_time}s${RESET}"
        echo -e "${CYAN}Successful runs: $successful_runs/$runs${RESET}"
        
        if [ $avg_time -lt 300 ]; then
            echo -e "${GREEN}🚀 EXCELLENT: Under 5 minutes average${RESET}"
        elif [ $avg_time -lt 600 ]; then
            echo -e "${YELLOW}👍 GOOD: Under 10 minutes average${RESET}"
        else
            echo -e "${RED}⚠️  SLOW: Over 10 minutes average${RESET}"
        fi
    else
        echo -e "${RED}❌ All benchmark runs failed${RESET}"
    fi
}

# Main function
main() {
    show_banner
    check_prerequisites
    
    case "${1:-full}" in
        "quick")
            quick_test "true"
            ;;
        "remote")
            run_all_tests "false"
            ;;
        "benchmark")
            performance_benchmark
            ;;
        "full"|*)
            run_all_tests "true"
            ;;
    esac
}

# Show usage if requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "FeNix Phoenix Testing Labs - Multi-Distro Validation"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  full       - Test all distributions with local bootstrap (default)"
    echo "  remote     - Test all distributions with remote bootstrap URL"
    echo "  quick      - Quick test with common distributions only"
    echo "  benchmark  - Performance benchmark on Ubuntu"
    echo ""
    echo "Examples:"
    echo "  $0                    # Full test suite"
    echo "  $0 quick             # Quick compatibility test"
    echo "  $0 benchmark         # Performance benchmark"
    echo ""
    exit 0
fi

# Run main function
main "$@"