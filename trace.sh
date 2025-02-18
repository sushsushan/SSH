#!/bin/bash

# Advanced Traceroute Analyzer Script
# Parses a pasted traceroute result, analyzes hops, and provides detailed insights

# Function to check if a value is numeric
is_numeric() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Function to analyze a single hop
analyze_hop() {
    local hop_line="$1"
    local hop_num hop_ip rtt1 rtt2 rtt3

    # Extract hop number, IP, and RTT values
    hop_num=$(echo "$hop_line" | awk '{print $1}')
    hop_ip=$(echo "$hop_line" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
    rtt1=$(echo "$hop_line" | awk '{print $2}')
    rtt2=$(echo "$hop_line" | awk '{print $3}')
    rtt3=$(echo "$hop_line" | awk '{print $4}')

    # Handle timeout cases
    if [[ "$hop_line" == *"* * *"* ]]; then
        echo "Hop $hop_num: [TIMEOUT] No response from this router. This may be normal if the router does not respond to ICMP."
        return
    fi

    # Analyze latency (set warning threshold at 100ms, critical at 200ms)
    if is_numeric "$rtt1" && (( $(echo "$rtt1 > 100" | bc -l) )); then
        if (( $(echo "$rtt1 > 200" | bc -l) )); then
            echo "Hop $hop_num ($hop_ip): [CRITICAL] High latency detected ($rtt1 ms). Check network congestion or routing issues."
        else
            echo "Hop $hop_num ($hop_ip): [WARNING] Elevated latency ($rtt1 ms)."
        fi
    else
        echo "Hop $hop_num ($hop_ip): Normal response time ($rtt1 ms)."
    fi
}

# Main function to process traceroute input
analyze_traceroute() {
    echo "Paste your traceroute output below, then press Ctrl+D to analyze:"
    
    local hop_lines=()
    while IFS= read -r line; do
        hop_lines+=("$line")
    done
    
    echo "\nAnalyzing Traceroute..."
    for hop in "${hop_lines[@]}"; do
        analyze_hop "$hop"
    done
    
    echo "\nAnalysis Complete. If high latency or packet loss is detected, investigate further."
}

# Run the script
analyze_traceroute
