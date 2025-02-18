#!/bin/bash

# Function to analyze traceroute output
analyze_traceroute() {
    local high_latency_threshold=100  # Warn if RTT > 100ms
    local severe_latency_threshold=200  # Critical if RTT > 200ms

    echo -e "\n🔍 Analyzing traceroute...\n"
    
    local last_hop=""
    local final_hop_reached=false
    local issues=()

    while IFS= read -r line; do
        if [[ $line =~ ^[0-9]+ ]]; then
            # Extract hop number, RTTs, hostname, and IP
            hop=$(echo "$line" | awk '{print $1}')
            rtt1=$(echo "$line" | awk '{print $2}')
            rtt2=$(echo "$line" | awk '{print $3}')
            rtt3=$(echo "$line" | awk '{print $4}')
            hostname=$(echo "$line" | awk '{print $5}')
            ip=$(echo "$line" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

            # Remove ms from RTT values and handle missing values
            rtt1=${rtt1/ms/}
            rtt2=${rtt2/ms/}
            rtt3=${rtt3/ms/}

            if [[ "$rtt1" == "*" && "$rtt2" == "*" && "$rtt3" == "*" ]]; then
                echo -e "⚠️  Hop $hop ($hostname [$ip]) is not responding. Likely ICMP filtering."
                issues+=("Hop $hop: ICMP filtering detected.")
            else
                # Convert RTT values to numeric and calculate average RTT
                rtt1=${rtt1:-0}
                rtt2=${rtt2:-0}
                rtt3=${rtt3:-0}
                avg_rtt=$(( (rtt1 + rtt2 + rtt3) / 3 ))

                echo "✅ Hop $hop ($hostname [$ip]): Avg ${avg_rtt}ms"

                if (( avg_rtt > high_latency_threshold && avg_rtt < severe_latency_threshold )); then
                    echo -e "⚠️  Warning: High latency detected at Hop $hop (${avg_rtt}ms)"
                    issues+=("Hop $hop: High latency detected (${avg_rtt}ms).")
                elif (( avg_rtt >= severe_latency_threshold )); then
                    echo -e "🚨 Critical: Severe latency detected at Hop $hop (${avg_rtt}ms)"
                    issues+=("Hop $hop: Severe latency detected (${avg_rtt}ms).")
                fi
            fi

            last_hop=$hop
        fi
    done

    echo -e "\n🔎 Summary Report:\n"
    if [[ ${#issues[@]} -eq 0 ]]; then
        echo "✅ No major issues detected in the traceroute."
    else
        for issue in "${issues[@]}"; do
            echo "⚠️  $issue"
        done
    fi

    # Check if final hop reached
    if [[ "$last_hop" != "" ]]; then
        echo -e "\n📌 Checking final hop..."
        echo "✅ Final destination reached successfully."
    else
        echo "❌ Final destination NOT reached. Possible routing issue."
    fi
}

# Main script
echo "📋 Paste your traceroute output below and press Ctrl+D when done:"
analyze_traceroute
