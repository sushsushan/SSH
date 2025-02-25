#!/bin/bash

# Define colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No color

# Run the uapi command to get domain details
output=$(uapi DomainInfo domains_data)

# Extract required fields using grep and awk
domains=($(echo "$output" | grep -E "domain: " | awk '{print $2}'))
documentroots=($(echo "$output" | grep -E "documentroot: " | awk '{print $2}'))
types=($(echo "$output" | grep -E "type: " | awk '{print $2}'))

# Calculate the number of domains found
count=${#domains[@]}

# Initialize counters for domain types
main_count=0
addon_count=0
parked_count=0
subdomain_count=0

# Set column widths dynamically based on content
domain_width=50
path_width=80
type_width=20

# Function to print a table border
print_border() {
    printf "${MAGENTA}+%-${domain_width}s+%-${path_width}s+%-${type_width}s+${NC}\n" \
        "$(printf -- '-%.0s' $(seq 1 $domain_width))" \
        "$(printf -- '-%.0s' $(seq 1 $path_width))" \
        "$(printf -- '-%.0s' $(seq 1 $type_width))"
}

# Print header with border
print_border
printf "${MAGENTA}| ${BLUE}%-${domain_width}s${MAGENTA} | ${YELLOW}%-${path_width}s${MAGENTA} | ${GREEN}%-${type_width}s${MAGENTA} |\n${NC}" "Domain Name" "Document Root/Path" "Type"
print_border

# Print rows of the table
for ((i=0; i<count; i++)); do
    # Count domain types
    case "${types[i]}" in
        main) ((main_count++)) ;;
        addon) ((addon_count++)) ;;
        parked) ((parked_count++)) ;;
        subdomain) ((subdomain_count++)) ;;
    esac
    
    # Set row color based on type
    row_color=$NC
    case "${types[i]}" in
        main) row_color=$CYAN ;;
        addon) row_color=$YELLOW ;;
        parked) row_color=$RED ;;
        subdomain) row_color=$GREEN ;;
    esac
    
    # Print table row
    printf "${MAGENTA}| ${NC}%-${domain_width}s ${MAGENTA}| ${NC}%-${path_width}s ${MAGENTA}| ${row_color}%-${type_width}s ${MAGENTA}|\n${NC}" \
        "${domains[i]}" "${documentroots[i]}" "${types[i]}"
done

# Print bottom border
print_border

# Print summary with colors
total_domains=$((main_count + addon_count + parked_count + subdomain_count))

echo -e "\n${CYAN}Summary:${NC}"
printf "  ${BLUE}%-20s ${NC}%d\n" "Main Domains:" "$main_count"
printf "  ${YELLOW}%-20s ${NC}%d\n" "Addon Domains:" "$addon_count"
printf "  ${RED}%-20s ${NC}%d\n" "Parked Domains:" "$parked_count"
printf "  ${GREEN}%-20s ${NC}%d\n" "Subdomains:" "$subdomain_count"
printf "  ${MAGENTA}%-20s ${NC}%d\n\n" "Total Domains:" "$total_domains"
