for log in ~/access-logs/*-ssl_log; do
    domain=$(basename "$log" | sed 's/-ssl_log//')
    total_requests=$(wc -l < "$log")

    # Skip domains with zero hits
    if [[ "$total_requests" -eq 0 ]]; then
        continue
    fi

    total_unique_ips=$(awk '{print $1}' "$log" | sort -u | wc -l)
    total_pages_requested=$(awk '{print $7}' "$log" | sort -u | wc -l)
    bot_hits=$(grep -i bot "$log" | wc -l)
    xmlrpc_hits=$(grep -i xmlrpc "$log" | wc -l)
    slow_requests=$(awk '$NF > 3 {print $7}' "$log" | wc -l)  # Requests taking more than 3s
    top_user_agents=$(awk -F\" '{print $6}' "$log" | sort | uniq -c | sort -rn | head -5)

    echo -e "\n============================================================="
    echo " Domain: $domain"
    echo "-------------------------------------------------------------"
    echo " Total Requests:         $total_requests"
    echo " Unique Visitors (IPs):  $total_unique_ips"
    echo " Unique Pages Requested: $total_pages_requested"
    echo " Bot Hits:              $bot_hits"
    echo " XMLRPC Hits:           $xmlrpc_hits"
    echo " Slow Requests (>3s):   $slow_requests"
    echo "============================================================="

    echo -e "\n Top 10 IPs Accessing $domain:"
    echo "-------------------------------------------------------------"
    awk '{print $1}' "$log" | sort | uniq -c | sort -rn | head | awk '{printf " %5s requests - %s\n", $1, $2}'

    echo -e "\n Top 10 Most Requested Pages:"
    echo "-------------------------------------------------------------"
    awk '{print $7}' "$log" | sort | uniq -c | sort -rn | head | awk '{printf " %5s requests - %s\n", $1, $2}'

    echo -e "\n Top 5 User Agents:"
    echo "-------------------------------------------------------------"
    echo "$top_user_agents"

    echo "============================================================="
done
