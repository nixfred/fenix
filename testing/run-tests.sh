#!/bin/bash
# 🔥 FeNix Phoenix Testing Labs - Master Test Runner
# Orchestrates all FeNix testing suites

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
SCRIPT_DIR="$(dirname "$0")"
RESULTS_DIR="phoenix_labs_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

show_banner() {
    clear
    echo -e "${BOLD}${RED}🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥${RESET}"
    echo -e "${BOLD}${YELLOW}                 FeNix Phoenix Testing Labs                ${RESET}"
    echo -e "${BOLD}${CYAN}                Rise from the Ashes, Stronger              ${RESET}"
    echo -e "${BOLD}${RED}🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥${RESET}"
    echo ""
    echo -e "${CYAN}Comprehensive testing suite for FeNix Phoenix System${RESET}"
    echo -e "${CYAN}Validates portability, resilience, and performance${RESET}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    echo -e "${CYAN}🔍 Checking prerequisites...${RESET}"
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is required for testing${RESET}"
        echo -e "${CYAN}💡 Install Docker: sudo apt install docker.io${RESET}"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker daemon is not running${RESET}"
        echo -e "${CYAN}💡 Start Docker: sudo systemctl start docker${RESET}"
        exit 1
    fi
    
    # Check Docker permissions
    if ! docker run --rm hello-world >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Docker permissions issue. You may need to:${RESET}"
        echo -e "${CYAN}   sudo usermod -aG docker \$USER${RESET}"
        echo -e "${CYAN}   Then log out and back in${RESET}"
    fi
    
    # Check for bc (used in performance calculations)
    if ! command -v bc >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Installing bc for calculations...${RESET}"
        if command -v apt >/dev/null 2>&1; then
            sudo apt install -y bc
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y bc
        fi
    fi
    
    echo -e "${GREEN}✅ Prerequisites check completed${RESET}"
    echo ""
}

# Run multi-distro tests
run_multi_distro_tests() {
    echo -e "${PURPLE}🌍 Running Multi-Distro Compatibility Tests${RESET}"
    echo "============================================"
    
    local test_type="${1:-full}"
    local start_time=$(date +%s)
    
    if [ -f "$SCRIPT_DIR/multi-distro-test.sh" ]; then
        "$SCRIPT_DIR/multi-distro-test.sh" "$test_type" 2>&1 | tee "$RESULTS_DIR/multi-distro.log"
        local exit_code=${PIPESTATUS[0]}
        
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✅ Multi-distro tests completed successfully${RESET}"
        else
            echo -e "${RED}❌ Multi-distro tests encountered issues${RESET}"
        fi
    else
        echo -e "${RED}❌ Multi-distro test script not found${RESET}"
        exit_code=1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "multi-distro,$test_type,$exit_code,$duration" >> "$RESULTS_DIR/test_summary.csv"
    echo ""
    
    return $exit_code
}

# Run chaos engineering tests
run_chaos_tests() {
    echo -e "${PURPLE}💥 Running Chaos Engineering Tests${RESET}"
    echo "==================================="
    
    local scenario="${1:-all}"
    local start_time=$(date +%s)
    
    if [ -f "$SCRIPT_DIR/chaos-engineering.sh" ]; then
        "$SCRIPT_DIR/chaos-engineering.sh" "$scenario" 2>&1 | tee "$RESULTS_DIR/chaos.log"
        local exit_code=${PIPESTATUS[0]}
        
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✅ Chaos engineering tests completed${RESET}"
        else
            echo -e "${RED}❌ Chaos engineering tests encountered failures${RESET}"
        fi
    else
        echo -e "${RED}❌ Chaos engineering test script not found${RESET}"
        exit_code=1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "chaos,$scenario,$exit_code,$duration" >> "$RESULTS_DIR/test_summary.csv"
    echo ""
    
    return $exit_code
}

# Run performance benchmarks
run_performance_tests() {
    echo -e "${PURPLE}⚡ Running Performance Benchmarks${RESET}"
    echo "================================="
    
    local test_type="${1:-single}"
    local start_time=$(date +%s)
    
    if [ -f "$SCRIPT_DIR/performance-bench.sh" ]; then
        "$SCRIPT_DIR/performance-bench.sh" "$test_type" 2>&1 | tee "$RESULTS_DIR/performance.log"
        local exit_code=${PIPESTATUS[0]}
        
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✅ Performance benchmarks completed${RESET}"
        else
            echo -e "${RED}❌ Performance benchmarks encountered issues${RESET}"
        fi
    else
        echo -e "${RED}❌ Performance benchmark script not found${RESET}"
        exit_code=1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "performance,$test_type,$exit_code,$duration" >> "$RESULTS_DIR/test_summary.csv"
    echo ""
    
    return $exit_code
}

