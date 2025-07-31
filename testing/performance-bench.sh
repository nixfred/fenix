#!/bin/bash
# 🔥 FeNix Phoenix Testing Labs - Performance Benchmarking
# Measures FeNix deployment performance and optimization opportunities

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
TARGET_TIME=600  # 10 minutes in seconds
RESULTS_DIR="perf_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

show_banner() {
    clear
    echo -e "${BOLD}${BLUE}⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡${RESET}"
    echo -e "${BOLD}${YELLOW}       FeNix Performance Labs           ${RESET}"
    echo -e "${BOLD}${CYAN}      Speed is a Feature 🔥             ${RESET}" 
    echo -e "${BOLD}${BLUE}⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡${RESET}"
    echo ""
    echo -e "${CYAN}Target: Complete FeNix deployment in under 10 minutes${RESET}"
    echo ""
}

# Benchmark single run
benchmark_run() {
    local distro="$1"
    local arch="$2"
    local run_number="$3"
    local use_local="$4"
    
    local test_name="${distro//[:\/]/_}_${arch//[:\/]/_}_run${run_number}"
    local log_file="$RESULTS_DIR/${test_name}.log"
    
    echo -e "${CYAN}⚡ Run $run_number: $distro ($arch)${RESET}"
    
    # Prepare performance monitoring script
    local perf_script="/tmp/perf_monitor_${run_number}.sh"
    cat > "$perf_script" << EOF
#!/bin/bash
set -e

# Performance monitoring
start_time=\$(date +%s.%N)
start_epoch=\$(date +%s)

echo "=== Performance Monitoring Started ==="
echo "Start time: \$(date)"
echo "Distribution: $distro"
echo "Architecture: $arch"
echo ""

# Monitor system resources during bootstrap
(
    while true; do
        echo "\$(date +%s.%N),\$(free -m | awk '/^Mem:/ {print \$3}'),\$(ps aux | awk '{sum += \$3} END {print sum}')" >> /tmp/resource_usage.csv
        sleep 5
    done
) &
monitor_pid=\$!

# Run FeNix bootstrap with detailed timing
echo "=== Starting FeNix Bootstrap ==="
if [ "$use_local" = "true" ]; then
    timeout $TARGET_TIME bash -c 'cat /tmp/bootstrap.sh | bash'
else
    timeout $TARGET_TIME bash -c 'curl -s https://raw.githubusercontent.com/nixfred/fenix/main/bootstrap.sh | bash'
fi

# Stop monitoring
kill \$monitor_pid 2>/dev/null || true

end_time=\$(date +%s.%N)
end_epoch=\$(date +%s)

# Calculate performance metrics
total_time=\$(echo "\$end_time - \$start_time" | bc)
total_seconds=\$((end_epoch - start_epoch))

echo ""
echo "=== Performance Results ==="
echo "End time: \$(date)"
echo "Total duration: \${total_time}s"
echo "Total seconds: \${total_seconds}s"

# Resource usage statistics
if [ -f /tmp/resource_usage.csv ]; then
    echo "Peak memory usage: \$(cat /tmp/resource_usage.csv | cut -d',' -f2 | sort -nr | head -1) MB"
    echo "Average CPU usage: \$(cat /tmp/resource_usage.csv | cut -d',' -f3 | awk '{sum+=\$1; count++} END {print sum/count}')%"
fi

# Package installation breakdown
echo ""
echo "=== Installation Breakdown ==="
if grep -q "Installing FeNix essential packages" /tmp/bootstrap.log 2>/dev/null; then
    grep "Installing\|✅\|Complete" /tmp/bootstrap.log | tail -10
fi

echo "=== Performance Test Complete ==="
EOF

    chmod +x "$perf_script"
    
    # Copy local bootstrap if needed
    if [ "$use_local" = "true" ]; then
        cp "/home/pi/fenix/bootstrap.sh" /tmp/bootstrap.sh
    fi
    
    local start_time=$(date +%s)
    local result="PASS"
    local duration=0
    local peak_memory=0
    local avg_cpu=0
    local error_msg=""
    
    # Run performance test
    {
        docker run --rm \
            --name "fenix_perf_${test_name}" \
            --platform "$arch" \
            -v "$perf_script:/tmp/test.sh:ro" \
            $([ "$use_local" = "true" ] && echo "-v /tmp/bootstrap.sh:/tmp/bootstrap.sh:ro") \
            -e "use_local=$use_local" \
            "$distro" \
            /tmp/test.sh
    } > "$log_file" 2>&1 || {
        result="FAIL"
        error_msg=$(tail -5 "$log_file" | head -2 | tr '\n' ' ')
    }
    
    local end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    # Extract performance metrics from log
    if [ "$result" = "PASS" ]; then
        peak_memory=$(grep "Peak memory usage" "$log_file" | grep -o '[0-9]*' | head -1 || echo "0")
        avg_cpu=$(grep "Average CPU usage" "$log_file" | grep -o '[0-9.]*%' | sed 's/%//' | head -1 || echo "0")
    fi
    
    # Clean up
    rm -f "$perf_script"
    [ "$use_local" = "true" ] && rm -f /tmp/bootstrap.sh
    
    # Report results
    local performance_grade=""
    if [ "$result" = "PASS" ]; then
        if [ $duration -lt 300 ]; then
            performance_grade="EXCELLENT"
            echo -e "${GREEN}🚀 EXCELLENT: ${duration}s (under 5min)${RESET}"
        elif [ $duration -lt 600 ]; then
            performance_grade="GOOD"
            echo -e "${YELLOW}👍 GOOD: ${duration}s (under 10min target)${RESET}"
        else
            performance_grade="SLOW"
            echo -e "${YELLOW}⏰ SLOW: ${duration}s (over 10min target)${RESET}"
        fi
        echo -e "${CYAN}   Memory: ${peak_memory}MB peak, CPU: ${avg_cpu}% avg${RESET}"
    else
        performance_grade="FAIL"
        echo -e "${RED}❌ FAILED: ${duration}s${RESET}"
        echo -e "${RED}   Error: ${error_msg}${RESET}"
    fi
    
    # Log results
    echo "$distro,$arch,$run_number,$result,$duration,$peak_memory,$avg_cpu,$performance_grade,$error_msg" >> "$RESULTS_DIR/performance.csv"
    
    return $([ "$result" = "PASS" ] && echo 0 || echo 1)
}

