#!/bin/bash

# Function to check if a domain is reachable using HTTP
check_domain_reachability() {
  domain=$1
  echo "Checking domain reachability..."
  
  # Using curl with a custom User-Agent to avoid 403 errors
  http_status=$(curl -Is "$domain" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" | head -n 1)
  
  if [[ "$http_status" =~ "200 OK" ]]; then
    echo "$domain is reachable."
  else
    echo "$domain is not reachable. HTTP Status: $http_status"
    exit 1
  fi
}

# Function to measure the response time using curl
measure_response_time() {
  domain=$1
  echo "Measuring server response time..."
  
  # Use curl to fetch the page and measure response time
  response_time=$(curl -o /dev/null -s -w "%{time_total}\n" "$domain")
  echo "Server Response Time: $response_time seconds"
}

# Function to run WebPageTest (using their public API)
run_webpagetest() {
  domain=$1
  echo "Running WebPageTest..."

  api_key="your_webpagetest_api_key"  # Replace with your WebPageTest API key
  result=$(curl -s "https://www.webpagetest.org/runtest.php?url=$domain&k=$api_key")
  test_url=$(echo $result | grep -oP 'http://www.webpagetest.org/result/\K[^"]+')
  echo "Test result available at: https://www.webpagetest.org/result/$test_url"
}

# Function to fetch Google PageSpeed Insights (using their public API)
run_pagespeed_insights() {
  domain=$1
  api_key="your_google_pagespeed_api_key"  # Replace with your Google API key
  echo "Fetching Google PageSpeed Insights..."
  
  result=$(curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=$domain&key=$api_key")
  
  # Extract relevant info from the result
  score=$(echo $result | jq '.lighthouseResult.categories.performance.score' | sed 's/\.//')
  load_time=$(echo $result | jq '.lighthouseResult.audits["first-contentful-paint"].displayValue')
  suggestions=$(echo $result | jq '.lighthouseResult.audits["unused-css-rules"].details.items' | wc -l)

  echo "PageSpeed Insights Performance Score: $score/100"
  echo "First Contentful Paint: $load_time"
  echo "Unused CSS Rules Suggestions: $suggestions"
}

# Main function to execute the full website performance check
check_website_performance() {
  domain=$1
  echo "Performing advanced website speed and optimization check for: $domain"
  
  # Check domain reachability
  check_domain_reachability "$domain"
  
  # Measure server response time
  measure_response_time "$domain"
  
  # Run WebPageTest for more detailed analysis (optional)
  run_webpagetest "$domain"
  
  # Fetch PageSpeed Insights for suggestions (optional)
  run_pagespeed_insights "$domain"
}

# User input
echo "Enter domain name to check (e.g., example.com):"
read domain_name
check_website_performance "$domain_name"