# Quick validation suite
quick_validation() {
    echo -e "${YELLOW}⚡ Running Quick Validation Suite${RESET}"
    echo ""
    
    local overall_result="PASS"
    
    # Quick multi-distro test
    echo -e "${CYAN}1/3: Quick Multi-Distro Test${RESET}"
    if ! run_multi_distro_tests "quick"; then
        overall_result="FAIL"
    fi
    
    # Quick chaos test
    echo -e "${CYAN}2/3: Quick Chaos Test${RESET}"
    if ! run_chaos_tests "quick"; then
        overall_result="FAIL"
    fi
    
    # Single performance test
    echo -e "${CYAN}3/3: Performance Test${RESET}"
    if ! run_performance_tests "single"; then
        overall_result="FAIL"
    fi
    
    # Summary
    echo -e "${BOLD}${CYAN}Quick Validation Results${RESET}"
    echo "========================"
    
    if [ "$overall_result" = "PASS" ]; then
        echo -e "${GREEN}🎉 FeNix passes quick validation!${RESET}"
        echo -e "${GREEN}   Ready for production deployment${RESET}"
    else
        echo -e "${RED}⚠️  FeNix has validation issues${RESET}"
        echo -e "${RED}   Review detailed logs before deployment${RESET}"
    fi
    
    return $([ "$overall_result" = "PASS" ] && echo 0 || echo 1)
}

# Comprehensive test suite
comprehensive_testing() {
    echo -e "${YELLOW}🏆 Running Comprehensive Test Suite${RESET}"
    echo ""
    
    local test_results=()
    local overall_start=$(date +%s)
    
    # Full multi-distro testing
    echo -e "${CYAN}Phase 1/3: Comprehensive Multi-Distro Testing${RESET}"
    if run_multi_distro_tests "full"; then
        test_results+=("multi-distro:PASS")
    else
        test_results+=("multi-distro:FAIL")
    fi
    
    # Full chaos engineering
    echo -e "${CYAN}Phase 2/3: Full Chaos Engineering Suite${RESET}"
    if run_chaos_tests "all"; then
        test_results+=("chaos:PASS")
    else
        test_results+=("chaos:FAIL")
    fi
    
    # Performance benchmarking
    echo -e "${CYAN}Phase 3/3: Performance Benchmarking${RESET}"
    if run_performance_tests "full"; then
        test_results+=("performance:PASS")
    else
        test_results+=("performance:FAIL")
    fi
    
    local overall_end=$(date +%s)
    local total_duration=$((overall_end - overall_start))
    
    # Generate comprehensive report
    generate_comprehensive_report "${test_results[@]}" "$total_duration"
}