# Multi-run benchmark
multi_run_benchmark() {
    local distro="$1"
    local arch="$2"
    local runs="$3"
    local use_local="$4"
    
    echo -e "${PURPLE}📊 Multi-run benchmark: $distro ($arch) - $runs runs${RESET}"
    echo ""
    
    local successful_runs=0
    local total_time=0
    local min_time=999999
    local max_time=0
    
    for i in $(seq 1 $runs); do
        if benchmark_run "$distro" "$arch" "$i" "$use_local"; then
            successful_runs=$((successful_runs + 1))
            
            # Get duration from last result
            local duration=$(tail -1 "$RESULTS_DIR/performance.csv" | cut -d',' -f5)
            total_time=$((total_time + duration))
            
            if [ $duration -lt $min_time ]; then
                min_time=$duration
            fi
            if [ $duration -gt $max_time ]; then
                max_time=$duration
            fi
        fi
        echo ""
    done
    
    if [ $successful_runs -gt 0 ]; then
        local avg_time=$((total_time / successful_runs))
        
        echo -e "${BOLD}Multi-run Results:${RESET}"
        echo -e "${CYAN}Successful runs: $successful_runs/$runs${RESET}"
        echo -e "${CYAN}Average time: ${avg_time}s${RESET}"
        echo -e "${CYAN}Best time: ${min_time}s${RESET}"
        echo -e "${CYAN}Worst time: ${max_time}s${RESET}"
        
        local consistency_score=$((100 - (max_time - min_time) * 100 / avg_time))
        echo -e "${CYAN}Consistency: ${consistency_score}%${RESET}"
        
        if [ $avg_time -lt 300 ]; then
            echo -e "${GREEN}🏆 Performance Grade: EXCELLENT${RESET}"
        elif [ $avg_time -lt 600 ]; then
            echo -e "${YELLOW}⭐ Performance Grade: GOOD${RESET}"
        else
            echo -e "${RED}⚠️  Performance Grade: NEEDS IMPROVEMENT${RESET}"
        fi
    else
        echo -e "${RED}❌ All benchmark runs failed${RESET}"
    fi
}