# CI/CD focused testing
ci_testing() {
    echo -e "${YELLOW}🚀 Running CI/CD Test Suite${RESET}"
    echo ""
    
    # Optimized for CI environments
    local ci_results=()
    
    # Limited multi-distro (key distributions only)
    echo -e "${CYAN}CI Test 1/3: Key Distribution Compatibility${RESET}"
    if run_multi_distro_tests "quick"; then
        ci_results+=("distro:PASS")
    else
        ci_results+=("distro:FAIL")
    fi
    
    # Essential chaos scenarios
    echo -e "${CYAN}CI Test 2/3: Critical Resilience Tests${RESET}"
    if run_chaos_tests "quick"; then
        ci_results+=("resilience:PASS") 
    else
        ci_results+=("resilience:FAIL")
    fi
    
    # Performance baseline
    echo -e "${CYAN}CI Test 3/3: Performance Baseline${RESET}"
    if run_performance_tests "single"; then
        ci_results+=("performance:PASS")
    else
        ci_results+=("performance:FAIL")
    fi
    
    # CI summary
    local passed_tests=0
    local total_tests=${#ci_results[@]}
    
    for result in "${ci_results[@]}"; do
        if [[ "$result" == *":PASS" ]]; then
            passed_tests=$((passed_tests + 1))
        fi
    done
    
    echo ""
    echo -e "${BOLD}${CYAN}CI/CD Test Results${RESET}"
    echo "==================="
    echo -e "${CYAN}Passed: $passed_tests/$total_tests${RESET}"
    
    if [ $passed_tests -eq $total_tests ]; then
        echo -e "${GREEN}✅ CI/CD PASS: FeNix ready for deployment${RESET}"
        return 0
    else
        echo -e "${RED}❌ CI/CD FAIL: FeNix not ready for deployment${RESET}"
        echo ""
        echo -e "${YELLOW}Failed tests:${RESET}"
        for result in "${ci_results[@]}"; do
            if [[ "$result" == *":FAIL" ]]; then
                echo -e "${RED}  ❌ ${result%:*}${RESET}"
            fi
        done
        return 1
    fi
}

# Generate comprehensive report
generate_comprehensive_report() {
    local test_results=("$@")
    local total_duration="${test_results[-1]}"
    unset test_results[-1]  # Remove duration from results array
    
    local report_file="$RESULTS_DIR/phoenix_labs_report.md"
    
    echo -e "${BOLD}${BLUE}🔥 Phoenix Labs Comprehensive Report${RESET}"
    echo "====================================="
    echo ""
    
    # Calculate overall metrics
    local total_tests=${#test_results[@]}
    local passed_tests=0
    
    for result in "${test_results[@]}"; do
        if [[ "$result" == *":PASS" ]]; then
            passed_tests=$((passed_tests + 1))
        fi
    done
    
    local success_rate=$((passed_tests * 100 / total_tests))
    
    echo -e "${CYAN}Overall Results:${RESET}"
    echo -e "${GREEN}✅ Passed: $passed_tests/$total_tests${RESET}"
    echo -e "${CYAN}Success Rate: $success_rate%${RESET}"
    echo -e "${CYAN}Total Duration: $((total_duration / 60))m $((total_duration % 60))s${RESET}"
    echo ""
    
    # Test category results
    echo -e "${CYAN}Test Category Results:${RESET}"
    for result in "${test_results[@]}"; do
        local category="${result%:*}"
        local status="${result#*:}"
        
        if [ "$status" = "PASS" ]; then
            echo -e "${GREEN}  ✅ $category${RESET}"
        else
            echo -e "${RED}  ❌ $category${RESET}"
        fi
    done
    echo ""
    
    # Overall grade
    local overall_grade=""
    if [ $success_rate -eq 100 ]; then
        overall_grade="🏆 PHOENIX GOLD"
        echo -e "${GREEN}${BOLD}🏆 PHOENIX GOLD: FeNix achieves perfect test results!${RESET}"
        echo -e "${GREEN}   Ready for production deployment across all environments${RESET}"
    elif [ $success_rate -ge 90 ]; then
        overall_grade="🥈 PHOENIX SILVER"
        echo -e "${YELLOW}${BOLD}🥈 PHOENIX SILVER: FeNix performs excellently${RESET}"
        echo -e "${YELLOW}   Minor issues detected, but production ready${RESET}"
    elif [ $success_rate -ge 75 ]; then
        overall_grade="🥉 PHOENIX BRONZE"
        echo -e "${YELLOW}${BOLD}🥉 PHOENIX BRONZE: FeNix shows good resilience${RESET}"
        echo -e "${YELLOW}   Some issues need addressing before wide deployment${RESET}"
    else
        overall_grade="⚠️ NEEDS IMPROVEMENT"
        echo -e "${RED}${BOLD}⚠️  NEEDS IMPROVEMENT: FeNix has significant issues${RESET}"
        echo -e "${RED}   Major improvements needed before production deployment${RESET}"
    fi
    
    echo ""
    echo -e "${CYAN}📁 Detailed results in: $RESULTS_DIR/${RESET}"
    echo -e "${CYAN}📊 Individual test logs available for analysis${RESET}"
    
    # Generate markdown report
    cat > "$report_file" << EOF
# FeNix Phoenix Testing Labs - Comprehensive Report

**Generated:** $(date)
**Duration:** $((total_duration / 60))m $((total_duration % 60))s
**Overall Grade:** $overall_grade

## Executive Summary

FeNix Phoenix System achieved a **$success_rate%** success rate across all testing categories.

- **Total Tests:** $total_tests categories
- **Passed:** $passed_tests
- **Failed:** $((total_tests - passed_tests))

## Test Results by Category

$(for result in "${test_results[@]}"; do
    category="${result%:*}"
    status="${result#*:}"
    if [ "$status" = "PASS" ]; then
        echo "- **$category:** ✅ PASS"
    else
        echo "- **$category:** ❌ FAIL"
    fi
done)

## Phoenix Labs Certification

$(if [ $success_rate -eq 100 ]; then
    echo "🏆 **PHOENIX GOLD CERTIFICATION**"
    echo ""
    echo "FeNix has achieved perfect test results across all categories:"
    echo "- Multi-distribution compatibility"
    echo "- Chaos resilience"
    echo "- Performance benchmarks"
    echo ""
    echo "**Recommendation:** Production ready for all environments"
elif [ $success_rate -ge 90 ]; then
    echo "🥈 **PHOENIX SILVER CERTIFICATION**"
    echo ""
    echo "FeNix demonstrates excellent performance with minor issues."
    echo ""
    echo "**Recommendation:** Production ready with noted limitations"
elif [ $success_rate -ge 75 ]; then
    echo "🥉 **PHOENIX BRONZE CERTIFICATION**"
    echo ""
    echo "FeNix shows good resilience but has areas for improvement."
    echo ""
    echo "**Recommendation:** Suitable for controlled deployments"
else
    echo "⚠️ **IMPROVEMENT REQUIRED**"
    echo ""
    echo "FeNix has significant issues that need addressing."
    echo ""
    echo "**Recommendation:** Not ready for production deployment"
fi)

## Detailed Results

Individual test results and logs are available in the following files:

- **Multi-Distro Tests:** \`multi-distro.log\`
- **Chaos Engineering:** \`chaos.log\`
- **Performance Benchmarks:** \`performance.log\`
- **Test Summary:** \`test_summary.csv\`

## Next Steps

$(if [ $success_rate -lt 100 ]; then
    echo "### Priority Improvements"
    for result in "${test_results[@]}"; do
        if [[ "$result" == *":FAIL" ]]; then
            category="${result%:*}"
            case "$category" in
                "multi-distro") echo "- Review distribution compatibility issues" ;;
                "chaos") echo "- Improve resilience under adverse conditions" ;;
                "performance") echo "- Optimize deployment speed and resource usage" ;;
            esac
        fi
    done
else
    echo "### Maintenance"
    echo "- Continue regular Phoenix Labs testing"
    echo "- Monitor performance metrics in production"
    echo "- Update test suites as new requirements emerge"
fi)

---
*Generated by FeNix Phoenix Testing Labs - Rise from the ashes, stronger! 🔥*
EOF

    echo -e "${CYAN}📝 Comprehensive report: $report_file${RESET}"
}

# Show test menu
show_test_menu() {
    echo -e "${YELLOW}🧪 FeNix Phoenix Testing Labs${RESET}"
    echo "============================="
    echo ""
    echo "Available test suites:"
    echo ""
    echo "  1) quick          - Quick validation (3 tests, ~10 minutes)"
    echo "  2) comprehensive  - Full test suite (all tests, ~45 minutes)"
    echo "  3) ci             - CI/CD optimized suite (~15 minutes)"
    echo ""
    echo "Individual test categories:"
    echo "  4) multi-distro   - Multi-distribution compatibility"
    echo "  5) chaos          - Chaos engineering and resilience"
    echo "  6) performance    - Performance benchmarking"
    echo ""
    echo "  0) exit           - Exit testing labs"
    echo ""
    
    read -p "Select test suite [1-6, 0]: " choice
    
    case "$choice" in
        1) quick_validation ;;
        2) comprehensive_testing ;;
        3) ci_testing ;;
        4) 
            echo "Multi-distro test options: quick, full, remote"
            read -p "Enter option [quick]: " distro_option
            run_multi_distro_tests "${distro_option:-quick}"
            ;;
        5)
            echo "Chaos test scenarios: all, network, resources, disk, repos, permissions, quick, stress"
            read -p "Enter scenario [quick]: " chaos_scenario
            run_chaos_tests "${chaos_scenario:-quick}"
            ;;
        6)
            echo "Performance test types: single, multi, arch, distro, full"
            read -p "Enter type [single]: " perf_type
            run_performance_tests "${perf_type:-single}"
            ;;
        0) 
            echo "Exiting Phoenix Labs..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid selection${RESET}"
            show_test_menu
            ;;
    esac
}

# Main function
main() {
    show_banner
    check_prerequisites
    
    # Initialize test summary
    echo "test_category,test_type,exit_code,duration" > "$RESULTS_DIR/test_summary.csv"
    
    case "${1:-menu}" in
        "quick")
            quick_validation
            ;;
        "comprehensive"|"full")
            comprehensive_testing
            ;;
        "ci")
            ci_testing
            ;;
        "multi-distro")
            run_multi_distro_tests "${2:-quick}"
            ;;
        "chaos")
            run_chaos_tests "${2:-quick}"
            ;;
        "performance")
            run_performance_tests "${2:-single}"
            ;;
        "menu"|*)
            show_test_menu
            ;;
    esac
}

# Show usage if requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "FeNix Phoenix Testing Labs - Master Test Runner"
    echo ""
    echo "Usage: $0 [suite] [options]"
    echo ""
    echo "Test Suites:"
    echo "  quick          - Quick validation suite"
    echo "  comprehensive  - Complete test suite"
    echo "  ci             - CI/CD optimized testing"
    echo "  multi-distro   - Multi-distribution tests [quick|full|remote]"
    echo "  chaos          - Chaos engineering tests [scenario]"
    echo "  performance    - Performance benchmarks [type]"
    echo "  menu           - Interactive menu (default)"
    echo ""
    echo "Examples:"
    echo "  $0                         # Interactive menu"
    echo "  $0 quick                   # Quick validation"
    echo "  $0 comprehensive           # Full test suite"
    echo "  $0 ci                      # CI/CD testing"
    echo "  $0 multi-distro full       # Full multi-distro tests"
    echo "  $0 chaos stress            # Chaos stress testing"
    echo "  $0 performance arch        # Architecture comparison"
    echo ""
    exit 0
fi

# Run main function
main "$@"