# Architecture comparison
architecture_comparison() {
    local distro="$1"
    local use_local="$2"
    
    echo -e "${PURPLE}🏗️  Architecture Comparison: $distro${RESET}"
    echo ""
    
    local amd64_time=0
    local arm64_time=0
    local amd64_result="FAIL"
    local arm64_result="FAIL"
    
    # Test AMD64
    echo -e "${CYAN}Testing AMD64...${RESET}"
    if benchmark_run "$distro" "linux/amd64" "arch" "$use_local"; then
        amd64_result="PASS"
        amd64_time=$(tail -1 "$RESULTS_DIR/performance.csv" | cut -d',' -f5)
    fi
    echo ""
    
    # Test ARM64
    echo -e "${CYAN}Testing ARM64...${RESET}"
    if benchmark_run "$distro" "linux/arm64" "arch" "$use_local"; then
        arm64_result="PASS"
        arm64_time=$(tail -1 "$RESULTS_DIR/performance.csv" | cut -d',' -f5)
    fi
    echo ""
    
    # Comparison
    echo -e "${BOLD}Architecture Comparison Results:${RESET}"
    echo -e "${CYAN}AMD64: $amd64_result (${amd64_time}s)${RESET}"
    echo -e "${CYAN}ARM64: $arm64_result (${arm64_time}s)${RESET}"
    
    if [ "$amd64_result" = "PASS" ] && [ "$arm64_result" = "PASS" ]; then
        local diff=$((amd64_time - arm64_time))
        local abs_diff=${diff#-}  # Absolute value
        local percent_diff=$((abs_diff * 100 / ((amd64_time + arm64_time) / 2)))
        
        if [ $diff -lt 0 ]; then
            echo -e "${GREEN}ARM64 is ${abs_diff}s (${percent_diff}%) faster${RESET}"
        elif [ $diff -gt 0 ]; then
            echo -e "${GREEN}AMD64 is ${abs_diff}s (${percent_diff}%) faster${RESET}"
        else
            echo -e "${GREEN}Performance is identical${RESET}"
        fi
        
        if [ $percent_diff -lt 10 ]; then
            echo -e "${GREEN}✅ Excellent cross-architecture consistency${RESET}"
        elif [ $percent_diff -lt 25 ]; then
            echo -e "${YELLOW}⚠️  Moderate architecture performance difference${RESET}"
        else
            echo -e "${RED}❌ Significant architecture performance gap${RESET}"
        fi
    fi
}

# Distribution performance comparison
distribution_comparison() {
    local arch="$1"
    local use_local="$2"
    local distros=("ubuntu:22.04" "debian:12" "alpine:3.19" "fedora:39")
    
    echo -e "${PURPLE}📋 Distribution Performance Comparison ($arch)${RESET}"
    echo ""
    
    declare -A results
    declare -A times
    
    for distro in "${distros[@]}"; do
        echo -e "${CYAN}Testing $distro...${RESET}"
        if benchmark_run "$distro" "$arch" "distro" "$use_local"; then
            results["$distro"]="PASS"
            times["$distro"]=$(tail -1 "$RESULTS_DIR/performance.csv" | cut -d',' -f5)
        else
            results["$distro"]="FAIL"
            times["$distro"]=999999
        fi
        echo ""
    done
    
    # Sort distributions by performance
    echo -e "${BOLD}Distribution Performance Ranking:${RESET}"
    
    # Create array of distro:time pairs and sort
    local sorted_distros=()
    for distro in "${distros[@]}"; do
        if [ "${results[$distro]}" = "PASS" ]; then
            sorted_distros+=("${times[$distro]}:$distro")
        fi
    done
    
    # Sort by time (numeric)
    IFS=$'\n' sorted_distros=($(sort -n <<<"${sorted_distros[*]}"))
    unset IFS
    
    local rank=1
    for entry in "${sorted_distros[@]}"; do
        local time="${entry%%:*}"
        local distro="${entry#*:}"
        local grade=""
        
        if [ $time -lt 300 ]; then
            grade="🚀 EXCELLENT"
        elif [ $time -lt 600 ]; then
            grade="👍 GOOD"
        else
            grade="⏰ SLOW"
        fi
        
        echo -e "${CYAN}$rank. $distro: ${time}s $grade${RESET}"
        rank=$((rank + 1))
    done
    
    # Show failed distributions
    for distro in "${distros[@]}"; do
        if [ "${results[$distro]}" = "FAIL" ]; then
            echo -e "${RED}❌ $distro: FAILED${RESET}"
        fi
    done
}

# Optimization analysis
optimization_analysis() {
    local log_dir="$1"
    
    echo -e "${PURPLE}🔍 Optimization Analysis${RESET}"
    echo ""
    
    if [ ! -f "$RESULTS_DIR/performance.csv" ]; then
        echo -e "${RED}❌ No performance data available${RESET}"
        return 1
    fi
    
    # Analyze timing patterns
    echo -e "${CYAN}Performance Pattern Analysis:${RESET}"
    
    # Average times by distribution
    echo ""
    echo -e "${YELLOW}Average Times by Distribution:${RESET}"
    awk -F',' 'NR>1 && $4=="PASS" {times[$1] += $5; counts[$1]++} END {for (d in times) printf "  %s: %.1fs\n", d, times[d]/counts[d]}' "$RESULTS_DIR/performance.csv" | sort -k2 -n
    
    # Average times by architecture
    echo ""
    echo -e "${YELLOW}Average Times by Architecture:${RESET}"
    awk -F',' 'NR>1 && $4=="PASS" {times[$2] += $5; counts[$2]++} END {for (a in times) printf "  %s: %.1fs\n", a, times[a]/counts[a]}' "$RESULTS_DIR/performance.csv"
    
    # Performance grades distribution
    echo ""
    echo -e "${YELLOW}Performance Grades:${RESET}"
    awk -F',' 'NR>1 {grades[$8]++} END {for (g in grades) printf "  %s: %d tests\n", g, grades[g]}' "$RESULTS_DIR/performance.csv" | sort
    
    # Bottleneck identification
    echo ""
    echo -e "${YELLOW}Potential Bottlenecks:${RESET}"
    
    # Check for consistently slow distributions
    local slow_distros=$(awk -F',' 'NR>1 && $5>600 {print $1}' "$RESULTS_DIR/performance.csv" | sort | uniq -c | sort -nr | head -3)
    if [ -n "$slow_distros" ]; then
        echo -e "${RED}  Slow distributions:${RESET}"
        echo "$slow_distros" | while read count distro; do
            echo "    $distro (slow in $count tests)"
        done
    fi
    
    # Resource usage analysis
    local high_memory=$(awk -F',' 'NR>1 && $6>500 {print $1}' "$RESULTS_DIR/performance.csv" | sort | uniq -c | sort -nr | head -3)
    if [ -n "$high_memory" ]; then
        echo -e "${YELLOW}  High memory usage:${RESET}"
        echo "$high_memory" | while read count distro; do
            echo "    $distro (>500MB in $count tests)"
        done
    fi
    
    # Recommendations
    echo ""
    echo -e "${GREEN}Optimization Recommendations:${RESET}"
    
    local total_tests=$(tail -n +2 "$RESULTS_DIR/performance.csv" | wc -l)
    local slow_tests=$(awk -F',' 'NR>1 && $5>600' "$RESULTS_DIR/performance.csv" | wc -l)
    local failed_tests=$(awk -F',' 'NR>1 && $4=="FAIL"' "$RESULTS_DIR/performance.csv" | wc -l)
    
    if [ $slow_tests -gt $((total_tests / 4)) ]; then
        echo "  • Consider parallel package installation"
        echo "  • Optimize package selection (remove non-essential packages)"
        echo "  • Implement caching mechanisms"
    fi
    
    if [ $failed_tests -gt 0 ]; then
        echo "  • Improve error handling and retry logic"
        echo "  • Add dependency checks before installation"
    fi
    
    local high_mem_tests=$(awk -F',' 'NR>1 && $6>300' "$RESULTS_DIR/performance.csv" | wc -l)
    if [ $high_mem_tests -gt $((total_tests / 3)) ]; then
        echo "  • Optimize memory usage during installation" 
        echo "  • Consider staged installation approach"
    fi
}

# Generate performance report
generate_performance_report() {
    local report_file="$RESULTS_DIR/performance_report.md"
    
    if [ ! -f "$RESULTS_DIR/performance.csv" ]; then
        echo -e "${RED}❌ No performance data to report${RESET}"
        return 1
    fi
    
    local total_tests=$(tail -n +2 "$RESULTS_DIR/performance.csv" | wc -l)
    local passed_tests=$(awk -F',' 'NR>1 && $4=="PASS"' "$RESULTS_DIR/performance.csv" | wc -l)
    local excellent_tests=$(awk -F',' 'NR>1 && $8=="EXCELLENT"' "$RESULTS_DIR/performance.csv" | wc -l)
    local good_tests=$(awk -F',' 'NR>1 && $8=="GOOD"' "$RESULTS_DIR/performance.csv" | wc -l)
    local slow_tests=$(awk -F',' 'NR>1 && $8=="SLOW"' "$RESULTS_DIR/performance.csv" | wc -l)
    
    local avg_time=$(awk -F',' 'NR>1 && $4=="PASS" {sum+=$5; count++} END {print sum/count}' "$RESULTS_DIR/performance.csv")
    local min_time=$(awk -F',' 'NR>1 && $4=="PASS" {min=min<$5?min:$5} END {print min}' "$RESULTS_DIR/performance.csv")
    local max_time=$(awk -F',' 'NR>1 && $4=="PASS" {max=max>$5?max:$5} END {print max}' "$RESULTS_DIR/performance.csv")
    
    echo -e "${BOLD}${BLUE}⚡ Performance Report${RESET}"
    echo "===================="
    echo ""
    echo -e "${CYAN}Overall Performance:${RESET}"
    echo -e "${GREEN}✅ Successful: $passed_tests/$total_tests${RESET}"
    echo -e "${GREEN}🚀 Excellent (<5min): $excellent_tests${RESET}"
    echo -e "${YELLOW}👍 Good (<10min): $good_tests${RESET}"
    echo -e "${RED}⏰ Slow (>10min): $slow_tests${RESET}"
    echo ""
    echo -e "${CYAN}Timing Statistics:${RESET}"
    printf "${CYAN}Average: %.1fs${RESET}\n" "$avg_time"
    printf "${CYAN}Best: %.0fs${RESET}\n" "$min_time"
    printf "${CYAN}Worst: %.0fs${RESET}\n" "$max_time"
    
    # Performance grade
    local performance_score=$((excellent_tests * 100 / total_tests))
    echo ""
    if [ $performance_score -ge 75 ]; then
        echo -e "${GREEN}🏆 PERFORMANCE GRADE: EXCELLENT${RESET}"
        echo -e "${GREEN}FeNix consistently deploys quickly across platforms${RESET}"
    elif [ $performance_score -ge 50 ]; then
        echo -e "${YELLOW}⭐ PERFORMANCE GRADE: GOOD${RESET}"
        echo -e "${YELLOW}FeNix performs well with room for optimization${RESET}"
    else
        echo -e "${RED}⚠️  PERFORMANCE GRADE: NEEDS IMPROVEMENT${RESET}"
        echo -e "${RED}FeNix deployment times need optimization${RESET}"
    fi
    
    echo ""
    echo -e "${CYAN}📁 Results saved to: $RESULTS_DIR/${RESET}"
    
    # Generate markdown report
    cat > "$report_file" << EOF
# FeNix Performance Benchmark Report

**Generated:** $(date)
**Target:** <10 minutes deployment time

## Summary

- **Total Tests:** $total_tests
- **Successful:** $passed_tests
- **Average Time:** ${avg_time}s
- **Best Time:** ${min_time}s
- **Worst Time:** ${max_time}s

## Performance Grades

- **🚀 Excellent (<5min):** $excellent_tests tests
- **👍 Good (<10min):** $good_tests tests
- **⏰ Slow (>10min):** $slow_tests tests

## Results by Test

$(tail -n +2 "$RESULTS_DIR/performance.csv" | while IFS=',' read -r distro arch run result duration memory cpu grade error; do
    if [ "$result" = "PASS" ]; then
        echo "- **$distro ($arch):** ${duration}s - $grade"
    else
        echo "- **$distro ($arch):** FAILED - $error"
    fi
done)

## Performance Analysis

$(if [ $(echo "$avg_time < 300" | bc -l) -eq 1 ]; then
    echo "🏆 **EXCELLENT PERFORMANCE:** FeNix averages under 5 minutes deployment time."
elif [ $(echo "$avg_time < 600" | bc -l) -eq 1 ]; then
    echo "👍 **GOOD PERFORMANCE:** FeNix meets the 10-minute target with an average of ${avg_time}s."
else
    echo "⚠️ **PERFORMANCE IMPROVEMENT NEEDED:** FeNix exceeds the 10-minute target."
fi)

## Recommendations

$(if [ $slow_tests -gt 0 ]; then
    echo "### Optimization Opportunities"
    echo "- Review package installation efficiency"
    echo "- Consider parallel installation strategies"
    echo "- Optimize network operations and downloads"
    echo "- Implement package caching mechanisms"
fi)

---
*Generated by FeNix Performance Labs*
EOF

    echo -e "${CYAN}📝 Detailed report: $report_file${RESET}"
}

# Main function
main() {
    show_banner
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is required for performance testing${RESET}"
        exit 1
    fi
    
    # Initialize CSV
    echo "distro,arch,run,result,duration,peak_memory,avg_cpu,grade,error" > "$RESULTS_DIR/performance.csv"
    
    case "${1:-single}" in
        "single")
            benchmark_run "ubuntu:22.04" "linux/amd64" "1" "true"
            ;;
        "multi")
            multi_run_benchmark "ubuntu:22.04" "linux/amd64" "3" "true"
            ;;
        "arch")
            architecture_comparison "ubuntu:22.04" "true"
            ;;
        "distro")
            distribution_comparison "linux/amd64" "true"
            ;;
        "full")
            echo -e "${YELLOW}🚀 Running comprehensive performance benchmark...${RESET}"
            echo ""
            
            # Test key distributions
            local distros=("ubuntu:22.04" "debian:12" "alpine:3.19")
            local arch="linux/amd64"
            
            for distro in "${distros[@]}"; do
                benchmark_run "$distro" "$arch" "full" "true"
                echo ""
            done
            
            # Architecture comparison on Ubuntu
            architecture_comparison "ubuntu:22.04" "true"
            ;;
        "analyze")
            optimization_analysis
            ;;
    esac
    
    # Generate report if we have data
    if [ -f "$RESULTS_DIR/performance.csv" ] && [ $(wc -l < "$RESULTS_DIR/performance.csv") -gt 1 ]; then
        echo ""
        generate_performance_report
        echo ""
        optimization_analysis
    fi
}

# Show usage if requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "FeNix Performance Benchmark"  
    echo ""
    echo "Usage: $0 [test_type]"
    echo ""
    echo "Test Types:"
    echo "  single     - Single benchmark run (default)"
    echo "  multi      - Multiple runs for consistency"
    echo "  arch       - Architecture comparison (AMD64 vs ARM64)"
    echo "  distro     - Distribution performance comparison"
    echo "  full       - Comprehensive benchmark suite"
    echo "  analyze    - Analyze existing results"
    echo ""
    echo "Examples:"
    echo "  $0                    # Single benchmark"
    echo "  $0 multi             # Multi-run benchmark"
    echo "  $0 arch              # Architecture comparison"
    echo "  $0 full              # Full benchmark suite"
    echo ""
    exit 0
fi

# Run main function
main "$@"